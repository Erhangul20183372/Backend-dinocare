import type { Pool, PoolClient, QueryResult, QueryResultRow } from "pg";
import { setUserContext } from "./user-context.helper";

export abstract class BaseRepository {
  protected readonly pool: Pool;
  private activeClient?: PoolClient;

  constructor(pool: Pool) {
    this.pool = pool;
  }

  protected async query<T extends QueryResultRow>(text: string, params?: any[]): Promise<QueryResult<T>> {
    const client = this.activeClient ?? (await this.pool.connect());
    const isTemp = !this.activeClient;

    try {
      if (isTemp) {
        await client.query("BEGIN");
        await setUserContext(client);
      }

      const result = await client.query<T>(text, params);

      if (isTemp) await client.query("COMMIT");
      return result;
    } catch (err) {
      if (isTemp) await client.query("ROLLBACK");
      throw err;
    } finally {
      if (isTemp) client.release();
    }
  }

  public setActiveClient(client?: PoolClient) {
    this.activeClient = client;
  }
}

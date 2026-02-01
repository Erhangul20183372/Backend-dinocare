import type { Pool } from "pg";
import { BaseRepository } from "./base.repository";
import { setUserContext } from "./user-context.helper";

export class TransactionManager {
  constructor(private readonly pool: Pool) {}

  async run<T>(fn: () => Promise<T>, repos: BaseRepository[] = []): Promise<T> {
    const client = await this.pool.connect();
    try {
      await client.query("BEGIN");
      await setUserContext(client);

      for (const repo of repos) repo.setActiveClient(client);

      const result = await fn();

      await client.query("COMMIT");
      return result;
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      for (const repo of repos) repo.setActiveClient(undefined);
      client.release();
    }
  }
}

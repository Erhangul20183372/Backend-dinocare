import { PoolClient } from "pg";
import { getRequestContext } from "../http/middlewares/context.middleware";

export async function setUserContext(client: PoolClient): Promise<void> {
  const ctx = getRequestContext();
  const appUserId = ctx.user?.appUserId;
  if (appUserId) {
    await client.query("SELECT set_config('app.current_user_id', $1, true)", [appUserId]);
  }
}

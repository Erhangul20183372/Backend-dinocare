import { Pool } from "pg";
import { ENV } from "../env";

const postgresPool = new Pool({
  host: ENV.POSTGRES_HOST,
  port: ENV.POSTGRES_PORT,
  user: ENV.POSTGRES_USER,
  password: ENV.POSTGRES_PASSWORD,
  database: ENV.POSTGRES_DATABASE,
});

export default postgresPool;

import { createApp } from "../app";
import { ENV } from "../env";

const app = createApp();
const port = ENV.PORT;

app.listen(port, () => {
  console.log(`[clients] listening on http://localhost:${port}`);
});

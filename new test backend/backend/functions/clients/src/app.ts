import { attachUserContext, errorMiddleware, useRequestContext } from "@shared/ts/http";
import express, { json, urlencoded } from "express";
import morgan from "morgan";
import createClientsRouter from "./api/client.router";
import { ENV } from "./env";

export function createApp() {
  const app = express();

  app.use(morgan("combined"));
  app.use(urlencoded({ extended: true }));
  app.use(json());

  app.use(useRequestContext());
  app.use(
    attachUserContext({
      allowDevImpersonation: ENV.NODE_ENV === "development" && ENV.ALLOW_DEV_IMPERSONATION,
      headerName: ENV.DEV_IMPERSONATE_HEADER,
      staticUserId: ENV.DEV_APP_USER_ID || undefined,
    })
  );

  app.use("/api/clients", createClientsRouter());

  app.use(errorMiddleware);
  return app;
}

import { errorMiddleware, useRequestContext } from "@shared/ts/http";
import express, { json, urlencoded } from "express";
import morgan from "morgan";
import createAuthRouter from "./api/auth.router";

export function createApp() {
  const app = express();

  app.use(morgan("combined"));
  app.use(urlencoded({ extended: true }));
  app.use(json());

  app.use(useRequestContext());

  app.use("/api/auth", createAuthRouter());

  app.use(errorMiddleware);
  return app;
}

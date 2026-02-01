import { errorMiddleware } from "@shared/ts/http";
import express, { json, urlencoded } from "express";
import morgan from "morgan";
import { createAlertsRouter } from "./api/alerts.router";

export const createApp = () => {
  const app = express();

  app.use(morgan("combined"));
  app.use(urlencoded({ extended: true }));
  app.use(json());

  app.use("/api/alerts", createAlertsRouter());

  app.use(errorMiddleware);
  return app;
};

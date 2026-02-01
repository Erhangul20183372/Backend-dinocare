import { validate } from "@shared/ts/http";
import { Router } from "express";
import { AlertsController } from "../controllers/alerts.controller";
import { GetAlertParamsSchema, ListAlertsQuerySchema } from "../dtos/alerts";
import { AlertsRepository } from "../repositories/alerts.repository";
import { AlertsService } from "../services/alerts.service";

export const createAlertsRouter = () => {
  const repo = new AlertsRepository();
  const service = new AlertsService(repo);
  const controller = new AlertsController(service);

  const router = Router();

  // Bestaande routes
  router.get("/", validate({ query: ListAlertsQuerySchema }), controller.list);
  router.get("/:id", validate({ params: GetAlertParamsSchema }), controller.getById);

  // Nieuwe route: feedback
  router.post("/feedback", controller.submitFeedback);

  return router;
};

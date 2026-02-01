import { validate } from "@shared/ts/http";
import { Router } from "express";
import ClientService from "../domain/client.service";
import ClientRepository from "../infrastructure/client.repository";
import postgresPool from "../utils/postgres_pool";
import ClientController from "./client.controller";
import * as C from "./dtos/client.dto";
import * as DA from "./dtos/device-assignment.dto";

const createClientRouter = () => {
  const repo = new ClientRepository(postgresPool);
  const service = new ClientService(repo);
  const controller = new ClientController(service);

  const router = Router();

  router.post("/", validate(C.createClientSchema), controller.createClient);
  router.post("/bulk", validate(C.createClientBulkSchema), controller.createClients);
  router.get("/", validate(C.getClientsSchema), controller.getClients);
  router.get("/:id", validate(C.getClientByIdSchema), controller.getClientById);
  router.patch("/:id", validate(C.patchClientSchema), controller.patchClient);
  router.delete("/:id", validate(C.deleteClientSchema), controller.deleteClient);

  router.post("/:id/devices", validate(DA.createDeviceAssignmentSchema), controller.createClientDevice);
  router.get("/:id/devices", validate(DA.getDeviceAssignmentsSchema), controller.getClientDevices);
  router.patch("/:clientId/devices/:deviceId", validate(DA.patchDeviceAssignmentSchema), controller.patchClientDevice);
  router.delete(
    "/:clientId/devices/:deviceId",
    validate(DA.deleteDeviceAssignmentSchema),
    controller.deleteClientDevice
  );

  return router;
};

export default createClientRouter;

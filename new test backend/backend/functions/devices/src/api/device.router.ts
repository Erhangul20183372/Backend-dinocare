import { validate } from "@shared/ts";
import { Router } from "express";
import DeviceRepository from "../data/device.repository";
import DeviceService from "../domain/device.service";
import postgresPool from "../utils/postgres_pool";
import DeviceController from "./device.controller";
import * as D from "./dtos/device.dto";

const createDevicesRouter = () => {
  const repo = new DeviceRepository(postgresPool);
  const service = new DeviceService(repo);
  const controller = new DeviceController(service);

  const router = Router();

  router.post("/", validate(D.createDevicesSchema), controller.createDevice);
  router.get("/", validate(D.getDevicesSchema), controller.getAllDevices);
  router.get("/:id", validate(D.getDeviceByIdSchema), controller.getDeviceById);
  router.patch("/:id", validate(D.patchDeviceSchema), controller.patchDevice);

  return router;
};

export default createDevicesRouter;

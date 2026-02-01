import { CreatedResponse, OkResponse } from "@shared/ts";
import { Request, Response } from "express";
import DeviceService from "../domain/device.service";
import * as D from "./dtos/device.dto";

export default class DeviceController {
  constructor(private deviceService: DeviceService) {}

  getAllDevices = async (req: Request, res: Response) => {
    const dto: D.GetDevicesDto = req.dto;
    const result = await this.deviceService.getAllDevices(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  createDevice = async (req: Request, res: Response) => {
    const dto: D.CreateDevicesDto = req.dto;
    const result = await this.deviceService.createDevice(dto);
    const response = new CreatedResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getDeviceById = async (req: Request, res: Response) => {
    const dto: D.GetDeviceByIdDto = req.dto;
    const result = await this.deviceService.getDeviceById(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  patchDevice = async (req: Request, res: Response) => {
    const dto: D.PatchDeviceDto = req.dto;
    const result = await this.deviceService.patchDevice(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };
}

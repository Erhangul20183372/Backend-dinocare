import { CreatedResponse, OkResponse } from "@shared/ts";
import { Request, Response } from "express";
import ClientService from "../domain/client.service";
import * as C from "./dtos/client.dto";
import * as DA from "./dtos/device-assignment.dto";

export default class ClientController {
  constructor(private clientService: ClientService) {}

  createClient = async (req: Request, res: Response) => {
    const dto: C.CreateClientDto = req.dto;

    const result = await this.clientService.createClient(dto);

    const response = new CreatedResponse({ data: result });
    return res.status(response.status).json(response);
  };

  createClients = async (req: Request, res: Response) => {
    const dto: C.CreateClientBulkDto = req.dto;

    const result = await this.clientService.createClients(dto);

    const response = new CreatedResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getClients = async (req: Request, res: Response) => {
    const dto: C.GetClientsDto = req.dto;

    const clients = await this.clientService.getClientsWithTeams(dto);

    const response = new OkResponse({ data: clients });
    res.status(response.status).json(response);
  };

  getClientById = async (req: Request, res: Response) => {
    const dto: C.GetClientByIdDto = req.dto;

    const result = await this.clientService.getClientById(dto);
    if (!result) return res.status(404).json({ message: "Client not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  patchClient = async (req: Request, res: Response) => {
    const dto: C.PatchClientDto = req.dto;

    const result = await this.clientService.patchClient(dto);
    if (!result) return res.status(404).json({ message: "Client not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  deleteClient = async (req: Request, res: Response) => {
    const dto: C.DeleteClientDto = req.dto;

    const result = await this.clientService.deleteClient(dto);
    if (!result) return res.status(404).json({ message: "Client not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getClientDevices = async (req: Request, res: Response) => {
    const dto: DA.GetDeviceAssignmentsDto = req.dto;

    const result = await this.clientService.getClientDevices(dto);

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  createClientDevice = async (req: Request, res: Response) => {
    const dto: DA.CreateDeviceAssignmentDto = req.dto;

    const result = await this.clientService.createClientDevice(dto);
    if (!result) return res.status(404).json({ message: "Client or device not found" });

    const response = new CreatedResponse({ data: result });
    return res.status(response.status).json(response);
  };

  patchClientDevice = async (req: Request, res: Response) => {
    const dto: DA.PatchDeviceAssignmentDto = req.dto;

    const result = await this.clientService.patchClientDevice(dto);
    if (!result) return res.status(404).json({ message: "Client device assignment not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  deleteClientDevice = async (req: Request, res: Response) => {
    const dto: DA.DeleteDeviceAssignmentDto = req.dto;

    const result = await this.clientService.deleteClientDevice(dto);
    if (!result) return res.status(404).json({ message: "Client device assignment not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };
}

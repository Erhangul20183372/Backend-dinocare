import { OkResponse } from "@shared/ts";
import { Request, Response } from "express";
import { UserService } from "../domain/user.service";
import * as AU from "./dtos/user.dto";

export class UserController {
  constructor(private service: UserService) {}

  getAll = async (req: Request, res: Response) => {
    const dto: AU.GetUsersDto = req.dto;
    const result = await this.service.getAll(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getById = async (req: Request, res: Response) => {
    const dto: AU.GetUserByIdDto = req.dto;
    const result = await this.service.getOne(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getMe = async (_: Request, res: Response) => {
    const result = await this.service.getMe();
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  patchById = async (req: Request, res: Response) => {
    const dto: AU.PatchUserDto = req.dto;
    const result = await this.service.patch(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  archiveById = async (req: Request, res: Response) => {
    const dto: AU.ArchiveUserDto = req.dto;
    const result = await this.service.archive(dto);
    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };
}

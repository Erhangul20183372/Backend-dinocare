import { Request, Response } from "express";
import { NoContentResponse, OkResponse } from "@shared/ts/http";import AuthService from "../domain/auth.service";
import * as A from "./dtos/auth.dto";

export default class AuthController {
  constructor(private authService: AuthService) {}

  login = async (req: Request, res: Response) => {
    const dto: A.LoginDto = req.dto;
    const login = await this.authService.login(dto);
    const response = new OkResponse({ data: login });
    return res.status(response.status).json(response);
  };

  refreshToken = async (req: Request, res: Response) => {
    const dto: A.RefreshDto = req.dto;
    const token = await this.authService.refresh(dto);
    const response = new OkResponse({ data: token });
    return res.status(response.status).json(response);
  };

  register = async (req: Request, res: Response) => {
    const dto: A.RegisterDto = req.dto;
    await this.authService.register(dto);
    const response = new NoContentResponse({});
    return res.status(response.status).send();
  };
}

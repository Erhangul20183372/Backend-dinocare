import { CreatedResponse, NoContentResponse, OkResponse } from "@shared/ts";
import { Request, Response } from "express";
import { TeamService } from "../../domain/services/team.service";
import * as TM from "../dtos/team-membership.dto";
import * as T from "../dtos/team.dto";

export class TeamController {
  constructor(private service: TeamService) {}

  createTeam = async (req: Request, res: Response) => {
    const dto: T.CreateTeamDto = req.dto;
    const result = await this.service.createTeam(dto);

    const response = new CreatedResponse({
      data: result,
    });

    return res.status(response.status).json(response);
  };

  bulkCreateTeams = async (req: Request, res: Response) => {
    const dto: T.BulkCreateTeamDto = req.dto;
    const result = await this.service.bulkCreateTeams(dto);

    // TODO: change to proper response class when we have one for 207
    const response = new OkResponse({
      data: result,
    });
    return res.status(response.status).json(response);
  };

  getAllTeams = async (req: Request, res: Response) => {
    const dto: T.GetTeamsDto = req.dto;
    const result = await this.service.getAllTeams(dto);

    const response = new OkResponse({
      data: result.rows,
      pagination: result.pagination,
    });

    return res.status(response.status).json(response);
  };

  getTeamById = async (req: Request, res: Response) => {
    const dto: T.GetTeamByIdDto = req.dto;
    const result = await this.service.getTeamById(dto);

    const response = new OkResponse({
      data: result,
    });

    return res.status(response.status).json(response);
  };

  patchTeamById = async (req: Request, res: Response) => {
    const dto: T.PatchTeamDto = req.dto;

    const result = await this.service.patchTeam(dto);

    const response = new OkResponse({
      data: result,
    });
    return res.status(response.status).json(response);
  };

  deleteTeamById = async (req: Request, res: Response) => {
    const dto: T.DeleteTeamDto = req.dto;

    await this.service.deleteTeam(dto);

    const response = new NoContentResponse({});
    return res.status(response.status).json(response);
  };

  getTeamClients = async (req: Request, res: Response) => {
    const dto: T.GetTeamClientsDto = req.dto;

    const result = await this.service.listClients(dto);

    const response = new OkResponse({
      data: result.rows,
      pagination: result.pagination,
    });
    return res.status(response.status).json(response);
  };

  getTeamMembers = async (req: Request, res: Response) => {
    const dto: TM.GetTeamMembersDto = req.dto;

    const result = await this.service.listMembers(dto);

    const response = new OkResponse({
      data: result.rows,
      pagination: result.pagination,
    });
    return res.status(response.status).json(response);
  };

  addMemberToTeam = async (req: Request, res: Response) => {
    const dto: TM.CreateTeamMembershipDto = req.dto;

    const result = await this.service.addMember(dto);

    const response = new CreatedResponse({
      data: result,
    });

    return res.status(response.status).json(response);
  };

  updateMembership = async (req: Request, res: Response) => {
    const dto: TM.PatchTeamMembershipDto = req.dto;

    const result = await this.service.updateMember(dto);

    const response = new OkResponse({
      data: result,
    });
    return res.status(response.status).json(response);
  };

  deleteTeamMember = async (req: Request, res: Response) => {
    const dto: TM.DeleteTeamMembershipDto = req.dto;

    await this.service.removeMember(dto);

    const response = new NoContentResponse({});
    return res.status(response.status).json(response);
  };
}

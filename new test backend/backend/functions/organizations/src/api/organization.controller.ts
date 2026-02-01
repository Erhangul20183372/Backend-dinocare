import { CreatedResponse, NoContentResponse, OkResponse } from "@shared/ts";
import { Request, Response } from "express";
import OrganizationService from "../domain/organizations.service";
import * as OM from "./dtos/organization-membership.dto";
import * as O from "./dtos/organization.dto";

export default class OrganizationController {
  constructor(private organizationService: OrganizationService) {}

  getOrganizations = async (req: Request, res: Response) => {
    const dto: O.GetOrganizationsDto = req.dto;
    const result = await this.organizationService.getOrganizations(dto);

    const response = new OkResponse({ data: result.rows, pagination: result.pagination });
    return res.status(response.status).json(response);
  };

  createOrganization = async (req: Request, res: Response) => {
    const dto: O.CreateOrganizationDto = req.dto;
    const result = await this.organizationService.createOrganization(dto);
    if (!result) return res.status(409).json({ message: "Cannot insert organization" });

    const response = new CreatedResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getOrganizationById = async (req: Request, res: Response) => {
    const dto: O.GetOrganizationByIdDto = req.dto;
    const result = await this.organizationService.getOrganizationById(dto);
    if (!result) return res.status(404).json({ message: "Organization not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  patchOrganization = async (req: Request, res: Response) => {
    const dto: O.PatchOrganizationDto = req.dto;
    const result = await this.organizationService.patchOrganization(dto);
    if (!result) return res.status(404).json({ message: "Organization not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  deleteOrganization = async (req: Request, res: Response) => {
    const dto: O.DeleteOrganizationDto = req.dto;
    const result = await this.organizationService.deleteOrganization(dto);
    if (!result) return res.status(404).json({ message: "Organization not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getOrganizationMembers = async (req: Request, res: Response) => {
    const dto: OM.GetOrganizationMembershipsDto = req.dto;
    const result = await this.organizationService.getOrganizationMembers(dto);

    const response = new OkResponse({ data: result.rows, pagination: result.pagination });
    return res.status(response.status).json(response);
  };

  createOrganizationMember = async (req: Request, res: Response) => {
    const dto: OM.CreateOrganizationMembershipDto = req.dto;
    const result = await this.organizationService.createOrganizationMember(dto);
    if (!result) return res.status(404).json({ message: "Organization not found" });

    const response = new CreatedResponse({ data: result });
    return res.status(response.status).json(response);
  };

  patchOrganizationMember = async (req: Request, res: Response) => {
    const dto: OM.PatchOrganizationMembershipDto = req.dto;
    const result = await this.organizationService.patchOrganizationMember(dto);
    if (!result) return res.status(404).json({ message: "Organization or member not found" });

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  deleteOrganizationMember = async (req: Request, res: Response) => {
    const dto: OM.DeleteOrganizationMembershipDto = req.dto;
    const result = await this.organizationService.deleteOrganizationMember(dto);
    if (!result) return res.status(404).json({ message: "Organization or member not found" });

    const response = new NoContentResponse({ req });
    return res.status(response.status).end();
  };

  getOrganizationTeams = async (req: Request, res: Response) => {
    const dto: O.GetOrganizationTeamsDto = req.dto;
    const result = await this.organizationService.getOrganizationTeams(dto);

    const response = new OkResponse({ data: result.rows, pagination: result.pagination });
    return res.status(response.status).json(response);
  };

  getOrganizationClients = async (req: Request, res: Response) => {
    const dto: O.GetOrganizationClientsDto = req.dto;
    const result = await this.organizationService.getOrganizationClients(dto);
    if (!result) return res.status(404).json({ message: "Organization not found" });

    const response = new OkResponse({ data: result.rows, pagination: result.pagination });
    return res.status(response.status).json(response);
  };
}

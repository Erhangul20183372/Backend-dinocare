import { toPaginationMeta } from "@shared/ts/domain";
import { PaginatedModel } from "packages/shared-ts/src/domain/models/paginated.model";
import * as OM from "../api/dtos/organization-membership.dto";
import * as O from "../api/dtos/organization.dto";
import OrganizationRepository from "../infrastructure/organization.repository";
import {
  AllOrganizationClientsDto,
  AllOrganizationMembersDto,
  AllOrganizationsDto,
  AllOrganizationTeamsDto,
  OneOrganizationDto,
  OrganizationCreatedDto,
  OrganizationDeletedDto,
  OrganizationMemberCreatedDto,
  OrganizationMemberDeletedDto,
  OrganizationMemberPatchedDto,
  OrganizationPatchedDto,
} from "./dtos";
import {
  AllOrganizationClientsMapper,
  AllOrganizationMembersMapper,
  AllOrganizationsMapper,
  AllOrganizationTeamsMapper,
  OneOrganizationMapper,
  OrganizationCreatedMapper,
  OrganizationDeletedMapper,
  OrganizationMemberCreatedMapper,
  OrganizationMemberDeletedMapper,
  OrganizationMemberPatchedMapper,
  OrganizationPatchedMapper,
} from "./mappers";

export default class OrganizationService {
  constructor(private readonly organizationRepository: OrganizationRepository) {}

  async getOrganizations(dto: O.GetOrganizationsDto): Promise<PaginatedModel<AllOrganizationsDto>> {
    const result = await this.organizationRepository.findAll({ limit: dto.limit, offset: dto.offset });

    const rows = result.rows.map(AllOrganizationsMapper.toResponse);
    const pagination = toPaginationMeta({
      total: result.total,
      count: result.count,
      limit: result.limit,
      offset: result.offset,
    });

    return { rows, pagination };
  }

  async createOrganization(dto: O.CreateOrganizationDto): Promise<OrganizationCreatedDto | null> {
    const exists = await this.organizationRepository.existsByDomain({ domain: dto.domain });
    if (exists) return null;

    const row = await this.organizationRepository.create({
      domain: dto.domain,
      name: dto.name,
      logoUrl: dto.logoUrl ?? undefined,
    });
    return OrganizationCreatedMapper.toResponse(row);
  }

  async getOrganizationById(dto: O.GetOrganizationByIdDto): Promise<OneOrganizationDto | null> {
    const row = await this.organizationRepository.findById({ id: dto.id });
    if (!row) return null;
    return OneOrganizationMapper.toResponse(row);
  }

  async patchOrganization(dto: O.PatchOrganizationDto): Promise<OrganizationPatchedDto | null> {
    const row = await this.organizationRepository.patchOne(
      { id: dto.id },
      { name: dto.name, domain: dto.domain, logoUrl: dto.logoUrl }
    );
    if (!row) return null;
    return OrganizationPatchedMapper.toResponse(row);
  }

  async deleteOrganization(dto: O.DeleteOrganizationDto): Promise<OrganizationDeletedDto | null> {
    const row = await this.organizationRepository.archiveOne({ id: dto.id });
    if (!row) return null;
    return OrganizationDeletedMapper.toResponse(row);
  }

  async getOrganizationMembers(
    dto: OM.GetOrganizationMembershipsDto
  ): Promise<PaginatedModel<AllOrganizationMembersDto>> {
    const result = await this.organizationRepository.findAllOrganizationMembers(
      { organizationId: dto.organizationId, role: dto.role },
      { limit: dto.limit, offset: dto.offset }
    );

    const rows = AllOrganizationMembersMapper.toResponse(result.rows);
    const pagination = toPaginationMeta({
      total: result.total,
      count: result.count,
      limit: result.limit,
      offset: result.offset,
    });

    return { rows, pagination };
  }

  async createOrganizationMember(
    dto: OM.CreateOrganizationMembershipDto
  ): Promise<OrganizationMemberCreatedDto | null> {
    const exists = await this.organizationRepository.existsOrganizationMember({
      organizationId: dto.organizationId,
      appUserId: dto.appUserId,
    });
    if (exists) return null;

    const row = await this.organizationRepository.createOrganizationMember({
      id: dto.organizationId,
      appUserId: dto.appUserId,
      role: dto.role,
    });
    if (!row) return null;
    return OrganizationMemberCreatedMapper.toResponse(row);
  }

  async patchOrganizationMember(dto: OM.PatchOrganizationMembershipDto): Promise<OrganizationMemberPatchedDto | null> {
    const row = await this.organizationRepository.patchOrganizationMember(
      { organizationId: dto.organizationId, appUserId: dto.appUserId },
      { role: dto.role }
    );
    if (!row) return null;
    return OrganizationMemberPatchedMapper.toResponse(row);
  }

  async deleteOrganizationMember(
    dto: OM.DeleteOrganizationMembershipDto
  ): Promise<OrganizationMemberDeletedDto | null> {
    const row = await this.organizationRepository.deleteOrganizationMember({
      organizationId: dto.organizationId,
      appUserId: dto.appUserId,
    });
    if (!row) return null;
    return OrganizationMemberDeletedMapper.toResponse(row);
  }

  async getOrganizationTeams(dto: O.GetOrganizationTeamsDto): Promise<PaginatedModel<AllOrganizationTeamsDto>> {
    const result = await this.organizationRepository.findAllOrganizationTeams(
      { id: dto.id, search: dto.search },
      { limit: dto.limit, offset: dto.offset }
    );

    const rows = AllOrganizationTeamsMapper.toResponse(result.rows);
    const pagination = toPaginationMeta({
      total: result.total,
      count: result.count,
      limit: result.limit,
      offset: result.offset,
    });

    return { rows, pagination };
  }

  async getOrganizationClients(dto: O.GetOrganizationClientsDto): Promise<PaginatedModel<AllOrganizationClientsDto>> {
    const result = await this.organizationRepository.findAllOrganizationClients(
      { id: dto.id, search: dto.search },
      { limit: dto.limit, offset: dto.offset }
    );

    const rows = AllOrganizationClientsMapper.toResponse(result.rows);
    const pagination = toPaginationMeta({
      total: result.total,
      count: result.count,
      limit: result.limit,
      offset: result.offset,
    });

    return { rows, pagination };
  }
}

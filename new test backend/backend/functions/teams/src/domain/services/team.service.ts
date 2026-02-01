import { PaginatedModel, toPaginationMeta } from "@shared/ts/domain";
import { BadRequestError, ConflictError, ErrorType, NotFoundError, NotImplementedError } from "@shared/ts/http";
import { BulkCreateTeamResponseDto } from "../../api/dtos/create-bulk-team.dto";
import * as TM from "../../api/dtos/team-membership.dto";
import * as T from "../../api/dtos/team.dto";
import { TeamRepository } from "../../infrastructure/repositories/team.repository";
import { TeamRow } from "../../infrastructure/rows/team.row";
import { randomAccessibleColor } from "../../utils/color";
import { AddTeamMemberMapper } from "../mappers/add-member.mapper";
import { TeamClientMapper } from "../mappers/team-client.mapper";
import { TeamMemberMapper } from "../mappers/team-member.mapper";
import { TeamMapper } from "../mappers/team.mapper";
import { TeamClientModel } from "../models/team-client.model";
import { TeamMemberModel } from "../models/team-member.model";
import { TeamModel } from "../models/team.model";

const PG_UNIQUE_VIOLATION = "23505";

export class TeamService {
  constructor(private teamRepository: TeamRepository) {}

  async createTeam(dto: T.CreateTeamDto): Promise<TeamModel> {
    const exists = await this.teamRepository.existsByOrganizationAndName({
      organizationId: dto.organizationId,
      name: dto.name,
    });
    if (exists) {
      throw new ConflictError(ErrorType.TEAM_ALREADY_EXISTS, "Team with this name already exists for the organization");
    }

    dto.color = dto.color ?? randomAccessibleColor();

    const result = await this.teamRepository.create({
      name: dto.name,
      organizationId: dto.organizationId,
      color: dto.color,
    });

    if (!result) throw new BadRequestError(ErrorType.TEAM_NOT_FOUND, "Team could not be created");

    return TeamMapper.toModel(result);
  }

  async bulkCreateTeams(dto: T.BulkCreateTeamDto): Promise<BulkCreateTeamResponseDto> {
    const failures: BulkCreateTeamResponseDto["failed"] = [];
    const entries = new Map<
      string,
      { index: number; input: { name: string; organizationId: string; color: string }; normalizedName: string }
    >();
    const duplicateIndexes = new Set<number>();

    // find duplicates in the request payload
    dto.teams.forEach((team: any, index: number) => {
      const name = team.name.trim();
      const normalizedName = name.toLowerCase();
      const key = `${team.organizationId}:${normalizedName}`;
      const color = team.color ?? randomAccessibleColor();

      if (entries.has(key)) {
        const prev = entries.get(key);
        if (prev && !duplicateIndexes.has(prev.index)) {
          failures.push({
            index: prev.index,
            code: ErrorType.TEAM_ALREADY_EXISTS,
            message: "Duplicate team names for the organization in the request payload",
          });
          duplicateIndexes.add(prev.index);
        }
        failures.push({
          index,
          code: ErrorType.TEAM_ALREADY_EXISTS,
          message: "Duplicate team names for the organization in the request payload",
        });
        duplicateIndexes.add(index);

        return;
      }

      entries.set(key, { index, input: { name, organizationId: team.organizationId, color }, normalizedName });
    });

    // remove duplicates from entries
    for (const idx of duplicateIndexes)
      for (const [key, entry] of entries.entries()) if (entry.index === idx) entries.delete(key);

    const uniqueEntries = Array.from(entries.values());
    if (uniqueEntries.length) {
      const existing = await this.teamRepository.findExistingByOrganizationAndNames(
        uniqueEntries.map((e) => ({ organizationId: e.input.organizationId, normalizedName: e.normalizedName }))
      );

      for (const item of existing) {
        const key = `${item.organizationId}:${item.name.trim().toLowerCase()}`;
        const entry = entries.get(key);
        if (entry) {
          failures.push({
            index: entry.index,
            code: ErrorType.TEAM_ALREADY_EXISTS,
            message: `Team with the name '${item.name}' already exists for the organization`,
          });
          entries.delete(key);
        }
      }
    }

    const pending = Array.from(entries.values()).sort((a, b) => a.index - b.index);
    const results: BulkCreateTeamResponseDto["results"] = [];

    if (pending.length) {
      const inputs = pending.map((e) => e.input);
      try {
        // try bulk insert first
        const rows = await this.teamRepository.bulkCreate(inputs);
        rows.forEach((row, i) => results.push({ index: pending[i].index, team: TeamMapper.toModel(row) }));
      } catch (error) {
        if ((error as { code?: string })?.code !== PG_UNIQUE_VIOLATION) throw error;
        // if bulk insert fails (e.g. due to unique violation), fallback to individual inserts
        for (const entry of pending) {
          try {
            const row = await this.teamRepository.create(entry.input);
            if (!row) {
              failures.push({
                index: entry.index,
                code: ErrorType.TEAM_NOT_FOUND,
                message: "Team could not be created",
              });
              continue;
            }
            results.push({ index: entry.index, team: TeamMapper.toModel(row) });
          } catch (err) {
            if ((err as { code?: string })?.code === PG_UNIQUE_VIOLATION)
              failures.push({
                index: entry.index,
                code: ErrorType.TEAM_ALREADY_EXISTS,
                message: `Team with the name "${entry.input.name}" already exists for the organization`,
              });
            else throw err;
          }
        }
      }
    }

    results.sort((a, b) => a.index - b.index);
    failures.sort((a, b) => a.index - b.index);

    return {
      total: dto.teams.length,
      created: results.length,
      failed: failures,
      results,
    };
  }

  async getAllTeams(dto: T.GetTeamsDto): Promise<PaginatedModel<TeamModel>> {
    const rows = await this.teamRepository.findAll(
      {
        organizationId: dto.organizationId,
        search: dto.search,
      },
      {
        limit: dto.limit,
        offset: dto.offset,
      }
    );

    return {
      rows: rows.rows.map(TeamMapper.toModel),
      pagination: toPaginationMeta({
        total: rows.total,
        offset: rows.offset,
        limit: rows.limit,
        count: rows.count,
      }),
    };
  }

  async getTeamById(dto: T.GetTeamByIdDto): Promise<TeamModel> {
    const result = await this.teamRepository.findById({
      teamId: dto.id,
    });
    if (!result) {
      throw new NotFoundError(ErrorType.TEAM_NOT_FOUND, "Team not found");
    }
    return TeamMapper.toModel(result);
  }

  async patchTeam(dto: T.PatchTeamDto): Promise<TeamModel> {
    const existing = await this.ensureTeamExists(dto.id);

    if (dto.name && dto.name !== existing.team_name) {
      const duplicate = await this.teamRepository.existsByOrganizationAndName({
        organizationId: existing.team_organization_id,
        name: dto.name,
        excludeTeamId: dto.id,
      });

      if (duplicate) {
        throw new ConflictError(
          ErrorType.TEAM_ALREADY_EXISTS,
          "Team with this name already exists for the organization"
        );
      }
    }

    const result = await this.teamRepository.update(dto.id, {
      name: dto.name,
      color: dto.color,
    });

    if (!result) {
      throw new NotFoundError(ErrorType.TEAM_NOT_FOUND, "Team not found");
    }

    return TeamMapper.toModel(result);
  }

  async deleteTeam(dto: T.DeleteTeamDto): Promise<void> {
    await this.ensureTeamExists(dto.id);
    await this.teamRepository.archive({
      teamId: dto.id,
    });
  }

  async listMembers(dto: TM.GetTeamMembersDto): Promise<PaginatedModel<TeamMemberModel>> {
    await this.ensureTeamExists(dto.teamId);

    const rows = await this.teamRepository.findAllMembers(
      {
        teamId: dto.teamId,
        role: dto.role,
      },
      {
        limit: dto.limit,
        offset: dto.offset,
      }
    );

    return {
      rows: rows.rows.map(TeamMemberMapper.toModel),
      pagination: toPaginationMeta({
        total: rows.total,
        offset: rows.offset,
        limit: rows.limit,
        count: rows.count,
      }),
    };
  }

  async addMember(dto: TM.CreateTeamMembershipDto): Promise<TeamMemberModel> {
    await this.ensureTeamExists(dto.teamId);

    const alreadyMember = await this.teamRepository.hasActiveMembership({
      teamId: dto.teamId,
      userId: dto.appUserId,
    });
    if (alreadyMember) {
      throw new ConflictError(ErrorType.USER_ALREADY_MEMBER_OF_TEAM, "User is already an active member of the team");
    }

    const member = await this.teamRepository.addMember({
      teamId: dto.teamId,
      userId: dto.appUserId,
      role: dto.role,
      memberUntil: dto.memberUntil,
    });

    if (!member) {
      throw new NotFoundError(ErrorType.USER_NOT_FOUND, "Unable to add team member");
    }

    return AddTeamMemberMapper.toModel(member);
  }

  async updateMember(dto: TM.PatchTeamMembershipDto): Promise<TeamMemberModel> {
    await this.ensureTeamExists(dto.teamId);

    const member = await this.teamRepository.updateMember(
      {
        teamId: dto.teamId,
      },
      {
        userId: dto.appUserId,
        role: dto.role,
        memberSince: dto.memberSince,
        memberUntil: dto.memberUntil,
      }
    );

    if (!member) {
      throw new NotImplementedError("Updating team membership is not implemented");
    }

    return TeamMemberMapper.toModel(member);
  }

  async removeMember(dto: TM.PatchTeamMembershipDto): Promise<void> {
    await this.ensureTeamExists(dto.teamId);

    const isActiveMember = await this.teamRepository.hasActiveMembership({
      teamId: dto.teamId,
      userId: dto.appUserId,
    });

    if (!isActiveMember) {
      throw new NotFoundError(ErrorType.MEMBERSHIP_NOT_FOUND, "Team membership not found");
    }

    const removed = await this.teamRepository.removeMember({
      teamId: dto.teamId,
      userId: dto.appUserId,
    });

    if (!removed) {
      throw new NotFoundError(ErrorType.MEMBERSHIP_NOT_FOUND, "Team membership not found");
    }
  }

  async listClients(dto: T.GetTeamClientsDto): Promise<PaginatedModel<TeamClientModel>> {
    await this.ensureTeamExists(dto.id);

    const rows = await this.teamRepository.listClients(
      { teamId: dto.id, search: dto.search },
      { limit: dto.limit, offset: dto.offset }
    );

    return {
      rows: rows.rows.map(TeamClientMapper.toModel),
      pagination: toPaginationMeta({
        total: rows.total,
        offset: rows.offset,
        limit: rows.limit,
        count: rows.count,
      }),
    };
  }

  private async ensureTeamExists(teamId: string): Promise<TeamRow> {
    const team = await this.teamRepository.findById({
      teamId,
    });
    if (!team) {
      throw new NotFoundError(ErrorType.TEAM_NOT_FOUND, "Team not found");
    }
    return team;
  }
}

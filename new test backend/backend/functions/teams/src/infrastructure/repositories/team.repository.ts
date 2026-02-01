import { BaseRepository, PaginatedResult } from "@shared/ts/db";
import {
  AppUserSelectBuilder,
  ClientSelectBuilder,
  TeamMembershipSelectBuilder,
  TeamSelectBuilder,
} from "@shared/ts/sql/builders";
import { Paginatable, Pagination } from "@shared/ts/sql/fragments";
import { extractTotal, TotalRow } from "@shared/ts/sql/rows";
import { ArchiveTeamByIdFilters, ArchiveTeamConditionable } from "../filters/archive-team.filter";
import {
  ExistsByOrganizationConditionable,
  ExistsByOrganizationFilters,
} from "../filters/exists-by-organization.filter";
import { FindAllConditionable, FindAllFilters } from "../filters/find-all.filter";
import { FindByIdConditionable, FindByIdFilters } from "../filters/find-by-id.filter";
import {
  FindClientsTeamByIdConditionable,
  FindClientsTeamByIdFilters,
} from "../filters/find-clients-team-by-id.filter";
import { FindMembershipByIdConditionable, FindMembershipByIdFilters } from "../filters/find-membership-by-id.filter";
import { ListMembersConditionable, ListMembersFilters } from "../filters/list-members.filter";
import { AddTeamMemberInput, AddTeamMemberInsertable } from "../inputs/add-team-member.input";
import { ArchiveTeamInput } from "../inputs/archive-team.input";
import { CreateTeamInput, CreateTeamInsertable } from "../inputs/create-team.input";
import { PatchTeamInput, PatchTeamUpdatable } from "../inputs/patch-team.input";
import { RemoveTeamMemberUpdatable } from "../inputs/remove-team-member.input";
import { UpdateTeamMemberInput } from "../inputs/update-team-member.input";
import { AddTeamMemberRow } from "../rows/add-team-member.row";
import { TeamClientRow } from "../rows/team-client.row";
import { TeamMemberRow } from "../rows/team-member.row";
import { TeamRow } from "../rows/team.row";

export class TeamRepository extends BaseRepository {
  async findAll(filters: FindAllFilters, pagination: Pagination): Promise<PaginatedResult<TeamRow>> {
    const T = TeamSelectBuilder.bind("t");

    const conditioner = new FindAllConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ team: T.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const query = `
      SELECT ${T.select({ include: ["id", "organization_id", "name", "color", "archived_by", "archived_on"] })}, COUNT(*) OVER() AS total
      FROM ${T.name} ${T.alias}
      ${conditions.sql}
      ORDER BY ${T.ref("name")} ASC
      ${paginations.sql}
    `;

    const result = await this.query<TeamRow & TotalRow>(query, [...conditions.values, ...paginations.values]);

    return {
      rows: result.rows,
      total: extractTotal(result),
      offset: pagination.offset,
      limit: pagination.limit,
      count: result.rows.length,
    };
  }

  async existsByOrganizationAndName(filters: ExistsByOrganizationFilters): Promise<boolean> {
    const T = TeamSelectBuilder.bind("t");

    const conditioner = new ExistsByOrganizationConditionable(filters);
    const conditions = conditioner.build({ team: T.alias });

    const query = `
      SELECT 1
      FROM ${T.name} ${T.alias}
      ${conditions.sql}
      LIMIT 1
    `;
    const result = await this.query(query, conditions.values);
    return result.rows.length > 0;
  }

  async create(input: CreateTeamInput): Promise<TeamRow | null> {
    const T = TeamSelectBuilder.bind("t");
    const insertable = new CreateTeamInsertable(input);
    const inserts = insertable.build();

    const query = `
      INSERT INTO ${T.name} ${inserts.sql}
      RETURNING ${T.returning({ include: ["id", "organization_id", "name", "color"] })}
    `;

    const result = await this.query<TeamRow>(query, inserts.values);

    return result.rows[0] ?? null;
  }

  async bulkCreate(inputs: CreateTeamInput[]): Promise<TeamRow[]> {
    const T = TeamSelectBuilder.bind("t");
    const insertable = new CreateTeamInsertable(inputs);
    const inserts = insertable.build();

    const query = `
      INSERT INTO ${T.name} ${inserts.sql}
      RETURNING ${T.returning({ include: ["id", "organization_id", "name", "color"] })}
    `;

    const result = await this.query<TeamRow>(query, inserts.values);
    return result.rows;
  }

  async findExistingByOrganizationAndNames(
    inputs: Array<{
      organizationId: string;
      normalizedName: string;
    }>
  ): Promise<Array<{ organizationId: string; name: string }>> {
    if (inputs.length === 0) return [];

    const T = TeamSelectBuilder.bind("t");

    const organizationIds = inputs.map((input) => input.organizationId);
    const normalizedNames = inputs.map((input) => input.normalizedName);

    const query = `
      SELECT ${T.select({ include: ["organization_id", "name"] })}
      FROM ${T.name} ${T.alias}
      JOIN UNNEST($1::UUID[]) AS org_ids(organization_id)
        ON ${T.ref("organization_id")} = org_ids.organization_id
      JOIN UNNEST($2::TEXT[]) AS norm_names(normalized_name)
        ON ${T.ref("name")} = norm_names.normalized_name
    `;

    const result = await this.query<{ organization_id: string; name: string }>(query, [
      organizationIds,
      normalizedNames,
    ]);

    return result.rows.map((row) => ({
      organizationId: row.organization_id,
      name: row.name,
    }));
  }

  async findById(filters: FindByIdFilters): Promise<TeamRow | null> {
    const T = TeamSelectBuilder.bind("t");
    const conditioner = new FindByIdConditionable(filters);

    const conditions = conditioner.build({ team: T.alias });

    const query = `
      SELECT ${T.select({ include: ["id", "organization_id", "name", "color", "archived_by", "archived_on"] })}
      FROM ${T.name} ${T.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query<TeamRow>(query, conditions.values);

    return result.rows[0] ?? null;
  }

  async update(teamId: string, input: PatchTeamInput): Promise<TeamRow | null> {
    const T = TeamSelectBuilder.bind("t");
    const updater = new PatchTeamUpdatable(input);
    const condition = new FindByIdConditionable({ teamId });

    const updates = updater.build();
    const conditions = condition.build({ team: T.alias }, updates.values.length + 1);

    if (!updates.sql) {
      return this.findById({
        teamId,
      });
    }

    const query = `
      UPDATE ${T.name} ${T.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${T.returning({ include: ["id", "organization_id", "name", "color", "archived_by", "archived_on"] })}
    `;

    const result = await this.query<TeamRow>(query, [...updates.values, ...conditions.values]);

    return result.rows[0] ?? null;
  }

  async archive(filters: ArchiveTeamByIdFilters): Promise<boolean> {
    const T = TeamSelectBuilder.bind("t");
    const archiver = new ArchiveTeamInput({});
    const conditioner = new ArchiveTeamConditionable(filters);

    const updates = archiver.build();
    const conditions = conditioner.build({ team: T.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${T.name} ${T.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${T.returning({ include: ["id"] })}
    `;

    const result = await this.query<TeamRow>(query, [...updates.values, ...conditions.values]);

    return result.rows.length > 0;
  }

  async findAllMembers(filters: ListMembersFilters, pagination: Pagination): Promise<PaginatedResult<TeamMemberRow>> {
    const TM = TeamMembershipSelectBuilder.bind("tm");
    const AU = AppUserSelectBuilder.bind("au");

    const conditioner = new ListMembersConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ app_user_team_membership: TM.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const query = `
      SELECT ${TM.select({ include: ["app_user_id", "role", "member_since", "member_until", "invited_by"] })},
         ${AU.select({ include: ["first_name", "last_name"] })},
         COUNT(*) OVER() AS total
      FROM ${TM.name} ${TM.alias}
      JOIN ${AU.name} ${AU.alias} ON ${AU.ref("id")} = ${TM.ref("app_user_id")}
      ${conditions.sql}
      ORDER BY ${TM.ref("member_since")} DESC
      ${paginations.sql}
    `;

    const result = await this.query<TeamMemberRow & TotalRow>(query, [...conditions.values, ...paginations.values]);

    return {
      rows: result.rows,
      total: extractTotal(result),
      offset: pagination.offset,
      limit: pagination.limit,
      count: result.rows.length,
    };
  }

  async addMember(input: AddTeamMemberInput): Promise<AddTeamMemberRow | null> {
    const AU = AppUserSelectBuilder.bind("au");
    const TM = TeamMembershipSelectBuilder.bind("tm");

    const insertable = new AddTeamMemberInsertable(input);
    const inserts = insertable.build();

    const insert = `
      INSERT INTO ${TM.name} ${inserts.sql}
      RETURNING ${TM.returning({ include: ["team_id", "app_user_id", "role", "member_since", "member_until", "invited_by"] })}
    `;
    const withUser = `
      WITH ins AS (
        ${insert}
      )
      SELECT ins.*,
            ${AU.select({ include: ["first_name", "last_name"] })}
      FROM ins
      JOIN ${AU.name} ${AU.alias} ON ${AU.ref("id")} = ins.app_user_team_membership_app_user_id
    `;

    const result = await this.query<AddTeamMemberRow>(withUser, [...inserts.values]);

    return result.rows[0];
  }

  async updateMember(filters: FindByIdFilters, input: UpdateTeamMemberInput): Promise<TeamMemberRow | null> {
    // TODO: update database constraints to require closing the current membership before creating a new one when changing roles
    return null;
  }

  async removeMember(filters: FindMembershipByIdFilters): Promise<boolean> {
    const TM = TeamMembershipSelectBuilder.bind("tm");

    const remover = new RemoveTeamMemberUpdatable({});
    const condition = new FindMembershipByIdConditionable(filters);

    const updates = remover.build();
    const conditions = condition.build({ app_user_team_membership: TM.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${TM.name} ${TM.alias}
      SET ${updates.sql}
      ${conditions.sql}
    `;

    const result = await this.query(query, [...updates.values, ...conditions.values]);

    return (result.rowCount ?? 0) > 0;
  }

  async listClients(
    filters: FindClientsTeamByIdFilters,
    pagination: Pagination
  ): Promise<PaginatedResult<TeamClientRow>> {
    const C = ClientSelectBuilder.bind("c");

    const conditioner = new FindClientsTeamByIdConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ client: C.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const query = `
      SELECT ${C.select({ include: ["id", "team_id", "first_name", "last_name", "gender"] })}, COUNT(*) OVER() AS total
      FROM ${C.name} ${C.alias}
      ${conditions.sql}
      ORDER BY ${C.ref("first_name")}, ${C.ref("last_name")}
      ${paginations.sql}
    `;

    const result = await this.query<TeamClientRow & TotalRow>(query, [...conditions.values, ...paginations.values]);

    return {
      rows: result.rows,
      total: extractTotal(result),
      offset: pagination.offset,
      limit: pagination.limit,
      count: result.rows.length,
    };
  }

  async hasActiveMembership(filters: FindMembershipByIdFilters): Promise<boolean> {
    const TM = TeamMembershipSelectBuilder.bind("tm");

    const conditioner = new FindMembershipByIdConditionable(filters);
    const conditions = conditioner.build({ app_user_team_membership: TM.alias });

    const query = `
      SELECT 1
      FROM ${TM.name} ${TM.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query(query, conditions.values);

    return result.rows.length > 0;
  }
}

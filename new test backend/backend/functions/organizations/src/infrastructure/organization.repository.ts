import { BaseRepository, PaginatedResult } from "@shared/ts/db";
import {
  AppUserOrganizationMembershipSelectBuilder,
  ClientSelectBuilder,
  OrganizationSelectBuilder,
  TeamSelectBuilder,
} from "@shared/ts/sql/builders";
import { Paginatable, Pagination } from "@shared/ts/sql/fragments";
import {
  CheckOrganizationExistsConditionable,
  CheckOrganizationExistsFilters,
  CheckOrganizationMemberConditionable,
  CheckOrganizationMemberFilters,
  DeleteOrganizationConditionable,
  DeleteOrganizationFilters,
  DeleteOrganizationMemberConditionable,
  FindAllOrganizationClientsConditionable,
  FindAllOrganizationClientsFilters,
  FindAllOrganizationMembersConditionable,
  FindAllOrganizationMembersFilters,
  FindAllOrganizationsConditionable,
  FindAllOrganizationTeamsConditionable,
  FindAllOrganizationTeamsFilters,
  FindOrganizationByIdConditionable,
  FindOrganizationByIdFilters,
  PatchOrganizationConditionable,
  PatchOrganizationFilters,
  PatchOrganizationMemberConditionable,
  PatchOrganizationMemberFilters,
} from "./filters";
import {
  CreateOrganizationInput,
  CreateOrganizationInsertable,
  CreateOrganizationMemberInput,
  CreateOrganizationMemberInsertable,
  DeleteOrganizationMemberUpdatable,
  DeleteOrganizationUpdatable,
  PatchOrganizationInput,
  PatchOrganizationMemberInput,
  PatchOrganizationMemberUpdatable,
  PatchOrganizationUpdatable,
} from "./inputs";
import {
  AllOrganizationClientsRow,
  AllOrganizationMembersRow,
  AllOrganizationsRow,
  AllOrganizationTeamsRow,
  GetOrganizationByIdRow,
  OrganizationCreatedRow,
  OrganizationDeletedRow,
  OrganizationMemberCreatedRow,
  OrganizationMemberDeletedRow,
  OrganizationMemberPatchedRow,
  OrganizationPatchedRow,
} from "./rows";

export default class OrganizationRepository extends BaseRepository {
  async findAll(pagination: Pagination): Promise<PaginatedResult<AllOrganizationsRow>> {
    const O = OrganizationSelectBuilder.bind("o");
    const conditionable = new FindAllOrganizationsConditionable({});
    const paginator = new Paginatable();

    const conditions = conditionable.build({ organization: O.alias });
    const paginations = paginator.build(pagination);

    const _fetchData = async (): Promise<AllOrganizationsRow[]> => {
      const query = `
      SELECT ${O.select({ exclude: ["archived_on", "archived_by"] })}
      FROM ${O.name} ${O.alias}
      ${conditions.sql}
      ${paginations.sql}
    `;
      const result = await this.query<AllOrganizationsRow>(query, paginations.values);
      return result.rows;
    };

    const _fetchTotal = async (): Promise<number> => {
      const query = `
      SELECT COUNT(DISTINCT ${O.ref("id")})::int AS total
      FROM ${O.name} ${O.alias}
      ${conditions.sql}
    `;
      const result = await this.query<{ total: number }>(query, conditions.values);
      return result.rows[0]?.total ?? 0;
    };

    const [rows, total] = await Promise.all([_fetchData(), _fetchTotal()]);
    const count = rows.length;
    const { limit, offset } = pagination;

    return { rows, total, count, limit, offset };
  }

  async create(input: CreateOrganizationInput): Promise<OrganizationCreatedRow> {
    const O = OrganizationSelectBuilder.bind("o");
    const insertable = new CreateOrganizationInsertable(input);

    const inserts = insertable.build();

    const query = `
      INSERT INTO ${O.name} ${inserts.sql}
      RETURNING ${O.returning({ exclude: ["archived_on", "archived_by"] })}
    `;

    const result = await this.query<OrganizationCreatedRow>(query, inserts.values);
    return result.rows[0];
  }

  async existsByDomain(filters: CheckOrganizationExistsFilters): Promise<boolean> {
    const O = OrganizationSelectBuilder.bind("o");
    const conditionable = new CheckOrganizationExistsConditionable(filters);

    const conditions = conditionable.build({ organization: O.alias });

    const query = `
      SELECT 1
      FROM ${O.name} ${O.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query(query, conditions.values);
    return (result.rowCount ?? 0) > 0;
  }

  async findById(filters: FindOrganizationByIdFilters): Promise<GetOrganizationByIdRow | null> {
    const O = OrganizationSelectBuilder.bind("o");
    const conditionable = new FindOrganizationByIdConditionable(filters);

    const conditions = conditionable.build({ organization: O.alias });

    const query = `
      SELECT ${O.select({ exclude: ["archived_on", "archived_by"] })}
      FROM ${O.name} ${O.alias}
      ${conditions.sql}
    `;

    const result = await this.query<GetOrganizationByIdRow>(query, conditions.values);
    return result.rows[0] ?? null;
  }

  async patchOne(
    filters: PatchOrganizationFilters,
    fields: PatchOrganizationInput
  ): Promise<OrganizationPatchedRow | null> {
    const O = OrganizationSelectBuilder.bind("o");

    const updater = new PatchOrganizationUpdatable(fields);
    const conditioner = new PatchOrganizationConditionable(filters);

    const updates = updater.build();
    const conditions = conditioner.build({ organization: O.alias }, updates.values.length + 1);

    if (!updates.sql) return null;

    const query = `
      UPDATE ${O.name} ${O.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${O.returning({ exclude: ["archived_on", "archived_by"] })}
    `;

    const result = await this.query<OrganizationPatchedRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async archiveOne(filters: DeleteOrganizationFilters): Promise<OrganizationDeletedRow | null> {
    const O = OrganizationSelectBuilder.bind("o");

    const deleter = new DeleteOrganizationUpdatable({});
    const conditioner = new DeleteOrganizationConditionable(filters);

    const deletions = deleter.build();
    const conditions = conditioner.build({ organization: O.alias }, deletions.values.length + 1);

    const query = `
      UPDATE ${O.name} ${O.alias}
      SET ${deletions.sql}
      ${conditions.sql}
      RETURNING ${O.returning("*")}
    `;

    const result = await this.query<OrganizationDeletedRow>(query, [...deletions.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async findAllOrganizationMembers(
    filters: FindAllOrganizationMembersFilters,
    pagination: Pagination
  ): Promise<PaginatedResult<AllOrganizationMembersRow>> {
    const O = OrganizationSelectBuilder.bind("o");
    const OM = AppUserOrganizationMembershipSelectBuilder.bind("om");
    const conditioner = new FindAllOrganizationMembersConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ app_user_organization_membership: OM.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const _fetchData = async (): Promise<AllOrganizationMembersRow[]> => {
      const query = `
      SELECT
        ${OM.select({ include: ["app_user_id", "role"] })},
        ${O.select({ exclude: ["archived_on", "archived_by"] })}
      FROM ${OM.name} ${OM.alias}
      JOIN ${O.name} ${O.alias}
        ON ${OM.ref("organization_id")} = ${O.ref("id")}
      ${conditions.sql}
      ${paginations.sql}
    `;
      const result = await this.query<AllOrganizationMembersRow>(query, [...conditions.values, ...paginations.values]);
      return result.rows;
    };

    const _fetchTotal = async (): Promise<number> => {
      const query = `
      SELECT COUNT(*)::int AS total
      FROM ${OM.name} ${OM.alias}
      JOIN ${O.name} ${O.alias}
        ON ${OM.ref("organization_id")} = ${O.ref("id")}
      ${conditions.sql}
    `;
      const result = await this.query<{ total: number }>(query, conditions.values);
      return result.rows[0]?.total ?? 0;
    };

    const [rows, total] = await Promise.all([_fetchData(), _fetchTotal()]);
    const count = rows.length;
    const { limit, offset } = pagination;

    return { rows, total, count, limit, offset };
  }

  async existsOrganizationMember(filters: CheckOrganizationMemberFilters): Promise<boolean> {
    const OM = AppUserOrganizationMembershipSelectBuilder.bind("om");
    const conditionable = new CheckOrganizationMemberConditionable(filters);

    const conditions = conditionable.build({ app_user_organization_membership: OM.alias });

    const query = `
      SELECT 1
      FROM ${OM.name} ${OM.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query(query, conditions.values);
    return (result.rowCount ?? 0) > 0;
  }

  async createOrganizationMember(input: CreateOrganizationMemberInput): Promise<OrganizationMemberCreatedRow | null> {
    const OM = AppUserOrganizationMembershipSelectBuilder.bind("om");
    const insertable = new CreateOrganizationMemberInsertable(input);

    const inserts = insertable.build();
    if (!inserts.sql) return null;

    const query = `
      INSERT INTO ${OM.name}
      ${inserts.sql}
      RETURNING ${OM.returning({ include: ["organization_id", "app_user_id", "role", "invited_by", "member_since"] })}
    `;

    const result = await this.query<OrganizationMemberCreatedRow>(query, [...inserts.values]);
    return result.rows[0] ?? null;
  }

  async patchOrganizationMember(
    filters: PatchOrganizationMemberFilters,
    input: PatchOrganizationMemberInput
  ): Promise<OrganizationMemberPatchedRow | null> {
    const OM = AppUserOrganizationMembershipSelectBuilder.bind("om");
    const updater = new PatchOrganizationMemberUpdatable(input);
    const conditioner = new PatchOrganizationMemberConditionable(filters);

    const updates = updater.build();
    const conditions = conditioner.build({ app_user_organization_membership: OM.alias }, updates.values.length + 1);

    if (!updates.sql) return null;

    const query = `
      UPDATE ${OM.name} ${OM.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${OM.returning({ include: ["organization_id", "app_user_id", "role"] })}
    `;

    const result = await this.query<OrganizationMemberPatchedRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async deleteOrganizationMember(
    filters: PatchOrganizationMemberFilters
  ): Promise<OrganizationMemberDeletedRow | null> {
    const OM = AppUserOrganizationMembershipSelectBuilder.bind("om");
    const deleter = new DeleteOrganizationMemberUpdatable({});
    const conditioner = new DeleteOrganizationMemberConditionable(filters);

    const deletions = deleter.build();
    const conditions = conditioner.build({ app_user_organization_membership: OM.alias }, deletions.values.length + 1);

    const query = `
      UPDATE ${OM.name} ${OM.alias}
      SET ${deletions.sql}
      ${conditions.sql}
      RETURNING ${OM.returning("*")}
    `;

    const result = await this.query<OrganizationMemberDeletedRow>(query, [...deletions.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async findAllOrganizationTeams(
    filters: FindAllOrganizationTeamsFilters,
    pagination: Pagination
  ): Promise<PaginatedResult<AllOrganizationTeamsRow>> {
    const T = TeamSelectBuilder.bind("t");
    const O = OrganizationSelectBuilder.bind("o");
    const conditioner = new FindAllOrganizationTeamsConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ team: T.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const _fetchData = async (): Promise<AllOrganizationTeamsRow[]> => {
      const query = `
        SELECT
          ${T.select({ exclude: ["archived_on", "archived_by", "organization_id"] })},
          ${O.select({ exclude: ["archived_on", "archived_by"] })}
        FROM ${T.name} ${T.alias}
        JOIN ${O.name} ${O.alias}
          ON ${T.ref("organization_id")} = ${O.ref("id")}
        ${conditions.sql}
        ${paginations.sql}
      `;
      const result = await this.query<AllOrganizationTeamsRow>(query, [...conditions.values, ...paginations.values]);
      return result.rows;
    };

    const _fetchTotal = async (): Promise<number> => {
      const query = `
        SELECT COUNT(DISTINCT ${T.alias}.id)::int AS total
        FROM ${T.name} ${T.alias}
        JOIN ${O.name} ${O.alias}
          ON ${T.ref("organization_id")} = ${O.ref("id")}
        ${conditions.sql}
      `;
      const result = await this.query<{ total: number }>(query, conditions.values);
      return result.rows[0]?.total ?? 0;
    };

    const [rows, total] = await Promise.all([_fetchData(), _fetchTotal()]);
    const count = rows.length;
    const { limit, offset } = pagination;

    return { rows, total, count, limit, offset };
  }

  async findAllOrganizationClients(
    filters: FindAllOrganizationClientsFilters,
    pagination: Pagination
  ): Promise<PaginatedResult<AllOrganizationClientsRow>> {
    const T = TeamSelectBuilder.bind("t");
    const C = ClientSelectBuilder.bind("c");
    const O = OrganizationSelectBuilder.bind("o");
    const conditioner = new FindAllOrganizationClientsConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ team: T.alias, client: C.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const _fetchData = async (): Promise<AllOrganizationClientsRow[]> => {
      const query = `
      SELECT
        ${C.select({ exclude: ["archived_on", "archived_by", "team_id"] })},
        ${T.select({ include: ["id"] })},
        ${O.select({ exclude: ["archived_on", "archived_by"] })}
      FROM ${C.name} ${C.alias}
      JOIN ${T.name} ${T.alias}
        ON ${C.ref("team_id")} = ${T.ref("id")}
      JOIN ${O.name} ${O.alias}
        ON ${T.ref("organization_id")} = ${O.ref("id")}
      ${conditions.sql}
      ${paginations.sql}
    `;

      const result = await this.query<AllOrganizationClientsRow>(query, [...conditions.values, ...paginations.values]);
      return result.rows;
    };

    const _fetchTotal = async (): Promise<number> => {
      const query = `
      SELECT COUNT(DISTINCT ${C.alias}.id)::int AS total
      FROM ${C.name} ${C.alias}
      JOIN ${T.name} ${T.alias}
        ON ${C.ref("team_id")} = ${T.ref("id")}
      JOIN ${O.name} ${O.alias}
        ON ${T.ref("organization_id")} = ${O.ref("id")}
      ${conditions.sql}
    `;

      const result = await this.query<{ total: number }>(query, conditions.values);
      return result.rows[0]?.total ?? 0;
    };

    const [rows, total] = await Promise.all([_fetchData(), _fetchTotal()]);
    const count = rows.length;
    const { limit, offset } = pagination;

    return { rows, total, count, limit, offset };
  }
}

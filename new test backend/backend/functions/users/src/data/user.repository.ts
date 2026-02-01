import { BaseRepository } from "@shared/ts/db";
import {
  AppUserOrganizationMembershipSelectBuilder,
  AppUserSelectBuilder,
  AppUserTeamMembershipSelectBuilder,
} from "@shared/ts/sql/builders";
import { Paginatable, Pagination } from "@shared/ts/sql/fragments";
import { Pool } from "pg";
import {
  ArchiveUserConditionable,
  ArchiveUserFilter,
  GetLimitedUsersConditionable,
  GetUserByIdConditionable,
  GetUserByIdFilter,
  GetUserMeConditionable,
  GetUsersAdditionsConditionable,
  GetUsersFilter,
  PatchUserConditionable,
  PatchUserFilter,
} from "./filters";
import { ArchiveUserUpdatable, PatchUserInput, PatchUserUpdatable } from "./inputs";
import { AllUsersRow, OneUserArchiveRow, OneUserRow } from "./rows";

export class UserRepository extends BaseRepository {
  constructor(pool: Pool) {
    super(pool);
  }

  async getAll(filter: GetUsersFilter, pagination: Pagination): Promise<AllUsersRow[]> {
    const buildLimitedUsersQuery = (filter: GetUsersFilter, pagination: Pagination) => {
      const AU = AppUserSelectBuilder.bind("au");
      const baseConditioner = new GetLimitedUsersConditionable(filter);
      const paginator = new Paginatable();

      const baseConditions = baseConditioner.build({ app_user: AU.alias });
      const paginations = paginator.build(pagination, baseConditions.values.length + 1);

      const query = `
        SELECT ${AU.select({ include: ["id"] })}
        FROM ${AU.name} ${AU.alias}
        ${baseConditions.sql}
        ORDER BY
          ${AU.ref("last_name")} ASC,
          ${AU.ref("first_name")} ASC,
          ${AU.ref("id")} ASC
        ${paginations.sql}
      `;

      return {
        limitedQuery: query.trim(),
        limitedValues: [...baseConditions.values, ...paginations.values],
      };
    };

    const buildUserDetailsQuery = (filter: GetUsersFilter, startIndex: number) => {
      const AU = AppUserSelectBuilder.bind("au");
      const AUTM = AppUserTeamMembershipSelectBuilder.bind("autm");
      const AUOM = AppUserOrganizationMembershipSelectBuilder.bind("auom");

      const additionalConditioner = new GetUsersAdditionsConditionable(filter);
      const additionalConditions = additionalConditioner.build(
        {
          app_user_team_membership: AUTM.alias,
          app_user_organization_membership: AUOM.alias,
        },
        startIndex
      );

      const query = `
        SELECT
          ${AU.select({ include: ["id", "first_name", "last_name"] })},
          ${AUTM.select({ include: ["team_id", "role"] })},
          ${AUOM.select({ include: ["organization_id", "role"] })}
        FROM limited_users lu
        JOIN ${AU.name} ${AU.alias}
          ON ${AU.ref("id")} = lu.app_user_id
        LEFT JOIN ${AUTM.name} ${AUTM.alias}
          ON ${AUTM.ref("app_user_id")} = ${AU.ref("id")}
        LEFT JOIN ${AUOM.name} ${AUOM.alias}
          ON ${AUOM.ref("app_user_id")} = ${AU.ref("id")}
        ${additionalConditions.sql}
      `;

      return {
        detailsQuery: query.trim(),
        detailsValues: additionalConditions.values,
      };
    };

    const { limitedQuery, limitedValues } = buildLimitedUsersQuery(filter, pagination);
    const { detailsQuery, detailsValues } = buildUserDetailsQuery(filter, limitedValues.length + 1);

    const finalQuery = `WITH limited_users AS (${limitedQuery}) ${detailsQuery}`;
    const result = await this.query<AllUsersRow>(finalQuery, [...limitedValues, ...detailsValues]);
    return result.rows;
  }

  async getById(filter: GetUserByIdFilter): Promise<OneUserRow | null> {
    const AU = AppUserSelectBuilder.bind("au");
    const conditioner = new GetUserByIdConditionable(filter);

    const conditions = conditioner.build({ app_user: AU.alias });

    const query = `
      SELECT ${AU.select({ include: ["id", "first_name", "last_name"] })}
      FROM ${AU.name} ${AU.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query<OneUserRow>(query, conditions.values);
    return result.rows[0] || null;
  }

  async getUserMe(): Promise<OneUserRow | null> {
    const AU = AppUserSelectBuilder.bind("au");
    const conditioner = new GetUserMeConditionable({});

    const conditions = conditioner.build({ app_user: AU.alias });

    const query = `
      SELECT ${AU.select({ include: ["id", "first_name", "last_name"] })}
      FROM ${AU.name} ${AU.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query<OneUserRow>(query, conditions.values);
    return result.rows[0] || null;
  }

  async patchUser(input: PatchUserInput, filter: PatchUserFilter): Promise<OneUserRow | null> {
    const AU = AppUserSelectBuilder.bind("au");
    const updater = new PatchUserUpdatable(input);
    const conditioner = new PatchUserConditionable(filter);

    const updates = updater.build();
    const conditions = conditioner.build({ app_user: AU.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${AU.name} ${AU.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${AU.select({ include: ["id", "first_name", "last_name"] })}
    `;

    const result = await this.query<OneUserRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async archiveUser(filter: ArchiveUserFilter): Promise<OneUserArchiveRow | null> {
    const AU = AppUserSelectBuilder.bind("au");
    const updater = new ArchiveUserUpdatable({});
    const conditioner = new ArchiveUserConditionable(filter);

    const updates = updater.build();
    const conditions = conditioner.build({ app_user: AU.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${AU.name} ${AU.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${AU.select({ include: ["id", "first_name", "last_name", "archived_on", "archived_by"] })}
    `;

    const result = await this.query<OneUserArchiveRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }
}

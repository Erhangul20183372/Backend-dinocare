import { BaseRepository } from "@shared/ts/db";
import {
  AppUserSelectBuilder,
  IdentitySelectBuilder,
  OrganizationSelectBuilder,
  AppUserOrganizationMembershipSelectBuilder,
} from "@shared/ts/sql/builders";
import { Pool } from "pg";
import {
  GetOrganizationByDomainConditionable,
  GetOrganizationByDomainFilters,
} from "./filters/get-organization-by-domain.filter";
import { LookupAppUserArgs, LookupAppUserFunction } from "./functions/lookup-app-users.function";
import { LookupIdentityArgs, LookupIdentityFunction } from "./functions/lookup-identity.function";
import { CreateAppUserInput, CreateAppUserInsertable } from "./inputs/create-app-user.input";
import { CreateIdentityInput, CreateIdentityInsertable } from "./inputs/create-identity.input";
import {
  CreateOrganizationMembershipInput,
  CreateOrganizationMembershipInsertable,
} from "./inputs/create-organization-membership.input";
import { AppUserByIdentityIdRow } from "./rows/app-user-by-identity-id.row";
import { AppUserCreatedRow } from "./rows/app-user-created.row";
import { IdentityByEmailRow } from "./rows/identity-by-email.row";
import { IdentityCreatedRow } from "./rows/identity-created.row";
import { OrganizationByDomainRow } from "./rows/organization-by-domain.row";

export default class AuthRepository extends BaseRepository {
  constructor(pool: Pool) {
    super(pool);
  }

  async getByEmail(args: LookupIdentityArgs): Promise<IdentityByEmailRow | null> {
    const functional = new LookupIdentityFunction(args);
    const fn = functional.build();

    const result = await this.query<IdentityByEmailRow>(fn.sql, fn.values);
    return result.rows[0];
  }

  async getByIdentityId(args: LookupAppUserArgs): Promise<AppUserByIdentityIdRow | null> {
    const functional = new LookupAppUserFunction(args);
    const fn = functional.build();

    const result = await this.query<AppUserByIdentityIdRow>(fn.sql, fn.values);
    return result.rows[0];
  }

  async createIdentity(input: CreateIdentityInput): Promise<IdentityCreatedRow> {
    const I = IdentitySelectBuilder.bind("i");
    const insertable = new CreateIdentityInsertable(input);

    const inserts = insertable.build();

    const query = `
      INSERT INTO ${I.name} ${inserts.sql}
      RETURNING ${I.returning("*")}
    `;

    const result = await this.query<IdentityCreatedRow>(query, inserts.values);
    return result.rows[0];
  }

  async createAppUser(input: CreateAppUserInput): Promise<AppUserCreatedRow> {
    const AU = AppUserSelectBuilder.bind("au");
    const insertable = new CreateAppUserInsertable(input);

    const inserts = insertable.build();

    const query = `
      INSERT INTO ${AU.name} ${inserts.sql}
      RETURNING ${AU.returning({ exclude: ["archived_on", "archived_by"] })}
    `;

    const result = await this.query<AppUserCreatedRow>(query, inserts.values);
    return result.rows[0];
  }

  async getOrganizationByDomain(filters: GetOrganizationByDomainFilters): Promise<OrganizationByDomainRow | null> {
    const O = OrganizationSelectBuilder.bind("o");
    const conditionable = new GetOrganizationByDomainConditionable(filters);

    const conditions = conditionable.build({ organization: O.alias });

    const query = `
      SELECT ${O.select({ include: ["id"] })}
      FROM ${O.name} ${O.alias}
      ${conditions.sql}
    `;

    const result = await this.query<OrganizationByDomainRow>(query, conditions.values);
    return result.rows[0];
  }

  async createOrganizationMembership(input: CreateOrganizationMembershipInput): Promise<boolean> {
    const OM = AppUserOrganizationMembershipSelectBuilder.bind("om");
    const insertable = new CreateOrganizationMembershipInsertable(input);

    const inserts = insertable.build();

    const query = `INSERT INTO ${OM.name} ${inserts.sql}`;

    const result = await this.query(query, inserts.values);
    return result.rows.length > 0;
  }
}

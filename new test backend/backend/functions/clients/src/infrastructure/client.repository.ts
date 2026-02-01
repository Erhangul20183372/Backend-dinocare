import { BaseRepository } from "@shared/ts/db";
import {
  ClientDeviceAssignmentSelectBuilder,
  ClientSelectBuilder,
  DeviceSelectBuilder,
  DeviceTypeSelectBuilder,
  TeamSelectBuilder,
} from "@shared/ts/sql/builders";
import { Paginatable, Pagination } from "@shared/ts/sql/fragments";
import {
  CheckClientDeviceConditionable,
  CheckClientDeviceFilters,
  DeleteClientConditionable,
  DeleteClientDeviceConditionable,
  DeleteClientDeviceFilters,
  DeleteClientFilters,
  FindAllConditionable,
  FindAllDevicesConditionable,
  FindAllDevicesFilters,
  FindAllFilters,
  FindByIdConditionable,
  FindByIdFilters,
  PatchClientConditionable,
  PatchClientDeviceConditionable,
  PatchClientDeviceFilters,
  PatchClientFilters,
} from "./filters";
import {
  CreateClientDeviceInput,
  CreateClientDeviceInsertable,
  CreateClientInput,
  CreateClientInsertable,
  DeleteClientDeviceUpdatable,
  DeleteClientUpdatable,
  PatchClientDeviceInput,
  PatchClientDeviceUpdatable,
  PatchClientInput,
  PatchClientUpdatable,
} from "./inputs";
import {
  AllClientDevicesRow,
  AllClientsRow,
  ClientCreatedRow,
  ClientDeletedRow,
  ClientDeviceCreatedRow,
  ClientDeviceDeletedRow,
  ClientDevicePatchedRow,
  ClientPatchedRow,
  GetClientByIdRow,
} from "./rows";

export default class ClientRepository extends BaseRepository {
  async findAll(filters: FindAllFilters, pagination: Pagination): Promise<AllClientsRow[]> {
    const C = ClientSelectBuilder.bind("c");
    const T = TeamSelectBuilder.bind("t");
    const conditioner = new FindAllConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ client: C.alias, team: T.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const query = `
      SELECT ${C.select({ include: ["id", "first_name", "last_name", "gender"] })}, ${T.select({ include: ["id", "name"] })}
      FROM ${C.name} ${C.alias}
      JOIN ${T.name} ${T.alias}
      ON ${C.ref("team_id")} = ${T.ref("id")}
      ${conditions.sql}
      ${paginations.sql}
    `;

    const result = await this.query<AllClientsRow>(query, [...conditions.values, ...paginations.values]);
    return result.rows;
  }

  async create(input: CreateClientInput): Promise<ClientCreatedRow> {
    const C = ClientSelectBuilder.bind("c");
    const insertable = new CreateClientInsertable(input);

    const inserts = insertable.build();

    const query = `
      INSERT INTO ${C.name} ${inserts.sql}
      RETURNING ${C.returning({ include: ["id", "team_id", "gender", "first_name", "last_name"] })}
    `;

    const result = await this.query<ClientCreatedRow>(query, inserts.values);
    return result.rows[0];
  }

  async getById(filters: FindByIdFilters): Promise<GetClientByIdRow | null> {
    const C = ClientSelectBuilder.bind("c");

    const conditioner = new FindByIdConditionable(filters);
    const conditions = conditioner.build({ client: C.alias });

    const query = `
      SELECT ${C.select({ include: ["id", "team_id", "gender", "first_name", "last_name"] })}
      FROM ${C.name} ${C.alias}
      ${conditions.sql}
      LIMIT 1
    `;
    const result = await this.query<GetClientByIdRow>(query, conditions.values);
    return result.rows[0] ?? null;
  }

  async patchOne(filters: PatchClientFilters, fields: PatchClientInput): Promise<ClientPatchedRow | null> {
    const C = ClientSelectBuilder.bind("c");
    const updater = new PatchClientUpdatable(fields);
    const conditioner = new PatchClientConditionable(filters);

    const updates = updater.build();
    const conditions = conditioner.build({ client: C.alias }, updates.values.length + 1);

    if (!updates.sql) return null;

    const query = `
      UPDATE ${C.name} ${C.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${C.returning("*")}
    `;

    const result = await this.query<ClientPatchedRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async delete(filters: DeleteClientFilters): Promise<ClientDeletedRow | null> {
    const C = ClientSelectBuilder.bind("c");
    const deleter = new DeleteClientUpdatable({});
    const conditioner = new DeleteClientConditionable(filters);

    const deletions = deleter.build();
    const conditions = conditioner.build({ client: C.alias }, deletions.values.length + 1);

    const query = `
      UPDATE ${C.name} ${C.alias}
      SET ${deletions.sql}
      ${conditions.sql}
      RETURNING ${C.returning("*")}
    `;

    const result = await this.query<ClientDeletedRow>(query, [...deletions.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async findAllDevices(filters: FindAllDevicesFilters, pagination: Pagination): Promise<AllClientDevicesRow[]> {
    const C = ClientSelectBuilder.bind("c");
    const D = DeviceSelectBuilder.bind("d");
    const CD = ClientDeviceAssignmentSelectBuilder.bind("cd");
    const DT = DeviceTypeSelectBuilder.bind("dt");

    const conditioner = new FindAllDevicesConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({ client: C.alias });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const query = `
      SELECT ${C.select({ exclude: ["archived_on", "archived_by"] })}, ${D.select({ exclude: ["device_type_id"] })}, ${CD.select({ exclude: ["client_id", "device_id"] })} , ${DT.select({ include: ["name"] })}
      FROM ${D.name} ${D.alias}
      JOIN ${CD.name} ${CD.alias}
      ON ${D.ref("id")} = ${CD.ref("device_id")}
      JOIN ${C.name} ${C.alias}
      ON ${CD.ref("client_id")} = ${C.ref("id")}
      JOIN ${DT.name} ${DT.alias}
      ON ${D.ref("device_type_id")} = ${DT.ref("id")}
      ${conditions.sql}
      ${paginations.sql}
    `;

    const result = await this.query<AllClientDevicesRow>(query, [...conditions.values, ...paginations.values]);
    return result.rows;
  }

  async checkClientDeviceAssignment(filters: CheckClientDeviceFilters): Promise<boolean> {
    const CD = ClientDeviceAssignmentSelectBuilder.bind("cd");

    const conditioner = new CheckClientDeviceConditionable(filters);
    const conditions = conditioner.build({ clientDeviceAssignment: CD.alias });

    const query = `
      SELECT 1
      FROM ${CD.name} ${CD.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query<{ exists: number }>(query, conditions.values);
    return result.rowCount !== null && result.rowCount > 0;
  }

  async createDeviceAssignment(input: CreateClientDeviceInput): Promise<ClientDeviceCreatedRow | null> {
    const CD = ClientDeviceAssignmentSelectBuilder.bind("cd");
    const insertable = new CreateClientDeviceInsertable(input);

    const inserts = insertable.build();

    const query = `
      INSERT INTO ${CD.name} ${inserts.sql}
      RETURNING ${CD.returning({ include: ["client_id", "device_id", "assigned_by", "assigned_since", "device_location"] })}
    `;

    const result = await this.query<ClientDeviceCreatedRow>(query, inserts.values);
    return result.rows[0] ?? null;
  }

  async patchDeviceAssignment(
    input: PatchClientDeviceInput,
    filters: PatchClientDeviceFilters
  ): Promise<ClientDevicePatchedRow | null> {
    const CD = ClientDeviceAssignmentSelectBuilder.bind("cd");
    const updater = new PatchClientDeviceUpdatable(input);
    const conditioner = new PatchClientDeviceConditionable(filters);

    const updates = updater.build();
    const conditions = conditioner.build({ clientDeviceAssignment: CD.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${CD.name} ${CD.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${CD.returning({ exclude: ["assigned_by", "assigned_until", "unassigned_by", "assigned_since"] })}
    `;

    const result = await this.query<ClientDevicePatchedRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async deleteDeviceAssignment(filters: DeleteClientDeviceFilters): Promise<ClientDeviceDeletedRow | null> {
    const CD = ClientDeviceAssignmentSelectBuilder.bind("cd");

    const updater = new DeleteClientDeviceUpdatable({});
    const conditioner = new DeleteClientDeviceConditionable(filters);

    const updates = updater.build();
    const conditions = conditioner.build({ clientDeviceAssignment: CD.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${CD.name} ${CD.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${CD.returning("*")}
    `;

    const result = await this.query<ClientDeviceDeletedRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] ?? null;
  }

  async createBulk(input: CreateClientInput[]): Promise<ClientCreatedRow[]> {
    const C = ClientSelectBuilder.bind("c");
    const insertable = new CreateClientInsertable(input);

    const inserts = insertable.build();

    const query = `
      INSERT INTO ${C.name} ${inserts.sql}
      RETURNING ${C.returning({ exclude: ["archived_on", "archived_by"] })}
    `;

    const result = await this.query<ClientCreatedRow>(query, inserts.values);
    return result.rows;
  }
}

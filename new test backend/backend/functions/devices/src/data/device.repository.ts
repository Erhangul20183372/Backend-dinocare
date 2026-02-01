import { BaseRepository } from "@shared/ts/db";
import {
  ClientDeviceAssignmentSelectBuilder,
  ClientSelectBuilder,
  DeviceSelectBuilder,
  DeviceTypeSelectBuilder,
  TeamSelectBuilder,
} from "@shared/ts/sql/builders";
import { Paginatable, Pagination } from "@shared/ts/sql/fragments";
import { Pool } from "pg";
import {
  ExistsByStickerOrSerialConditionable,
  ExistsByStickerOrSerialFilter,
  GetAllDevicesConditionable,
  GetAllDevicesFilter,
  PatchDeviceConditionable,
  PatchDeviceFilters,
} from "./filters";
import { GetDeviceByIdConditionable, GetDeviceByIdFilter } from "./filters/get-device-by-id.filter";
import { PatchDeviceInput, PatchDeviceUpdatable } from "./inputs";
import { CreateDeviceInput, CreateDeviceInsertable } from "./inputs/create-device.input";
import { AllDevicesRow, DeviceCreatedRow, DevicePatchedRow, OneDeviceRow } from "./rows";

export default class DeviceRepository extends BaseRepository {
  constructor(pool: Pool) {
    super(pool);
  }

  async getAll(filters: GetAllDevicesFilter, pagination: Pagination): Promise<AllDevicesRow[]> {
    const D = DeviceSelectBuilder.bind("d");
    const DT = DeviceTypeSelectBuilder.bind("dt");
    const CDA = ClientDeviceAssignmentSelectBuilder.bind("cda");
    const C = ClientSelectBuilder.bind("c");
    const T = TeamSelectBuilder.bind("t");

    const conditioner = new GetAllDevicesConditionable(filters);
    const paginator = new Paginatable();

    const conditions = conditioner.build({
      device: D.alias,
      device_type: DT.alias,
      client_device_assignment: CDA.alias,
      client: C.alias,
      team: T.alias,
    });
    const paginations = paginator.build(pagination, conditions.values.length + 1);

    const query = `
      SELECT ${D.select({ include: ["id", "sticker_id", "serial_number", "status"] })}, ${DT.select({ include: ["name"] })}, ${CDA.select({ include: ["device_location"] })}, ${C.select({ include: ["first_name", "last_name", "id"] })}, ${T.select({ include: ["id"] })}
      FROM ${D.name} ${D.alias}
      LEFT JOIN ${DT.name} ${DT.alias} ON ${D.ref("device_type_id")} = ${DT.ref("id")}
      LEFT JOIN ${CDA.name} ${CDA.alias} ON ${D.ref("id")} = ${CDA.ref("device_id")}
      LEFT JOIN ${C.name} ${C.alias} ON ${CDA.ref("client_id")} = ${C.ref("id")}
      LEFT JOIN ${T.name} ${T.alias} ON ${C.ref("team_id")} = ${T.ref("id")}
      ${conditions.sql}
      ORDER BY ${T.ref("id")}, ${C.ref("id")}
      ${paginations.sql}
    `;

    const result = await this.query<AllDevicesRow>(query, [...conditions.values, ...paginations.values]);
    return result.rows;
  }

  async getOne(filters: GetDeviceByIdFilter): Promise<OneDeviceRow | null> {
    const D = DeviceSelectBuilder.bind("d");
    const DT = DeviceTypeSelectBuilder.bind("dt");
    const conditioner = new GetDeviceByIdConditionable(filters);
    const conditions = conditioner.build({ device: D.alias });

    const query = `
      SELECT ${D.select({ include: ["id", "sticker_id", "serial_number", "status"] })}, ${DT.select({ include: ["name"] })}
      FROM ${D.name} ${D.alias}
      INNER JOIN ${DT.name} ${DT.alias} ON ${D.ref("device_type_id")} = ${DT.ref("id")}
      ${conditions.sql}
    `;

    const result = await this.query<OneDeviceRow>(query, conditions.values);
    return result.rows[0] || null;
  }

  async patchOne(filters: PatchDeviceFilters, input: PatchDeviceInput): Promise<DevicePatchedRow | null> {
    const D = DeviceSelectBuilder.bind("d");
    const conditioner = new PatchDeviceConditionable(filters);
    const updator = new PatchDeviceUpdatable(input);

    const updates = updator.build();
    const conditions = conditioner.build({ device: D.alias }, updates.values.length + 1);

    const query = `
      UPDATE ${D.name} ${D.alias}
      SET ${updates.sql}
      ${conditions.sql}
      RETURNING ${D.returning("*")}
    `;

    const result = await this.query<DevicePatchedRow>(query, [...updates.values, ...conditions.values]);
    return result.rows[0] || null;
  }

  async create(input: CreateDeviceInput): Promise<DeviceCreatedRow> {
    const D = DeviceSelectBuilder.bind("d");
    const inserter = new CreateDeviceInsertable(input);

    const inserts = inserter.build();

    const query = `
      INSERT INTO ${D.name} ${inserts.sql}
      RETURNING ${D.returning("*")}
    `;

    const result = await this.query<DeviceCreatedRow>(query, inserts.values);
    return result.rows[0] || null;
  }

  async existsByStickerOrSerial(filter: ExistsByStickerOrSerialFilter): Promise<boolean> {
    const D = DeviceSelectBuilder.bind("d");
    const conditioner = new ExistsByStickerOrSerialConditionable(filter);

    const conditions = conditioner.build({ device: D.alias });

    const query = `
      SELECT 1
      FROM ${D.name} ${D.alias}
      ${conditions.sql}
      LIMIT 1
    `;

    const result = await this.query(query, conditions.values);
    return (result.rowCount ?? 0) > 0;
  }
}

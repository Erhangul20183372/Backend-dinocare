import { deviceStatuses } from "@shared/ts/entities";
import {
  composeDto,
  isValidEnum,
  isValidSerialNumber,
  isValidStickerId,
  isValidString,
  isValidUUID,
  pagination,
  search,
} from "@shared/ts/validation";
import z from "zod";

const deviceBaseSchema = z.object({
  id: isValidUUID,
  organizationId: isValidUUID,
  teamId: isValidUUID,
  clientId: isValidUUID,
  stickerId: isValidStickerId,
  serialNumber: isValidSerialNumber,
  deviceTypeId: isValidUUID,
  type: isValidString,
  status: isValidEnum(deviceStatuses),
});

export const { schema: createDevicesSchema, dto: CreateDevicesDto } = composeDto({
  body: deviceBaseSchema.pick({ stickerId: true, serialNumber: true, deviceTypeId: true, status: true }),
});
export type CreateDevicesDto = z.infer<typeof CreateDevicesDto>;

export const { schema: getDevicesSchema, dto: GetDevicesDto } = composeDto({
  query: pagination({ max: 100, default: 100 })
    .merge(search)
    .merge(
      deviceBaseSchema
        .pick({ organizationId: true, teamId: true, clientId: true, type: true, status: true })
        .partial({ organizationId: true, teamId: true, clientId: true, type: true, status: true })
    ),
});
export type GetDevicesDto = z.infer<typeof GetDevicesDto>;

export const { schema: getDeviceByIdSchema, dto: GetDeviceByIdDto } = composeDto({
  params: deviceBaseSchema.pick({ id: true }),
});
export type GetDeviceByIdDto = z.infer<typeof GetDeviceByIdDto>;

export const { schema: patchDeviceSchema, dto: PatchDeviceDto } = composeDto({
  params: deviceBaseSchema.pick({ id: true }),
  body: deviceBaseSchema.pick({ status: true }),
});
export type PatchDeviceDto = z.infer<typeof PatchDeviceDto>;

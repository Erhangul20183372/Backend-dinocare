import { composeDto, isValidString, isValidUUID, pagination } from "@shared/ts/validation";
import z from "zod";

const deviceAssignmentBaseSchema = z.object({
  deviceId: isValidUUID,
  clientId: isValidUUID,
  location: isValidString.nullable().default(null),
});

export const { schema: createDeviceAssignmentSchema, dto: CreateDeviceAssignmentDto } = composeDto({
  body: deviceAssignmentBaseSchema.pick({ deviceId: true, location: true }),
  params: deviceAssignmentBaseSchema.pick({ clientId: true }),
});
export type CreateDeviceAssignmentDto = z.infer<typeof CreateDeviceAssignmentDto>;

export const { schema: getDeviceAssignmentsSchema, dto: GetDeviceAssignmentsDto } = composeDto({
  params: deviceAssignmentBaseSchema.pick({ clientId: true }),
  query: pagination({ max: 100, default: 100 }),
});
export type GetDeviceAssignmentsDto = z.infer<typeof GetDeviceAssignmentsDto>;

export const { schema: patchDeviceAssignmentSchema, dto: PatchDeviceAssignmentDto } = composeDto({
  params: deviceAssignmentBaseSchema.pick({ clientId: true, deviceId: true }),
  body: deviceAssignmentBaseSchema.pick({ location: true }),
});
export type PatchDeviceAssignmentDto = z.infer<typeof PatchDeviceAssignmentDto>;

export const { schema: deleteDeviceAssignmentSchema, dto: DeleteDeviceAssignmentDto } = composeDto({
  params: deviceAssignmentBaseSchema.pick({ clientId: true, deviceId: true }),
});
export type DeleteDeviceAssignmentDto = z.infer<typeof DeleteDeviceAssignmentDto>;

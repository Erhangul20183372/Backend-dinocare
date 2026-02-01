import { deviceStatuses, genders } from "@shared/ts/entities";
import { z } from "zod";

export const deviceSchema = z.object({
  id: z.string().uuid(),
  stickerId: z.string(),
  serialNumber: z.string(),
  type: z.string(),
  status: z.enum(deviceStatuses),
  assignedSince: z.date(),
  assignedUntil: z.date().nullable(),
  assignedBy: z.string().uuid(),
  unassignedBy: z.string().uuid().nullable(),
  location: z.string().nullable(),
});

export const allClientDevicesSchema = z.object({
  id: z.string().uuid(),
  teamId: z.string().uuid(),
  firstName: z.string(),
  lastName: z.string(),
  gender: z.enum(genders),
  devices: z.array(deviceSchema),
});

export type AllClientDevicesDto = z.infer<typeof allClientDevicesSchema>;

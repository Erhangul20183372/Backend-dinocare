import { z } from "zod";

export const clientDeviceDeletedSchema = z.object({
  clientId: z.string().uuid(),
  deviceId: z.string().uuid(),
  location: z.string().nullable(),
  assignedBy: z.string().uuid(),
  assignedSince: z.date(),
  assignedUntil: z.date(),
  unassignedBy: z.string().uuid(),
});

export type ClientDeviceDeletedDto = z.infer<typeof clientDeviceDeletedSchema>;

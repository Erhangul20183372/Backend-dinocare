import { z } from "zod";

export const createdClientDeviceSchema = z.object({
  clientId: z.string().uuid(),
  deviceId: z.string().uuid(),
  location: z.string().nullable(),
  assignedBy: z.string().uuid(),
  assignedSince: z.date(),
});

export type CreatedClientDeviceDto = z.infer<typeof createdClientDeviceSchema>;

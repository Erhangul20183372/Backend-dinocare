import { z } from "zod";

export const clientDevicePatchedSchema = z.object({
  clientId: z.string().uuid(),
  deviceId: z.string().uuid(),
  location: z.string().nullable(),
});

export type ClientDevicePatchedDto = z.infer<typeof clientDevicePatchedSchema>;

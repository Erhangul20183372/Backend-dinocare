import z from "zod";
import { AlertType } from "../types/alerts";

export const ListAlertsQuerySchema = z.object({
  clientId: z.string().min(1).optional(),
  organizationId: z.string().min(1).optional(),
  type: z.nativeEnum(AlertType).optional(),
});

export type ListAlertsDTO = z.infer<typeof ListAlertsQuerySchema>;

export const GetAlertParamsSchema = z.object({
  id: z.string().min(1).trim(),
});

export type GetAlertParams = z.infer<typeof GetAlertParamsSchema>;

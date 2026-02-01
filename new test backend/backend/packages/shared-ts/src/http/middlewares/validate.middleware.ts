import { NextFunction, Request, Response } from "express";
import { ZodObject, ZodTypeAny } from "zod";
import { ErrorType } from "../errors";

type Part = "body" | "params" | "query" | "headers";
type SchemaMap = Partial<Record<Part, ZodTypeAny>>;

export const validate = (schemaOrMap: SchemaMap | ZodTypeAny) => (req: Request, res: Response, next: NextFunction) => {
  const isCombined = "safeParse" in schemaOrMap;

  // TODO: as soon as we fully switch to combined schemas, we can remove the individual part validation
  if (isCombined) {
    const result = (schemaOrMap as ZodTypeAny).safeParse({
      ...req.body,
      ...req.query,
      ...req.params,
    });

    if (!result.success)
      return res.status(400).json({
        errorType: ErrorType.VALIDATION_FAILED,
        message: "Request validation failed",
        errors: result.error.issues.map((i) => ({
          path: i.path.join("."),
          code: i.code,
          message: i.message,
        })),
      });

    req.dto = result.data;
    return next();
  }

  // Fallback: individual part validation
  const parts: Part[] = ["body", "params", "query", "headers"];
  let dto: Record<string, unknown> = {};

  for (const part of parts) {
    const schema = (schemaOrMap as SchemaMap)[part];
    if (!schema || (schema instanceof ZodObject && Object.keys(schema.shape).length === 0)) continue;

    const value = req[part];
    const result = schema.safeParse(value);

    if (!result.success) {
      return res.status(400).json({
        errorType: ErrorType.VALIDATION_FAILED,
        message: "Request validation failed",
        errors: result.error.issues.map((i) => ({
          path: `${part}.${i.path.join(".")}`,
          code: i.code,
          message: i.message,
        })),
      });
    }

    dto = { ...dto, ...result.data };
  }

  req.dto = dto;
  next();
};

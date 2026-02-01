import { z } from "zod";

type AnyZodObject = z.ZodObject<any, any, any, any, any>;
type ZodLikeObject = AnyZodObject | z.ZodEffects<AnyZodObject>;

type SchemaConfig = {
  body?: ZodLikeObject;
  query?: ZodLikeObject;
  params?: ZodLikeObject;
};

export function createDtoSchema({ body, query, params }: SchemaConfig) {
  const extractShape = (schema?: ZodLikeObject) =>
    schema instanceof z.ZodObject ? schema.shape : schema instanceof z.ZodEffects ? schema._def.schema.shape : {};

  return z.object({
    ...extractShape(body),
    ...extractShape(query),
    ...extractShape(params),
  });
}

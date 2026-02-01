import { z } from "zod";

function unwrapObject<T extends z.ZodRawShape>(schema: z.ZodObject<T> | z.ZodEffects<z.ZodObject<T>>): z.ZodObject<T> {
  return schema instanceof z.ZodEffects ? schema._def.schema : schema;
}

export function composeDto<
  TBody extends z.ZodRawShape = {},
  TParams extends z.ZodRawShape = {},
  TQuery extends z.ZodRawShape = {},
>(parts: {
  body?: z.ZodObject<TBody> | z.ZodEffects<z.ZodObject<TBody>>;
  params?: z.ZodObject<TParams> | z.ZodEffects<z.ZodObject<TParams>>;
  query?: z.ZodObject<TQuery> | z.ZodEffects<z.ZodObject<TQuery>>;
}): {
  schema: {
    body: z.ZodObject<TBody> | z.ZodEffects<z.ZodObject<TBody>>;
    params: z.ZodObject<TParams> | z.ZodEffects<z.ZodObject<TParams>>;
    query: z.ZodObject<TQuery> | z.ZodEffects<z.ZodObject<TQuery>>;
  };
  dto: z.ZodObject<TParams & TQuery & TBody>;
} {
  const body = (parts.body ?? z.object({}).partial()) as z.ZodObject<TBody> | z.ZodEffects<z.ZodObject<TBody>>;
  const params = (parts.params ?? z.object({}).partial()) as z.ZodObject<TParams> | z.ZodEffects<z.ZodObject<TParams>>;
  const query = (parts.query ?? z.object({}).partial()) as z.ZodObject<TQuery> | z.ZodEffects<z.ZodObject<TQuery>>;

  const schema = { body, params, query } as const;

  const dto = unwrapObject(params).merge(unwrapObject(query)).merge(unwrapObject(body)) as z.ZodObject<
    TParams & TQuery & TBody
  >;

  return { schema, dto };
}

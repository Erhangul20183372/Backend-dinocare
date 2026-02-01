import { NextFunction, Request, Response } from "express";
import { BadRequestError, ErrorType, HttpError } from "../errors";

export const errorMiddleware = (err: Error | HttpError, _req: Request, res: Response, _next: NextFunction) => {
  const status = err instanceof HttpError ? err.statusCode : 500;

  if (err instanceof HttpError) {
    return res.status(status).json(err);
  }

  const isJsonSyntaxError = err instanceof SyntaxError && "body" in err;
  if (isJsonSyntaxError) {
    return res.status(400).json(new BadRequestError(ErrorType.VALIDATION_FAILED, "Invalid JSON payload"));
  }

  console.error("Unexpected error:", err);

  return res.status(status).json({
    errorType: ErrorType.INTERNAL_SERVER_ERROR,
    message: "Internal server error",
  });
};

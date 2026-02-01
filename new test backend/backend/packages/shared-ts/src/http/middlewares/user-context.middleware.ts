import { getCurrentInvoke } from "@codegenie/serverless-express";
import { NextFunction, Request, Response } from "express";
import { ErrorType, InternalServerError, UnauthorizedError } from "../errors";
import { setUserContext } from "./context.middleware";

interface Options {
  allowDevImpersonation?: boolean;
  headerName?: string;
  staticUserId?: string;
}

export const attachUserContext =
  (options: Options = {}) =>
  (req: Request, _res: Response, next: NextFunction) => {
    const { event } = getCurrentInvoke();
    const fromAuthorizer =
      event && event.requestContext && event.requestContext.authorizer?.lambda?.appUserId
        ? String(event.requestContext.authorizer.lambda.appUserId)
        : undefined;

    let appUserId = fromAuthorizer;

    if (!appUserId && options.allowDevImpersonation) {
      if (!options.headerName && !options.staticUserId) {
        throw new InternalServerError(
          "Either headerName or staticUserId must be provided when allowDevImpersonation is true"
        );
      }

      const headerKey = options.headerName?.toLowerCase();
      const fromHeader = headerKey ? (req.headers[headerKey] as string | undefined)?.toString() : undefined;
      appUserId = fromHeader || options.staticUserId;
    }

    if (appUserId) {
      req.context = req.context || {};
      req.context.user = { appUserId };
      setUserContext({ appUserId });
      return next();
    }

    throw new UnauthorizedError(ErrorType.INSUFFICIENT_PERMISSIONS, "Missing user authorization");
  };

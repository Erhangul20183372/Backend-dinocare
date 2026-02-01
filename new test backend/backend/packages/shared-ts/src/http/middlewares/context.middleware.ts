import { AsyncLocalStorage } from "node:async_hooks";
import { NextFunction, Request, Response } from "express";

export type RequestContext = {
  user?: {
    appUserId: string;
  };
};

export const requestContext = new AsyncLocalStorage<RequestContext>();

export const useRequestContext = () => (_req: Request, _res: Response, next: NextFunction) => {
  // Start a fresh context for each request
  requestContext.run({}, () => next());
};

export const getRequestContext = (): RequestContext => requestContext.getStore() ?? {};

export const setUserContext = (user: { appUserId: string }) => {
  const store = requestContext.getStore();
  if (store) {
    store.user = user;
  }
};

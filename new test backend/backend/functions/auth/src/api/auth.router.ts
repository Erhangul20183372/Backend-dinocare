import { attachUserContext, validate } from "@shared/ts";
import { TransactionManager } from "@shared/ts/db";
import { Router } from "express";
import AuthRepository from "../data/auth.repository";
import AuthService from "../domain/auth.service";
import { ENV } from "../env";
import postgresPool from "../utils/postgres_pool";
import AuthController from "./auth.controller";
import * as A from "./dtos/auth.dto";

const createAuthRouter = () => {
  const repo = new AuthRepository(postgresPool);
  const transactionManager = new TransactionManager(postgresPool);
  const service = new AuthService(repo, transactionManager);
  const controller = new AuthController(service);

  const userContextMiddleware = attachUserContext({
    allowDevImpersonation: ENV.NODE_ENV === "development" && ENV.ALLOW_DEV_IMPERSONATION,
    headerName: ENV.DEV_IMPERSONATE_HEADER,
    staticUserId: ENV.DEV_APP_USER_ID || undefined,
  });

  const router = Router();

  router.post("/login", validate(A.loginSchema), controller.login);
  router.post("/refresh", validate(A.refreshSchema), controller.refreshToken);
  router.post("/register", userContextMiddleware, validate(A.registerSchema), controller.register);

  return router;
};

export default createAuthRouter;

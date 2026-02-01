import { validate } from "@shared/ts/http";
import { Router } from "express";
import { UserRepository } from "../data/user.repository";
import { UserService } from "../domain/user.service";
import postgresPool from "../utils/postgres_pool";
import * as AU from "./dtos/user.dto";
import { UserController } from "./user.controller";

const createUserRouter = () => {
  const repo = new UserRepository(postgresPool);
  const service = new UserService(repo);
  const controller = new UserController(service);

  const router = Router();

  router.get("/", validate(AU.getUsersSchema), controller.getAll);
  router.get("/me", controller.getMe);
  router.get("/:id", validate(AU.getUserByIdSchema), controller.getById);
  router.patch("/:id", validate(AU.patchUserSchema), controller.patchById);
  router.delete("/:id", validate(AU.archiveUserSchema), controller.archiveById);

  return router;
};

export default createUserRouter;

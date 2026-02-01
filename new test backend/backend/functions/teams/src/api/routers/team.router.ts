import { validate } from "@shared/ts/http";
import { Router } from "express";
import { TeamService } from "../../domain/services/team.service";
import { TeamRepository } from "../../infrastructure/repositories/team.repository";
import postgresPool from "../../utils/postgres_pool";
import { TeamController } from "../controllers/team.controller";
import * as TM from "../dtos/team-membership.dto";
import * as T from "../dtos/team.dto";

export const createTeamRouter = () => {
  const repo = new TeamRepository(postgresPool);
  const service = new TeamService(repo);
  const controller = new TeamController(service);

  const router = Router();

  router.post("/", validate(T.createTeamSchema), controller.createTeam);
  router.post("/bulk", validate(T.bulkCreateTeamSchema), controller.bulkCreateTeams);
  router.get("/", validate(T.getTeamsSchema), controller.getAllTeams);
  router.get("/:id", validate(T.getTeamByIdSchema), controller.getTeamById);
  router.patch("/:id", validate(T.patchTeamSchema), controller.patchTeamById);
  router.delete("/:id", validate(T.deleteTeamSchema), controller.deleteTeamById);
  router.get("/:teamId/clients", validate(T.getTeamClientsSchema), controller.getTeamClients);

  router.get("/:teamId/members", validate(TM.getTeamMembersSchema), controller.getTeamMembers);
  router.post("/:teamId/members", validate(TM.createTeamMembershipSchema), controller.addMemberToTeam);
  router.patch("/:teamId/members/:appUserId", validate(TM.patchTeamMembershipSchema), controller.updateMembership);
  router.delete("/:teamId/members/:appUserId", validate(TM.deleteTeamMembershipSchema), controller.deleteTeamMember);

  return router;
};

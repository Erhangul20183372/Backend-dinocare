import { validate } from "@shared/ts/http";
import { Router } from "express";
import OrganizationService from "../domain/organizations.service";
import OrganizationRepository from "../infrastructure/organization.repository";
import postgresPool from "../utils/postgres_pool";
import * as OM from "./dtos/organization-membership.dto";
import * as O from "./dtos/organization.dto";
import OrganizationController from "./organization.controller";

const createOrganizationRouter = () => {
  const repo = new OrganizationRepository(postgresPool);
  const service = new OrganizationService(repo);
  const controller = new OrganizationController(service);

  const router = Router();

  router.get("/", validate(O.getOrganizationsSchema), controller.getOrganizations);
  router.post("/", validate(O.createOrganizationSchema), controller.createOrganization);
  router.get("/:id", validate(O.getOrganizationByIdSchema), controller.getOrganizationById);
  router.patch("/:id", validate(O.patchOrganizationSchema), controller.patchOrganization);
  router.delete("/:id", validate(O.deleteOrganizationSchema), controller.deleteOrganization);
  router.get("/:id/teams", validate(O.getOrganizationTeamsSchema), controller.getOrganizationTeams);
  router.get("/:id/clients", validate(O.getOrganizationClientsSchema), controller.getOrganizationClients);

  router.get(
    "/:organizationId/members",
    validate(OM.getOrganizationMembershipsSchema),
    controller.getOrganizationMembers
  );
  router.post(
    "/:organizationId/members",
    validate(OM.createOrganizationMembershipSchema),
    controller.createOrganizationMember
  );
  router.patch(
    "/:organizationId/members/:appUserId",
    validate(OM.patchOrganizationMembershipSchema),
    controller.patchOrganizationMember
  );
  router.delete(
    "/:organizationId/members/:appUserId",
    validate(OM.deleteOrganizationMembershipSchema),
    controller.deleteOrganizationMember
  );

  return router;
};

export default createOrganizationRouter;

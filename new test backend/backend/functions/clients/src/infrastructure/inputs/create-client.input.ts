import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateClientInput = {
  gender: "male" | "female" | "other";
  firstName: string;
  lastName: string;
  teamId: string;
};

export class CreateClientInsertable extends BaseInsertable<CreateClientInput> {
  protected mapping = {
    gender: "gender",
    firstName: "first_name",
    lastName: "last_name",
    teamId: "team_id",
  } as const;
}

import { currentUser, now } from "@shared/ts/db";
import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateClientDeviceInput = {
  clientId: string;
  deviceId: string;
  location: string | null;
};

export class CreateClientDeviceInsertable extends BaseInsertable<CreateClientDeviceInput> {
  protected mapping = {
    clientId: "client_id",
    deviceId: "device_id",
    location: "device_location",
  } as const;

  constructor(input: CreateClientDeviceInput) {
    super(input);
    this.addExpression("assigned_by", currentUser);
    this.addExpression("assigned_since", now);
  }
}

import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchClientDeviceInput = {
  location: string | null;
};

export class PatchClientDeviceUpdatable extends BaseUpdatable<PatchClientDeviceInput> {
  protected mapping = {
    location: "device_location",
  } as const;
}

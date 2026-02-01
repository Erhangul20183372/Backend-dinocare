import { DeviceStatus } from "@shared/ts/entities";
import { BaseUpdatable } from "@shared/ts/sql/fragments";

export type PatchDeviceInput = {
  status: DeviceStatus;
};

export class PatchDeviceUpdatable extends BaseUpdatable<PatchDeviceInput> {
  protected mapping = {
    status: "status",
  } as const;
}

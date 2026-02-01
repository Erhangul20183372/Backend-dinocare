import { DeviceStatus } from "@shared/ts/entities";
import { BaseInsertable } from "@shared/ts/sql/fragments";

export type CreateDeviceInput = {
  stickerId: string;
  serialNumber: string;
  deviceTypeId: string;
  status: DeviceStatus;
};

export class CreateDeviceInsertable extends BaseInsertable<CreateDeviceInput> {
  protected mapping = {
    stickerId: "sticker_id",
    serialNumber: "serial_number",
    deviceTypeId: "device_type_id",
    status: "status",
  } as const;
}

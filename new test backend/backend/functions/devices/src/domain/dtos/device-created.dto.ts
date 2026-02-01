import { DeviceStatus } from "@shared/ts/entities";

export interface DeviceCreatedDto {
  deviceId: string;
  stickerId: string;
  serialNumber: string;
  status: DeviceStatus;
  typeId: string;
}

import { DeviceStatus } from "@shared/ts/entities";

export interface DevicePatchedDto {
  deviceId: string;
  stickerId: string;
  serialNumber: string;
  status: DeviceStatus;
  typeId: string;
}

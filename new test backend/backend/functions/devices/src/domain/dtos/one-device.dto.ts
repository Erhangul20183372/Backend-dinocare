import { DeviceStatus } from "@shared/ts/entities";

export interface OneDeviceDto {
  deviceId: string;
  stickerId: string;
  serialNumber: string;
  status: DeviceStatus;
  type: string;
}

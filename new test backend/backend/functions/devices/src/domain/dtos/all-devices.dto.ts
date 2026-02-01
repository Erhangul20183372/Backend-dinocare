import { DeviceStatus } from "@shared/ts/entities";

export interface AllDevicesDto {
  deviceId: string;
  stickerId: string;
  serialNumber: string;
  status: DeviceStatus;
  type: string;
  location: string | null;
  client: {
    id: string;
    firstName: string;
    lastName: string;
  } | null;
  teamId: string | null;
}

export const DeviceStatus = {
  ACTIVE: "active",
  INACTIVE: "inactive",
  RETIRED: "retired",
  IN_REPAIR: "in_repair",
} as const;

export type DeviceStatus = (typeof DeviceStatus)[keyof typeof DeviceStatus];

export const deviceStatuses = Object.values(DeviceStatus) as [DeviceStatus, ...DeviceStatus[]];

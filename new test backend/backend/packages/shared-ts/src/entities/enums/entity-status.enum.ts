export const EntityStatus = {
  ACTIVE: "active",
  INACTIVE: "inactive",
} as const;

export type EntityStatus = (typeof EntityStatus)[keyof typeof EntityStatus];

export const entityStatuses = Object.values(EntityStatus) as [EntityStatus, ...EntityStatus[]];

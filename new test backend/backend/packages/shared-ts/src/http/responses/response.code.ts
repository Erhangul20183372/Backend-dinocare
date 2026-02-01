export const ResponseCode = {
  OK: "OK",
  CREATED: "CREATED",
  NO_CONTENT: "NO_CONTENT",
  PARTIAL_CONTENT: "PARTIAL_CONTENT",
  ACCEPTED: "ACCEPTED",
} as const;

export type ResponseCode = (typeof ResponseCode)[keyof typeof ResponseCode];

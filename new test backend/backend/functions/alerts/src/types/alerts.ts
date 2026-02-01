export enum AlertType {
  TOILET_ALERT = "TOILET_ALERT",
  MEAL_ALERT = "MEAL_ALERT",
  FRONT_DOOR_ALERT = "FRONT_DOOR_ALERT",
}

export type BaseAlert = {
  id: string;
  type: AlertType;
  organizationId: string;
  clientId: string;
  timestamp: number;
  createdAt?: number;
  updatedAt?: number;
};

export type ToiletContext = {
  meanIntervalMin: number;
  stdIntervalMin: number;
  toiletVisits: number;
};

export type LlmConclusion = {
  explanation: string;
  short_explanation: string;
  urgency: number;
  action: "INFO" | "MONITOR" | "FOLLOW_UP" | "ESCALATE";
};

export type ToiletAlert = BaseAlert & {
  type: AlertType.TOILET_ALERT;
  context: ToiletContext;
  llmConclusion?: LlmConclusion;
};

export type MealAlert = BaseAlert & {
  type: AlertType.MEAL_ALERT;
  context: {
    meal: "BREAKFAST" | "LUNCH" | "DINNER";
    mealAlertType: "MEAL_SKIPPED" | "MEAL_DELAYED" | "MEAL_EARLY";
  };
};

export type FrontDoorAlert = BaseAlert & {
  type: AlertType.FRONT_DOOR_ALERT;
  message: string;
  feedback: string | null;
  context: {
    hour: number;
    score: number;
  };
};

export type Alert = ToiletAlert | MealAlert | FrontDoorAlert;

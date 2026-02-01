import { ListAlertsDTO } from "../dtos/alerts";
import { Alert, AlertType } from "../types/alerts";

const alerts: Alert[] = [
  {
    id: "6851c3f73d357ca694328682",
    type: AlertType.TOILET_ALERT,
    organizationId: "67b4735e593f1da4f644f48c",
    clientId: "2b6d1a5b-8624-4245-8430-897c19af43b4",
    timestamp: 1747008000000,
    createdAt: 1750189047124,
    updatedAt: 1750189047124,
    context: { meanIntervalMin: 136, stdIntervalMin: 98, toiletVisits: 6 },
    llmConclusion: {
      explanation:
        "Cliënt heeft minder toiletbezoeken en langere intervallen dan normaal, wat kan wijzen op een verminderde vochtinname; het is raadzaam dit verder te laten controleren.",
      short_explanation: "Minder toiletbezoeken, controle nodig.",
      urgency: 6,
      action: "FOLLOW_UP",
    },
  },
  {
    id: "68539951bfc76e75e0cfd9bf",
    type: AlertType.TOILET_ALERT,
    organizationId: "67b4735e593f1da4f644f48c",
    clientId: "625e3855-1807-4646-b109-4702c9c049c0",
    timestamp: 1744761600000,
    createdAt: 1750309201034,
    updatedAt: 1750309201034,
    context: { meanIntervalMin: 254, stdIntervalMin: 30, toiletVisits: 4 },
    llmConclusion: {
      explanation:
        "Cliënt heeft vandaag minder toiletbezoeken met langere en regelmatige tussenpozen, wat kan wijzen op verminderde inname of obstipatie.",
      short_explanation: "Minder toiletbezoeken, mogelijke obstipatie.",
      urgency: 6,
      action: "FOLLOW_UP",
    },
  },
  {
    id: "683a85c8bfc22f2e45abb565",
    type: AlertType.MEAL_ALERT,
    organizationId: "67b4735e593f1da4f644f48c",
    clientId: "625e3855-1807-4646-b109-4702c9c049c0",
    timestamp: 1748609012700,
    createdAt: 1748665800438,
    updatedAt: 1748665800438,
    context: { meal: "LUNCH", mealAlertType: "MEAL_SKIPPED" },
  },
  {
    id: "682cd1745ccc548b11aa9422",
    type: AlertType.FRONT_DOOR_ALERT,
    organizationId: "67b4735e593f1da4f644f48c",
    clientId: "3d1226ad-d2e6-4e7b-a894-2796524f2e7c",
    timestamp: 1740530977161,
    message: "Voordeur geopend op ongebruikelijk tijdstip.",
    feedback: null,
    context: { hour: 0, score: -0.1658659231211448 },
  },
  {
    id: "682cd1745ccc548b11aa942f",
    type: AlertType.FRONT_DOOR_ALERT,
    organizationId: "67b4735e593f1da4f644f48c",
    clientId: "3d1226ad-d2e6-4e7b-a894-2796524f2e7c",
    timestamp: 1743828029305,
    message: "Voordeur geopend op ongebruikelijk tijdstip.",
    feedback: null,
    context: { hour: 4, score: -0.15462753086764747 },
  },
];

export class AlertsRepository {
  getAll(dto: ListAlertsDTO): Alert[] {
    return alerts.filter((a) => {
      if (dto?.clientId && a.clientId !== dto.clientId) return false;
      if (dto?.organizationId && a.organizationId !== dto.organizationId) return false;
      if (dto?.type && a.type !== dto.type) return false;
      return true;
    });
  }

  getById(id: string): Alert | null {
    return alerts.find((a) => a.id === id) ?? null;
  }
}

import { ErrorType, NotFoundError } from "@shared/ts/http";
import { GetAlertParams, ListAlertsDTO } from "../dtos/alerts";
import { AlertsRepository } from "../repositories/alerts.repository";
import { Alert } from "../types/alerts";

// Interface voor feedback input
interface AlertFeedbackInput {
  userId: number;
  alertId: number;
  feedback: string;
}

export class AlertsService {
  constructor(private repo: AlertsRepository) {}

  async list(dto: ListAlertsDTO): Promise<Alert[]> {
    return this.repo.getAll(dto);
  }

  async get(dto: GetAlertParams): Promise<Alert | null> {
    // Zet id om naar string, want repo verwacht string
    const row = await this.repo.getById(String(dto.id));

    if (!row) throw new NotFoundError(ErrorType.ALERT_NOT_FOUND, "Alert not found");

    return row;
  }

  // Nieuwe methode voor feedback
  async submitFeedback(input: AlertFeedbackInput): Promise<void> {
    const alert = await this.repo.getById(String(input.alertId));

    if (!alert) {
      throw new NotFoundError(ErrorType.ALERT_NOT_FOUND, "Alert not found");
    }

    // TODO: hier kun je opslaan in de database
    // Bijvoorbeeld: this.repo.saveFeedback(input);
    console.log("Feedback ontvangen:", input);

    // Voor nu loggen we het alleen
  }
}

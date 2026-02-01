import { OkResponse } from "@shared/ts/http";
import { Request, Response } from "express";
import { AlertsService } from "../services/alerts.service";

export class AlertsController {
  constructor(private service: AlertsService) {}

  // Bestaande methodes
  list = async (req: Request, res: Response) => {
    const result = await this.service.list(req.dto);

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  getById = async (req: Request, res: Response) => {
    const result = await this.service.get(req.dto);

    const response = new OkResponse({ data: result });
    return res.status(response.status).json(response);
  };

  // Nieuwe methode voor feedback
  submitFeedback = async (req: Request, res: Response) => {
  	console.log("BODY:", req.body);
  	console.log("PARAMS:", req.params);
  	console.log("QUERY:", req.query);
  	console.log("HEADERS:", req.headers);    
	const { userId, alertId, feedback } = req.body;


    if (!userId || !alertId || !feedback) {
      return res.status(400).json({
        message: "userId, alertId en feedback zijn verplicht",
      });
    }

    // Standaard response
    const response = new OkResponse({
      data: {
        status: "ok",
        message: "Feedback ontvangen",
      },
    });

    return res.status(response.status).json(response);
  };
}

import winston from "winston";
import Transport from "winston-transport";
import SlackTransport from "./slack.transport.js";

const isProduction = process.env.NODE_ENV === "production";
const hasSlackWebhook = Boolean(process.env.SLACK_WEBHOOK_URL);

const { combine, timestamp, printf, errors, colorize } = winston.format;

const logFormat = printf(
  ({ level, message, timestamp, stack }) => `${timestamp} [${level}]: ${message}${stack ? `\n${stack}` : ""}`
);

const transports: Transport[] = [
  new winston.transports.Console({
    format: combine(timestamp(), colorize(), logFormat),
  }),
];

if (hasSlackWebhook) {
  transports.push(new SlackTransport({ level: "warn" }));
}

export const logger = winston.createLogger({
  level: isProduction ? "warn" : "debug",
  format: combine(timestamp(), errors({ stack: true }), logFormat),
  transports,
});

export default logger;

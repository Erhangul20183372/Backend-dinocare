import axios from "axios";
import TransportStream from "winston-transport";

class SlackTransport extends TransportStream {
  constructor(opts: TransportStream.TransportStreamOptions) {
    super(opts);
  }

  log(info: any, callback: () => void) {
    const webhook = process.env.SLACK_WEBHOOK_URL;
    if (!webhook) return callback();

    const message = {
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: `:warning: *DinoWatch Alert* :warning:\n*Service:* Functions\n*Level:* ${String(info.level).toUpperCase()}\n*Environment:* ${process.env.NODE_ENV}\n*Timestamp:* ${new Date().toISOString()}\n`,
          },
        },
        { type: "divider" },
        {
          type: "section",
          text: { type: "mrkdwn", text: `*Error Details:*\n\`\`\`${JSON.stringify(info, null, 2)}\`\`\`` },
        },
      ],
    };

    axios.post(webhook, message).catch((error) => {
      console.error("Error sending log to Slack:", error);
    });
    callback();
  }
}

export default SlackTransport;

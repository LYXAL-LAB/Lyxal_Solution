import nodemailer from "nodemailer";
import { logger } from "../pkg/logger";
import { config } from "../config";

export interface EmailMessage {
    to: string;
    subject: string;
    html: string;
    text?: string;
}

export class EmailService {
    private transporter: nodemailer.Transporter;

    constructor() {
        this.transporter = nodemailer.createTransport({
            host: config.mail.host,
            port: config.mail.port,
            secure: config.mail.tls,
            auth: {
                user: config.mail.username,
                pass: config.mail.password,
            },
        });
    }

    async send(message: EmailMessage): Promise<void> {
        try {
            const info = await this.transporter.sendMail({
                from: config.mail.from || `"${config.app.organisation}" <noreply@lyxal.com>`,
                to: message.to,
                subject: config.mail.subjectPrefix + message.subject,
                html: message.html,
                text: message.text,
            });
            logger.info(`Email sent: ${info.messageId}`);
        } catch (error) {
            logger.error("Failed to send email", error);
            throw error;
        }
    }
}

export const emailService = new EmailService();

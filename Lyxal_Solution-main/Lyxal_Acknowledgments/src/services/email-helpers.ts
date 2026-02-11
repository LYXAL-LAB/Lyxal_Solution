import { emailService, EmailMessage } from "./email.service";
import { emailQueueRepository } from "../repositories/email-queue.repository";
import { emailRenderer } from "./email-renderer.service";

/**
 * Send an email directly (synchronous)
 */
export async function sendEmail(
    template: string,
    to: string[],
    locale: string,
    subject: string,
    data: Record<string, any>
): Promise<void> {
    // Render template
    const templateData = {
        ...data,
        BaseURL: process.env.BASE_URL || "http://localhost:3000",
        Organisation: process.env.ORGANISATION || "Lyxal",
    };

    const html = emailRenderer.render(template, templateData);

    const message: EmailMessage = {
        to: to.join(", "),
        subject,
        html,
    };

    await emailService.send(message);
}

/**
 * Send a signature reminder email directly (synchronous)
 */
export async function sendSignatureReminderEmail(
    to: string[],
    locale: string,
    docID: string,
    docURL: string,
    signURL: string,
    recipientName: string
): Promise<void> {
    const data = {
        DocID: docID,
        DocURL: docURL,
        SignURL: signURL,
        RecipientName: recipientName,
    };

    const subject = locale === "fr"
        ? "Rappel : Confirmation de lecture de document requise"
        : "Reminder: Document reading confirmation required";

    await sendEmail("signature_reminder", to, locale, subject, data);
}

/**
 * Queue an email for asynchronous sending
 */
export async function queueEmail(
    template: string,
    to: string[],
    locale: string,
    subject: string,
    data: Record<string, any>,
    priority: "high" | "normal" = "normal"
): Promise<void> {
    await emailQueueRepository.enqueue(to.join(", "), subject, "", template, data);
}

/**
 * Queue a signature reminder email
 */
export async function queueSignatureReminderEmail(
    recipients: string[],
    locale: string,
    docID: string,
    docURL: string,
    signURL: string,
    recipientName: string,
    sentBy: string
): Promise<void> {
    const data = {
        doc_id: docID,
        doc_url: docURL,
        sign_url: signURL,
        recipient_name: recipientName,
        locale,
    };

    const subject = locale === "fr"
        ? "Rappel : Signature de document requise"
        : "Reminder: Document signature required";

    // Queue with high priority
    await emailQueueRepository.enqueue(
        recipients.join(", "),
        subject,
        "",
        "signature_reminder",
        data
    );
}

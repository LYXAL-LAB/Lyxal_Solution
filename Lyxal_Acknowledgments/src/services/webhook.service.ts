import { db } from "../db";
import { logger } from "../pkg/logger";
import { randomUUID } from "crypto";

export class WebhookService {
    /**
     * Publishes an event to all subscribed webhooks.
     * Enqueues a delivery record for each active webhook.
     */
    async publish(eventType: string, payload: any): Promise<void> {
        try {
            logger.info(`Publishing event: ${eventType}`);

            // 1. List active webhooks for this event
            // Note: In SurrealDB, we can store events as an array of strings in the webhook record
            const webhooks = await db.query(
                "SELECT * FROM webhooks WHERE active = true AND $eventType IN events",
                { eventType }
            );

            const hooksList = webhooks[0] as any[];

            if (!hooksList || hooksList.length === 0) {
                return;
            }

            const eventId = randomUUID();

            // 2. Enqueue deliveries
            for (const hook of hooksList) {
                await db.create("webhook_deliveries", {
                    webhook_id: hook.id,
                    event_type: eventType,
                    event_id: eventId,
                    payload: payload,
                    status: "pending",
                    priority: 0,
                    max_retries: 6,
                    created_at: new Date(),
                    next_retry_at: new Date() // Ready immediately
                });
                logger.info(`Enqueued webhook delivery for ${hook.target_url}`);
            }

        } catch (error: any) {
            logger.error(`Failed to publish event ${eventType}`, error);
            // Don't throw, just log. Webhooks shouldn't break the main flow.
        }
    }
}

export const webhookService = new WebhookService();

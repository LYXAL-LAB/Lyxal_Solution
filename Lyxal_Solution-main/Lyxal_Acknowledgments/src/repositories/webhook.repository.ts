import { db } from "../db";
import { logger } from "../pkg/logger";

export interface Webhook {
    id: string;
    url: string;
    events: string[];
    secret?: string;
    active: boolean;
    created_by: string;
    created_at: Date;
    updated_at: Date;
}

export interface WebhookDelivery {
    id: string;
    webhook_id: string;
    event_type: string;
    payload: any;
    status: "pending" | "success" | "failed";
    response_status_code?: number;
    response_body?: string;
    error_message?: string;
    retries: number;
    max_retries: number;
    next_retry_at: Date;
    delivered_at?: Date;
    created_at: Date;
    updated_at: Date;
}

export class WebhookRepository {
    /**
     * Create a webhook
     */
    async create(url: string, events: string[], secret: string, createdBy: string): Promise<Webhook> {
        try {
            const [webhook] = await db.create("webhooks", {
                url,
                events,
                secret,
                active: true,
                created_by: createdBy,
                created_at: new Date(),
                updated_at: new Date()
            });
            return webhook as Webhook;
        } catch (error) {
            logger.error("Failed to create webhook", error);
            throw error;
        }
    }

    /**
     * List all active webhooks
     */
    async listActive(): Promise<Webhook[]> {
        try {
            const result = await db.query("SELECT * FROM webhooks WHERE active = true ORDER BY created_at DESC");
            return result[0] as Webhook[];
        } catch (error) {
            logger.error("Failed to list active webhooks", error);
            throw error;
        }
    }

    /**
     * List webhooks by event type
     */
    async listByEvent(eventType: string): Promise<Webhook[]> {
        try {
            const result = await db.query(
                "SELECT * FROM webhooks WHERE active = true AND $eventType IN events",
                { eventType }
            );
            return result[0] as Webhook[];
        } catch (error) {
            logger.error(`Failed to list webhooks for event ${eventType}`, error);
            throw error;
        }
    }

    /**
     * Update webhook
     */
    async update(id: string, url?: string, events?: string[], secret?: string, active?: boolean): Promise<Webhook> {
        try {
            const updates: any = { updated_at: new Date() };
            if (url !== undefined) updates.url = url;
            if (events !== undefined) updates.events = events;
            if (secret !== undefined) updates.secret = secret;
            if (active !== undefined) updates.active = active;

            const [webhook] = await db.merge(id, updates);
            return webhook as Webhook;
        } catch (error) {
            logger.error(`Failed to update webhook ${id}`, error);
            throw error;
        }
    }

    /**
     * Delete webhook
     */
    async delete(id: string): Promise<void> {
        try {
            await db.delete(id);
        } catch (error) {
            logger.error(`Failed to delete webhook ${id}`, error);
            throw error;
        }
    }
}

export class WebhookDeliveryRepository {
    /**
     * Create a webhook delivery
     */
    async create(webhookId: string, eventType: string, payload: any): Promise<WebhookDelivery> {
        try {
            const [delivery] = await db.create("webhook_deliveries", {
                webhook_id: webhookId,
                event_type: eventType,
                payload,
                status: "pending",
                retries: 0,
                max_retries: 3,
                next_retry_at: new Date(),
                created_at: new Date(),
                updated_at: new Date()
            });
            return delivery as WebhookDelivery;
        } catch (error) {
            logger.error("Failed to create webhook delivery", error);
            throw error;
        }
    }

    /**
     * Get pending deliveries
     */
    async getPending(limit: number = 10): Promise<WebhookDelivery[]> {
        try {
            const result = await db.query(
                `SELECT * FROM webhook_deliveries 
         WHERE status = 'pending' AND next_retry_at <= time::now()
         LIMIT $limit`,
                { limit }
            );
            return result[0] as WebhookDelivery[];
        } catch (error) {
            logger.error("Failed to get pending webhook deliveries", error);
            throw error;
        }
    }

    /**
     * Mark delivery as successful
     */
    async markAsSuccess(id: string, statusCode: number, responseBody: string): Promise<void> {
        try {
            await db.merge(id, {
                status: "success",
                response_status_code: statusCode,
                response_body: responseBody,
                delivered_at: new Date(),
                updated_at: new Date()
            });
        } catch (error) {
            logger.error(`Failed to mark delivery ${id} as success`, error);
            throw error;
        }
    }

    /**
     * Mark delivery as failed
     */
    async markAsFailed(id: string, errorMessage: string, retryDelay: number = 60000): Promise<void> {
        try {
            const [delivery] = await db.select(id);
            const current = delivery as WebhookDelivery;
            const newRetries = (current.retries || 0) + 1;

            if (newRetries >= (current.max_retries || 3)) {
                await db.merge(id, {
                    status: "failed",
                    error_message: errorMessage,
                    updated_at: new Date()
                });
            } else {
                await db.merge(id, {
                    retries: newRetries,
                    error_message: errorMessage,
                    next_retry_at: new Date(Date.now() + retryDelay * Math.pow(2, newRetries)),
                    updated_at: new Date()
                });
            }
        } catch (error) {
            logger.error(`Failed to mark delivery ${id} as failed`, error);
            throw error;
        }
    }

    /**
     * Get deliveries for a webhook
     */
    async getByWebhookId(webhookId: string, limit: number = 50): Promise<WebhookDelivery[]> {
        try {
            const result = await db.query(
                "SELECT * FROM webhook_deliveries WHERE webhook_id = $webhookId ORDER BY created_at DESC LIMIT $limit",
                { webhookId, limit }
            );
            return result[0] as WebhookDelivery[];
        } catch (error) {
            logger.error(`Failed to get deliveries for webhook ${webhookId}`, error);
            throw error;
        }
    }
}

export const webhookRepository = new WebhookRepository();
export const webhookDeliveryRepository = new WebhookDeliveryRepository();

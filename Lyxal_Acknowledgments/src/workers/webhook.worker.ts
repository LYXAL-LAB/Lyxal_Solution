import { db } from "../db";
import { logger } from "../pkg/logger";
import { webhookDeliveryRepository, WebhookDelivery } from "../repositories/webhook.repository";
import { createHmac } from "crypto";

export class WebhookWorker {
    private batchSize = 10;
    private pollInterval = 5000; // 5 seconds
    private cleanupInterval = 3600000; // 1 hour
    private cleanupAge = 30 * 24 * 60 * 60 * 1000; // 30 days
    private maxConcurrent = 5;
    private requestTimeout = 10000; // 10 seconds

    private isRunning = false;
    private stopSignal = false;

    /**
     * Start the worker
     */
    start() {
        if (this.isRunning) return;
        this.isRunning = true;
        this.stopSignal = false;

        logger.info("Starting webhook worker");

        this.processLoop();
        this.cleanupLoop();
    }

    /**
     * Stop the worker
     */
    stop() {
        this.stopSignal = true;
        this.isRunning = false;
        logger.info("Stopping webhook worker...");
    }

    /**
     * Main processing loop
     */
    private async processLoop() {
        while (!this.stopSignal) {
            try {
                await this.processBatch();
            } catch (error) {
                logger.error("Error in webhook worker process loop", error);
            }

            if (!this.stopSignal) {
                await new Promise(resolve => setTimeout(resolve, this.pollInterval));
            }
        }
    }

    /**
     * Cleanup loop
     */
    private async cleanupLoop() {
        while (!this.stopSignal) {
            try {
                // Delete old deliveries
                // Note: SurrealDB delete query needs to be constructed carefully
                // For now, we'll rely on the repository method if we implement it, 
                // or just skip complex cleanup logic for V1 if repository doesn't support it yet.
                // The Go code calls repo.CleanupOld.

                // We'll implement a basic cleanup query here
                await db.query(
                    `DELETE FROM webhook_deliveries 
                     WHERE status IN ['success', 'failed'] 
                     AND created_at < time::now() - 30d`
                );
                logger.info("Cleaned up old webhook deliveries");
            } catch (error) {
                logger.error("Error in webhook worker cleanup loop", error);
            }

            if (!this.stopSignal) {
                await new Promise(resolve => setTimeout(resolve, this.cleanupInterval));
            }
        }
    }

    /**
     * Process a batch of deliveries
     */
    private async processBatch() {
        // Get pending deliveries
        const deliveries = await webhookDeliveryRepository.getPending(this.batchSize);

        if (deliveries.length === 0) return;

        // Process concurrently
        const promises = deliveries.map(delivery => this.processDelivery(delivery));
        await Promise.all(promises);
    }

    /**
     * Process a single delivery
     */
    private async processDelivery(delivery: WebhookDelivery) {
        try {
            // Get the webhook definition to get the URL and secret
            const [webhook] = await db.select(delivery.webhook_id);

            if (!webhook) {
                await webhookDeliveryRepository.markAsFailed(delivery.id, "Webhook definition not found", 0);
                return;
            }

            const targetUrl = (webhook as any).url;
            const secret = (webhook as any).secret;
            const payloadStr = JSON.stringify(delivery.payload);

            // Prepare headers
            const timestamp = Math.floor(Date.now() / 1000);
            // Note: delivery.id is used as event_id in Go code, but here we might want a separate event_id if available
            // In our service we didn't explicitly store event_id in the delivery table, 
            // so we'll use delivery.id as the event ID for the signature.
            const eventId = delivery.id;
            const eventType = delivery.event_type;

            const signature = this.computeSignature(secret, timestamp, eventId, eventType, payloadStr);

            const headers: Record<string, string> = {
                "Content-Type": "application/json",
                "User-Agent": "Ackify-Webhooks/1.0",
                "X-Ackify-Event": eventType,
                "X-Ackify-Event-Id": eventId,
                "X-Ackify-Timestamp": timestamp.toString(),
                "X-Ackify-Signature": `sha256=${signature}`
            };

            // Send request
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), this.requestTimeout);

            try {
                const response = await fetch(targetUrl, {
                    method: "POST",
                    headers,
                    body: payloadStr,
                    signal: controller.signal
                });

                clearTimeout(timeoutId);

                const responseBody = await response.text();

                if (response.ok) {
                    await webhookDeliveryRepository.markAsSuccess(delivery.id, response.status, responseBody);
                    logger.info(`Webhook delivered successfully: ${delivery.id}`);
                } else {
                    await webhookDeliveryRepository.markAsFailed(
                        delivery.id,
                        `HTTP ${response.status}: ${responseBody.substring(0, 200)}`
                    );
                    logger.warn(`Webhook delivery failed: ${delivery.id} (HTTP ${response.status})`);
                }
            } catch (fetchError: any) {
                clearTimeout(timeoutId);
                await webhookDeliveryRepository.markAsFailed(delivery.id, fetchError.message);
                logger.warn(`Webhook delivery network error: ${delivery.id}`, fetchError);
            }

        } catch (error: any) {
            logger.error(`Critical error processing webhook delivery ${delivery.id}`, error);
            await webhookDeliveryRepository.markAsFailed(delivery.id, error.message);
        }
    }

    /**
     * Compute HMAC SHA-256 signature
     * Format: timestamp.eventID.eventType.body
     */
    private computeSignature(secret: string, timestamp: number, eventId: string, eventType: string, body: string): string {
        const base = `${timestamp}.${eventId}.${eventType}.${body}`;
        return createHmac("sha256", secret)
            .update(base)
            .digest("hex");
    }
}

export const webhookWorker = new WebhookWorker();

import Surreal from "surrealdb.js";
import { logger } from "./pkg/logger";
import { config } from "./config";

export const db = new Surreal();

export async function initDB() {
    try {
        await db.connect(config.database.url);
        await db.use({
            namespace: config.database.namespace,
            database: config.database.database
        });
        await db.signin({
            username: config.database.username,
            password: config.database.password
        });
        logger.info("Connected to SurrealDB");
    } catch (error) {
        logger.error("Failed to connect to SurrealDB", error);
        throw error;
    }
}

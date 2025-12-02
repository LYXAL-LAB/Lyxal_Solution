import { app } from "./app";
import { logger } from "./pkg/logger";
import { config } from "./config";

app.listen(config.server.port);

logger.info(`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`);

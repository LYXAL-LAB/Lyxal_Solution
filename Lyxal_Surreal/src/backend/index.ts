// src/index.ts

// Client & contexte
export * from "./client/surrealClient";
export * from "./client/surrealConfig";
export * from "./client/surrealContext";
export * from "./client/surrealWarmup";

// Context Engine (Multi-Tenant / Marque Blanche)
export * from "./context/contextTypes";
export * from "./context/contextManager";
export * from "./context/contextResolver";
export * from "./context/contextCache";
export * from "./context/domainMapping";
export * from "./context/workspaceMapping";
export * from "./context/saasMapping";

// Query helpers
export * from "./query/query";
export * from "./query/select";
export * from "./query/write";
export * from "./query/transaction";
export * from "./query/health";

// Utils
export * from "./utils/types";
export * from "./utils/errors";
export * from "./utils/logger";
export * from "./utils/retry";

import { Command } from "commander";
import { z } from "zod";

// Schéma de validation de la configuration
export const ServerConfigSchema = z.object({
  endpoint: z.string().optional(),
  namespace: z.string().optional(),
  database: z.string().optional(),
  username: z.string().optional(),
  password: z.string().optional(),
  
  // HTTP & Auth Params
  bindAddress: z.string().optional(),
  serverUrl: z.string().default("https://mcp.surrealdb.com"), // URL publique de ce serveur MCP
  
  authDisabled: z.boolean().default(false),
  
  // OAuth 2.1 Params
  authServer: z.string().default("https://auth.surrealdb.com"), // URL de l'IdP (Issuer base)
  authAudience: z.string().default("https://mcp.surrealdb.com"), // Audience attendue dans le token
  authJwksUri: z.string().default("https://auth.surrealdb.com/.well-known/jwks.json"), // URL des clés publiques

  rateLimitRps: z.number().default(100),
  rateLimitBurst: z.number().default(200),
  
  cloudAccessToken: z.string().optional(),
  cloudRefreshToken: z.string().optional(),
});

export type ServerConfig = z.infer<typeof ServerConfigSchema>;

export function parseConfig(): ServerConfig {
  const program = new Command();

  program
    .name("surreal-mcp")
    .description("MCP Server for SurrealDB")
    .option("--endpoint <url>", "SurrealDB endpoint URL")
    .option("--ns <namespace>", "Namespace to use")
    .option("--db <database>", "Database to use")
    .option("--user <username>", "Username")
    .option("--pass <password>", "Password")
    .option("--server-url <url>", "Server URL for OAuth discovery")
    .option("--bind-address <address>", "Bind address for HTTP server")
    .option("--auth-disabled", "Disable authentication")
    .option("--auth-server <url>", "Auth server URL (Issuer)")
    .option("--auth-audience <url>", "Auth audience")
    .option("--auth-jwks-uri <url>", "JWKS URI")
    .option("--rate-limit-rps <number>", "Rate limit RPS", parseInt)
    .option("--rate-limit-burst <number>", "Rate limit burst", parseInt)
    .option("--cloud-access-token <token>", "Cloud access token")
    .option("--cloud-refresh-token <token>", "Cloud refresh token");

  program.parse();
  const options = program.opts();

  // Validation Zod
  return ServerConfigSchema.parse({
    endpoint: options.endpoint || process.env.SURREAL_ENDPOINT,
    namespace: options.ns || process.env.SURREAL_NS,
    database: options.db || process.env.SURREAL_DB,
    username: options.user || process.env.SURREAL_USER,
    password: options.pass || process.env.SURREAL_PASS,
    
    serverUrl: options.serverUrl || process.env.MCP_SERVER_URL,
    bindAddress: options.bindAddress || process.env.MCP_BIND_ADDRESS,
    authDisabled: options.authDisabled || process.env.MCP_AUTH_DISABLED === "true",
    
    authServer: options.authServer || process.env.MCP_AUTH_SERVER,
    authAudience: options.authAudience || process.env.MCP_AUTH_AUDIENCE,
    authJwksUri: options.authJwksUri || process.env.MCP_AUTH_JWKS_URI,

    rateLimitRps: options.rateLimitRps,
    rateLimitBurst: options.rateLimitBurst,
    cloudAccessToken: options.cloudAccessToken || process.env.SURREAL_CLOUD_TOKEN,
    cloudRefreshToken: options.cloudRefreshToken,
  });
}

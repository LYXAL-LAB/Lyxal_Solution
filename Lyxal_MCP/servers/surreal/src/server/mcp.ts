import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";
import { CloudClient } from "../cloud/client.js";
import { Surreal } from "surrealdb";
import { parseConfig } from "../config.js";
import { DatabaseQueryAssistant, DataModelingExpert, SurrealQlGuide } from "../prompts/templates.js";
import { Resources } from "./resources.js";
import { AuthService } from "./auth.js";
import express from "express";
import { v4 as uuidv4 } from "uuid";

// --- Rate Limiter (Simple Token Bucket) ---
const rateLimits = new Map<string, { tokens: number; lastRefill: number }>();

function checkRateLimit(ip: string, rps: number, burst: number): boolean {
  const now = Date.now();
  let bucket = rateLimits.get(ip);

  if (!bucket) {
    bucket = { tokens: burst, lastRefill: now };
    rateLimits.set(ip, bucket);
  }

  const elapsed = (now - bucket.lastRefill) / 1000;
  bucket.tokens = Math.min(burst, bucket.tokens + elapsed * rps);
  bucket.lastRefill = now;

  if (bucket.tokens >= 1) {
    bucket.tokens -= 1;
    return true;
  }

  return false;
}

// Helper pour convertir Zod schema en JSON Schema pour MCP
function zodToToolInput(schema: z.ZodType<any>): any {
    return zodToJsonSchema(schema);
}

export async function startMcpServer() {
  const config = parseConfig();
  const authService = new AuthService(config);

  const server = new Server(
    {
      name: "lyxal-surreal-mcp",
      version: "1.0.0",
    },
    {
      capabilities: {
        tools: {},
        prompts: {},
        resources: {},
      },
    }
  );

  const cloud = new CloudClient(config.cloudAccessToken);
  const db = new Surreal();

  // --- DEFINITION DES OUTILS ---
  const tools: Record<string, { schema: any; handler: (args: any) => Promise<any> }> = {};

  function registerTool(name: string, description: string, schema: z.ZodType<any>, handler: (args: any) => Promise<any>) {
    tools[name] = {
        schema: zodToToolInput(schema),
        handler
    };
  }

  // --- REGISTER TOOLS (Identique à avant) ---
  
  registerTool("list_cloud_instances", "List Surreal Cloud instances", z.object({ org_id: z.string() }), async ({ org_id }) => {
      const instances = await cloud.listInstances(org_id);
      return { content: [{ type: "text", text: JSON.stringify(instances, null, 2) }] };
  });

  registerTool("create_cloud_instance", "Create a new cloud instance", z.object({ org_id: z.string(), name: z.string() }), async ({ org_id, name }) => {
      const instance = await cloud.createInstance(org_id, name);
      return { content: [{ type: "text", text: `Created instance ${instance.id} (${instance.name})` }] };
  });

    registerTool("get_cloud_instance_status", "Get instance status", z.object({ instance_id: z.string() }), async ({ instance_id }) => {
      const status = await cloud.getInstanceStatus(instance_id);
      return { content: [{ type: "text", text: JSON.stringify(status, null, 2) }] };
    });

    registerTool("pause_cloud_instance", "Pause instance", z.object({ instance_id: z.string() }), async ({ instance_id }) => {
      const instance = await cloud.pauseInstance(instance_id);
      return { content: [{ type: "text", text: `Paused instance ${instance.id}` }] };
    });

    registerTool("resume_cloud_instance", "Resume instance", z.object({ instance_id: z.string() }), async ({ instance_id }) => {
      const instance = await cloud.resumeInstance(instance_id);
      return { content: [{ type: "text", text: `Resumed instance ${instance.id}` }] };
    });

    registerTool("connect_endpoint", "Connect to SurrealDB", z.object({ 
      endpoint: z.string(), 
      namespace: z.string().optional(), 
      database: z.string().optional(), 
      user: z.string().optional(), 
      pass: z.string().optional(),
      token: z.string().optional()
    }), async ({ endpoint, namespace, database, user, pass, token }) => {
      await db.connect(endpoint);
      if (token) await db.authenticate(token);
      else if (user && pass) await db.signin({ username: user, password: pass });
      if (namespace && database) await db.use({ namespace, database });
      return { content: [{ type: "text", text: `Connected to ${endpoint} [${namespace || "?"}/${database || "?"}]` }] };
    });

    registerTool("disconnect_endpoint", "Disconnect", z.object({}), async () => {
        await db.close();
        return { content: [{ type: "text", text: "Disconnected" }] };
    });

    registerTool("use_namespace", "Switch namespace", z.object({ namespace: z.string() }), async ({ namespace }) => {
        await db.use({ namespace });
        return { content: [{ type: "text", text: `Switched to namespace ${namespace}` }] };
    });

    registerTool("use_database", "Switch database", z.object({ database: z.string() }), async ({ database }) => {
        await db.use({ database });
        return { content: [{ type: "text", text: `Switched to database ${database}` }] };
    });

    registerTool("query", "Execute SurrealQL", z.object({ sql: z.string() }), async ({ sql }) => {
        const start = performance.now();
        try {
            const result = await db.query(sql);
            const duration = (performance.now() - start).toFixed(2);
            console.log(`[QUERY] ${duration}ms - ${sql.substring(0, 50)}...`);
            return {
                content: [
                    { type: "text", text: JSON.stringify(result, null, 2) },
                    { type: "text", text: `\n-- Execution time: ${duration}ms` }
                ]
            };
        } catch (err: any) {
            const duration = (performance.now() - start).toFixed(2);
            console.error(`[QUERY ERROR] ${duration}ms - ${err.message}`);
            return { content: [{ type: "text", text: `Error: ${err.message} (in ${duration}ms)` }], isError: true };
        }
    });

    registerTool("select", "Select records", z.object({ table: z.string() }), async ({ table }) => {
        const result = await db.select(table);
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    });

    registerTool("create", "Create record", z.object({ table: z.string(), data: z.record(z.any()) }), async ({ table, data }) => {
        const result = await db.create(table, data);
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    });

    registerTool("insert", "Insert records", z.object({ 
      target: z.string(), 
      values: z.array(z.record(z.any())),
      ignore: z.boolean().optional(),
      relation: z.boolean().optional()
    }), async ({ target, values, ignore, relation }) => {
      if (ignore || relation) {
        let q = "INSERT";
        if (ignore) q += " IGNORE";
        if (relation) q += " RELATION";
        q += ` INTO ${target} $values`;
        const result = await db.query(q, { values });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
      const result = await db.insert(target, values);
      return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    });

    registerTool("upsert", "Upsert record", z.object({ thing: z.string(), data: z.record(z.any()) }), async ({ thing, data }) => {
        const result = await db.upsert(thing, data);
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    });

    registerTool("update", "Update record", z.object({ thing: z.string(), data: z.record(z.any()) }), async ({ thing, data }) => {
        const result = await db.merge(thing, data);
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    });

    registerTool("delete", "Delete record", z.object({ thing: z.string() }), async ({ thing }) => {
        await db.delete(thing);
        return { content: [{ type: "text", text: `Deleted ${thing}` }] };
    });

    registerTool("relate", "Relate records", z.object({ from: z.string(), to: z.string(), kind: z.string(), data: z.record(z.any()).optional() }), async ({ from, to, kind, data }) => {
        const q = `RELATE ${from}->${kind}->${to} ${data ? "CONTENT $data" : ""}`;
        const result = await db.query(q, { data });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    });


  // --- HANDLERS ---

  server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
      tools: Object.entries(tools).map(([name, tool]) => ({
        name,
        description: "Tool description", 
        inputSchema: tool.schema,
      })),
    };
  });

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const tool = tools[request.params.name];
      if (!tool) {
          throw new Error(`Unknown tool: ${request.params.name}`);
      }
      return tool.handler(request.params.arguments);
  });

  server.setRequestHandler(ListPromptsRequestSchema, async () => {
      return {
          prompts: [DatabaseQueryAssistant, DataModelingExpert, SurrealQlGuide].map(p => ({
              name: p.name,
              description: p.description,
              arguments: p.arguments
          }))
      };
  });

  server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const prompt = [DatabaseQueryAssistant, DataModelingExpert, SurrealQlGuide].find(p => p.name === request.params.name);
      if (!prompt) throw new Error("Prompt not found");
      return {
          messages: prompt.messages(request.params.arguments as Record<string, string>)
      };
  });

  server.setRequestHandler(ListResourcesRequestSchema, async () => {
      const resources = await Promise.all(Resources.map(async r => ({
          uri: r.uri,
          name: r.name,
          mimeType: r.mimeType,
          description: r.description
      })));
      return { resources };
  });

  server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const resource = Resources.find(r => r.uri === request.params.uri);
      if (!resource) throw new Error("Resource not found");
      return await resource.read();
  });

  // ===========================================================================
  // SERVER START (HTTP Streamable + STDIO)
  // ===========================================================================

  const port = process.env.PORT || config.bindAddress?.split(":")[1];

  if (port) {
    const app = express();
    
    // Map pour stocker les transports SSE par session
    const sessions = new Map<string, SSEServerTransport>();

    app.use((req, res, next) => {
        const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || "unknown";
        if (!checkRateLimit(String(ip), config.rateLimitRps, config.rateLimitBurst)) {
            res.status(429).send("Too Many Requests");
            return;
        }
        next();
    });

    if (!config.authDisabled) {
        app.use(async (req, res, next) => {
            if (req.path === "/health" || req.path === "/.well-known/oauth-protected-resource") {
                return next();
            }
            const authHeader = req.headers.authorization;
            try {
                await authService.validateToken(authHeader);
                next();
            } catch (err) {
                res.set("WWW-Authenticate", `Bearer realm="mcp", resource_metadata="${config.serverUrl}/.well-known/oauth-protected-resource"`);
                res.status(401).send("Unauthorized");
            }
        });
    }

    app.get("/health", (req, res) => {
        res.status(200).send("OK");
    });

    app.get("/.well-known/oauth-protected-resource", (req, res) => {
        res.json(authService.getDiscoveryConfig());
    });

    // Endpoint SSE (GET /mcp)
    app.get("/mcp", async (req, res) => {
        const transport = new SSEServerTransport("/mcp", res);
        const sessionId = uuidv4();
        
        // On stocke le transport
        sessions.set(sessionId, transport);

        // Header Session ID pour le client
        res.setHeader("Mcp-Session-Id", sessionId);

        console.log(`[SSE] New session: ${sessionId}`);
        
        // Nettoyage quand la connexion se ferme
        res.on("close", () => {
            console.log(`[SSE] Session closed: ${sessionId}`);
            sessions.delete(sessionId);
        });

        await server.connect(transport);
    });

    // Endpoint Messages (POST /mcp)
    // Note: On n'utilise PAS express.json() ici car handlePostMessage lit le stream de la requête directement
    app.post("/mcp", async (req, res) => {
        const sessionId = req.query.sessionId as string; // Client doit envoyer ?sessionId=... ou on peut utiliser un header
        // Note: La spec dit "The client MUST include it in the Mcp-Session-Id header".
        // Mais le SDK SSEServerTransport actuel s'attend souvent à ce que le POST soit sur un endpoint dédié.
        // Pour le Streamable HTTP standard, on utilise le header Mcp-Session-Id.
        
        // Correction: On lit le header ou le query param pour la flexibilité
        const sid = (req.headers["mcp-session-id"] as string) || sessionId;

        if (!sid || !sessions.has(sid)) {
            res.status(404).send("Session not found. Please connect via GET /mcp first.");
            return;
        }

        const transport = sessions.get(sid);
        if (transport) {
            await transport.handlePostMessage(req, res);
        }
    });

    app.listen(port, () => {
        console.log(`Lyxal Surreal MCP Server running on HTTP port ${port} (Streamable HTTP)`);
    });

  } else {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("Lyxal Surreal MCP Server running on stdio");
  }
}

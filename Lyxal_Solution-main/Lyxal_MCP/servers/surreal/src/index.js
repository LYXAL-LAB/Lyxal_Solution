import { startMcpServer } from "./server/mcp.js";
startMcpServer().catch((err) => {
    console.error("Fatal Error:", err);
    process.exit(1);
});

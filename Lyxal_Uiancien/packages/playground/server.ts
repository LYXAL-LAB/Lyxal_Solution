#!/usr/bin/env bun

const SERVER_PORT = 3001;

console.log("🚀 Starting Lyxal UI Playground server...");

// Create Bun server for HTML imports
const httpServer = Bun.serve({
  port: SERVER_PORT,

  async fetch(req) {
    const url = new URL(req.url);

    // Handle API routes (if needed in the future)
    if (url.pathname.startsWith("/api/")) {
      return new Response("API endpoint", { status: 200 });
    }

    // Serve static files from src directory
    if (url.pathname.startsWith("/src/")) {
      try {
        const filePath = "." + url.pathname;
        const file = Bun.file(filePath);

        if (await file.exists()) {
          let contentType = "text/plain";

          if (url.pathname.endsWith(".js")) {
            contentType = "application/javascript";
          } else if (url.pathname.endsWith(".ts")) {
            contentType = "application/javascript"; // Bun transpiles TS to JS
          } else if (url.pathname.endsWith(".tsx")) {
            contentType = "application/javascript"; // Bun transpiles TSX to JS
          } else if (url.pathname.endsWith(".jsx")) {
            contentType = "application/javascript";
          } else if (url.pathname.endsWith(".css")) {
            contentType = "text/css";
          } else if (url.pathname.endsWith(".json")) {
            contentType = "application/json";
          }

          return new Response(file, {
            headers: {
              "Content-Type": contentType,
            },
          });
        }
      } catch (error) {
        console.error("Error serving static file:", error);
      }
    }

    // Serve index.html for all other routes (SPA fallback)
    try {
      const html = await Bun.file("./index.html").text();
      return new Response(html, {
        headers: {
          "Content-Type": "text/html",
        },
      });
    } catch (error) {
      console.error("Error serving HTML:", error);
      return new Response("Not Found", { status: 404 });
    }
  },

  error(error) {
    console.error("Server error:", error);
    return new Response("Internal Server Error", { status: 500 });
  },
});

console.log(`🚀 Lyxal UI Playground running at ${httpServer.url}`);
console.log(`🔥 Hot reloading enabled for all React/TypeScript files`);
console.log(`📦 Fullstack bundling active`);

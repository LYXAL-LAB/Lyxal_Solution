#!/usr/bin/env bun

const port = 3002;

// Serve built files from dist directory
const server = Bun.serve({
  port,
  async fetch(req) {
    const url = new URL(req.url);

    // Handle API routes (if any)
    if (url.pathname.startsWith("/api/")) {
      return new Response("API endpoint", { status: 200 });
    }

    // Serve static files from dist directory
    try {
      // For HTML files
      if (url.pathname === "/" || url.pathname.endsWith(".html")) {
        const filePath = url.pathname === "/" ? "/index.html" : url.pathname;
        const file = Bun.file(`./dist${filePath}`);
        if (await file.exists()) {
          return new Response(file, {
            headers: { "Content-Type": "text/html" },
          });
        }
      }

      // For JS/TSX files (from src)
      if (url.pathname.endsWith(".js") || url.pathname.endsWith(".ts") || url.pathname.endsWith(".jsx") || url.pathname.endsWith(".tsx")) {
        const file = Bun.file(`./dist${url.pathname}`);
        if (await file.exists()) {
          const contentType = url.pathname.endsWith(".ts") || url.pathname.endsWith(".tsx")
            ? "application/typescript"
            : "application/javascript";
          return new Response(file, {
            headers: { "Content-Type": contentType },
          });
        }
      }

      // For CSS files
      if (url.pathname.endsWith(".css")) {
        const file = Bun.file(`./dist${url.pathname}`);
        if (await file.exists()) {
          return new Response(file, {
            headers: { "Content-Type": "text/css" },
          });
        }
      }

      // For other static assets
      const file = Bun.file(`./dist${url.pathname}`);
      if (await file.exists()) {
        return new Response(file);
      }

      // SPA fallback - serve index.html for client-side routing
      const indexFile = Bun.file("./dist/index.html");
      if (await indexFile.exists()) {
        return new Response(indexFile, {
          headers: { "Content-Type": "text/html" },
        });
      }

      return new Response("Not Found", { status: 404 });
    } catch (error) {
      console.error("Server error:", error);
      return new Response("Internal Server Error", { status: 500 });
    }
  },
  error(error) {
    console.error("Server error:", error);
    return new Response("Internal Server Error", { status: 500 });
  },
});

console.log(`🚀 Lyxal UI Playground Preview running at ${server.url}`);
console.log(`📁 Serving built files from: ${process.cwd()}/dist`);

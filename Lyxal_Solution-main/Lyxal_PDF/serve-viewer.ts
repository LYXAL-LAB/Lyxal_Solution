import { serve } from "bun";
import { join } from "node:path";
import { stat } from "node:fs/promises";

const ROOT = join(import.meta.dir, "viewer/build/generic/web");
const PORT = 3000;

console.log(`🚀 Serving Lyxal Viewer at http://localhost:${PORT}/viewer.html`);

serve({
  port: PORT,
  async fetch(req) {
    const url = new URL(req.url);
    let path = url.pathname;
    
    // Default to viewer.html
    if (path === "/" || path === "/viewer") path = "/viewer.html";
    
    // Handle build/ mapping because viewer.html expects ../build/pdf.mjs
    // The structure is:
    // generic/
    //   build/
    //   web/  <-- We are serving this as root
    // But viewer.html does <script src="../build/pdf.mjs">
    
    // So we need to serve 'generic' as root actually.
    
    // Let's serve from "viewer/build/generic"
    const GENERIC_ROOT = join(import.meta.dir, "viewer/build/generic");
    const filePath = join(GENERIC_ROOT, path);

    try {
      const fileStat = await stat(filePath);
      if (fileStat.isFile()) {
        const file = Bun.file(filePath);
        const headers = new Headers();
        
        // Set content types (crucial for .mjs)
        if (path.endsWith(".html")) headers.set("Content-Type", "text/html");
        if (path.endsWith(".js") || path.endsWith(".mjs")) headers.set("Content-Type", "application/javascript");
        if (path.endsWith(".css")) headers.set("Content-Type", "text/css");
        if (path.endsWith(".wasm")) headers.set("Content-Type", "application/wasm");
        
        return new Response(file, { headers });
      }
    } catch (e) {
      // 404
    }

    return new Response("404 Not Found: " + path, { status: 404 });
  },
});


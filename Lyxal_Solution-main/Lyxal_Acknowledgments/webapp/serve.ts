import { serve } from "bun";

const server = serve({
    port: 3000,
    async fetch(req) {
        const url = new URL(req.url);

        // API Proxy
        if (url.pathname.startsWith("/api")) {
            const backendUrl = new URL(url.pathname + url.search, "http://localhost:8080");
            try {
                const response = await fetch(backendUrl, {
                    method: req.method,
                    headers: req.headers,
                    body: req.body
                });
                return response;
            } catch (e) {
                return new Response("Backend unavailable", { status: 502 });
            }
        }

        // Build on the fly for dev
        if (url.pathname === "/index.js" || url.pathname.endsWith(".tsx") || url.pathname.endsWith(".ts")) {
            const result = await Bun.build({
                entrypoints: ["./src/index.tsx"],
                minify: false,
                sourcemap: "inline",
            });

            if (result.success) {
                return new Response(result.outputs[0]);
            } else {
                return new Response("Build failed: " + result.logs.join("\n"), { status: 500 });
            }
        }

        // Serve static files
        let filePath = `./src${url.pathname}`;

        // CSS handling
        if (url.pathname.startsWith("/styles/")) {
            filePath = `./src${url.pathname}`;
        }

        const file = Bun.file(filePath);
        if (await file.exists()) {
            return new Response(file);
        }

        // Fallback to index.html for SPA
        return new Response(Bun.file("./src/index.html"));
    },
});

console.log(`Listening on http://localhost:${server.port}`);

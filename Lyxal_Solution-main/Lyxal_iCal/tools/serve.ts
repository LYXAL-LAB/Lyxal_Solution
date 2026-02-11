const port = 8080;

console.log(`Server listening on http://localhost:${port}`);
console.log(`\nTools available at:`);
console.log(`- Validator:    http://localhost:${port}/tools/validator.html`);
console.log(`- Recur Tester: http://localhost:${port}/tools/recur-tester.html`);

Bun.serve({
    port: port,
    async fetch(req) {
        const url = new URL(req.url);
        let path = url.pathname;
        if (path === "/") path = "/index.html";

        // Serve files from the project root
        const filePath = "." + path;
        const file = Bun.file(filePath);

        if (await file.exists()) {
            return new Response(file);
        }

        return new Response("Not Found", { status: 404 });
    },
});

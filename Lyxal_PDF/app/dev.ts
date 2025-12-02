import { serve } from "bun";
import { join } from "node:path";

const ROOT = import.meta.dir;
const PROJECT_ROOT = join(ROOT, ".."); // Lyxal_PDF root

console.log(`🚀 Starting Lyxal App Dev Server at http://localhost:3004`);
console.log(`DEBUG: ROOT=${ROOT}`);
console.log(`DEBUG: PROJECT_ROOT=${PROJECT_ROOT}`);

serve({
  port: 3004,
  async fetch(req) {
    const url = new URL(req.url);
    let path = url.pathname;

    // 1. React App Bundle (On-the-fly build)
    if (path === "/app.js") {
        console.log("Rebuilding app.js...");
        try {
            const result = await Bun.build({
                entrypoints: [join(ROOT, "src/index.tsx")],
                target: "browser",
                external: ["/renderer/*", "*pdf.mjs"],
            });
            
            console.log("Build success:", result.success);
            if (!result.success) {
                console.error(result.logs);
                return new Response("Build Failed", { status: 500 });
            }
            
            return new Response(result.outputs[0]);
        } catch (e) {
            console.error("Build Exception:", e);
            return new Response("Build Exception", { status: 500 });
        }
    }
    
    // 2. Renderer Static Files (Proxy to renderer build)
    if (path.startsWith("/renderer/")) {
        const subPath = path.replace("/renderer/", "");
        const filePath = join(PROJECT_ROOT, "renderer/build/generic", subPath);
        
        // console.log(`DEBUG: ${path} -> ${filePath}`);

        const file = Bun.file(filePath);
        if (await file.exists()) {
             const headers = new Headers();
             if (path.endsWith(".mjs") || path.endsWith(".js")) headers.set("Content-Type", "application/javascript");
             if (path.endsWith(".css")) headers.set("Content-Type", "text/css");
             return new Response(file, { headers });
        } else {
            // console.log(`DEBUG: File NOT found`);
        }
    }

    // 3. Index HTML
    if (path === "/" || path === "/index.html") {
        let index = await Bun.file(join(ROOT, "index.html")).text();
        index = index.replace('src="./src/index.tsx"', 'src="/app.js"');
        return new Response(index, { headers: { "Content-Type": "text/html" } });
    }

    // 4. Local Static Files (Fallback)
    // Tente de servir le fichier depuis la racine de 'app' (ex: style.css)
    const localFile = Bun.file(join(ROOT, path.startsWith("/") ? path.slice(1) : path));
    if (await localFile.exists()) {
        return new Response(localFile);
    }
    
    console.log(`DEBUG: 404 for ${path}`);
    return new Response("Not Found: " + path, { status: 404 });
  },
});

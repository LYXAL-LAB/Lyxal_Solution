import type { BuildConfig } from "bun";

const config: BuildConfig = {
    entrypoints: ["./src/index.tsx"],
    outdir: "./dist",
    minify: true,
    sourcemap: "external",
    plugins: [],
};

await Bun.build(config);

// Copy index.html
const indexHtml = await Bun.file("./src/index.html").text();
await Bun.write("./dist/index.html", indexHtml);

console.log("Build complete!");

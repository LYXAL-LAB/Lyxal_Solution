#!/usr/bin/env bun

async function build() {
  try {
    console.log("🏗️ Building Lyxal UI Playground...");

    // Create dist directory using Bun APIs
    try {
      await Bun.write("dist/.gitkeep", "");
    } catch {
      // Directory exists
    }

    // Copy index.html using Bun.file
    const indexContent = await Bun.file("index.html").text();
    await Bun.write("dist/index.html", indexContent);
    console.log("📄 Copied index.html");

    // For a simple copy, we'll just copy the essential files
    // The preview server will handle the bundling
    console.log("📂 Files prepared for dist/");

    console.log("✅ Build completed successfully!");
    console.log("📦 Files ready in dist/ directory");
    console.log("💡 Use 'bun run preview' to test the build");
  } catch (error) {
    console.error("❌ Build failed:", error);
    process.exit(1);
  }
}

build();

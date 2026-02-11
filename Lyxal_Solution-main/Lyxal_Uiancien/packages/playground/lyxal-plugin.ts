#!/usr/bin/env bun
import type { BunPlugin } from "bun";

const lyxalPlugin: BunPlugin = {
  name: "lyxal-ui-plugin",

  setup(build) {
    console.log("🚀 Lyxal UI Plugin loaded and active!");
    // Intercepter tous les imports Lyxal UI pour debug
    build.onResolve({ filter: /lyxalui/ }, (args) => {
      console.log("🎯 Resolving Lyxal UI import:", args.path, "from", args.importer);
      return null; // Laisser Bun gérer la résolution normale
    });

    // Intercepter les imports du plugin Lyxal UI principal
    build.onLoad({ filter: /lyxalui$/ }, async (args) => {
      console.log("🔧 Loading Lyxal UI main plugin from:", args.path);

      try {
        // Charger le vrai fichier lyxalui/index.ts
        const realPluginPath = "../../lyxalui/index.ts";
        const pluginContent = await Bun.file(realPluginPath).text();

        console.log("✅ Lyxal UI plugin loaded successfully");

        return {
          contents: pluginContent,
          loader: "ts",
        };
      } catch (error) {
        console.error("❌ Failed to load Lyxal UI plugin:", error);
        return {
          contents: `console.error("Failed to load Lyxal UI:", ${JSON.stringify((error as Error).message)});`,
          loader: "js",
        };
      }
    });

    // Intercepter les imports du thème plugin
    build.onLoad({ filter: /lyxalui\/theme$/ }, async (_args) => {
      console.log("🎨 Loading Lyxal UI theme plugin...");

      try {
        const themePluginPath = "../../lyxalui/theme/index.ts";
        const themeContent = await Bun.file(themePluginPath).text();

        console.log("✅ Lyxal UI theme plugin loaded successfully");

        return {
          contents: themeContent,
          loader: "ts",
        };
      } catch (error) {
        console.error("❌ Failed to load Lyxal UI theme plugin:", error);
        return {
          contents: `console.error("Failed to load Lyxal UI theme:", ${JSON.stringify((error as Error).message)});`,
          loader: "js",
        };
      }
    });

    // Intercepter les fichiers CSS de thème individuels
    build.onLoad({ filter: /lyxalui\/src\/themes\/.*\.css$/ }, async (args) => {
      const themeName = args.path.split('/').pop()?.replace('.css', '') || 'unknown';
      console.log(`🎨 Loading theme: ${themeName}`);

      try {
        // Charger le vrai fichier CSS de thème
        const cssContent = await Bun.file(args.path).text();

        console.log(`✅ Theme ${themeName} loaded successfully`);

        return {
          contents: cssContent,
          loader: "css",
        };
      } catch (error) {
        console.error(`❌ Failed to load theme ${themeName}:`, error);
        // Fallback basique
        return {
          contents: `/* Theme ${themeName} - Fallback */
:root[data-theme="${themeName}"] {
  --color-primary: #3b82f6;
  --color-secondary: #8b5cf6;
}`,
          loader: "css",
        };
      }
    });

    // Intercepter les autres fichiers Lyxal UI
    build.onLoad({ filter: /lyxalui\/src\// }, async (args) => {
      console.log("📁 Loading Lyxal UI file:", args.path);

      try {
        const fileContent = await Bun.file(args.path).text();
        const ext = args.path.split('.').pop();

        let loader: "ts" | "js" | "css" | "json" = "js";
        if (ext === "ts") loader = "ts";
        else if (ext === "tsx") loader = "ts";
        else if (ext === "css") loader = "css";
        else if (ext === "json") loader = "json";

        return {
          contents: fileContent,
          loader,
        };
      } catch (error) {
        console.error("❌ Failed to load Lyxal UI file:", error);
        return {
          contents: `console.error("Failed to load:", ${JSON.stringify(args.path)});`,
          loader: "js",
        };
      }
    });
  },
};

console.log("📦 Lyxal UI Plugin module loaded");

export default lyxalPlugin;

#!/usr/bin/env bun

import { serve } from "bun";
import homepage from "../index.html";

const server = serve({
  routes: {
    // HTML imports - Bun automatically bundles React/TypeScript
    "/": homepage,
  },

  // Enable development mode for hot reloading
  development: true,

  async fetch(req) {
    // Handle API routes (if needed in the future)
    const url = new URL(req.url);

    if (url.pathname.startsWith("/api/")) {
      return new Response("API endpoint", { status: 200 });
    }

    // All other routes are handled by the HTML bundler
    return new Response("Not Found", { status: 404 });
  },

  error(error) {
    console.error("Server error:", error);
    return new Response("Internal Server Error", { status: 500 });
  },
});

console.log(`🚀 Lyxal UI Playground running at ${server.url}`);
console.log(`🔥 Hot reloading enabled for all React/TypeScript files`);
console.log(`📦 Fullstack bundling active`);

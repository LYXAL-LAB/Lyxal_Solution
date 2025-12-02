// Types TypeScript pour Bun.build
interface BunBuildOptions {
  entrypoints: string[];
  outdir: string;
  naming: string;
  format: 'esm' | 'cjs';
  banner: string;
  footer: string;
}

interface BunBuild {
  (options: BunBuildOptions): Promise<void>;
}

declare const Bun: {
  build: BunBuild;
};

// Import des dépendances
import { updateVersion } from "./updateVersion.ts";

// Constantes
const BANNER: string = "/** 🌼\n *  @license PROPRIETARY\n *  Lyxal UI Bundle\n *  https://lyxal_solution.com\n *\n *  PROPRIETARY LICENSE - Lyxal UI System\n *\n *  Copyright (c) 2025 Lyxal Solution – https://lyxal_solution.com\n *\n *  This software and associated documentation files (the \"Software\") are the\n *  exclusive property of Lyxal Solution. All rights, title, and interest in and\n *  to the Software, including all intellectual property rights therein, are\n *  owned by Lyxal Solution.\n *\n *  RESTRICTIONS:\n *  - The Software may not be used, copied, modified, merged, published,\n *    distributed, sublicensed, or sold without express written permission\n *    from Lyxal Solution.\n *  - Any use of the Software requires a valid commercial license agreement\n *    with Lyxal Solution.\n *  - Reverse engineering, decompilation, or disassembly of the Software is\n *    strictly prohibited.\n *\n *  THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL\n *  LYXAL SOLUTION BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,\n *  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF\n *  OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n *  SOFTWARE.\n *\n *  For licensing inquiries: contact@lyxal_solution.com\n */\n";

const FOOTER: string =
  '\n/*\n\n  PROPRIETARY LICENSE - Lyxal UI System\n\n  Copyright (c) 2025 Lyxal Solution – https://lyxal_solution.com\n\n  This software and associated documentation files (the "Software") are the\n  exclusive property of Lyxal Solution. All rights, title, and interest in and\n  to the Software, including all intellectual property rights therein, are\n  owned by Lyxal Solution.\n\n  RESTRICTIONS:\n  - The Software may not be used, copied, modified, merged, published,\n    distributed, sublicensed, or sold without express written permission\n    from Lyxal Solution.\n  - Any use of the Software requires a valid commercial license agreement\n    with Lyxal Solution.\n  - Reverse engineering, decompilation, or disassembly of the Software is\n    strictly prohibited.\n\n  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL\n  LYXAL SOLUTION BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,\n  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF\n  OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n  SOFTWARE.\n\n  For licensing inquiries: contact@lyxal_solution.com\n\n*/';

// Build des bundles
await Promise.all([
  updateVersion(),
  Bun.build({
    entrypoints: ["packages/lyxalui/index.ts"],
    outdir: "packages/bundle",
    naming: "lyxalui.mjs",
    format: "esm",
    banner: BANNER,
    footer: FOOTER,
  }),
  Bun.build({
    entrypoints: ["packages/lyxalui/theme/index.ts"],
    outdir: "packages/bundle",
    naming: "lyxalui-theme.mjs",
    format: "esm",
    banner: BANNER,
    footer: FOOTER,
  }),
  Bun.build({
    entrypoints: ["packages/lyxalui/index.ts"],
    outdir: "packages/bundle",
    naming: "lyxalui.js",
    format: "cjs",
    banner: BANNER,
    footer: FOOTER,
  }),
  Bun.build({
    entrypoints: ["packages/lyxalui/theme/index.ts"],
    outdir: "packages/bundle",
    naming: "lyxalui-theme.js",
    format: "cjs",
    banner: BANNER,
    footer: FOOTER,
  }),
]);

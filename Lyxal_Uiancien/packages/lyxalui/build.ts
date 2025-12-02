import { generateThemesObject } from "./functions/generateThemesObject.ts"
import { generateThemeFiles } from "./functions/generateThemeFiles.ts"
import { generateColorRules } from "./functions/generateColorRules.ts"
import { generateRawStyles } from "./functions/generateRawStyles.ts"
import { minify, minifyCssInDirectory } from "./functions/minify.ts"
import { generatePlugins } from "./functions/generatePlugins.ts"
import { generateImports } from "./functions/generateImports.ts"
import { extractClasses } from "./functions/extractClasses.ts"
import { generateThemes } from "./functions/generateThemes.ts"
import { generateChunks } from "./functions/generateChunks.ts"
import { removeFiles } from "./functions/removeFiles.ts"
import { copyFile } from "./functions/copyFile.ts"
import { packCss } from "./functions/packCss.ts"
import { report } from "./functions/report.ts"
import { version } from "./package.json"

const isDev = process.argv.includes("--dev")

async function generateFiles() {
  await Promise.all([
    copyFile("./functions/themePlugin.ts", "./theme/themePlugin.ts", "index.ts"),

    !isDev &&
      generateColorRules({
        distDir: "../colors",
        properties: ["bg", "text", "border"],
        breakpoints: ["sm", "md", "lg", "xl", "2xl"],
        states: ["hover"],
        opacities: {
          properties: [10, 20, 30, 40, 50, 60, 70, 80, 90],
          responsive: [],
          states: [],
        },
        outputFiles: {
          properties: "properties.css",
          responsive: "responsive.css",
          states: "states.css",
        },
      }),

    !isDev &&
      generateColorRules({
        distDir: "../colors",
        properties: ["bg", "text", "border"],
        breakpoints: [],
        states: ["focus", "active"],
        outputFiles: {
          properties: null,
          responsive: null,
          states: "states-extended.css",
        },
      }),

    !isDev &&
      generateColorRules({
        distDir: "../colors",
        properties: ["bg", "text", "border"],
        breakpoints: ["max-sm", "max-md", "max-lg", "max-xl", "max-2xl"],
        states: [],
        outputFiles: {
          properties: null,
          responsive: "responsive-extended.css",
          states: null,
        },
      }),

    !isDev &&
      generateColorRules({
        distDir: "../colors",
        properties: [
          "from",
          "via",
          "to",
          "ring",
          // "ring-offset",
          "fill",
          "stroke",
          // "caret",
          // "divide",
          // "accent",
          "shadow",
          "outline",
          // "decoration",
          // "placeholder",
        ],
        breakpoints: [],
        states: [],
        outputFiles: {
          properties: "properties-extended.css",
          responsive: null,
          states: null,
        },
      }),

    !isDev && generateThemeFiles({ srcDir: "src/themes", distDir: "theme" }),

    !isDev && generateRawStyles({ srcDir: "../src/base", distDir: "../base", layer: "base" }),

    !isDev &&
      generateRawStyles({
        srcDir: "../src/components",
        distDir: "../components",
        responsive: true,
        exclude: [
          "calendar",
          "countdown",
          "loading",
          "filter",
          "mask",
          "mockup",
          "skeleton",
          "swap",
          "validator",
          "hover3d",
          "textrotate",
        ],
        layer: "utilities",
      }),

    !isDev &&
      generateRawStyles({
        srcDir: "../src/utilities",
        distDir: "../utilities",
        responsive: true,
        exclude: ["typography", "glass"],
        layer: "utilities",
      }),
    generatePlugins({ type: "base", srcDir: "src/themes", distDir: "theme" }),
    generatePlugins({ type: "base", srcDir: "src/base", distDir: "base", exclude: ["reset"] }),
    generatePlugins({ type: "component", srcDir: "src/components", distDir: "components" }),
    generatePlugins({ type: "utility", srcDir: "src/utilities", distDir: "utilities" }),
  ])
  await Promise.all([
    generateImports("imports.ts"),

    !isDev && generateChunks("chunks.css"),

    !isDev &&
      packCss({
        outputFile: "lyxalui.css",
        exclude: {
          colors: ["properties-extended", "responsive-extended", "states-extended"],
          components: [],
          utilities: [],
        },
      }),

    !isDev && generateThemes("themes.css"),
    generateThemesObject("./theme/object.ts"),
  ])
  await Promise.all([
    extractClasses({ srcDir: "components" }),
    !isDev && minifyCssInDirectory(["colors", "base", "components", "utilities"]),
    !isDev && minify("themes.css"),
    !isDev && minify("lyxalui.css"),
  ])
}

async function build() {
  try {
    // eslint-disable-next-line no-unused-expressions
    !isDev &&
      (await removeFiles([
        "base",
        "colors",
        "components",
        "theme",
        "utilities",
        "chunks.css",
        "lyxalui.css",
        "imports.ts",
        "themes.css",
      ]))
    console.time(`${decodeURIComponent("%F0%9F%8C%BC")} ${atob("THl4YWwgVUk=")} ${version}`)
    await generateFiles()
    console.timeEnd(`${decodeURIComponent("%F0%9F%8C%BC")} ${atob("THl4YWwgVUk=")} ${version}`)
    // eslint-disable-next-line no-unused-expressions
    !isDev &&
      (await report([
        "base",
        "components",
        "utilities",
        "colors",
        "chunks.css",
        "themes.css",
        "lyxalui.css",
      ]))
  } catch (error) {
    throw new Error("Build error: " + (error instanceof Error ? error.message : String(error)))
  }
}

build(/* 🌼 */)

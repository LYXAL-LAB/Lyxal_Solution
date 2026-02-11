// Types TypeScript
interface Opacities {
  properties: number[];
  responsive: number[];
  states: number[];
}

interface OutputFiles {
  properties: string | null;
  responsive: string | null;
  states: string | null;
}

interface GenerateColorRulesOptions {
  distDir: string;
  properties: string[];
  breakpoints: string[];
  states: string[];
  opacities?: Opacities;
  outputFiles?: OutputFiles;
}

interface StylePropertyMap {
  [key: string]: string;
}

interface BreakpointWidths {
  sm: string;
  md: string;
  lg: string;
  xl: string;
  "2xl": string;
}

// Import des dépendances
import { compile } from "tailwindcss";
import fs from "fs/promises";
import path from "path";

// Fonction principale pour générer les règles de couleur
export const generateColorRules = async ({
  distDir,
  properties,
  breakpoints,
  states,
  opacities = {
    properties: [],
    responsive: [],
    states: [],
  },
  outputFiles = {
    properties: null,
    responsive: null,
    states: null,
  },
}: GenerateColorRulesOptions): Promise<void> => {
  try {
    const [defaultTheme, theme] = await Promise.all([
      fs.readFile(
        path.join(import.meta.dirname!, "../../../node_modules/tailwindcss/theme.css"),
        "utf-8",
      ),
      fs.readFile(path.join(import.meta.dirname!, "./variables.css"), "utf-8"),
    ]);

    const colorNames: string[] = [
      "base-100",
      "base-200",
      "base-300",
      "base-content",
      "primary",
      "primary-content",
      "secondary",
      "secondary-content",
      "accent",
      "accent-content",
      "neutral",
      "neutral-content",
      "info",
      "info-content",
      "success",
      "success-content",
      "warning",
      "warning-content",
      "error",
      "error-content",
    ];

    const getStyleProperty = (style: string): string => {
      const stylePropertyMap: StylePropertyMap = {
        bg: "background-color",
        text: "color",
        border: "border-color",
        fill: "fill",
        stroke: "stroke",
        outline: "outline-color",
        accent: "accent-color",
        caret: "caret-color",
        ring: "--tw-ring-color",
        "ring-offset": "--tw-ring-offset-color",
        shadow: "--tw-shadow-color",
        decoration: "text-decoration-color",
        divide: "border-color",
        placeholder: "--tw-placeholder-color",
      };
      return stylePropertyMap[style] || "color";
    };

    const generateBaseVariants = (style: string, color: string): string => {
      return `.${style}-${color}{@apply ${style}-${color};}`;
    };

    const generateOpacityVariants = (style: string, color: string, opacityList: number[]): string[] => {
      return opacityList.map(
        (opacity: number): string =>
          `.${style}-${color}\\/${opacity}{${getStyleProperty(style)}:color-mix(in oklab,var(--color-${color})${opacity}%,#0000);}`,
      );
    };

    const generateResponsiveVariants = (style: string, color: string, includeOpacities: number[] = []): string[] => {
      const baseVariants: string[] = breakpoints.map((bp: string): string =>
        bp.match(/^\d/)
          ? `.\\3${bp[0]}${bp.slice(1)}\\:${style}-${color}{@apply ${bp}:${style}-${color};}`
          : `.${bp}\\:${style}-${color}{@apply ${bp}:${style}-${color};}`,
      );

      const opacityVariants: string[] = includeOpacities.length
        ? breakpoints.flatMap((bp: string): string[] =>
            includeOpacities.map((opacity: number): string => {
              const prefix: string = bp.match(/^\d/) ? `\\3${bp[0]}${bp.slice(1)}` : bp;
              return `.${prefix}\\:${style}-${color}\\/${opacity}{@apply ${bp}:${style}-${color}\\/${opacity};}`;
            }),
          )
        : [];

      return [...baseVariants, ...opacityVariants];
    };

    const generateStateVariants = (style: string, color: string, includeOpacities: number[] = []): string[] => {
      const baseVariants: string[] = states.map(
        (state: string): string => `.${state}\\:${style}-${color}:${state}{@apply ${state}:${style}-${color};}`,
      );

      const opacityVariants: string[] = includeOpacities.length
        ? states.flatMap((state: string): string[] =>
            includeOpacities.map(
              (opacity: number): string =>
                `.${state}\\:${style}-${color}\\/${opacity}:${state}{@apply ${state}:${style}-${color}\\/${opacity};}`,
            ),
          )
        : [];

      return [...baseVariants, ...opacityVariants];
    };

    const generatePropertiesContent = (): string => {
      return colorNames
        .flatMap((color: string): string[] =>
          properties.flatMap((style: string): string[] => [
            generateBaseVariants(style, color),
            ...generateOpacityVariants(style, color, opacities.properties || []),
          ]),
        )
        .join("\n");
    };

    const generateResponsiveContent = (groupBreakpoints: boolean = true): string => {
      if (groupBreakpoints) {
        return breakpoints
          .map((bp: string): string => {
            const prefix: string = bp.match(/^\d/) ? `\\3${bp[0]}${bp.slice(1)}` : bp;
            const classes: string = colorNames
              .flatMap((color: string): string[] =>
                properties.flatMap((style: string): string[] => {
                  const baseClass: string = `.${prefix}\\:${style}-${color}{@apply ${style}-${color};}`;
                  const opacityClasses: string[] = (opacities.responsive || []).map(
                    (opacity: number): string =>
                      `.${prefix}\\:${style}-${color}\\/${opacity}{@apply ${style}-${color}\\/${opacity};}`,
                  );
                  return [baseClass, ...opacityClasses];
                }),
              )
              .join("\n");
            return `@media ${getBreakpointWidth(bp)} {\n${classes}\n}`;
          })
          .join("\n\n");
      }
      return colorNames
        .flatMap((color: string): string[] =>
          properties.flatMap((style: string): string[] =>
            generateResponsiveVariants(style, color, opacities.responsive || []),
          ),
        )
        .join("\n");
    };

    const getBreakpointWidth = (breakpoint: string): string => {
      const widths: BreakpointWidths = {
        sm: "40rem",
        md: "48rem",
        lg: "64rem",
        xl: "80rem",
        "2xl": "96rem",
      };
      if (breakpoint.startsWith("max-")) {
        return `(width < ${widths[breakpoint.slice(4) as keyof BreakpointWidths] || "40rem"})`;
      }
      return `(width >= ${widths[breakpoint as keyof BreakpointWidths] || "40rem"})`;
    };

    const generateStatesContent = (): string => {
      return colorNames
        .flatMap((color: string): string[] =>
          properties.flatMap((style: string): string[] =>
            generateStateVariants(style, color, opacities.states || []),
          ),
        )
        .join("\n");
    };

    const compileAndWriteFile = async (content: string, fileName: string): Promise<void> => {
      const compiledContent: string = (
        await compile(`
        @layer base{${defaultTheme}${theme}}
        @layer wrapperStart{
          ${content}
        }
        @layer wrapperEnd
      `)
      ).build([]);

      const startIndex: number = compiledContent.indexOf("@layer wrapperStart");
      const endIndex: number = compiledContent.indexOf("@layer wrapperEnd");

      if (startIndex === -1 || endIndex === -1) {
        throw new Error("Failed to find wrapper layers in compiled content");
      }

      const openingBraceIndex: number = compiledContent.indexOf("{", startIndex);
      const closingBraceIndex: number = compiledContent.lastIndexOf("}", endIndex);

      if (
        openingBraceIndex === -1 ||
        closingBraceIndex === -1 ||
        openingBraceIndex >= closingBraceIndex
      ) {
        throw new Error("Invalid wrapper layer structure in compiled content");
      }

      let extractedContent: string = compiledContent.slice(openingBraceIndex + 1, closingBraceIndex).trim();

      // For responsive.css, we need to preserve the media queries
      if (fileName === outputFiles.responsive) {
        extractedContent = extractedContent.replace(/&/g, "");
      }

      const colorsDir: string = path.join(import.meta.dirname!, distDir);
      await fs.mkdir(colorsDir, { recursive: true });
      await fs.writeFile(path.join(colorsDir, fileName), extractedContent);
    };

    await Promise.all(
      [
        outputFiles.properties &&
          compileAndWriteFile(generatePropertiesContent(), outputFiles.properties),
        outputFiles.responsive &&
          compileAndWriteFile(generateResponsiveContent(), outputFiles.responsive),
        outputFiles.states && compileAndWriteFile(generateStatesContent(), outputFiles.states),
      ].filter(Boolean),
    );
  } catch (error: any) {
    throw new Error(error);
  }
};

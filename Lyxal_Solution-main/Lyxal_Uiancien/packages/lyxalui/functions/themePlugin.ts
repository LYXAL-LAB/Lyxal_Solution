// Types TypeScript
interface ThemePluginOptions {
  name?: string;
  default?: boolean;
  prefersdark?: boolean;
  "color-scheme"?: string;
  root?: string;
  [key: string]: any;
}

interface ThemeObject {
  [key: string]: string;
}

interface ThemeData {
  ":root": ThemeObject;
}

interface ThemesObject {
  [themeName: string]: ThemeData;
}

interface AddBaseFunction {
  (styles: { [selector: string]: any }): void;
}

interface PluginFunction {
  (options?: ThemePluginOptions): { handler: any; config: any };
}

// Import des dépendances
import { plugin } from "./plugin.ts";
const allThemes: ThemesObject = require("./object.ts");

const themePlugin: PluginFunction = plugin.withOptions((options: ThemePluginOptions = {}) => {
  return ({ addBase }: { addBase: AddBaseFunction }) => {
    const {
      name = "custom-theme",
      default: isDefault = false,
      prefersdark = false,
      "color-scheme": colorScheme = "normal",
      root = ":root",
      ...customThemeTokens
    } = options;

    let selector: string = `${root}:has(input.theme-controller[value=${name}]:checked),[data-theme="${name}"]`;
    if (isDefault) {
      selector = `:where(${root}),${selector}`;
    }

    // Merge custom theme with built-in theme if it exists
    let themeTokens: any = { ...customThemeTokens };
    if (allThemes[name]) {
      const builtinTheme: ThemeData = allThemes[name];
      const themeRoot: ThemeObject = builtinTheme[":root"];
      themeTokens = {
        ...themeRoot,
        ...customThemeTokens,
        "color-scheme": colorScheme || themeRoot["color-scheme"],
      };
    }

    const baseStyles: { [key: string]: any } = {
      [selector]: {
        "color-scheme": themeTokens["color-scheme"] || colorScheme,
        ...themeTokens,
      },
    };

    if (prefersdark) {
      // Use :root:not([data-theme]) for dark mode specificity
      const darkSelector: string =
        root === ":root" ? ":root:not([data-theme])" : `${root}:not([data-theme])`;
      addBase({
        "@media (prefers-color-scheme: dark)": {
          [darkSelector]: baseStyles[selector],
        },
      });
    }

    addBase(baseStyles);
  };
});

export default themePlugin;

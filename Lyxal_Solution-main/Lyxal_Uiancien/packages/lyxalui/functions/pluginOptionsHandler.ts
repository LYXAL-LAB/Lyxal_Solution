// Types TypeScript
interface PluginOptions {
  logs?: boolean;
  root?: string;
  themes?: string[] | string;
  include?: string[];
  exclude?: string[];
  prefix?: string;
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
  (styles: { [selector: string]: ThemeObject | { [selector: string]: ThemeObject } }): void;
}

// Import des dépendances
import themeOrder from "./themeOrder.ts";

export const pluginOptionsHandler = (() => {
  let firstRun: boolean = true;
  return (
    options: PluginOptions | undefined,
    addBase: AddBaseFunction,
    themesObject: ThemesObject,
    packageVersion: string,
  ) => {
    const {
      logs = true,
      root = ":root",
      themes = ["light --default", "dark --prefersdark"],
      include,
      exclude,
      prefix = "",
    } = options || {};

    if (logs !== false && firstRun) {
      console.log(
        `${atob("Lyoh")} ${decodeURIComponent("%F0%9F%8C%BC")} ${atob("ZGFpc3lVSQ==")} ${packageVersion} ${atob("Ki8=")}`,
      );
      firstRun = false;
    }

    const applyTheme = (themeName: string, flags: string[]): void => {
      const theme: ThemeData | undefined = themesObject[themeName];
      if (theme) {
        // Use prefix for theme-controller class name
        const themeControllerClass: string = `${prefix}theme-controller`;
        let selector: string = `${root}:has(input.${themeControllerClass}[value=${themeName}]:checked),[data-theme=${themeName}]`;
        if (flags.includes("--default")) {
          selector = `:where(${root}),${selector}`;
        }
        addBase({ [selector]: theme[":root"] });

        if (flags.includes("--prefersdark")) {
          // Use :root:not([data-theme]) for dark mode specificity
          const darkSelector: string =
            root === ":root" ? ":root:not([data-theme])" : `${root}:not([data-theme])`;
          const darkThemeStyles: { [selector: string]: ThemeObject } = {};
          darkThemeStyles[darkSelector] = theme[":root"];
          addBase({ "@media (prefers-color-scheme: dark)": darkThemeStyles });
        }
      }
    };

    if (themes === "all") {
      if (themesObject["light"]) {
        applyTheme("light", ["--default"]);
      }

      if (themesObject["dark"]) {
        const darkSelector: string =
          root === ":root" ? ":root:not([data-theme])" : `${root}:not([data-theme])`;
        const darkThemeStyles: { [selector: string]: ThemeObject } = {};
        darkThemeStyles[darkSelector] = themesObject["dark"][":root"];
        addBase({ "@media (prefers-color-scheme: dark)": darkThemeStyles });
      }

      themeOrder.forEach((themeName: string) => {
        if (themesObject[themeName]) {
          applyTheme(themeName, []);
        }
      });
    } else if (themes) {
      const themeArray: string[] = Array.isArray(themes) ? themes : [themes];

      // For single theme with --default flag, skip the other applications
      if (themeArray.length === 1 && themeArray[0] && themeArray[0].includes("--default")) {
        const [themeName, ...flags] = themeArray[0].split(" ");
        if (themeName) {
          applyTheme(themeName, flags);
          return { include, exclude, prefix };
        }
      }

      // default theme
      themeArray.forEach((themeOption: string) => {
        const [themeName, ...flags] = themeOption.split(" ");
        if (themeName && flags.includes("--default")) {
          applyTheme(themeName, ["--default"]);
        }
      });

      // prefers dark theme
      themeArray.forEach((themeOption: string) => {
        const [themeName, ...flags] = themeOption.split(" ");
        if (themeName && flags.includes("--prefersdark")) {
          applyTheme(themeName, ["--prefersdark"]);
        }
      });

      // other themes
      themeArray.forEach((themeOption: string) => {
        const [themeName, ...flags] = themeOption.split(" ");
        if (themeName && !flags.includes("--default") && !flags.includes("--prefersdark")) {
          applyTheme(themeName, flags);
        }
      });
    }

    return { include, exclude, prefix };
  };
})();

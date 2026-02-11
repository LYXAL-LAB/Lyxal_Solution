// Types TypeScript
interface CssObject {
  [key: string]: string | number | CssObject | Array<string | number | CssObject>;
}

type ExcludedPrefixes = string[];
type PrefixType = string | undefined;

// Constantes avec types
const defaultExcludedPrefixes: ExcludedPrefixes = ["color-", "size-", "radius-", "border", "depth", "noise"];
const excludedSelectors: string[] = ["prose"];

// Fonctions utilitaires avec types
const shouldExcludeVariable = (variableName: string, excludedPrefixes: ExcludedPrefixes): boolean => {
  if (variableName.startsWith("tw")) {
    return true;
  }
  return excludedPrefixes.some((excludedPrefix: string) => variableName.startsWith(excludedPrefix));
};

const prefixVariable = (variableName: string, prefix: PrefixType, excludedPrefixes: ExcludedPrefixes): string => {
  if (shouldExcludeVariable(variableName, excludedPrefixes)) {
    return variableName;
  }
  return `${prefix}${variableName}`;
};

const getPrefixedSelector = (selector: string, prefix: PrefixType): string => {
  if (!selector.startsWith(".")) return selector;
  if (excludedSelectors.includes(selector.slice(1))) return selector;
  return `.${prefix}${selector.slice(1)}`;
};

const getPrefixedKey = (key: string, prefix: PrefixType, excludedPrefixes: ExcludedPrefixes): string => {
  const prefixAmpDot: string = prefix ? `&.${prefix}` : "";

  if (!prefix) return key;

  if (key.startsWith(".") && excludedSelectors.includes(key.slice(1))) return key;

  if (key.startsWith("--")) {
    const variableName: string = key.slice(2);
    return `--${prefixVariable(variableName, prefix, excludedPrefixes)}`;
  }

  if (key.startsWith("@") || key.startsWith("[")) {
    return key;
  }

  if (key.startsWith("&")) {
    // If it's a complex selector with :not(), :has(), etc.
    if (key.match(/:[a-z-]+\(/)) {
      return key.replace(/\.([\w-]+)/g, (m: string, cls: string) =>
        excludedSelectors.includes(cls) ? `.${cls}` : `.${prefix}${cls}`,
      );
    }
    // For simple &. cases
    if (key.startsWith("&.")) {
      if (excludedSelectors.includes(key.slice(2))) return key;
      return `${prefixAmpDot}${key.slice(2)}`;
    }
    // For other & cases (like &:hover or &:not(...))
    return key.replace(/\.([\w-]+)/g, (m: string, cls: string) =>
      excludedSelectors.includes(cls) ? `.${cls}` : `.${prefix}${cls}`,
    );
  }

  if (key.startsWith(":")) {
    return key.replace(/\.([\w-]+)/g, (m: string, cls: string) =>
      excludedSelectors.includes(cls) ? `.${cls}` : `.${prefix}${cls}`,
    );
  }

  if (
    key.includes(".") &&
    !key.includes(" ") &&
    !key.includes(">") &&
    !key.includes("+") &&
    !key.includes("~")
  ) {
    return key
      .split(".")
      .filter(Boolean)
      .map((part: string) => (excludedSelectors.includes(part) ? part : prefix! + part))
      .join(".")
      .replace(/^/, ".");
  }

  if (key.includes(">") || key.includes("+") || key.includes("~")) {
    // For comma-separated selectors
    if (key.includes(",")) {
      return key
        .split(/\s*,\s*/)
        .map((part: string) => {
          // Replace class names with prefixed versions for each part
          return part.replace(/\.([\w-]+)/g, (m: string, cls: string) =>
            excludedSelectors.includes(cls) ? `.${cls}` : `.${prefix}${cls}`,
          );
        })
        .join(", ");
    }

    // For simple combinators (not comma-separated)
    let processedKey: string = key.replace(/\.([\w-]+)/g, (m: string, cls: string) =>
      excludedSelectors.includes(cls) ? `.${cls}` : `.${prefix}${cls}`,
    );

    // Add a space before combinators at the beginning
    if (
      processedKey.startsWith(">") ||
      processedKey.startsWith("+") ||
      processedKey.startsWith("~")
    ) {
      processedKey = ` ${processedKey}`;
    }

    return processedKey;
  }

  if (key.includes(" ")) {
    return key
      .split(/\s+/)
      .map((part: string) => {
        if (part.startsWith(".")) {
          return excludedSelectors.includes(part.slice(1))
            ? part
            : getPrefixedSelector(part, prefix);
        }
        return part;
      })
      .join(" ");
  }

  if (key.includes(":")) {
    const [selector, ...pseudo] = key.split(":");
    if (selector && selector.startsWith(".")) {
      return `${excludedSelectors.includes(selector.slice(1)) ? selector : getPrefixedSelector(selector, prefix)}:${pseudo.join(":")}`;
    }
    return key.replace(/\.([\w-]+)/g, (m: string, cls: string) =>
      excludedSelectors.includes(cls) ? `.${cls}` : `.${prefix}${cls}`,
    );
  }

  if (key.startsWith(".")) {
    return excludedSelectors.includes(key.slice(1)) ? key : getPrefixedSelector(key, prefix);
  }

  return key;
};

const processArrayValue = (value: Array<string | number | CssObject>, prefix: PrefixType, excludedPrefixes: ExcludedPrefixes): Array<string | number | CssObject> => {
  return value.map((item: string | number | CssObject) => {
    if (typeof item === "string") {
      if (item.startsWith(".")) {
        return excludedSelectors.includes(item.slice(1))
          ? item
          : prefix
            ? `.${prefix}${item.slice(1)}`
            : item;
      }
      return processStringValue(item, prefix, excludedPrefixes);
    }
    return item;
  });
};

const processStringValue = (value: string, prefix: PrefixType, excludedPrefixes: ExcludedPrefixes): string => {
  if (prefix === undefined || prefix === null) return value;
  return value.replace(/var\(--([^)]+)\)/g, (match: string, variableName: string) => {
    if (shouldExcludeVariable(variableName, excludedPrefixes)) {
      return match;
    }
    return `var(--${prefix}${variableName})`;
  });
};

const processValue = (value: string | number | CssObject | Array<string | number | CssObject>, prefix: PrefixType, excludedPrefixes: ExcludedPrefixes): string | number | CssObject | Array<string | number | CssObject> => {
  if (Array.isArray(value)) {
    return processArrayValue(value, prefix, excludedPrefixes);
  } else if (typeof value === "object" && value !== null) {
    return addPrefix(value as CssObject, prefix, excludedPrefixes);
  } else if (typeof value === "string") {
    return processStringValue(value, prefix, excludedPrefixes);
  } else {
    return value;
  }
};

export const addPrefix = (obj: CssObject, prefix?: string, excludedPrefixes: ExcludedPrefixes = defaultExcludedPrefixes): CssObject => {
  return Object.entries(obj).reduce((result: CssObject, [key, value]) => {
    const newKey: string = getPrefixedKey(key, prefix, excludedPrefixes);
    result[newKey] = processValue(value, prefix, excludedPrefixes);
    return result;
  }, {});
};

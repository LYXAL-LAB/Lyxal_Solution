// Fonction pour nettoyer le CSS généré
export const cleanCss = (cssContent: string): string => {
  // Precompile regular expressions for better performance
  const emptyFallbackRegex: RegExp = /var\((--[^,)]+),\s*\)/g;
  const spacingWidthFallbackRegex: RegExp =
    /var\((--(spacing|width)[\w-]*),\s*((?:[^)(]+|\((?:[^)(]+|\([^)(]*\))*\))*)\)/g;
  const spacingVarRegex: RegExp = /var\(--spacing\)/g;

  // Remove empty fallbacks
  cssContent = cssContent.replace(emptyFallbackRegex, "var($1)");

  // Remove spacing, width css variable if there's a fallback value
  cssContent = cssContent.replace(
    spacingWidthFallbackRegex,
    (match: string, variable: string, prefix: string, fallback: string): string => {
      // If there's no actual fallback value, return the original match
      return fallback.trim() ? fallback.trim() : match;
    },
  );

  // Replace all `var(--spacing)` with `0.25rem`
  cssContent = cssContent.replace(spacingVarRegex, "0.25rem");

  return cssContent;
};

# 🎨 Utilisation des Thèmes dans le Runtime

Guide complet pour utiliser le système de thèmes Database-Driven dans le Lyxal Studio Runtime.

---

## 🎯 Principe Fondamental

**AUCUN framework CSS ou système de thème externe !**

Tous les thèmes sont :
- ✅ Définis dans SurrealDB (tables `theme`, `theme_color`, `theme_mode`)
- ✅ Indépendants de Tailwind, Material Design, Bootstrap, etc.
- ✅ Récupérés dynamiquement depuis la DB
- ✅ Appliqués via CSS Variables ou classes générées dynamiquement
- ✅ Multi-framework : supporte Tailwind, Material Design, Bootstrap, CSS Variables

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│              SURREALDB (Dictionnaire Thèmes)            │
│                                                          │
│  theme:lyxal_default_light                              │
│    ├── config.mode → theme_mode:light                  │
│    ├── config.css_framework → css_framework:tailwind   │
│    ├── config.icon_provider → icon_provider:lucide      │
│    └── Relations avec theme_color                       │
│                                                          │
│  theme_color:primary_500                                │
│    ├── color.hex: "#3b82f6"                            │
│    ├── color.rgb: {r: 59, g: 130, b: 246}             │
│    ├── context.type → theme_color_type:primary         │
│    ├── context.variant: "500"                          │
│    └── metadata.css_variable: "--color-primary-500"    │
│                                                          │
│  theme_mode:light                                       │
│    ├── config.applies_to_system: true                  │
│    └── config.media_query: null                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
                         ↓ Requête DB
┌─────────────────────────────────────────────────────────┐
│              RUNTIME (React)                             │
│                                                          │
│  useStudioTheme("lyxal-default-light") → {             │
│    colors: { primary: {...}, error: {...} },           │
│    mode: "light",                                       │
│    cssVariables: { "--color-primary-500": "#3b82f6" },│
│    ...                                                  │
│  }                                                      │
│                                                          │
│  <ThemeProvider theme={theme}>                          │
│    <App />                                              │
│  </ThemeProvider>                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 📚 Structure des Tables

### 1. `theme` - Thème Complet

Définition complète d'un thème.

```surql
SELECT * FROM theme WHERE identity.slug = 'lyxal-default-light';

-- Résultat :
{
  id: theme:lyxal_default_light,
  identity: {
    value: "lyxal_default_light",
    slug: "lyxal-default-light"
  },
  config: {
    mode: theme_mode:light,
    css_framework: css_framework:tailwind,
    icon_provider: icon_provider:lucide,
    is_system_theme: true,
    is_inheritable: true
  },
  tailwind: {
    config_json: { /* Tailwind config */ },
    safelist: ["bg-primary-500", "text-error-main"]
  },
  status: {
    is_active: true,
    is_default: true,
    visibility: "system"
  }
}
```

### 2. `theme_color` - Variables de Couleur

Chaque couleur du thème.

```surql
SELECT * FROM theme_color 
WHERE context.type = theme_color_type:primary 
AND context.variant = "500"
AND context.theme_mode INSIDE ['both', 'light'];

-- Résultat :
{
  id: theme_color:primary_500,
  identity: {
    value: "primary_500",
    slug: "primary-500"
  },
  color: {
    hex: "#3b82f6",
    rgb: { r: 59, g: 130, b: 246, a: 1 },
    hsl: { h: 217, s: 91, l: 60, a: 1 }
  },
  context: {
    type: theme_color_type:primary,
    variant: "500",
    theme_mode: "both",
    usage: ["button", "text", "background"]
  },
  metadata: {
    css_variable: "--color-primary-500",
    tailwind_class: "bg-primary-500"
  }
}
```

### 3. `theme_mode` - Mode de Thème

Light, Dark, Auto, Custom.

```surql
SELECT * FROM theme_mode WHERE identity.slug = 'light';

-- Résultat :
{
  id: theme_mode:light,
  identity: {
    value: "light",
    slug: "light"
  },
  config: {
    applies_to_system: true,
    media_query: null,
    is_system_mode: true
  },
  status: {
    is_active: true,
    is_default: true
  }
}
```

### 4. `theme_color_type` - Type de Couleur

Primary, Error, Success, etc.

```surql
SELECT * FROM theme_color_type WHERE identity.slug = 'primary';

-- Résultat :
{
  id: theme_color_type:primary,
  identity: {
    value: "primary",
    slug: "primary"
  },
  context: {
    category: "semantic",
    usage_hints: ["buttons", "text", "backgrounds"]
  },
  config: {
    requires_variants: true,
    default_variants: ["50", "100", "200", ..., "900"]
  }
}
```

### 5. `css_framework` - Framework CSS

Tailwind, Material Design, Bootstrap, etc.

```surql
SELECT * FROM css_framework WHERE identity.slug = 'tailwind';

-- Résultat :
{
  id: css_framework:tailwind,
  identity: {
    value: "tailwind",
    slug: "tailwind"
  },
  config: {
    type: "utility_first",
    supported_features: ["dark_mode", "responsive", "animations"],
    version: "3.4.0"
  },
  status: {
    is_active: true,
    is_default: true
  }
}
```

---

## 💻 Implémentation dans le Runtime

### 1. Hook `useStudioTheme`

Hook React pour récupérer un thème depuis la DB.

```typescript
// lib/studio/hooks/useStudioTheme.ts
import { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';

export interface ThemeColor {
  hex: string;
  rgb?: { r: number; g: number; b: number; a?: number };
  hsl?: { h: number; s: number; l: number; a?: number };
  cssVariable?: string;
  tailwindClass?: string;
}

export interface ThemeColors {
  [type: string]: {
    [variant: string]: ThemeColor;
  };
}

export interface StudioTheme {
  id: string;
  name: string;
  mode: 'light' | 'dark' | 'auto' | 'custom';
  cssFramework: string;
  iconProvider: string;
  colors: ThemeColors;
  cssVariables: Record<string, string>;
  tailwindConfig?: any;
}

export const useStudioTheme = (
  themeSlug: string,
  options?: {
    fallback?: string;
    mode?: 'light' | 'dark';
  }
): {
  theme: StudioTheme | null;
  loading: boolean;
  error: Error | null;
} => {
  const [theme, setTheme] = useState<StudioTheme | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError(null);

        // 1. Récupérer le thème principal
        const themeQuery = `
          SELECT 
            *,
            config.mode.* AS mode_info,
            config.css_framework.* AS css_framework_info,
            config.icon_provider.* AS icon_provider_info
          FROM theme
          WHERE identity.slug = $themeSlug
          AND status.is_active = true
          LIMIT 1;
        `;

        const [themeResult] = await db.query(themeQuery, {
          themeSlug
        });

        if (!themeResult || themeResult.length === 0) {
          if (options?.fallback) {
            return useStudioTheme(options.fallback, options);
          }
          throw new Error(`Theme not found: ${themeSlug}`);
        }

        const themeData = themeResult[0];
        const themeMode = options?.mode || themeData.config.mode?.identity.value || 'light';

        // 2. Récupérer toutes les couleurs du thème
        // Pour chaque type de couleur (primary, error, success, etc.)
        const colorTypesQuery = `
          SELECT * FROM theme_color_type
          WHERE status.is_active = true;
        `;

        const [colorTypesResult] = await db.query(colorTypesQuery);
        const colorTypes = colorTypesResult || [];

        // 3. Construire l'objet colors
        const colors: ThemeColors = {};
        const cssVariables: Record<string, string> = {};

        for (const colorType of colorTypes) {
          const colorQuery = `
            SELECT *
            FROM theme_color
            WHERE context.type = ${colorType.id}
            AND context.theme_mode INSIDE ['both', $themeMode]
            AND status.is_active = true;
          `;

          const [colorResult] = await db.query(colorQuery, { themeMode });

          colors[colorType.identity.value] = {};

          for (const color of colorResult || []) {
            const variant = color.context.variant || 'main';
            colors[colorType.identity.value][variant] = {
              hex: color.color.hex,
              rgb: color.color.rgb,
              hsl: color.color.hsl,
              cssVariable: color.metadata.css_variable,
              tailwindClass: color.metadata.tailwind_class
            };

            // Ajouter à cssVariables
            if (color.metadata.css_variable) {
              cssVariables[color.metadata.css_variable] = color.color.hex;
            }
          }
        }

        // 4. Récupérer le nom i18n
        const i18nKey = themeData.presentation.name_i18n;
        const i18nQuery = `
          SELECT 
            ->translation->language.text AS name
          FROM ${i18nKey}
          WHERE language.code = $lang
          LIMIT 1;
        `;

        const [i18nResult] = await db.query(i18nQuery, {
          lang: 'fr'  // TODO: Récupérer depuis le contexte i18n
        });

        // 5. Construire l'objet StudioTheme
        const studioTheme: StudioTheme = {
          id: themeData.id,
          name: i18nResult?.name || themeData.identity.value,
          mode: themeMode,
          cssFramework: themeData.config.css_framework?.identity.value || 'tailwind',
          iconProvider: themeData.config.icon_provider?.identity.value || 'lucide',
          colors,
          cssVariables,
          tailwindConfig: themeData.tailwind?.config_json
        };

        setTheme(studioTheme);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
        setTheme(null);
      } finally {
        setLoading(false);
      }
    })();
  }, [themeSlug, options?.mode, options?.fallback]);

  return { theme, loading, error };
};
```

### 2. Hook `useStudioColor`

Hook pour récupérer une couleur spécifique.

```typescript
// lib/studio/hooks/useStudioColor.ts
import { useMemo } from 'react';
import { useStudioTheme } from './useStudioTheme';

export const useStudioColor = (
  type: string,
  variant: string = 'main',
  themeSlug?: string
): {
  color: string | null;
  cssVariable: string | null;
  tailwindClass: string | null;
} => {
  // Utiliser le thème actuel depuis le contexte ou le slug fourni
  const { theme } = useStudioTheme(themeSlug || 'lyxal-default-light');

  return useMemo(() => {
    if (!theme) {
      return { color: null, cssVariable: null, tailwindClass: null };
    }

    const colorData = theme.colors[type]?.[variant];

    return {
      color: colorData?.hex || null,
      cssVariable: colorData?.cssVariable || null,
      tailwindClass: colorData?.tailwindClass || null
    };
  }, [theme, type, variant]);
};
```

### 3. Composant `ThemeProvider`

Provider React pour injecter les CSS Variables.

```typescript
// components/studio/ThemeProvider.tsx
import React, { createContext, useContext, useEffect } from 'react';
import { useStudioTheme } from '@/lib/studio/hooks/useStudioTheme';

interface ThemeContextValue {
  theme: StudioTheme | null;
  loading: boolean;
  error: Error | null;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export const useThemeContext = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useThemeContext must be used within ThemeProvider');
  }
  return context;
};

export interface ThemeProviderProps {
  themeSlug: string;
  mode?: 'light' | 'dark';
  fallback?: string;
  children: React.ReactNode;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({
  themeSlug,
  mode,
  fallback,
  children
}) => {
  const { theme, loading, error } = useStudioTheme(themeSlug, { mode, fallback });

  // Injecter les CSS Variables dans le document
  useEffect(() => {
    if (!theme) return;

    const root = document.documentElement;

    // Appliquer toutes les CSS Variables
    Object.entries(theme.cssVariables).forEach(([key, value]) => {
      root.style.setProperty(key, value);
    });

    // Appliquer le mode (data-theme pour dark mode)
    if (theme.mode === 'dark') {
      root.setAttribute('data-theme', 'dark');
    } else {
      root.removeAttribute('data-theme');
    }

    // Nettoyage
    return () => {
      Object.keys(theme.cssVariables).forEach((key) => {
        root.style.removeProperty(key);
      });
    };
  }, [theme]);

  const value: ThemeContextValue = {
    theme,
    loading,
    error
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};
```

### 4. Utilisation dans les Composants

```typescript
// Exemple : Utilisation d'une couleur dans un composant
const ButtonComponent = ({ variant = 'primary' }) => {
  const { theme } = useThemeContext();
  const primaryColor = theme?.colors.primary?.['500']?.hex || '#3b82f6';

  return (
    <button
      style={{
        backgroundColor: primaryColor,
        // ou via CSS Variable
        backgroundColor: 'var(--color-primary-500)'
      }}
    >
      Click me
    </button>
  );
};

// Exemple : Utilisation du hook useStudioColor
const AlertComponent = ({ type = 'error' }) => {
  const { color, cssVariable } = useStudioColor(type, 'main');

  return (
    <div
      style={{
        backgroundColor: `var(${cssVariable})`
      }}
    >
      Alert message
    </div>
  );
};
```

---

## 🔍 Requêtes SurrealDB Optimisées

### Récupérer un thème complet avec toutes ses couleurs

```surql
-- Requête optimisée pour récupérer un thème complet
SELECT 
  *,
  config.mode.* AS mode_info,
  config.css_framework.* AS css_framework_info,
  (SELECT * FROM theme_color 
   WHERE context.theme_mode INSIDE ['both', mode_info.identity.value]
   AND status.is_active = true) AS colors
FROM theme
WHERE identity.slug = 'lyxal-default-light'
AND status.is_active = true
LIMIT 1;
```

### Récupérer toutes les couleurs d'un type spécifique

```surql
-- Couleurs primary pour le mode light
SELECT 
  *,
  context.type.* AS type_info,
  context.variant AS variant
FROM theme_color
WHERE context.type = theme_color_type:primary
AND context.theme_mode INSIDE ['both', 'light']
AND status.is_active = true
ORDER BY context.variant;
```

### Rechercher des thèmes par mode

```surql
-- Tous les thèmes light disponibles
SELECT 
  identity.slug,
  presentation.name_i18n,
  config.mode.*
FROM theme
WHERE config.mode = theme_mode:light
AND status.is_active = true
AND status.visibility INSIDE ['public', 'system'];
```

---

## 🎨 Gestion des Modes (Light/Dark)

### Détection Automatique

```typescript
// lib/studio/hooks/useThemeMode.ts
import { useEffect, useState } from 'react';

export const useThemeMode = (): {
  mode: 'light' | 'dark';
  setMode: (mode: 'light' | 'dark') => void;
  toggleMode: () => void;
} => {
  const [mode, setModeState] = useState<'light' | 'dark'>(() => {
    // Détecter depuis localStorage ou système
    const saved = localStorage.getItem('theme-mode');
    if (saved === 'light' || saved === 'dark') {
      return saved;
    }
    
    // Détecter depuis prefers-color-scheme
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    
    return 'light';
  });

  useEffect(() => {
    // Écouter les changements système
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const handler = (e: MediaQueryListEvent) => {
      // Optionnel : suivre automatiquement le système
      // setModeState(e.matches ? 'dark' : 'light');
    };
    
    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  const setMode = (newMode: 'light' | 'dark') => {
    setModeState(newMode);
    localStorage.setItem('theme-mode', newMode);
  };

  const toggleMode = () => {
    setMode(mode === 'light' ? 'dark' : 'light');
  };

  return { mode, setMode, toggleMode };
};
```

### Utilisation avec ThemeProvider

```typescript
const App = () => {
  const { mode, toggleMode } = useThemeMode();
  const defaultTheme = mode === 'light' 
    ? 'lyxal-default-light' 
    : 'lyxal-default-dark';

  return (
    <ThemeProvider themeSlug={defaultTheme} mode={mode}>
      <button onClick={toggleMode}>
        Toggle {mode === 'light' ? 'Dark' : 'Light'}
      </button>
      <YourApp />
    </ThemeProvider>
  );
};
```

---

## 🚀 Génération de CSS Variables

### Hook pour Générer le CSS

```typescript
// lib/studio/utils/generateThemeCSS.ts
export const generateThemeCSS = (theme: StudioTheme): string => {
  const variables: string[] = [];

  // Générer toutes les CSS Variables
  Object.entries(theme.cssVariables).forEach(([key, value]) => {
    variables.push(`  ${key}: ${value};`);
  });

  return `
:root {
${variables.join('\n')}
}

[data-theme="dark"] {
  /* Override pour dark mode si nécessaire */
}
  `.trim();
};

// Utilisation
const { theme } = useStudioTheme('lyxal-default-light');
const css = theme ? generateThemeCSS(theme) : '';

useEffect(() => {
  if (!css) return;
  
  // Injecter dans un <style> tag
  const style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);
  
  return () => {
    document.head.removeChild(style);
  };
}, [css]);
```

---

## 📝 Exemples d'Utilisation

### Dans un Composant DB

```json
// studio_component:button structure
{
  "type": "button",
  "props": {
    "variant": "{{props.variant}}",  // "primary", "error", etc.
    "mode": "{{theme.mode}}"          // "light", "dark"
  }
}
```

```typescript
// Dans le renderer
const ButtonRenderer = ({ structure, props }) => {
  const { theme } = useThemeContext();
  const variant = resolveTemplate(structure.props.variant, props);
  const color = theme?.colors[variant]?.['500']?.hex;

  return (
    <button
      style={{
        backgroundColor: color || 'var(--color-primary-500)'
      }}
    >
      {resolveTemplate(structure.props.label, props)}
    </button>
  );
};
```

### Utilisation dans StudioConfig

```surql
-- studio_config peut référencer un thème
UPDATE studio_config:default SET
  theme = theme:lyxal_default_light,
  theme_mode = theme_mode:light;
```

---

## 🔒 Sécurité et Validation

### Validation des Couleurs

```typescript
// Valider le format HEX
const isValidColor = (color: string): boolean => {
  return /^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$/.test(color);
};

// Dans useStudioTheme
if (colorData && !isValidColor(colorData.hex)) {
  console.warn(`Invalid color format: ${colorData.hex}`);
}
```

---

## 🧪 Tests

### Test du Hook

```typescript
// __tests__/useStudioTheme.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { useStudioTheme } from '@/lib/studio/hooks/useStudioTheme';

jest.mock('@/lib/surrealdb', () => ({
  db: {
    query: jest.fn()
  }
}));

test('should fetch theme from DB', async () => {
  const { result } = renderHook(() => useStudioTheme('lyxal-default-light'));
  
  expect(result.current.loading).toBe(true);
  
  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });
  
  expect(result.current.theme).toBeTruthy();
  expect(result.current.theme?.colors.primary).toBeDefined();
});
```

---

## 🎯 Résumé

1. **Aucun framework externe** - Tout passe par SurrealDB
2. **Thèmes complets** - Mode + Couleurs + Framework configuré
3. **CSS Variables dynamiques** - Génération automatique depuis la DB
4. **Support multi-framework** - Tailwind, Material Design, Bootstrap, CSS Variables
5. **Light/Dark mode** - Détection automatique + bascule manuelle
6. **Couleurs typées** - Primary, Error, Success, etc. avec variantes

---

**✅ Système 100% Database-Driven, 0 dépendance aux frameworks de thème externes !** 🚀


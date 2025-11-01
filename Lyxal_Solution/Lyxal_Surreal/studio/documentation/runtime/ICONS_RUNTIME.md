# 🎨 Utilisation des Icônes dans le Runtime

Guide complet pour utiliser le système d'icônes Database-Driven dans le Lyxal Studio Runtime.

---

## 🎯 Principe Fondamental

**AUCUNE bibliothèque d'icônes importée dans le code frontend !**

Toutes les icônes sont :
- ✅ Définies dans SurrealDB (tables `icon`, `icon_variant`, `icon_provider`)
- ✅ Hébergées sur Bunny CDN (URLs stockées dans la table `url`)
- ✅ Récupérées dynamiquement depuis la DB
- ✅ Rendu via des URLs SVG (pas de composants React d'icônes)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│              SURREALDB (Dictionnaire Icônes)            │
│                                                          │
│  icon:user (concept abstrait)                          │
│    ├── identity.value: "user"                          │
│    ├── identity.slug: "user"                           │
│    ├── context.category → icon_category:ui              │
│    └── Relations icon_variant → icon_provider          │
│                                                          │
│  icon_variant (RELATION icon → icon_provider)          │
│    ├── in: icon:user                                   │
│    ├── out: icon_provider:lucide                        │
│    ├── asset.svg_url → url:icon_user_lucide_stroke     │
│    └── asset.style_variant: "stroke"                   │
│                                                          │
│  url:icon_user_lucide_stroke                           │
│    ├── url.href: "https://icons.lyxal.b-cdn.net/      │
│    │                   lucide/user.svg"                │
│    └── context.usage_type: "asset"                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
                         ↓ Requête DB
┌─────────────────────────────────────────────────────────┐
│              RUNTIME (React)                             │
│                                                          │
│  useStudioIcon("user") → {                             │
│    svgUrl: "https://icons.lyxal.b-cdn.net/...",       │
│    alt: "User",                                        │
│    ...                                                 │
│  }                                                      │
│                                                          │
│  <Icon src={svgUrl} alt={alt} />                       │
└─────────────────────────────────────────────────────────┘
```

---

## 📚 Structure des Tables

### 1. `icon` - Concept Abstrait

Icône sémantique (ex: `icon:user`, `icon:settings`).

```surql
SELECT * FROM icon WHERE identity.slug = 'user';

-- Résultat :
{
  id: icon:user,
  identity: {
    value: "user",
    slug: "user"
  },
  presentation: {
    name_i18n: i18n_key:icon_user_name,
    label_i18n: i18n_key:icon_user_label,
    keywords: ["user", "account", "profile", "person"]
  },
  context: {
    category: icon_category:ui
  },
  status: {
    is_active: true,
    is_system_icon: true
  }
}
```

### 2. `icon_variant` - Variantes par Provider

**RELATION** entre `icon` et `icon_provider` contenant l'URL SVG.

```surql
SELECT 
  ->icon_variant->(icon_provider WHERE status.is_active = true) AS variants
FROM icon:user;

-- Résultat :
{
  variants: [
    {
      id: icon_variant:user_lucide_stroke,
      in: icon:user,
      out: icon_provider:lucide,
      provider_mapping: {
        provider_icon_name: "user"
      },
      asset: {
        svg_url: url:icon_user_lucide_stroke,  -- ← Référence vers table url
        style_variant: "stroke"
      },
      status: {
        is_active: true,
        is_fallback: true
      }
    }
  ]
}
```

### 3. `url` - URL du SVG sur Bunny CDN

L'URL complète du SVG est stockée dans la table `url`.

```surql
SELECT * FROM url:icon_user_lucide_stroke;

-- Résultat :
{
  id: url:icon_user_lucide_stroke,
  url: {
    href: "https://icons.lyxal.b-cdn.net/lucide/user.svg",
    protocol: "https",
    is_external: true
  },
  context: {
    usage_type: "asset",
    module: builder_catalogue:studio_icon
  },
  extensions: {
    asset: {
      mime_type: "image/svg+xml"
    }
  },
  status: {
    is_active: true
  }
}
```

### 4. `icon_provider` - Fournisseur d'Icônes

Configuration du fournisseur (Lucide, Heroicons, etc.).

```surql
SELECT * FROM icon_provider:lucide;

-- Résultat :
{
  id: icon_provider:lucide,
  identity: {
    value: "lucide",
    slug: "lucide"
  },
  config: {
    base_url: url:icon_provider_lucide_base_cdn,  -- ← Référence vers table url
    version: "0.344.0",
    style: icon_style:stroke,
    is_recommended: true
  },
  status: {
    is_active: true,
    is_default: true
  }
}
```

---

## 💻 Implémentation dans le Runtime

### 1. Hook `useStudioIcon`

Hook React pour récupérer une icône depuis la DB.

```typescript
// lib/studio/hooks/useStudioIcon.ts
import { useEffect, useState } from 'react';
import { db } from '@/lib/surrealdb';

export interface StudioIcon {
  id: string;
  svgUrl: string;
  alt: string;
  style: 'stroke' | 'solid' | 'duotone' | 'custom';
  provider: string;
  category: string;
}

export const useStudioIcon = (
  iconSlug: string,
  options?: {
    provider?: string;  // Préférer un provider spécifique
    style?: 'stroke' | 'solid' | 'duotone' | 'custom';
    fallback?: string;  // Icône de fallback si non trouvée
  }
): {
  icon: StudioIcon | null;
  loading: boolean;
  error: Error | null;
} => {
  const [icon, setIcon] = useState<StudioIcon | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError(null);

        // 1. Récupérer l'icône abstraite
        const iconQuery = `
          SELECT 
            *,
            context.category.* AS category_info
          FROM icon
          WHERE identity.slug = $iconSlug
          AND status.is_active = true
          LIMIT 1;
        `;

        const [iconResult] = await db.query(iconQuery, {
          iconSlug
        });

        if (!iconResult || iconResult.length === 0) {
          // Fallback si icône non trouvée
          if (options?.fallback) {
            return useStudioIcon(options.fallback, options);
          }
          throw new Error(`Icon not found: ${iconSlug}`);
        }

        const iconData = iconResult[0];

        // 2. Récupérer les variantes (relations icon_variant)
        const variantQuery = `
          SELECT 
            *,
            ->icon_variant->(icon_provider WHERE status.is_active = true) AS variants
          FROM icon:${iconData.id}
          FETCH variants.asset.svg_url.*;
        `;

        const [variantResult] = await db.query(variantQuery);

        // 3. Sélectionner la meilleure variante
        let selectedVariant = null;

        if (variantResult && variantResult.variants) {
          // Filtrer selon les options
          const variants = variantResult.variants.filter((v: any) => {
            if (options?.provider && v.out.identity.value !== options.provider) {
              return false;
            }
            if (options?.style && v.asset.style_variant !== options.style) {
              return false;
            }
            return v.status.is_active === true;
          });

          // Priorité : fallback > style préféré > premier actif
          selectedVariant = variants.find((v: any) => v.status.is_fallback === true)
            || variants.find((v: any) => v.asset.style_variant === options?.style)
            || variants[0];
        }

        if (!selectedVariant) {
          throw new Error(`No active variant found for icon: ${iconSlug}`);
        }

        // 4. Récupérer l'URL complète depuis la table url
        const urlId = selectedVariant.asset.svg_url;
        const urlQuery = `
          SELECT 
            url.href AS href
          FROM ${urlId}
          WHERE status.is_active = true
          LIMIT 1;
        `;

        const [urlResult] = await db.query(urlQuery);

        if (!urlResult || !urlResult.href) {
          throw new Error(`URL not found for variant: ${urlId}`);
        }

        // 5. Récupérer le label i18n
        const i18nKey = iconData.presentation.label_i18n || iconData.presentation.name_i18n;
        const i18nQuery = `
          SELECT 
            ->translation->language.text AS label
          FROM ${i18nKey}
          WHERE language.code = $lang
          LIMIT 1;
        `;

        const [i18nResult] = await db.query(i18nQuery, {
          lang: 'fr'  // TODO: Récupérer depuis le contexte i18n
        });

        // 6. Construire l'objet StudioIcon
        const studioIcon: StudioIcon = {
          id: iconData.id,
          svgUrl: urlResult.href,
          alt: i18nResult?.label || iconData.identity.value,
          style: selectedVariant.asset.style_variant,
          provider: selectedVariant.out.identity.value,
          category: iconData.context.category?.identity.value || 'unknown'
        };

        setIcon(studioIcon);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
        setIcon(null);
      } finally {
        setLoading(false);
      }
    })();
  }, [iconSlug, options?.provider, options?.style, options?.fallback]);

  return { icon, loading, error };
};
```

### 2. Composant `StudioIcon`

Composant React pour afficher une icône.

```typescript
// components/studio/StudioIcon.tsx
import React from 'react';
import { useStudioIcon } from '@/lib/studio/hooks/useStudioIcon';

export interface StudioIconProps {
  /** Slug de l'icône (ex: "user", "settings") */
  name: string;
  /** Taille de l'icône (en pixels) */
  size?: number;
  /** Couleur de l'icône (CSS color) */
  color?: string;
  /** Classes CSS additionnelles */
  className?: string;
  /** Provider spécifique (optionnel) */
  provider?: string;
  /** Style spécifique (optionnel) */
  style?: 'stroke' | 'solid' | 'duotone' | 'custom';
  /** Icône de fallback si non trouvée */
  fallback?: string;
  /** Callback en cas d'erreur */
  onError?: (error: Error) => void;
}

export const StudioIcon: React.FC<StudioIconProps> = ({
  name,
  size = 24,
  color = 'currentColor',
  className = '',
  provider,
  style,
  fallback,
  onError
}) => {
  const { icon, loading, error } = useStudioIcon(name, {
    provider,
    style,
    fallback
  });

  React.useEffect(() => {
    if (error && onError) {
      onError(error);
    }
  }, [error, onError]);

  if (loading) {
    // Placeholder pendant le chargement
    return (
      <div
        className={`studio-icon-loading ${className}`}
        style={{
          width: size,
          height: size,
          backgroundColor: 'transparent'
        }}
        aria-hidden="true"
      />
    );
  }

  if (!icon) {
    // Icône de fallback ou placeholder
    return (
      <div
        className={`studio-icon-error ${className}`}
        style={{
          width: size,
          height: size,
          backgroundColor: 'rgba(0,0,0,0.1)',
          borderRadius: '4px'
        }}
        aria-label={name}
        title={`Icon not found: ${name}`}
      />
    );
  }

  // Rendu via <img> ou <svg> inline selon besoin
  return (
    <img
      src={icon.svgUrl}
      alt={icon.alt}
      className={`studio-icon ${className}`}
      style={{
        width: size,
        height: size,
        color: color,
        filter: color !== 'currentColor' ? `drop-shadow(0 0 0 ${color})` : undefined
      }}
      loading="lazy"
      decoding="async"
      onError={(e) => {
        if (fallback && !error) {
          // Essayer le fallback
          return;
        }
        onError?.(new Error(`Failed to load icon: ${icon.svgUrl}`));
      }}
    />
  );
};
```

### 3. Utilisation dans les Composants DB

Utilisation dans un composant généré depuis la DB.

```typescript
// Exemple : Structure JSON dans studio_component:button
{
  type: "button",
  props: {
    icon: {
      name: "user",
      size: 20,
      color: "#3b82f6"
    },
    label: "{{props.label}}"
  }
}

// Dans le Renderer :
const ButtonComponent = ({ props }) => {
  return (
    <button className="btn">
      {props.icon && (
        <StudioIcon 
          name={props.icon.name}
          size={props.icon.size}
          color={props.icon.color}
        />
      )}
      <span>{props.label}</span>
    </button>
  );
};
```

---

## 🔍 Requêtes SurrealDB Optimisées

### Récupérer une icône avec toutes ses variantes

```surql
-- Requête optimisée pour récupérer une icône complète
SELECT 
  *,
  ->icon_variant[WHERE status.is_active = true]->(icon_provider WHERE status.is_active = true) {
    provider_mapping.*,
    asset.style_variant,
    asset.svg_url.* {
      url.href AS svg_url,
      context.usage_type
    }
  } AS variants
FROM icon
WHERE identity.slug = 'user'
AND status.is_active = true
LIMIT 1;
```

### Rechercher des icônes par catégorie

```surql
-- Trouver toutes les icônes d'une catégorie
SELECT 
  identity.slug,
  presentation.label_i18n,
  context.category.*
FROM icon
WHERE context.category = icon_category:ui
AND status.is_active = true;
```

### Rechercher des icônes par keywords

```surql
-- Recherche par mots-clés
SELECT 
  identity.slug,
  presentation.name_i18n,
  presentation.keywords
FROM icon
WHERE presentation.keywords CONTAINS 'user'
OR presentation.keywords CONTAINS 'account'
AND status.is_active = true;
```

---

## 🎨 Gestion des Styles et Variantes

### Priorité de Sélection des Variantes

1. **Icône de fallback** (`status.is_fallback = true`)
2. **Style préféré** (si spécifié dans les options)
3. **Provider préféré** (si spécifié dans les options)
4. **Première variante active** disponible

### Exemple de Sélection

```typescript
// Préférer Lucide stroke pour "user"
const { icon } = useStudioIcon('user', {
  provider: 'lucide',
  style: 'stroke'
});

// Si Lucide stroke n'existe pas, utiliser le fallback
// Si aucun fallback, utiliser la première variante active
```

---

## 🚀 Cache et Optimisation

### Cache des Icônes

```typescript
// lib/studio/cache/iconCache.ts
import { create } from 'zustand';

interface IconCacheEntry {
  icon: StudioIcon;
  timestamp: number;
  ttl: number; // Time to live (ms)
}

const useIconCache = create<{
  cache: Map<string, IconCacheEntry>;
  get: (key: string) => StudioIcon | null;
  set: (key: string, icon: StudioIcon, ttl?: number) => void;
  clear: () => void;
}>((set, get) => ({
  cache: new Map(),
  
  get: (key: string) => {
    const entry = get().cache.get(key);
    if (!entry) return null;
    
    const now = Date.now();
    if (now > entry.timestamp + entry.ttl) {
      // Cache expiré
      get().cache.delete(key);
      return null;
    }
    
    return entry.icon;
  },
  
  set: (key: string, icon: StudioIcon, ttl = 3600000) => {
    get().cache.set(key, {
      icon,
      timestamp: Date.now(),
      ttl
    });
  },
  
  clear: () => {
    get().cache.clear();
  }
}));

// Utilisation dans useStudioIcon
export const useStudioIcon = (iconSlug: string, options?: {...}) => {
  // 1. Vérifier le cache
  const cacheKey = `${iconSlug}_${options?.provider || 'any'}_${options?.style || 'any'}`;
  const cached = useIconCache.getState().get(cacheKey);
  
  if (cached) {
    return { icon: cached, loading: false, error: null };
  }
  
  // 2. Récupérer depuis la DB
  // ... (code existant)
  
  // 3. Mettre en cache
  if (icon) {
    useIconCache.getState().set(cacheKey, icon);
  }
};
```

### Préchargement des Icônes

```typescript
// Précharger les icônes les plus utilisées
const preloadIcons = async (iconSlugs: string[]) => {
  const preloadPromises = iconSlugs.map(async (slug) => {
    const { icon } = await useStudioIcon(slug);
    if (icon) {
      // Précharger l'image
      const img = new Image();
      img.src = icon.svgUrl;
    }
  });
  
  await Promise.all(preloadPromises);
};

// À appeler au démarrage de l'app
preloadIcons(['user', 'settings', 'home', 'menu', 'search']);
```

---

## 🔒 Sécurité

### Validation des URLs

```typescript
// Valider que l'URL provient bien de Bunny CDN
const isValidIconUrl = (url: string): boolean => {
  try {
    const urlObj = new URL(url);
    return urlObj.hostname === 'icons.lyxal.b-cdn.net'
      || urlObj.hostname.endsWith('.b-cdn.net');
  } catch {
    return false;
  }
};

// Dans StudioIcon
if (!isValidIconUrl(icon.svgUrl)) {
  throw new Error(`Invalid icon URL: ${icon.svgUrl}`);
}
```

---

## 📝 Exemples d'Utilisation

### Dans un Menu

```typescript
// studio_menu.item.icon → "user"
const MenuItem = ({ item }) => {
  const { icon, loading } = useStudioIcon(item.icon || 'placeholder');
  
  return (
    <li>
      {!loading && icon && (
        <StudioIcon name={icon.id} size={20} />
      )}
      <span>{item.label}</span>
    </li>
  );
};
```

### Dans un Bouton DB

```json
// studio_component:button structure
{
  "type": "button",
  "props": {
    "icon": "{{props.icon}}",  // Template résolu depuis DB
    "label": "{{props.label}}"
  }
}
```

```typescript
// Dans le renderer
const ButtonRenderer = ({ structure, props }) => {
  const iconName = resolveTemplate(structure.props.icon, props);
  
  return (
    <button>
      {iconName && <StudioIcon name={iconName} size={16} />}
      {resolveTemplate(structure.props.label, props)}
    </button>
  );
};
```

---

## 🧪 Tests

### Test du Hook

```typescript
// __tests__/useStudioIcon.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { useStudioIcon } from '@/lib/studio/hooks/useStudioIcon';

// Mock SurrealDB
jest.mock('@/lib/surrealdb', () => ({
  db: {
    query: jest.fn()
  }
}));

test('should fetch icon from DB', async () => {
  const { result } = renderHook(() => useStudioIcon('user'));
  
  expect(result.current.loading).toBe(true);
  
  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });
  
  expect(result.current.icon).toBeTruthy();
  expect(result.current.icon?.svgUrl).toContain('b-cdn.net');
});
```

---

## 🎯 Résumé

1. **Aucune bibliothèque importée** - Tout passe par SurrealDB
2. **URLs dans la table `url`** - Référence via `icon_variant.asset.svg_url`
3. **Hook `useStudioIcon`** - Récupération optimisée depuis la DB
4. **Composant `StudioIcon`** - Rendu via `<img src={svgUrl} />`
5. **Cache intelligent** - Performance optimale
6. **Validation sécurité** - URLs validées (Bunny CDN uniquement)

---

**✅ Système 100% Database-Driven, 0 dépendance frontend !** 🚀


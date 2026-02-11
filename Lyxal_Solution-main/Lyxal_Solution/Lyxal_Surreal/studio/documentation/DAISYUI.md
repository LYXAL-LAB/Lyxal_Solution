# 🎨 Lyxal Studio + DaisyUI

Guide complet pour intégrer DaisyUI avec Lyxal Studio et piloter les thèmes depuis SurrealDB.

---

## 🎯 Pourquoi DaisyUI ?

**DaisyUI** est la bibliothèque de composants UI idéale pour Lyxal Studio car :

1. **Thèmes CSS Variables** → Pilotables depuis SurrealDB
2. **33 thèmes prédéfinis** → Changement instantané
3. **Dark mode natif** → 1 seul attribut HTML
4. **50+ composants** → Boutons, cards, modals, etc.
5. **Basé sur Tailwind** → Performance optimale
6. **Pas de JavaScript** → Pure CSS

---

## ✨ Avantages pour Lyxal

### Sans DaisyUI ❌

```
- Créer tous les composants manuellement
- Gérer le dark mode soi-même
- Écrire du CSS personnalisé pour chaque tenant
- Maintenance complexe des styles
```

### Avec DaisyUI ✅

```
- 50+ composants prêts à l'emploi
- Dark mode automatique
- Thèmes White-Label en 1 UPDATE DB
- Maintenance minimale
```

---

## 📦 Installation

### 1. Installer les dépendances

```bash
# Projet React (Lyxal Central)
cd Lyxal_Central

# Installer Tailwind CSS + DaisyUI
npm install -D tailwindcss postcss autoprefixer daisyui

# Initialiser Tailwind
npx tailwindcss init -p
```

### 2. Configuration Tailwind

```javascript
// tailwind.config.js
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
  daisyui: {
    themes: [
      'light',
      'dark',
      'cupcake',
      'bumblebee',
      'emerald',
      'corporate',
      'synthwave',
      'retro',
      'cyberpunk',
      'valentine',
      'halloween',
      'garden',
      'forest',
      'aqua',
      'lofi',
      'pastel',
      'fantasy',
      'wireframe',
      'black',
      'luxury',
      'dracula',
      'cmyk',
      'autumn',
      'business',
      'acid',
      'lemonade',
      'night',
      'coffee',
      'winter',
      // Thèmes personnalisés (définis dans SurrealDB)
    ],
    darkTheme: 'dark',
    base: true,
    styled: true,
    utils: true,
    logs: false,
  },
}
```

### 3. Importer les styles

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

---

## 🎨 Configuration SurrealDB

### Structure des Thèmes

```surql
-- Thème prédéfini DaisyUI
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  web_theme = "corporate",  -- Utilise un thème DaisyUI existant
  ...;

-- Thème personnalisé
CREATE studio_config:batipro SET
  tenant_id = "batipro",
  daisy_custom = {
    "primary": "#FF6B35",
    "secondary": "#004E89",
    "accent": "#FFC857",
    "neutral": "#1F2937",
    "base-100": "#FFFFFF",
    "base-200": "#F9FAFB",
    "base-300": "#E5E7EB",
    "info": "#3ABFF8",
    "success": "#36D399",
    "warning": "#FBBD23",
    "error": "#F87272"
  },
  ...;
```

---

## 🔧 Application du Thème

### Hook useStudioTheme

```typescript
// hooks/useStudioTheme.ts
import { useEffect } from 'react';

interface DaisyTheme {
  web_theme?: string;
  daisy_custom?: Record<string, string>;
}

export const useStudioTheme = (theme: DaisyTheme) => {
  useEffect(() => {
    const root = document.documentElement;

    if (theme.web_theme) {
      // Appliquer un thème prédéfini
      root.setAttribute('data-theme', theme.web_theme);
      console.log(`✅ Thème DaisyUI appliqué: ${theme.web_theme}`);
    } else if (theme.daisy_custom) {
      // Appliquer un thème personnalisé
      Object.entries(theme.daisy_custom).forEach(([key, value]) => {
        root.style.setProperty(`--${key}`, value);
      });
      console.log('✅ Thème personnalisé appliqué');
    }
  }, [theme]);
};
```

### Dans StudioEngine

```typescript
// components/studio/StudioEngine.tsx
import React, { useEffect, useState } from 'react';
import { useStudioTheme } from '@/hooks/useStudioTheme';
import { db } from '@/lib/surrealdb';

export const StudioEngine: React.FC<{ tenant: string }> = ({ tenant }) => {
  const [config, setConfig] = useState<any>(null);

  useEffect(() => {
    const loadConfig = async () => {
      const result = await db.query(`
        SELECT fn::studio_get_config('${tenant}')
      `);
      
      if (result?.[0]?.config) {
        setConfig(result[0].config);
      }
    };

    loadConfig();
  }, [tenant]);

  // Appliquer le thème DaisyUI
  useStudioTheme({
    web_theme: config?.web_theme,
    daisy_custom: config?.daisy_custom,
  });

  return (
    <div className="h-screen flex overflow-hidden">
      {/* Contenu de l'application */}
    </div>
  );
};
```

---

## 🧩 Composants Studio avec DaisyUI

### 1. StudioMenu avec DaisyUI

```tsx
// components/studio/StudioMenu.tsx
import React from 'react';
import { Link } from 'react-router-dom';
import * as Icons from 'lucide-react';

export const StudioMenu: React.FC<{ menu: any[] }> = ({ menu }) => {
  return (
    <ul className="menu bg-base-200 w-56 rounded-box">
      {menu.map((item) => (
        <li key={item.code}>
          {item.children ? (
            // Menu avec sous-menus
            <details open>
              <summary>
                <Icons.User className="w-4 h-4" />
                {item.label.fr}
              </summary>
              <ul>
                {item.children.map((child: any) => (
                  <li key={child.code}>
                    <Link to={child.url}>{child.label.fr}</Link>
                  </li>
                ))}
              </ul>
            </details>
          ) : (
            // Menu simple
            <Link to={item.url} className={item.active ? 'active' : ''}>
              <Icons.User className="w-4 h-4" />
              {item.label.fr}
            </Link>
          )}
        </li>
      ))}
    </ul>
  );
};
```

### 2. StudioWidget Stat avec DaisyUI

```tsx
// components/studio/widgets/StatWidget.tsx
import React from 'react';
import * as Icons from 'lucide-react';

export const StatWidget: React.FC<{ widget: any; data: any }> = ({ widget, data }) => {
  const Icon = Icons[widget.config.icon as keyof typeof Icons];

  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">{widget.title.fr}</h2>
        
        <div className="stats shadow">
          <div className="stat">
            <div className="stat-figure text-primary">
              {Icon && <Icon className="w-8 h-8" />}
            </div>
            <div className="stat-title">Total</div>
            <div className="stat-value text-primary">
              {data?.count || data?.total || 0}
            </div>
            <div className="stat-desc">↗︎ 12% ce mois</div>
          </div>
        </div>
      </div>
    </div>
  );
};
```

### 3. StudioForm avec DaisyUI

```tsx
// components/studio/StudioForm.tsx
import React, { useState } from 'react';

export const StudioForm: React.FC<{ form: any }> = ({ form }) => {
  const [formData, setFormData] = useState<any>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // Logique de soumission
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <h2 className="text-2xl font-bold">{form.title.fr}</h2>

      {form.fields.map((field: any) => (
        <div key={field.name} className="form-control">
          <label className="label">
            <span className="label-text">{field.label.fr}</span>
          </label>

          {field.type === 'text' || field.type === 'email' ? (
            <input
              type={field.type}
              placeholder={field.placeholder?.fr}
              className="input input-bordered w-full"
              value={formData[field.name] || ''}
              onChange={(e) => setFormData({ ...formData, [field.name]: e.target.value })}
              required={field.required}
            />
          ) : field.type === 'textarea' ? (
            <textarea
              placeholder={field.placeholder?.fr}
              className="textarea textarea-bordered w-full"
              value={formData[field.name] || ''}
              onChange={(e) => setFormData({ ...formData, [field.name]: e.target.value })}
              required={field.required}
              rows={field.rows || 4}
            />
          ) : field.type === 'select' ? (
            <select
              className="select select-bordered w-full"
              value={formData[field.name] || field.default}
              onChange={(e) => setFormData({ ...formData, [field.name]: e.target.value })}
              required={field.required}
            >
              {field.options.map((opt: any) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label.fr}
                </option>
              ))}
            </select>
          ) : null}
        </div>
      ))}

      <div className="flex gap-4">
        <button type="submit" className="btn btn-primary">
          {form.submit_button.label.fr}
        </button>
        <button type="button" className="btn btn-ghost">
          Annuler
        </button>
      </div>
    </form>
  );
};
```

### 4. StudioTable avec DaisyUI

```tsx
// components/studio/widgets/TableWidget.tsx
import React from 'react';

export const TableWidget: React.FC<{ widget: any; data: any[] }> = ({ widget, data }) => {
  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">{widget.title.fr}</h2>

        <div className="overflow-x-auto">
          <table className="table table-zebra w-full">
            <thead>
              <tr>
                {widget.config.columns.map((col: any) => (
                  <th key={col.field}>{col.label.fr}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {data.map((row, i) => (
                <tr key={i} className="hover">
                  {widget.config.columns.map((col: any) => (
                    <td key={col.field}>{row[col.field]}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
```

### 5. Dashboard avec DaisyUI

```tsx
// components/studio/StudioDashboard.tsx
import React from 'react';
import { StatWidget } from './widgets/StatWidget';
import { ChartWidget } from './widgets/ChartWidget';
import { TableWidget } from './widgets/TableWidget';

export const StudioDashboard: React.FC<{ widgets: any[] }> = ({ widgets }) => {
  return (
    <div className="p-6">
      {/* Hero */}
      <div className="hero min-h-[200px] bg-base-200 rounded-box mb-6">
        <div className="hero-content text-center">
          <div className="max-w-md">
            <h1 className="text-5xl font-bold">Tableau de Bord</h1>
            <p className="py-6">Vue d'ensemble de votre activité</p>
          </div>
        </div>
      </div>

      {/* Widgets Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {widgets.map((w) => {
          switch (w.widget.type) {
            case 'stat':
              return <StatWidget key={w.widget.code} widget={w.widget} data={w.data} />;
            case 'chart':
              return <ChartWidget key={w.widget.code} widget={w.widget} data={w.data} />;
            case 'table':
              return <TableWidget key={w.widget.code} widget={w.widget} data={w.data} />;
            default:
              return null;
          }
        })}
      </div>
    </div>
  );
};
```

---

## 🌓 Dark Mode

### Toggle Dark Mode

```tsx
// components/ThemeToggle.tsx
import React from 'react';
import { Sun, Moon } from 'lucide-react';

export const ThemeToggle: React.FC = () => {
  const [theme, setTheme] = React.useState<'light' | 'dark'>('light');

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
    
    // Optionnel : sauvegarder dans SurrealDB
    // await db.query(`UPDATE studio_config:lyxal SET web_theme = '${newTheme}'`);
  };

  return (
    <label className="swap swap-rotate">
      <input type="checkbox" onChange={toggleTheme} />
      
      {/* Sun icon */}
      <Sun className="swap-on w-6 h-6" />
      
      {/* Moon icon */}
      <Moon className="swap-off w-6 h-6" />
    </label>
  );
};
```

### Sauvegarder le thème dans SurrealDB

```typescript
// Sauvegarder préférence utilisateur
const saveThemePreference = async (theme: string) => {
  await db.query(`
    UPDATE user_preferences SET
      theme = '${theme}'
    WHERE user = $auth.id
  `);
};

// Charger au démarrage
const loadThemePreference = async () => {
  const result = await db.query(`
    SELECT theme FROM user_preferences WHERE user = $auth.id
  `);
  
  if (result?.[0]?.theme) {
    document.documentElement.setAttribute('data-theme', result[0].theme);
  }
};
```

---

## 🎨 Liste Complète des Thèmes DaisyUI

### Thèmes Clairs

- `light` (par défaut)
- `cupcake`
- `bumblebee`
- `emerald`
- `corporate`
- `retro`
- `cyberpunk`
- `valentine`
- `garden`
- `aqua`
- `lofi`
- `pastel`
- `fantasy`
- `wireframe`
- `cmyk`
- `autumn`
- `acid`
- `lemonade`
- `winter`

### Thèmes Sombres

- `dark` (par défaut)
- `synthwave`
- `halloween`
- `forest`
- `black`
- `luxury`
- `dracula`
- `business`
- `night`
- `coffee`

---

## 🎯 Changement Instantané de Thème

### Depuis l'Admin

```surql
-- Admin change le thème de BatiPro
UPDATE studio_config:batipro SET
  web_theme = "dark";

-- Tous les utilisateurs de BatiPro passent en dark mode instantanément ! 🌙
```

### Avec LIVE QUERY

```typescript
// Frontend écoute les changements
const liveQuery = await db.live(
  `SELECT * FROM studio_config WHERE tenant_id = 'batipro'`,
  (update) => {
    if (update.action === 'UPDATE' && update.result.web_theme) {
      // Appliquer le nouveau thème instantanément
      document.documentElement.setAttribute('data-theme', update.result.web_theme);
    }
  }
);
```

**Résultat** : Changement de thème en temps réel pour tous les utilisateurs ! ⚡

---

## 📊 Comparaison avec Alternatives

| Aspect | CSS Pur | Material-UI | DaisyUI + Lyxal |
|--------|---------|-------------|-----------------|
| **Composants** | ❌ À créer | ✅ 50+ | ✅ 50+ |
| **Thèmes** | ⚠️ Manuel | ✅ ThemeProvider | ✅✅ DB-Driven |
| **Dark Mode** | ⚠️ Code CSS | ✅ Hook | ✅ Attribut HTML |
| **Performance** | ✅✅ Excellent | ⚠️ JS lourd | ✅✅ CSS pur |
| **Pilotage DB** | ❌ Non | ❌ Non | ✅✅ Natif |
| **White-Label** | ⚠️ Complexe | ⚠️ Config | ✅ 1 UPDATE DB |

---

## 💡 Bonnes Pratiques

### 1. Utiliser les Variables CSS

```typescript
// Accéder aux couleurs du thème en JavaScript
const primaryColor = getComputedStyle(document.documentElement)
  .getPropertyValue('--p');
```

### 2. Composants Cohérents

```tsx
// Toujours utiliser les classes DaisyUI
<button className="btn btn-primary">Créer</button>  // ✅ Bon
<button style={{ background: '#3B82F6' }}>Créer</button>  // ❌ Mauvais
```

### 3. Responsive Design

```tsx
// DaisyUI est responsive par défaut
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* Widgets */}
</div>
```

### 4. Accessibilité

DaisyUI respecte les standards d'accessibilité :
- Contraste suffisant
- Focus visible
- ARIA labels
- Keyboard navigation

---

## 🚀 Résultat Final

**DaisyUI + Lyxal Studio = UI parfaite en quelques lignes** ! 🎨

**Avantages** :
- ✅ 50+ composants prêts
- ✅ 33 thèmes prédéfinis
- ✅ White-Label instantané (UPDATE DB)
- ✅ Dark mode natif
- ✅ Performance optimale (CSS pur)
- ✅ Maintenance minimale

---

## 🔗 Ressources

- [Documentation DaisyUI](https://daisyui.com)
- [Tous les thèmes DaisyUI](https://daisyui.com/docs/themes/)
- [Composants DaisyUI](https://daisyui.com/components/)
- [Tailwind CSS](https://tailwindcss.com)

---

**Lyxal Studio + DaisyUI : Beautiful UI, Database-Driven** 🎨✨


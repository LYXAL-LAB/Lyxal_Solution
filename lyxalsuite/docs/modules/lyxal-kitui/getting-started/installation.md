# 📦 Installation LyxalKitUI - Guide Complet
*Guide unifié pour l'installation et la configuration de LyxalKitUI dans l'écosystème LyxalSuite*

---

## ⚠️ Note importante : Bibliothèque interne

**LyxalKitUI n'est PAS publié sur npm** - c'est une bibliothèque interne de l'écosystème LyxalSuite.

---

## 🚀 Installation

### 📁 Option 1: Workspace Monorepo (Recommandé)

**Pour l'écosystème LyxalSuite avec workspaces :**

```json
// package.json racine de LyxalSuite
{
  "name": "lyxalsuite",
  "workspaces": [
    "lyxalkitui",
    "lyxalauth", 
    "lyxalcrm",
    "lyxalanalytics",
    "generated-saas/*"
  ]
}
```

```json
// package.json de l'application SaaS
{
  "name": "my-generated-saas",
  "dependencies": {
    "@lyxal/ui-kit": "workspace:*",
    "daisyui": "^5.0.0",
    "tailwindcss": "^4.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
```

Installation :
```bash
# À la racine de LyxalSuite
npm install

# L'application SaaS aura automatiquement accès à LyxalKitUI
cd generated-saas/my-saas
npm run dev
```

### 🔗 Option 2: Linking en développement

```bash
# 1. Dans le dossier lyxalkitui, créer le lien
cd lyxalsuite/lyxalkitui
npm run build  # Important : builder d'abord
npm link

# 2. Dans votre application SaaS, utiliser le lien
cd ../my-saas-app
npm link @lyxal/ui-kit

# 3. Installer DaisyUI
npm install daisyui@5 tailwindcss@4
```

### 📂 Option 3: Dépendance locale

```bash
# Dans votre application SaaS
npm install ../lyxalkitui
# ou
npm install file:../lyxalkitui

# Installer DaisyUI 5 séparément
npm install daisyui@5 tailwindcss@4
```

### 🛠️ Build de LyxalKitUI

Avant d'utiliser LyxalKitUI, assurez-vous qu'il est buildé :

```bash
# Dans lyxalsuite/lyxalkitui
cd lyxalsuite/lyxalkitui
npm install
npm run build

# Le dossier dist/ contiendra les fichiers compilés
```

## ⚙️ Configuration de base

### 1. Importer les styles

Dans votre fichier principal (`main.tsx`, `App.tsx` ou `index.tsx`) :

```tsx
import '@lyxal/ui-kit/dist/style.css';
```

### 2. Configuration basique

```tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import '@lyxal/ui-kit/dist/style.css';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

## 🎨 Configuration Tailwind CSS

Si vous utilisez Tailwind CSS dans votre projet, intégrez notre configuration :

### tailwind.config.js
```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
    './node_modules/@lyxal/ui-kit/dist/**/*.{js,ts,jsx,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: 'var(--primary-50)',
          100: 'var(--primary-100)',
          200: 'var(--primary-200)',
          300: 'var(--primary-300)',
          400: 'var(--primary-400)',
          500: 'var(--primary-500)',
          600: 'var(--primary-600)',
          700: 'var(--primary-700)',
          800: 'var(--primary-800)',
          900: 'var(--primary-900)',
        },
        secondary: {
          50: 'var(--secondary-50)',
          100: 'var(--secondary-100)',
          200: 'var(--secondary-200)',
          300: 'var(--secondary-300)',
          400: 'var(--secondary-400)',
          500: 'var(--secondary-500)',
          600: 'var(--secondary-600)',
          700: 'var(--secondary-700)',
          800: 'var(--secondary-800)',
          900: 'var(--secondary-900)',
        },
        accent: {
          50: 'var(--accent-50)',
          100: 'var(--accent-100)',
          200: 'var(--accent-200)',
          300: 'var(--accent-300)',
          400: 'var(--accent-400)',
          500: 'var(--accent-500)',
          600: 'var(--accent-600)',
          700: 'var(--accent-700)',
          800: 'var(--accent-800)',
          900: 'var(--accent-900)',
        }
      },
      borderRadius: {
        'theme': 'var(--radius)',
      },
      fontFamily: {
        'theme': 'var(--font-family)',
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
```

## 🎯 Configuration TypeScript

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

## 🌟 Configuration avec Next.js

### next.config.js
```js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  transpilePackages: ['@lyxal/ui-kit'],
}

module.exports = nextConfig
```

### Configuration des styles dans Next.js

Dans `app/globals.css` ou `pages/_app.tsx` :
```css
@import '@lyxal/ui-kit/dist/style.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## 🔧 Configuration avec Vite

### vite.config.ts
```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  optimizeDeps: {
    include: ['@lyxal/ui-kit']
  }
})
```

## 📱 Configuration pour React Native

⚠️ **Note** : LyxalKitUI est actuellement conçu pour les applications web React. Le support React Native est prévu pour une version future.

## 🎨 Initialisation des thèmes

```tsx
import { initThemeRegistry, applyTheme } from '@lyxal/ui-kit';

// Dans votre App.tsx ou main.tsx
function App() {
  useEffect(() => {
    // Initialiser le registre de thèmes
    initThemeRegistry();
    
    // Appliquer un thème par défaut
    applyTheme('dracula');
  }, []);

  return <YourApp />;
}
```

## 🚦 Vérification de l'installation

Créez un composant de test pour vérifier que tout fonctionne :

```tsx
import { Button, Input, Badge } from '@lyxal/ui-kit';

function TestComponent() {
  return (
    <div className="p-8 space-y-4">
      <h1 className="text-2xl font-bold">Test LyxalKitUI</h1>
      
      <div className="space-y-2">
        <Input label="Email" type="email" placeholder="test@example.com" />
        <Button variant="primary" size="lg">
          Tester le bouton
        </Button>
        <Badge variant="success">Installation réussie ✓</Badge>
      </div>
    </div>
  );
}

export default TestComponent;
```

## 🔍 Dépendances

### Dépendances requises
- `react` >= 18.0.0
- `react-dom` >= 18.0.0

### Dépendances recommandées
- `tailwindcss` >= 3.3.0
- `@tailwindcss/forms` (pour les composants de formulaire)
- `typescript` >= 5.0.0 (pour le support TypeScript)

## 🐛 Résolution des problèmes courants

### Erreur : "Module not found: Can't resolve '@lyxal/ui-kit'"
**Solution** : Vérifiez que le package est correctement installé :
```bash
npm list @lyxal/ui-kit
```

### Erreur : Styles CSS non appliqués
**Solution** : Assurez-vous d'importer les styles CSS :
```tsx
import '@lyxal/ui-kit/dist/style.css';
```

### Erreur : Types TypeScript manquants
**Solution** : Redémarrez votre serveur de développement et l'IDE :
```bash
npm run dev
# ou
yarn dev
```

### Erreur : Conflit avec Tailwind CSS
**Solution** : Vérifiez la configuration Tailwind et assurez-vous que les chemins sont corrects.

## 📈 Optimisation des performances

### Tree-shaking
LyxalKitUI supporte le tree-shaking automatiquement. Importez seulement les composants nécessaires :

```tsx
// ✅ Bon - import spécifique
import { Button } from '@lyxal/ui-kit';

// ❌ Éviter - import global
import * as LyxalUI from '@lyxal/ui-kit';
```

### Lazy loading
Pour les gros composants, utilisez le lazy loading :

```tsx
import { lazy, Suspense } from 'react';

const DataTable = lazy(() => import('@lyxal/ui-kit').then(module => ({ 
  default: module.DataTable 
})));

function MyComponent() {
  return (
    <Suspense fallback={<div>Chargement...</div>}>
      <DataTable data={data} columns={columns} />
    </Suspense>
  );
}
```

## ✅ Prochaines étapes

1. [**Guide de démarrage rapide**](./quick-start.md) - Premiers pas avec les composants
2. [**Système de thèmes**](./themes.md) - Personnaliser l'apparence
3. [**Référence des composants**](./components/basic.md) - Explorer tous les composants

---

**Besoin d'aide ?** Consultez nos [exemples d'intégration](./examples.md) ou ouvrez une issue sur GitHub. 
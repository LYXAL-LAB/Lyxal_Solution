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

---

## ⚙️ Configuration

### 🛠️ Build de LyxalKitUI

Avant d'utiliser LyxalKitUI, assurez-vous qu'il est buildé :

```bash
# Dans lyxalsuite/lyxalkitui
cd lyxalsuite/lyxalkitui
npm install
npm run build

# Le dossier dist/ contiendra les fichiers compilés
```

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

---

## 🎨 Configuration Tailwind CSS v4 + DaisyUI 5

### tailwind.config.js
```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
    // ⚠️ Adapter le chemin selon votre option d'installation :
    '../lyxalkitui/dist/**/*.{js,ts,jsx,tsx}',        // Si workspace
    './node_modules/@lyxal/ui-kit/dist/**/*.{js,ts,jsx,tsx}' // Si npm link
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
        }
      }
    }
  },
  plugins: [
    require('daisyui')
  ],
  
  // Configuration DaisyUI 5
  daisyui: {
    themes: [
      // Thèmes clairs
      "light", "cupcake", "bumblebee", "emerald", "corporate", 
      "retro", "valentine", "garden", "aqua", "lofi", "pastel", 
      "fantasy", "wireframe", "luxury", "cmyk", "autumn", 
      "business", "acid", "lemonade", "coffee", "winter", "nord",
      
      // Thèmes sombres  
      "dark", "synthwave", "halloween", "forest", "black", 
      "dracula", "night", "dim", "sunset", "cyberpunk"
    ],
    darkTheme: "dark",
    base: true,
    styled: true,
    utils: true,
    prefix: "",
    logs: true,
    themeRoot: ":root"
  }
}
```

### Configuration des styles

```css
/* src/theme/globals.css */
@import "tailwindcss";
@plugin "daisyui";

/* Configuration DaisyUI 5 */
:root {
  /* Animations */
  --animation-btn: 0.25s;
  --animation-input: 0.2s;
  
  /* Boutons */
  --btn-focus-scale: 0.95;
  --border-btn: 1px;
  
  /* Rayons personnalisés */
  --rounded-box: 1rem;
  --rounded-btn: 0.5rem;
  --rounded-badge: 1.9rem;
}

/* Styles personnalisés pour LyxalSuite */
.lyxal-gradient {
  background: linear-gradient(135deg, hsl(var(--primary)) 0%, hsl(var(--secondary)) 100%);
}

.lyxal-card {
  @apply card bg-base-100 shadow-xl border border-base-300;
}

.lyxal-btn {
  @apply btn btn-primary;
}

/* Animations personnalisées */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in-up {
  animation: fadeInUp 0.6s ease-out;
}
```

---

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
      "@/*": ["./src/*"],
      "@lyxal/ui-kit": ["../lyxalkitui/src"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

---

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

---

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
      '@lyxal/ui-kit': path.resolve(__dirname, '../lyxalkitui/src')
    },
  },
  optimizeDeps: {
    include: ['@lyxal/ui-kit']
  }
})
```

---

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

---

## 🧪 Test de l'installation

Créez un composant de test pour vérifier que tout fonctionne :

```tsx
// src/components/TestInstallation.tsx
import { Button, Input, Badge } from '@lyxal/ui-kit';

export function TestInstallation() {
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
      
      {/* Test DaisyUI */}
      <div className="lyxal-card">
        <div className="card-body">
          <h2 className="card-title">Test DaisyUI</h2>
          <p>Si vous voyez cette carte avec styles, DaisyUI fonctionne !</p>
          <div className="card-actions justify-end">
            <button className="lyxal-btn">Action</button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

Puis utilisez-le dans votre App :
```tsx
// App.tsx
import { TestInstallation } from './components/TestInstallation';

function App() {
  return (
    <div className="min-h-screen bg-base-100">
      <TestInstallation />
    </div>
  );
}

export default App;
```

---

## 🔍 Dépendances

### Dépendances requises
- `react` >= 18.0.0
- `react-dom` >= 18.0.0
- `daisyui` >= 5.0.0
- `tailwindcss` >= 4.0.0

### Dépendances recommandées
- `@tailwindcss/forms` (pour les composants de formulaire)
- `typescript` >= 5.0.0 (pour le support TypeScript)
- `react-router-dom` >= 6.0.0 (pour la navigation)

---

## 🐛 Résolution des problèmes courants

### Erreur : "Module not found: Can't resolve '@lyxal/ui-kit'"
**Solutions** :
1. Vérifiez que LyxalKitUI est buildé : `cd lyxalkitui && npm run build`
2. Vérifiez le workspace : `npm list @lyxal/ui-kit`
3. Relancez l'installation : `npm install`

### Erreur : Styles CSS non appliqués
**Solutions** :
1. Vérifiez l'import CSS : `import '@lyxal/ui-kit/dist/style.css';`
2. Vérifiez la configuration Tailwind
3. Redémarrez le serveur de développement

### Erreur : Types TypeScript manquants
**Solutions** :
1. Vérifiez que `dist/index.d.ts` existe
2. Redémarrez TypeScript : Ctrl+Shift+P → "TypeScript: Restart TS Server"
3. Vérifiez le chemin dans `tsconfig.json`

### Erreur : DaisyUI ne fonctionne pas
**Solutions** :
1. Vérifiez la version DaisyUI : `npm list daisyui`
2. Vérifiez la configuration dans `tailwind.config.js`
3. Assurez-vous que le plugin est bien ajouté : `plugins: [require('daisyui')]`

---

## 📈 Optimisation des performances

### Tree-shaking
LyxalKitUI supporte le tree-shaking automatiquement. Importez seulement les composants nécessaires :

```tsx
// ✅ Bon - import spécifique
import { Button, Input } from '@lyxal/ui-kit';

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

---

## ✅ Checklist installation

- [ ] **Build LyxalKitUI** : `npm run build` dans lyxalkitui
- [ ] **Installation** : workspace, link ou dépendance locale
- [ ] **Styles CSS** : import de `@lyxal/ui-kit/dist/style.css`
- [ ] **Configuration Tailwind** : chemins et plugin DaisyUI
- [ ] **Configuration TypeScript** : paths et types
- [ ] **Test d'installation** : composant de test fonctionnel
- [ ] **DaisyUI** : thèmes et styles appliqués

---

## 🎯 Prochaines étapes

1. [**Guide de démarrage rapide**](./quick-start.md) - Premiers pas avec les composants
2. [**Architecture Frontend**](../architecture/architecture-unified.md) - Comprendre l'architecture
3. [**Système de thèmes**](./themes.md) - Personnaliser l'apparence
4. [**Référence des composants**](../components/basic.md) - Explorer tous les composants

---

**🔗 Installation locale LyxalKitUI - Prêt pour le développement !** 
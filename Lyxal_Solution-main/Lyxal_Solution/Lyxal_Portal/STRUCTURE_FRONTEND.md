# 📁 Structure du Frontend Actuel - Lyxal Portal

**Localisation principale :** `Lyxal_Solution/Lyxal_Portal/`

---

## 🎯 Vue d'Ensemble

Le frontend est un projet **React + TypeScript + Vite** utilisant :
- ✅ **Tailwind CSS** (via `@tailwindcss/vite`)
- ✅ **DaisyUI** (composants UI prêts à l'emploi)
- ✅ **React Router** (déclaré mais utilise un router custom)
- ✅ **Zustand** (state management)
- ✅ **Lucide React** (icônes)
- ✅ **Vitest** (tests)

---

## 📂 Structure des Répertoires

```
Lyxal_Portal/
├── src/
│   ├── main.tsx                    ← Point d'entrée (AppRouter)
│   ├── AppRouter.tsx               ← Router custom (pas react-router-dom)
│   ├── App.tsx                     ← Page Dashboard principale
│   ├── index.css                   ← Styles globaux (Tailwind + DaisyUI)
│   │
│   ├── pages/                      ← Pages de l'application
│   │   ├── website/
│   │   │   ├── Home.tsx           ← Page d'accueil publique
│   │   │   └── SignIn.tsx         ← Page de connexion
│   │   ├── admin/
│   │   │   └── components/        ← Composants admin
│   │   └── test/
│   │       └── StudioTestPage.tsx ← Page de test Studio Runtime
│   │
│   ├── components/                 ← Composants réutilisables
│   │   ├── app/                   ← Composants application (Dashboard)
│   │   │   ├── Layout.tsx         ← Layout principal (Header + Sidebar + Footer)
│   │   │   ├── Header.tsx        ← Header avec thèmes et menu système
│   │   │   ├── Sidebar.tsx        ← Sidebar navigation
│   │   │   └── Footer.tsx        ← Footer
│   │   ├── website/               ← Composants site public
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Layout.tsx
│   │   └── studio/                ← Composants Studio Runtime (DB-driven)
│   │       ├── StudioComponentRenderer.tsx
│   │       ├── StructureRenderer.tsx
│   │       ├── StudioPageRenderer.tsx
│   │       └── StudioErrorBoundary.tsx
│   │
│   ├── lib/
│   │   └── studio/                ← Studio Runtime (Parser + Hooks + Actions)
│   │       ├── parser/            ← Parser JSON → React
│   │       ├── hooks/             ← useStudioComponent, useStudioPage, etc.
│   │       ├── actions/           ← Actions (navigate, submit, etc.)
│   │       ├── context/            ← ContextManager
│   │       ├── store/              ← Zustand store
│   │       └── types/              ← Types TypeScript
│   │
│   ├── services/                   ← Services métier
│   │   ├── SurrealClient.ts       ← Client SurrealDB
│   │   ├── SystemConfigService.ts ← Configuration système
│   │   ├── I18nService.ts         ← Internationalisation
│   │   ├── IconRegistry.tsx        ← Registre d'icônes
│   │   ├── MenuService.ts         ← Service de menu
│   │   └── EventRunner.ts        ← Gestionnaire d'événements
│   │
│   ├── hooks/                      ← Hooks personnalisés
│   │   ├── useSystemConfig.ts     ← Hook configuration système
│   │   └── usePerformanceMonitor.ts ← Hook monitoring
│   │
│   └── utils/                      ← Utilitaires
│       ├── accessibility.ts        ← Utilitaires accessibilité
│       └── performanceLogger.ts    ← Logger de performance
│
├── vite.config.mjs                 ← Configuration Vite
├── package.json                     ← Dépendances
└── tsconfig.json                    ← Configuration TypeScript
```

---

## 🎨 Système de Styles Actuel

### Configuration CSS (`src/index.css`)

```css
@import "tailwindcss";
@plugin "daisyui" {
  themes: all;
  root: ":root";
  logs: true;
}
```

**Utilisé actuellement :**
- ✅ **Tailwind CSS** (classes utilitaires)
- ✅ **DaisyUI** (composants avec thèmes)
- ✅ **Thèmes DaisyUI** : light, dark, corporate, etc. (via `data-theme`)

**Classes utilisées dans les composants :**
- `btn`, `btn-primary`, `btn-ghost` (DaisyUI)
- `card`, `card-body`, `card-title` (DaisyUI)
- `navbar`, `dropdown`, `badge` (DaisyUI)
- Classes Tailwind : `flex`, `grid`, `p-6`, `text-3xl`, etc.

**Gestion des thèmes :**
- Thèmes DaisyUI appliqués via `document.documentElement.setAttribute('data-theme', theme)`
- Thème par défaut depuis `SystemConfigService` → `config.identity.themeParDefaut`
- Sauvegarde dans `localStorage` (`lyxal-theme`)

---

## 🔧 Composants Clés à Connaître

### 1. Layout (`components/app/Layout.tsx`)
- **Rôle :** Orchestre Header + Sidebar + Footer + Contenu
- **Fonctionnalités :**
  - Gestion du thème (DaisyUI)
  - Responsive sidebar
  - Accessibilité (ARIA)
  - Performance monitoring
- **Props :** `children`, `initialTheme`, `initialSidebarOpen`, `onThemeChange`

### 2. Header (`components/app/header/Header.tsx`)
- **Rôle :** Navigation principale + Sélecteur de thème + Menu système
- **Fonctionnalités :**
  - Sélecteur de thème DaisyUI (dropdown)
  - Menu système (Console Admin, Configuration, etc.)
  - Breadcrumb
  - Toggle sidebar mobile
- **Utilise :** `useSystemConfig()` pour le nom de plateforme

### 3. Home (`pages/website/Home.tsx`)
- **Rôle :** Page d'accueil publique
- **Style :** Classes DaisyUI (`hero`, `card`, `btn`, etc.)
- **Structure :** Hero section + Features + CTA

### 4. App (`App.tsx`)
- **Rôle :** Dashboard principal (LYXAL Master Console)
- **Style :** Cards DaisyUI avec grid
- **Contenu :** Statut système, Investisseurs, Plateformes

---

## 🔌 Services Existants

### SurrealClient (`services/SurrealClient.ts`)
- Client SurrealDB pour requêtes DB

### SystemConfigService (`services/SystemConfigService.ts`)
- Récupère la configuration système depuis SurrealDB
- Fournit : `identity`, `themeParDefaut`, `platformName`, etc.

### I18nService (`services/I18nService.ts`)
- Gestion de l'internationalisation

### IconRegistry (`services/IconRegistry.tsx`)
- Registre d'icônes (probablement Lucide React)

---

## 🎯 Système de Rendu Actuel

### Pages Normales (Hardcodées)
- ✅ `Home.tsx` → JSX hardcodé
- ✅ `App.tsx` → JSX hardcodé
- ✅ `SignIn.tsx` → JSX hardcodé

### Pages DB-Driven (Studio Runtime)
- ✅ `StudioTestPage.tsx` → Utilise `StudioPageRenderer`
- ✅ Charge depuis `studio_page:test_page` dans SurrealDB
- ✅ Rendu 100% depuis JSON de la DB

---

## 📝 Points Importants pour le Rendu

### 1. **Classes CSS Utilisées**
Actuellement, les composants utilisent :
- **DaisyUI** : `btn`, `card`, `navbar`, `dropdown`, `badge`
- **Tailwind** : Classes utilitaires (`flex`, `grid`, `p-6`, etc.)

### 2. **Thèmes**
- Gérés par DaisyUI via `data-theme`
- Thèmes disponibles : `light`, `dark`, `corporate`, `cupcake`, etc.
- Application : `document.documentElement.setAttribute('data-theme', theme)`

### 3. **Responsive**
- Sidebar : Masquée sur mobile (`lg:hidden`)
- Grid : `grid-cols-1 md:grid-cols-2 lg:grid-cols-3`

### 4. **Accessibilité**
- Labels ARIA partout
- `announceToScreenReader()` pour lecteurs d'écran
- Gestion du focus

---

## 🚀 Prochaines Étapes

Pour améliorer le rendu DB-driven, vous pouvez m'indiquer :

1. **Quels composants DaisyUI utiliser ?**
   - `btn`, `card`, `input`, `modal`, etc.
   - Classes à générer depuis la DB

2. **Structure de rendu souhaitée ?**
   - Comment organiser les composants dans `studio_component.structure`
   - Comment mapper les classes CSS

3. **Intégration avec les thèmes ?**
   - Utiliser les thèmes DaisyUI existants
   - Ou connecter au système de thèmes DB (`theme`, `theme_color`)

4. **Responsive et accessibilité ?**
   - Comment gérer dans les structures DB
   - Classes responsive à générer

---

**Fichier créé le :** 2025-01-31
**Dernière mise à jour :** 2025-01-31


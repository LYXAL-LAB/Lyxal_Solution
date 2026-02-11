# 🔗 Intégration Réelle - Lyxal Studio Runtime

Ce document explique comment intégrer le **Lyxal Studio Runtime** dans vos applications **React (Web)** et **React Native (Mobile)**.

**⚠️ IMPORTANT : Cette documentation décrit l'implémentation actuelle, pas une spécification future.**

---

## 📋 Table des Matières

1. [Installation](#-installation)
2. [Configuration SurrealDB](#-configuration-surrealdb)
3. [Utilisation des Composants](#-composants-db-driven)
4. [Utilisation des Pages](#-pages-db-driven)
5. [Hooks et State Management](#-hooks-et-state)
6. [Architecture Modulaire](#-architecture-modulaire)
7. [Intégration Mobile](#-react-native)
8. [Dépannage](#-dépannage)

---

## 📦 Installation

### Dépendances Requises

```bash
# Dépendances principales
npm install surrealdb.js
npm install zustand react-router-dom @tanstack/react-virtual

# Pour le développement
npm install --save-dev typescript vitest @testing-library/react
```

### Structure du Projet Réel

```
your-app/
├── src/
│   ├── lib/
│   │   └── studio/
│   │       ├── parser/
│   │       │   ├── index.ts
│   │       │   ├── resolveTemplate.ts
│   │       │   ├── resolveProps.ts
│   │       │   ├── createReactElement.ts
│   │       │   └── types/
│   │       │       └── component.ts
│   │       ├── hooks/
│   │       │   ├── useStudioComponent.ts
│   │       │   ├── useStudioPage.ts
│   │       │   └── useActionHandler.ts
│   │       ├── context/
│   │       │   └── ContextManager.ts
│   │       └── store/
│   │           └── useStudioState.ts
│   ├── components/
│   │   └── studio/
│   │       ├── StudioComponentRenderer.tsx
│   │       ├── StudioPageRenderer.tsx
│   │       ├── StructureRenderer.tsx
│   │       └── index.ts
│   ├── services/
│   │   └── SurrealClient.ts
│   └── App.tsx
```

---

## 🔌 Configuration SurrealDB

### Service SurrealClient

Utilisez le `SurrealClient` existant pour la connexion :

```typescript
// services/SurrealClient.ts
import Surreal from 'surrealdb.js';

export class SurrealClient {
  static async query<T>(
    config: SystemConfig,
    query: string,
    vars?: Record<string, any>
  ): Promise<T[]> {
    const db = new Surreal();
    try {
      await db.connect(config.surreal.endpoint);
      await db.use(config.surreal.namespace, config.surreal.database);
      await db.signin(config.surreal.auth);

      const result = await db.query(query, vars);
      return result as T[];
    } finally {
      await db.close();
    }
  }
}
```

### Hook `useSystemConfig`

Utilisez le hook pour accéder à la configuration :

```typescript
// Dans votre App.tsx
import { useSystemConfig } from '@/hooks/useSystemConfig';

function App() {
  const { config, loading, error } = useSystemConfig();

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <StudioProvider config={config}>
      {/* Votre application */}
    </StudioProvider>
  );
}
```

---

## 🔧 Composants DB-Driven

### `StudioComponentRenderer` - Rendu de Composants

Le composant principal pour rendre des composants définis en DB :

```typescript
import { StudioComponentRenderer } from '@/components/studio';

function MyComponent() {
  return (
    <StudioComponentRenderer
      code="button"
      props={{
        label: "Cliquez-moi",
        variant: "primary",
        disabled: false
      }}
    />
  );
}
```

### `StudioPageRenderer` - Rendu de Pages

Pour rendre des pages complètes définies en DB :

```typescript
import { StudioPageRenderer } from '@/components/studio';

function MyPage() {
  return <StudioPageRenderer pageCode="dashboard" />;
}
```

### `StructureRenderer` - Rendu de Structures Complexes

Pour des structures imbriquées personnalisées :

```typescript
import { StructureRenderer } from '@/components/studio';

const customStructure = {
  type: "div",
  props: { className: ["container"] },
  children: [
    { type: "component", component: "header", props: { title: "Test" } }
  ]
};

function MyCustomComponent() {
  return (
    <StructureRenderer
      structure={customStructure}
      componentProps={{}}
    />
  );
}
```

---

## 🎣 Hooks et State Management

### `useStudioComponent` - Chargement de Composants

Hook principal pour charger un composant depuis la DB :

```typescript
import { useStudioComponent } from '@/lib/studio/hooks/useStudioComponent';

function MyComponent() {
  const { component, loading, error, refetch } = useStudioComponent('button');

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!component) return null;

  // Utiliser component.structure avec le parser
  return <StudioComponentRenderer code="button" />;
}
```

### `useStudioPage` - Chargement de Pages

Hook pour charger une page complète :

```typescript
import { useStudioPage } from '@/lib/studio/hooks/useStudioPage';

function MyPage() {
  const { page, loading, error } = useStudioPage('dashboard');

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!page) return null;

  return <StudioPageRenderer pageCode="dashboard" />;
}
```

### `useStudioState` - State Global

Gestion de l'état partagé entre composants :

```typescript
import { useStudioState } from '@/lib/studio/store/useStudioState';

function MyComponent() {
  const globalState = useStudioState((state: any) => state.state);

  // Accéder aux variables globales
  const selectedItem = globalState.selectedItem;
}
```

### `useActionHandler` - Gestion des Actions

Hook pour exécuter les actions définies dans les composants :

```typescript
import { useActionHandler } from '@/lib/studio/hooks/useActionHandler';

function MyComponent() {
  const { handleAction } = useActionHandler();

  const onButtonClick = (actionDef: any) => {
    handleAction(actionDef);
  };
}
```

---

## 🏗️ Architecture Modulaire

Le système Lyxal Studio Runtime suit une architecture modulaire :

### Parser TypeScript

```typescript
// lib/studio/parser/
├── index.ts              // Point d'entrée parseComponent()
├── resolveTemplate.ts    // Résolution des {{variables}}
├── resolveProps.ts       // Fusion des props
├── resolveChildren.ts    // Parsing récursif des enfants
├── createReactElement.ts // Création des éléments React
└── types/component.ts    // Interfaces TypeScript
```

### Gestion d'État

```typescript
// lib/studio/store/
└── useStudioState.ts     // Store Zustand global

// lib/studio/context/
└── ContextManager.ts     // Fusion des contextes
```

### Hooks Utilisateur

```typescript
// lib/studio/hooks/
├── useStudioComponent.ts // Chargement DB composants
├── useStudioPage.ts      // Chargement DB pages
└── useActionHandler.ts   // Exécution des actions
```

### Composants React

```typescript
// components/studio/
├── StudioComponentRenderer.tsx  // Rendu composants DB
├── StudioPageRenderer.tsx       // Rendu pages DB
├── StructureRenderer.tsx        // Rendu structures complexes
└── index.ts                     // Exports
```

---

## 📱 React Native (Mobile)

### Installation

```bash
npm install surrealdb.js
npm install @react-native-async-storage/async-storage
npm install zustand react-navigation
```

### Utilisation

```typescript
import { StudioComponentRenderer } from '@/components/studio';

// Même API qu'en Web
<StudioComponentRenderer
  code="mobile_button"
  props={{ label: "Touch me" }}
/>
```

### Différences avec le Web

- Pas de DaisyUI (utiliser React Native Paper ou NativeBase)
- Icônes : `react-native-vector-icons` au lieu de Lucide
- Navigation : React Navigation au lieu de React Router

---

## 🔧 Dépannage

### Composant ne se charge pas

```typescript
// Vérifier que le composant existe
const { component, error } = useStudioComponent('my_component');
console.log('Component:', component);
console.log('Error:', error);
```

### Parser échoue

```typescript
// Vérifier la structure JSON
const structure = component.structure;
console.log('Structure valide:', structure.type && structure.props);
```

### Actions ne fonctionnent pas

```typescript
// Vérifier que useActionHandler est utilisé
const { handleAction } = useActionHandler();

// Vérifier la définition d'action
const actionDef = {
  type: "action",
  action: "navigate",
  params: { url: "/dashboard" }
};
```

### Problèmes de performance

```typescript
// Utiliser React.memo pour les composants lourds
const MyHeavyComponent = React.memo(({ props }) => {
  // Logique coûteuse
  return <div>{/* rendu */}</div>;
});
```

---

## 📚 Références

- **[STUDIO_COMPONENT_SCHEMA.md](../runtime/STUDIO_COMPONENT_SCHEMA.md)** - Schéma complet composants
- **[STUDIO_PAGE_SCHEMA.md](../runtime/STUDIO_PAGE_SCHEMA.md)** - Schéma complet pages
- **[DATABASE.md](../database/DATABASE.md)** - Tous les schémas DB
- **[ARCHITECTURE.md](../architecture/ARCHITECTURE.md)** - Vue d'ensemble système

---

**Cette documentation décrit l'intégration réelle du Lyxal Studio Runtime.**

# 📘 Documentation Technique — Améliorations du Système de Rendu Contrôlé (DB → React)

Ce document complète le guide "Système de Rendu Contrôlé pour Composants DB".

Il précise les points de correction, optimisations structurelles, et bonnes pratiques pour rendre le moteur plus modulaire, stable et évolutif dans l'écosystème LYXAL.

---

## 🧩 Contexte

Ce document détaille les améliorations architecturales nécessaires pour transformer le système de rendu contrôlé en un **moteur production-ready** et extensible.

**Objectif** : Passer d'un prototype fonctionnel à un système robuste, testable et évolutif.

---

## 🏗️ Préambule : Architecture Globale du Lyxal Studio Runtime

Le **Lyxal Studio Runtime** est le moteur de rendu au cœur du système LYXAL Studio. Il transforme des **définitions JSON stockées dans SurrealDB** en **composants React sécurisés, dynamiques et multi-tenant**.

### Vision Système

Ce moteur fait partie intégrante du **Builder LYXAL** : il permet de déployer des interfaces métiers et des applications entières à partir de structures de données, sans aucune ligne de code frontend en dur.

**Principe fondamental** : 100% Database-Driven UI

- Les **composants UI** sont définis en JSON dans SurrealDB
- Les **pages** sont décrites comme des templates JSON
- Les **actions** (navigation, submit, etc.) sont déclarées en DB
- React ne fait qu'**interpréter et rendre** ces structures dynamiquement

### Positionnement dans l'Écosystème LYXAL

```
Lyxal Studio Runtime
    ↓
    └─> Génère dynamiquement les interfaces
            ↓
    Intègre avec :
    - Lyxal Identity (authentification)
    - Lyxal Mail (formulaires email)
    - Modules Business (CRM, Sales, etc.)
```

**Résultat** : Un seul codebase React peut servir **N tenants** avec des interfaces complètement différentes, configurées uniquement depuis SurrealDB.

---

## 📦 Prérequis : Dépendances NPM

Avant d'implémenter le Lyxal Studio Runtime, installer les dépendances suivantes :

### Dépendances Requises

```bash
npm install zustand react-router-dom @tanstack/react-virtual
```

- **zustand** : State management léger pour le StateManager
- **react-router-dom** : Navigation et routing
- **@tanstack/react-virtual** : Virtual scrolling pour grandes listes

### Dépendances de Développement (Optionnel mais Recommandé)

```bash
npm install --save-dev typescript @types/react @types/react-dom vitest @testing-library/react
```

- **typescript** : Typage statique
- **@types/react** : Types TypeScript pour React
- **vitest** : Framework de tests (ou Jest)
- **@testing-library/react** : Tests des composants React

### SurrealDB Client

```bash
npm install surrealdb.js
```

- **surrealdb.js** : Client JavaScript pour SurrealDB

---

## 1. 🧱 Découpage du ComponentParser en Pipeline Modulaire

### 🎯 Objectif

Rendre le parser plus lisible, testable, et extensible, en séparant clairement les responsabilités internes :

- Résolution des templates
- Résolution des props
- Application des variants
- Création du composant React final

### ✅ Nouvelle Architecture Suggérée

```
lib/studio/parser/
│
├── resolveTemplate.ts        → remplace les {{props.x}} et {{page.y}}
├── resolveProps.ts           → fusionne et résout les props d'un composant
├── resolveChildren.ts        → parse récursivement les children
├── applyVariants.ts          → applique les variants CSS et styles
├── createReactElement.ts     → assemble le composant final
└── index.ts                  → exporte le pipeline complet
```

### 🧠 Implémentation

#### `resolveTemplate.ts`

```typescript
/**
 * Résout un template string avec le contexte donné
 * Ex: "{{page.title.fr}}" → "Liste des Contacts"
 */
export const resolveTemplate = (
  template: string,
  context: Record<string, any>
): string => {
  if (!template || typeof template !== 'string') return template;
  
  return template.replace(/\{\{([^}]+)\}\}/g, (match, path) => {
    const keys = path.split('.');
    let value: any = context;
    
    for (const key of keys) {
      value = value?.[key];
      if (value === undefined) break;
    }
    
    return value ?? match;
  });
};
```

#### `resolveProps.ts`

```typescript
/**
 * Résout et fusionne les props d'un composant
 */
export const resolveProps = (
  structureProps: Record<string, any>,
  componentProps: Record<string, any>,
  context: Record<string, any>
): Record<string, any> => {
  const resolved: Record<string, any> = {};
  
  // Props de la structure
  Object.entries(structureProps).forEach(([key, value]) => {
    if (typeof value === 'string') {
      resolved[key] = resolveTemplate(value, context);
    } else if (value?.type === 'action') {
      resolved[key] = value; // Action sera résolue plus tard
    } else {
      resolved[key] = resolveTemplate(value, context);
    }
  }));
  
  // Props du composant (prioritaires)
  Object.assign(resolved, componentProps);
  
  return resolved;
};
```

#### `applyVariants.ts`

```typescript
/**
 * Applique les variants et styles selon le variant spécifié
 */
export const applyVariants = (
  component: any,
  variant: string,
  props: Record<string, any>
): Record<string, any> => {
  const variantStyles = component.variants?.[variant] || {};
  
  // Fusionner les classNames
  if (variantStyles.css_classes) {
    const existingClasses = props.className || [];
    props.className = Array.isArray(existingClasses)
      ? [...existingClasses, ...variantStyles.css_classes]
      : [existingClasses, ...variantStyles.css_classes];
  }
  
  // Fusionner les styles inline
  if (variantStyles.css_variables) {
    props.style = {
      ...props.style,
      ...variantStyles.css_variables,
    };
  }
  
  return props;
};
```

#### `resolveChildren.ts`

```typescript
import React from 'react';
import { resolveTemplate } from './resolveTemplate';
import { StructureRenderer } from '@/components/studio/StructureRenderer';

/**
 * Résout récursivement les children
 */
export const resolveChildren = (
  children: any[],
  context: Record<string, any>
): React.ReactNode[] => {
  return children
    .filter((child) => {
      // Filtrer selon conditions
      if (child.condition) {
        const conditionValue = resolveTemplate(child.condition, context);
        return conditionValue === true || conditionValue === 'true';
      }
      return true;
    })
    .map((child, index) => {
      if (child.type === 'text') {
        return (
          <span key={index}>
            {resolveTemplate(child.content, context)}
          </span>
        );
      }
      
      if (child.type === 'component') {
        return (
          <StructureRenderer
            key={index}
            structure={child}
            context={context}
          />
        );
      }
      
      // Élément HTML natif
      const Element = child.type;
      return (
        <Element key={index} {...child.props}>
          {child.children ? resolveChildren(child.children, context) : null}
        </Element>
      );
    });
};
```

#### `createReactElement.ts`

```typescript
import React from 'react';
import { resolveProps } from './resolveProps';
import { applyVariants } from './applyVariants';
import { resolveChildren } from './resolveChildren';

/**
 * Crée un élément React final à partir de la structure
 */
export const createReactElement = (
  structure: any,
  componentProps: Record<string, any>,
  context: Record<string, any>
): React.ReactElement => {
  const props = resolveProps(structure.props || {}, componentProps, context);
  const variant = componentProps.variant || 'primary';
  
  // Appliquer variants
  const propsWithVariant = applyVariants(structure, variant, props);
  
  // Résoudre children
  const children = structure.children
    ? resolveChildren(structure.children, context)
    : null;
  
  // Créer l'élément React
  if (structure.type === 'component') {
    // Composant DB - nécessite StudioComponentRenderer
    return React.createElement(
      'StudioComponentRenderer',
      {
        code: structure.component,
        props: propsWithVariant,
        ...children ? { children } : {},
      }
    );
  }
  
  // Élément HTML natif
  const Element = structure.type;
  return React.createElement(Element, propsWithVariant, children);
};
```

#### `index.ts` - Pipeline Complet

```typescript
import { createReactElement } from './createReactElement';

/**
 * Parse une structure de composant en élément React
 */
export const parseComponent = (
  structure: any,
  props: Record<string, any> = {},
  context: Record<string, any> = {}
): React.ReactElement => {
  return createReactElement(structure, props, context);
};
```

### 🧠 Exemple d'Utilisation

```typescript
import { parseComponent } from '@/lib/studio/parser';

const parsed = parseComponent(structure, props, variant);
return parsed;
```

### 💡 Avantages

- ✅ Code maintenable et facilement auditable
- ✅ Possibilité de tests unitaires par étape
- ✅ Extension future : support des hooks, conditions, boucles, etc.

---

## 2. 🔄 Gestion du State et du Binding Dynamique

### 🎯 Objectif

Permettre aux composants générés depuis la DB de réagir dynamiquement aux entrées utilisateur.

### 🧩 Nouvelle Convention JSON pour le Binding

```json
{
  "type": "input",
  "props": {
    "value": "{{state.search}}",
    "onChange": {
      "type": "state_update",
      "target": "search"
    }
  }
}
```

### 🧠 Implémentation Recommandée

Créer un store global contrôlé dans `lib/studio/store/` (ex : basé sur Zustand ou un simple React.Context).

#### `lib/studio/store/useStudioState.ts`

```typescript
import { create } from 'zustand';

interface StudioState {
  state: Record<string, any>;
  setValue: (key: string, value: any) => void;
  getValue: (key: string) => any;
}

export const useStudioState = create<StudioState>((set, get) => ({
  state: {},
  
  setValue: (key: string, value: any) =>
    set((s) => ({
      state: { ...s.state, [key]: value }
    })),
  
  getValue: (key: string) => {
    const state = get().state;
    const keys = key.split('.');
    let value: any = state;
    
    for (const k of keys) {
      value = value?.[k];
      if (value === undefined) break;
    }
    
    return value;
  },
}));
```

#### Utilisation dans ActionHandler

```typescript
case 'state_update':
  const { setValue } = useStudioState.getState();
  setValue(action.target, args[0].target.value);
  
  // Déclencher re-render si nécessaire
  break;
```

#### Intégration dans StructureRenderer

```typescript
// Dans resolveTemplate, ajouter le contexte state
const contextWithState = {
  ...context,
  state: useStudioState.getState().state,
};

const value = resolveTemplate("{{state.search}}", contextWithState);
```

### 💡 Avantages

- ✅ Composants interactifs sans code en dur
- ✅ State partagé entre composants
- ✅ Binding bidirectionnel (value + onChange)

---

## 3. 🧩 Gestion Centralisée des Contextes Dynamiques

### 🎯 Objectif

Offrir un système cohérent pour résoudre les templates dynamiques (`{{page.title.fr}}`, `{{user.name}}`, `{{row.id}}`, etc.).

### ✅ Solution : ContextManager

#### Structure

```
lib/studio/context/
│
├── ContextManager.ts     → fusionne tous les contextes (page, user, row, etc.)
└── resolveTemplate.ts    → utilise ContextManager pour interpréter les {{...}}
```

#### `ContextManager.ts`

```typescript
interface ContextSources {
  page?: any;
  user?: any;
  tenant?: any;
  row?: any;        // Pour les tableaux
  state?: any;      // State local
  params?: any;     // Paramètres URL
  workspace?: any;  // Contexte workspace
}

export class ContextManager {
  /**
   * Fusionne tous les contextes disponibles
   */
  static merge(
    baseContext: ContextSources,
    extra?: Record<string, any>
  ): Record<string, any> {
    return {
      page: baseContext.page || {},
      user: baseContext.user || {},
      tenant: baseContext.tenant || {},
      row: baseContext.row || {},
      state: baseContext.state || {},
      params: baseContext.params || {},
      workspace: baseContext.workspace || {},
      ...extra,
    };
  }
  
  /**
   * Récupère une valeur depuis un chemin
   * Ex: "user.email" → context.user.email
   */
  static getValue(
    path: string,
    context: Record<string, any>
  ): any {
    const keys = path.split('.');
    return keys.reduce((acc, key) => acc?.[key], context);
  }
  
  /**
   * Résout tous les templates d'un objet
   */
  static resolve(
    obj: any,
    context: Record<string, any>
  ): any {
    if (typeof obj === 'string') {
      return resolveTemplate(obj, context);
    }
    
    if (Array.isArray(obj)) {
      return obj.map(item => this.resolve(item, context));
    }
    
    if (obj && typeof obj === 'object') {
      const resolved: any = {};
      Object.entries(obj).forEach(([key, value]) => {
        resolved[key] = this.resolve(value, context);
      });
      return resolved;
    }
    
    return obj;
  }
}
```

#### Utilisation dans StructureRenderer

```typescript
const context = ContextManager.merge({
  page,
  user,
  tenant,
  state: useStudioState.getState().state,
});

const value = resolveTemplate("{{user.email}}", context);
```

### 💡 Avantages

- ✅ Gestion uniforme des variables de contexte
- ✅ Support natif multi-source (page, user, workspace, state, etc.)
- ✅ Simplifie grandement la logique du renderer

---

## 4. 🗂️ Séparer la Logique DB du Renderer

### 🎯 Objectif

Éviter que le composant React (StudioComponentRenderer) soit responsable des appels SurrealDB.

### ❌ Actuel

```typescript
// StudioComponentRenderer → fait un db.query() interne
const result = await db.query(`SELECT * FROM studio_component...`);
```

### ✅ Corrigé

Créer un hook dédié pour la récupération des composants :

#### `lib/studio/hooks/useStudioComponent.ts`

```typescript
import { db } from '@/lib/surrealdb';
import { useEffect, useState } from 'react';

interface UseStudioComponentResult {
  component: any;
  loading: boolean;
  error: Error | null;
}

export const useStudioComponent = (code: string): UseStudioComponentResult => {
  const [component, setComponent] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const loadComponent = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const result = await db.query(`
          SELECT * FROM studio_component 
          WHERE code = '${code}' AND active = true
          LIMIT 1
        `);
        
        setComponent(result?.[0] || null);
      } catch (err: any) {
        setError(err);
        console.error(`Failed to load component ${code}:`, err);
      } finally {
        setLoading(false);
      }
    };

    if (code) {
      loadComponent();
    }
  }, [code]);

  return { component, loading, error };
};
```

#### Renderer Pur

```typescript
// components/studio/StudioComponentRenderer.tsx
import { useStudioComponent } from '@/lib/studio/hooks/useStudioComponent';
import { parseComponent } from '@/lib/studio/parser';

export const StudioComponentRenderer: React.FC<Props> = ({
  code,
  props = {},
  context = {},
}) => {
  const { component, loading, error } = useStudioComponent(code);
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!component) return null;
  
  // Renderer pur - pas de logique DB ici
  return parseComponent(component.structure, props, context);
};
```

### 💡 Avantages

- ✅ Découplage net : DB ↔ Renderer
- ✅ Testabilité unitaire (on peut mocker le hook)
- ✅ Compatibilité SSR et cache possible (React Query, SWR)

---

## 5. 🧩 Standardisation du Schéma `studio_component`

### 📝 Rappel : Convention de Nomenclature

Avant de définir le schéma, il est crucial de respecter la convention de nommage suivante pour garantir la cohérence du système :

#### Nomenclature dans SurrealDB

- **Champs `code`** : Utiliser `snake_case`
  ```surql
  code = "contact_list"      -- ✅ Bon
  code = "contactList"       -- ❌ Mauvais
  code = "contact-list"       -- ❌ Mauvais
  ```

- **Props JSON** : Utiliser `camelCase` pour les clés, mais `type: "action"` pour identifier les actions
  ```json
  {
    "onClick": {
      "type": "action",        // ✅ Clé spéciale "type"
      "action": "navigate",
      "params": { "url": "/contacts" }
    }
  }
  ```

- **Fichiers TypeScript** : Utiliser `camelCase` pour les fichiers et fonctions
  ```
  resolveTemplate.ts          -- ✅ Bon
  useStudioComponent.ts       -- ✅ Bon
  ```

#### Exemples de Conventions

| Élément | Convention | Exemple |
|---------|-----------|---------|
| **Code DB** | `snake_case` | `contact_list`, `button_primary` |
| **Props JSON** | `camelCase` | `onClick`, `label`, `variant` |
| **Fichiers TS** | `camelCase.ts` | `resolveTemplate.ts` |
| **Actions DB** | `type: "action"` | `{type: "action", action: "navigate"}` |

**Important** : Cette convention doit être respectée dans tous les seeds et scripts pour éviter les divergences futures.

---

### 🎯 Objectif

Préparer un modèle clair, versionné et validable de tous les composants DB.

### ✅ Nouveau Schéma SurrealDB

```surql
DEFINE TABLE studio_component SCHEMAFULL;

DEFINE FIELD code          ON studio_component TYPE string;
DEFINE FIELD name          ON studio_component TYPE object;       -- {fr, en}
DEFINE FIELD category      ON studio_component TYPE string;
DEFINE FIELD structure     ON studio_component TYPE object;       -- JSON complet
DEFINE FIELD props_schema  ON studio_component TYPE array;        -- Liste des props
DEFINE FIELD variants      ON studio_component TYPE object;       -- Styles conditionnels
DEFINE FIELD version       ON studio_component TYPE string;       -- v1.0.0
DEFINE FIELD active        ON studio_component TYPE bool VALUE true;
DEFINE FIELD tags          ON studio_component TYPE array;
DEFINE FIELD created_at    ON studio_component VALUE time::now();
DEFINE FIELD updated_at    ON studio_component VALUE time::now();

-- Index
DEFINE INDEX code_unique ON studio_component FIELDS code UNIQUE;
DEFINE INDEX category_idx ON studio_component FIELDS category;
DEFINE INDEX active_idx ON studio_component FIELDS active;
```

### Exemple de Seed

```surql
CREATE studio_component:button SET
  code = "button",
  name = {
    fr: "Bouton",
    en: "Button"
  },
  category = "form",
  structure = {
    type: "button",
    props: {
      className: ["btn", "btn-base", "{{props.variant}}"]
    },
    children: [
      { type: "text", content: "{{props.label}}" }
    ]
  },
  props_schema = [
    {
      name: "label",
      type: "string",
      required: true,
      description: "Texte du bouton"
    },
    {
      name: "variant",
      type: "string",
      default: "primary",
      options: ["primary", "secondary", "danger", "ghost"]
    },
    {
      name: "onClick",
      type: "action",
      required: false
    }
  ],
  variants = {
    primary: {
      css_classes: ["bg-blue-500", "text-white"],
      css_variables: {
        "--bg": "#3B82F6"
      }
    },
    secondary: {
      css_classes: ["bg-gray-500", "text-white"],
      css_variables: {
        "--bg": "#6B7280"
      }
    }
  },
  version = "1.0.0",
  active = true,
  tags = ["form", "action", "ui"],
  created_at = time::now(),
  updated_at = time::now();
```

### 💡 Avantages

- ✅ Versioning propre des composants
- ✅ Recherche facile par catégorie ou tag
- ✅ Validation stricte via props_schema

---

## 6. ⚡ Sécurisation et Réécriture du ActionHandler

### 🎯 Objectif

Empêcher les hooks React d'être appelés dans des contextes non-React et isoler la logique d'exécution dans des actions pures.

### ❌ Problème Actuel

```typescript
// ⚠️ DANGER : Hook appelé dans une fonction non-React
static createHandler(action: any) {
  const navigate = useNavigate(); // ❌ Erreur !
  return () => navigate(action.params.url);
}
```

### ✅ Nouvelle Structure

```
components/studio/actions/
│
├── index.ts              → registre global d'actions
├── navigate.ts           → navigation
├── submit.ts             → insertion/update DB
├── search.ts             → requêtes filtrées
└── stateUpdate.ts        → gestion du store React
```

#### `actions/navigate.ts`

```typescript
/**
 * Action de navigation pure
 */
export const navigateAction = (
  params: { url: string },
  context: { navigate: (url: string) => void }
) => {
  const { navigate } = context;
  const url = params.url;
  
  if (!url) {
    console.warn('Navigate action: url is required');
    return;
  }
  
  navigate(url);
};
```

#### `actions/submit.ts`

```typescript
import { db } from '@/lib/surrealdb';

/**
 * Action de soumission de formulaire
 */
export const submitAction = async (
  params: {
    table: string;
    data: any;
    operation?: 'create' | 'update';
  },
  context: any
) => {
  const { table, data, operation = 'create' } = params;
  
  try {
    if (operation === 'create') {
      await db.query(`CREATE ${table} CONTENT $data`, { data });
    } else {
      await db.query(`UPDATE ${table} SET $data`, { data });
    }
    
    return { success: true };
  } catch (error) {
    console.error('Submit action failed:', error);
    return { success: false, error };
  }
};
```

#### `actions/stateUpdate.ts`

```typescript
import { useStudioState } from '@/lib/studio/store/useStudioState';

/**
 * Action de mise à jour du state
 */
export const stateUpdateAction = (
  params: { target: string },
  context: { event?: any }
) => {
  const { setValue } = useStudioState.getState();
  const { target } = params;
  const value = context.event?.target?.value;
  
  if (target && value !== undefined) {
    setValue(target, value);
  }
};
```

#### `actions/index.ts` - Registre Global

```typescript
import { navigateAction } from './navigate';
import { submitAction } from './submit';
import { searchAction } from './search';
import { stateUpdateAction } from './stateUpdate';

export const ActionRegistry = {
  navigate: navigateAction,
  submit: submitAction,
  search: searchAction,
  state_update: stateUpdateAction,
};

export type ActionType = keyof typeof ActionRegistry;
```

#### Hook Unifié

```typescript
import { useNavigate } from 'react-router-dom';
import { ActionRegistry } from './actions';

export const useActionHandler = () => {
  const navigate = useNavigate();
  
  const handleAction = async (
    action: {
      type: 'action';
      action: string;
      params: any;
    },
    event?: any
  ) => {
    const actionFn = ActionRegistry[action.action as keyof typeof ActionRegistry];
    
    if (!actionFn) {
      console.warn(`Unknown action: ${action.action}`);
      return;
    }
    
    // Context pour toutes les actions
    const context = {
      navigate,
      event,
      // Autres contextes possibles (user, tenant, etc.)
    };
    
    return await actionFn(action.params, context);
  };
  
  return { handleAction };
};
```

### 💡 Avantages

- ✅ Pas de hooks React dans des fonctions non-React
- ✅ Actions testables unitairement
- ✅ Extensible facilement (ajouter de nouvelles actions)

---

## 7. 🧩 Support du Rendu Côté Serveur (SSR Ready)

### 🎯 Objectif

Préparer le système à un rendu statique ou côté serveur (pages publiques, SEO, pré-génération).

### ✅ Plan de Compatibilité

Le `StructureRenderer` doit pouvoir fonctionner sans hooks (purement fonctionnel).

Les données doivent être passées en props statiques.

Les fonctions `resolveTemplate` et `resolveProps` doivent être pures (sans effets de bord).

### Exemple d'Utilisation SSR

```typescript
import { renderToString } from 'react-dom/server';
import { StructureRenderer } from '@/components/studio/StructureRenderer';
import { db } from '@/lib/surrealdb';

// Côté serveur (Next.js, Express, etc.)
export const renderPageSSR = async (pageCode: string) => {
  // Charger les données
  const pageData = await db.query(`
    SELECT * FROM studio_page WHERE code = '${pageCode}'
  `);
  
  const page = pageData[0];
  
  // Context statique
  const context = {
    page,
    user: {}, // Peut être injecté depuis la session
    tenant: {},
  };
  
  // Rendu HTML
  const html = renderToString(
    <StructureRenderer
      structure={page.content_structure}
      context={context}
    />
  );
  
  return html;
};
```

### Version Compatible SSR de StructureRenderer

```typescript
// StructureRenderer doit accepter toutes les données en props
export const StructureRenderer: React.FC<{
  structure: any;
  context: Record<string, any>;
  components?: Map<string, any>; // Composants pré-chargés
}> = ({ structure, context, components }) => {
  // Pas de hooks ici, tout vient des props
  // ...
};
```

### 💡 Avantages

- ✅ Pages statiques pour SEO
- ✅ Performance améliorée (pre-rendering)
- ✅ Support Next.js, Remix, etc.

---

## 8. 🧩 Extension Future — "Lyxal Studio Runtime"

Ce système devient la base du **Studio Runtime** de LYXAL.

### Architecture du Runtime

| Élément | Rôle |
|---------|------|
| **SurrealDB** | Stocke toutes les structures JSON, composants, pages |
| **React Renderer** | Interprète et rend les structures dynamiques |
| **ActionHandler** | Traduit les actions JSON en comportements réels |
| **ContextManager** | Injecte les variables de contexte (user, page, data) |
| **StateManager** | Gère les états interactifs (formulaires, filtres, etc.) |

### Le tout permet :

- 🧠 **Génération dynamique d'interfaces**
- 🧩 **Personnalisation white-label instantanée**
- 🚀 **Déploiement sans redéploiement de code**

---

## 9. 💾 Caching et Optimisation des Performances

### 🎯 Objectif

Éviter de recharger les composants depuis la DB à chaque render et optimiser les performances.

### ✅ Solution : Cache Intelligent

#### `lib/studio/cache/ComponentCache.ts`

```typescript
import { db } from '@/lib/surrealdb';

interface CachedComponent {
  component: any;
  timestamp: number;
  version: string;
}

class ComponentCache {
  private cache: Map<string, CachedComponent> = new Map();
  private readonly TTL = 5 * 60 * 1000; // 5 minutes

  /**
   * Récupère un composant depuis le cache ou la DB
   */
  async get(code: string): Promise<any> {
    const cached = this.cache.get(code);
    
    // Vérifier si le cache est valide
    if (cached && Date.now() - cached.timestamp < this.TTL) {
      return cached.component;
    }
    
    // Charger depuis la DB
    const result = await db.query(`
      SELECT * FROM studio_component 
      WHERE code = '${code}' AND active = true
    `);
    
    const component = result?.[0];
    
    if (component) {
      // Mettre en cache
      this.cache.set(code, {
        component,
        timestamp: Date.now(),
        version: component.version || '1.0.0',
      });
    }
    
    return component;
  }
  
  /**
   * Invalide le cache pour un composant
   */
  invalidate(code: string): void {
    this.cache.delete(code);
  }
  
  /**
   * Invalide tout le cache
   */
  clear(): void {
    this.cache.clear();
  }
  
  /**
   * Vérifie si une version plus récente existe en DB
   */
  async isStale(code: string, cachedVersion: string): Promise<boolean> {
    const result = await db.query(`
      SELECT version FROM studio_component 
      WHERE code = '${code}'
    `);
    
    const dbVersion = result?.[0]?.version;
    return dbVersion && dbVersion !== cachedVersion;
  }
}

export const componentCache = new ComponentCache();
```

#### Utilisation dans `useStudioComponent`

```typescript
import { componentCache } from '@/lib/studio/cache/ComponentCache';

export const useStudioComponent = (code: string) => {
  const [component, setComponent] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadComponent = async () => {
      try {
        setLoading(true);
        
        // Utiliser le cache
        const cached = componentCache.get(code);
        
        if (cached instanceof Promise) {
          const comp = await cached;
          setComponent(comp);
        } else {
          setComponent(cached);
        }
      } catch (error) {
        console.error(`Failed to load component ${code}:`, error);
      } finally {
        setLoading(false);
      }
    };

    loadComponent();
  }, [code]);

  return { component, loading };
};
```

#### Hot Reload en Développement

```typescript
// lib/studio/cache/HotReload.ts
export const enableHotReload = () => {
  if (process.env.NODE_ENV !== 'development') return;
  
  // Écouter les changements en DB (LIVE QUERY)
  const liveQuery = db.live(
    `SELECT * FROM studio_component WHERE active = true`,
    (update) => {
      if (update.action === 'UPDATE' || update.action === 'CREATE') {
        const code = update.result.code;
        // Invalider le cache
        componentCache.invalidate(code);
        
        // Émettre un événement pour forcer le re-render
        window.dispatchEvent(new CustomEvent('component-updated', { 
          detail: { code } 
        }));
      }
    }
  );
  
  return () => liveQuery.kill();
};
```

### 💡 Avantages

- ✅ Performance : Pas de requête DB à chaque render
- ✅ Hot reload : Changements DB visibles instantanément en dev
- ✅ Cache intelligent : Invalidation automatique si version changée

---

## 10. ✅ Validation Runtime des Props

### 🎯 Objectif

Valider les props passées aux composants selon le `props_schema` défini en DB.

### ✅ Solution : PropsValidator

#### `lib/studio/validation/PropsValidator.ts`

```typescript
interface PropSchema {
  name: string;
  type: string;
  required?: boolean;
  default?: any;
  options?: any[];
  description?: string;
}

export class PropsValidator {
  /**
   * Valide les props selon le schema
   */
  static validate(
    props: Record<string, any>,
    schema: PropSchema[]
  ): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    
    // Vérifier les props requises
    schema.forEach((propDef) => {
      if (propDef.required && props[propDef.name] === undefined) {
        errors.push(`Prop '${propDef.name}' is required`);
      }
      
      // Vérifier le type
      if (props[propDef.name] !== undefined) {
        const value = props[propDef.name];
        const isValidType = this.checkType(value, propDef.type);
        
        if (!isValidType) {
          errors.push(
            `Prop '${propDef.name}' has invalid type. Expected ${propDef.type}, got ${typeof value}`
          );
        }
        
        // Vérifier les options si définies
        if (propDef.options && !propDef.options.includes(value)) {
          errors.push(
            `Prop '${propDef.name}' has invalid value. Expected one of: ${propDef.options.join(', ')}`
          );
        }
      }
    });
    
    // Vérifier les props inconnues
    const schemaNames = schema.map(p => p.name);
    Object.keys(props).forEach((key) => {
      if (!schemaNames.includes(key) && key !== 'children' && key !== 'slots') {
        console.warn(`Unknown prop '${key}' passed to component`);
      }
    });
    
    return {
      valid: errors.length === 0,
      errors,
    };
  }
  
  /**
   * Vérifie le type d'une valeur
   */
  private static checkType(value: any, expectedType: string): boolean {
    switch (expectedType) {
      case 'string':
        return typeof value === 'string';
      case 'number':
        return typeof value === 'number';
      case 'boolean':
        return typeof value === 'boolean';
      case 'array':
        return Array.isArray(value);
      case 'object':
        return typeof value === 'object' && !Array.isArray(value);
      case 'action':
        return value && typeof value === 'object' && value.type === 'action';
      case 'function':
        return typeof value === 'function';
      default:
        return true;
    }
  }
  
  /**
   * Applique les valeurs par défaut
   */
  static applyDefaults(
    props: Record<string, any>,
    schema: PropSchema[]
  ): Record<string, any> {
    const withDefaults = { ...props };
    
    schema.forEach((propDef) => {
      if (withDefaults[propDef.name] === undefined && propDef.default !== undefined) {
        withDefaults[propDef.name] = propDef.default;
      }
    });
    
    return withDefaults;
  }
}
```

#### Utilisation dans `StudioComponentRenderer`

```typescript
import { PropsValidator } from '@/lib/studio/validation/PropsValidator';

export const StudioComponentRenderer: React.FC<Props> = ({
  code,
  props = {},
}) => {
  const { component, loading } = useStudioComponent(code);
  
  if (loading || !component) return null;
  
  // Valider les props en développement
  if (process.env.NODE_ENV === 'development' && component.props_schema) {
    const validation = PropsValidator.validate(props, component.props_schema);
    
    if (!validation.valid) {
      console.error(`Component ${code} validation errors:`, validation.errors);
      // En dev, on affiche les erreurs mais on continue
      // En prod, on pourrait throw ou retourner null
    }
  }
  
  // Appliquer les defaults
  const propsWithDefaults = PropsValidator.applyDefaults(
    props,
    component.props_schema || []
  );
  
  return parseComponent(component.structure, propsWithDefaults);
};
```

### 💡 Avantages

- ✅ Erreurs claires si props incorrectes
- ✅ Valeurs par défaut appliquées automatiquement
- ✅ Aide au développement (warnings)

---

## 11. ⚡ Optimisation des Performances

### 🎯 Objectif

Optimiser le rendu pour des pages complexes avec beaucoup de composants.

### ✅ Solutions Multiples

#### Lazy Loading des Composants

```typescript
// lib/studio/lazy/ComponentLazyLoader.tsx
import React, { lazy, Suspense } from 'react';

const componentCache = new Map<string, React.ComponentType<any>>();

export const LazyComponentRenderer: React.FC<{ code: string; props: any }> = ({
  code,
  props,
}) => {
  // Créer un composant lazy seulement si pas déjà en cache
  if (!componentCache.has(code)) {
    componentCache.set(
      code,
      lazy(() =>
        import(`@/components/studio/components/${code}`).catch(() => {
          // Fallback vers le renderer générique
          return {
            default: (p: any) => <StudioComponentRenderer code={code} {...p} />,
          };
        })
      )
    )
    );
  }
  
  const LazyComponent = componentCache.get(code)!;
  
  return (
    <Suspense fallback={<div>Loading {code}...</div>}>
      <LazyComponent {...props} />
    </Suspense>
  );
};
```

#### Code Splitting par Route

```typescript
// App.tsx - Routes lazy-loaded
const ContactPage = lazy(() => 
  import('@/pages/ContactPage').then(m => ({ default: m.ContactPage }))
);

const DashboardPage = lazy(() => 
  import('@/pages/DashboardPage').then(m => ({ default: m.DashboardPage }))
);

// Dans le router
<Suspense fallback={<LoadingSpinner />}>
  <Routes>
    <Route path="/contacts" element={<ContactPage />} />
    <Route path="/dashboard" element={<DashboardPage />} />
  </Routes>
</Suspense>
```

#### Memoization des Composants Parsés

```typescript
// lib/studio/memo/ComponentMemo.ts
import { useMemo } from 'react';

export const useMemoizedComponent = (
  structure: any,
  props: any,
  context: any
) => {
  return useMemo(() => {
    return parseComponent(structure, props, context);
  }, [
    JSON.stringify(structure),
    JSON.stringify(props),
    JSON.stringify(context),
  ]);
};
```

#### Virtual Scrolling pour Grandes Listes

```typescript
// Pour les composants table avec beaucoup de données
import { useVirtualizer } from '@tanstack/react-virtual';

export const VirtualizedTable: React.FC<{ data: any[]; columns: any[] }> = ({
  data,
  columns,
}) => {
  const parentRef = React.useRef<HTMLDivElement>(null);
  
  const virtualizer = useVirtualizer({
    count: data.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
    overscan: 5,
  });
  
  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          width: '100%',
          position: 'relative',
        }}
      >
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.index}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {/* Render row */}
          </div>
        ))}
      </div>
    </div>
  );
};
```

### 💡 Avantages

- ✅ Chargement initial plus rapide
- ✅ Meilleure expérience utilisateur
- ✅ Gestion efficace des grandes listes

---

## 12. 📝 Documentation et Exemples d'Utilisation

### 🎯 Objectif

Faciliter l'adoption du système par les développeurs avec des exemples concrets.

### ✅ Structure de Documentation

#### Exemples d'Utilisation

```markdown
# Exemples d'Utilisation

## Créer un Bouton Simple

\`\`\`surql
CREATE studio_component:button SET
  code = "button",
  structure = {...},
  props_schema = [...];
\`\`\`

\`\`\`tsx
<StudioComponentRenderer 
  code="button" 
  props={{ label: "Cliquer", variant: "primary" }} 
/>
\`\`\`

## Créer une Page Complète

\`\`\`surql
CREATE studio_page:home SET
  content_structure = {...};
\`\`\`

\`\`\`tsx
<StudioPage pageCode="home" tenant="lyxal" />
\`\`\`
```

#### API Reference

```typescript
/**
 * Hook pour charger un composant depuis la DB
 * @param code - Code unique du composant
 * @returns { component, loading, error }
 */
export const useStudioComponent = (code: string) => { ... };

/**
 * Parse une structure JSON en composant React
 * @param structure - Structure JSON du composant
 * @param props - Props à passer au composant
 * @param context - Contexte (page, user, etc.)
 * @returns Élément React
 */
export const parseComponent = (
  structure: any,
  props?: any,
  context?: any
) => { ... };
```

---

## ✅ Synthèse Générale

| Domaine | Problème corrigé | Solution apportée |
|---------|------------------|-------------------|
| **Parser monolithique** | Code complexe à maintenir | Découpage en pipeline modulaire |
| **Composants statiques** | Aucune réactivité | Store global + bindings dynamiques |
| **Contexte isolé** | Variables limitées | ContextManager multi-source |
| **Couplage DB/UI** | Le renderer dépend du backend | Hook `useStudioComponent` |
| **Schéma non versionné** | Impossible de gérer l'évolution | Schéma standardisé `studio_component` |
| **Actions non sécurisées** | Hooks utilisés hors contexte | ActionRegistry + hook unique `useActionHandler` |
| **Pas de SSR** | Limité au client | Fonctions pures et compatibles serveur |
| **Pas de cache** | Requêtes DB à chaque render | Cache intelligent avec TTL |
| **Pas de validation** | Erreurs props à l'exécution | PropsValidator avec schema |
| **Performance limitée** | Rendu non optimisé | Lazy loading + memoization + virtual scrolling |

---

## 🏁 Conclusion

Ces améliorations posent les **fondations solides** du **Lyxal Studio Runtime** :

- 🔐 **Sécurisé** : Actions isolées, pas de code injecté
- ⚡ **Performant** : Pipeline optimisé, SSR ready
- 🧱 **Modulaire** : Chaque partie est indépendante et testable
- 🌍 **Multi-tenant** : Chaque tenant a ses propres composants
- 🧠 **Extensible par IA** : Structure JSON = génération possible

Vous disposez maintenant d'un **moteur universel de rendu contrôlé**, capable d'interpréter n'importe quelle interface décrite en JSON dans SurrealDB — et donc de **générer dynamiquement des SaaS entiers sans code en dur**.

---

## 🚀 Prochaines Étapes Recommandées

### Phase 1 : Fondations (Semaine 1)

1. **Implémenter le pipeline modulaire** (3 jours)
   - Découper ComponentParser en modules séparés
   - Créer resolveTemplate, resolveProps, resolveChildren, etc.

2. **Séparer DB/Renderer avec hooks** (2 jours)
   - Créer `useStudioComponent`
   - Rendre StudioComponentRenderer pur

3. **Standardiser le schéma** (1 jour)
   - Mettre à jour `studio_component` avec version, tags, etc.

### Phase 2 : Fonctionnalités Avancées (Semaine 2)

4. **Ajouter le StateManager** (2 jours)
   - Créer `useStudioState` (Zustand ou Context)
   - Implémenter le binding dynamique

5. **Créer le ContextManager** (2 jours)
   - Centraliser tous les contextes
   - Résolution multi-source des templates

6. **Sécuriser ActionHandler** (2 jours)
   - Créer ActionRegistry
   - Implémenter useActionHandler

7. **Implémenter le Cache** (1 jour)
   - Créer ComponentCache
   - Intégrer dans useStudioComponent

### Phase 3 : Optimisations (Semaine 3)

8. **Validation Runtime** (1 jour)
   - Créer PropsValidator
   - Intégrer dans StudioComponentRenderer

9. **Optimisations Performance** (2 jours)
   - Lazy loading des composants
   - Memoization
   - Virtual scrolling pour tables

10. **Hot Reload en Dev** (1 jour)
    - LIVE QUERY pour changements DB
    - Invalidation automatique du cache

11. **Tester SSR** (2 jours)
    - Adapter StructureRenderer pour SSR
    - Tests avec Next.js/Remix

### Phase 4 : Documentation (Semaine 4)

12. **Documentation et Exemples** (3 jours)
    - API Reference complète
    - Exemples d'utilisation
    - Guides pas à pas

**Total estimé** : ~4 semaines pour un système production-ready complet.

### 🎯 Priorisation (MVP en 2 semaines)

Pour un MVP plus rapide, prioriser :
- ✅ Pipeline modulaire
- ✅ Séparation DB/Renderer
- ✅ StateManager
- ✅ ActionRegistry
- ✅ Cache de base

Les optimisations avancées peuvent être ajoutées ensuite.

---

## 🧪 Structure des Tests Unitaires

Pour garantir la stabilité et la qualité du système, tous les modules clés du Lyxal Studio Runtime doivent être couverts par des tests unitaires.

### 📁 Répertoire de Tests

```
tests/studio/
│
├── parser/
│   ├── resolveTemplate.test.ts
│   ├── resolveProps.test.ts
│   ├── resolveChildren.test.ts
│   ├── applyVariants.test.ts
│   └── createReactElement.test.ts
│
├── validation/
│   └── propsValidator.test.ts
│
├── actions/
│   └── actionHandler.test.ts
│
├── cache/
│   └── componentCache.test.ts
│
├── context/
│   └── contextManager.test.ts
│
├── hooks/
│   └── useStudioComponent.test.ts
│
└── integration/
    └── structureRenderer.test.ts
```

### 🛠️ Framework de Tests

Les tests utilisent **Vitest** (ou Jest) avec **@testing-library/react** pour les composants React.

#### Configuration Vitest

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
  },
});
```

#### Exemple de Test : resolveTemplate.test.ts

```typescript
import { describe, it, expect } from 'vitest';
import { resolveTemplate } from '@/lib/studio/parser/resolveTemplate';

describe('resolveTemplate', () => {
  it('should resolve simple template', () => {
    const context = { page: { title: { fr: 'Home' } } };
    const result = resolveTemplate('{{page.title.fr}}', context);
    expect(result).toBe('Home');
  });

  it('should handle nested paths', () => {
    const context = { user: { profile: { name: 'John' } } };
    const result = resolveTemplate('{{user.profile.name}}', context);
    expect(result).toBe('John');
  });

  it('should return original string if path not found', () => {
    const context = {};
    const result = resolveTemplate('{{page.title.fr}}', context);
    expect(result).toBe('{{page.title.fr}}');
  });
});
```

#### Exemple de Test : propsValidator.test.ts

```typescript
import { describe, it, expect } from 'vitest';
import { PropsValidator } from '@/lib/studio/validation/PropsValidator';

describe('PropsValidator', () => {
  it('should validate required props', () => {
    const schema = [
      { name: 'label', type: 'string', required: true },
    ];
    
    const validation = PropsValidator.validate({}, schema);
    expect(validation.valid).toBe(false);
    expect(validation.errors).toContain("Prop 'label' is required");
  });

  it('should validate prop types', () => {
    const schema = [
      { name: 'count', type: 'number' },
    ];
    
    const validation = PropsValidator.validate({ count: '123' }, schema);
    expect(validation.valid).toBe(false);
  });

  it('should apply defaults', () => {
    const schema = [
      { name: 'variant', type: 'string', default: 'primary' },
    ];
    
    const result = PropsValidator.applyDefaults({}, schema);
    expect(result.variant).toBe('primary');
  });
});
```

#### Exemple de Test : useStudioComponent.test.ts

```typescript
import { describe, it, expect, vi } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { useStudioComponent } from '@/lib/studio/hooks/useStudioComponent';

// Mock SurrealDB
vi.mock('@/lib/surrealdb', () => ({
  db: {
    query: vi.fn(),
  },
}));

describe('useStudioComponent', () => {
  it('should load component from DB', async () => {
    const mockComponent = { code: 'button', structure: {} };
    vi.mocked(db.query).mockResolvedValue([mockComponent]);

    const { result } = renderHook(() => useStudioComponent('button'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.component).toEqual(mockComponent);
    });
  });
});
```

### 📊 Couverture de Tests Recommandée

| Module | Couverture Minimum | Priorité |
|--------|-------------------|----------|
| **Parser** | 90% | 🔴 Critique |
| **PropsValidator** | 95% | 🔴 Critique |
| **ActionHandler** | 85% | 🟠 Haute |
| **ContextManager** | 80% | 🟠 Haute |
| **ComponentCache** | 75% | 🟡 Moyenne |
| **Hooks** | 70% | 🟡 Moyenne |

### 🚀 Commandes de Test

```bash
# Lancer tous les tests
npm run test

# Tests en mode watch (développement)
npm run test:watch

# Tests avec couverture
npm run test:coverage

# Tests d'un module spécifique
npm run test parser
```

### 💡 Avantages

- ✅ **Stabilité** : Détection précoce des régressions
- ✅ **Confiance** : Refactoring sécurisé
- ✅ **Documentation** : Tests = exemples d'utilisation
- ✅ **CI/CD** : Intégration dans le pipeline de déploiement

---

**Documentation créée pour le développement du Lyxal Studio Runtime** 🎨🚀


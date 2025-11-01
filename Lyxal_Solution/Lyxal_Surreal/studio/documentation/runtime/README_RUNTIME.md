# 🚀 Lyxal Studio Runtime - Guide Technique

## 🎯 Philosophie

Le **Lyxal Studio Runtime** est un moteur de rendu universel qui transforme des **définitions JSON stockées dans SurrealDB** en **interfaces React complètes et interactives**.

### Principe Fondamental : 100% Database-Driven

**Aucun code frontend en dur** — Tout est défini dans SurrealDB :
- ✅ Composants UI (boutons, inputs, tables, etc.)
- ✅ Pages complètes (structure, layout, widgets)
- ✅ Actions (navigation, submit, search, etc.)
- ✅ Styles et thèmes
- ✅ Permissions et règles d'accès

**Résultat** : Déployer des SaaS entiers sans redéploiement de code, uniquement via des `UPDATE` SurrealDB.

---

## 🔄 Pipeline Global

### Schéma Visuel du Runtime

```
┌─────────────────────────────────────────────────────────────┐
│                    SURREALDB CLOUD                          │
│  ┌────────────────────────────────────────────────────┐     │
│  │ studio_component                                   │     │
│  │   • code: "button"                                 │     │
│  │   • structure: { type, props, children }           │     │
│  │   • props_schema: [...]                            │     │
│  │   • variants: {...}                                │     │
│  └────────────────────────────────────────────────────┘     │
│  ┌────────────────────────────────────────────────────┐     │
│  │ studio_page                                        │     │
│  │   • code: "contact_list"                           │     │
│  │   • content_structure: { ... }                     │     │
│  └────────────────────────────────────────────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓ WebSocket (WSS)
┌─────────────────────────────────────────────────────────────┐
│              REACT APPLICATION                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 1. useStudioComponent                              │     │
│  │    → Charge composant depuis DB (avec cache)       │     │
│  └────────────────────────┬───────────────────────────┘     │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 2. ComponentParser                                 │     │
│  │    ├─ resolveTemplate()                            │     │
│  │    ├─ resolveProps()                               │     │
│  │    ├─ applyVariants()                              │     │
│  │    └─ createReactElement()                         │     │
│  └────────────────────────┬───────────────────────────┘     │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 3. StructureRenderer                               │     │
│  │    → Rendu récursif avec ContextManager            │     │
│  └────────────────────────┬───────────────────────────┘     │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 4. ActionHandler                                   │     │
│  │    → Exécute actions (navigate, submit, etc.)      │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    DOM RENDU                                │
│  • Composants React natifs                                  │
│  • Styles appliqués                                         │
│  • Interactivité complète                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧩 Modules Clés

### 1. Parser (`lib/studio/parser/`)

**Rôle** : Transformer structure JSON → Composant React

**Pipeline** :
1. `resolveTemplate` → Remplace `{{props.x}}` par valeurs réelles
2. `resolveProps` → Fusionne props structure + props composant
3. `applyVariants` → Applique styles selon variant
4. `resolveChildren` → Parse récursivement les enfants
5. `createReactElement` → Crée l'élément React final

**Exemple** :
```typescript
import { parseComponent } from '@/lib/studio/parser';

const structure = {
  type: "button",
  props: { className: ["btn"], onClick: { type: "action", action: "navigate" } },
  children: [{ type: "text", content: "{{props.label}}" }]
};

const element = parseComponent(structure, { label: "Créer" }, { page, user });
// → <button className="btn" onClick={...}>Créer</button>
```

### 2. Renderer (`components/studio/`)

**Rôle** : Charger composant DB et le rendre

**Composants** :
- `StudioComponentRenderer` → Rend un composant depuis son code DB
- `StructureRenderer` → Rend récursivement une structure complète
- `StudioPage` → Charge et rend une page complète

**Exemple** :
```typescript
<StudioComponentRenderer 
  code="button" 
  props={{ label: "Créer", variant: "primary" }} 
/>
```

### 3. Cache (`lib/studio/cache/`)

**Rôle** : Éviter les requêtes DB répétées

**Fonctionnalités** :
- Cache avec TTL (5 minutes par défaut)
- Invalidation par version
- Hot reload en développement (LIVE QUERY)

**Exemple** :
```typescript
import { componentCache } from '@/lib/studio/cache/ComponentCache';

const component = await componentCache.get('button');
// Premier appel : DB
// Appels suivants : Cache (si < 5 min)
```

### 4. Validation (`lib/studio/validation/`)

**Rôle** : Valider les props selon `props_schema`

**Fonctionnalités** :
- Validation de type
- Vérification des props requises
- Application des valeurs par défaut
- Warnings pour props inconnues

**Exemple** :
```typescript
import { PropsValidator } from '@/lib/studio/validation/PropsValidator';

const validation = PropsValidator.validate(
  { label: "Créer", variant: "primary" },
  component.props_schema
);

if (!validation.valid) {
  console.error(validation.errors);
}
```

### 5. Actions (`components/studio/actions/`)

**Rôle** : Exécuter les actions définies en DB

**Actions supportées** :
- `navigate` → Navigation
- `submit` → Soumission formulaire
- `search` → Recherche/filtrage
- `state_update` → Mise à jour du state

**Exemple** :
```typescript
import { useActionHandler } from '@/components/studio/actions';

const { handleAction } = useActionHandler();

handleAction({
  type: "action",
  action: "navigate",
  params: { url: "/contacts/new" }
});
```

### 6. Context Manager (`lib/studio/context/`)

**Rôle** : Gérer tous les contextes (page, user, tenant, state, etc.)

**Sources de contexte** :
- `page` → Données de la page actuelle
- `user` → Utilisateur connecté
- `tenant` → Configuration tenant
- `state` → State local (formulaires, filtres)
- `row` → Données de ligne (dans tableaux)

**Exemple** :
```typescript
import { ContextManager } from '@/lib/studio/context/ContextManager';

const context = ContextManager.merge({
  page,
  user,
  tenant,
  state: useStudioState.getState().state,
});

const value = resolveTemplate("{{user.email}}", context);
```

### 7. State Manager (`lib/studio/store/`)

**Rôle** : Gérer le state interactif (formulaires, filtres, etc.)

**Basé sur** : Zustand (ou React Context)

**Exemple** :
```typescript
import { useStudioState } from '@/lib/studio/store/useStudioState';

const { state, setValue } = useStudioState();

// Mettre à jour
setValue('search', 'query');

// Lire
const searchValue = state.search;
```

---

## 📊 Flux Complet : De la DB au DOM

### Étape 1 : Chargement de la Page

```typescript
// User navigue vers /contacts
<StudioPage pageCode="contact_list" tenant="lyxal" />
```

### Étape 2 : Chargement depuis DB

```typescript
// StudioPage.tsx
const page = await db.query(`
  SELECT * FROM studio_page WHERE code = 'contact_list'
`);

// Structure JSON complète chargée
page.content_structure = {
  type: "div",
  children: [
    { type: "component", component: "button", props: {...} },
    { type: "component", component: "table", props: {...} }
  ]
};
```

### Étape 3 : Parsing Récursif

```typescript
// StructureRenderer.tsx
<StructureRenderer 
  structure={page.content_structure} 
  context={{ page, user, tenant }}
/>
```

Pour chaque enfant :
1. Si `type: "component"` → Charger depuis DB (avec cache)
2. Parser la structure
3. Résoudre les templates (`{{props.label}}`)
4. Appliquer les variants
5. Résoudre les actions
6. Créer l'élément React

### Étape 4 : Rendu React

```typescript
// Éléments React natifs créés
React.createElement('button', { onClick: handleNavigate }, 'Créer');
React.createElement('table', { columns, data }, ...);
```

### Étape 5 : Actions Utilisateur

```typescript
// User clique sur bouton → Action navigate déclenchée
{
  type: "action",
  action: "navigate",
  params: { url: "/contacts/new" }
}
→ useActionHandler.execute()
→ Navigation vers /contacts/new
```

---

## 🎨 Exemple Complet : Créer une Page de Contacts

### 1. Définir le Composant Button en DB

```surql
CREATE studio_component:button SET
  code = "button",
  structure = {
    type: "button",
    props: {
      className: ["btn", "btn-{{props.variant}}"]
    },
    children: [
      { type: "text", content: "{{props.label}}" }
    ]
  },
  props_schema = [
    { name: "label", type: "string", required: true },
    { name: "variant", type: "string", default: "primary" },
    { name: "onClick", type: "action", required: false }
  ],
  variants = {
    primary: { css_classes: ["bg-blue-500"] },
    secondary: { css_classes: ["bg-gray-500"] }
  };
```

### 2. Définir la Page en DB

```surql
CREATE studio_page:contact_list SET
  code = "contact_list",
  title = { fr: "Liste des Contacts", en: "Contact List" },
  url = "/contacts",
  content_structure = {
    type: "div",
    children: [
      {
        type: "component",
        component: "button",
        props: {
          label: { fr: "Créer un Contact", en: "Create Contact" },
          variant: "primary",
          onClick: {
            type: "action",
            action: "navigate",
            params: { url: "/contacts/new" }
          }
        }
      }
    ]
  };
```

### 3. Utiliser dans React

```typescript
// App.tsx
<Route path="/contacts" element={<StudioPage pageCode="contact_list" />} />
```

**Résultat** : Page complète rendue dynamiquement, aucun code React en dur !

---

## 🛠️ Architecture des Fichiers

```
src/
├── lib/
│   └── studio/
│       ├── parser/              → Pipeline de parsing
│       │   ├── resolveTemplate.ts
│       │   ├── resolveProps.ts
│       │   ├── resolveChildren.ts
│       │   ├── applyVariants.ts
│       │   ├── createReactElement.ts
│       │   └── index.ts
│       │
│       ├── cache/               → Cache des composants
│       │   ├── ComponentCache.ts
│       │   └── HotReload.ts
│       │
│       ├── validation/          → Validation props
│       │   └── PropsValidator.ts
│       │
│       ├── context/             → Gestion contexte
│       │   └── ContextManager.ts
│       │
│       ├── store/               → State management
│       │   └── useStudioState.ts
│       │
│       └── hooks/               → Hooks React
│           └── useStudioComponent.ts
│
├── components/
│   └── studio/
│       ├── StudioComponentRenderer.tsx
│       ├── StructureRenderer.tsx
│       ├── StudioPage.tsx
│       └── actions/
│           ├── index.ts
│           ├── navigate.ts
│           ├── submit.ts
│           └── stateUpdate.ts
│
└── tests/
    └── studio/
        ├── parser/
        ├── validation/
        ├── actions/
        └── hooks/
```

---

## 📚 Ressources

### Documentation Complète

- **[AMELIORATIONS_RENDU.md](./AMELIORATIONS_RENDU.md)** → Guide technique complet
- **[SYSTEME_RENDU.md](./SYSTEME_RENDU.md)** → Système de rendu contrôlé
- **[COMPOSANTS_DB.md](./COMPOSANTS_DB.md)** → Composants pilotés par DB
- **[ICONS_RUNTIME.md](./ICONS_RUNTIME.md)** → Utilisation des icônes dans le Runtime
- **[THEMES_RUNTIME.md](./THEMES_RUNTIME.md)** → Utilisation des thèmes dans le Runtime
- **[DATABASE.md](../database/DATABASE.md)** → Schémas SurrealDB

### Liens Externes

- [SurrealDB Documentation](https://surrealdb.com/docs)
- [React Documentation](https://react.dev)
- [Zustand Documentation](https://zustand-demo.pmnd.rs)
- [Vitest Documentation](https://vitest.dev)

---

## 🚀 Démarrage Rapide

### 1. Installer les Dépendances

```bash
npm install zustand react-router-dom @tanstack/react-virtual surrealdb.js
npm install --save-dev vitest @testing-library/react typescript
```

### 2. Créer le Premier Composant en DB

```surql
CREATE studio_component:button SET
  code = "button",
  structure = { type: "button", props: {}, children: [] },
  props_schema = [],
  active = true;
```

### 3. Utiliser dans React

```typescript
import { StudioComponentRenderer } from '@/components/studio/StudioComponentRenderer';

<StudioComponentRenderer code="button" props={{ label: "Test" }} />
```

**C'est tout !** Le composant est chargé depuis la DB et rendu automatiquement.

---

## 🎯 Prochaines Étapes

1. Lire [AMELIORATIONS_RENDU.md](./AMELIORATIONS_RENDU.md) pour les détails d'implémentation
2. Suivre la roadmap en 4 phases
3. Implémenter module par module
4. Tester chaque module avant de passer au suivant

---

**Lyxal Studio Runtime : Database-Driven UI, Anywhere** 🎨🚀📱

*Documentation de référence pour le développement du Runtime*


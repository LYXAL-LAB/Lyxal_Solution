# 🎨 Lyxal Studio Runtime

Système de rendu **100% Database-Driven** pour React. Transforme des structures JSON définies dans SurrealDB en composants et pages React interactives **sans code en dur**.

## 🎯 Principe Fondamental

**Aucun code frontend en dur** — Tout est défini dans SurrealDB :
- ✅ **Composants UI** (boutons, inputs, tables, etc.) → `studio_component`
- ✅ **Pages complètes** (structure, layout, composants) → `studio_page.content_structure`
- ✅ **Actions** (navigation, submit, etc.) → Définies en DB comme JSON
- ✅ **Styles et thèmes** → Gérés via DB
- ✅ **Permissions** → Définies en DB

React ne fait qu'**interpréter et rendre** ces structures dynamiquement.

---

## 📁 Structure

```
lib/studio/
├── parser/              # Pipeline de parsing JSON → React
│   ├── resolveTemplate.ts  # Résout {{props.x}}
│   ├── resolveProps.ts      # Fusionne props
│   ├── applyVariants.ts     # Applique variants CSS
│   ├── resolveChildren.ts   # Parse children récursivement
│   ├── createReactElement.ts # Crée élément React final
│   └── index.ts            # parseComponent()

├── context/            # Gestion contextes
│   └── ContextManager.ts

├── store/              # State management
│   └── useStudioState.ts

├── hooks/              # Hooks React
│   ├── useStudioComponent.ts  # Charge composant depuis SurrealDB
│   ├── useStudioPage.ts    # Charge page depuis SurrealDB
│   └── useActionHandler.ts # Gère les actions DB

├── actions/            # Actions définies en DB
│   ├── navigate.ts
│   ├── stateUpdate.ts
│   ├── submit.ts
│   └── index.ts

└── types/              # Types TypeScript
    └── component.ts
```

---

## 🚀 Utilisation

### Rendre une Page Complète depuis la DB (100% DB-Driven)

```tsx
import { StudioPageRenderer } from '@/components/studio';

// ✅ AUCUN code React en dur - tout vient de studio_page:test_page
function MyRouter() {
  return (
    <Routes>
      <Route 
        path="/test" 
        element={<StudioPageRenderer pageCode="test_page" />} 
      />
    </Routes>
  );
}
```

La page `test_page` est **entièrement définie dans SurrealDB** avec sa structure complète, ses composants, et leurs props.

### Rendre un Composant Individuel

```tsx
import { StudioComponentRenderer } from '@/components/studio';

// Rendre le composant test_button depuis la DB
<StudioComponentRenderer
  code="test_button"
  props={{ label: "Click me", disabled: false }}
/>
```

### Utiliser le Parser Directement (pour tests)

```tsx
import { parseComponent } from '@/lib/studio/parser';

const structure = {
  type: "button",
  props: {
    className: ["btn"],
    disabled: "{{props.disabled}}"
  },
  children: [
    { type: "text", content: "{{props.label}}" }
  ]
};

const element = parseComponent(
  structure,
  { label: "Hello", disabled: false }
);
```

---

## 📊 Flux Complet : De la DB au DOM

### 1. Page Complète (100% DB-Driven)

```
User visite /test
    ↓
<StudioPageRenderer pageCode="test_page" />
    ↓
useStudioPage('test_page') → Charge studio_page:test_page depuis SurrealDB
    ↓
page.content_structure = {
  type: "div",
  children: [
    { type: "component", component: "test_button", props: {...} }
  ]
}
    ↓
<StructureRenderer structure={page.content_structure} />
    ↓
Pour chaque child:
  - Si type: "component" → <StudioComponentRenderer code="test_button" />
  - Si type: "text" → Résout template {{...}}
  - Si type: "div" → Crée élément HTML
    ↓
React.render() → DOM
```

### 2. Composant Individuel

```
<StudioComponentRenderer code="test_button" />
    ↓
useStudioComponent('test_button') → Charge studio_component:test_button
    ↓
component.structure = { type: "button", props: {...}, children: [...] }
    ↓
parseComponent(component.structure, props)
    ↓
React Element → DOM
```

---

## 🎯 Exemple Complet : Page de Test

### 1. Définir la Page dans SurrealDB

```surql
CREATE studio_page:test_page SET
  identity.code = "test_page",
  presentation.url = "/test",
  content_structure = {
    type: "div",
    children: [
      {
        type: "component",
        component: "test_button",
        props: { label: "Cliquez-moi !", disabled: false }
      }
    ]
  },
  status.is_active = true;
```

### 2. Utiliser dans React (UNE SEULE ligne)

```tsx
<StudioPageRenderer pageCode="test_page" />
```

**Résultat** : La page complète avec tous ses composants est rendue depuis la DB, **sans code React en dur**.

---

## ✅ Tests

Tous les tests passent :
```bash
npm run test:run
# ✓ 51 tests passed
```

---

## 📚 Documentation Complète

- `Lyxal_Surreal/studio/documentation/runtime/README_RUNTIME.md` - Vue d'ensemble
- `Lyxal_Surreal/studio/documentation/runtime/AMELIORATIONS_RENDU.md` - Spécifications complètes
- `Lyxal_Surreal/studio/documentation/runtime/SYSTEME_RENDU.md` - Principe fondamental
- `Lyxal_Surreal/studio/documentation/INDEX_REFERENCE.md` - Index de référence

---

## 🔄 Prochaines Étapes

1. ✅ Parser JSON → React (Phase 1)
2. ✅ Connexion DB ↔ React (Phase 2)
3. ✅ Pages 100% DB-Driven (Phase 3) ← **Vous êtes ici**
4. ⏳ Routes dynamiques (Phase 4)
5. ⏳ Optimisations (cache, SSR, etc.)

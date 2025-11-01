# 🚀 Ordre d'Implémentation - Lyxal Studio Runtime

Guide pour déterminer **par où commencer** : SurrealDB ou TypeScript/React ?

---

## 🎯 Réponse Rapide

**Commencez par SurrealDB** (schéma minimal), puis **développez en parallèle** DB et TypeScript.

**Pourquoi ?** :
- Le schéma DB définit le **contrat de données**
- Le parser TypeScript doit **respecter** cette structure
- Vous pouvez tester le parser avec des **données mock** pendant que vous finalisez le schéma

---

## 📋 Ordre Recommandé (Approche Itérative)

### Phase 0 : Préparation (1 jour)

#### ✅ Étape 1 : Schéma SurrealDB Minimal (2 heures)

**Créer la table de base** pour avoir une structure de référence :

```surql
-- database/studio/studio_component.surql
DEFINE TABLE studio_component SCHEMAFULL;

DEFINE FIELD code ON studio_component TYPE string;
DEFINE FIELD name ON studio_component TYPE object;
DEFINE FIELD structure ON studio_component TYPE object;
DEFINE FIELD props_schema ON studio_component TYPE array;
DEFINE FIELD variants ON studio_component TYPE object;
DEFINE FIELD version ON studio_component TYPE string DEFAULT '1.0.0';
DEFINE FIELD active ON studio_component TYPE bool DEFAULT true;

DEFINE INDEX code_unique ON studio_component FIELDS code UNIQUE;
```

#### ✅ Étape 2 : Seed de Test (1 heure)

**Créer un composant de test** pour valider le schéma :

```surql
-- reference/studio/component/test_button.surql
CREATE studio_component:test_button SET
  code = "test_button",
  name = { fr: "Bouton Test", en: "Test Button" },
  structure = {
    type: "button",
    props: {
      className: ["btn", "btn-primary"]
    },
    children: [
      { type: "text", content: "{{props.label}}" }
    ]
  },
  props_schema = [
    { name: "label", type: "string", required: true }
  ],
  variants = {},
  version = "1.0.0",
  active = true;
```

**Résultat** : Vous avez maintenant une structure de référence et un exemple concret.

---

### Phase 1 : Parser TypeScript avec Données Mock (3 jours)

**Maintenant que vous connaissez la structure**, développez le parser avec des données mock.

#### ✅ Étape 1 : Créer les Modules Parser (Jour 1)

```typescript
// lib/studio/parser/resolveTemplate.ts
export const resolveTemplate = (template: string, context: any) => {
  // Implémentation...
};

// lib/studio/parser/resolveProps.ts
export const resolveProps = (structureProps: any, componentProps: any, context: any) => {
  // Implémentation...
};

// etc.
```

**Utilisez des données mock** pour tester :

```typescript
// tests/parser/resolveTemplate.test.ts
const mockComponent = {
  code: "test_button",
  structure: {
    type: "button",
    props: { className: ["btn"] },
    children: [{ type: "text", content: "{{props.label}}" }]
  },
  props_schema: [{ name: "label", type: "string", required: true }]
};

// Test avec données mock
const result = parseComponent(mockComponent.structure, { label: "Test" });
```

#### ✅ Étape 2 : Tests Unitaires (Jour 2)

Testez chaque module du parser indépendamment avec des données mock.

**Avantage** : Vous validez la logique sans dépendre de SurrealDB.

---

### Phase 2 : Connexion DB ↔ React (2 jours)

#### ✅ Étape 1 : Hook `useStudioComponent` (Jour 1)

```typescript
// lib/studio/hooks/useStudioComponent.ts
export const useStudioComponent = (code: string) => {
  // Charger depuis SurrealDB
  // Utiliser le parser développé en Phase 1
};
```

#### ✅ Étape 2 : Renderer React (Jour 2)

```typescript
// components/studio/StudioComponentRenderer.tsx
export const StudioComponentRenderer = ({ code, props }) => {
  const { component } = useStudioComponent(code);
  return parseComponent(component.structure, props);
};
```

**Testez avec le seed `test_button` créé en Phase 0.**

---

## 🔄 Approche Alternative : Développement Parallèle

### Option 1 : DB First (Recommandé pour débutants)

```
Jour 1-2 : Schéma SurrealDB complet
    ↓
Jour 3-5 : Parser TypeScript (avec mock)
    ↓
Jour 6-7 : Connexion DB ↔ React
    ↓
Jour 8+ : Tests d'intégration
```

**Avantages** :
- ✅ Structure claire dès le départ
- ✅ Pas de refactoring du parser
- ✅ Schéma validé avant implémentation

**Inconvénient** :
- ⚠️ Risque de sur-engineerer le schéma sans tester

---

### Option 2 : TypeScript First (Recommandé si expérimentation)

```
Jour 1-3 : Parser TypeScript avec structure JSON inventée
    ↓
Jour 4-5 : Adapter le schéma DB à cette structure
    ↓
Jour 6-7 : Connexion DB ↔ React
```

**Avantages** :
- ✅ Découvre les besoins au fur et à mesure
- ✅ Plus itératif

**Inconvénient** :
- ⚠️ Risque de devoir refactorer le schéma

---

## ✅ Recommandation Finale

### 🎯 Commencer par SurrealDB (Schéma Minimal)

**Ordre optimal** :

```
1. Créer le schéma DB minimal (2h) 
   → Table studio_component avec champs essentiels

2. Créer 1 seed de test (1h)
   → Composant simple (button) pour valider

3. Développer le parser TypeScript (3 jours)
   → Avec données mock basées sur le seed

4. Connecter au vrai DB (1 jour)
   → useStudioComponent charge depuis SurrealDB

5. Itérer et compléter (semaines suivantes)
   → Ajouter champs DB si besoin
   → Étendre le parser
```

---

## 📊 Checklist de Démarrage

### SurrealDB (Phase 0 - 3h)

- [ ] Créer `database/studio/studio_component.surql`
- [ ] Définir champs : `code`, `name`, `structure`, `props_schema`, `variants`, `version`, `active`
- [ ] Créer index `code_unique`
- [ ] Créer seed `test_button.surql`
- [ ] Tester le seed : `SELECT * FROM studio_component:test_button`

### TypeScript (Phase 1 - 3 jours)

- [ ] Installer dépendances : `zustand`, `react-router-dom`, `vitest`
- [ ] Créer `lib/studio/parser/resolveTemplate.ts`
- [ ] Créer `lib/studio/parser/resolveProps.ts`
- [ ] Créer `lib/studio/parser/resolveChildren.ts`
- [ ] Créer `lib/studio/parser/createReactElement.ts`
- [ ] Créer `lib/studio/parser/index.ts`
- [ ] Tests unitaires pour chaque module

### Connexion (Phase 2 - 2 jours)

- [ ] Créer `lib/studio/hooks/useStudioComponent.ts`
- [ ] Créer `components/studio/StudioComponentRenderer.tsx`
- [ ] Tester avec seed `test_button`
- [ ] Valider le flux complet : DB → Hook → Parser → React → DOM

---

## 💡 Pourquoi DB en Premier ?

### 1. **Contrat de Données Claire**

Le schéma DB définit **exactement** ce que le parser doit recevoir :

```surql
DEFINE FIELD structure ON studio_component TYPE object;
```

→ Le parser sait qu'il recevra toujours un `object`

### 2. **Validation Immédiate**

Si vous créez un seed avec une mauvaise structure, SurrealDB vous le dira :

```surql
CREATE studio_component:button SET
  structure = "wrong type";  -- ❌ Erreur : doit être object
```

### 3. **Tests Plus Faciles**

Vous pouvez tester le parser avec des données qui **respectent le schéma** :

```typescript
// Données conformes au schéma
const mockData = {
  code: "button",
  structure: { type: "button", props: {} },  // ✅ Conforme
  props_schema: []
};
```

### 4. **Évolution Progressive**

Vous pouvez ajouter des champs au schéma progressivement :

```surql
-- Semaine 1 : Schéma minimal
DEFINE FIELD structure ON studio_component TYPE object;

-- Semaine 2 : Ajout de variants
DEFINE FIELD variants ON studio_component TYPE object;
```

---

## 🚀 Plan d'Action Concret (Première Semaine)

### Lundi Matin (2h) : SurrealDB

```bash
# 1. Créer le fichier schéma
touch database/studio/studio_component.surql

# 2. Définir la table (copier depuis AMELIORATIONS_RENDU.md section 5)

# 3. Créer le seed test
touch reference/studio/component/test_button.surql

# 4. Tester dans SurrealDB
surreal sql --endpoint wss://...
> IMPORT database/studio/studio_component.surql;
> IMPORT reference/studio/component/test_button.surql;
> SELECT * FROM studio_component:test_button;
```

### Lundi Après-midi + Mardi : Parser TypeScript

```bash
# 1. Installer dépendances
npm install zustand react-router-dom vitest

# 2. Créer structure
mkdir -p lib/studio/parser
mkdir -p tests/studio/parser

# 3. Implémenter resolveTemplate.ts avec tests
# 4. Implémenter resolveProps.ts avec tests
# 5. etc.
```

### Mercredi - Jeudi : Connexion

```bash
# 1. Créer useStudioComponent hook
# 2. Créer StudioComponentRenderer
# 3. Tester avec le seed test_button
```

### Vendredi : Tests d'Intégration

```bash
# 1. Test complet : DB → React → DOM
# 2. Valider le flux
# 3. Ajuster si besoin
```

---

## 🎯 Conclusion

**Réponse** : **Commencer par SurrealDB** (schéma minimal + 1 seed), puis développer le parser TypeScript avec des données mock, puis connecter les deux.

**Temps estimé** :
- SurrealDB : **3 heures** (schéma + seed)
- Parser TypeScript : **3 jours** (avec tests)
- Connexion : **2 jours**

**Total première semaine** : Schéma DB + Parser fonctionnel + 1 composant testé end-to-end.

---

**Cette approche garantit** :
- ✅ Structure claire dès le départ
- ✅ Tests possibles sans DB réelle
- ✅ Progression itérative et sécurisée
- ✅ Pas de refactoring majeur

🎨🚀 **Bonne implémentation !**


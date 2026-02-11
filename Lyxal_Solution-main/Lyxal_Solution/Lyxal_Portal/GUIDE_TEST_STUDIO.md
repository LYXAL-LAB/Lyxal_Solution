# 🧪 Guide de Test - Studio Runtime

## Comment Tester le Rendu 100% DB-Driven

### ✅ Ce qui est Prêt

1. ✅ Schéma `studio_page` créé dans SurrealDB
2. ✅ Schéma `studio_component` créé dans SurrealDB  
3. ✅ Page `test_page` importée dans SurrealDB
4. ✅ Composant `test_button` importé dans SurrealDB
5. ✅ Code React : `StudioPageRenderer`, `StudioComponentRenderer`, etc.

---

## 🚀 Étapes pour Tester

### 1. Lancer l'Application

```bash
cd Lyxal_Portal
npm run dev
```

L'application démarre sur `http://localhost:5173` (ou le port configuré).

### 2. Accéder à la Page de Test

Dans votre navigateur, allez sur :

```
http://localhost:5173/test
```

**OU** naviguez manuellement depuis la page d'accueil si vous avez un lien.

### 3. Ce que Vous Devriez Voir

La page `test_page` devrait se charger **depuis SurrealDB** et afficher :

```
┌─────────────────────────────────────┐
│ Page de Test                        │ ← Titre depuis DB
│                                     │
│ Page de démonstration du rendu...   │ ← Description depuis DB
│                                     │
│ Test du composant test_button      │ ← H2
│ [Cliquez-moi !]                     │ ← Bouton depuis DB
│                                     │
│ [Bouton 1] [Bouton 2]               │ ← 2 boutons depuis DB
└─────────────────────────────────────┘
```

**Important** : Tout cela est rendu **sans code React en dur** ! Tout vient de la DB.

---

## 🔍 Vérifier que ça Fonctionne

### ✅ Si ça marche

Vous devriez voir :
- ✅ Le titre "Page de Test"
- ✅ La description
- ✅ 3 boutons cliquables
- ✅ Les boutons ont les labels corrects ("Cliquez-moi !", "Bouton 1", "Bouton 2")
- ✅ Le bouton "Bouton 2" est désactivé (disabled: true)

### ❌ Si ça ne marche pas

**Erreur "Loading..." qui ne s'arrête pas** :
- Vérifiez que SurrealDB est accessible
- Vérifiez la configuration dans `useSystemConfig`
- Ouvrez la console du navigateur pour voir les erreurs

**Erreur "Page not found"** :
- Vérifiez que la page `test_page` est bien importée dans SurrealDB
- Vérifiez avec MCP : `SELECT * FROM studio_page:test_page`

**Page blanche** :
- Ouvrez la console du navigateur (F12)
- Regardez les erreurs JavaScript
- Vérifiez les imports TypeScript

---

## 🧩 Comment ça Fonctionne

### Flux de Données

```
1. Vous tapez /test dans le navigateur
   ↓
2. AppRouter détecte /test
   ↓
3. Appelle <StudioTestPage />
   ↓
4. StudioTestPage appelle <StudioPageRenderer pageCode="test_page" />
   ↓
5. StudioPageRenderer :
   - useStudioPage('test_page') → Charge depuis SurrealDB
   - Reçoit page.content_structure (JSON complet)
   ↓
6. StructureRenderer parse content_structure
   ↓
7. Pour chaque child :
   - Si type: "component" → <StudioComponentRenderer code="test_button" />
   - useStudioComponent('test_button') → Charge depuis SurrealDB
   - parseComponent(component.structure, props)
   ↓
8. React.render() → DOM final
```

### Aucun Code en Dur

**Avant** (code en dur) :
```tsx
export const TestPage = () => {
  return (
    <div>
      <button>Click me</button>  ← Code en dur
    </div>
  );
};
```

**Maintenant** (100% DB-driven) :
```tsx
export const TestPage = () => {
  return <StudioPageRenderer pageCode="test_page" />;  ← Tout en DB
};
```

La structure complète vient de `studio_page:test_page.content_structure`.

---

## 🎯 Prochaines Étapes

Une fois que `/test` fonctionne, vous pouvez :

1. **Modifier la page dans la DB** :
   ```surql
   UPDATE studio_page:test_page SET
     content_structure.children[1].children[1].props.label = "Nouveau Label";
   ```
   Rechargez la page → Changement visible **sans redéployer** !

2. **Créer de nouvelles pages** en DB avec `content_structure`

3. **Créer de nouveaux composants** en DB avec `studio_component`

4. **Tout est modifiable via SurrealDB** sans toucher au code React !

---

## 💡 Astuce

Ouvrez les **DevTools du navigateur** (F12) pour voir :
- Les requêtes vers SurrealDB dans l'onglet Network
- Les logs de chargement dans la Console
- La structure React rendue dans l'onglet React DevTools


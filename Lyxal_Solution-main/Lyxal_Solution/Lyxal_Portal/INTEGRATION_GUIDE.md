# 🚀 **GUIDE D'INTÉGRATION - CircularMenu DB-driven**

## 📋 **Vue d'ensemble**

Votre système DB-driven est **COMPLET et PRÊT** ! Voici comment l'intégrer dans votre UI.

---

## 🗃️ **ÉTAPE 1 : Import des données DB**

### **Commande d'importation :**
```bash
# Depuis le dossier racine du projet
./studio/reference/studio/component/import_circular_menu_demo.sh
```

**Résultat attendu :**
- ✅ Composant `circular_menu` créé
- ✅ Page `circular_menu_demo` créée
- ✅ Tags, i18n, traductions importés

---

## 🛣️ **ÉTAPE 2 : Ajout de la route**

### **Dans votre router (ex: App.tsx) :**
```tsx
import CircularMenuDemoPage from '@/pages/CircularMenuDemoPage';

// Dans vos routes :
<Route path="/demo/circular-menu" element={<CircularMenuDemoPage />} />
```

### **Ou directement dans le JSX :**
```tsx
import { StudioPageRenderer } from '@/components/studio';

<Route
  path="/demo/circular-menu"
  element={
    <StudioErrorBoundary>
      <StudioPageRenderer pageCode="circular_menu_demo" />
    </StudioErrorBoundary>
  }
/>
```

---

## 🎯 **ÉTAPE 3 : Test de l'intégration**

### **Accès à la démo :**
```
http://localhost:3000/demo/circular-menu
```

### **Ce que vous verrez :**
- ✅ **6 exemples** de menus circulaires différents
- ✅ **Animations fluides** (CSS transitions)
- ✅ **Actions fonctionnelles** (alerts, navigation simulée)
- ✅ **Responsive** et stylisé avec Tailwind

---

## 🧩 **Utilisation dans votre code**

### **Rendre un composant individuel :**
```tsx
import { StudioComponentRenderer } from '@/components/studio';

<StudioComponentRenderer
  code="circular_menu"
  props={{
    items: [
      { icon: "user", action: { type: "navigation", url: "/profile" } },
      { icon: "settings", action: { type: "modal", modal: "settings" } }
    ],
    radius: 80
  }}
/>
```

### **Rendre une page complète :**
```tsx
import { StudioPageRenderer } from '@/components/studio';

<StudioPageRenderer pageCode="circular_menu_demo" />
```

---

## 🔧 **Architecture Technique**

### **Composants existants utilisés :**
- ✅ **`StudioComponentRenderer`** - Rend les composants DB
- ✅ **`StudioPageRenderer`** - Rend les pages DB
- ✅ **`StructureRenderer`** - Parse la structure JSON
- ✅ **`ContextManager`** - Gestion du contexte
- ✅ **Actions system** - Navigation, state, modals

### **Hooks utilisés :**
- ✅ **`useStudioComponent`** - Charge depuis DB
- ✅ **`useStudioPage`** - Charge page depuis DB
- ✅ **`useActionHandler`** - Gestion des actions
- ✅ **`useStudioState`** - State global

---

## 🎨 **Personnalisation Avancée**

### **Modifier un composant en DB :**
```surql
-- Changer la couleur du menu
UPDATE studio_component:circular_menu SET
  structure.children[0].props.className = ["bg-blue-500", "hover:bg-blue-600"];

-- Ajouter une animation
UPDATE studio_component:circular_menu SET
  structure.children[1].props.className += ["animate-pulse"];
```

### **Créer une variante :**
```surql
-- Nouveau composant basé sur circular_menu
CREATE studio_component:circular_menu_dark = {
  // Copier et modifier la structure originale
  structure: studio_component:circular_menu.structure,
  // Override les couleurs pour thème sombre
};
```

---

## 🚨 **Dépannage**

### **Erreur "Component not found" :**
```bash
# Vérifier que l'import a réussi
surreal sql --conn http://localhost:8000 --ns lyxal --db studio \
  --query 'SELECT * FROM studio_component:circular_menu;'
```

### **Erreur "Page not found" :**
```bash
# Vérifier la page
surreal sql --conn http://localhost:8000 --ns lyxal --db studio \
  --query 'SELECT * FROM studio_page:circular_menu_demo;'
```

### **Actions ne fonctionnent pas :**
- Vérifier que `useActionHandler` est configuré
- Vérifier les types d'actions supportés (navigate, state, modal, alert)

---

## 🎉 **RÉSULTAT FINAL**

**Votre CircularMenu est maintenant :**

- ✅ **100% DB-driven** (pas de code React en dur)
- ✅ **Modifiable sans redéploiement** (UPDATE en DB)
- ✅ **Réutilisable** partout dans l'app
- ✅ **Personnalisable** par configuration
- ✅ **Intégré** dans votre architecture existante

**Accédez à `/demo/circular-menu` pour voir la magie opérer !** ✨

---

**Prochaine étape : Créez vos propres composants DB-driven !** 🚀

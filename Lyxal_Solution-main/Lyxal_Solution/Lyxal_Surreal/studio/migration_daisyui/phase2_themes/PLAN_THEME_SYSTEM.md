# 🟡 PHASE 2 : SYSTÈME DE MAPPING CSS RELATIONNEL

## 🎯 OBJECTIF
Créer un système Database-Driven de mapping CSS relationnel (inspiré du système d'icônes) qui remplace DaisyUI avec une flexibilité maximale pour tous les frameworks CSS.

## 🏗️ ARCHITECTURE ADOPTÉE : DATABASE-DRIVEN PURE

### ✅ **Principe Fondamental**
**Pas d'adaptateurs TypeScript** qui nécessitent des redéploiements. Tout est géré en base de données comme le système d'icônes :

```
icon_seeds (dictionnaire) → icon_mapping (relations) → utilisation
css_dictionary (dictionnaire) → css_mapping (relations) → utilisation
```

### ✅ **Avantages Clés**
- **Ajout de frameworks** : `CREATE` en DB (pas de code)
- **Modification mappings** : `UPDATE` en DB (pas de redéploiement)
- **Nouveaux thèmes** : Overrides automatiques
- **Évolutivité** : Support illimité de frameworks

---

## 📋 TABLES À CRÉER

### ✅ **Tables Déplacées dans `database/theme/css/`**

#### 1. **`css_framework`** : Frameworks CSS Disponibles ➕ AJOUTÉ
**Localisation** : `database/theme/css/css_framework.surql`
- Définit les frameworks supportés (Tailwind, Bootstrap, Material, etc.)
- Métadonnées et configuration par framework
- Validation des frameworks autorisés

#### 2. **`css_dictionary`** : Éléments CSS de Base
**Localisation** : `database/theme/css/css_dictionary.surql`
```surql
DEFINE TABLE css_dictionary SCHEMAFULL;
DEFINE FIELD name, category, base_styles, responsive, semantic_meaning...
```
- Dictionnaire des éléments CSS (boutons, inputs, cards)
- Styles de base indépendants du framework
- Métadonnées sémantiques

#### 3. **`css_framework_mapping`** : Mappings par Framework
**Localisation** : `database/theme/css/css_framework_mapping.surql`
```surql
DEFINE TABLE css_framework_mapping SCHEMAFULL;
DEFINE FIELD css_element, framework, mapped_classes, custom_css, priority...
```
- Traduction élément → classes framework
- Mappings spécifiques par framework (Tailwind, Bootstrap, etc.)
- Gestion des priorités

#### 4. **`css_theme_mapping`** : Overrides par Thème
**Localisation** : `database/theme/css/css_theme_mapping.surql`
```surql
DEFINE TABLE css_theme_mapping SCHEMAFULL;
DEFINE FIELD css_element, theme, custom_classes, custom_css, priority...
```
- Personnalisation White-Label par thème
- Overrides spécifiques tenant/thème
- Gestion des priorités d'override

#### 5. **Extension studio_config**
```surql
-- À ajouter dans studio_config
DEFINE FIELD css_framework ON TABLE studio_config TYPE string DEFAULT "tailwind";
DEFINE FIELD supported_frameworks ON TABLE studio_config TYPE array<string>;
```

---

## 🎨 EXEMPLES CONCRETS

### **Élément de Base : Bouton Primaire**
```surql
CREATE css_dictionary:primary_button SET
  name = "Bouton Primaire",
  category = "button",
  semantic_meaning = "action",
  base_styles = {
    display = "inline-flex",
    align_items = "center",
    justify_content = "center",
    font_weight = "500",
    cursor = "pointer",
    transition = "all 0.2s ease",
    user_select = "none"
  },
  responsive = {
    mobile = {
      padding = "0.5rem 1rem",
      font_size = "0.875rem",
      min_height = "2.5rem"
    },
    desktop = {
      padding = "0.75rem 1.5rem",
      font_size = "1rem",
      min_height = "3rem"
    }
  };
```

### **Mapping Tailwind**
```surql
CREATE css_framework_mapping:primary_button_tailwind SET
  css_element = css_dictionary:primary_button,
  framework = "tailwind",
  mapped_classes = [
    "inline-flex", "items-center", "justify-center",
    "font-medium", "cursor-pointer", "select-none",
    "transition-all", "duration-200", "ease-in-out"
  ],
  custom_css = "
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    min-height: 3rem;
    background: var(--color-primary);
    color: var(--color-on-primary);
    border-radius: var(--border-radius);
  ",
  priority = 1;
```

### **Mapping Bootstrap**
```surql
CREATE css_framework_mapping:primary_button_bootstrap SET
  css_element = css_dictionary:primary_button,
  framework = "bootstrap",
  mapped_classes = ["btn", "btn-primary", "d-inline-flex", "align-items-center", "justify-content-center"],
  custom_css = "
    font-weight: 500;
    cursor: pointer;
    user-select: none;
    transition: all 0.2s ease;
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    min-height: 3rem;
    border-radius: var(--border-radius);
  ",
  priority = 1;
```

### **Override Thème Corporate**
```surql
CREATE css_theme_mapping:primary_button_corporate SET
  css_element = css_dictionary:primary_button,
  theme = studio_theme:corporate,
  custom_classes = ["shadow-lg"],
  custom_css = "
    background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    transform: translateY(0);
    transition: transform 0.2s ease;
  ",
  priority = 10; -- Override les mappings de base
```

---

## ⚙️ FONCTION DE RÉSOLUTION

### **fn::resolve_css_classes()**
```surql
DEFINE FUNCTION fn::resolve_css_classes(
  $element_code: string,
  $framework: string,
  $theme: option<record<studio_theme>>
) {
  LET $element = SELECT * FROM css_dictionary WHERE id = $element_code;
  LET $framework_mapping = SELECT * FROM css_framework_mapping
    WHERE css_element = $element AND framework = $framework
    ORDER BY priority DESC LIMIT 1;

  LET $theme_mapping = IF $theme THEN (
    SELECT * FROM css_theme_mapping
    WHERE css_element = $element AND theme = $theme
    ORDER BY priority DESC LIMIT 1
  ) ELSE NONE;

  RETURN {
    base_classes: $framework_mapping.mapped_classes,
    theme_classes: $theme_mapping.custom_classes OR [],
    custom_css: $theme_mapping.custom_css OR $framework_mapping.custom_css,
    responsive: $element.responsive
  };
};
```

---

## 🎯 UTILISATION FRONTEND

### **Hook React**
```typescript
const useCssClasses = (elementCode: string) => {
  const { framework, theme } = useTenantConfig();

  return useQuery({
    queryKey: ['css-classes', elementCode, framework, theme],
    queryFn: () => db.query(`
      SELECT fn::resolve_css_classes($element_code, $framework, $theme)
    `, { element_code: elementCode, framework, theme })
  });
};
```

### **Utilisation Composant**
```tsx
const MyButton = ({ children }) => {
  const { data: cssClasses } = useCssClasses('primary_button');

  const allClasses = [
    ...cssClasses.base_classes,
    ...cssClasses.theme_classes
  ].join(' ');

  return (
    <button
      className={allClasses}
      style={{ cssText: cssClasses.custom_css }}
    >
      {children}
    </button>
  );
};
```

---

## 🚀 AVANTAGES VS APPROCHE ADAPTATEUR

| Aspect | Adaptateurs TypeScript | Mapping Relationnel |
|--------|----------------------|-------------------|
| **Ajout framework** | 🔴 Redéploiement | ✅ `CREATE` en DB |
| **Modification** | 🔴 Code + build | ✅ `UPDATE` en DB |
| **Maintenance** | 🔴 Complexe | ✅ Simple |
| **Performance** | ✅ Optimisé | ✅ + Cache DB |
| **Flexibilité** | 🟡 Limitée | ✅ Maximale |
| **Évolutivité** | 🟡 Code à maintenir | ✅ Auto-scaling |

---

## 📋 PLAN DE DÉVELOPPEMENT PHASE 2

### **Semaine 1 : Architecture & Tables**
- [ ] Créer table `css_dictionary`
- [ ] Créer table `css_framework_mapping`
- [ ] Créer table `css_theme_mapping`
- [ ] Étendre `studio_config` pour framework
- [ ] Créer fonction `fn::resolve_css_classes()`

### **Semaine 2 : Éléments & Mappings de Base**
- [ ] Peupler `css_dictionary` avec éléments essentiels
- [ ] Créer mappings Tailwind pour tous les éléments
- [ ] Tester la résolution automatique
- [ ] Valider l'intégration frontend
- [ ] Documentation complète

---

## 🎯 RÉSULTAT ATTENDU

**Un système où :**
- ✅ **Ajout Bootstrap** = `CREATE css_framework_mapping`
- ✅ **Nouveau thème** = `CREATE css_theme_mapping`
- ✅ **Modification bouton** = `UPDATE` en DB
- ✅ **Zéro redéploiement** pour changements CSS

**Database-Driven CSS, comme les icônes !** 🎨⚡

---

*Architecture validée : [DATE]*
*Approche adoptée : Mapping relationnel Database-Driven*
# 🎨 Frameworks CSS - Données de Référence

Ce dossier contient les **données de référence** pour les frameworks CSS supportés par Lyxal Studio.

## 📁 Structure

```
reference/theme/css/
├── README.md                    # Ce fichier
├── index.surql                  # Catalogue des frameworks
├── tailwind.surql              # Framework par défaut
├── bootstrap.surql             # Framework alternatif
├── material_design.surql       # Framework alternatif
├── css_framework_keys.surql    # 🔤 Clés i18n (6 clés)
├── css_framework_translations.surql  # 🌍 Traductions i18n (30 relations)
├── icons_to_create.surql       # 📋 Guide création icônes (6)
├── urls_to_create.surql        # 📋 Guide création URLs (~15)
└── [futurs frameworks...]
```

## 🎯 Frameworks Disponibles

### ✅ **Tailwind CSS** (Par Défaut)
- **Fichier** : `tailwind.surql`
- **Type** : Utility-first
- **Status** : Actif, Défaut
- **Ordre** : 1
- **Fonctionnalités** : Dark mode, responsive, animations, custom colors

### ✅ **Bootstrap**
- **Fichier** : `bootstrap.surql`
- **Type** : Component-based
- **Status** : Actif
- **Ordre** : 2
- **Fonctionnalités** : JavaScript components, responsive, dark mode

### ✅ **Material Design**
- **Fichier** : `material_design.surql`
- **Type** : Component-based
- **Status** : Actif
- **Ordre** : 3
- **Fonctionnalités** : Élévation, typography, guidelines Google

## 🔗 Références Utilisées

### Icônes (à créer)
- `icon:tailwind_icon_light`
- `icon:tailwind_icon_dark`
- `icon:bootstrap_icon_light`
- `icon:bootstrap_icon_dark`
- `icon:material_icon_light`
- `icon:material_icon_dark`

### URLs (à créer)
- `url:tailwind_css_cdn`
- `url:bootstrap_css_cdn`
- `url:bootstrap_js_cdn`
- `url:material_css_cdn`
- `url:material_js_cdn`
- `url:roboto_font`
- `url:tailwind_official`
- `url:tailwind_docs`
- `url:tailwind_github`
- `url:bootstrap_official`
- `url:bootstrap_docs`
- `url:bootstrap_github`
- `url:material_official`
- `url:material_docs`
- `url:material_github`

### Clés i18n ✅ **CRÉÉES**
- ✅ `i18n_key:framework_tailwind_name`
- ✅ `i18n_key:framework_tailwind_description`
- ✅ `i18n_key:framework_bootstrap_name`
- ✅ `i18n_key:framework_bootstrap_description`
- ✅ `i18n_key:framework_material_name`
- ✅ `i18n_key:framework_material_description`

**Fichier** : `css_framework_keys.surql`

#### Détails des Clés

##### Pour Tailwind CSS
- **`i18n_key:framework_tailwind_name`**
  - Description : Nom d'affichage du framework Tailwind CSS
  - Usage : Interface utilisateur (sélecteur de framework)

- **`i18n_key:framework_tailwind_description`**
  - Description : Description détaillée du framework Tailwind CSS
  - Usage : Info-bulles et documentation

##### Pour Bootstrap
- **`i18n_key:framework_bootstrap_name`**
  - Description : Nom d'affichage du framework Bootstrap CSS

- **`i18n_key:framework_bootstrap_description`**
  - Description : Description détaillée du framework Bootstrap CSS

##### Pour Material Design
- **`i18n_key:framework_material_name`**
  - Description : Nom d'affichage du framework Material Design

- **`i18n_key:framework_material_description`**
  - Description : Description détaillée du framework Material Design

#### Traductions 🌍 **CRÉÉES**
**30 traductions** (6 clés × 5 langues) dans `css_framework_translations.surql` :

##### Langues supportées ✅
- ✅ **Français (fr)** : Interface principale
- ✅ **Anglais (en)** : Documentation
- ✅ **Italien (it)** : Marchés italophones
- ✅ **Espagnol (es)** : Marchés hispanophones
- ✅ **Allemand (de)** : Marchés germanophones

##### Exemples de traductions

###### Français
- `framework_tailwind_name` → "Tailwind CSS"
- `framework_tailwind_description` → "Framework CSS utility-first moderne et flexible"
- `framework_bootstrap_name` → "Bootstrap"
- `framework_bootstrap_description` → "Framework CSS component-based populaire avec JavaScript"
- `framework_material_name` → "Material Design"
- `framework_material_description` → "Framework basé sur les guidelines Material Design de Google"

###### Anglais
- `framework_tailwind_name` → "Tailwind CSS"
- `framework_tailwind_description` → "Modern and flexible utility-first CSS framework"

*(Italien, Espagnol, Allemand : traductions complètes disponibles)*

## 🚀 Utilisation

### Importer dans la base
```bash
# Depuis le dossier studio
# 1. Importer les clés i18n d'abord
surreal import reference/theme/css/css_framework_keys.surql
surreal import reference/theme/css/css_framework_translations.surql

# 2. Puis importer les frameworks (quand icônes/URLs créées)
surreal import reference/theme/css/tailwind.surql
surreal import reference/theme/css/bootstrap.surql
surreal import reference/theme/css/material_design.surql
```

### Vérifier l'importation
```surql
-- Lister tous les frameworks
SELECT identity.value, status.is_default, metadata.order
FROM css_framework ORDER BY metadata.order;

-- Vérifier les dépendances
SELECT identity.value, config.dependencies
FROM css_framework;
```

### Utilisation dans l'application
```typescript
// Récupérer le framework par défaut
const defaultFramework = await db.query(`
  SELECT * FROM css_framework
  WHERE status.is_default = true
`);

// Récupérer un framework spécifique
const tailwind = await db.query(`
  SELECT * FROM css_framework
  WHERE identity.value = "tailwind"
`);
```

## 📋 TODO - Éléments à Créer

### ✅ **GUIDES TECHNIQUES CRÉÉS**
- ✅ **`icons_to_create.surql`** : Guide complet pour créer les 6 icônes
- ✅ **`urls_to_create.surql`** : Guide complet pour créer les ~15 URLs

### Priorité 1 : Icônes
- [ ] **Consulter le guide** : `icons_to_create.surql`
- [ ] Télécharger les logos officiels des frameworks
- [ ] Optimiser et uploader sur Bunny CDN
- [ ] Créer les records dans la table `icon`

### Priorité 2 : URLs
- [ ] **Consulter le guide** : `urls_to_create.surql`
- [ ] Configurer les CDN externes (Tailwind, Bootstrap, Material)
- [ ] Créer les URLs Bunny pour les icônes
- [ ] Créer les records dans la table `url`

### Priorité 3 : i18n ✅ **TERMINÉ**
- [x] Créer les clés de traduction
- [x] Les ajouter dans la table `i18n_key`
- [x] Créer les traductions dans `translation` (fr, en, it, es, de)

## 🎯 Prochaines Étapes

1. **Importer les clés i18n** : `css_framework_keys.surql` + `css_framework_translations.surql`
2. **Créer les icônes** (suivre `icons_to_create.surql`)
3. **Créer les URLs** (suivre `urls_to_create.surql`)
4. **Importer les frameworks** dans la DB
5. **Tester l'intégration** avec le système de mapping CSS

---

*Date de création : [DATE]*
*Frameworks supportés : 3 (Tailwind, Bootstrap, Material Design)*
*Framework par défaut : Tailwind CSS*

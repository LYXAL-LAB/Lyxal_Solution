# 🔍 Analyse Pattern `record` et Couleurs

**Date** : 2025-01-27  
**Objectif** : Comprendre les modifications sur les `record` types et clarifier l'usage des couleurs

---

## 📋 Pattern `record` dans les Tables Existantes

### Pattern Observé dans `auth_type.surql` (modifié)

```surql
-- ✅ Pattern CORRECT pour record<i18n_key> (non optionnel)
DEFINE FIELD identity.display_name_i18n ON auth_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT '...';

-- ✅ Pattern CORRECT pour record<icon> (non optionnel)
DEFINE FIELD presentation.icon ON auth_type 
    TYPE record<icon>
    REFERENCE ON DELETE REJECT
    COMMENT '...';

-- ✅ Pattern CORRECT pour record<transmission_method> (non optionnel)
DEFINE FIELD http.transmission_method ON auth_type 
    TYPE record<transmission_method>
    REFERENCE ON DELETE REJECT
    COMMENT '...';
```

**Conclusion** : Pour les `record<...>` **non optionnels**, on utilise seulement `REFERENCE ON DELETE REJECT` (pas de `VALUE type::thing()`).

---

### Pattern dans `provider.surql` (pour référence)

```surql
-- ✅ Pattern pour option<record<url>>
DEFINE FIELD config.urls.website ON provider 
    TYPE option<record<url>>
    VALUE type::thing('url', $value)
    REFERENCE ON DELETE REJECT
    COMMENT '...';

-- ✅ Pattern pour option<record<logo_brand>>
DEFINE FIELD presentation.logo_light ON provider 
    TYPE option<record<logo_brand>>
    VALUE type::thing('logo_brand', $value)
    REFERENCE ON DELETE REJECT
    COMMENT '...';
```

**Conclusion** : Pour les `option<record<...>>`, on utilise `VALUE type::thing('table_name', $value)` + `REFERENCE ON DELETE REJECT`.

---

## 🎨 Usage des Couleurs

### Dans `auth_type.surql`

```surql
DEFINE FIELD presentation.color ON auth_type 
    TYPE string
    ASSERT string::starts_with($value, '#') AND string::len($value) = 7
    COMMENT 'Couleur hexadécimale (ex: #4285F4).';

DEFINE FIELD presentation.color_daisy ON auth_type 
    TYPE string
    ASSERT $value IN ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']
    COMMENT 'Classe de couleur DaisyUI (ex: primary, secondary, accent, neutral, info, success, warning, error).';
```

**Usage** : 
- `presentation.color` : Couleur hexadécimale pour les **tags/badges** dans l'UI
- `presentation.color_daisy` : Classe DaisyUI pour les **tags/badges** (cohérence avec le design system)

**Exemple d'utilisation** :
- Tag "OAuth2" → couleur `#4285F4` + classe DaisyUI `primary`
- Tag "API Key" → couleur `#FF6B35` + classe DaisyUI `warning`

---

## ✅ Corrections à Appliquer sur les Nouvelles Tables

### Table `user_service_credential`

**Champs à vérifier** :
- `identity.description_i18n` : `TYPE option<record<i18n_key>>` → ✅ Correct (seulement `REFERENCE`)
- Pas de `VALUE type::thing()` nécessaire pour `option<record<i18n_key>>`

### Table `integration_log`

**Champs à vérifier** :
- Tous les `record<...>` sont non optionnels → ✅ Correct (seulement `REFERENCE`)

### Table `response_mapping`

**Champs à vérifier** :
- `identity.description_i18n` : `TYPE option<record<i18n_key>>` → ✅ Correct (seulement `REFERENCE`)

### Table `webhook_config`

**Champs à vérifier** :
- `identity.display_name_i18n` : `TYPE record<i18n_key>` → ✅ Correct (seulement `REFERENCE`)
- `identity.description_i18n` : `TYPE option<record<i18n_key>>` → ✅ Correct (seulement `REFERENCE`)
- `presentation.icon` : `TYPE option<record<icon>>` → ✅ Correct (seulement `REFERENCE`)

---

## 📝 Règles à Retenir

### Pour les `record<...>` types

1. **`record<...>` non optionnel** :
   ```surql
   TYPE record<i18n_key>
   REFERENCE ON DELETE REJECT
   ```
   ❌ Pas de `VALUE type::thing()`

2. **`option<record<...>>`** :
   ```surql
   TYPE option<record<i18n_key>>
   REFERENCE ON DELETE REJECT
   ```
   ❌ Pas de `VALUE type::thing()` pour `i18n_key`, `icon`, `user`, `service`, etc.
   
   ✅ Mais `VALUE type::thing()` pour `url`, `logo_brand` (tables spéciales)

### Exception : Tables spéciales (`url`, `logo_brand`)

Pour `option<record<url>>` et `option<record<logo_brand>>`, utiliser :
```surql
TYPE option<record<url>>
VALUE type::thing('url', $value)
REFERENCE ON DELETE REJECT
```

---

## 🎨 Couleurs pour Tags/Badges

**Confirmé** : `presentation.color` et `presentation.color_daisy` sont pour les **tags/badges** dans l'UI.

**Usage** :
- Badge "OAuth2" → `color: "#4285F4"` + `color_daisy: "primary"`
- Badge "API Key" → `color: "#FF6B35"` + `color_daisy: "warning"`
- Badge "Basic Auth" → `color: "#F44336"` + `color_daisy: "error"`

---

## ✅ Vérification des Nouvelles Tables

Toutes les nouvelles tables utilisent le bon pattern :
- ✅ `record<i18n_key>` : seulement `REFERENCE ON DELETE REJECT`
- ✅ `option<record<i18n_key>>` : seulement `REFERENCE ON DELETE REJECT`
- ✅ `record<user>`, `record<service>`, etc. : seulement `REFERENCE ON DELETE REJECT`

**Pas de corrections nécessaires** pour les nouvelles tables ! ✅

---

**Confirmation** : Les couleurs sont bien pour les tags/badges dans l'UI ! 🎨


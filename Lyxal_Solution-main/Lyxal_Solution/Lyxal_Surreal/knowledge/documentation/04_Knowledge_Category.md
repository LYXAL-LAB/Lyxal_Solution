# 📂 Table : `knowledge_category`

## 🎯 Objectif

La table `knowledge_category` représente les **catégories principales** permettant d'organiser les topics de connaissance par domaine.  
Chaque catégorie regroupe des topics thématiques similaires (ex : *DATA_DEFINITION*, *QUERIES*, *PERMISSIONS*) et sert de niveau intermédiaire entre le domaine et les topics.

Elle est utilisée pour :
- Structurer la navigation hiérarchique dans l'UI
- Organiser les topics par thématique au sein d'un domaine
- Permettre un filtrage et une recherche plus précise
- Faciliter la compréhension IA du contexte organisationnel

---

## 🧱 Structure de la table

| Bloc | Description |
|------|-------------|
| `identity.*` | Code unique, slug, et clés i18n (nom et description) |
| `metadata.*` | Métadonnées techniques (version, statut actif, ordre d'affichage) |

---

## 📎 Champs principaux

### 🆔 Identité

#### `identity.code`
- **Type** : `string`
- **Format** : `UPPER_SNAKE_CASE` (ex: `"DATA_DEFINITION"`, `"QUERIES"`, `"PERMISSIONS"`)
- **Contrainte** : Obligatoire, unique, majuscules uniquement
- **Rôle** : Identifiant unique de la catégorie pour références internes

#### `identity.slug`
- **Type** : `string`
- **Format** : Slug lisible (ex: `"data-definition"`, `"queries"`, `"permissions"`)
- **Contrainte** : Obligatoire, unique
- **Rôle** : Identifiant pour URL et navigation UI

#### `identity.label_key`
- **Type** : `record<i18n_key>`
- **Rôle** : Clé i18n du nom court de la catégorie (pour UI, menus, filtres)
- **Exemple** : `i18n_key:cat_data_definition_label`

#### `identity.description_key`
- **Type** : `record<i18n_key>`
- **Rôle** : Clé i18n de la description longue de la catégorie
- **Exemple** : `i18n_key:cat_data_definition_description`

---

### ⚙️ Métadonnées

| Champ | Type | Description |
|-------|------|-------------|
| `metadata.version_label` | `option<string>` | Version fonctionnelle (ex: `"v1.0"`, `"v2.1"`) |
| `metadata.is_active` | `bool` | Statut actif (défaut: `true`) - Active/inactive pour utilisation |
| `metadata.display_order` | `option<number>` | Ordre d'affichage UI (plus petit = affiché en premier) |

---

## 🔗 Relations

### Relation avec `knowledge_topic`

Un topic appartient **obligatoirement** à une catégorie :

```surql
-- Dans knowledge_topic
DEFINE FIELD category ON TABLE knowledge_topic
    TYPE record<knowledge_category>
    REFERENCE ON DELETE REJECT;
```

**Règle** : Si une catégorie est supprimée, les topics qui y sont liés ne peuvent pas être supprimés automatiquement (REJECT). Il faut d'abord changer la catégorie des topics ou les supprimer manuellement.

### Relation avec `knowledge_sub_category`

Une sous-catégorie appartient **obligatoirement** à une catégorie :

```surql
-- Dans knowledge_sub_category
DEFINE FIELD category ON TABLE knowledge_sub_category
    TYPE record<knowledge_category>
    REFERENCE ON DELETE CASCADE;
```

**Règle** : Si une catégorie est supprimée, toutes ses sous-catégories sont supprimées automatiquement (CASCADE).

---

## 📊 Hiérarchie complète

```
knowledge_domain (niveau 1)
    └── knowledge_category (niveau 2)
            ├── knowledge_sub_category (niveau 2.5 - optionnel)
            └── knowledge_topic (niveau 3)
                    └── knowledge_content (niveau 4)
```

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_category_code` | `identity.code` | UNIQUE | Recherche rapide par code |
| `idx_category_slug` | `identity.slug` | UNIQUE | Navigation UI/URL |
| `idx_category_active` | `metadata.is_active` | Normal | Filtrage des catégories actives |

---

## 📝 Exemples d'utilisation

### ✅ Créer une catégorie

```surql
CREATE knowledge_category SET
    identity.code = "DATA_DEFINITION",
    identity.slug = "data-definition",
    identity.label_key = i18n_key:cat_data_definition_label,
    identity.description_key = i18n_key:cat_data_definition_description,
    metadata.is_active = true,
    metadata.display_order = 1,
    metadata.version_label = "v1.0";
```

### ✅ Récupérer toutes les catégories actives triées

```surql
SELECT 
    identity.code,
    identity.slug,
    identity.label_key,
    metadata.display_order
FROM knowledge_category
WHERE metadata.is_active = true
ORDER BY metadata.display_order ASC;
```

### ✅ Récupérer les topics d'une catégorie

```surql
SELECT 
    identity.code,
    identity.label_key,
    metadata.display_order
FROM knowledge_topic
WHERE category = knowledge_category:DATA_DEFINITION
    AND metadata.is_active = true
ORDER BY metadata.display_order ASC;
```

### ✅ Récupérer les sous-catégories d'une catégorie

```surql
SELECT 
    identity.code,
    identity.slug,
    identity.label_key,
    metadata.display_order
FROM knowledge_sub_category
WHERE category = knowledge_category:DATA_DEFINITION
    AND metadata.is_active = true
ORDER BY metadata.display_order ASC;
```

---

## 🧠 Impact IA

Les catégories permettent à l'IA de :

- **Contextualiser** : Comprendre le contexte organisationnel d'un topic
- **Filtrer** : Sélectionner les topics pertinents par catégorie
- **Naviguer** : Explorer la connaissance de manière hiérarchique
- **Générer** : Produire du contenu structuré selon la catégorie

---

## 🎯 Cas d'usage typiques

### 1. Navigation hiérarchique UI

```
Domaine: SURREAL_DB
  ├── Catégorie: DATA_DEFINITION
  │     ├── Topic: DEFINE_FIELD
  │     ├── Topic: DEFINE_TABLE
  │     └── Topic: DEFINE_INDEX
  ├── Catégorie: QUERIES
  │     ├── Topic: SELECT
  │     └── Topic: UPDATE
  └── Catégorie: PERMISSIONS
        └── Topic: DEFINE_PERMISSIONS
```

### 2. Filtrage par catégorie

Permet de filtrer les topics selon leur catégorie pour affiner les résultats de recherche.

### 3. Organisation thématique

Regroupe les topics liés pour faciliter la compréhension et la maintenance.

---

## 📋 Bonnes pratiques

1. **Naming** : Utiliser des codes descriptifs en `UPPER_SNAKE_CASE`
2. **Slug** : Utiliser des slugs cohérents et lisibles pour l'URL
3. **Ordre** : Utiliser `display_order` pour définir l'ordre d'affichage logique
4. **Version** : Utiliser `version_label` pour suivre les évolutions fonctionnelles
5. **Activation** : Désactiver (`is_active = false`) plutôt que supprimer pour garder l'historique

---

## 🧵 Résumé

La table `knowledge_category` :

- ✅ Organise les topics par catégorie thématique
- ✅ Facilite la navigation hiérarchique
- ✅ Permet un filtrage précis des connaissances
- ✅ Structure la connaissance pour l'IA et les humains
- ✅ Supporte l'internationalisation via clés i18n
- ✅ Indexée pour performance optimale

Elle constitue le **niveau 2** de la hiérarchie de connaissance Lyxal.


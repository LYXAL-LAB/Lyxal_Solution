# 📁 Table : `knowledge_sub_category`

## 🎯 Objectif

La table `knowledge_sub_category` représente les **sous-catégories optionnelles** permettant d'affiner l'organisation des topics au sein d'une catégorie principale.  
Chaque sous-catégorie permet un niveau supplémentaire de granularité (ex : *FIELD_TYPES* dans *DATA_DEFINITION*, *QUERY_FILTERS* dans *QUERIES*).

Elle est utilisée pour :
- Affiner la catégorisation lorsque nécessaire
- Permettre une organisation plus granulaire dans les domaines complexes
- Faciliter la navigation et la recherche dans les grandes catégories
- Améliorer la précision du filtrage IA

---

## 🧱 Structure de la table

| Bloc | Description |
|------|-------------|
| `category` | Référence vers la catégorie parente (obligatoire) |
| `identity.*` | Code unique, slug, et clés i18n (nom et description) |
| `metadata.*` | Métadonnées techniques (version, statut actif, ordre d'affichage) |

---

## 📎 Champs principaux

### 🔗 Relation parente

#### `category`
- **Type** : `record<knowledge_category>`
- **Contrainte** : Obligatoire, `REFERENCE ON DELETE CASCADE`
- **Rôle** : Catégorie parente à laquelle appartient cette sous-catégorie
- **Comportement** : Si la catégorie parente est supprimée, la sous-catégorie est supprimée automatiquement

---

### 🆔 Identité

#### `identity.code`
- **Type** : `string`
- **Format** : `UPPER_SNAKE_CASE` (ex: `"FIELD_TYPES"`, `"INDEX_TYPES"`, `"QUERY_FILTERS"`)
- **Contrainte** : Obligatoire, unique, majuscules uniquement
- **Rôle** : Identifiant unique de la sous-catégorie pour références internes

#### `identity.slug`
- **Type** : `string`
- **Format** : Slug lisible (ex: `"field-types"`, `"index-types"`, `"query-filters"`)
- **Contrainte** : Obligatoire, unique
- **Rôle** : Identifiant pour URL et navigation UI

#### `identity.label_key`
- **Type** : `record<i18n_key>`
- **Rôle** : Clé i18n du nom court de la sous-catégorie (pour UI, menus, filtres)
- **Exemple** : `i18n_key:subcat_field_types_label`

#### `identity.description_key`
- **Type** : `record<i18n_key>`
- **Rôle** : Clé i18n de la description longue de la sous-catégorie
- **Exemple** : `i18n_key:subcat_field_types_description`

---

### ⚙️ Métadonnées

| Champ | Type | Description |
|-------|------|-------------|
| `metadata.version_label` | `option<string>` | Version fonctionnelle (ex: `"v1.0"`, `"v2.1"`) |
| `metadata.is_active` | `bool` | Statut actif (défaut: `true`) - Active/inactive pour utilisation |
| `metadata.display_order` | `option<number>` | Ordre d'affichage UI (plus petit = affiché en premier) |

---

## 🔗 Relations

### Relation avec `knowledge_category` (parente)

Une sous-catégorie appartient **obligatoirement** à une catégorie :

```surql
DEFINE FIELD category ON TABLE knowledge_sub_category
    TYPE record<knowledge_category>
    REFERENCE ON DELETE CASCADE;
```

**Règle** : Suppression en cascade - si la catégorie est supprimée, toutes ses sous-catégories sont supprimées automatiquement.

### Relation avec `knowledge_topic` (enfants)

Un topic peut **optionnellement** appartenir à une sous-catégorie :

```surql
-- Dans knowledge_topic
DEFINE FIELD sub_category ON TABLE knowledge_topic
    TYPE option<record<knowledge_sub_category>>
    REFERENCE ON DELETE REJECT;
```

**Règle** : Optionnel - tous les topics n'ont pas besoin d'une sous-catégorie. Si une sous-catégorie est supprimée, les topics qui y sont liés ne peuvent pas être supprimés automatiquement (REJECT).

---

## 📊 Hiérarchie complète

```
knowledge_domain (niveau 1)
    └── knowledge_category (niveau 2)
            ├── knowledge_sub_category (niveau 2.5 - optionnel)
            │       └── knowledge_topic (niveau 3)
            │               └── knowledge_content (niveau 4)
            └── knowledge_topic (niveau 3 - sans sous-catégorie)
                    └── knowledge_content (niveau 4)
```

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_sub_category_code` | `identity.code` | UNIQUE | Recherche rapide par code |
| `idx_sub_category_slug` | `identity.slug` | UNIQUE | Navigation UI/URL |
| `idx_sub_category_category` | `category` | Normal | Jointures rapides avec la catégorie parente |
| `idx_sub_category_active` | `metadata.is_active` | Normal | Filtrage des sous-catégories actives |

---

## 📝 Exemples d'utilisation

### ✅ Créer une sous-catégorie

```surql
CREATE knowledge_sub_category SET
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "FIELD_TYPES",
    identity.slug = "field-types",
    identity.label_key = i18n_key:subcat_field_types_label,
    identity.description_key = i18n_key:subcat_field_types_description,
    metadata.is_active = true,
    metadata.display_order = 1,
    metadata.version_label = "v1.0";
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

### ✅ Récupérer les topics d'une sous-catégorie

```surql
SELECT 
    identity.code,
    identity.label_key,
    metadata.display_order
FROM knowledge_topic
WHERE sub_category = knowledge_sub_category:FIELD_TYPES
    AND metadata.is_active = true
ORDER BY metadata.display_order ASC;
```

### ✅ Navigation complète : Catégorie → Sous-catégories → Topics

```surql
SELECT 
    category.identity.code AS category_code,
    category.identity.label_key AS category_label,
    identity.code AS sub_category_code,
    identity.label_key AS sub_category_label,
    (SELECT COUNT() FROM knowledge_topic WHERE sub_category = knowledge_sub_category.id) AS topics_count
FROM knowledge_sub_category
WHERE category = knowledge_category:DATA_DEFINITION
    AND metadata.is_active = true
ORDER BY metadata.display_order ASC;
```

---

## 🎯 Quand utiliser une sous-catégorie ?

### ✅ Utiliser une sous-catégorie quand :

- Une catégorie contient **beaucoup de topics** (> 10-15 topics)
- Les topics peuvent être **regroupés thématiquement** au sein de la catégorie
- La navigation UI bénéficierait d'un **niveau supplémentaire**
- L'organisation hiérarchique améliore la **compréhension IA**

### ❌ Ne pas utiliser de sous-catégorie quand :

- La catégorie contient **peu de topics** (< 5 topics)
- Les topics sont **hétérogènes** et ne se regroupent pas naturellement
- La complexité supplémentaire n'apporte **pas de valeur**
- Le niveau de catégorie suffit pour **l'organisation**

---

## 🧠 Impact IA

Les sous-catégories permettent à l'IA de :

- **Affiner le contexte** : Comprendre la granularité organisationnelle
- **Améliorer la précision** : Filtrer plus précisément les topics pertinents
- **Naviguer efficacement** : Explorer la connaissance de manière hiérarchique fine
- **Générer du contenu structuré** : Produire du contenu selon la sous-catégorie

---

## 📋 Bonnes pratiques

1. **Utilisation optionnelle** : N'utiliser que lorsque nécessaire pour améliorer l'organisation
2. **Cohérence** : Respecter la hiérarchie Catégorie → Sous-catégorie → Topic
3. **Naming** : Utiliser des codes descriptifs en `UPPER_SNAKE_CASE`
4. **Slug** : Utiliser des slugs cohérents et lisibles pour l'URL
5. **Ordre** : Utiliser `display_order` pour définir l'ordre d'affichage logique
6. **Version** : Utiliser `version_label` pour suivre les évolutions fonctionnelles
7. **Activation** : Désactiver (`is_active = false`) plutôt que supprimer pour garder l'historique

---

## 🧵 Résumé

La table `knowledge_sub_category` :

- ✅ Affine l'organisation des topics au sein d'une catégorie
- ✅ Permet une granularité supplémentaire lorsque nécessaire
- ✅ Facilite la navigation dans les grandes catégories
- ✅ Améliore la précision du filtrage IA
- ✅ Supporte l'internationalisation via clés i18n
- ✅ Indexée pour performance optimale
- ⚠️ **Optionnelle** : À utiliser uniquement lorsque cela améliore l'organisation

Elle constitue le **niveau 2.5** optionnel de la hiérarchie de connaissance Lyxal.


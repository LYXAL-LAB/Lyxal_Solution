# 📘 Table : `knowledge_content`

## 🎯 Objectif

La table `knowledge_content` stocke chaque **unité de connaissance** liée à un topic.  
Il s'agit du cœur du système : chaque enregistrement représente un morceau de savoir exploitable par un humain et par une IA.

Un topic = plusieurs contenus de nature différente (exemples, explications, code, règles, patterns…).

**Structure U3-FLEX** : Multi-format flexible permettant de stocker texte, code, exemples, JSON, média, etc. dans une structure unifiée optimisée pour l'IA.

---

## 🧱 Structure

| Bloc | Description |
|------|-------------|
| `topic` | Référence vers le topic parent (obligatoire) |
| `identity.*` | Identité du contenu (slug, type, titre, description) |
| `content.*` | Contenu U3-FLEX (texte, code, exemples, JSON, média, contexte) |
| `tags` | Tags structurés pour catégorisation |
| `metadata.*` | Métadonnées (priorité, statut actif, version) |

---

## 🔗 Relations

| Table liée | Type | Description |
|------------|------|-------------|
| `knowledge_topic` | 1 → N | Un topic possède plusieurs contenus |
| `knowledge_content_type` | N → 1 | Type de contenu (référentiel dynamique) |
| `i18n_key` | N → N | Clés i18n pour tous les textes traduisibles |
| `tag` | N → N | Tags structurés pour catégorisation |

---

## 🧩 Champs principaux

### 🆔 `identity` - Identité du contenu

#### `identity.slug`
- **Type** : `string`
- **Contrainte** : Obligatoire, unique, minimum 3 caractères
- **Rôle** : Identifiant unique lisible pour UI et navigation (ex: `"define-field-basic-syntax"`)

#### `identity.content_type`
- **Type** : `record<knowledge_content_type>`
- **Contrainte** : Obligatoire, `REFERENCE ON DELETE REJECT`
- **Rôle** : Type de contenu depuis le référentiel dynamique (ex: `SYNTAX`, `RULE`, `EXAMPLE_CORRECT`, `REFERENCE`)

#### `identity.title_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n du titre court du contenu (optionnel)
- **Exemple** : `i18n_key:content_define_field_title`

#### `identity.description_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n de la description courte du contenu (optionnel)
- **Exemple** : `i18n_key:content_define_field_description`

---

### 📚 `content` - Contenu U3-FLEX (multi-format)

#### `content.text_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n du contenu textuel principal (explication lisible + structurée)
- **Exemple** : `i18n_key:content_define_field_explanation`

#### `content.code` - Array de blocs de code (multi-langage)

**⚠️ IMPORTANT** : Utilise la syntaxe wildcard `*` pour les arrays d'objets (voir `16_SurrealDB_Arrays_Objects_Syntax.md`)

- **Type** : `option<array<object>>`
- **Structure** : Array d'objets avec champs définis via wildcard `*`

##### `content.code.*.language`
- **Type** : `string`
- **Rôle** : Langage du code (ex: `"surql"`, `"js"`, `"json"`, `"python"`)

##### `content.code.*.value`
- **Type** : `string`
- **Rôle** : Code source (non traduit, reste en string)

##### `content.code.*.explanation_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n de l'explication du code (optionnelle)

#### `content.prompt`
- **Type** : `option<string>`
- **Rôle** : Version prompt-ready optimisée pour IA (peut rester en anglais/technique)

#### `content.json`
- **Type** : `option<object>`
- **Rôle** : Contenu structuré JSON (schéma, données, config, etc.) - non traduit

#### `content.context_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n du contexte d'utilisation, bonnes pratiques, do/don't, use cases

#### `content.examples` - Exemples corrects et incorrects

**⚠️ IMPORTANT** : Utilise la syntaxe wildcard `*` pour les arrays d'objets

##### `content.examples.correct` - Array d'exemples corrects
- **Type** : `option<array<object>>`

###### `content.examples.correct.*.text_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n de l'explication de l'exemple correct

###### `content.examples.correct.*.code`
- **Type** : `option<string>`
- **Rôle** : Code correct (si applicable)

##### `content.examples.incorrect` - Array d'exemples incorrects
- **Type** : `option<array<object>>`

###### `content.examples.incorrect.*.text_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n expliquant pourquoi cet exemple est incorrect

###### `content.examples.incorrect.*.code`
- **Type** : `option<string>`
- **Rôle** : Code incorrect (si applicable)

#### `content.media` - Médias associés
- **Type** : `option<array<record<url>>>`
- **Rôle** : Médias associés : images, PDF, vidéos, etc. via table `url`

#### `content.references` - Références vers autres contenus
- **Type** : `option<array<record<knowledge_content>>>`
- **Rôle** : Références rapides vers d'autres contenus de connaissance liés
- **Note** : Pour des relations structurées avec types spécifiques (prerequisite, dependency, etc.), utiliser la table `knowledge_content_relation`

**Exemple** :
```surql
-- Ajouter des références à un contenu
UPDATE knowledge_content:define-field-basics SET
    content.references = [
        knowledge_content:define-table-basics,
        knowledge_content:define-field-advanced
    ]
WHERE id = knowledge_content:define-field-basics;

-- Récupérer un contenu avec ses références
SELECT 
    id,
    identity.slug,
    content.references.*.identity.slug AS referenced_slugs
FROM knowledge_content:define-field-basics
FETCH content.references;
```

---

### 🏷️ `tags` - Catégorisation

- **Type** : `option<array<record<tag>>>`
- **Rôle** : Tags structurés provenant de la table globale `tag` pour catégorisation et filtrage

---

### ⚙️ `metadata` - Métadonnées

| Champ | Type | Description |
|-------|------|-------------|
| `metadata.priority` | `int` | Priorité d'affichage (défaut: `0`) |
| `metadata.is_active` | `bool` | Statut actif (défaut: `true`) |
| `metadata.version_label` | `string` | Version fonctionnelle (défaut: `"1.0.0"`) |
| `metadata.quality_score` | `number` | Score de qualité (0-1, défaut: `0.5`). Utilisé par l'IA pour filtrer et prioriser les contenus selon leur qualité |
| `metadata.analytics.view_count` | `int` | Nombre total de consultations/vues (défaut: `0`) |
| `metadata.analytics.last_viewed` | `option<datetime>` | Date et heure de la dernière consultation (optionnel) |
| `metadata.analytics.ai_usage_count` | `int` | Nombre d'utilisations spécifiques par des IA/agents IA (défaut: `0`) |

**Utilisation de `metadata.quality_score`** :
- `0.0` → Qualité très faible (contenu à revoir ou supprimer)
- `0.5` → Qualité moyenne (défaut)
- `1.0` → Excellente qualité (contenu validé et optimal)
- L'IA peut filtrer les contenus avec `metadata.quality_score >= 0.7` pour ne récupérer que les contenus de haute qualité

**Utilisation de `metadata.analytics`** :
Les métriques d'usage permettent de :
- 📊 **Identifier les contenus populaires** : Quels contenus sont les plus consultés ?
- 🔍 **Détecter les contenus obsolètes** : Contenus jamais consultés depuis longtemps
- 🤖 **Optimiser l'utilisation IA** : Suivre quels contenus sont utilisés par les IA
- 📈 **Mesurer l'impact** : Analyser l'efficacité du système de connaissance

**Exemple de tracking** :
```surql
-- Incrémenter le compteur de vue et mettre à jour la date
UPDATE knowledge_content:content_slug SET
    metadata.analytics.view_count = metadata.analytics.view_count + 1,
    metadata.analytics.last_viewed = time::now()
WHERE id = knowledge_content:content_slug;

-- Incrémenter spécifiquement le compteur IA
UPDATE knowledge_content:content_slug SET
    metadata.analytics.ai_usage_count = metadata.analytics.ai_usage_count + 1,
    metadata.analytics.view_count = metadata.analytics.view_count + 1,
    metadata.analytics.last_viewed = time::now()
WHERE id = knowledge_content:content_slug;

-- Requête : Contenus les plus consultés
SELECT 
    identity.slug,
    metadata.analytics.view_count,
    metadata.analytics.last_viewed,
    metadata.analytics.ai_usage_count
FROM knowledge_content
WHERE metadata.is_active = true
ORDER BY metadata.analytics.view_count DESC
LIMIT 10;
```

---

### 📚 Métadonnées d'entraînement IA (`metadata.training`)

Les métadonnées d'entraînement permettent de gérer l'export de contenus pour le fine-tuning de modèles IA spécialisés.

| Champ | Type | Description |
|-------|------|-------------|
| `metadata.training.included_in_training` | `bool` | Ce contenu est inclus dans les datasets d'entraînement IA (défaut: `false`) |
| `metadata.training.training_versions` | `array<string>` | Versions de datasets où ce contenu a été utilisé (ex: `["v1.0", "v1.1"]`, défaut: `[]`) |
| `metadata.training.training_weight` | `number` | Poids d'entraînement (1.0 = normal, 2.0 = double poids, 0.5 = demi-poids, défaut: `1.0`) |
| `metadata.training.last_training_date` | `option<datetime>` | Date de la dernière utilisation dans un dataset d'entraînement |

**Utilisation de `metadata.training`** :
- **Export sélectif** : Filtrer uniquement les contenus marqués `included_in_training = true`
- **Versioning** : Tracker quelles versions de datasets ont utilisé chaque contenu
- **Pondération** : Utiliser `training_weight` pour donner plus d'importance à certains contenus (ex: exemples validés = 2.0, contenus génériques = 0.5)
- **Suivi** : Enregistrer `last_training_date` pour savoir quand un contenu a été utilisé pour la dernière fois

**Exemple de gestion des métadonnées d'entraînement** :
```surql
-- Marquer un contenu pour inclusion dans les datasets d'entraînement
UPDATE knowledge_content:content_slug SET
    metadata.training.included_in_training = true,
    metadata.training.training_weight = 1.5
WHERE id = knowledge_content:content_slug;

-- Enregistrer qu'un contenu a été utilisé dans une version de dataset
UPDATE knowledge_content:content_slug SET
    metadata.training.training_versions = array::append(metadata.training.training_versions, "v1.0"),
    metadata.training.last_training_date = time::now()
WHERE id = knowledge_content:content_slug;

-- Requête : Contenus éligibles pour entraînement (haute qualité + marqués pour entraînement)
SELECT 
    identity.slug,
    identity.content_type->identity.code AS type,
    metadata.quality_score,
    metadata.training.training_weight,
    metadata.training.training_versions
FROM knowledge_content
WHERE metadata.is_active = true
    AND metadata.quality_score >= 0.7
    AND metadata.training.included_in_training = true
ORDER BY metadata.training.training_weight DESC, metadata.quality_score DESC;
```

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_content_topic` | `topic` | Normal | Recherche rapide par topic |
| `idx_content_type` | `identity.content_type` | Normal | Filtrage par type de contenu |
| `idx_content_slug` | `identity.slug` | UNIQUE | Navigation UI/URL |
| `idx_content_active` | `metadata.is_active` | Normal | Filtrage des contenus actifs |
| `idx_content_training` | `metadata.training.included_in_training` | Normal | Filtrage pour export entraînement |

---

## 📝 Exemples d'utilisation

### ✅ Créer un contenu simple (texte seulement)

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-basic-concept",
    identity.content_type = knowledge_content_type:SYNTAX,
    identity.title_key = i18n_key:content_define_field_title,
    identity.description_key = i18n_key:content_define_field_description,
    content.text_key = i18n_key:content_define_field_explanation,
    metadata.is_active = true,
    metadata.priority = 1,
    metadata.version_label = "1.0.0";
```

### ✅ Créer un contenu avec code multi-langage

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-with-assert",
    identity.content_type = knowledge_content_type:EXAMPLE_CORRECT,
    identity.title_key = i18n_key:content_define_field_assert_title,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);",
            explanation_key: i18n_key:content_define_field_assert_explanation
        },
        {
            language: "js",
            value: "// Equivalent JavaScript validation",
            explanation_key: i18n_key:content_define_field_assert_js_explanation
        }
    ],
    metadata.is_active = true,
    metadata.priority = 2;
```

### ✅ Créer un contenu avec exemples corrects et incorrects

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-validation-examples",
    identity.content_type = knowledge_content_type:RULE,
    content.examples.correct = [
        {
            text_key: i18n_key:example_correct_1,
            code: "DEFINE FIELD age ON TABLE user TYPE int ASSERT $value > 0 AND $value < 150;"
        },
        {
            text_key: i18n_key:example_correct_2,
            code: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);"
        }
    ],
    content.examples.incorrect = [
        {
            text_key: i18n_key:example_incorrect_1,
            code: "DEFINE FIELD age ON TABLE user TYPE int ASSERT $value > 0; -- ❌ Pas de limite supérieure"
        },
        {
            text_key: i18n_key:example_incorrect_2,
            code: "DEFINE FIELD email ON TABLE user TYPE string; -- ❌ Pas de validation"
        }
    ],
    content.context_key = i18n_key:content_validation_context,
    metadata.is_active = true;
```

### ✅ Créer un contenu complet (structure U3-FLEX complète)

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-complete-guide",
    identity.content_type = knowledge_content_type:REFERENCE,
    identity.title_key = i18n_key:content_define_field_guide_title,
    identity.description_key = i18n_key:content_define_field_guide_description,
    content.text_key = i18n_key:content_define_field_guide_text,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD name ON TABLE user TYPE string;",
            explanation_key: i18n_key:content_define_field_basic_explanation
        }
    ],
    content.context_key = i18n_key:content_define_field_context,
    content.examples.correct = [
        {
            text_key: i18n_key:example_correct_basic,
            code: "DEFINE FIELD id ON TABLE user TYPE record<user>;"
        }
    ],
    content.examples.incorrect = [
        {
            text_key: i18n_key:example_incorrect_basic,
            code: "DEFINE FIELD id ON TABLE user TYPE string; -- ❌ Mauvais type"
        }
    ],
    content.media = [
        url:guide_image_1,
        url:guide_pdf_1
    ],
    content.references = [
        knowledge_content:define-table-basics,
        knowledge_content:define-field-types
    ],
    tags = [tag:surreal, tag:definition],
    metadata.is_active = true,
    metadata.priority = 5,
    metadata.version_label = "2.0.0",
    metadata.quality_score = 0.9;
```

### ✅ Récupérer tous les contenus d'un topic

```surql
SELECT 
    identity.slug,
    identity.content_type->identity.code AS content_type,
    identity.title_key,
    content.text_key,
    content.code,
    metadata.priority,
    metadata.is_active,
    metadata.quality_score
FROM knowledge_content
WHERE topic = knowledge_topic:DEFINE_FIELD
    AND metadata.is_active = true
    AND metadata.quality_score >= 0.7
ORDER BY metadata.priority DESC, metadata.quality_score DESC, metadata.version_label DESC;
```

### ✅ Préparer un bundle pour IA (RAG)

```surql
SELECT {
    slug: identity.slug,
    type: identity.content_type->identity.code,
    title: identity.title_key,
    text: content.text_key,
    code: content.code,
    examples_correct: content.examples.correct,
    examples_incorrect: content.examples.incorrect,
    context: content.context_key,
    tags: tags,
    priority: metadata.priority
}
FROM knowledge_content
WHERE topic = knowledge_topic:DEFINE_FIELD
    AND metadata.is_active = true
ORDER BY metadata.priority DESC;
```

### ✅ Rechercher par type de contenu

```surql
SELECT 
    identity.slug,
    identity.title_key,
    content.text_key
FROM knowledge_content
WHERE identity.content_type = knowledge_content_type:SYNTAX
    AND metadata.is_active = true
ORDER BY metadata.priority DESC;
```

---

## 🤖 Bénéfices pour l'IA

Cette structure U3-FLEX optimise :

- ✅ **RAG interne** : Recherche + Assembly du contexte optimal avec multi-formats
- ✅ **Génération de code** : Pattern + syntax + rule + tips dans une structure unifiée
- ✅ **Apprentissage automatique** : Raisonnement correct via exemples corrects/incorrects
- ✅ **Détection d'erreurs** : Via `examples.incorrect` avec explications
- ✅ **Contexte enrichi** : Via `context_key` pour meilleure compréhension
- ✅ **Multi-langage** : Support code dans plusieurs langages dans le même contenu
- ✅ **Flexibilité** : Tous les champs optionnels, structure adaptée au besoin

---

## 📋 Bonnes pratiques

1. **Slug unique** : Utiliser des slugs descriptifs et uniques pour chaque contenu
2. **Type de contenu** : Toujours spécifier un `content_type` approprié
3. **i18n** : Utiliser des clés i18n pour tous les textes traduisibles
4. **Code** : Utiliser la syntaxe wildcard `*` pour les arrays d'objets (`content.code.*.language`)
5. **Exemples** : Fournir des exemples corrects ET incorrects pour meilleur apprentissage IA
6. **Priorité** : Utiliser `metadata.priority` pour ordonner l'affichage
7. **Tags** : Utiliser des tags structurés pour catégorisation et filtrage
8. **Version** : Utiliser `version_label` pour suivre les évolutions fonctionnelles

---

## 🧵 Résumé

La table `knowledge_content` :

- ✅ Représente chaque pièce de connaissance exploitable
- ✅ Structure U3-FLEX multi-format flexible
- ✅ Supporte texte, code, exemples, JSON, média dans une structure unifiée
- ✅ Optimisée pour l'IA (RAG, génération, apprentissage)
- ✅ Supporte l'internationalisation via clés i18n
- ✅ Indexée pour performance optimale
- ✅ Relie un contenu à un topic et à un type

Elle constitue le **centre de gravité** de tout le système de connaissance Lyxal et le **niveau 4** de la hiérarchie de connaissance.

---

## 📚 Références

- **Syntaxe arrays d'objets** : `16_SurrealDB_Arrays_Objects_Syntax.md`
- **Types de contenu** : `07_Knowledge_Content_Type.md`
- **Topics** : `04_Knowledge_Topic.md`
- **Tags** : `08_Knowledge_Keyword.md` (section Tags vs Keywords)

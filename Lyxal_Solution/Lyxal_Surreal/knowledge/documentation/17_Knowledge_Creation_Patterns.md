# 📝 Guide de Patterns de Création – Knowledge System

## 🎯 Objectif

Ce guide fournit des **patterns recommandés** et des **bonnes pratiques** pour créer des données knowledge de manière cohérente et efficace dans le système Lyxal Knowledge System.

Il couvre :
- ✅ Patterns recommandés pour chaque niveau (Domain → Category → Topic → Content)
- ✅ Checklist de validation avant création
- ✅ Exemples complets étape par étape
- ✅ Pièges courants et bonnes pratiques
- ✅ Workflow recommandé

---

## 🏗️ Hiérarchie de création

### Ordre logique de création

```
1. knowledge_domain (niveau 1)
   ↓
2. knowledge_category (niveau 2)
   ↓
3. knowledge_sub_category (niveau 2.5 - optionnel)
   ↓
4. knowledge_topic (niveau 3)
   ↓
5. knowledge_content (niveau 4)
```

**⚠️ IMPORTANT** : Respectez cet ordre ! Chaque niveau dépend du niveau précédent.

---

## 📋 Pattern 1 : Créer un Domain

### Structure recommandée

```surql
CREATE knowledge_domain SET
    identity.code = "UPPER_SNAKE_CASE",
    identity.slug = "lowercase-slug",
    identity.label_key = i18n_key:kd_domain_label,
    identity.description_key = i18n_key:kd_domain_description,
    identity.ai_context_key = i18n_key:kd_domain_ai_context,
    ui.icon = icon:icon_reference,
    tags = [tag:tag1, tag:tag2],
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;
```

### Checklist de validation

- [ ] `identity.code` en `UPPER_SNAKE_CASE` (ex: `SURREAL_DB`, `LYXAL_SOLUTION`)
- [ ] `identity.slug` en lowercase avec tirets (ex: `surreal-db`, `lyxal-solution`)
- [ ] Clés i18n créées avant le CREATE
- [ ] Tags existent dans la table `tag` globale
- [ ] Icon existe dans la table `icon` (optionnel)
- [ ] `metadata.display_order` défini pour l'ordre d'affichage

### Exemple complet

```surql
-- 1. Créer les clés i18n d'abord (si nécessaire)
CREATE i18n_key:kd_surreal_db_label SET
    key = "kd_surreal_db_label",
    translations.fr = "SurrealDB",
    translations.en = "SurrealDB";

CREATE i18n_key:kd_surreal_db_description SET
    key = "kd_surreal_db_description",
    translations.fr = "Base de données graphe moderne et flexible",
    translations.en = "Modern and flexible graph database";

CREATE i18n_key:kd_surreal_db_ai_context SET
    key = "kd_surreal_db_ai_context",
    translations.fr = "Domaine technique couvrant tous les aspects de SurrealDB : syntaxe, requêtes, permissions, optimisations",
    translations.en = "Technical domain covering all aspects of SurrealDB: syntax, queries, permissions, optimizations";

-- 2. Créer le domaine
CREATE knowledge_domain:SURREAL_DB SET
    identity.code = "SURREAL_DB",
    identity.slug = "surreal-db",
    identity.label_key = i18n_key:kd_surreal_db_label,
    identity.description_key = i18n_key:kd_surreal_db_description,
    identity.ai_context_key = i18n_key:kd_surreal_db_ai_context,
    tags = [tag:surreal, tag:database, tag:technical],
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;

-- 3. Ajouter des keywords pour recherche
RELATE knowledge_domain:SURREAL_DB
    ->knowledge_domain_keyword->"surreal";
RELATE knowledge_domain:SURREAL_DB
    ->knowledge_domain_keyword->"database";
RELATE knowledge_domain:SURREAL_DB
    ->knowledge_domain_keyword->"graph";
```

### Bonnes pratiques

✅ **À faire** :
- Utiliser des codes descriptifs et cohérents
- Créer les clés i18n avant le domaine
- Ajouter des keywords pertinents pour la recherche
- Utiliser des tags structurés pour catégorisation

❌ **À éviter** :
- Codes trop génériques (`DATABASE` au lieu de `SURREAL_DB`)
- Slug différent du code (garder cohérence)
- Oublier les clés i18n (système multi-langue)
- Trop de keywords (5-10 maximum)

---

## 📋 Pattern 2 : Créer une Category

### Structure recommandée

```surql
CREATE knowledge_category SET
    identity.code = "UPPER_SNAKE_CASE",
    identity.slug = "lowercase-slug",
    identity.label_key = i18n_key:kc_category_label,
    identity.description_key = i18n_key:kc_category_description,
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;
```

### Checklist de validation

- [ ] `identity.code` en `UPPER_SNAKE_CASE` (ex: `DATA_DEFINITION`, `QUERIES`)
- [ ] `identity.slug` en lowercase avec tirets
- [ ] Clés i18n créées avant le CREATE
- [ ] `metadata.display_order` défini pour l'ordre d'affichage

### Exemple complet

```surql
-- 1. Créer les clés i18n
CREATE i18n_key:kc_data_definition_label SET
    key = "kc_data_definition_label",
    translations.fr = "Définition de données",
    translations.en = "Data Definition";

CREATE i18n_key:kc_data_definition_description SET
    key = "kc_data_definition_description",
    translations.fr = "Catégorie regroupant les topics liés à la définition de structures de données (tables, champs, index)",
    translations.en = "Category grouping topics related to data structure definition (tables, fields, indexes)";

-- 2. Créer la catégorie
CREATE knowledge_category:DATA_DEFINITION SET
    identity.code = "DATA_DEFINITION",
    identity.slug = "data-definition",
    identity.label_key = i18n_key:kc_data_definition_label,
    identity.description_key = i18n_key:kc_data_definition_description,
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;
```

### Bonnes pratiques

✅ **À faire** :
- Créer des catégories logiques et cohérentes
- Utiliser des noms descriptifs
- Respecter l'ordre d'affichage logique

❌ **À éviter** :
- Catégories trop spécifiques (mieux vaut créer une sous-catégorie)
- Catégories redondantes
- Ordre d'affichage incohérent

---

## 📋 Pattern 3 : Créer une Sub_Category (optionnel)

### Quand utiliser une sous-catégorie ?

Utilisez une sous-catégorie uniquement si :
- ✅ La catégorie contient **beaucoup de topics** (> 10-15)
- ✅ Les topics peuvent être **regroupés thématiquement**
- ✅ La navigation UI bénéficierait d'un **niveau supplémentaire**

### Structure recommandée

```surql
CREATE knowledge_sub_category SET
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "UPPER_SNAKE_CASE",
    identity.slug = "lowercase-slug",
    identity.label_key = i18n_key:ksc_sub_category_label,
    identity.description_key = i18n_key:ksc_sub_category_description,
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;
```

### Exemple complet

```surql
-- 1. Créer les clés i18n
CREATE i18n_key:ksc_field_types_label SET
    key = "ksc_field_types_label",
    translations.fr = "Types de champs",
    translations.en = "Field Types";

-- 2. Créer la sous-catégorie
CREATE knowledge_sub_category:FIELD_TYPES SET
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "FIELD_TYPES",
    identity.slug = "field-types",
    identity.label_key = i18n_key:ksc_field_types_label,
    identity.description_key = i18n_key:ksc_field_types_description,
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;
```

---

## 📋 Pattern 4 : Créer un Topic

### Structure recommandée

```surql
CREATE knowledge_topic SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    sub_category = knowledge_sub_category:FIELD_TYPES,  -- optionnel
    tags = [tag:tag1, tag:tag2],
    identity.code = "UPPER_SNAKE_CASE",
    identity.slug = "lowercase-slug",
    identity.label_key = i18n_key:kt_topic_label,
    identity.description_key = i18n_key:kt_topic_description,
    identity.ai_context_key = i18n_key:kt_topic_ai_context,  -- optionnel
    metadata.version_label = "1.0.0",
    metadata.display_order = 1,
    metadata.is_active = true;
```

### Checklist de validation

- [ ] Domain existe et est actif
- [ ] Category existe et est active
- [ ] Sub_category existe et est active (si utilisée)
- [ ] `identity.code` en `UPPER_SNAKE_CASE`
- [ ] `identity.slug` en lowercase avec tirets
- [ ] Clés i18n créées avant le CREATE
- [ ] Tags existent dans la table `tag` globale

### Exemple complet

```surql
-- 1. Créer les clés i18n
CREATE i18n_key:kt_define_field_label SET
    key = "kt_define_field_label",
    translations.fr = "DEFINE FIELD",
    translations.en = "DEFINE FIELD";

CREATE i18n_key:kt_define_field_description SET
    key = "kt_define_field_description",
    translations.fr = "Définit un champ dans une table avec type, contraintes et assertions",
    translations.en = "Defines a field in a table with type, constraints and assertions";

CREATE i18n_key:kt_define_field_ai_context SET
    key = "kt_define_field_ai_context",
    translations.fr = "Topic couvrant la syntaxe complète de DEFINE FIELD : types, ASSERT, DEFAULT, PERMISSIONS, etc.",
    translations.en = "Topic covering the complete syntax of DEFINE FIELD: types, ASSERT, DEFAULT, PERMISSIONS, etc.";

-- 2. Créer le topic
CREATE knowledge_topic:DEFINE_FIELD SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    sub_category = knowledge_sub_category:FIELD_TYPES,
    tags = [tag:surreal, tag:definition, tag:beginner],
    identity.code = "DEFINE_FIELD",
    identity.slug = "define-field",
    identity.label_key = i18n_key:kt_define_field_label,
    identity.description_key = i18n_key:kt_define_field_description,
    identity.ai_context_key = i18n_key:kt_define_field_ai_context,
    metadata.version_label = "1.0.0",
    metadata.display_order = 1,
    metadata.is_active = true;

-- 3. Ajouter des keywords pour recherche
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"assert";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"validation";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"constraint";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"type";
```

### Bonnes pratiques

✅ **À faire** :
- Créer des topics spécifiques et focalisés
- Utiliser `ai_context_key` pour améliorer la compréhension IA
- Ajouter des keywords pour recherche sémantique
- Combiner Tags (catégorisation) et Keywords (recherche)

❌ **À éviter** :
- Topics trop génériques ou trop larges
- Oublier les keywords (essentiels pour la recherche)
- Trop de tags (3-5 maximum recommandé)

---

## 📋 Pattern 5 : Créer un Content

### Structure U3-FLEX recommandée

Le contenu peut être créé avec différents niveaux de complexité selon le besoin.

### Pattern 5.1 : Contenu simple (texte seulement)

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-basic-concept",
    identity.content_type = knowledge_content_type:SYNTAX,
    identity.title_key = i18n_key:content_title,
    identity.description_key = i18n_key:content_description,
    content.text_key = i18n_key:content_explanation,
    metadata.is_active = true,
    metadata.priority = 1,
    metadata.version_label = "1.0.0";
```

### Pattern 5.2 : Contenu avec code multi-langage

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-with-assert",
    identity.content_type = knowledge_content_type:EXAMPLE_CORRECT,
    identity.title_key = i18n_key:content_assert_title,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);",
            explanation_key: i18n_key:content_assert_explanation
        },
        {
            language: "js",
            value: "// Equivalent JavaScript validation",
            explanation_key: i18n_key:content_assert_js_explanation
        }
    ],
    metadata.is_active = true,
    metadata.priority = 2;
```

**⚠️ IMPORTANT** : Utilisez la syntaxe wildcard `*` dans le schéma (`content.code.*.language`). Voir `16_SurrealDB_Arrays_Objects_Syntax.md`.

### Pattern 5.3 : Contenu avec exemples corrects et incorrects

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

### Pattern 5.4 : Contenu complet (structure U3-FLEX complète)

```surql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-complete-guide",
    identity.content_type = knowledge_content_type:REFERENCE,
    identity.title_key = i18n_key:content_guide_title,
    identity.description_key = i18n_key:content_guide_description,
    content.text_key = i18n_key:content_guide_text,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD name ON TABLE user TYPE string;",
            explanation_key: i18n_key:content_basic_explanation
        }
    ],
    content.context_key = i18n_key:content_context,
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
    tags = [tag:surreal, tag:definition],
    metadata.is_active = true,
    metadata.priority = 5,
    metadata.version_label = "2.0.0";
```

### Checklist de validation Content

- [ ] Topic existe et est actif
- [ ] Content_type existe et est actif
- [ ] `identity.slug` unique et descriptif
- [ ] Clés i18n créées avant le CREATE
- [ ] Arrays d'objets utilisent la syntaxe correcte (voir `16_SurrealDB_Arrays_Objects_Syntax.md`)
- [ ] `content.code.*.language` défini pour chaque bloc de code
- [ ] `content.examples.correct.*.text_key` défini pour chaque exemple
- [ ] `content.examples.incorrect.*.text_key` défini pour chaque exemple
- [ ] Tags existent dans la table `tag` globale
- [ ] Media existent dans la table `url` (si utilisés)

### Types de contenus recommandés par situation

| Situation | Content Type recommandé | Priorité |
|-----------|-------------------------|----------|
| Syntaxe officielle | `SYNTAX` | 5 |
| Règle à suivre | `RULE` | 5 |
| Bon exemple | `EXAMPLE_CORRECT` | 5 |
| Mauvais exemple | `EXAMPLE_INCORRECT` | 4 |
| Astuce rapide | `TIP` | 3 |
| Pattern réutilisable | `PATTERN` | 5 |
| Explication détaillée | `EXPLANATION` | 4 |
| Référence externe | `REFERENCE` | 3 |

---

## 🔄 Workflow recommandé

### Workflow complet : Créer un domaine avec ses topics

```surql
-- ÉTAPE 1 : Créer le domaine
CREATE knowledge_domain:SURREAL_DB SET
    identity.code = "SURREAL_DB",
    identity.slug = "surreal-db",
    identity.label_key = i18n_key:kd_surreal_db_label,
    identity.description_key = i18n_key:kd_surreal_db_description,
    metadata.is_active = true,
    metadata.display_order = 1;

-- ÉTAPE 2 : Ajouter des keywords au domaine
RELATE knowledge_domain:SURREAL_DB
    ->knowledge_domain_keyword->"surreal";
RELATE knowledge_domain:SURREAL_DB
    ->knowledge_domain_keyword->"database";

-- ÉTAPE 3 : Créer les catégories
CREATE knowledge_category:DATA_DEFINITION SET
    identity.code = "DATA_DEFINITION",
    identity.slug = "data-definition",
    identity.label_key = i18n_key:kc_data_definition_label,
    identity.description_key = i18n_key:kc_data_definition_description,
    metadata.is_active = true,
    metadata.display_order = 1;

-- ÉTAPE 4 : Créer un topic
CREATE knowledge_topic:DEFINE_FIELD SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "DEFINE_FIELD",
    identity.slug = "define-field",
    identity.label_key = i18n_key:kt_define_field_label,
    identity.description_key = i18n_key:kt_define_field_description,
    metadata.is_active = true,
    metadata.display_order = 1;

-- ÉTAPE 5 : Ajouter des keywords au topic
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"assert";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"validation";

-- ÉTAPE 6 : Créer les contenus du topic
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-syntax",
    identity.content_type = knowledge_content_type:SYNTAX,
    identity.title_key = i18n_key:content_syntax_title,
    content.text_key = i18n_key:content_syntax_text,
    metadata.is_active = true,
    metadata.priority = 1;

CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-example-correct",
    identity.content_type = knowledge_content_type:EXAMPLE_CORRECT,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);",
            explanation_key: i18n_key:content_example_explanation
        }
    ],
    metadata.is_active = true,
    metadata.priority = 2;
```

---

## ✅ Checklist globale avant création

### Avant de créer un Domain

- [ ] Les clés i18n nécessaires sont créées
- [ ] Les tags existent dans la table `tag` globale
- [ ] Le code est en `UPPER_SNAKE_CASE`
- [ ] Le slug est en lowercase avec tirets
- [ ] Le code et le slug sont cohérents

### Avant de créer un Topic

- [ ] Le domain existe et est actif
- [ ] La category existe et est active
- [ ] La sub_category existe et est active (si utilisée)
- [ ] Les clés i18n nécessaires sont créées
- [ ] Les tags existent dans la table `tag` globale
- [ ] Le code est en `UPPER_SNAKE_CASE`
- [ ] Le slug est en lowercase avec tirets

### Avant de créer un Content

- [ ] Le topic existe et est actif
- [ ] Le content_type existe et est actif
- [ ] Les clés i18n nécessaires sont créées
- [ ] Les tags existent dans la table `tag` globale (si utilisés)
- [ ] Les media existent dans la table `url` (si utilisés)
- [ ] Le slug est unique et descriptif
- [ ] La syntaxe wildcard `*` est utilisée pour les arrays d'objets
- [ ] Les champs optionnels sont correctement gérés (option<>)

---

## ⚠️ Pièges courants et solutions

### Piège 1 : Oublier la syntaxe wildcard `*` pour les arrays d'objets

❌ **INCORRECT** :
```surql
DEFINE FIELD content.code.language ON TABLE knowledge_content
    TYPE string;
```

✅ **CORRECT** :
```surql
DEFINE FIELD content.code.*.language ON TABLE knowledge_content
    TYPE string;
```

**Solution** : Voir `16_SurrealDB_Arrays_Objects_Syntax.md`

### Piège 2 : Créer un topic sans vérifier que le domain existe

❌ **INCORRECT** :
```surql
CREATE knowledge_topic:MY_TOPIC SET
    domain = knowledge_domain:NON_EXISTANT,  -- ❌ Erreur !
    ...
```

✅ **CORRECT** :
```surql
-- Vérifier d'abord
SELECT id FROM knowledge_domain WHERE identity.code = "SURREAL_DB";

-- Puis créer
CREATE knowledge_topic:MY_TOPIC SET
    domain = knowledge_domain:SURREAL_DB,  -- ✅ Existe
    ...
```

### Piège 3 : Utiliser des keywords au lieu de tags (ou vice versa)

❌ **INCORRECT** :
```surql
-- Utiliser keywords pour catégorisation structurée
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"surreal";  -- ❌ Devrait être un tag
```

✅ **CORRECT** :
```surql
-- Tags pour catégorisation structurée
CREATE knowledge_topic:DEFINE_FIELD SET
    tags = [tag:surreal],  -- ✅ Catégorisation structurée
    ...

-- Keywords pour recherche sémantique
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"assert";  -- ✅ Recherche sémantique
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"validation";  -- ✅ Synonyme
```

**Solution** : Voir `08_Knowledge_Keyword.md` (section Tags vs Keywords)

### Piège 4 : Oublier de créer les clés i18n avant le CREATE

❌ **INCORRECT** :
```surql
CREATE knowledge_domain:SURREAL_DB SET
    identity.label_key = i18n_key:non_existant_key;  -- ❌ Erreur !
```

✅ **CORRECT** :
```surql
-- Créer d'abord les clés i18n
CREATE i18n_key:kd_surreal_db_label SET
    key = "kd_surreal_db_label",
    translations.fr = "SurrealDB",
    translations.en = "SurrealDB";

-- Puis créer le domaine
CREATE knowledge_domain:SURREAL_DB SET
    identity.label_key = i18n_key:kd_surreal_db_label;  -- ✅ Existe
```

### Piège 5 : Slug non unique

❌ **INCORRECT** :
```surql
CREATE knowledge_content SET
    identity.slug = "example",  -- ❌ Peut exister déjà
    ...
```

✅ **CORRECT** :
```surql
CREATE knowledge_content SET
    identity.slug = "define-field-basic-concept",  -- ✅ Descriptif et unique
    ...
```

---

## 📊 Exemple complet : Scénario réel

### Scénario : Documenter la fonctionnalité DEFINE FIELD de SurrealDB

```surql
-- ============================================================================
-- WORKFLOW COMPLET : Documenter DEFINE FIELD
-- ============================================================================

-- ÉTAPE 1 : Vérifier que le domaine existe (ou le créer)
SELECT id FROM knowledge_domain WHERE identity.code = "SURREAL_DB";
-- Si existe, continuer. Sinon créer le domaine.

-- ÉTAPE 2 : Vérifier/créer la catégorie
SELECT id FROM knowledge_category WHERE identity.code = "DATA_DEFINITION";
-- Si existe, continuer. Sinon créer la catégorie.

-- ÉTAPE 3 : Créer les clés i18n pour le topic
CREATE i18n_key:kt_define_field_label SET
    key = "kt_define_field_label",
    translations.fr = "DEFINE FIELD",
    translations.en = "DEFINE FIELD";

CREATE i18n_key:kt_define_field_description SET
    key = "kt_define_field_description",
    translations.fr = "Définit un champ dans une table avec type, contraintes et assertions",
    translations.en = "Defines a field in a table with type, constraints and assertions";

-- ÉTAPE 4 : Créer le topic
CREATE knowledge_topic:DEFINE_FIELD SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    tags = [tag:surreal, tag:definition, tag:beginner],
    identity.code = "DEFINE_FIELD",
    identity.slug = "define-field",
    identity.label_key = i18n_key:kt_define_field_label,
    identity.description_key = i18n_key:kt_define_field_description,
    metadata.version_label = "1.0.0",
    metadata.display_order = 1,
    metadata.is_active = true;

-- ÉTAPE 5 : Ajouter des keywords au topic
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"assert";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"validation";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"constraint";
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->"type";

-- ÉTAPE 6 : Créer les clés i18n pour les contenus
CREATE i18n_key:content_syntax_title SET
    key = "content_syntax_title",
    translations.fr = "Syntaxe de base",
    translations.en = "Basic syntax";

CREATE i18n_key:content_syntax_text SET
    key = "content_syntax_text",
    translations.fr = "La syntaxe de base de DEFINE FIELD est : DEFINE FIELD nom ON TABLE table TYPE type;",
    translations.en = "The basic syntax of DEFINE FIELD is: DEFINE FIELD name ON TABLE table TYPE type;";

-- ÉTAPE 7 : Créer le contenu SYNTAX
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-basic-syntax",
    identity.content_type = knowledge_content_type:SYNTAX,
    identity.title_key = i18n_key:content_syntax_title,
    content.text_key = i18n_key:content_syntax_text,
    metadata.is_active = true,
    metadata.priority = 1,
    metadata.version_label = "1.0.0";

-- ÉTAPE 8 : Créer les clés i18n pour un exemple
CREATE i18n_key:content_example_explanation SET
    key = "content_example_explanation",
    translations.fr = "Cet exemple montre comment utiliser ASSERT pour valider un email",
    translations.en = "This example shows how to use ASSERT to validate an email";

-- ÉTAPE 9 : Créer le contenu EXAMPLE_CORRECT
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-email-validation",
    identity.content_type = knowledge_content_type:EXAMPLE_CORRECT,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);",
            explanation_key: i18n_key:content_example_explanation
        }
    ],
    metadata.is_active = true,
    metadata.priority = 2,
    metadata.version_label = "1.0.0";
```

---

## 🎯 Résumé des patterns essentiels

### Naming conventions

| Élément | Format | Exemple |
|---------|--------|---------|
| Domain code | `UPPER_SNAKE_CASE` | `SURREAL_DB` |
| Domain slug | `lowercase-kebab-case` | `surreal-db` |
| Category code | `UPPER_SNAKE_CASE` | `DATA_DEFINITION` |
| Topic code | `UPPER_SNAKE_CASE` | `DEFINE_FIELD` |
| Content slug | `lowercase-kebab-case` | `define-field-basic-syntax` |
| i18n key | `lowercase_snake_case` | `kt_define_field_label` |

### Ordre de création

1. **i18n keys** → Créer toutes les clés i18n nécessaires
2. **Domain** → Créer le domaine
3. **Category** → Créer la catégorie (ou utiliser existante)
4. **Sub_Category** → Créer la sous-catégorie (si nécessaire)
5. **Topic** → Créer le topic
6. **Keywords** → Ajouter les keywords au topic
7. **Content** → Créer les contenus du topic

### Checklist finale

Avant de finaliser la création :

- [ ] Tous les éléments parents existent et sont actifs
- [ ] Toutes les clés i18n sont créées
- [ ] Les codes sont en `UPPER_SNAKE_CASE`
- [ ] Les slugs sont en `lowercase-kebab-case`
- [ ] Les tags existent dans la table `tag`
- [ ] Les keywords sont ajoutés pour recherche
- [ ] La syntaxe wildcard `*` est utilisée pour arrays d'objets
- [ ] Les content_types sont valides
- [ ] Les metadata sont cohérentes

---

## 📚 Références

- **Syntaxe arrays d'objets** : `16_SurrealDB_Arrays_Objects_Syntax.md`
- **Guide Tags vs Keywords** : `08_Knowledge_Keyword.md`
- **Documentation Domain** : `02_Knowledge_Domain.md`
- **Documentation Category** : `04_Knowledge_Category.md`
- **Documentation Topic** : `04_Knowledge_Topic.md`
- **Documentation Content** : `06_Knowledge_Content.md`
- **Documentation Content Types** : `07_Knowledge_Content_Type.md`

---

## 🧵 Résumé

Ce guide fournit :

- ✅ Patterns recommandés pour chaque niveau de la hiérarchie
- ✅ Checklist de validation avant création
- ✅ Exemples complets étape par étape
- ✅ Pièges courants et solutions
- ✅ Workflow recommandé complet

**Utilisez ce guide comme référence** lors de la création de nouvelles données knowledge pour garantir la cohérence et la qualité du système.


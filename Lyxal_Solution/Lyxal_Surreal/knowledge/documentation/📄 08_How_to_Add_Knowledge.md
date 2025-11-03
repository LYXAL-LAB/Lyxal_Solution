# 🧩 Comment Ajouter une Nouvelle Connaissance – Guide Pratique

Ce guide explique étape par étape comment ajouter un nouvel élément dans le **Knowledge System Lyxal**.  
Il s'adresse aussi bien aux humains qu'aux IA contribuant au système.

> 📚 **Pour un guide complet avec patterns détaillés**, voir `17_Knowledge_Creation_Patterns.md`

---

## ✅ 1. Ajouter un Domaine (si nécessaire)

Un domaine représente un grand pilier de connaissance (ex : SurrealDB, Business, IA).

À faire uniquement si le sujet n'existe pas.

### Étapes :

1. **Créer les clés i18n** nécessaires
```sql
CREATE i18n_key:kd_surreal_db_label SET
    key = "kd_surreal_db_label",
    translations.fr = "SurrealDB",
    translations.en = "SurrealDB";
```

2. **Créer le domaine**
```sql
CREATE knowledge_domain:SURREAL_DB SET
    identity.code = "SURREAL_DB",
    identity.slug = "surreal-db",
    identity.label_key = i18n_key:kd_surreal_db_label,
    identity.description_key = i18n_key:kd_surreal_db_description,
    tags = [],
    metadata.version_label = "1.0.0",
    metadata.is_active = true,
    metadata.display_order = 1;
```

3. **Ajouter les mots-clés** (via `knowledge_keyword` et `knowledge_domain_keyword`)
```sql
-- Créer ou récupérer le keyword
CREATE knowledge_keyword:database SET
    identity.value = "database",
    identity.slug = "database",
    metadata.is_active = true;

-- Lier le keyword au domain
RELATE knowledge_domain:SURREAL_DB 
    ->knowledge_domain_keyword->knowledge_keyword:database;
```

---

## 🗂️ 2. Ajouter un Topic

Un topic est un **sujet précis** dans un domaine (ex : DEFINE FIELD, RELATE, Business Model Canvas).

### Étapes :

1. **Créer les clés i18n** nécessaires
```sql
CREATE i18n_key:kt_define_field_label SET
    key = "kt_define_field_label",
    translations.fr = "DEFINE FIELD",
    translations.en = "DEFINE FIELD";
```

2. **Créer le topic**
```sql
CREATE knowledge_topic:DEFINE_FIELD SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "DEFINE_FIELD",
    identity.slug = "define-field",
    identity.label_key = i18n_key:kt_define_field_label,
    identity.description_key = i18n_key:kt_define_field_description,
    metadata.version_label = "1.0.0",
    metadata.display_order = 1,
    metadata.is_active = true;
```

3. **Ajouter les mots-clés**
```sql
-- Créer ou récupérer les keywords
CREATE knowledge_keyword:assert SET
    identity.value = "assert",
    identity.slug = "assert",
    metadata.is_active = true;

-- Lier les keywords au topic
RELATE knowledge_topic:DEFINE_FIELD 
    ->knowledge_topic_keyword->knowledge_keyword:assert;
```

> Un topic doit rester **concis et universel**.  
> Si trop large, le découper en plusieurs topics.

---

## 📘 3. Choisir le Type de Contenu

Chaque contenu doit utiliser un type issu de `knowledge_content_type`.

### Types disponibles :

| Type | Usage | Quand l'utiliser |
|------|-------|------------------|
| `SYNTAX` | Montre la syntaxe correcte | Syntaxe officielle d'une commande |
| `RULE` | Règle à suivre | Règles de validation, bonnes pratiques |
| `EXAMPLE_CORRECT` | Exemple valide | Exemples de code qui fonctionnent |
| `EXAMPLE_INCORRECT` | Mauvais exemple + explication | Anti-patterns, erreurs communes |
| `TIP` | Conseil rapide | Astuces courtes et pratiques |
| `PATTERN` | Modèle réutilisable | Patterns de conception réutilisables |
| `EXPLANATION` | Explication détaillée | Explications approfondies |
| `REFERENCE` | Référence externe | Liens vers ressources externes |

> Pour plus de détails sur chaque type, voir `07_Knowledge_Content_Type.md`

---

## ✍️ 4. Ajouter un Contenu

Un contenu est une **unité de connaissance** liée à un topic.

### Étapes :

1. **Créer les clés i18n** nécessaires
```sql
CREATE i18n_key:content_syntax_title SET
    key = "content_syntax_title",
    translations.fr = "Syntaxe de base",
    translations.en = "Basic syntax";
```

2. **Créer le contenu** (structure U3-FLEX)
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-basic-syntax",
    identity.content_type = knowledge_content_type:SYNTAX,
    identity.title_key = i18n_key:content_syntax_title,
    content.text_key = i18n_key:content_syntax_text,
    metadata.is_active = true,
    metadata.priority = 1,
    metadata.version_label = "1.0.0";
```

### Exemple avec code multi-langage :

```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-with-assert",
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

> ⚠️ **IMPORTANT** : Pour les arrays d'objets, utiliser la syntaxe wildcard `*` dans le schéma (voir `16_SurrealDB_Arrays_Objects_Syntax.md`)

> Un topic doit contenir **plusieurs contenus variés** pour être utile.

---

## 🏷️ 5. Ajouter des Tags

Les tags servent au classement structuré via la table globale `tag`.

### Règles :

- Toujours vérifier si un tag existe avant d'en créer un
- Utiliser le **référentiel tag global** (pas de duplication)
- Maximum recommandé : **3-5 tags par item**

### Exemple :

```sql
CREATE knowledge_domain:SURREAL_DB SET
    ...
    tags = [tag:surreal, tag:database, tag:technical];
```

---

## 🔍 6. Ajouter des Mots-Clés (Keywords)

Les mots-clés améliorent la recherche IA + Full-text.

### Workflow recommandé :

1. **Créer ou récupérer le keyword** dans `knowledge_keyword`
```sql
-- Créer un nouveau keyword
CREATE knowledge_keyword:validation SET
    identity.value = "validation",
    identity.slug = "validation",
    metadata.is_active = true;

-- OU récupérer un keyword existant
SELECT id FROM knowledge_keyword WHERE identity.value = "validation" LIMIT 1;
```

2. **Lier le keyword** via relation
```sql
-- Lier au domain
RELATE knowledge_domain:SURREAL_DB 
    ->knowledge_domain_keyword->knowledge_keyword:validation;

-- Lier au topic
RELATE knowledge_topic:DEFINE_FIELD 
    ->knowledge_topic_keyword->knowledge_keyword:validation;
```

### Recommandations :

- ✅ 3 à 8 mots-clés maximum par domaine/topic
- ✅ Toujours en lowercase (normalisé automatiquement)
- ✅ Simples et universels
- ✅ Réutiliser les keywords existants quand possible

---

## 🤖 7. Checklist de Qualité avant Validation

| Critère | OK ? |
|---------|------|
| Le domaine existe et est pertinent | ☐ |
| Le topic est clair et unique | ☐ |
| Le type de contenu est adapté | ☐ |
| Le contenu est utile pour humain & IA | ☐ |
| Tags pertinents ajoutés | ☐ |
| 3+ mots-clés ajoutés | ☐ |
| I18n keys créées | ☐ |
| Pas de redondance avec un contenu existant | ☐ |

---

## 🧠 Principe Fondamental Lyxal

Chaque ajout doit augmenter la valeur collective de la connaissance, et être exploitable par les IA Lyxal pour générer, enseigner, corriger et améliorer.

---

## 🚀 Exemple Minimal d'Ajout

### Workflow complet :

```sql
-- 1. Créer les clés i18n
CREATE i18n_key:kt_define_field_label SET
    key = "kt_define_field_label",
    translations.fr = "DEFINE FIELD",
    translations.en = "DEFINE FIELD";

-- 2. Créer le topic
CREATE knowledge_topic:DEFINE_FIELD SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "DEFINE_FIELD",
    identity.slug = "define-field",
    identity.label_key = i18n_key:kt_define_field_label,
    metadata.is_active = true;

-- 3. Créer les keywords
CREATE knowledge_keyword:field SET
    identity.value = "field",
    identity.slug = "field",
    metadata.is_active = true;

-- 4. Lier les keywords
RELATE knowledge_topic:DEFINE_FIELD 
    ->knowledge_topic_keyword->knowledge_keyword:field;

-- 5. Créer les contenus
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-syntax",
    identity.content_type = knowledge_content_type:SYNTAX,
    content.text_key = i18n_key:content_syntax_text,
    metadata.is_active = true;
```

---

## 📚 Références

- **Guide complet de patterns** : `17_Knowledge_Creation_Patterns.md`
- **Documentation des types** : `07_Knowledge_Content_Type.md`
- **Syntaxe arrays d'objets** : `16_SurrealDB_Arrays_Objects_Syntax.md`
- **Guide Tags vs Keywords** : `08_Knowledge_Keyword.md`

---

Ce fichier garantit que toute nouvelle connaissance ajoutée suit un standard homogène, évolutif et exploitable par IA.

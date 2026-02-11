# 📘 Table : `knowledge_content_type`

## 🎯 Objectif

La table `knowledge_content_type` définit les **types de contenus** disponibles dans le système de connaissance.  
Elle remplace la liste statique initiale (`syntax`, `rule`, `example_correct`, …) par un **référentiel dynamique**, extensible et exploitable par l’IA.

Chaque type de contenu dispose de :

- métadonnées pour l’UI,
- contexte d’usage,
- paramètres d’optimisation IA.

---

## 🧱 Structure

| Bloc | Description |
|-------|----------------|
| `identity` | Code + clés i18n (nom & description) |
| `metadata` | Informations générales |
| `metadata.ai` | Paramètres d'optimisation IA |
| `metadata.ai.use_cases` | Cas d’usage IA configurables |

---

## 🔗 Relations

Cette table n’a pas de dépendances directes, mais elle est référencée par :

| Table | Rôle |
|--------|--------|
| `knowledge_content` | chaque contenu pointe vers un type |

---

## 🧩 Champs principaux

### 🧠 `identity`

| Field | Description |
|--------|----------------|
| `code` | Identifiant unique du type au format UPPER_SNAKE_CASE |
| `label_key` | Clé i18n — nom affiché dans l’UI |
| `description_key` | Clé i18n — description du type (optionnel) |

Exemples de codes type :

- `SYNTAX`
- `RULE`
- `EXAMPLE_CORRECT`
- `EXAMPLE_INCORRECT`
- `TIP`
- `PATTERN`
- `EXPLANATION`

> Extensible : vous pouvez créer `VIDEO_TUTORIAL`, `AI_CORRECTION`, `QUIZ`, etc.

---

### 📍 `metadata`

| Field | Description |
|--------|----------------|
| `is_active` | Active/désactive le type |
| `display_order` | Ordre d’affichage dans l’UI |
| `version_label` | Version fonctionnelle du type |

---

### 🤖 `metadata.ai` — Optimisation Intelligence Artificielle

Ce bloc permet aux agents IA de :

- choisir le bon type de contenu au bon moment,
- prioriser certaines sources,
- filtrer selon complexité ou score.

| Field | Description |
|--------|----------------|
| `priority` | Importance (1-5) pour IA lors des réponses |
| `weight` | Poids dans le ranking (0-1) |
| `level.level` | Niveau de complexité (1-5) |
| `level.label` | Texte du niveau (BEGINNER → EXPERT) |
| `context_length` | Longueur recommandée du contexte (tokens) |
| `is_structured` | Contenu structuré ou libre |
| `min_quality_score` | Score min pour être utilisé par IA |

---

### 🧰 `metadata.ai.use_cases`

Chaque type peut définir plusieurs cas d’usage IA (ex: génération, enseignement, validation).

| Field | Description |
|--------|----------------|
| `code` | Identifiant du cas d’usage |
| `weight` | Importance du cas |
| `description_key` | Clé i18n explicative |
| `min_quality_score` | Score min pour IA |
| `recommended` | Si l’IA doit le préférer |

---

## 📊 Métadonnées IA Complètes par Type

### `SYNTAX`

**Usage** : Montre la syntaxe correcte d'une commande ou fonction.

**Quand l'utiliser** :
- ✅ Pour documenter la syntaxe officielle d'une commande
- ✅ Pour enseigner la structure de base
- ✅ Pour génération automatique de code

**Métadonnées IA** :
```json
{
  "priority": 5,
  "weight": 0.9,
  "level": { "level": 1, "label": "BEGINNER" },
  "is_structured": true,
  "context_length": 350,
  "min_quality_score": 0.4,
  "use_cases": [
    { "code": "TEACH_SYNTAX", "weight": 0.9, "recommended": true },
    { "code": "GENERATE_SYNTAX", "weight": 0.7 }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:SYNTAX,
    content.text_key = i18n_key:syntax_define_field_text,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD field_name ON TABLE table_name TYPE type_name ASSERT assertion;"
        }
    ];
```

---

### `RULE`

**Usage** : Règle à suivre, bonne pratique, contrainte.

**Quand l'utiliser** :
- ✅ Pour documenter des règles de validation
- ✅ Pour bonnes pratiques et contraintes
- ✅ Pour validation de code par IA

**Métadonnées IA** :
```json
{
  "priority": 5,
  "weight": 1.0,
  "level": { "level": 2, "label": "INTERMEDIATE" },
  "is_structured": false,
  "context_length": 600,
  "min_quality_score": 0.6,
  "use_cases": [
    { "code": "VALIDATE_CODE", "weight": 1.0, "recommended": true },
    { "code": "TEACH_RULES", "weight": 0.8 }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:RULE,
    content.text_key = i18n_key:rule_field_naming_text,
    content.context_key = i18n_key:rule_field_naming_context;
```

---

### `EXAMPLE_CORRECT`

**Usage** : Exemple valide qui fonctionne.

**Quand l'utiliser** :
- ✅ Pour montrer un exemple concret qui fonctionne
- ✅ Pour génération d'exemples similaires
- ✅ Pour comparaison avec code utilisateur

**Métadonnées IA** :
```json
{
  "priority": 5,
  "weight": 0.95,
  "level": { "level": 1, "label": "BEGINNER" },
  "is_structured": true,
  "context_length": 400,
  "min_quality_score": 0.5,
  "use_cases": [
    { "code": "GENERATE_EXAMPLE", "weight": 0.9, "recommended": true },
    { "code": "COMPARE_OUTPUT", "weight": 0.6 }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:EXAMPLE_CORRECT,
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);",
            explanation_key: i18n_key:example_email_explanation
        }
    ];
```

---

### `EXAMPLE_INCORRECT`

**Usage** : Mauvais exemple + explication de l'erreur.

**Quand l'utiliser** :
- ✅ Pour prévenir des erreurs communes
- ✅ Pour enseigner les anti-patterns
- ✅ Pour aider l'IA à détecter les erreurs

**Métadonnées IA** :
```json
{
  "priority": 4,
  "weight": 0.7,
  "level": { "level": 2, "label": "INTERMEDIATE" },
  "is_structured": true,
  "context_length": 400,
  "min_quality_score": 0.7,
  "use_cases": [
    { "code": "PREVENT_MISTAKE", "weight": 1.0, "recommended": true },
    { "code": "TEACH_MISTAKE", "weight": 0.7 }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:EXAMPLE_INCORRECT,
    content.examples.incorrect = [
        {
            code: "DEFINE FIELD email TYPE string ASSERT email($value);",
            text_key: i18n_key:mistake_function_name_explanation
        }
    ];
```

---

### `TIP`

**Usage** : Conseil rapide et pratique.

**Quand l'utiliser** :
- ✅ Pour astuces courtes et pratiques
- ✅ Pour aide rapide sans trop de détails
- ✅ Pour conseils d'optimisation

**Métadonnées IA** :
```json
{
  "priority": 3,
  "weight": 0.6,
  "level": { "level": 1, "label": "BEGINNER" },
  "is_structured": false,
  "context_length": 200,
  "min_quality_score": 0.2,
  "use_cases": [
    { "code": "QUICK_HELP", "weight": 1.0, "recommended": true }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:TIP,
    content.text_key = i18n_key:tip_field_naming_text;
```

---

### `PATTERN`

**Usage** : Modèle réutilisable, pattern de conception.

**Quand l'utiliser** :
- ✅ Pour patterns de conception réutilisables
- ✅ Pour architectures complexes
- ✅ Pour modèles génériques

**Métadonnées IA** :
```json
{
  "priority": 5,
  "weight": 0.95,
  "level": { "level": 3, "label": "ADVANCED" },
  "is_structured": true,
  "context_length": 950,
  "min_quality_score": 0.75,
  "use_cases": [
    { "code": "GENERATE_PATTERN", "weight": 1.0, "recommended": true },
    { "code": "APPLY_PATTERN", "weight": 0.8 }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:PATTERN,
    content.text_key = i18n_key:pattern_validation_text,
    content.code = [
        {
            language: "surql",
            value: "-- Pattern: Validation avec fonctions natives\nDEFINE FIELD field_name ON TABLE table_name TYPE type_name ASSERT function::name($value);"
        }
    ],
    content.json = {
        pattern_name: "Native Function Validation",
        use_cases: ["email", "phone", "url"],
        complexity: "intermediate"
    };
```

---

### `EXPLANATION`

**Usage** : Explication détaillée et approfondie.

**Quand l'utiliser** :
- ✅ Pour explications approfondies de concepts
- ✅ Pour contexte détaillé
- ✅ Pour enseignement complet

**Métadonnées IA** :
```json
{
  "priority": 4,
  "weight": 0.8,
  "level": { "level": 2, "label": "INTERMEDIATE" },
  "is_structured": false,
  "context_length": 900,
  "min_quality_score": 0.5,
  "use_cases": [
    { "code": "TEACH_EXPLANATION", "weight": 1.0, "recommended": true }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:EXPLANATION,
    content.text_key = i18n_key:explanation_assertions_text,
    content.context_key = i18n_key:explanation_assertions_context;
```

---

### `REFERENCE`

**Usage** : Référence externe, lien vers ressource.

**Quand l'utiliser** :
- ✅ Pour références vers documentation externe
- ✅ Pour liens vers ressources complémentaires
- ✅ Pour sources de référence

**Métadonnées IA** :
```json
{
  "priority": 3,
  "weight": 0.5,
  "level": { "level": 1, "label": "BEGINNER" },
  "is_structured": false,
  "context_length": 150,
  "min_quality_score": 0.3,
  "use_cases": [
    { "code": "ADD_SOURCE", "weight": 1.0, "recommended": true }
  ]
}
```

**Exemple** :
```sql
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.content_type = knowledge_content_type:REFERENCE,
    content.text_key = i18n_key:reference_official_docs_text,
    content.media = [
        url:https://surrealdb.com/docs/surrealql/statements/define/field
    ];
```

---

## 🎯 Guide d'Utilisation : Quand Utiliser Chaque Type ?

### Pour un nouveau topic, créer au minimum :

1. **1 SYNTAX** → Montre la syntaxe de base
2. **1 EXAMPLE_CORRECT** → Exemple concret qui fonctionne
3. **1 RULE** → Règle importante à suivre
4. **1 TIP** → Conseil rapide (optionnel mais recommandé)

### Pour un topic complet, ajouter :

5. **1 EXAMPLE_INCORRECT** → Prévenir les erreurs communes
6. **1 EXPLANATION** → Contexte détaillé (si nécessaire)
7. **1 PATTERN** → Pattern réutilisable (si applicable)
8. **N REFERENCE** → Références externes (si disponible)

### Ordre de priorité pour l'IA :

1. **Priorité 5** : `SYNTAX`, `RULE`, `EXAMPLE_CORRECT`, `PATTERN` → Essentiels
2. **Priorité 4** : `EXAMPLE_INCORRECT`, `EXPLANATION` → Importants
3. **Priorité 3** : `TIP`, `REFERENCE` → Utiles mais secondaires

---

## 🤖 Utilisation par l'IA

### Requête pour récupérer les types adaptés à un cas d'usage

```sql
-- Récupérer les types pour génération de syntaxe
SELECT * FROM knowledge_content_type
WHERE metadata.ai.use_cases[*].code CONTAINS "GENERATE_SYNTAX"
    AND metadata.ai.priority >= 4
ORDER BY metadata.ai.weight DESC;

-- Récupérer les types pour validation
SELECT * FROM knowledge_content_type
WHERE metadata.ai.use_cases[*].code CONTAINS "VALIDATE_CODE"
    AND metadata.ai.min_quality_score <= 0.7
ORDER BY metadata.ai.weight DESC;
```

### Filtrage par niveau de complexité

```sql
-- Contenus adaptés pour débutants
SELECT * FROM knowledge_content
WHERE identity.content_type.metadata.ai.level.level <= 2
    AND metadata.is_active = true;

-- Contenus adaptés pour experts
SELECT * FROM knowledge_content
WHERE identity.content_type.metadata.ai.level.level >= 4
    AND metadata.is_active = true;
```

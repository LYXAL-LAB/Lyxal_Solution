# 📋 Syntaxe SurrealDB : Arrays d'objets avec wildcard `*`

## 🎯 Objectif

Ce document explique la syntaxe correcte pour définir les champs d'objets dans les arrays (`array<object>`) en SurrealDB. Cette syntaxe est **essentielle** pour le module Knowledge System et toutes les données qui utilisent des arrays d'objets.

---

## ⚠️ Problème sans le wildcard `*`

Sans utiliser le wildcard `*`, lors d'un `CREATE`, SurrealDB ne peut pas créer correctement les objets dans le array et retourne un **array d'objets vides**.

### ❌ Syntaxe INCORRECTE

```surql
DEFINE FIELD IF NOT EXISTS content.code ON TABLE knowledge_content
    TYPE option<array<object>>;

DEFINE FIELD IF NOT EXISTS content.code.language ON TABLE knowledge_content
    TYPE string;
    -- ❌ ERREUR : Sans le wildcard, les objets ne seront pas créés
```

### ✅ Syntaxe CORRECTE

```surql
DEFINE FIELD IF NOT EXISTS content.code ON TABLE knowledge_content
    TYPE option<array<object>>;

DEFINE FIELD IF NOT EXISTS content.code.*.language ON TABLE knowledge_content
    TYPE string;
    -- ✅ CORRECT : Le wildcard * permet de définir les champs de chaque objet dans le array
```

---

## 📚 Règle générale

Pour définir les champs d'objets dans un `array<object>`, utilisez toujours le wildcard `*` entre le nom du champ array et le nom du champ de l'objet.

**Pattern** : `[chemin_vers_array].*.[champ_objet]`

---

## 🔍 Exemples dans le Knowledge System

### Exemple 1 : `content.code` (array de blocs de code)

```surql
-- Définition du array
DEFINE FIELD IF NOT EXISTS content.code ON TABLE knowledge_content
    TYPE option<array<object>>
    COMMENT 'Liste de blocs de code (multi-langage)';

-- Définition des champs de chaque objet dans le array (avec wildcard *)
DEFINE FIELD IF NOT EXISTS content.code.*.language ON TABLE knowledge_content
    TYPE string
    COMMENT 'Langage du code (ex: "surql", "js", "json")';

DEFINE FIELD IF NOT EXISTS content.code.*.value ON TABLE knowledge_content
    TYPE string
    COMMENT 'Code source';

DEFINE FIELD IF NOT EXISTS content.code.*.explanation_key ON TABLE knowledge_content
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n : explication du code (optionnelle)';
```

**Utilisation lors d'un CREATE** :

```surql
CREATE knowledge_content SET
    content.code = [
        {
            language: "surql",
            value: "DEFINE FIELD name ON TABLE user TYPE string;",
            explanation_key: i18n_key:expl_define_field
        },
        {
            language: "js",
            value: "// Equivalent JavaScript",
            explanation_key: i18n_key:expl_js_equivalent
        }
    ];
```

---

### Exemple 2 : `content.examples.correct` (array d'exemples corrects)

```surql
-- Définition du array
DEFINE FIELD IF NOT EXISTS content.examples.correct ON TABLE knowledge_content
    TYPE option<array<object>>
    COMMENT 'Liste d\'exemples corrects';

-- Définition des champs de chaque objet dans le array (avec wildcard *)
DEFINE FIELD IF NOT EXISTS content.examples.correct.*.text_key ON TABLE knowledge_content
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n : explication de l\'exemple correct';

DEFINE FIELD IF NOT EXISTS content.examples.correct.*.code ON TABLE knowledge_content
    TYPE option<string>
    COMMENT 'Code correct (si applicable)';
```

**Utilisation lors d'un CREATE** :

```surql
CREATE knowledge_content SET
    content.examples.correct = [
        {
            text_key: i18n_key:example_correct_1,
            code: "DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);"
        },
        {
            text_key: i18n_key:example_correct_2,
            code: "DEFINE FIELD age ON TABLE user TYPE int ASSERT $value > 0;"
        }
    ];
```

---

### Exemple 3 : `metadata.ai.use_cases` (array de cas d'usage IA)

Référence : `knowledge_content_type.surql`

```surql
-- Définition du array
DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases ON TABLE knowledge_content_type
    TYPE option<array<object>>
    COMMENT 'Liste de cas d\'usage IA';

-- Définition des champs de chaque objet dans le array (avec wildcard *)
DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.code ON TABLE knowledge_content_type
    TYPE string
    COMMENT 'Code du cas d\'usage (UPPER_SNAKE_CASE)';

DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.weight ON TABLE knowledge_content_type
    TYPE number
    DEFAULT 0.5
    ASSERT $value >= 0 AND $value <= 1
    COMMENT 'Poids IA du cas d\'usage';

DEFINE FIELD IF NOT EXISTS metadata.ai.use_cases.*.description_key ON TABLE knowledge_content_type
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour description du cas d\'usage (optionnel)';
```

---

## 🎯 Champs concernés dans le Knowledge System

### Table `knowledge_content`

| Champ array | Wildcard utilisé | Exemple |
|-------------|------------------|---------|
| `content.code` | `content.code.*.language` | ✅ |
| `content.examples.correct` | `content.examples.correct.*.text_key` | ✅ |
| `content.examples.incorrect` | `content.examples.incorrect.*.text_key` | ✅ |

### Table `knowledge_content_type`

| Champ array | Wildcard utilisé | Exemple |
|-------------|------------------|---------|
| `metadata.ai.use_cases` | `metadata.ai.use_cases.*.code` | ✅ |

---

## ⚙️ Cas spéciaux

### Arrays de records (pas besoin de wildcard)

Pour les arrays de records (ex: `array<record<tag>>`, `array<record<url>>`), le wildcard `*` n'est **pas nécessaire** car ce sont des références vers d'autres tables.

```surql
DEFINE FIELD IF NOT EXISTS tags ON TABLE knowledge_content
    TYPE option<array<record<tag>>>
    COMMENT 'Tags associés au contenu';
    -- ✅ Pas besoin de wildcard pour les records
```

---

## 📝 Checklist lors de la création de données

Lors de la création de données avec des arrays d'objets :

- [ ] Vérifier que le schéma utilise `*` pour définir les champs des objets
- [ ] Vérifier que lors du CREATE, les objets dans le array sont bien structurés
- [ ] Tester avec un exemple simple avant de créer toutes les données
- [ ] Vérifier que les objets ne sont pas vides après création

---

## 🧵 Résumé

**Règle d'or** : Pour tout `array<object>`, utilisez toujours le wildcard `*` pour définir les champs des objets individuels.

**Syntaxe** : `[chemin_array].*.[champ_objet]`

**Exemples** :
- ✅ `content.code.*.language`
- ✅ `content.examples.correct.*.text_key`
- ✅ `metadata.ai.use_cases.*.code`

**Exception** : Les arrays de records (`array<record<table>>`) n'ont pas besoin du wildcard.

---

## 📚 Références

- Fichier de référence : `knowledge/database/knowledge_content_type.surql` (lignes 122-150)
- Fichier de référence : `knowledge/database/knowledge_content.surql` (lignes 72-87, 110-134)
- Documentation SurrealDB : [Schema definitions](https://surrealdb.com/docs/surrealql/statements/define)


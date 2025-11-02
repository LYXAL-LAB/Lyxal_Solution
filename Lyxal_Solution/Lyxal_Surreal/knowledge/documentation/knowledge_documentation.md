# 📚 Knowledge Pack SurrealDB - Documentation

## 🎯 Vue d'ensemble

Le **Knowledge Pack SurrealDB** est un système de connaissance centralisé stocké directement dans SurrealDB. Il permet aux IA et aux développeurs d'accéder à une base de connaissances complète sur SurrealDB pour générer du code fiable et conforme aux bonnes pratiques.

## 🧩 Structure

Le système est composé de deux tables principales :

### 1. `knowledge_pack_topic`

Table des sujets de connaissance (topics). Chaque topic représente un concept SurrealDB (ex: DEFINE FIELD, DEFINE TABLE, RELATE, etc.).

**Champs principaux :**
- `identity.code` : Code unique du topic (ex: "DEFINE_FIELD")
- `identity.name` : Nom descriptif (ex: "DEFINE FIELD")
- `identity.description` : Description du topic
- `metadata.category` : Catégorie (DEFINE, RELATE, SELECT, INDEX, etc.)
- `metadata.priority` : Priorité d'affichage
- `metadata.is_active` : Le topic est actif

### 2. `knowledge_pack_content`

Table du contenu de connaissance. Chaque entrée est une unité de connaissance liée à un topic.

**Types de contenu :**
- `syntax` : Syntaxe officielle
- `rule` : Bonnes pratiques et règles
- `example_correct` : Exemples corrects
- `example_incorrect` : Mauvais exemples (anti-patterns)
- `tip` : Conseils et astuces
- `pattern` : Patterns réutilisables
- `explanation` : Explications détaillées

**Champs principaux :**
- `topic` : Référence au topic parent
- `identity.content_type` : Type de contenu
- `content.surql_code` : Code SurrealQL (si applicable)
- `content.explanation` : Explication détaillée
- `metadata.tags` : Tags pour recherche et filtrage

## 🔍 Utilisation

### Requête : Obtenir le bundle complet d'un topic

Pour obtenir toutes les connaissances sur un topic (par exemple DEFINE FIELD), utilisez cette requête :

```surql
SELECT 
    topic.identity.*,
    ->knowledge_pack_content AS contents
FROM knowledge_pack_topic 
WHERE identity.code = "DEFINE_FIELD" 
    AND metadata.is_active = true
FETCH contents;
```

### Requête : Obtenir un type spécifique de contenu

Pour obtenir seulement les exemples corrects d'un topic :

```surql
SELECT * FROM knowledge_pack_content
WHERE topic = knowledge_pack_topic:define_field
    AND identity.content_type = "example_correct"
    AND metadata.is_active = true
ORDER BY metadata.priority DESC;
```

### Requête : Rechercher par tag

Pour trouver tous les contenus avec un tag spécifique :

```surql
SELECT 
    content.*,
    topic.identity.name AS topic_name
FROM knowledge_pack_content AS content
WHERE content.metadata.tags CONTAINS "validation"
    AND content.metadata.is_active = true
FETCH topic;
```

### Requête : Bundle formaté pour IA

Requête optimisée pour générer un prompt complet pour une IA :

```surql
SELECT {
    topic: topic.identity.name,
    description: topic.identity.description,
    syntax: array::group(
        (SELECT content FROM knowledge_pack_content 
         WHERE topic = topic.id 
           AND identity.content_type = "syntax"
           AND metadata.is_active = true)[0].content
    ),
    rules: (SELECT {
        title: identity.title,
        explanation: content.explanation,
        when_to_use: content.when_to_use
    } FROM knowledge_pack_content 
    WHERE topic = topic.id 
      AND identity.content_type = "rule"
      AND metadata.is_active = true),
    examples_correct: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation
    } FROM knowledge_pack_content 
    WHERE topic = topic.id 
      AND identity.content_type = "example_correct"
      AND metadata.is_active = true),
    examples_incorrect: (SELECT {
        title: identity.title,
        code: content.surql_code,
        why_incorrect: content.why_incorrect
    } FROM knowledge_pack_content 
    WHERE topic = topic.id 
      AND identity.content_type = "example_incorrect"
      AND metadata.is_active = true),
    tips: (SELECT {
        title: identity.title,
        explanation: content.explanation,
        when_to_use: content.when_to_use
    } FROM knowledge_pack_content 
    WHERE topic = topic.id 
      AND identity.content_type = "tip"
      AND metadata.is_active = true),
    patterns: (SELECT {
        title: identity.title,
        code: content.surql_code,
        explanation: content.explanation,
        when_to_use: content.when_to_use
    } FROM knowledge_pack_content 
    WHERE topic = topic.id 
      AND identity.content_type = "pattern"
      AND metadata.is_active = true)
} FROM knowledge_pack_topic AS topic
WHERE topic.identity.code = "DEFINE_FIELD"
    AND topic.metadata.is_active = true;
```

## ➕ Ajouter de nouvelles connaissances

### Ajouter un nouveau topic

```surql
CREATE knowledge_pack_topic:define_table {
    identity: {
        code: "DEFINE_TABLE",
        name: "DEFINE TABLE",
        description: "Définition de tables dans SurrealDB"
    },
    metadata: {
        category: "DEFINE",
        priority: 10,
        version: "1.0.0",
        is_active: true
    }
};
```

### Ajouter du contenu à un topic existant

```surql
CREATE knowledge_pack_content:new_rule {
    topic: knowledge_pack_topic:define_field,
    identity: {
        content_type: "rule",
        title: "Nouvelle règle",
        description: "Description de la règle"
    },
    content: {
        explanation: "Explication de la règle",
        when_to_use: "Quand utiliser cette règle"
    },
    metadata: {
        priority: 8,
        tags: ["new", "rule"],
        is_active: true,
        version: "1.0.0"
    }
};
```

## 📋 Topics actuellement disponibles

- ✅ **DEFINE_FIELD** : Définition complète de champs (syntaxe, règles, exemples, patterns)

## 🚀 Topics prévus (placeholders disponibles)

Les fichiers de seeds contiennent des placeholders commentés pour :
- DEFINE_TABLE
- DEFINE_INDEX
- RELATE
- PERMISSIONS
- SELECT
- Etc.

Pour activer un topic, décommentez le CREATE correspondant dans `knowledge_pack_topic_seeds.surql` et ajoutez le contenu dans `knowledge_pack_content_seeds.surql`.

## 🎓 Utilisation par une IA

Une IA peut utiliser le Knowledge Pack de plusieurs façons :

1. **Auto-apprentissage** : Lire les règles et exemples pour comprendre les bonnes pratiques
2. **Génération de code** : Utiliser les patterns et exemples corrects pour générer du code SurrealQL
3. **Validation** : Comparer le code généré avec les anti-patterns pour détecter les erreurs
4. **Correction** : Utiliser les exemples incorrects et leurs corrections pour améliorer le code

## 📝 Exemple d'utilisation pour génération de code

```surql
-- 1. Récupérer le bundle complet
LET $knowledge = (SELECT ... FROM knowledge_pack_topic WHERE identity.code = "DEFINE_FIELD");

-- 2. Extraire les règles
LET $rules = $knowledge.rules;

-- 3. Extraire les patterns
LET $patterns = $knowledge.patterns;

-- 4. Utiliser pour générer un champ email
-- En suivant le pattern email_field et les règles de validation
```

## ✅ Critères de succès

Le système est considéré réussi lorsque :

- ✅ La connaissance SurrealDB est stockée en base
- ✅ On peut faire une requête SurrealQL et obtenir un bundle complet pour un topic
- ✅ Une IA peut utiliser ce bundle pour générer du code SurrealDB
- ✅ Il est possible d'ajouter de nouvelles connaissances sans modifier du code, uniquement en insérant en base

## 🔄 Maintenance

Le Knowledge Pack est conçu pour être **100% extensible sans modification de code** :

- Ajouter un nouveau topic : INSERT dans `knowledge_pack_topic`
- Ajouter du contenu : INSERT dans `knowledge_pack_content`
- Désactiver temporairement : `UPDATE ... SET metadata.is_active = false`
- Versioning : Utiliser `metadata.version` pour suivre les versions


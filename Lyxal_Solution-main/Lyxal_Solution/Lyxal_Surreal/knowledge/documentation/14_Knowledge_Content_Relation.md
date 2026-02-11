# 🔗 Knowledge Content Relation – Relations entre Contenus

## 🎯 Objectif

La table `knowledge_content_relation` permet de créer des **liens structurés entre contenus de connaissance** pour représenter des relations comme prérequis, dépendances, références, etc.

---

## 📊 Vue d'Ensemble

| Aspect | Description |
|--------|-------------|
| **Type** | `RELATION` (table relationnelle SurrealDB) |
| **Rôle** | Créer des liens entre contenus (`knowledge_content` → `knowledge_content`) |
| **Dépendances** | `knowledge_content` |

---

## 🔗 Types de Relations

| Type | Description | Exemple |
|------|-------------|---------|
| `prerequisite` | Le contenu source est un prérequis du contenu destination | "DEFINE TABLE" est un prérequis de "DEFINE FIELD" |
| `dependency` | Le contenu destination dépend du contenu source | "DEFINE FIELD" dépend de "DEFINE TABLE" |
| `reference` | Le contenu source référence le contenu destination | Un exemple référence une documentation |
| `related` | Les contenus sont simplement liés/associés | Deux méthodes différentes pour faire la même chose |

---

## 🧱 Structure des Champs

### Relation (`relation_type`)

| Champ | Type | Description |
|-------|------|-------------|
| `relation_type` | `string` | Type de relation : `"prerequisite"`, `"dependency"`, `"reference"`, `"related"` |

### Métadonnées (`metadata`)

| Champ | Type | Description |
|-------|------|-------------|
| `metadata.is_active` | `bool` | La relation est active (défaut: `true`) |
| `metadata.created_at` | `datetime` | Date de création (défaut: `time::now()`) |
| `metadata.created_by` | `option<string>` | Identifiant du créateur |

### Champs additionnels

| Champ | Type | Description |
|-------|------|-------------|
| `description` | `option<string>` | Description optionnelle de la relation |
| `priority` | `int` | Ordre de priorité pour navigation (défaut: `0`) |

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_relation_type` | `relation_type` | Normal | Recherche par type de relation |
| `idx_relation_active` | `metadata.is_active` | Normal | Filtrage par statut actif |
| `idx_relation_in_out` | `in, out` | Composite | Recherche par contenus source/destination |
| `idx_relation_priority` | `priority` | Normal | Tri par priorité |

---

## 📝 Exemples d'Utilisation

### Créer une relation prérequis

```surql
-- "DEFINE TABLE" est un prérequis de "DEFINE FIELD"
RELATE knowledge_content:define-table-basics ->knowledge_content_relation-> knowledge_content:define-field-basics SET
    relation_type = "prerequisite",
    description = "Il faut connaître DEFINE TABLE avant DEFINE FIELD",
    priority = 1,
    metadata.created_by = "system";
```

### Créer une relation de dépendance

```surql
-- "DEFINE FIELD" dépend de "DEFINE TABLE"
RELATE knowledge_content:define-field-basics ->knowledge_content_relation-> knowledge_content:define-table-basics SET
    relation_type = "dependency",
    description = "DEFINE FIELD nécessite la compréhension de DEFINE TABLE",
    priority = 1;
```

### Créer une relation référence

```surql
-- Un exemple référence une documentation
RELATE knowledge_content:example-user-table ->knowledge_content_relation-> knowledge_content:documentation-user-table SET
    relation_type = "reference",
    priority = 2;
```

### Créer une relation liée

```surql
-- Deux méthodes alternatives pour créer une table
RELATE knowledge_content:create-table-method1 ->knowledge_content_relation-> knowledge_content:create-table-method2 SET
    relation_type = "related",
    description = "Méthodes alternatives pour créer une table",
    priority = 3;
```

---

## 🔍 Requêtes Utiles

### Trouver tous les prérequis d'un contenu

```surql
SELECT 
    ->knowledge_content_relation[WHERE relation_type = "prerequisite"]->(in AS prerequisite) AS prerequisites
FROM knowledge_content:define-field-basics
FETCH prerequisites;
```

### Trouver toutes les dépendances d'un contenu

```surql
SELECT 
    <-knowledge_content_relation[WHERE relation_type = "dependency"]<-knowledge_content AS dependencies
FROM knowledge_content:define-table-basics;
```

### Trouver tous les contenus liés

```surql
SELECT 
    ->knowledge_content_relation[WHERE relation_type = "related"]->(out AS related) AS related_contents,
    <-knowledge_content_relation[WHERE relation_type = "related"]<-knowledge_content AS also_related
FROM knowledge_content:define-field-basics
FETCH related_contents;
```

### Obtenir le graphe complet d'un contenu

```surql
SELECT 
    id,
    identity.slug,
    ->knowledge_content_relation->(out AS related, relation_type) AS outgoing_relations,
    <-knowledge_content_relation<-knowledge_content AS incoming_relations
FROM knowledge_content:define-field-basics
FETCH related;
```

---

## 🔄 Intégration avec `content.references`

Le champ `content.references` dans `knowledge_content` peut être utilisé pour référencer rapidement d'autres contenus sans créer de relation structurée. Les relations `knowledge_content_relation` sont plus appropriées pour :

- Relations structurées avec types spécifiques
- Navigation hiérarchique (prérequis → contenu)
- Analyse de dépendances
- Graphes de connaissance complexes

Le champ `content.references` est plus simple et adapté pour :
- Références rapides dans un contenu
- Listes de contenus associés
- Liens simples sans métadonnées

---

## 📚 Références

- **Table knowledge_content** : `06_Knowledge_Content.md`
- **Champ content.references** : `06_Knowledge_Content.md` (section Content)
- **Schéma complet** : `SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


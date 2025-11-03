# 🔎 Keywords du Système de Connaissance

## 🎯 Objectif

Les **mots-clés (keywords)** sont des **entités référencées** utilisées pour améliorer la recherche et l'indexation des contenus de connaissance.  
Ils permettent :

- la recherche full-text (BM25),
- la recherche sémantique,
- la navigation UX,
- l'interprétation par l'IA.

Les mots-clés sont stockés dans une table dédiée `knowledge_keyword` et liés aux domaines et topics via des **tables relationnelles** (`knowledge_domain_keyword` et `knowledge_topic_keyword`).

---

## 🧱 Architecture

### Table principale : `knowledge_keyword`

Les mots-clés sont stockés comme **records** dans la table `knowledge_keyword` :

| Champ | Type | Description |
|-------|------|-------------|
| `identity.value` | `string` | Valeur du mot-clé (lowercase, max 100 caractères) |
| `identity.slug` | `string` | Slug du mot-clé (pour URL et référence) |
| `metadata.is_active` | `bool` | Le mot-clé est actif |
| `metadata.usage_count` | `int` | Nombre d'utilisations (domaines + topics) |

### Tables relationnelles

Les mots-clés sont liés aux domaines et topics via des **tables TYPE RELATION** :

- `knowledge_domain_keyword` : Relation entre un domaine et un mot-clé (record)
- `knowledge_topic_keyword` : Relation entre un topic et un mot-clé (record)

**Structure des relations :**
- `in` : Record vers le domaine ou topic (`record<knowledge_domain>` ou `record<knowledge_topic>`)
- `out` : **Record vers le mot-clé** (`record<knowledge_keyword>`)

### Analyseur full-text

Les mots-clés utilisent l'analyseur `knowledge_keywords_analyzer` pour :
- Tokenisation : `blank`, `class`
- Filtrage : `lowercase`, `ascii`
- Indexation BM25 avec highlighting

---

## 🔗 Relations

| Table | Type | Rôle |
|--------|--------|--------|
| `knowledge_keyword` | NORMAL | Référentiel des mots-clés |
| `knowledge_domain_keyword` | RELATION | Mots-clés liés à un domaine |
| `knowledge_topic_keyword` | RELATION | Mots-clés liés à un topic |

---

## 📋 Contraintes et règles

### Format des mots-clés

- **Type** : Record dans `knowledge_keyword`
- **Valeur** : String en lowercase (max 100 caractères)
- **Normalisation** : Automatique en lowercase via ASSERT
- **Unicité** : Un mot-clé unique par valeur (index UNIQUE sur `identity.value`)
- **Relations** : Un mot-clé unique par domaine/topic (contrainte UNIQUE sur `in, out`)

### Exemples de mots-clés valides

- `permissions`
- `assert`
- `relation`
- `fulltext_search`
- `pattern`
- `ai_context`
- `definitions`
- `queries`

---

## 🔎 Exemples d'utilisation

### Créer un mot-clé

```sql
-- Créer un nouveau mot-clé
CREATE knowledge_keyword:surreal SET
    identity.value = "surreal",
    identity.slug = "surreal",
    metadata.is_active = true,
    metadata.usage_count = 0;
```

### Lier un mot-clé à un domaine

```sql
-- Lier un mot-clé à un domaine
RELATE knowledge_domain:SURREAL_DB 
    ->knowledge_domain_keyword->knowledge_keyword:surreal;
```

### Lier un mot-clé à un topic

```sql
-- Lier un mot-clé à un topic
RELATE knowledge_topic:DEFINE_FIELD 
    ->knowledge_topic_keyword->knowledge_keyword:assert;
```

### Récupérer les mots-clés d'un domaine

```sql
-- Récupérer tous les mots-clés d'un domaine
SELECT ->knowledge_domain_keyword->out AS keywords 
FROM knowledge_domain:SURREAL_DB;

-- Avec détails des keywords
SELECT ->knowledge_domain_keyword->out {
    id,
    identity.value,
    identity.slug,
    metadata.usage_count
} AS keywords 
FROM knowledge_domain:SURREAL_DB;
```

### Recherche full-text dans les mots-clés

```sql
-- Rechercher les domaines par mot-clé (via relation)
SELECT 
    in AS domain,
    out.identity.value AS keyword_value
FROM knowledge_domain_keyword 
WHERE out.identity.value @1@ "surreal";

-- Rechercher les topics par mot-clé
SELECT 
    in AS topic,
    out.identity.value AS keyword_value
FROM knowledge_topic_keyword 
WHERE out.identity.value @1@ "assert";
```

### Trouver tous les domaines/topics utilisant un mot-clé

```sql
-- Domaines utilisant un mot-clé spécifique
SELECT <-knowledge_domain_keyword<-in AS domains
FROM knowledge_keyword:surreal;

-- Topics utilisant un mot-clé spécifique
SELECT <-knowledge_topic_keyword<-in AS topics
FROM knowledge_keyword:assert;
```

---

## 🔄 Workflow recommandé

### 1. Créer ou récupérer le mot-clé

```sql
-- Option 1 : Créer un nouveau mot-clé
CREATE knowledge_keyword:assert SET
    identity.value = "assert",
    identity.slug = "assert",
    metadata.is_active = true;

-- Option 2 : Utiliser un mot-clé existant
SELECT id FROM knowledge_keyword WHERE identity.value = "assert" LIMIT 1;
```

### 2. Lier le mot-clé à un domaine/topic

```sql
-- Lier au domaine
RELATE knowledge_domain:SURREAL_DB 
    ->knowledge_domain_keyword->knowledge_keyword:assert;

-- Lier au topic
RELATE knowledge_topic:DEFINE_FIELD 
    ->knowledge_topic_keyword->knowledge_keyword:assert;
```

### 3. Mettre à jour le compteur d'utilisation (optionnel)

```sql
-- Mettre à jour usage_count lors de l'ajout d'une relation
UPDATE knowledge_keyword:assert SET
    metadata.usage_count += 1;
```

---

## 📊 Avantages de cette approche

### ✅ Avantages

1. **Référentiel centralisé** : Tous les mots-clés sont dans une seule table
2. **Déduplication automatique** : Un même mot-clé peut être réutilisé
3. **Métadonnées enrichies** : Possibilité d'ajouter des infos sur chaque mot-clé
4. **Comptage d'utilisation** : Suivi de la popularité des mots-clés
5. **Conformité avec SurrealDB** : Les relations pointent vers des records
6. **Recherche efficace** : Index full-text sur `identity.value`

### ⚠️ Points d'attention

1. **Création préalable** : Il faut créer le mot-clé avant de l'utiliser dans une relation
2. **Gestion des slugs** : Les slugs doivent être cohérents avec les valeurs
3. **Normalisation** : Les valeurs sont automatiquement en lowercase

---

## 🔍 Différence avec les Tags

| Aspect | Keywords | Tags |
|--------|----------|------|
| **Table** | `knowledge_keyword` (dédiée) | `tag` (globale) |
| **Type** | Records dans table knowledge | Records dans table tag globale |
| **Usage** | Recherche full-text, sémantique | Catégorisation structurée |
| **Multiplicité** | Plusieurs par domaine/topic | Plusieurs par domaine/topic |
| **Normalisation** | Lowercase automatique | Défini dans table tag |
| **Métadonnées** | Usage count, active/inactive | Défini dans table tag |

**Recommandation** :
- **Keywords** : Pour recherche sémantique, synonymes, termes techniques
- **Tags** : Pour catégorisation structurée, organisation hiérarchique

---

## 📚 Références

- Documentation `knowledge_keyword` : Table principale des mots-clés
- Documentation `knowledge_domain_keyword` : Relations domaines ↔ keywords
- Documentation `knowledge_topic_keyword` : Relations topics ↔ keywords
- Guide Tags vs Keywords : Comparaison détaillée dans `08_Knowledge_Keyword.md`

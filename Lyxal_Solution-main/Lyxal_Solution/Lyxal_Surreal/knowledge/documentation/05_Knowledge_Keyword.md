# 📋 Table : `knowledge_keyword`

## 🎯 Objectif

La table `knowledge_keyword` représente le **référentiel centralisé des mots-clés** utilisés pour la recherche full-text et l'indexation dans le système Knowledge.

Elle permet :
- ✅ Un référentiel centralisé et normalisé
- ✅ Réutilisation des mots-clés entre domaines et topics
- ✅ Métadonnées enrichies (usage_count, is_active)
- ✅ Recherche full-text efficace via index SEARCH ANALYZER

---

## 🧱 Structure

| Bloc | Champ | Type | Description |
|------|-------|------|-------------|
| `identity` | `value` | `string` | Valeur du mot-clé en lowercase (max 100 caractères, UNIQUE) |
| `identity` | `slug` | `string` | Slug du mot-clé (pour URL et référence, UNIQUE) |
| `metadata` | `is_active` | `bool` | Le mot-clé est actif et peut être utilisé |
| `metadata` | `usage_count` | `int` | Nombre d'utilisations (domaines + topics) |

---

## 🔗 Relations

| Table liée | Type | Description |
|------------|------|-------------|
| `knowledge_domain_keyword` | N ↔ N | Relations avec les domaines |
| `knowledge_topic_keyword` | N ↔ N | Relations avec les topics |

---

## 📋 Contraintes

- ✅ **Unicité** : `identity.value` est UNIQUE (via index)
- ✅ **Unicité** : `identity.slug` est UNIQUE (via index)
- ✅ **Normalisation** : `identity.value` doit être en lowercase (ASSERT)
- ✅ **Taille** : `identity.value` max 100 caractères

---

## 🔎 Index

| Index | Champs | Type | Description |
|-------|--------|------|-------------|
| `idx_keyword_value` | `identity.value` | UNIQUE | Index unique sur la valeur |
| `idx_keyword_slug` | `identity.slug` | UNIQUE | Index unique sur le slug |
| `idx_keyword_search` | `identity.value` | SEARCH ANALYZER | Index full-text pour recherche BM25 |
| `idx_keyword_active` | `metadata.is_active` | Standard | Index sur le statut actif |

---

## 📝 Exemples

### Créer un mot-clé

```sql
CREATE knowledge_keyword:assert SET
    identity.value = "assert",
    identity.slug = "assert",
    metadata.is_active = true,
    metadata.usage_count = 0;
```

### Récupérer un mot-clé par valeur

```sql
SELECT * FROM knowledge_keyword 
WHERE identity.value = "assert";
```

### Recherche full-text

```sql
-- Rechercher des mots-clés par texte
SELECT 
    id,
    identity.value,
    identity.slug,
    metadata.usage_count
FROM knowledge_keyword 
WHERE identity.value @1@ "assert";
```

### Récupérer tous les domaines utilisant un mot-clé

```sql
SELECT 
    <-knowledge_domain_keyword<-in AS domains
FROM knowledge_keyword:assert;
```

### Récupérer tous les topics utilisant un mot-clé

```sql
SELECT 
    <-knowledge_topic_keyword<-in AS topics
FROM knowledge_keyword:assert;
```

---

## 🔄 Workflow recommandé

### 1. Créer ou récupérer le mot-clé

```sql
-- Option 1 : Créer un nouveau mot-clé
CREATE knowledge_keyword:new_keyword SET
    identity.value = "new_keyword",
    identity.slug = "new-keyword",
    metadata.is_active = true;

-- Option 2 : Utiliser un mot-clé existant (recommandé pour éviter doublons)
SELECT id FROM knowledge_keyword 
WHERE identity.value = "new_keyword" 
LIMIT 1;
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

## 📊 Avantages

### ✅ Référentiel centralisé

- Tous les mots-clés sont dans une seule table
- Déduplication automatique
- Normalisation garantie (lowercase)

### ✅ Métadonnées enrichies

- Suivi de la popularité (`usage_count`)
- Activation/désactivation (`is_active`)
- Slug pour URL et référence

### ✅ Recherche efficace

- Index full-text sur `identity.value`
- Recherche BM25 avec highlighting
- Recherche par slug également possible

---

## 🔍 Relation avec les Tags

| Aspect | Keywords | Tags |
|--------|----------|------|
| **Table** | `knowledge_keyword` (knowledge) | `tag` (globale) |
| **Usage** | Recherche full-text, sémantique | Catégorisation structurée |
| **Normalisation** | Lowercase automatique | Défini dans table tag |
| **Métadonnées** | Usage count, active/inactive | Défini dans table tag |

**Recommandation** :
- **Keywords** : Pour recherche sémantique, synonymes, termes techniques
- **Tags** : Pour catégorisation structurée, organisation hiérarchique

---

## 📚 Références

- Documentation Keywords : `08_Knowledge_Keyword.md`
- Documentation Relations : `09_Knowledge_Relations.md`
- Guide Tags vs Keywords : Comparaison détaillée dans `08_Knowledge_Keyword.md`


# 🔎 Table : `knowledge_keyword`

## 🎯 Objectif

La table `knowledge_keyword` sert de **référentiel centralisé des mots-clés** utilisés dans le système de connaissance.  
Elle apporte une **cohérence globale** pour :

- l’indexation des contenus,
- la recherche intelligente,
- la navigation UX,
- l’interprétation par l’IA.

Les mots-clés sont liés aux domaines, topics et contenus via des relations dédiées.

---

## 🧱 Structure

| Bloc | Description |
|-------|----------------|
| `identity` | Code + i18n |
| `metadata` | Paramètres UI/activation/statut |
| `metadata.ai` | Paramètres d’optimisation IA |

---

## 🔗 Relations

| Table | Type | Rôle |
|--------|--------|--------|
| `knowledge_domain_keyword` | RELATION | Mots-clés liés à un domaine |
| `knowledge_topic_keyword` | RELATION | Mots-clés liés à un topic |
| `knowledge_content_keyword` *(optionnel futur)* | RELATION | Mots-clés liés au contenu |

---

## 🧩 Champs principaux

### 🧠 `identity`

| Field | Description |
|--------|----------------|
| `code` | Identifiant unique en UPPER_SNAKE_CASE |
| `label_key` | Clé i18n du mot-clé affiché en UI |
| `description_key` | Clé i18n description (optionnel) |

Exemples de mots-clés :

- `PERMISSIONS`
- `ASSERT`
- `RELATION`
- `FULLTEXT_SEARCH`
- `PATTERN`
- `AI_CONTEXT`

---

### 📍 `metadata`

| Field | Description |
|--------|----------------|
| `is_active` | Le mot-clé peut être utilisé ou non |
| `display_order` | Ordre d’affichage |
| `version_label` | Version fonctionnelle |

---

### 🤖 `metadata.ai`

Permet à l’IA d’utiliser les mots-clés intelligemment.

| Field | Description |
|--------|----------------|
| `weight` | Importance (0 → 1) |
| `min_quality_score` | Score minimal IA |
| `recommended` | Suggestion prioritaire |

---

## 🔎 Exemples

### ✅ Récupérer tous les mots-clés actifs classés pour UI

```sql
SELECT identity.code, identity.label_key
FROM knowledge_keyword
WHERE metadata.is_active = true
ORDER BY metadata.display_order;

🤖 Filtrer les mots-clés recommandés pour IA

SELECT *
FROM knowledge_keyword
WHERE metadata.ai.recommended = true
ORDER BY metadata.ai.weight DESC;

➕ Ajouter un mot-clé

CREATE knowledge_keyword:PERMISSIONS SET
    identity.code = "PERMISSIONS",
    metadata.is_active = true,
    metadata.ai = {
        weight: 0.8,
        recommended: true
    };

🧵 Résumé

La table knowledge_keyword :

centralise et normalise tous les mots-clés,

améliore la recherche full-text et les filtres,

sert de base sémantique pour l’IA,

permet une gouvernance globale des mots-clés.

Elle garantit une cohérence sur toute la base de connaissances Lyxal.
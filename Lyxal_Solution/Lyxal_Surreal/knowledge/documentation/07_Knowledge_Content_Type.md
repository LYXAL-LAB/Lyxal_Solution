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

## 🧪 Exemples

### ✅ Récupérer tous les types de contenus pour UI

```sql
SELECT identity.code, identity.label_key, metadata.display_order
FROM knowledge_content_type
WHERE metadata.is_active = true
ORDER BY metadata.display_order;

🤖 Récupérer uniquement les types recommandés pour IA

SELECT *
FROM knowledge_content_type
WHERE metadata.ai.priority >= 4
ORDER BY metadata.ai.weight DESC;

➕ Ajouter un nouveau type personnalisé

CREATE knowledge_content_type:VIDEO_TUTORIAL SET
    identity.code = "VIDEO_TUTORIAL",
    metadata.is_active = true,
    metadata.ai = {
        priority: 3,
        weight: 0.6,
        level: { level: 2, label: "INTERMEDIATE" },
        is_structured: false
    };

🧵 Résumé

La table knowledge_content_type :

rend les types de contenus dynamiques et extensibles,

fournit un cadre pour l’optimisation IA + UX,

permet à Lyxal de faire évoluer son Knowledge System sans modifier le schéma.

Elle est essentielle pour transformer un simple référentiel en un système d’apprentissage intelligent.
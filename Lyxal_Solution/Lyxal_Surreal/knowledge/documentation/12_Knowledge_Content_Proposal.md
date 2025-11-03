# 📝 Table : `knowledge_content_proposal`

## 🎯 Objectif

La table `knowledge_content_proposal` permet de stocker les propositions de contenus générées automatiquement par l'IA pour enrichir le système de connaissance. Ces propositions sont basées sur les gaps détectés et nécessitent une validation humaine avant d'être transformées en contenus réels.

**Fondation pour v3 – Self-Learning** : Cette table permet au système de proposer automatiquement de nouveaux contenus basés sur les lacunes identifiées, facilitant l'enrichissement continu avec validation humaine.

---

## 🧱 Structure

| Bloc | Description |
|------|-------------|
| `gap`, `topic`, `content_type` | Références vers le gap source, topic cible, et type de contenu |
| `identity.*` | Identité de la proposition (title_key, slug, description_key) |
| `content.*` | Contenu proposé (structure U3-FLEX : text, code, examples, prompt, json) |
| `generation.*` | Informations sur la génération automatique (méthode, modèle, confiance) |
| `review.*` | État de révision et validation (status, dates, notes) |
| `metadata.*` | Métadonnées (priorité, qualité, version, active) |

---

## 🔗 Relations

| Table liée | Type | Description |
|------------|------|-------------|
| `knowledge_gap` | N → 1 | Gap à l'origine de la proposition (optionnel, SET NULL) |
| `knowledge_topic` | N → 1 | Topic auquel la proposition est rattachée (CASCADE) |
| `knowledge_content_type` | N → 1 | Type de contenu proposé (REJECT) |
| `knowledge_content` | N → 1 | Contenu réel créé si mergé (SET NULL) |
| `i18n_key` | N → 1 | Clés i18n pour les textes (REJECT/SET NULL) |

**Comportements** :
- `ON DELETE CASCADE` pour `topic` - Si le topic est supprimé, la proposition est supprimée
- `ON DELETE SET NULL` pour `gap` - Si le gap est supprimé, la proposition reste mais perd la référence
- `ON DELETE REJECT` pour `content_type` - Empêche la suppression du type si des propositions l'utilisent

---

## 🧩 Champs principaux

### 🔗 Références contextuelles

#### `gap`
- **Type** : `option<record<knowledge_gap>>`
- **Rôle** : Gap détecté à l'origine de cette proposition (optionnel)

#### `topic`
- **Type** : `record<knowledge_topic>` (REQUIRED)
- **Rôle** : Topic auquel cette proposition de contenu est rattachée

#### `content_type`
- **Type** : `record<knowledge_content_type>` (REQUIRED)
- **Rôle** : Type de contenu proposé (ex: SYNTAX, RULE, EXAMPLE_CORRECT)

---

### 📝 `identity` - Identité de la proposition

#### `identity.title_key`
- **Type** : `record<i18n_key>` (REQUIRED)
- **Rôle** : Clé i18n pour le titre de la proposition

#### `identity.slug`
- **Type** : `string` (REQUIRED, UNIQUE)
- **Rôle** : Slug unique pour identifier la proposition

#### `identity.description_key`
- **Type** : `option<record<i18n_key>>`
- **Rôle** : Clé i18n pour la description de la proposition

---

### 📄 `content` - Contenu proposé (Structure U3-FLEX)

La structure `content` suit le même format que `knowledge_content`, permettant de stocker :
- **`text_key`** : Contenu textuel (i18n)
- **`code[*]`** : Array de blocs de code avec `language`, `code`, `description_key`
- **`examples.correct[*]`** : Exemples corrects proposés
- **`examples.incorrect[*]`** : Exemples incorrects proposés
- **`prompt`** : Prompt proposé pour utilisation IA
- **`json`** : Données JSON proposées

---

### 🤖 `generation` - Informations de génération

#### `generation.method`
- **Type** : `string`
- **Valeurs possibles** : `"automatic"`, `"manual"`, `"ai_assisted"`
- **Défaut** : `"automatic"`
- **Rôle** : Méthode de génération de la proposition

#### `generation.model`
- **Type** : `option<string>`
- **Rôle** : Modèle IA utilisé pour générer la proposition (ex: "gpt-4", "claude-3")

#### `generation.generated_at`
- **Type** : `datetime`
- **Défaut** : `time::now()`
- **Rôle** : Date et heure de génération

#### `generation.confidence`
- **Type** : `number`
- **Contrainte** : 0 ≤ `confidence` ≤ 1, défaut : `0.5`
- **Rôle** : Niveau de confiance de la génération (0 = faible, 1 = élevé)

#### `generation.source_context`
- **Type** : `option<string>`
- **Rôle** : Contexte source utilisé pour la génération (ex: description du gap, documentation, etc.)

---

### ✅ `review` - État de révision

#### `review.status`
- **Type** : `string`
- **Valeurs possibles** :
  - `"draft"` : Brouillon initial (défaut)
  - `"pending_review"` : En attente de révision humaine
  - `"approved"` : Approuvé mais pas encore mergé
  - `"rejected"` : Rejeté
  - `"merged"` : Fusionné dans `knowledge_content`
- **Défaut** : `"draft"`
- **Rôle** : Statut de révision de la proposition

#### `review.reviewed_at`
- **Type** : `option<datetime>`
- **Rôle** : Date et heure de révision

#### `review.reviewed_by`
- **Type** : `option<string>`
- **Rôle** : Identifiant de la personne/IA qui a révisé

#### `review.review_notes`
- **Type** : `option<string>`
- **Rôle** : Notes de révision (commentaires, corrections, etc.)

#### `review.rejection_reason`
- **Type** : `option<string>`
- **Rôle** : Raison du rejet si `status = "rejected"`

#### `review.merged_content`
- **Type** : `option<record<knowledge_content>>`
- **Rôle** : Référence vers le contenu créé si `status = "merged"`

---

### ⚙️ `metadata` - Métadonnées

#### `metadata.priority`
- **Type** : `int`
- **Défaut** : `0`
- **Rôle** : Priorité de traitement (0 = normale, plus élevé = plus prioritaire)

#### `metadata.quality_score`
- **Type** : `number`
- **Contrainte** : 0 ≤ `quality_score` ≤ 1, défaut : `0.5`
- **Rôle** : Score de qualité estimé de la proposition

#### `metadata.version_label`
- **Type** : `option<string>`
- **Rôle** : Label de version si applicable (ex: "v1.0", "v2.1")

#### `metadata.is_active`
- **Type** : `bool`
- **Défaut** : `true`
- **Rôle** : La proposition est active (peut être désactivée sans suppression)

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_proposal_gap` | `gap` | Normal | Recherche par gap source |
| `idx_proposal_topic` | `topic` | Normal | Recherche par topic |
| `idx_proposal_content_type` | `content_type` | Normal | Filtrage par type |
| `idx_proposal_status` | `review.status` | Normal | Filtrage par statut |
| `idx_proposal_active` | `metadata.is_active` | Normal | Filtrage des actives |
| `idx_proposal_priority` | `metadata.priority` | Normal | Tri par priorité |
| `idx_proposal_slug` | `identity.slug` | UNIQUE | Unicité du slug |
| `idx_proposal_pending` | `review.status, metadata.priority` | Composite | Requêtes optimisées pour propositions en attente |

---

## 📝 Exemples d'utilisation

### ✅ Créer une proposition via fonction

```surql
-- Créer une proposition basée sur un gap
SELECT * FROM fn::knowledge_enrich_propose_content(
    knowledge_gap:gap_xyz,
    "SYNTAX",
    "automatic",
    "gpt-4",
    0.8,
    5
);
```

### ✅ Mettre à jour une proposition (génération du contenu complet)

```surql
UPDATE knowledge_content_proposal:proposal_xyz SET
    content.text_key = i18n_key:proposal_text_xyz,
    content.code = [
        {
            language: "surql",
            code: "DEFINE TABLE example SET name = 'test';",
            description_key: i18n_key:code_desc_xyz
        }
    ],
    review.status = "pending_review";
```

### ✅ Approuver une proposition et la transformer en contenu réel

```surql
SELECT * FROM fn::knowledge_enrich_approve_proposal(
    knowledge_content_proposal:proposal_xyz,
    "user_expert",
    "Proposition approuvée après révision",
    0.85
);
```

### ✅ Récupérer les propositions en attente de révision

```surql
SELECT 
    id,
    identity.slug,
    topic->identity.code AS topic_code,
    content_type->identity.code AS content_type_code,
    generation.confidence,
    metadata.priority,
    review.review_notes
FROM knowledge_content_proposal
WHERE review.status = "pending_review"
    AND metadata.is_active = true
ORDER BY metadata.priority DESC, generation.confidence DESC;
```

### ✅ Traiter automatiquement les gaps critiques

```surql
SELECT * FROM fn::knowledge_enrich_process_gaps(
    "critical",
    4,
    ["SYNTAX", "RULE", "EXAMPLE_CORRECT"],
    "automatic",
    "gpt-4"
);
```

---

## 🎯 Cas d'Usage

### Pour les humains

- **Réviser les propositions** : Voir les contenus proposés automatiquement et les valider/rejeter
- **Corriger et améliorer** : Modifier les propositions avant approbation
- **Suivre le workflow** : Visualiser l'état des propositions (draft → review → merged)

### Pour les IA/Agents IA

- **Générer automatiquement** : Créer des propositions basées sur les gaps détectés
- **Remplir le contenu** : Compléter les champs de la proposition (text, code, examples)
- **Soumettre pour révision** : Passer les propositions à `pending_review`

### Pour le système

- **Enrichissement continu** : Proposer automatiquement de nouveaux contenus
- **Gestion du workflow** : Orchestrer le cycle draft → review → merged
- **Traçabilité** : Lier les propositions aux gaps et aux contenus finaux

---

## 🔄 Cycle de vie d'une proposition

```
1. Détection de gap
   ↓ (automatique)
2. Création de proposition
   ↓ (fn::enrich::propose_content())
   status: "draft"
3. Génération du contenu complet
   ↓ (IA externe ou manuel)
   Remplissage des champs content.*
4. Soumission pour révision
   ↓ (mise à jour manuelle ou automatique)
   status: "pending_review"
5. Révision humaine
   ↓ (approuver ou rejeter)
   status: "approved" ou "rejected"
6. Merging (si approuvé)
   ↓ (fn::enrich::approve_proposal())
   status: "merged"
   Création du contenu réel dans knowledge_content
```

---

## 📚 Références

- **Fonctions d'enrichissement** : `function/enrichment/README.md`
- **Table gaps** : `11_Knowledge_Gap.md`
- **Table content** : `06_Knowledge_Content.md`
- **Schéma complet** : `SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


# 🧬 Modèle de Données – Knowledge System

## 🎯 Objectif

Ce document présente **la vision globale du modèle de données** du système de connaissance Lyxal.  
Il illustre comment les différentes tables interagissent pour former une base de connaissance structurée, intelligente, et exploitable par l'IA et l'humain.

---

## 🧱 Les 9 Tables Principales du Knowledge System

Le système repose sur 9 tables principales :

| Composant | Table | Type | Rôle |
|-----------|-------|------|------|
| Domaine | `knowledge_domain` | NORMAL | Grande catégorie de connaissance |
| Catégorie | `knowledge_category` | NORMAL | Organisation thématique des topics |
| Sous-catégorie | `knowledge_sub_category` | NORMAL | Affinement de l'organisation |
| Topic | `knowledge_topic` | NORMAL | Sujet de connaissance (ex: DEFINE FIELD) |
| Mot-clé | `knowledge_keyword` | NORMAL | Référentiel centralisé des mots-clés |
| Type de contenu | `knowledge_content_type` | NORMAL | Catégorisation dynamique du contenu |
| Contenu | `knowledge_content` | NORMAL | Unité de connaissance (U3-FLEX) |
| Relation domain-keyword | `knowledge_domain_keyword` | RELATION | Liens domaines ↔ keywords |
| Relation topic-keyword | `knowledge_topic_keyword` | RELATION | Liens topics ↔ keywords |

---

## 🌐 Diagramme des Relations

```plaintext
┌─────────────────────┐
│ knowledge_domain     │
│ (Niveau 1)          │
└──────────┬───────────┘
           │ 1─∞
           │
           ▼
┌─────────────────────┐      ┌─────────────────────┐
│ knowledge_category   │      │ knowledge_sub_cat   │
│ (Niveau 2)          │ 1─∞  │ (Niveau 2.5)        │
└──────────┬───────────┘◄─────┘                      │
           │                                          │
           │ 1─∞                                      │
           ▼                                          │
┌─────────────────────┐                              │
│ knowledge_topic      │◄─────────────────────────────┘
│ (Niveau 3)          │ 1─∞
└──────────┬───────────┘
           │
           │ 1─∞
           ▼
┌─────────────────────┐      ┌─────────────────────┐
│ knowledge_content    │      │knowledge_content_type│
│ (Niveau 4)          │───────► (Référentiel)       │
└─────────────────────┘ N→1  └─────────────────────┘

        Mots-Clés (Keywords)
        ┌─────────────────────────────────────────┐
        │             knowledge_keyword             │
        │         (Référentiel centralisé)         │
        └─────────────────────────────────────────┘
                  ▲              ▲
                  │              │
         ∞─∞      │              │      ∞─∞
                  │              │
    ┌─────────────┘              └─────────────┐
    │                                            │
┌───┴────────────────────┐   ┌─────────────────┴───┐
│knowledge_domain_keyword│   │knowledge_topic_keyword│
│  (RELATION)            │   │  (RELATION)            │
└────────────────────────┘   └───────────────────────┘
```

---

## 📋 Structure Complète des Tables

### 1. `knowledge_domain` (Niveau 1)

**Rôle** : Grandes catégories de connaissance

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE | Code unique (ex: `SURREAL_DB`) |
| `identity.slug` | `string` | UNIQUE | Slug pour URL (ex: `surreal-db`) |
| `identity.label_key` | `record<i18n_key>` | REQUIRED | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED | Description traduisible |
| `identity.ai_context_key` | `option<record<i18n_key>>` | OPTIONAL | Contexte pour IA |
| `ui.icon` | `option<record<icon>>` | OPTIONAL | Icône du domaine |
| `tags` | `option<array<record<tag>>>` | OPTIONAL | Tags structurés |
| `metadata.version_label` | `string` | DEFAULT "1.0.0" | Version fonctionnelle |
| `metadata.is_active` | `bool` | DEFAULT true | Domaine actif |
| `metadata.display_order` | `int` | DEFAULT 0 | Ordre d'affichage |

**Index** :
- `idx_domain_code` UNIQUE sur `identity.code`
- `idx_domain_slug` UNIQUE sur `identity.slug`
- `idx_domain_active` sur `metadata.is_active`

---

### 2. `knowledge_category` (Niveau 2)

**Rôle** : Organisation thématique des topics

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE | Code unique (ex: `DATA_DEFINITION`) |
| `identity.slug` | `string` | UNIQUE | Slug pour URL |
| `identity.label_key` | `record<i18n_key>` | REQUIRED | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED | Description traduisible |
| `metadata.version_label` | `option<string>` | OPTIONAL | Version fonctionnelle |
| `metadata.is_active` | `bool` | DEFAULT true | Catégorie active |
| `metadata.display_order` | `option<number>` | OPTIONAL | Ordre d'affichage |

**Index** :
- `idx_category_code` UNIQUE sur `identity.code`
- `idx_category_slug` UNIQUE sur `identity.slug`
- `idx_category_active` sur `metadata.is_active`

---

### 3. `knowledge_sub_category` (Niveau 2.5)

**Rôle** : Affinement de l'organisation (optionnel)

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `category` | `record<knowledge_category>` | REQUIRED, CASCADE | Catégorie parente |
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE | Code unique |
| `identity.slug` | `string` | UNIQUE | Slug pour URL |
| `identity.label_key` | `record<i18n_key>` | REQUIRED | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED | Description traduisible |
| `metadata.version_label` | `option<string>` | OPTIONAL | Version fonctionnelle |
| `metadata.is_active` | `bool` | DEFAULT true | Sous-catégorie active |
| `metadata.display_order` | `option<number>` | OPTIONAL | Ordre d'affichage |

**Index** :
- `idx_sub_category_code` UNIQUE sur `identity.code`
- `idx_sub_category_slug` UNIQUE sur `identity.slug`
- `idx_sub_category_category` sur `category`
- `idx_sub_category_active` sur `metadata.is_active`

---

### 4. `knowledge_topic` (Niveau 3)

**Rôle** : Sujet précis de connaissance

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `domain` | `record<knowledge_domain>` | REQUIRED, REJECT | Domaine parent |
| `category` | `record<knowledge_category>` | REQUIRED, REJECT | Catégorie |
| `sub_category` | `option<record<knowledge_sub_category>>` | OPTIONAL, REJECT | Sous-catégorie |
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE | Code unique (ex: `DEFINE_FIELD`) |
| `identity.slug` | `string` | UNIQUE | Slug pour URL |
| `identity.label_key` | `record<i18n_key>` | REQUIRED | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED | Description traduisible |
| `identity.ai_context_key` | `option<record<i18n_key>>` | OPTIONAL | Contexte pour IA |
| `tags` | `option<array<record<tag>>>` | OPTIONAL | Tags structurés |
| `metadata.version_label` | `string` | DEFAULT "1.0.0" | Version fonctionnelle |
| `metadata.display_order` | `int` | DEFAULT 0 | Ordre d'affichage |
| `metadata.is_active` | `bool` | DEFAULT true | Topic actif |

**Index** :
- `idx_topic_code` UNIQUE sur `identity.code`
- `idx_topic_slug` UNIQUE sur `identity.slug`
- `idx_topic_domain` sur `domain`
- `idx_topic_category` sur `category`
- `idx_topic_active` sur `metadata.is_active`
- `idx_topic_domain_category` COMPOSITE sur `domain, category`

---

### 5. `knowledge_keyword` (Référentiel)

**Rôle** : Référentiel centralisé des mots-clés

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `identity.value` | `string` | UNIQUE, lowercase, max 100 | Valeur du mot-clé |
| `identity.slug` | `string` | UNIQUE | Slug du mot-clé |
| `metadata.is_active` | `bool` | DEFAULT true | Mot-clé actif |
| `metadata.usage_count` | `int` | DEFAULT 0 | Nombre d'utilisations |

**Index** :
- `idx_keyword_value` UNIQUE sur `identity.value`
- `idx_keyword_slug` UNIQUE sur `identity.slug`
- `idx_keyword_search` SEARCH ANALYZER sur `identity.value`
- `idx_keyword_active` sur `metadata.is_active`

---

### 6. `knowledge_content_type` (Référentiel)

**Rôle** : Types de contenus dynamiques

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE | Code unique (ex: `SYNTAX`) |
| `identity.label_key` | `record<i18n_key>` | REQUIRED | Nom traduisible |
| `identity.description_key` | `option<record<i18n_key>>` | OPTIONAL | Description traduisible |
| `metadata.is_active` | `bool` | DEFAULT true | Type actif |
| `metadata.display_order` | `int` | DEFAULT 0 | Ordre d'affichage |
| `metadata.version_label` | `string` | DEFAULT "1.0.0" | Version fonctionnelle |
| `metadata.ai.priority` | `int` | DEFAULT 3, 1-5 | Priorité IA |
| `metadata.ai.weight` | `number` | DEFAULT 0.5, 0-1 | Poids dans ranking |
| `metadata.ai.level.level` | `int` | DEFAULT 1, 1-5 | Niveau numérique |
| `metadata.ai.level.label` | `string` | DEFAULT "BEGINNER" | Label du niveau |
| `metadata.ai.context_length` | `int` | DEFAULT 500 | Taille recommandée (tokens) |
| `metadata.ai.is_structured` | `bool` | DEFAULT false | Contenu structuré |
| `metadata.ai.min_quality_score` | `number` | DEFAULT 0.5, 0-1 | Score minimal requis |
| `metadata.ai.use_cases` | `option<array<object>>` | OPTIONAL | Cas d'usage IA |

**Types standards** : `SYNTAX`, `RULE`, `EXAMPLE_CORRECT`, `EXAMPLE_INCORRECT`, `TIP`, `PATTERN`, `EXPLANATION`, `REFERENCE`

**Index** :
- `idx_content_type_code` UNIQUE sur `identity.code`
- `idx_content_type_active` sur `metadata.is_active`

---

### 7. `knowledge_content` (Niveau 4 - U3-FLEX)

**Rôle** : Unités de connaissance multi-formats

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `topic` | `record<knowledge_topic>` | REQUIRED, CASCADE | Topic parent |
| `identity.slug` | `string` | UNIQUE, min 3 chars | Slug unique |
| `identity.content_type` | `record<knowledge_content_type>` | REQUIRED, REJECT | Type de contenu |
| `identity.title_key` | `option<record<i18n_key>>` | OPTIONAL | Titre traduisible |
| `identity.description_key` | `option<record<i18n_key>>` | OPTIONAL | Description traduisible |
| `content.text_key` | `option<record<i18n_key>>` | OPTIONAL | Texte principal traduisible |
| `content.code` | `option<array<object>>` | OPTIONAL | Blocs de code multi-langage |
| `content.code.*.language` | `string` | REQUIRED si code | Langage (ex: "surql", "js") |
| `content.code.*.value` | `string` | REQUIRED si code | Code source |
| `content.code.*.explanation_key` | `option<record<i18n_key>>` | OPTIONAL | Explication traduisible |
| `content.prompt` | `option<string>` | OPTIONAL | Version prompt-ready pour IA |
| `content.json` | `option<object>` | OPTIONAL | Contenu JSON structuré |
| `content.context_key` | `option<record<i18n_key>>` | OPTIONAL | Contexte d'utilisation |
| `content.examples.correct` | `option<array<object>>` | OPTIONAL | Exemples corrects |
| `content.examples.correct.*.text_key` | `option<record<i18n_key>>` | OPTIONAL | Explication traduisible |
| `content.examples.correct.*.code` | `option<string>` | OPTIONAL | Code correct |
| `content.examples.incorrect` | `option<array<object>>` | OPTIONAL | Exemples incorrects |
| `content.examples.incorrect.*.text_key` | `option<record<i18n_key>>` | OPTIONAL | Explication traduisible |
| `content.examples.incorrect.*.code` | `option<string>` | OPTIONAL | Code incorrect |
| `content.media` | `option<array<record<url>>>` | OPTIONAL | Médias associés |
| `tags` | `option<array<record<tag>>>` | OPTIONAL | Tags structurés |
| `metadata.priority` | `int` | DEFAULT 0 | Priorité d'affichage |
| `metadata.is_active` | `bool` | DEFAULT true | Contenu actif |
| `metadata.version_label` | `string` | DEFAULT "1.0.0" | Version fonctionnelle |

**Index** :
- `idx_content_topic` sur `topic`
- `idx_content_type` sur `identity.content_type`
- `idx_content_slug` UNIQUE sur `identity.slug`
- `idx_content_active` sur `metadata.is_active`

---

### 8. `knowledge_domain_keyword` (RELATION)

**Rôle** : Relations domaines ↔ keywords

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `in` | `record<knowledge_domain>` | REQUIRED, CASCADE | Domaine |
| `out` | `record<knowledge_keyword>` | REQUIRED, CASCADE | Mot-clé |

**Index** :
- `idx_domain_keyword_text` SEARCH ANALYZER sur `out.identity.value`
- `idx_domain_keyword_domain` sur `in`
- `idx_domain_keyword_unique` UNIQUE sur `in, out`

---

### 9. `knowledge_topic_keyword` (RELATION)

**Rôle** : Relations topics ↔ keywords

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `in` | `record<knowledge_topic>` | REQUIRED, CASCADE | Topic |
| `out` | `record<knowledge_keyword>` | REQUIRED, CASCADE | Mot-clé |

**Index** :
- `idx_keyword_text` SEARCH ANALYZER sur `out.identity.value`
- `idx_keyword_topic` sur `in`
- `idx_keyword_unique` UNIQUE sur `in, out`

---

## 🧠 Logique Conceptuelle

| Niveau | Élément | Question à laquelle il répond |
|--------|---------|-------------------------------|
| 1 | Domaine | "Dans quel univers de connaissance sommes-nous ?" |
| 2 | Catégorie | "Dans quelle thématique ?" |
| 2.5 | Sous-catégorie | "Affinement de la thématique ?" |
| 3 | Topic | "De quoi parle-t-on précisément ?" |
| 4 | Contenu | "Quelle information utile associons-nous à ce sujet ?" |
| Meta | Type | "De quelle nature est ce contenu ?" |
| Sémantique | Keywords | "Comment l'IA et l'utilisateur doivent trouver/relier cette info ?" |

---

## 🧩 Exemple Concret

### Cas d'usage : un agent IA doit aider à écrire un DEFINE FIELD.

| Table | Exemple |
|-------|---------|
| Domain | `SURREAL_DB` |
| Category | `DATA_DEFINITION` |
| Topic | `DEFINE_FIELD` |
| Content Types | `SYNTAX`, `RULE`, `EXAMPLE_CORRECT`, `EXAMPLE_INCORRECT`, `TIP` |
| Keywords | `field`, `assert`, `validation`, `type` |

### Processus IA :

1. Cherche le domaine → `SURREAL_DB`
2. Trouve le topic → `DEFINE_FIELD`
3. Récupère les contenus associés
4. Filtre par type selon le besoin (ex: examples only)
5. Utilise les keywords pour contextualisation / RAG

---

## 📊 Pourquoi ce modèle est optimal ?

| Critère | Résultat |
|---------|----------|
| Évolutivité | Ajout de sujets sans changer le schéma |
| IA Ready | Données structurées + sémantique + scoring |
| RAG efficace | Indexation par mots-clés + types + structure |
| UX-Friendly | Multi-niveaux lisibles pour l'humain |
| White Label | Extensible à d'autres connaissances que SurrealDB |
| Normalisation | Référentiel centralisé des keywords |
| Recherche | Full-text BM25 opérationnelle |

---

## 🔗 Relations et Contraintes

### Relations CASCADE (suppression automatique)

- `knowledge_sub_category.category` → Supprime si category supprimée
- `knowledge_content.topic` → Supprime si topic supprimé
- `knowledge_domain_keyword.in` → Supprime si domain supprimé
- `knowledge_topic_keyword.in` → Supprime si topic supprimé
- `knowledge_domain_keyword.out` → Supprime si keyword supprimé
- `knowledge_topic_keyword.out` → Supprime si keyword supprimé

### Relations REJECT (empêche suppression)

- `knowledge_topic.domain` → Empêche suppression si topics existent
- `knowledge_topic.category` → Empêche suppression si topics existent
- `knowledge_content.topic` → Empêche suppression si contents existent
- Toutes les références `i18n_key` → Empêche suppression si utilisées

### Relations UNSET (devient NULL)

- `knowledge_domain.ui.icon` → Devient NULL si icon supprimé

---

## 🚀 Scalabilité prévue

Cette architecture supporte nativement l'extension future :

- ✅ Ajout d'historiques et versioning natif SurrealDB
- ✅ Ajout d'un niveau "module" ou "collection" si besoin
- ✅ Ajout d'un graphe IA (embeddings & similarity search) si activé
- ✅ Ajout de métadonnées analytics (`usage_count`, `view_count`, etc.)

---

## 🧵 Résumé

Le Knowledge System repose sur un modèle :

- ✅ **Structuré** (Domain → Category → Topic → Content)
- ✅ **Sémantique** (Keywords + Types)
- ✅ **IA-optimisé** (Scoring, Priorités, Use Cases IA)
- ✅ **Multi-domaines** et multi-niveaux
- ✅ **Normalisé** (Référentiel centralisé keywords)
- ✅ **Recherche-full-text** (Index BM25 opérationnel)

Ce modèle transforme la base de connaissance Lyxal en un véritable cortex de savoir, utilisable par des humains, des IAs internes ou externes, et tous les modules de la suite.

---

## 📚 Références

- Documentation complète : Voir `00_INDEX.md`
- Guide de création : `17_Knowledge_Creation_Patterns.md`
- Schéma de référence : `SCHEMA_Knowledge_System.md` (à créer)

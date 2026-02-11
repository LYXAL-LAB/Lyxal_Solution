# 📋 Schéma de Référence – Knowledge System

## 🎯 Objectif

Ce document est **le schéma de référence unifié** du Knowledge System.  
Il liste toutes les tables, champs, types, contraintes, index et relations en un seul endroit pour référence rapide.

> 📚 **Pour comprendre le modèle conceptuel**, voir `10_Knowledge_Data_Model.md`  
> 📚 **Pour créer des données**, voir `17_Knowledge_Creation_Patterns.md`

---

## 📊 Vue d'Ensemble

| Table | Type | Rôle | Dépendances |
|-------|------|------|-------------|
| `knowledge_domain` | NORMAL | Domaines de connaissance (niveau 1) | `i18n_key`, `tag`, `icon` |
| `knowledge_category` | NORMAL | Catégories principales (niveau 2) | `i18n_key` |
| `knowledge_sub_category` | NORMAL | Sous-catégories (niveau 2.5) | `knowledge_category`, `i18n_key` |
| `knowledge_topic` | NORMAL | Sujets de connaissance (niveau 3) | `knowledge_domain`, `knowledge_category`, `tag`, `i18n_key` |
| `knowledge_keyword` | NORMAL | Référentiel centralisé des mots-clés | Aucune |
| `knowledge_content_type` | NORMAL | Types de contenus dynamiques | `i18n_key` |
| `knowledge_content` | NORMAL | Contenus de connaissance (niveau 4) | `knowledge_topic`, `knowledge_content_type`, `tag`, `url`, `i18n_key` |
| `knowledge_feedback` | NORMAL | Feedback sur les contenus (amélioration continue) | `knowledge_content` |
| `knowledge_gap` | NORMAL | Gaps détectés dans le système (détection de lacunes) | `knowledge_domain`, `knowledge_topic`, `knowledge_content` |
| `knowledge_content_proposal` | NORMAL | Propositions de contenus générées par IA | `knowledge_gap`, `knowledge_topic`, `knowledge_content_type` |
| `knowledge_dataset_export` | NORMAL | Tracking des exports de datasets d'entraînement | `knowledge_domain` |
| `knowledge_content_relation` | RELATION | Relations entre contenus (prerequisite, dependency, etc.) | `knowledge_content` |
| `knowledge_domain_keyword` | RELATION | Relations domaines ↔ keywords | `knowledge_domain`, `knowledge_keyword` |
| `knowledge_topic_keyword` | RELATION | Relations topics ↔ keywords | `knowledge_topic`, `knowledge_keyword` |

---

## 1. `knowledge_domain`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Domaines de connaissance universels (SurrealDB, Business, IA, etc.)

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE, NOT NULL | - | Code unique (ex: `SURREAL_DB`) |
| `identity.slug` | `string` | UNIQUE, NOT NULL | - | Slug pour URL (ex: `surreal-db`) |
| `identity.label_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Description traduisible |
| `identity.ai_context_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Contexte pour IA |
| `ui.icon` | `option<record<icon>>` | OPTIONAL, ON DELETE UNSET | - | Icône du domaine |
| `tags` | `option<array<record<tag>>>` | OPTIONAL | - | Tags structurés |
| `metadata.version_label` | `string` | DEFAULT | `"1.0.0"` | Version fonctionnelle |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Domaine actif |
| `metadata.display_order` | `int` | DEFAULT | `0` | Ordre d'affichage |

### Index

- `idx_domain_code` UNIQUE sur `identity.code`
- `idx_domain_slug` UNIQUE sur `identity.slug`
- `idx_domain_active` sur `metadata.is_active`

### Relations

- `knowledge_domain_keyword` (RELATION) → `knowledge_keyword` (∞─∞)

---

## 2. `knowledge_category`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Catégories principales pour organisation des topics

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE, NOT NULL | - | Code unique (ex: `DATA_DEFINITION`) |
| `identity.slug` | `string` | UNIQUE, NOT NULL | - | Slug pour URL |
| `identity.label_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Description traduisible |
| `metadata.version_label` | `option<string>` | OPTIONAL | - | Version fonctionnelle |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Catégorie active |
| `metadata.display_order` | `option<number>` | OPTIONAL | - | Ordre d'affichage |

### Index

- `idx_category_code` UNIQUE sur `identity.code`
- `idx_category_slug` UNIQUE sur `identity.slug`
- `idx_category_active` sur `metadata.is_active`

### Relations

- `knowledge_sub_category.category` → `knowledge_category` (1─∞, CASCADE)
- `knowledge_topic.category` → `knowledge_category` (1─∞, REJECT)

---

## 3. `knowledge_sub_category`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Sous-catégories optionnelles pour affinement

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `category` | `record<knowledge_category>` | REQUIRED, ON DELETE CASCADE | - | Catégorie parente |
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE, NOT NULL | - | Code unique |
| `identity.slug` | `string` | UNIQUE, NOT NULL | - | Slug pour URL |
| `identity.label_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Description traduisible |
| `metadata.version_label` | `option<string>` | OPTIONAL | - | Version fonctionnelle |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Sous-catégorie active |
| `metadata.display_order` | `option<number>` | OPTIONAL | - | Ordre d'affichage |

### Index

- `idx_sub_category_code` UNIQUE sur `identity.code`
- `idx_sub_category_slug` UNIQUE sur `identity.slug`
- `idx_sub_category_category` sur `category`
- `idx_sub_category_active` sur `metadata.is_active`

### Relations

- `knowledge_topic.sub_category` → `knowledge_sub_category` (1─∞, REJECT)

---

## 4. `knowledge_topic`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Sujets de connaissance rattachés à un domaine

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `domain` | `record<knowledge_domain>` | REQUIRED, ON DELETE REJECT | - | Domaine parent |
| `category` | `record<knowledge_category>` | REQUIRED, ON DELETE REJECT | - | Catégorie |
| `sub_category` | `option<record<knowledge_sub_category>>` | OPTIONAL, ON DELETE REJECT | - | Sous-catégorie |
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE, NOT NULL | - | Code unique (ex: `DEFINE_FIELD`) |
| `identity.slug` | `string` | UNIQUE, NOT NULL | - | Slug pour URL |
| `identity.label_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Nom traduisible |
| `identity.description_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Description traduisible |
| `identity.ai_context_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Contexte pour IA |
| `tags` | `option<array<record<tag>>>` | OPTIONAL | - | Tags structurés |
| `metadata.version_label` | `string` | DEFAULT | `"1.0.0"` | Version fonctionnelle |
| `metadata.display_order` | `int` | DEFAULT | `0` | Ordre d'affichage |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Topic actif |

### Index

- `idx_topic_code` UNIQUE sur `identity.code`
- `idx_topic_slug` UNIQUE sur `identity.slug`
- `idx_topic_domain` sur `domain`
- `idx_topic_category` sur `category`
- `idx_topic_active` sur `metadata.is_active`
- `idx_topic_domain_category` COMPOSITE sur `domain, category`

### Relations

- `knowledge_content.topic` → `knowledge_topic` (1─∞, CASCADE)
- `knowledge_topic_keyword` (RELATION) → `knowledge_keyword` (∞─∞)

---

## 5. `knowledge_keyword`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Référentiel centralisé des mots-clés

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `identity.value` | `string` | UNIQUE, lowercase, max 100, NOT NULL | - | Valeur du mot-clé |
| `identity.slug` | `string` | UNIQUE, NOT NULL | - | Slug du mot-clé |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Mot-clé actif |
| `metadata.usage_count` | `int` | DEFAULT | `0` | Nombre d'utilisations |

### Index

- `idx_keyword_value` UNIQUE sur `identity.value`
- `idx_keyword_slug` UNIQUE sur `identity.slug`
- `idx_keyword_search` SEARCH ANALYZER sur `identity.value` (full-text BM25)
- `idx_keyword_active` sur `metadata.is_active`

### Relations

- `knowledge_domain_keyword.out` → `knowledge_keyword` (∞─∞, CASCADE)
- `knowledge_topic_keyword.out` → `knowledge_keyword` (∞─∞, CASCADE)

---

## 6. `knowledge_content_type`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Référentiel dynamique des types de contenus

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `identity.code` | `string` | UNIQUE, UPPER_SNAKE_CASE, NOT NULL | - | Code unique (ex: `SYNTAX`) |
| `identity.label_key` | `record<i18n_key>` | REQUIRED, ON DELETE REJECT | - | Nom traduisible |
| `identity.description_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Description traduisible |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Type actif |
| `metadata.display_order` | `int` | DEFAULT | `0` | Ordre d'affichage |
| `metadata.version_label` | `string` | DEFAULT | `"1.0.0"` | Version fonctionnelle |
| `metadata.ai.priority` | `int` | DEFAULT, 1-5 | `3` | Priorité IA |
| `metadata.ai.weight` | `number` | DEFAULT, 0-1 | `0.5` | Poids dans ranking |
| `metadata.ai.level.level` | `int` | DEFAULT, 1-5 | `1` | Niveau numérique |
| `metadata.ai.level.label` | `string` | DEFAULT | `"BEGINNER"` | Label du niveau |
| `metadata.ai.context_length` | `int` | DEFAULT | `500` | Taille recommandée (tokens) |
| `metadata.ai.is_structured` | `bool` | DEFAULT | `false` | Contenu structuré |
| `metadata.ai.min_quality_score` | `number` | DEFAULT, 0-1 | `0.5` | Score minimal requis |
| `metadata.ai.use_cases` | `option<array<object>>` | OPTIONAL | - | Cas d'usage IA |

**Types standards** : `SYNTAX`, `RULE`, `EXAMPLE_CORRECT`, `EXAMPLE_INCORRECT`, `TIP`, `PATTERN`, `EXPLANATION`, `REFERENCE`

### Index

- `idx_content_type_code` UNIQUE sur `identity.code`
- `idx_content_type_active` sur `metadata.is_active`

### Relations

- `knowledge_content.identity.content_type` → `knowledge_content_type` (N→1, REJECT)

---

## 7. `knowledge_content`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Contenus de connaissance multi-formats (U3-FLEX)

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `topic` | `record<knowledge_topic>` | REQUIRED, ON DELETE CASCADE | - | Topic parent |
| `identity.slug` | `string` | UNIQUE, min 3 chars, NOT NULL | - | Slug unique |
| `identity.content_type` | `record<knowledge_content_type>` | REQUIRED, ON DELETE REJECT | - | Type de contenu |
| `identity.title_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Titre traduisible |
| `identity.description_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Description traduisible |
| `content.text_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Texte principal |
| `content.code` | `option<array<object>>` | OPTIONAL | - | Blocs de code multi-langage |
| `content.code.*.language` | `string` | REQUIRED si code | - | Langage (ex: "surql", "js") |
| `content.code.*.value` | `string` | REQUIRED si code | - | Code source |
| `content.code.*.explanation_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Explication |
| `content.prompt` | `option<string>` | OPTIONAL | - | Version prompt-ready pour IA |
| `content.json` | `option<object>` | OPTIONAL | - | Contenu JSON structuré |
| `content.context_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Contexte d'utilisation |
| `content.examples.correct` | `option<array<object>>` | OPTIONAL | - | Exemples corrects |
| `content.examples.correct.*.text_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Explication |
| `content.examples.correct.*.code` | `option<string>` | OPTIONAL | - | Code correct |
| `content.examples.incorrect` | `option<array<object>>` | OPTIONAL | - | Exemples incorrects |
| `content.examples.incorrect.*.text_key` | `option<record<i18n_key>>` | OPTIONAL, ON DELETE REJECT | - | Explication |
| `content.examples.incorrect.*.code` | `option<string>` | OPTIONAL | - | Code incorrect |
| `content.media` | `option<array<record<url>>>` | OPTIONAL | - | Médias associés |
| `content.references` | `option<array<record<knowledge_content>>>` | OPTIONAL | - | Références vers d'autres contenus liés |
| `tags` | `option<array<record<tag>>>` | OPTIONAL | - | Tags structurés |
| `metadata.priority` | `int` | DEFAULT | `0` | Priorité d'affichage |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Contenu actif |
| `metadata.version_label` | `string` | DEFAULT | `"1.0.0"` | Version fonctionnelle |
| `metadata.quality_score` | `number` | DEFAULT, 0-1 | `0.5` | Score de qualité (0 = faible, 1 = excellente). Utilisé par l'IA pour filtrer et prioriser |
| `metadata.analytics.view_count` | `int` | DEFAULT | `0` | Nombre total de consultations/vues (humain + IA) |
| `metadata.analytics.last_viewed` | `option<datetime>` | OPTIONAL | - | Date et heure de la dernière consultation |
| `metadata.analytics.ai_usage_count` | `int` | DEFAULT | `0` | Nombre d'utilisations spécifiques par des IA/agents IA |
| `metadata.training.included_in_training` | `bool` | DEFAULT | `false` | Ce contenu est inclus dans les datasets d'entraînement IA |
| `metadata.training.training_versions` | `array<string>` | DEFAULT | `[]` | Versions de datasets où ce contenu a été utilisé (ex: ["v1.0", "v1.1"]) |
| `metadata.training.training_weight` | `number` | DEFAULT, 0-2 | `1.0` | Poids d'entraînement (1.0 = normal, 2.0 = double poids, 0.5 = demi-poids) |
| `metadata.training.last_training_date` | `option<datetime>` | OPTIONAL | - | Date de la dernière utilisation dans un dataset d'entraînement |

> ⚠️ **Syntaxe arrays d'objets** : Utiliser le wildcard `*` pour définir les champs dans les arrays d'objets (voir `16_SurrealDB_Arrays_Objects_Syntax.md`)

### Index

- `idx_content_topic` sur `topic`
- `idx_content_type` sur `identity.content_type`
- `idx_content_slug` UNIQUE sur `identity.slug`
- `idx_content_active` sur `metadata.is_active`
- `idx_content_training` sur `metadata.training.included_in_training`

---

## 8. `knowledge_feedback`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Feedback sur les contenus de connaissance pour amélioration continue

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `content` | `record<knowledge_content>` | REQUIRED, ON DELETE CASCADE | - | Contenu concerné |
| `feedback_type` | `string` | REQUIRED, IN ["positive", "negative", "suggestion", "correction"] | - | Type de feedback |
| `score` | `number` | DEFAULT, 0-1 | `0.5` | Score de qualité perçu |
| `comment` | `option<string>` | OPTIONAL | - | Commentaire libre |
| `source.type` | `string` | DEFAULT, IN ["human", "ai", "system"] | `"human"` | Type de source |
| `source.identifier` | `option<string>` | OPTIONAL | - | Identifiant de la source |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Feedback actif |
| `metadata.is_resolved` | `bool` | DEFAULT | `false` | Feedback résolu |
| `metadata.resolved_at` | `option<datetime>` | OPTIONAL | - | Date de résolution |
| `metadata.created_at` | `datetime` | DEFAULT | `time::now()` | Date de création |
| `metadata.impact_score` | `number` | DEFAULT, 0-1 | `0.5` | Score d'impact |

### Index

- `idx_feedback_content` sur `content`
- `idx_feedback_type` sur `feedback_type`
- `idx_feedback_active` sur `metadata.is_active`
- `idx_feedback_resolved` sur `metadata.is_resolved`
- `idx_feedback_created` sur `metadata.created_at`
- `idx_feedback_content_type` COMPOSITE sur `content, feedback_type`

### Relations

- `knowledge_feedback.content` → `knowledge_content` (N→1, CASCADE)

---

## 9. `knowledge_gap`

**Type** : `NORMAL SCHEMAFULL`  
**Rôle** : Gaps détectés dans le système de connaissance pour amélioration continue

### Champs

| Champ | Type | Contrainte | Default | Description |
|-------|------|------------|---------|-------------|
| `gap_type` | `string` | REQUIRED, IN [6 types] | - | Type de gap détecté |
| `severity` | `string` | DEFAULT, IN ["low", "medium", "high", "critical"] | `"medium"` | Sévérité du gap |
| `domain` | `option<record<knowledge_domain>>` | OPTIONAL, ON DELETE CASCADE | - | Domaine concerné |
| `topic` | `option<record<knowledge_topic>>` | OPTIONAL, ON DELETE CASCADE | - | Topic concerné |
| `content` | `option<record<knowledge_content>>` | OPTIONAL, ON DELETE CASCADE | - | Contenu concerné |
| `detection.method` | `string` | DEFAULT, IN [4 méthodes] | `"automatic"` | Méthode de détection |
| `detection.source` | `option<string>` | OPTIONAL | - | Source de détection |
| `detection.detected_at` | `datetime` | DEFAULT | `time::now()` | Date de détection |
| `detection.confidence` | `number` | DEFAULT, 0-1 | `0.5` | Niveau de confiance |
| `description` | `option<string>` | OPTIONAL | - | Description du gap |
| `expected_content` | `option<string>` | OPTIONAL | - | Contenu attendu |
| `suggested_keywords` | `option<array<string>>` | OPTIONAL | - | Mots-clés suggérés |
| `resolution.status` | `string` | DEFAULT, IN [5 statuts] | `"pending"` | Statut de résolution |
| `resolution.resolved_at` | `option<datetime>` | OPTIONAL | - | Date de résolution |
| `resolution.resolved_by` | `option<string>` | OPTIONAL | - | Qui a résolu |
| `resolution.resolution_content` | `option<record<knowledge_content>>` | OPTIONAL, ON DELETE SET NULL | - | Contenu créé pour résoudre |
| `resolution.notes` | `option<string>` | OPTIONAL | - | Notes sur la résolution |
| `metadata.priority` | `int` | DEFAULT | `0` | Priorité de traitement |
| `metadata.impact_score` | `number` | DEFAULT, 0-1 | `0.5` | Score d'impact |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Gap actif |
| `metadata.recurrence_count` | `int` | DEFAULT | `1` | Nombre de détections |

### Index

- `idx_gap_type` sur `gap_type`
- `idx_gap_severity` sur `severity`
- `idx_gap_status` sur `resolution.status`
- `idx_gap_domain` sur `domain`
- `idx_gap_topic` sur `topic`
- `idx_gap_active` sur `metadata.is_active`
- `idx_gap_priority` sur `metadata.priority`
- `idx_gap_detected` sur `detection.detected_at`
- `idx_gap_pending_severity` COMPOSITE sur `resolution.status, severity, metadata.priority`

### Relations

- `knowledge_gap.domain` → `knowledge_domain` (N→1, CASCADE)
- `knowledge_gap.topic` → `knowledge_topic` (N→1, CASCADE)
- `knowledge_gap.content` → `knowledge_content` (N→1, CASCADE)
- `knowledge_gap.resolution.resolution_content` → `knowledge_content` (N→1, SET NULL)

---

## 10. `knowledge_domain_keyword` (RELATION)

**Type** : `RELATION`  
**Rôle** : Relations domaines ↔ keywords

### Champs

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `in` | `record<knowledge_domain>` | REQUIRED, ON DELETE CASCADE | Domaine |
| `out` | `record<knowledge_keyword>` | REQUIRED, ON DELETE CASCADE | Mot-clé |

### Index

- `idx_domain_keyword_text` SEARCH ANALYZER sur `out.identity.value` (full-text BM25)
- `idx_domain_keyword_domain` sur `in`
- `idx_domain_keyword_unique` UNIQUE sur `in, out`

---

## 11. `knowledge_topic_keyword` (RELATION)

**Type** : `RELATION`  
**Rôle** : Relations topics ↔ keywords

### Champs

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `in` | `record<knowledge_topic>` | REQUIRED, ON DELETE CASCADE | Topic |
| `out` | `record<knowledge_keyword>` | REQUIRED, ON DELETE CASCADE | Mot-clé |

### Index

- `idx_keyword_text` SEARCH ANALYZER sur `out.identity.value` (full-text BM25)
- `idx_keyword_topic` sur `in`
- `idx_keyword_unique` UNIQUE sur `in, out`

---

## 12. `knowledge_content_relation` (RELATION)

**Type** : `RELATION`  
**Rôle** : Relations structurées entre contenus de connaissance

### Champs

| Champ | Type | Contrainte | Description |
|-------|------|------------|-------------|
| `relation_type` | `string` | REQUIRED, IN ["prerequisite", "dependency", "reference", "related"] | Type de relation |
| `description` | `option<string>` | OPTIONAL | Description de la relation |
| `priority` | `int` | DEFAULT | `0` | Ordre de priorité pour navigation |
| `metadata.is_active` | `bool` | DEFAULT | `true` | Relation active |
| `metadata.created_at` | `datetime` | DEFAULT | `time::now()` | Date de création |
| `metadata.created_by` | `option<string>` | OPTIONAL | Identifiant créateur |

### Index

- `idx_relation_type` sur `relation_type`
- `idx_relation_active` sur `metadata.is_active`
- `idx_relation_in_out` COMPOSITE sur `in, out`
- `idx_relation_priority` sur `priority`

> 📚 **Documentation complète** : Voir `14_Knowledge_Content_Relation.md`

---

## 🔗 Relations et Contraintes

### Relations CASCADE (suppression automatique)

- `knowledge_sub_category.category` → Supprime si category supprimée
- `knowledge_content.topic` → Supprime si topic supprimé
- `knowledge_feedback.content` → Supprime si content supprimé
- `knowledge_gap.domain` → Supprime si domain supprimé
- `knowledge_gap.topic` → Supprime si topic supprimé
- `knowledge_gap.content` → Supprime si content supprimé
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

## 📊 Diagramme des Relations

```plaintext
knowledge_domain (1)
    ├─→ knowledge_topic (∞) [REJECT]
    │       ├─→ knowledge_content (∞) [CASCADE]
    │       │       ├─→ knowledge_feedback (∞) [CASCADE]
    │       │       └─→ knowledge_gap (∞) [CASCADE] (pour gaps spécifiques au contenu)
    │       └─→ knowledge_topic_keyword (∞) [CASCADE]
    │               └─→ knowledge_gap (∞) [CASCADE] (pour gaps spécifiques au topic)
    │
    └─→ knowledge_domain_keyword (∞) [CASCADE]
            └─→ knowledge_keyword (1)

knowledge_category (1)
    ├─→ knowledge_sub_category (∞) [CASCADE]
    │       └─→ knowledge_topic (∞) [REJECT]
    │
    └─→ knowledge_topic (∞) [REJECT]

knowledge_content_type (1)
    └─→ knowledge_content (∞) [REJECT]

knowledge_keyword (1)
    ├─→ knowledge_domain_keyword (∞) [CASCADE]
    └─→ knowledge_topic_keyword (∞) [CASCADE]

knowledge_content (1)
    ├─→ knowledge_content_relation (∞) [via RELATE]
    └─→ knowledge_content (∞) [via content.references]
```

---

## 🔍 Index de Recherche

### Index UNIQUE

- `identity.code` sur toutes les tables principales
- `identity.slug` sur toutes les tables principales
- `identity.value` sur `knowledge_keyword`
- Relations : `(in, out)` sur tables relationnelles

### Index FULLTEXT (SEARCH ANALYZER)

- `knowledge_keyword.identity.value` → Recherche BM25
- `knowledge_domain_keyword.out.identity.value` → Recherche BM25
- `knowledge_topic_keyword.out.identity.value` → Recherche BM25

### Index de Filtrage

- `metadata.is_active` sur toutes les tables
- `domain`, `category`, `topic` sur tables dépendantes
- `identity.content_type` sur `knowledge_content`

---

## 📚 Références

- **Modèle conceptuel** : `10_Knowledge_Data_Model.md`
- **Guide de création** : `17_Knowledge_Creation_Patterns.md`
- **Syntaxe arrays** : `16_SurrealDB_Arrays_Objects_Syntax.md`
- **Documentation complète** : Voir `00_INDEX.md`

---

**Dernière mise à jour** : 2025  
**Version schéma** : 1.0.0


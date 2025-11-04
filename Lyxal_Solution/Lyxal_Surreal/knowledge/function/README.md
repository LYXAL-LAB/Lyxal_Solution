-- ============================================================================
-- Fichier : knowledge/function/README.md
-- Module : knowledge
-- Description : Documentation des fonctions API pour requêtes optimisées IA
-- ============================================================================

# 🤖 API de Requête Optimisée IA – Knowledge System

Ce dossier contient les **fonctions SurrealDB** qui permettent aux IA d'interroger le Knowledge System de manière optimisée, sans écrire de requêtes SQL complexes.

## 🎯 Objectif

Fournir une interface simplifiée pour les IA qui :
- ✅ Encapsule les requêtes complexes dans des fonctions simples
- ✅ Retourne des données formatées pour prompts IA
- ✅ Filtre automatiquement par qualité (`quality_score >= 0.7`)
- ✅ Priorise les contenus selon métadonnées IA (`priority`, `weight`, `level`)
- ✅ Structure les résultats pour usage direct par l'IA

## 📋 Fonctions Disponibles

### 1. `fn::knowledge_get_topic_bundle_for_ai()`

Récupère un bundle complet de connaissances pour un topic, optimisé pour l'IA.

**Paramètres** :
- `$topic_code` : Code du topic (ex: `"DEFINE_FIELD"`)
- `$intent` : Intention IA (`"GENERATE_CODE"`, `"TEACH"`, `"VALIDATE"`, `"QUICK_HELP"`)
- `$min_quality_score` : Score minimum (défaut: `0.7`)
- `$max_contents` : Nombre max de contenus (défaut: `10`)
- `$level` : Niveau (`"BEGINNER"`, `"INTERMEDIATE"`, `"ADVANCED"`, `"EXPERT"`) - optionnel

**Retourne** : Bundle structuré avec topic, contenus filtrés et formatés, métadonnées, format prompt

**Exemple** :
```sql
SELECT * FROM fn::knowledge_get_topic_bundle_for_ai(
    "DEFINE_FIELD",
    "GENERATE_CODE",
    0.7,
    10,
    "BEGINNER"
);
```

---

### 2. `fn::knowledge_search_keywords_for_ai()`

Recherche par mots-clés avec scoring BM25, optimisée pour IA.

**Paramètres** :
- `$keywords` : Array de mots-clés (ex: `["database", "field", "validation"]`)
- `$domain_code` : Code du domaine pour filtrer (optionnel, ex: `"SURREAL_DB"`)
- `$limit` : Nombre de résultats (défaut: `10`)

**Retourne** : Topics pertinents avec scores, meilleur contenu par topic, métadonnées

**Exemple** :
```sql
SELECT * FROM fn::knowledge_search_keywords_for_ai(
    ["database", "field", "validation"],
    "SURREAL_DB",
    10
);
```

---

### 3. `fn::knowledge_get_content_by_type_for_ai()`

Récupère les contenus d'un topic filtrés par type, optimisé IA.

**Paramètres** :
- `$topic_code` : Code du topic (ex: `"DEFINE_FIELD"`)
- `$content_types` : Array de types (ex: `["SYNTAX", "EXAMPLE_CORRECT"]`)
- `$quality_threshold` : Score minimum (défaut: `0.7`)

**Retourne** : Topic + contenus filtrés par type, triés par priorité et qualité

**Exemple** :
```sql
SELECT * FROM fn::knowledge_get_content_by_type_for_ai(
    "DEFINE_FIELD",
    ["SYNTAX", "EXAMPLE_CORRECT"],
    0.7
);
```

---

### 4. `fn::knowledge_get_best_content_for_ai()`

Récupère le meilleur contenu pour un topic selon critères IA.

**Paramètres** :
- `$topic_code` : Code du topic (ex: `"DEFINE_FIELD"`)
- `$level` : Niveau (`"BEGINNER"`, `"INTERMEDIATE"`, `"ADVANCED"`, `"EXPERT"`) - optionnel
- `$min_quality_score` : Score minimum (défaut: `0.7`)

**Retourne** : Topic + meilleur contenu (un seul) selon critères

**Exemple** :
```sql
SELECT * FROM fn::knowledge_get_best_content_for_ai(
    "DEFINE_FIELD",
    "BEGINNER",
    0.7
);
```

---

### 5. `fn::knowledge_get_domain_overview_for_ai()`

Vue d'ensemble d'un domaine avec ses topics et statistiques.

**Paramètres** :
- `$domain_code` : Code du domaine (ex: `"SURREAL_DB"`)

**Retourne** : Domaine complet + liste de topics + statistiques (totaux, qualité moyenne, etc.)

**Exemple** :
```sql
SELECT * FROM fn::knowledge_get_domain_overview_for_ai("SURREAL_DB");
```

---

## 🎯 Intentions IA Supportées

Les fonctions `get_topic_bundle_for_ai()` filtrent automatiquement selon l'intention :

| Intention | Types de contenus inclus |
|-----------|--------------------------|
| `GENERATE_CODE` | `SYNTAX`, `RULE`, `EXAMPLE_CORRECT`, `PATTERN` |
| `TEACH` | `SYNTAX`, `EXPLANATION`, `EXAMPLE_CORRECT`, `EXAMPLE_INCORRECT`, `TIP` |
| `VALIDATE` | `RULE`, `EXAMPLE_INCORRECT`, `PATTERN` |
| `QUICK_HELP` | `TIP`, `SYNTAX`, `EXAMPLE_CORRECT` |

---

## 📊 Format de Réponse Standard

Toutes les fonctions retournent un format standardisé :

```json
{
  "success": true,
  "data": {
    "topic": {...},
    "contents": [...],
    "metadata": {...}
  },
  "metadata": {
    "total_found": 5,
    "quality_filtered": true,
    "query_time": "..."
  },
  "prompt_format": {
    "system": "...",
    "user": "...",
    "context": "..."
  }
}
```

---

## 🚀 Avantages

1. **Simplification** : L'IA appelle une fonction au lieu d'écrire du SQL complexe
2. **Performance** : Filtrage et tri optimisés côté base
3. **Qualité** : Filtrage automatique par `quality_score`
4. **Cohérence** : Format standardisé pour toutes les IA
5. **Évolutivité** : Facile d'ajouter du caching, priorisation, etc. plus tard

---

## 🧠 Workflow Intelligent : Découverte et Sélection Automatique

Pour des tâches complexes (ex: "Créer le module calendar"), l'IA peut utiliser un workflow intelligent qui combine plusieurs fonctions :

### 🔍 Étape 1 : Explorer le Domaine

L'IA commence par découvrir tous les topics disponibles dans un domaine :

```sql
-- L'IA voit TOUS les topics du domaine avec leurs statistiques
SELECT * FROM fn::knowledge_get_domain_overview_for_ai("SURREAL_DB");
```

**Ce que l'IA obtient :**
- Liste complète des topics du domaine
- Statistiques pour chaque topic :
  - `contents_count` : Nombre de contenus disponibles
  - `high_quality_contents_count` : Nombre de contenus haute qualité
  - `best_content_quality` : Meilleur score de qualité
- Keywords associés à chaque topic
- Topics triés par nombre de contenus (les plus riches en premier)

### 🎯 Étape 2 : Sélectionner les Topics Pertinents

L'IA analyse les statistiques et sélectionne automatiquement les topics les plus utiles pour la tâche :

**Exemple pour "Créer le module calendar" :**

```
Topics disponibles dans SURREAL_DB :
✅ DEFINE_TABLE (15 contenus, qualité 0.9) → Très pertinent !
✅ DEFINE_FIELD (20 contenus, qualité 0.85) → Essentiel !
✅ LYXAL_ARCHITECTURE (12 contenus, qualité 0.9) → Important !
✅ DEFINE_INDEX (8 contenus, qualité 0.8) → Utile pour optimiser
❌ ADVANCED_PATTERNS (5 contenus, qualité 0.7) → Pas nécessaire pour commencer
```

**Critères de sélection :**
- Nombre de contenus (`contents_count`) : Plus il y a de contenus, plus le topic est riche
- Qualité moyenne (`best_content_quality`) : Prioriser les topics avec contenu de haute qualité
- Keywords : Vérifier si les keywords correspondent à la tâche
- Pertinence contextuelle : Sélectionner selon l'intention (GENERATE_CODE, TEACH, etc.)

### 📦 Étape 3 : Récupérer les Bundles pour les Topics Sélectionnés

L'IA fait des appels ciblés uniquement pour les topics sélectionnés :

```sql
-- Topic 1 : Architecture Lyxal
SELECT * FROM fn::knowledge_get_topic_bundle_for_ai(
    "LYXAL_ARCHITECTURE",
    "GENERATE_CODE",
    0.7,
    10,
    "INTERMEDIATE"
);

-- Topic 2 : Création de tables
SELECT * FROM fn::knowledge_get_topic_bundle_for_ai(
    "DEFINE_TABLE",
    "GENERATE_CODE",
    0.7,
    10,
    "INTERMEDIATE"
);

-- Topic 3 : Définition de champs
SELECT * FROM fn::knowledge_get_topic_bundle_for_ai(
    "DEFINE_FIELD",
    "GENERATE_CODE",
    0.7,
    10,
    "INTERMEDIATE"
);
```

### ✨ Résultat

L'IA dispose de toutes les connaissances nécessaires pour :
- ✅ Respecter l'architecture Lyxal (organisation des modules, conventions)
- ✅ Utiliser les bonnes pratiques SurrealDB (syntaxe, patterns)
- ✅ Générer du code idempotent (`IF NOT EXISTS`)
- ✅ Créer un module complet et conforme

### 🎯 Avantages de ce Workflow

1. **Intelligence contextuelle** : L'IA sélectionne dynamiquement selon la tâche
2. **Optimisation** : Ne récupère que les topics pertinents, pas tout le domaine
3. **Qualité** : Priorise les topics avec plus de contenus et meilleure qualité
4. **Évolutivité** : Si de nouveaux topics sont ajoutés, l'IA les découvre automatiquement
5. **Flexibilité** : S'adapte selon le contexte (débutant vs expert)

### 📝 Exemple Complet : "Créer le module calendar"

```
1. User demande : "Créer le module calendar"

2. IA appelle : get_domain_overview_for_ai("SURREAL_DB")
   → Découvre 10+ topics disponibles

3. IA analyse et sélectionne :
   - DEFINE_TABLE (15 contenus, qualité 0.9) → ✅
   - DEFINE_FIELD (20 contenus, qualité 0.85) → ✅
   - LYXAL_ARCHITECTURE (12 contenus, qualité 0.9) → ✅

4. IA récupère les bundles pour ces 3 topics

5. IA génère le module calendar complet :
   📁 calendar/
     ├── database/
     │   ├── calendar_event.surql
     │   └── calendar_appointment.surql
     └── documentation/
```

---

## 📊 Fonctions de Tracking (Sous-dossier `tracking/`)

Le dossier `tracking/` contient des fonctions séparées pour automatiser le tracking des métriques d'usage :

- `fn::knowledge_track_content_view()` - Incrémente le compteur de vues
- `fn::knowledge_track_ai_usage()` - Incrémente le compteur d'utilisation IA
- `fn::knowledge_track_content_access()` - Fonction combinée pour tracking
- `fn::knowledge_track_get_analytics()` - Récupère les métriques analytics

**Note** : Ces fonctions sont **séparées des fonctions IA** pour respecter la séparation des responsabilités. Elles peuvent être appelées depuis les fonctions IA si nécessaire, mais ne sont pas encore intégrées automatiquement.

📚 **Documentation complète** : Voir `tracking/README.md`

---

## 🔍 Fonctions de Détection de Gaps (Sous-dossier `gap_detection/`)

Le dossier `gap_detection/` contient des fonctions pour détecter automatiquement les lacunes dans le système de connaissance :

- `fn::knowledge_gap_detect_missing_content()` - Détecte les topics avec peu/pas de contenus
- `fn::knowledge_gap_detect_low_quality_content()` - Détecte les contenus de faible qualité
- `fn::knowledge_gap_detect_missing_keywords()` - Détecte les topics/domaines avec peu de keywords
- `fn::knowledge_gap_record_gap()` - Enregistre un gap dans la table `knowledge_gap`

**Note** : Ces fonctions permettent au système d'identifier automatiquement ce qui manque ou doit être amélioré, facilitant l'amélioration continue (v3 – Self-Learning).

📚 **Documentation complète** : Voir `gap_detection/README.md`

---

## 🔄 Fonctions d'Enrichissement Automatique (Sous-dossier `enrichment/`)

Le dossier `enrichment/` contient des fonctions pour enrichir automatiquement le système à partir des gaps détectés :

- `fn::knowledge_enrich_propose_content()` - Propose un nouveau contenu basé sur un gap
- `fn::knowledge_enrich_approve_proposal()` - Approuve une proposition et la transforme en contenu réel
- `fn::knowledge_enrich_process_gaps()` - Traite automatiquement les gaps pour générer des propositions

**Note** : Ces fonctions permettent au système de proposer automatiquement de nouveaux contenus basés sur les lacunes identifiées, avec validation humaine (v3 – Self-Learning).

📚 **Documentation complète** : Voir `enrichment/README.md`

---

## 📊 Fonctions Analytics et Métriques (Sous-dossier `analytics/`)

Le dossier `analytics/` contient des fonctions pour analyser les métriques d'usage et générer des statistiques pour le dashboard :

- `fn::knowledge_analytics_get_global_stats()` - Statistiques globales du système
- `fn::knowledge_analytics_get_domain_stats()` - Statistiques détaillées par domaine
- `fn::knowledge_analytics_get_topic_stats()` - Statistiques détaillées par topic
- `fn::knowledge_analytics_get_top_contents()` - Top contenus les plus consultés avec filtres
- `fn::knowledge_analytics_get_unused_contents()` - Contenus jamais consultés (potentiellement obsolètes)

**Note** : Ces fonctions permettent de créer un dashboard complet avec vue d'ensemble, analyse par domaine/topic, identification des contenus populaires et obsolètes (v2 – IA-Ready).

📚 **Documentation complète** : Voir `analytics/README.md`

---

## 🎓 Fonctions d'Export pour Entraînement IA (Sous-dossier `training/`)

Le dossier `training/` contient des fonctions pour exporter les contenus de connaissance au format structuré pour l'entraînement de modèles IA :

- `fn::knowledge_export_domain_for_training()` - Exporte les contenus d'un domaine pour entraînement (format JSONL-ready)
- `fn::knowledge_export_create_dataset()` - Crée un export avec versioning automatique et tracking
- `fn::knowledge_export_list_datasets()` - Liste les exports avec filtres optionnels
- `fn::knowledge_export_auto_version()` - Génère automatiquement la prochaine version pour un domaine

**Note** : Ces fonctions permettent de générer des datasets structurés pour fine-tuning de modèles IA spécialisés, avec filtrage par qualité, pondération, versioning automatique et tracking complet (v3 – Self-Learning).

📚 **Documentation complète** : Voir `training/README.md`

---

## 📚 Références

- **Fonctions de tracking** : `tracking/README.md`
- **Fonctions de détection de gaps** : `gap_detection/README.md`
- **Fonctions d'enrichissement** : `enrichment/README.md`
- **Fonctions analytics** : `analytics/README.md`
- **Fonctions d'export entraînement** : `training/README.md`
- **Guide d'utilisation IA** : `📄 09_How_AI_Should_Use_Knowledge.md`
- **Requêtes utiles** : `📄 10_Useful_Queries.md`
- **Schéma complet** : `SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


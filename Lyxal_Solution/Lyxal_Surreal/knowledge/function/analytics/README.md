# 📊 Fonctions Analytics et Métriques – Knowledge System

Ce dossier contient les **fonctions SurrealDB** pour analyser les métriques d'usage et générer des statistiques pour le dashboard.

## 🎯 Objectif

Fournir des fonctions pour :
- ✅ Obtenir des statistiques globales du système
- ✅ Analyser les métriques par domaine et par topic
- ✅ Identifier les contenus les plus consultés
- ✅ Détecter les contenus jamais utilisés (potentiellement obsolètes)
- ✅ Mesurer la complétude et la qualité du système

## 📋 Fonctions Disponibles

### 1. `fn::knowledge_analytics_get_global_stats()`

Récupère les statistiques globales du système de connaissance.

**Paramètres** : Aucun

**Retourne** :
```json
{
  "success": true,
  "generated_at": "2025-01-15T10:30:00Z",
  "domains": {
    "total": 5,
    "total_topics": 25,
    "total_contents": 150
  },
  "topics": {
    "total": 25,
    "with_contents": 20,
    "without_contents": 5,
    "avg_contents_per_topic": 7.5
  },
  "contents": {
    "total": 150,
    "with_views": 120,
    "with_ai_usage": 80,
    "unused": 30,
    "total_views": 5000,
    "total_ai_usage": 2500,
    "avg_quality_score": 0.75,
    "avg_views_per_content": 41.67,
    "ai_usage_ratio": 50.0
  },
  "contents_by_type": [
    {
      "content_type": "SYNTAX",
      "count": 45,
      "avg_quality": 0.8,
      "total_views": 2000
    }
  ],
  "top_contents": [...]
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_analytics_get_global_stats();
```

**Utilisation** :
- Dashboard principal : Vue d'ensemble du système
- Rapport de santé : Identifier les problèmes généraux
- Métriques de performance : Mesurer l'efficacité globale

---

### 2. `fn::knowledge_analytics_get_domain_stats()`

Récupère les statistiques détaillées pour un domaine spécifique.

**Paramètres** :
- `$domain_code` : Code du domaine (ex: `"SURREAL_DB"`)

**Retourne** :
```json
{
  "success": true,
  "domain": {
    "id": "knowledge_domain:SURREAL_DB",
    "code": "SURREAL_DB",
    "slug": "surreal-db",
    "label_key": "i18n_key:domain_surreal_db_label"
  },
  "generated_at": "2025-01-15T10:30:00Z",
  "topics": {
    "total": 10,
    "with_contents": 8,
    "without_contents": 2,
    "avg_contents_per_topic": 12.5
  },
  "contents": {
    "total": 100,
    "with_views": 85,
    "with_ai_usage": 60,
    "unused": 15,
    "total_views": 3000,
    "total_ai_usage": 1500,
    "avg_quality_score": 0.78,
    "avg_views_per_content": 35.29,
    "ai_usage_ratio": 50.0
  },
  "top_topics": [...],
  "contents_by_type": [...],
  "top_contents": [...]
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_analytics_get_domain_stats("SURREAL_DB");
```

**Utilisation** :
- Dashboard par domaine : Analyse approfondie d'un domaine
- Identification des topics prioritaires : Voir quels topics ont besoin de plus de contenus
- Optimisation : Identifier les contenus les plus utilisés dans un domaine

---

### 3. `fn::knowledge_analytics_get_topic_stats()`

Récupère les statistiques détaillées pour un topic spécifique.

**Paramètres** :
- `$topic_code` : Code du topic (ex: `"DEFINE_FIELD"`)

**Retourne** :
```json
{
  "success": true,
  "topic": {
    "id": "knowledge_topic:DEFINE_FIELD",
    "code": "DEFINE_FIELD",
    "slug": "define-field",
    "label_key": "i18n_key:topic_define_field_label",
    "domain": {
      "code": "SURREAL_DB",
      "slug": "surreal-db"
    }
  },
  "generated_at": "2025-01-15T10:30:00Z",
  "contents": {
    "total": 15,
    "with_views": 12,
    "with_ai_usage": 8,
    "unused": 3,
    "total_views": 500,
    "total_ai_usage": 300,
    "avg_quality_score": 0.82,
    "avg_views_per_content": 41.67,
    "max_quality_score": 0.95,
    "min_quality_score": 0.6,
    "ai_usage_ratio": 60.0
  },
  "contents_by_type": [...],
  "top_contents": [...],
  "unused_contents": [...]
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_analytics_get_topic_stats("DEFINE_FIELD");
```

**Utilisation** :
- Analyse de topic : Voir la complétude et la qualité d'un topic
- Identification des gaps : Contenus manquants ou peu utilisés
- Optimisation : Améliorer les contenus d'un topic spécifique

---

### 4. `fn::knowledge_analytics_get_top_contents()`

Récupère les contenus les plus consultés avec filtres optionnels.

**Paramètres** :
- `$limit` : Nombre de résultats (optionnel, défaut: `20`)
- `$domain_code` : Filtrer par domaine (optionnel)
- `$topic_code` : Filtrer par topic (optionnel)
- `$content_type` : Filtrer par type de contenu (optionnel)
- `$min_quality_score` : Score de qualité minimum (optionnel, défaut: `0.0`)

**Retourne** :
```json
{
  "success": true,
  "generated_at": "2025-01-15T10:30:00Z",
  "filters": {
    "limit": 20,
    "domain_code": "SURREAL_DB",
    "topic_code": null,
    "content_type": null,
    "min_quality_score": 0.7
  },
  "total_found": 15,
  "top_contents": [
    {
      "id": "knowledge_content:content_slug",
      "slug": "content_slug",
      "type": "SYNTAX",
      "type_label": "i18n_key:content_type_syntax_label",
      "topic": {
        "code": "DEFINE_FIELD",
        "slug": "define-field",
        "label_key": "i18n_key:topic_define_field_label"
      },
      "domain": {
        "code": "SURREAL_DB",
        "slug": "surreal-db"
      },
      "view_count": 500,
      "ai_usage_count": 300,
      "last_viewed": "2025-01-15T09:00:00Z",
      "quality_score": 0.9,
      "ai_usage_ratio": 60.0
    }
  ]
}
```

**Exemple** :
```sql
-- Top 10 contenus global
SELECT * FROM fn::knowledge_analytics_get_top_contents(10);

-- Top contenus d'un domaine avec qualité minimale
SELECT * FROM fn::knowledge_analytics_get_top_contents(
    20,
    "SURREAL_DB",
    NONE,
    NONE,
    0.7
);

-- Top contenus SYNTAX d'un topic
SELECT * FROM fn::knowledge_analytics_get_top_contents(
    10,
    NONE,
    "DEFINE_FIELD",
    "SYNTAX",
    0.8
);
```

**Utilisation** :
- Dashboard : Afficher les contenus les plus populaires
- Optimisation : Identifier les contenus à améliorer
- Statistiques : Mesurer l'impact des contenus

---

### 5. `fn::knowledge_analytics_get_unused_contents()`

Récupère les contenus jamais consultés (potentiellement obsolètes).

**Paramètres** :
- `$limit` : Nombre de résultats (optionnel, défaut: `50`)
- `$domain_code` : Filtrer par domaine (optionnel)
- `$topic_code` : Filtrer par topic (optionnel)
- `$max_quality_score` : Score de qualité maximum pour inclure (optionnel, défaut: `1.0`)

**Retourne** :
```json
{
  "success": true,
  "generated_at": "2025-01-15T10:30:00Z",
  "filters": {
    "limit": 50,
    "domain_code": "SURREAL_DB",
    "topic_code": null,
    "max_quality_score": 0.6
  },
  "total_found": 15,
  "unused_contents": [
    {
      "id": "knowledge_content:old_content",
      "slug": "old_content",
      "type": "SYNTAX",
      "type_label": "i18n_key:content_type_syntax_label",
      "topic": {
        "code": "DEFINE_FIELD",
        "slug": "define-field",
        "label_key": "i18n_key:topic_define_field_label"
      },
      "domain": {
        "code": "SURREAL_DB",
        "slug": "surreal-db"
      },
      "quality_score": 0.5,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

**Exemple** :
```sql
-- Contenus jamais consultés avec qualité faible
SELECT * FROM fn::knowledge_analytics_get_unused_contents(
    50,
    NONE,
    NONE,
    0.6
);

-- Contenus inutilisés d'un domaine spécifique
SELECT * FROM fn::knowledge_analytics_get_unused_contents(
    30,
    "SURREAL_DB",
    NONE,
    0.7
);
```

**Utilisation** :
- Nettoyage : Identifier les contenus à supprimer ou améliorer
- Optimisation : Détecter les contenus peu pertinents
- Audit : Analyser la qualité et l'utilisation du système

---

## 🔄 Intégration avec le Dashboard

Ces fonctions peuvent être utilisées pour créer un dashboard complet :

### Vue d'ensemble globale
```sql
SELECT * FROM fn::knowledge_analytics_get_global_stats();
```

### Vue par domaine
```sql
FOR $domain IN (SELECT VALUE identity.code FROM knowledge_domain WHERE metadata.is_active = true) {
    SELECT * FROM fn::knowledge_analytics_get_domain_stats($domain);
};
```

### Top contenus
```sql
SELECT * FROM fn::knowledge_analytics_get_top_contents(10);
```

### Contenus à améliorer
```sql
SELECT * FROM fn::knowledge_analytics_get_unused_contents(20, NONE, NONE, 0.6);
```

---

## 📊 Cas d'Usage

### Dashboard de santé du système

```sql
-- Statistiques globales
LET $global = SELECT * FROM fn::knowledge_analytics_get_global_stats();

-- Domaines avec le plus de contenus
FOR $domain IN (SELECT VALUE identity.code FROM knowledge_domain WHERE metadata.is_active = true) {
    LET $stats = SELECT * FROM fn::knowledge_analytics_get_domain_stats($domain);
    -- Afficher les métriques
};
```

### Identification des gaps

```sql
-- Topics sans contenus (via global stats)
LET $global = SELECT * FROM fn::knowledge_analytics_get_global_stats();
-- $global.topics.without_contents = nombre de topics vides

-- Contenus jamais utilisés
LET $unused = SELECT * FROM fn::knowledge_analytics_get_unused_contents(100);
-- Analyser pour déterminer s'ils doivent être supprimés ou améliorés
```

### Optimisation de qualité

```sql
-- Top contenus pour voir ce qui fonctionne bien
SELECT * FROM fn::knowledge_analytics_get_top_contents(20, NONE, NONE, NONE, 0.8);

-- Contenus de faible qualité jamais consultés
SELECT * FROM fn::knowledge_analytics_get_unused_contents(50, NONE, NONE, 0.5);
```

---

## 🎯 Avantages

1. **Vue complète** : Statistiques globales et détaillées
2. **Filtrage flexible** : Multiples critères de filtrage
3. **Performance** : Requêtes optimisées avec agrégations côté base
4. **Extensibilité** : Facile d'ajouter de nouvelles métriques
5. **Dashboard-ready** : Format de réponse structuré pour affichage

---

## 📚 Références

- **Fonctions de tracking** : `function/tracking/README.md`
- **Champs analytics** : `knowledge/documentation/06_Knowledge_Content.md` (section `metadata.analytics`)
- **Schéma complet** : `knowledge/documentation/SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


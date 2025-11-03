-- ============================================================================
-- Fichier : knowledge/function/gap_detection/README.md
-- Module : knowledge
-- Description : Documentation des fonctions de détection de gaps
-- ============================================================================

# 🔍 Fonctions de Détection de Gaps – Knowledge System

Ce dossier contient les **fonctions SurrealDB** pour détecter automatiquement les lacunes (gaps) dans le système de connaissance.

## 🎯 Objectif

Fournir des fonctions pour :
- ✅ Détecter automatiquement les topics avec peu ou pas de contenus
- ✅ Identifier les contenus de faible qualité
- ✅ Repérer les topics/domaines avec peu de keywords
- ✅ Enregistrer les gaps détectés dans la table `knowledge_gap`
- ✅ Analyser les patterns de gaps pour améliorer le système

## 📋 Fonctions Disponibles

### 1. `fn::knowledge_gap_detect_missing_content()`

Détecte les topics avec peu ou pas de contenus de haute qualité.

**Paramètres** :
- `$domain_code` : Code du domaine pour filtrer (optionnel, ex: `"SURREAL_DB"`)
- `$min_content_count` : Nombre minimum de contenus requis (défaut: `3`)
- `$min_quality_score` : Score de qualité minimum (défaut: `0.7`)

**Retourne** :
```json
{
  "success": true,
  "gaps_detected": 5,
  "gaps": [
    {
      "gap_type": "missing_content",
      "severity": "critical",
      "domain": {...},
      "topic": {...},
      "description": "...",
      "expected_content": "...",
      ...
    }
  ],
  "filters": {...},
  "detected_at": "..."
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_gap_detect_missing_content(
    "SURREAL_DB",
    3,
    0.7
);
```

---

### 2. `fn::knowledge_gap_detect_low_quality_content()`

Détecte les contenus de faible qualité nécessitant amélioration.

**Paramètres** :
- `$max_quality_score` : Score de qualité maximum pour considérer comme faible qualité (défaut: `0.6`)
- `$min_feedback_negative` : Nombre minimum de feedbacks négatifs pour déclencher (défaut: `2`)

**Retourne** :
```json
{
  "success": true,
  "gaps_detected": 8,
  "gaps": [
    {
      "gap_type": "low_quality_content",
      "severity": "high",
      "content": {...},
      "description": "...",
      ...
    }
  ],
  ...
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_gap_detect_low_quality_content(
    0.6,
    2
);
```

---

### 3. `fn::knowledge_gap_detect_missing_keywords()`

Détecte les topics/domaines avec peu ou pas de keywords pour la recherche.

**Paramètres** :
- `$domain_code` : Code du domaine pour filtrer (optionnel)
- `$min_keyword_count` : Nombre minimum de keywords requis (défaut: `3`)

**Retourne** :
```json
{
  "success": true,
  "gaps_detected": 10,
  "gaps_topics": [...],
  "gaps_domains": [...],
  ...
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_gap_detect_missing_keywords(
    "SURREAL_DB",
    3
);
```

---

### 4. `fn::knowledge_gap_record_gap()`

Enregistre un gap détecté dans la table `knowledge_gap`. Gère automatiquement les doublons en incrémentant le compteur de récurrence.

**Paramètres** :
- `$gap_type` : Type de gap (ex: `"missing_content"`)
- `$severity` : Sévérité (`"low"`, `"medium"`, `"high"`, `"critical"`)
- `$domain`, `$topic`, `$content` : Références optionnelles
- `$description`, `$expected_content` : Descriptions optionnelles
- `$suggested_keywords` : Mots-clés suggérés (optionnel)
- `$detection_method` : Méthode (`"automatic"`, `"feedback"`, `"usage_analysis"`, `"manual"`)
- `$detection_source` : Source de détection (optionnel)
- `$confidence` : Niveau de confiance (0-1)
- `$priority` : Priorité (entier)
- `$impact_score` : Score d'impact (0-1)

**Retourne** :
```json
{
  "success": true,
  "action": "created" | "updated",
  "gap_id": "knowledge_gap:gap_xyz",
  "recurrence_count": 1
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_gap_record_gap(
    "missing_content",
    "high",
    knowledge_domain:SURREAL_DB,
    knowledge_topic:DEFINE_FIELD,
    NONE,
    "Topic a seulement 1 contenu",
    "Recommandé: 3+ contenus de qualité",
    NONE,
    "automatic",
    "detect_missing_content",
    0.9,
    4,
    0.8
);
```

---

## 🔄 Workflow de Détection

### Workflow automatique complet

```sql
-- 1. Détecter les contenus manquants
LET $missing_content = SELECT * FROM fn::knowledge_gap_detect_missing_content(NONE, 3, 0.7);

-- 2. Enregistrer chaque gap détecté
FOR $gap IN $missing_content.gaps {
    SELECT * FROM fn::knowledge_gap_record_gap(
        $gap.gap_type,
        $gap.severity,
        $gap.domain,
        $gap.topic,
        $gap.content,
        $gap.description,
        $gap.expected_content,
        $gap.suggested_keywords,
        $gap.detection.method,
        $gap.detection.source,
        $gap.detection.confidence,
        $gap.metadata.priority,
        $gap.metadata.impact_score
    );
};

-- 3. Détecter les contenus de faible qualité
LET $low_quality = SELECT * FROM fn::knowledge_gap_detect_low_quality_content(0.6, 2);

-- 4. Enregistrer ces gaps également
FOR $gap IN $low_quality.gaps {
    SELECT * FROM fn::knowledge_gap_record_gap(...);
};
```

---

## 📊 Cas d'Usage

### Détection automatique périodique

Exécuter ces fonctions périodiquement pour identifier les gaps :
- **Quotidien** : Détection de contenus de faible qualité (basé sur feedbacks récents)
- **Hebdomadaire** : Détection de contenus manquants et keywords manquants
- **Mensuel** : Analyse complète de tous les types de gaps

### Détection à la demande

Les fonctions peuvent être appelées manuellement pour analyser un domaine spécifique :

```sql
-- Analyser uniquement le domaine SurrealDB
SELECT * FROM fn::knowledge_gap_detect_missing_content("SURREAL_DB", 3, 0.7);
```

### Intégration avec feedback

Les feedbacks peuvent déclencher la création automatique de gaps :

```sql
-- Si un feedback négatif avec impact élevé
CREATE knowledge_gap SET
    gap_type = "low_quality_content",
    severity = "high",
    content = $feedback.content,
    detection.method = "feedback",
    detection.source = $feedback.id,
    ...
```

---

## 🎯 Types de Gaps Détectables

| Type | Description | Détection |
|------|-------------|-----------|
| `missing_topic` | Topic manquant dans un domaine | Analyse manuelle ou suggestion |
| `missing_content` | Contenus manquants pour un topic | ✅ `detect_missing_content()` |
| `incomplete_content` | Contenu incomplet | Analyse structure ou feedback |
| `missing_keywords` | Keywords manquants | ✅ `detect_missing_keywords()` |
| `low_quality_content` | Contenu de faible qualité | ✅ `detect_low_quality_content()` |
| `outdated_content` | Contenu obsolète | Analyse date + feedback |

---

## 📚 Références

- **Table gaps** : `knowledge/documentation/11_Knowledge_Gap.md` (à créer)
- **Table feedback** : `knowledge/documentation/10_Knowledge_Feedback.md`
- **Schéma complet** : `knowledge/documentation/SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


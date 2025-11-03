# 🔍 Table : `knowledge_gap`

## 🎯 Objectif

La table `knowledge_gap` permet de stocker et gérer les lacunes (gaps) détectées dans le système de connaissance. Elle sert de base pour l'amélioration continue et la complétion automatique du système.

**Fondation pour v3 – Self-Learning** : Cette table permet au système d'identifier automatiquement ce qui manque ou doit être amélioré, facilitant l'enrichissement automatique et la détection proactive de problèmes.

---

## 🧱 Structure

| Bloc | Description |
|------|-------------|
| `gap_type` | Type de gap détecté (missing_topic, missing_content, etc.) |
| `severity` | Sévérité du gap (low, medium, high, critical) |
| `domain`, `topic`, `content` | Références optionnelles vers les entités concernées |
| `detection.*` | Informations sur la détection (méthode, source, date, confiance) |
| `description` | Description détaillée du gap |
| `expected_content` | Description du contenu attendu |
| `resolution.*` | État de résolution (status, dates, notes) |
| `metadata.*` | Métadonnées (priorité, impact, récurrence) |

---

## 🔗 Relations

| Table liée | Type | Description |
|------------|------|-------------|
| `knowledge_domain` | N → 1 | Domaine concerné (optionnel, CASCADE) |
| `knowledge_topic` | N → 1 | Topic concerné (optionnel, CASCADE) |
| `knowledge_content` | N → 1 | Contenu concerné (optionnel, CASCADE) |

**Comportement** : `ON DELETE CASCADE` - Si une entité référencée est supprimée, le gap est également supprimé.

---

## 🧩 Champs principaux

### 🏷️ `gap_type` - Type de gap

- **Type** : `string`
- **Valeurs possibles** :
  - `"missing_topic"` : Topic manquant dans un domaine
  - `"missing_content"` : Contenus manquants pour un topic
  - `"incomplete_content"` : Contenu incomplet
  - `"missing_keywords"` : Mots-clés manquants pour découvrabilité
  - `"low_quality_content"` : Contenu de faible qualité
  - `"outdated_content"` : Contenu obsolète
- **Rôle** : Catégorise le type de gap pour traitement ciblé

---

### ⚠️ `severity` - Sévérité

- **Type** : `string`
- **Valeurs possibles** : `"low"`, `"medium"`, `"high"`, `"critical"`
- **Défaut** : `"medium"`
- **Rôle** : Indique l'urgence et l'importance de résoudre le gap

---

### 📍 Références contextuelles

#### `domain`
- **Type** : `option<record<knowledge_domain>>`
- **Rôle** : Domaine concerné (optionnel si gap général)

#### `topic`
- **Type** : `option<record<knowledge_topic>>`
- **Rôle** : Topic concerné (optionnel si gap au niveau domaine)

#### `content`
- **Type** : `option<record<knowledge_content>>`
- **Rôle** : Contenu concerné (optionnel si gap au niveau topic/domaine)

---

### 🔍 `detection` - Informations de détection

#### `detection.method`
- **Type** : `string`
- **Valeurs possibles** :
  - `"automatic"` : Détection automatique par IA (défaut)
  - `"feedback"` : Remonté via feedback utilisateur/IA
  - `"usage_analysis"` : Analyse d'usage (requêtes échouées, etc.)
  - `"manual"` : Détection manuelle

#### `detection.source`
- **Type** : `option<string>`
- **Rôle** : Source de la détection (ID requête échouée, ID feedback, nom de l'analyseur, etc.)

#### `detection.detected_at`
- **Type** : `datetime`
- **Défaut** : `time::now()`
- **Rôle** : Date et heure de détection

#### `detection.confidence`
- **Type** : `number`
- **Contrainte** : 0 ≤ `confidence` ≤ 1, défaut : `0.5`
- **Rôle** : Niveau de confiance de la détection (0 = incertain, 1 = très sûr)

---

### 📝 `description` et `expected_content`

#### `description`
- **Type** : `option<string>`
- **Rôle** : Description détaillée du gap détecté

#### `expected_content`
- **Type** : `option<string>`
- **Rôle** : Description du contenu attendu (pour gaps de type missing_content/incomplete_content)

#### `suggested_keywords`
- **Type** : `option<array<string>>`
- **Rôle** : Mots-clés suggérés pour améliorer la découvrabilité (pour gaps missing_keywords)

---

### ✅ `resolution` - État de résolution

#### `resolution.status`
- **Type** : `string`
- **Valeurs possibles** :
  - `"pending"` : En attente (défaut)
  - `"in_progress"` : En cours de traitement
  - `"resolved"` : Résolu
  - `"rejected"` : Rejeté/non pertinent
  - `"duplicate"` : Doublon d'un autre gap
- **Rôle** : Statut de résolution du gap

#### `resolution.resolved_at`
- **Type** : `option<datetime>`
- **Rôle** : Date et heure de résolution

#### `resolution.resolved_by`
- **Type** : `option<string>`
- **Rôle** : Identifiant de la personne/IA qui a résolu le gap

#### `resolution.resolution_content`
- **Type** : `option<record<knowledge_content>>`
- **Rôle** : Référence vers le contenu créé pour résoudre ce gap (si applicable)

#### `resolution.notes`
- **Type** : `option<string>`
- **Rôle** : Notes sur la résolution (pourquoi rejeté, comment résolu, etc.)

---

### ⚙️ `metadata` - Métadonnées

#### `metadata.priority`
- **Type** : `int`
- **Défaut** : `0`
- **Rôle** : Priorité de traitement (0 = normale, plus élevé = plus prioritaire)

#### `metadata.impact_score`
- **Type** : `number`
- **Contrainte** : 0 ≤ `impact_score` ≤ 1, défaut : `0.5`
- **Rôle** : Score d'impact estimé (0 = faible impact, 1 = impact critique)

#### `metadata.is_active`
- **Type** : `bool`
- **Défaut** : `true`
- **Rôle** : Le gap est actif (peut être désactivé sans suppression)

#### `metadata.recurrence_count`
- **Type** : `int`
- **Défaut** : `1`
- **Rôle** : Nombre de fois que ce gap a été détecté (pour détecter les patterns)

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_gap_type` | `gap_type` | Normal | Filtrage par type |
| `idx_gap_severity` | `severity` | Normal | Filtrage par sévérité |
| `idx_gap_status` | `resolution.status` | Normal | Filtrage par statut |
| `idx_gap_domain` | `domain` | Normal | Recherche par domaine |
| `idx_gap_topic` | `topic` | Normal | Recherche par topic |
| `idx_gap_active` | `metadata.is_active` | Normal | Filtrage des gaps actifs |
| `idx_gap_priority` | `metadata.priority` | Normal | Tri par priorité |
| `idx_gap_detected` | `detection.detected_at` | Normal | Tri chronologique |
| `idx_gap_pending_severity` | `resolution.status, severity, metadata.priority` | Composite | Requêtes optimisées pour gaps en attente |

---

## 📝 Exemples d'utilisation

### ✅ Créer un gap manuellement

```surql
CREATE knowledge_gap SET
    gap_type = "missing_content",
    severity = "high",
    domain = knowledge_domain:SURREAL_DB,
    topic = knowledge_topic:DEFINE_FIELD,
    description = "Le topic DEFINE_FIELD n'a que 1 contenu, il en faudrait au moins 3",
    expected_content = "Recommandé: SYNTAX, RULE, et EXAMPLE_CORRECT minimum",
    detection.method = "manual",
    detection.confidence = 0.9,
    metadata.priority = 4,
    metadata.impact_score = 0.8;
```

### ✅ Marquer un gap comme résolu

```surql
UPDATE knowledge_gap:gap_id SET
    resolution.status = "resolved",
    resolution.resolved_at = time::now(),
    resolution.resolved_by = "user_expert",
    resolution.resolution_content = knowledge_content:new_content_id,
    resolution.notes = "Créé 3 nouveaux contenus : SYNTAX, RULE, et EXAMPLE_CORRECT"
WHERE id = knowledge_gap:gap_id;
```

### ✅ Récupérer les gaps critiques en attente

```surql
SELECT 
    id,
    gap_type,
    severity,
    domain->identity.code AS domain_code,
    topic->identity.code AS topic_code,
    description,
    metadata.priority,
    metadata.impact_score,
    detection.confidence,
    detection.detected_at
FROM knowledge_gap
WHERE severity = "critical"
    AND resolution.status = "pending"
    AND metadata.is_active = true
ORDER BY metadata.priority DESC, metadata.impact_score DESC, detection.detected_at ASC;
```

### ✅ Récupérer les gaps pour un domaine spécifique

```surql
SELECT 
    gap_type,
    severity,
    count() AS gap_count
FROM knowledge_gap
WHERE domain = knowledge_domain:SURREAL_DB
    AND resolution.status = "pending"
    AND metadata.is_active = true
GROUP BY gap_type, severity
ORDER BY severity DESC;
```

---

## 🎯 Cas d'Usage

### Pour les humains

- **Visualiser les lacunes** : Voir quels topics/contenus manquent ou doivent être améliorés
- **Prioriser le travail** : Focus sur les gaps critiques ou haute priorité
- **Tracker la résolution** : Suivre quels gaps ont été résolus et comment

### Pour les IA/Agents IA

- **Détection automatique** : Les fonctions de détection créent automatiquement des gaps
- **Priorisation intelligente** : Les gaps sont classés par sévérité et impact
- **Enrichissement ciblé** : Les gaps guident la création de nouveaux contenus

### Pour le système

- **Amélioration continue** : Les gaps permettent d'identifier systématiquement les améliorations
- **Métriques de complétude** : Mesurer combien de gaps existent par domaine/topic
- **Détection de patterns** : Les gaps récurrents (`recurrence_count`) indiquent des problèmes systémiques

---

## 🔄 Cycle de vie d'un gap

```
1. Détection
   ↓ (automatique ou manuelle)
2. Enregistrement dans knowledge_gap
   ↓ (status: "pending")
3. Analyse et priorisation
   ↓ (status: "in_progress")
4. Résolution
   ↓ (création de contenu, amélioration, etc.)
5. Fermeture
   ↓ (status: "resolved" ou "rejected")
```

---

## 📚 Références

- **Fonctions de détection** : `function/gap_detection/README.md`
- **Table feedback** : `10_Knowledge_Feedback.md` (les feedbacks peuvent déclencher des gaps)
- **Schéma complet** : `SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


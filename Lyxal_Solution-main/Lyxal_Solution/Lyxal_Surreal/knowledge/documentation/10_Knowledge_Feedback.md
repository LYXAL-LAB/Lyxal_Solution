# 📝 Table : `knowledge_feedback`

## 🎯 Objectif

La table `knowledge_feedback` permet de collecter des retours sur les contenus de connaissance pour améliorer continuellement la qualité du système. Elle permet aux IA, aux humains et au système de remonter des feedbacks sur la pertinence, la qualité et l'utilité des contenus.

**Fondation pour v3 – Self-Learning** : Cette table est essentielle pour permettre au système d'apprendre et de s'améliorer automatiquement à partir des retours d'usage.

---

## 🧱 Structure

| Bloc | Description |
|------|-------------|
| `content` | Référence vers le contenu concerné (obligatoire) |
| `feedback_type` | Type de feedback (positive, negative, suggestion, correction) |
| `score` | Score de qualité perçu (0-1) |
| `comment` | Commentaire libre détaillant le feedback (optionnel) |
| `source.*` | Informations sur l'origine du feedback (type, identifier) |
| `metadata.*` | Métadonnées (statut actif, résolution, dates, impact) |

---

## 🔗 Relations

| Table liée | Type | Description |
|------------|------|-------------|
| `knowledge_content` | N → 1 | Un contenu peut recevoir plusieurs feedbacks |

**Comportement** : `ON DELETE CASCADE` - Si un contenu est supprimé, tous ses feedbacks sont également supprimés.

---

## 🧩 Champs principaux

### 📋 `content` - Référence vers le contenu

- **Type** : `record<knowledge_content>`
- **Contrainte** : Obligatoire, `REFERENCE ON DELETE CASCADE`
- **Rôle** : Contenu de connaissance concerné par ce feedback

---

### 🏷️ `feedback_type` - Type de feedback

- **Type** : `string`
- **Valeurs possibles** :
  - `"positive"` : Contenu utile, bien reçu
  - `"negative"` : Contenu inutile, erroné, ou mal reçu
  - `"suggestion"` : Amélioration proposée pour le contenu
  - `"correction"` : Erreur identifiée à corriger
- **Rôle** : Catégorise le type de retour pour faciliter le traitement

---

### ⭐ `score` - Score de qualité perçu

- **Type** : `number`
- **Contrainte** : 0 ≤ `score` ≤ 1, défaut : `0.5`
- **Rôle** : Score de qualité perçu par le feedback (0 = très mauvais, 1 = excellent)
- **Utilisation** : Peut être utilisé pour calculer automatiquement le `quality_score` du contenu

---

### 💬 `comment` - Commentaire libre

- **Type** : `option<string>`
- **Rôle** : Commentaire libre détaillant le feedback (optionnel)

**Exemples** :
- `"Le code d'exemple contient une erreur de syntaxe"`
- `"Cette explication m'a beaucoup aidé, merci !"`
- `"Il manque un exemple pour ce cas d'usage"`

---

### 📍 `source` - Origine du feedback

#### `source.type`
- **Type** : `string`
- **Valeurs possibles** :
  - `"human"` : Retour humain (défaut)
  - `"ai"` : Retour IA/agent IA
  - `"system"` : Retour système automatique
- **Rôle** : Identifie l'origine du feedback pour analyse

#### `source.identifier`
- **Type** : `option<string>`
- **Rôle** : Identifiant de la source (nom utilisateur, ID agent IA, etc.) - optionnel

---

### ⚙️ `metadata` - Métadonnées du feedback

#### `metadata.is_active`
- **Type** : `bool`
- **Défaut** : `true`
- **Rôle** : Le feedback est actif (peut être désactivé sans suppression)

#### `metadata.is_resolved`
- **Type** : `bool`
- **Défaut** : `false`
- **Rôle** : Le feedback a été traité/résolu (pour suggestions et corrections)

#### `metadata.resolved_at`
- **Type** : `option<datetime>`
- **Rôle** : Date et heure de résolution du feedback

#### `metadata.created_at`
- **Type** : `datetime`
- **Défaut** : `time::now()`
- **Rôle** : Date et heure de création du feedback

#### `metadata.impact_score`
- **Type** : `number`
- **Contrainte** : 0 ≤ `impact_score` ≤ 1, défaut : `0.5`
- **Rôle** : Score d'impact du feedback (0 = faible impact, 1 = impact critique). Utilisé pour prioriser les feedbacks

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_feedback_content` | `content` | Normal | Recherche rapide par contenu |
| `idx_feedback_type` | `feedback_type` | Normal | Filtrage par type de feedback |
| `idx_feedback_active` | `metadata.is_active` | Normal | Filtrage des feedbacks actifs |
| `idx_feedback_resolved` | `metadata.is_resolved` | Normal | Filtrage des feedbacks résolus/non résolus |
| `idx_feedback_created` | `metadata.created_at` | Normal | Tri chronologique |
| `idx_feedback_content_type` | `content, feedback_type` | Composite | Requêtes combinées par contenu et type |

---

## 📝 Exemples d'utilisation

### ✅ Créer un feedback positif (humain)

```surql
CREATE knowledge_feedback SET
    content = knowledge_content:define-field-basic-syntax,
    feedback_type = "positive",
    score = 0.9,
    comment = "Cette explication m'a beaucoup aidé à comprendre DEFINE FIELD !",
    source.type = "human",
    source.identifier = "user_john_doe",
    metadata.is_active = true,
    metadata.impact_score = 0.7;
```

### ✅ Créer un feedback de suggestion (IA)

```surql
CREATE knowledge_feedback SET
    content = knowledge_content:define-field-validation-examples,
    feedback_type = "suggestion",
    score = 0.6,
    comment = "Il manque un exemple pour la validation d'email avec format personnalisé",
    source.type = "ai",
    source.identifier = "agent_knowledge_reviewer_v1",
    metadata.is_active = true,
    metadata.impact_score = 0.8,
    metadata.is_resolved = false;
```

### ✅ Créer un feedback de correction (humain)

```surql
CREATE knowledge_feedback SET
    content = knowledge_content:define-field-basic-syntax,
    feedback_type = "correction",
    score = 0.3,
    comment = "Le code d'exemple contient une erreur : ASSERT $value != NONE devrait être ASSERT $value IS NOT NONE",
    source.type = "human",
    source.identifier = "user_expert_reviewer",
    metadata.is_active = true,
    metadata.impact_score = 0.9,
    metadata.is_resolved = false;
```

### ✅ Marquer un feedback comme résolu

```surql
UPDATE knowledge_feedback:feedback_id SET
    metadata.is_resolved = true,
    metadata.resolved_at = time::now()
WHERE id = knowledge_feedback:feedback_id;
```

### ✅ Récupérer tous les feedbacks non résolus pour un contenu

```surql
SELECT 
    id,
    feedback_type,
    score,
    comment,
    source,
    metadata.impact_score,
    metadata.created_at
FROM knowledge_feedback
WHERE content = knowledge_content:define-field-basic-syntax
    AND metadata.is_active = true
    AND metadata.is_resolved = false
ORDER BY metadata.impact_score DESC, metadata.created_at DESC;
```

### ✅ Récupérer les feedbacks négatifs nécessitant attention

```surql
SELECT 
    content.identity.slug AS content_slug,
    feedback_type,
    score,
    comment,
    metadata.impact_score,
    metadata.created_at
FROM knowledge_feedback
WHERE feedback_type IN ["negative", "correction"]
    AND metadata.is_active = true
    AND metadata.is_resolved = false
    AND metadata.impact_score >= 0.7
ORDER BY metadata.impact_score DESC, metadata.created_at ASC;
```

### ✅ Calculer le score moyen des feedbacks pour un contenu

```surql
SELECT 
    content,
    math::mean((SELECT VALUE score FROM knowledge_feedback WHERE knowledge_feedback.content = knowledge_content:define-field-basic-syntax AND metadata.is_active = true)) AS average_score,
    count((SELECT VALUE id FROM knowledge_feedback WHERE knowledge_feedback.content = knowledge_content:define-field-basic-syntax AND metadata.is_active = true)) AS feedback_count
FROM knowledge_content:define-field-basic-syntax;
```

---

## 🎯 Cas d'usage

### Pour les humains

- **Signaler une erreur** : Feedback `correction` avec détails de l'erreur
- **Suggérer une amélioration** : Feedback `suggestion` avec description de l'amélioration
- **Valider la qualité** : Feedback `positive` ou `negative` avec score

### Pour les IA/Agents IA

- **Détection automatique de problèmes** : Feedback `correction` ou `negative` avec score bas
- **Suggestion d'enrichissement** : Feedback `suggestion` pour contenus incomplets
- **Validation de qualité** : Feedback `positive` pour contenus bien utilisés

### Pour le système

- **Feedback système automatique** : Basé sur l'utilisation (ex: contenu jamais consulté, contenu très utilisé)
- **Calcul automatique de `quality_score`** : Agréger les scores des feedbacks pour mettre à jour `metadata.quality_score` dans `knowledge_content`

---

## 🔄 Amélioration continue

Les feedbacks peuvent être utilisés pour :

1. **Mettre à jour automatiquement `quality_score`** : Moyenne pondérée des scores de feedbacks
2. **Identifier les contenus problématiques** : Feedbacks négatifs/corrections avec impact élevé
3. **Prioriser les améliorations** : Feedbacks non résolus triés par `impact_score`
4. **Mesurer l'efficacité** : Ratio feedbacks positifs/négatifs par contenu

---

## 📚 Références

- **Table concernée** : `knowledge_content` (voir `06_Knowledge_Content.md`)
- **Schéma complet** : `SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


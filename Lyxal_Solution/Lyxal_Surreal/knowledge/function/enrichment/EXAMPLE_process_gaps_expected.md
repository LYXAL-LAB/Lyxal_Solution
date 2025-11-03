# Exemple : Comportement Attendu de `process_gaps()`

## 📋 Scénario de Test

### État Initial dans la Base

Supposons que nous ayons détecté et enregistré les gaps suivants :

```sql
-- Gap 1 : Topic sans contenu (CRITIQUE)
knowledge_gap:gap1 {
    gap_type: "missing_content",
    severity: "critical",
    topic: knowledge_topic:topic_surreal_syntax,
    domain: knowledge_domain:SURREAL_DB,
    metadata.priority: 5,
    description: "Topic 'DEFINE_FIELD' a seulement 0 contenu(s) de qualité"
}

-- Gap 2 : Topic avec peu de contenu (HAUTE PRIORITÉ)
knowledge_gap:gap2 {
    gap_type: "missing_content",
    severity: "high",
    topic: knowledge_topic:topic_surreal_queries,
    domain: knowledge_domain:SURREAL_DB,
    metadata.priority: 4,
    description: "Topic 'SELECT_QUERY' a seulement 1 contenu(s) de qualité"
}

-- Gap 3 : Contenu incomplet (MOYENNE PRIORITÉ)
knowledge_gap:gap3 {
    gap_type: "incomplete_content",
    severity: "medium",
    topic: knowledge_topic:topic_surreal_indexes,
    domain: knowledge_domain:SURREAL_DB,
    metadata.priority: 3,
    description: "Le contenu existe mais est incomplet"
}
```

---

## 🎯 Appel de la Fonction

```sql
SELECT * FROM fn::knowledge_enrich_process_gaps(
    "critical",  -- $severity_filter : seulement "critical" et "high"
    4,           -- $min_priority : priorité >= 4
    ["SYNTAX", "RULE", "EXAMPLE_CORRECT"],  -- Types de contenus à créer
    "automatic", -- Méthode de génération
    "gpt-4"      -- Modèle IA
);
```

**Filtres appliqués :**
- `severity IN ["critical", "high"]` (mais seulement ceux avec priority >= 4)
- `gap_type IN ["missing_content", "incomplete_content"]`
- `metadata.priority >= 4`

**Résultat :** Seuls `gap1` (priority 5) et `gap2` (priority 4) sont sélectionnés.

---

## ✅ Comportement Attendu

### Pour `gap1` (missing_content, critical) :
- Crée **3 propositions** (une pour chaque type) :
  1. `knowledge_content_proposal:proposal_1a` avec `content_type = SYNTAX`
  2. `knowledge_content_proposal:proposal_1b` avec `content_type = RULE`
  3. `knowledge_content_proposal:proposal_1c` avec `content_type = EXAMPLE_CORRECT`

### Pour `gap2` (missing_content, high) :
- Crée **3 propositions** :
  1. `knowledge_content_proposal:proposal_2a` avec `content_type = SYNTAX`
  2. `knowledge_content_proposal:proposal_2b` avec `content_type = RULE`
  3. `knowledge_content_proposal:proposal_2c` avec `content_type = EXAMPLE_CORRECT`

### Pour `gap3` (incomplete_content, priority 3) :
- **IGNORÉ** car `priority = 3 < 4` (filtre min_priority)

---

## 📊 Résultat Retourné

```json
{
  "success": true,
  "gaps_processed": 2,
  "proposals_created": 6,
  "proposals": [
    {
      "success": true,
      "proposal_id": "knowledge_content_proposal:proposal_1a",
      "gap_id": "knowledge_gap:gap1",
      "topic_id": "knowledge_topic:topic_surreal_syntax",
      "content_type_code": "SYNTAX",
      "slug": "surreal_syntax_SYNTAX_proposal_abc123...",
      "status": "draft"
    },
    {
      "success": true,
      "proposal_id": "knowledge_content_proposal:proposal_1b",
      "gap_id": "knowledge_gap:gap1",
      "topic_id": "knowledge_topic:topic_surreal_syntax",
      "content_type_code": "RULE",
      "slug": "surreal_syntax_RULE_proposal_def456...",
      "status": "draft"
    },
    {
      "success": true,
      "proposal_id": "knowledge_content_proposal:proposal_1c",
      "gap_id": "knowledge_gap:gap1",
      "topic_id": "knowledge_topic:topic_surreal_syntax",
      "content_type_code": "EXAMPLE_CORRECT",
      "slug": "surreal_syntax_EXAMPLE_CORRECT_proposal_ghi789...",
      "status": "draft"
    },
    {
      "success": true,
      "proposal_id": "knowledge_content_proposal:proposal_2a",
      "gap_id": "knowledge_gap:gap2",
      "topic_id": "knowledge_topic:topic_surreal_queries",
      "content_type_code": "SYNTAX",
      "slug": "surreal_queries_SYNTAX_proposal_jkl012...",
      "status": "draft"
    },
    {
      "success": true,
      "proposal_id": "knowledge_content_proposal:proposal_2b",
      "gap_id": "knowledge_gap:gap2",
      "topic_id": "knowledge_topic:topic_surreal_queries",
      "content_type_code": "RULE",
      "slug": "surreal_queries_RULE_proposal_mno345...",
      "status": "draft"
    },
    {
      "success": true,
      "proposal_id": "knowledge_content_proposal:proposal_2c",
      "gap_id": "knowledge_gap:gap2",
      "topic_id": "knowledge_topic:topic_surreal_queries",
      "content_type_code": "EXAMPLE_CORRECT",
      "slug": "surreal_queries_EXAMPLE_CORRECT_proposal_pqr678...",
      "status": "draft"
    }
  ],
  "filters": {
    "severity_filter": "critical",
    "min_priority": 4,
    "content_types": ["SYNTAX", "RULE", "EXAMPLE_CORRECT"],
    "generation_method": "automatic"
  },
  "processed_at": "2025-01-15T10:30:00Z"
}
```

---

## 🔄 Workflow Complet Automatique

```sql
-- 1. Détecter les gaps
LET $detection = SELECT * FROM fn::knowledge_gap_detect_missing_content(NONE, 3, 0.7);

-- 2. Enregistrer les gaps dans la base
FOR $gap IN $detection.gaps {
    SELECT * FROM fn::knowledge_gap_record_gap(...);
};

-- 3. 🎯 TRAITER AUTOMATIQUEMENT : Créer toutes les propositions
-- Cette étape doit être AUTOMATIQUE et créer les propositions directement
LET $result = SELECT * FROM fn::knowledge_enrich_process_gaps(
    "critical",
    4,
    ["SYNTAX", "RULE", "EXAMPLE_CORRECT"],
    "automatic",
    "gpt-4"
);

-- ✅ Résultat : 6 nouvelles propositions créées dans knowledge_content_proposal
-- ✅ Toutes en statut "draft", prêtes pour génération du contenu complet par IA
-- ✅ Les propositions sont liées aux gaps via le champ `gap`
```

---

## 📝 Ce qui doit se passer techniquement

Pour chaque gap sélectionné :

1. **Si `gap_type = "missing_content"`** :
   - Pour chaque type dans `["SYNTAX", "RULE", "EXAMPLE_CORRECT"]` :
     - Appeler `fn::knowledge_enrich_propose_content(gap.id, type, ...)`
     - Collecter le résultat dans le tableau `$proposals`

2. **Si `gap_type = "incomplete_content"`** :
   - Appeler une seule fois `fn::knowledge_enrich_propose_content(gap.id, "SYNTAX", ...)`
   - Collecter le résultat dans le tableau `$proposals`

3. **Retourner** :
   - Le nombre de gaps traités
   - Le nombre de propositions créées
   - La liste complète des propositions créées

---

## ❌ Problème Actuel

**Version simplifiée actuelle :**
- ❌ Ne crée AUCUNE proposition
- ✅ Liste seulement les gaps à traiter
- ❌ Nécessite une itération manuelle côté client

**Version avec FOR (tentative échouée) :**
- ❌ Syntaxe invalide : SurrealDB ne permet pas `FOR` dans `SELECT FROM`
- ❌ Erreur de compilation

---

## ✅ Solution Requise

Une fonction qui **crée réellement** toutes les propositions dans la base de données en une seule exécution, sans nécessiter d'itération côté client.


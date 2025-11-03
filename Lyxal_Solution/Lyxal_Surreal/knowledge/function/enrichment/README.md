# 🔄 Fonctions d'Enrichissement Automatique – Knowledge System

Ce dossier contient les **fonctions SurrealDB** pour l'enrichissement automatique du système de connaissance à partir des gaps détectés.

## 🎯 Objectif

Fournir des fonctions pour :
- ✅ Proposer automatiquement de nouveaux contenus basés sur les gaps détectés
- ✅ Générer des propositions de contenus structurés (structure U3-FLEX)
- ✅ Gérer le workflow de révision et d'approbation
- ✅ Transformer les propositions approuvées en contenus réels
- ✅ Traiter automatiquement les gaps critiques/haute priorité

## 📋 Fonctions Disponibles

### 1. `fn::knowledge_enrich_propose_content()`

Propose un nouveau contenu basé sur un gap détecté.

**Paramètres** :
- `$gap_id` : ID du gap détecté (record<knowledge_gap>)
- `$content_type_code` : Code du type de contenu à proposer (ex: "SYNTAX", "RULE")
- `$generation_method` : Méthode de génération ("automatic", "manual", "ai_assisted")
- `$generation_model` : Modèle IA utilisé (optionnel)
- `$confidence` : Niveau de confiance (0-1)
- `$priority` : Priorité de la proposition (int)

**Retourne** :
```json
{
  "success": true,
  "proposal_id": "knowledge_content_proposal:proposal_xyz",
  "gap_id": "knowledge_gap:gap_xyz",
  "topic_id": "knowledge_topic:topic_xyz",
  "content_type_code": "SYNTAX",
  "slug": "topic_slug_SYNTAX_proposal_2025-01-...",
  "status": "draft"
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_enrich_propose_content(
    knowledge_gap:gap_xyz,
    "SYNTAX",
    "automatic",
    "gpt-4",
    0.8,
    5
);
```

---

### 2. `fn::knowledge_enrich_approve_proposal()`

Approuve une proposition et la transforme en contenu réel dans `knowledge_content`.

**Paramètres** :
- `$proposal_id` : ID de la proposition à approuver (record<knowledge_content_proposal>)
- `$approved_by` : Identifiant de la personne/IA qui approuve (string)
- `$review_notes` : Notes de révision (optionnel)
- `$quality_score` : Score de qualité final (optionnel, utilise celui de la proposition par défaut)

**Retourne** :
```json
{
  "success": true,
  "proposal_id": "knowledge_content_proposal:proposal_xyz",
  "content_id": "knowledge_content:content_xyz",
  "gap_id": "knowledge_gap:gap_xyz",
  "gap_resolved": true,
  "status": "merged"
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_enrich_approve_proposal(
    knowledge_content_proposal:proposal_xyz,
    "user_expert",
    "Proposition approuvée après révision",
    0.85
);
```

---

### 3. `fn::knowledge_enrich_process_gaps()`

Traite automatiquement les gaps critiques/haute priorité pour générer des propositions.

**Paramètres** :
- `$severity_filter` : Filtrer par sévérité (optionnel, ex: "critical", "high")
- `$min_priority` : Priorité minimum (int, défaut: 0)
- `$content_types` : Types de contenus à générer (optionnel, array<string>)
- `$generation_method` : Méthode de génération ("automatic", "manual", "ai_assisted")
- `$generation_model` : Modèle IA utilisé (optionnel)

**Retourne** :
```json
{
  "success": true,
  "gaps_processed": 5,
  "proposals_created": 12,
  "proposals": [...],
  "filters": {...},
  "processed_at": "..."
}
```

**Exemple** :
```sql
-- Traiter les gaps critiques automatiquement
SELECT * FROM fn::knowledge_enrich_process_gaps(
    "critical",
    4,
    ["SYNTAX", "RULE", "EXAMPLE_CORRECT"],
    "automatic",
    "gpt-4"
);
```

---

## 🔄 Workflow Complet

### Workflow automatique d'enrichissement

```sql
-- 1. Détecter les gaps
LET $gaps = SELECT * FROM fn::knowledge_gap_detect_missing_content(NONE, 3, 0.7);

-- 2. Enregistrer les gaps détectés
FOR $gap IN $gaps.gaps {
    SELECT * FROM fn::knowledge_gap_record_gap(...);
};

-- 3. Traiter automatiquement les gaps critiques pour créer des propositions
LET $processing = SELECT * FROM fn::knowledge_enrich_process_gaps(
    "critical",
    4,
    ["SYNTAX", "RULE", "EXAMPLE_CORRECT"],
    "automatic",
    "gpt-4"
);

-- 4. Les propositions sont maintenant en statut "draft" et attendent génération du contenu complet
-- (La génération du contenu complet nécessite une intégration externe avec une IA)

-- 5. Après génération et révision, approuver une proposition
SELECT * FROM fn::knowledge_enrich_approve_proposal(
    knowledge_content_proposal:proposal_xyz,
    "user_expert",
    "Contenu généré et validé",
    0.85
);
```

---

## 📊 États des Propositions

| État | Description | Action possible |
|------|-------------|-----------------|
| `draft` | Brouillon initial créé | Générer le contenu complet, passer à `pending_review` |
| `pending_review` | En attente de révision humaine | Approuver (`approved`) ou rejeter (`rejected`) |
| `approved` | Approuvé mais pas encore mergé | Merger dans `knowledge_content` (statut devient `merged`) |
| `rejected` | Rejeté | Peut être corrigé et resoumis, ou supprimé |
| `merged` | Fusionné dans `knowledge_content` | Final - ne peut plus être modifié |

---

## 🎯 Cas d'Usage

### Enrichissement automatique périodique

Exécuter ce workflow périodiquement :
- **Quotidien** : Traiter les gaps critiques détectés
- **Hebdomadaire** : Traiter tous les gaps haute priorité
- **Mensuel** : Analyse complète et enrichissement systématique

### Workflow avec intégration IA

1. **Détection automatique** : Les gaps sont détectés automatiquement
2. **Création de propositions** : `process_gaps()` crée les propositions (structure vide)
3. **Génération IA externe** : Un système externe (IA) remplit les champs de la proposition
4. **Révision humaine** : Un expert révisionne et approuve/rejette
5. **Merging automatique** : `approve_proposal()` transforme en contenu réel

---

## 📚 Références

- **Table propositions** : `knowledge/documentation/12_Knowledge_Content_Proposal.md` (à créer)
- **Table gaps** : `knowledge/documentation/11_Knowledge_Gap.md`
- **Fonctions gaps** : `function/gap_detection/README.md`
- **Schéma complet** : `knowledge/documentation/SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


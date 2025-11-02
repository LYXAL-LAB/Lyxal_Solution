# 🔄 Data Flow – Cycle de Vie de la Connaissance

## 🎯 Objectif

Ce document explique **le flux de données complet** du Knowledge System :  
de la création initiale d’un savoir, jusqu’à son utilisation et amélioration continue par l’IA et les utilisateurs.

Il décrit comment l’information entre dans le système, comment elle circule, comment elle est enrichie, et comment elle est exploitée.

---

## 🧬 Les 5 Phases du Cycle de Vie

Le Knowledge System fonctionne selon un cycle continu :

| Phase | Nom | Description |
|--------|--------|----------------|
| 01 | Création | Ajout d’un nouveau savoir structuré |
| 02 | Enrichissement | Ajout de mots-clés, types, i18n, metadata, tags |
| 03 | Consommation | UI, IA, RAG, recherche, documentation |
| 04 | Feedback | Notes, améliorations, statistiques d’usage |
| 05 | Amélioration | Mise à jour, versioning, enrichissement IA |

---

## 1️⃣ Création de Connaissance

### Entrées possibles

| Source | Exemple |
|--------|-------------|
| Expert Lyxal | Ajout d’un nouveau sujet SurrealDB |
| IA Assistée | Génération automatique de premiers contenus |
| Import externe | Documentation officielle, ressources web |

### Tables impliquées

- `knowledge_domain`
- `knowledge_topic`
- `knowledge_content`
- `knowledge_content_type`

### But

Créer un premier niveau de savoir **valable, structuré, minimal**.

---

## 2️⃣ Enrichissement Sémantique

Une fois la base posée, on ajoute la sémantique pour :

✅ améliorer la recherche  
✅ orienter l’IA  
✅ permettre l’auto-amélioration  

### Éléments enrichis

| Enrichissement | Tables impliquées |
|----------------|------------------------|
| Mots-clés globaux | `knowledge_keyword`, relations |
| Tags | `knowledge_tag` + fields tags |
| I18n | Clés liées au domaine/topic/content |
| Metadata IA | Poids, priorité, niveau, use cases |

### Exemple

```sql
RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->knowledge_keyword:ASSERT;

3️⃣ Consommation de Connaissance

La donnée est utilisée par :

Consommation	Exemple
UI Humaine	Interface Learn, Documentation
IA interne	Génération de contenu Surreal, auto-correction
RAG	Indexation sémantique
UI Studio	Assistants intelligents
Accès par niveaux
acteur	niveau d’accès
Débutant	Domain → Topic → Exemple simple
Avancé	Tous types + règles + anti-patterns
IA	Requêtes complexes + scoring + keywords
4️⃣ Feedback & Qualité

Le système permet de mesurer et améliorer la qualité du savoir.

Mécanisme	Exemple
Score IA	Notation de la qualité du contenu
Popularité	Contenu le plus consulté
Retours utilisateurs	Votes, signalements
Auto-évaluation IA	Correction et amélioration continue

Les champs metadata.ai permettent à l’IA de savoir quand utiliser un contenu.

5️⃣ Amélioration & Versioning

Une connaissance peut être :

mise à jour

éclatée en plusieurs contenus

remplacée par une version supérieure

désactivée puis archivée

Méthodes
Méthode	Usage
metadata.is_active = false	Archive douce
version_label	Suivi de version métier
Versioning natif SurrealDB (plus tard)	Time travel
🔁 Flow Résumé

Expert/IA → (1) Création
                ↓
            (2) Enrichissement
                ↓
            (3) Consommation (UI/IA)
                ↓
            (4) Feedback & Score
                ↓
            (5) Amélioration / Version
                ↓
                ↺ (Retour phase 2 ou 3)

Le système s’auto-renforce : plus il est utilisé, plus il devient intelligent.

🚀 Résultat attendu

Ce Data Flow garantit :

un cycle constant d’amélioration

une qualité de plus en plus élevée

un impact direct sur les performances IA

une documentation vivante et auto-apprenante

La connaissance ne stagne pas — elle évolue avec Lyxal.
# 🔄 Data Flow – Cycle de Vie de la Connaissance

## 🎯 Objectif

Ce document explique **le flux de données complet** du Knowledge System :  
de la création initiale d'un savoir, jusqu'à son utilisation et amélioration continue par l'IA et les utilisateurs.

Il décrit comment l'information entre dans le système, comment elle circule, comment elle est enrichie, et comment elle est exploitée.

---

## 🧬 Les 5 Phases du Cycle de Vie

Le Knowledge System fonctionne selon un cycle continu :

| Phase | Nom | Description | Tables principales |
|-------|--------|----------------|-------------------|
| 01 | Création | Ajout d'un nouveau savoir structuré | `knowledge_domain`, `knowledge_topic`, `knowledge_content` |
| 02 | Enrichissement | Ajout de mots-clés, types, i18n, metadata, tags | `knowledge_keyword`, relations, `i18n_key`, `tag` |
| 03 | Consommation | UI, IA, RAG, recherche, documentation | Toutes (lecture) |
| 04 | Feedback | Notes, améliorations, statistiques d'usage | `metadata.*` (futur : `knowledge_feedback`) |
| 05 | Amélioration | Mise à jour, versioning, enrichissement IA | Toutes (update) |

---

## 1️⃣ Création de Connaissance

### Entrées possibles

| Source | Exemple | Fréquence |
|--------|-------------|-----------|
| Expert Lyxal | Ajout d'un nouveau sujet SurrealDB | Initiale |
| IA Assistée | Génération automatique de premiers contenus | Continue |
| Import externe | Documentation officielle, ressources web | Ponctuelle |

### Ordre de création (dépendances)

1. **Domain** (si nouveau)
   ```sql
   CREATE knowledge_domain:SURREAL_DB SET
       identity.code = "SURREAL_DB",
       identity.slug = "surreal-db",
       identity.label_key = i18n_key:kd_surreal_db_label,
       ...
   ```

2. **Category** (si nouvelle)
   ```sql
   CREATE knowledge_category:DATA_DEFINITION SET
       identity.code = "DATA_DEFINITION",
       identity.slug = "data-definition",
       ...
   ```

3. **Topic**
   ```sql
   CREATE knowledge_topic:DEFINE_FIELD SET
       domain = knowledge_domain:SURREAL_DB,
       category = knowledge_category:DATA_DEFINITION,
       identity.code = "DEFINE_FIELD",
       ...
   ```

4. **Content** (multiples par topic)
   ```sql
   CREATE knowledge_content SET
       topic = knowledge_topic:DEFINE_FIELD,
       identity.content_type = knowledge_content_type:SYNTAX,
       content.text_key = i18n_key:content_syntax_text,
       ...
   ```

### Tables impliquées

- `knowledge_domain` (si nouveau)
- `knowledge_category` / `knowledge_sub_category` (si nouvelles)
- `knowledge_topic`
- `knowledge_content`
- `knowledge_content_type` (référentiel existant)
- `i18n_key` (pour tous les textes traduisibles)

### But

Créer un premier niveau de savoir **valable, structuré, minimal**.

> 📚 **Voir** : `17_Knowledge_Creation_Patterns.md` pour le guide complet

---

## 2️⃣ Enrichissement Sémantique

Une fois la base posée, on ajoute la sémantique pour :

✅ améliorer la recherche  
✅ orienter l'IA  
✅ permettre l'auto-amélioration  

### Éléments enrichis

| Enrichissement | Tables impliquées | Exemple |
|----------------|------------------------|---------|
| **Mots-clés globaux** | `knowledge_keyword`, `knowledge_domain_keyword`, `knowledge_topic_keyword` | `"database"`, `"schema"`, `"validation"` |
| **Tags structurés** | `tag` (référentiel global) | `tag:surreal`, `tag:technical` |
| **I18n** | `i18n_key` | Clés liées au domaine/topic/content |
| **Metadata IA** | `metadata.ai.*` dans `knowledge_content_type` et `knowledge_content` | Priorité, poids, niveau, use cases |

### Workflow d'enrichissement

#### 1. Créer/récupérer les keywords

```sql
-- Créer un nouveau keyword
CREATE knowledge_keyword:validation SET
    identity.value = "validation",
    identity.slug = "validation",
    metadata.is_active = true;

-- OU récupérer un keyword existant
SELECT VALUE id FROM knowledge_keyword 
WHERE identity.value = "validation" LIMIT 1;
```

#### 2. Lier les keywords aux entités

```sql
-- Lier au domain
RELATE knowledge_domain:SURREAL_DB 
    ->knowledge_domain_keyword->knowledge_keyword:validation;

-- Lier au topic
RELATE knowledge_topic:DEFINE_FIELD 
    ->knowledge_topic_keyword->knowledge_keyword:validation;
```

#### 3. Ajouter les tags

```sql
UPDATE knowledge_topic:DEFINE_FIELD SET
    tags = [tag:surreal, tag:technical, tag:schema];
```

#### 4. Enrichir les métadonnées IA

```sql
UPDATE knowledge_content SET
    metadata.priority = 2,
    metadata.is_active = true
WHERE topic = knowledge_topic:DEFINE_FIELD 
    AND identity.content_type = knowledge_content_type:SYNTAX;
```

### Résultat

Le contenu devient **recherchable**, **trouvable par IA**, et **exploitable** pour RAG.

---

## 3️⃣ Consommation de Connaissance

La donnée est utilisée par différents acteurs avec différents besoins.

### Acteurs et leurs besoins

| Acteur | Besoin | Exemples de requêtes |
|--------|--------|---------------------|
| **UI Humaine** | Affichage organisé | Domain → Topic → Content |
| **IA interne** | Génération de code | Recherche par keywords + filtrage par type |
| **RAG** | Indexation sémantique | Recherche full-text sur keywords |
| **UI Studio** | Assistants intelligents | Requêtes complexes avec scoring |

### Accès par niveaux

| Niveau | Accès | Exemple |
|--------|-------|---------|
| **Débutant** | Domain → Topic → Exemple simple | Types `SYNTAX`, `EXAMPLE_CORRECT`, `TIP` |
| **Intermédiaire** | Tous types + règles | Types `RULE`, `EXAMPLE_INCORRECT`, `EXPLANATION` |
| **Avancé** | Patterns complexes | Type `PATTERN` |
| **IA** | Requêtes complexes + scoring + keywords | Tous types avec `metadata.ai.priority >= 4` |

### Exemples de requêtes de consommation

#### Requête simple (UI)
```sql
SELECT * FROM knowledge_content
WHERE topic = knowledge_topic:DEFINE_FIELD
    AND metadata.is_active = true
ORDER BY metadata.priority DESC;
```

#### Requête IA (avec keywords)
```sql
SELECT * FROM knowledge_content
WHERE topic IN (
    SELECT VALUE ->knowledge_topic_keyword->knowledge_keyword
    FROM knowledge_keyword
    WHERE identity.value @1@ "validation"
)
AND identity.content_type = knowledge_content_type:SYNTAX
AND metadata.is_active = true
ORDER BY metadata.priority DESC;
```

#### Requête RAG (full-text)
```sql
SELECT * FROM knowledge_content
WHERE topic IN (
    SELECT VALUE <-knowledge_topic_keyword<-knowledge_topic
    FROM knowledge_keyword
    WHERE identity.value @1@ "database"
)
AND metadata.is_active = true;
```

---

## 4️⃣ Feedback & Qualité

Le système permet de mesurer et améliorer la qualité du savoir.

### Mécanismes actuels

| Mécanisme | Table/Champ | Exemple |
|-----------|------------|---------|
| **Score IA** | `metadata.ai.min_quality_score` | Score minimal requis pour usage IA |
| **Priorité** | `metadata.priority` | Ordre d'affichage |
| **Usage count** | `knowledge_keyword.metadata.usage_count` | Nombre d'utilisations d'un keyword |
| **Activation** | `metadata.is_active` | Archive douce |

### Mécanismes futurs (Phase v3)

| Mécanisme | Table future | Description |
|-----------|--------------|-------------|
| **Feedback utilisateur** | `knowledge_feedback` | Votes, commentaires |
| **Popularité** | Analytics | Contenu le plus consulté |
| **Auto-évaluation IA** | `metadata.ai.quality_score` | Score de qualité calculé par IA |

### Les champs `metadata.ai` permettent à l'IA de savoir quand utiliser un contenu

```sql
-- Récupérer uniquement les contenus adaptés pour IA
SELECT * FROM knowledge_content
WHERE metadata.ai.priority >= 4
    AND metadata.ai.min_quality_score >= 0.6
    AND metadata.is_active = true
ORDER BY metadata.ai.weight DESC;
```

---

## 5️⃣ Amélioration & Versioning

Une connaissance peut être :

- ✅ **mise à jour** (modification de contenu)
- ✅ **éclatée** (division en plusieurs contenus)
- ✅ **remplacée** (version supérieure)
- ✅ **désactivée** puis archivée (`metadata.is_active = false`)

### Méthodes de versioning

| Méthode | Usage | Exemple |
|---------|-------|---------|
| `metadata.is_active = false` | Archive douce | Garde l'historique sans afficher |
| `metadata.version_label` | Suivi de version métier | "1.0.0" → "1.1.0" → "2.0.0" |
| Versioning natif SurrealDB (futur) | Time travel | Historique complet avec `VERSION` |

### Exemple de mise à jour

```sql
-- Désactiver l'ancienne version
UPDATE knowledge_content SET
    metadata.is_active = false
WHERE identity.slug = "define-field-old-syntax";

-- Créer la nouvelle version
CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define-field-new-syntax",
    identity.content_type = knowledge_content_type:SYNTAX,
    metadata.version_label = "2.0.0",
    metadata.is_active = true;
```

---

## 🔁 Flow Résumé

```
Expert/IA → (1) Création
                ↓
            (2) Enrichissement (keywords, tags, i18n)
                ↓
            (3) Consommation (UI/IA/RAG)
                ↓
            (4) Feedback & Score
                ↓
            (5) Amélioration / Version
                ↓
                ↺ (Retour phase 2 ou 3)
```

Le système s'auto-renforce : plus il est utilisé, plus il devient intelligent.

---

## 📊 Métriques du Cycle

### Métriques de création

- Nombre de domains créés
- Nombre de topics créés par domain
- Nombre de contenus par topic
- Temps moyen de création

### Métriques d'enrichissement

- Nombre de keywords par entité
- Taux de réutilisation des keywords
- Couverture i18n (nombre de langues)
- Taux de tags par entité

### Métriques de consommation

- Requêtes par type d'acteur
- Contenus les plus consultés
- Keywords les plus recherchés
- Types de contenus les plus utilisés

### Métriques d'amélioration

- Taux de mise à jour
- Temps moyen entre versions
- Taux de désactivation

---

## 🚀 Résultat attendu

Ce Data Flow garantit :

- ✅ un cycle constant d'amélioration
- ✅ une qualité de plus en plus élevée
- ✅ un impact direct sur les performances IA
- ✅ une documentation vivante et auto-apprenante

La connaissance ne stagne pas — elle évolue avec Lyxal.

---

## 📚 Références

- **Guide de création** : `17_Knowledge_Creation_Patterns.md`
- **Guide keywords** : `08_Knowledge_Keyword.md`
- **Modèle de données** : `10_Knowledge_Data_Model.md`
- **Schéma de référence** : `SCHEMA_Knowledge_System.md`

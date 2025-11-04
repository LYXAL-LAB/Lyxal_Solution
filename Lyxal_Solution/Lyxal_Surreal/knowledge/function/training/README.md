# 🎓 Fonctions d'Export pour Entraînement IA – Knowledge System

Ce dossier contient les **fonctions SurrealDB** pour exporter les contenus de connaissance au format structuré pour l'entraînement de modèles IA spécialisés.

## 🎯 Objectif

Fournir des fonctions pour :
- ✅ Exporter les contenus d'un domaine pour fine-tuning
- ✅ Filtrer par qualité et métadonnées d'entraînement
- ✅ Générer des datasets structurés au format JSONL-ready
- ✅ Appliquer la pondération des contenus selon leur importance

## 📋 Fonctions Disponibles

### 1. `fn::knowledge_export_domain_for_training()`

Exporte les contenus d'un domaine pour entraînement IA au format structuré (JSONL-ready).

**Paramètres** :
- `$domain_code` : Code du domaine (ex: `"SURREAL_DB"`)
- `$min_quality_score` : Score de qualité minimum (optionnel, défaut: `0.7`)
- `$dataset_version` : Version du dataset (optionnel, ex: `"v1.0"`)
- `$include_only_marked` : Inclure uniquement les contenus marqués `included_in_training = true` (optionnel, défaut: `false`)

**Retourne** :
```json
{
  "success": true,
  "stats": {
    "domain_code": "SURREAL_DB",
    "dataset_version": "v1.0",
    "min_quality_score": 0.7,
    "include_only_marked": false,
    "total_contents_found": 150,
    "total_items_exported": 150,
    "exported_at": "2025-01-15T10:30:00Z",
    "avg_quality_score": 0.82,
    "avg_training_weight": 1.15
  },
  "data": [
    {
      "id": "knowledge_content:content_slug",
      "slug": "content_slug",
      "domain": {
        "code": "SURREAL_DB",
        "slug": "surreal-db"
      },
      "topic": {
        "code": "DEFINE_FIELD",
        "slug": "define-field",
        "label_key": "i18n_key:topic_define_field_label"
      },
      "content_type": {
        "code": "SYNTAX",
        "label_key": "i18n_key:content_type_syntax_label"
      },
      "title_key": "i18n_key:content_title",
      "description_key": "i18n_key:content_description",
      "content": {
        "text_key": "i18n_key:content_text",
        "code": [...],
        "prompt": "...",
        "json": {...},
        "context_key": "i18n_key:context",
        "examples": {...},
        "media": [...]
      },
      "tags": [...],
      "metadata": {
        "priority": 1,
        "version_label": "1.0.0",
        "quality_score": 0.9,
        "training_weight": 1.5,
        "training_versions": ["v1.0"],
        "analytics": {
          "view_count": 500,
          "ai_usage_count": 300
        }
      },
      "dataset_version": "v1.0",
      "exported_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

**Exemple** :
```sql
-- Export complet du domaine SurrealDB avec qualité minimale 0.7
SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.7, "v1.0", false);

-- Export uniquement des contenus marqués pour entraînement
SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.8, "v1.1", true);

-- Export avec qualité minimale très élevée
SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.9, NONE, false);
```

**Utilisation** :
- Export de datasets pour fine-tuning de modèles IA
- Génération de datasets versionnés pour tracking
- Sélection de contenus de haute qualité pour entraînement

---

## 📝 Conversion en JSONL

La fonction retourne un tableau de données structurées. Pour convertir en format JSONL (JSON Lines), vous pouvez utiliser un script externe :

### Exemple JavaScript/Node.js

```javascript
const result = await db.query(`
  SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.7, "v1.0", false)
`);

const exportResult = result[0].result[0];
const jsonlLines = exportResult.data.map(item => JSON.stringify(item)).join('\n');

// Sauvegarder dans un fichier
const fs = require('fs');
fs.writeFileSync('dataset_v1.0.jsonl', jsonlLines);
```

### Exemple Python

```python
import json

result = db.query("""
  SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.7, "v1.0", false)
""")

export_result = result[0]["result"][0]
jsonl_lines = [json.dumps(item) for item in export_result["data"]]

# Sauvegarder dans un fichier
with open("dataset_v1.0.jsonl", "w") as f:
    f.write("\n".join(jsonl_lines))
```

---

## 🎯 Filtrage et Pondération

### Filtrage par qualité

La fonction filtre automatiquement les contenus selon :
- `metadata.quality_score >= $min_quality_score` (défaut: 0.7)
- `metadata.is_active = true` (toujours requis)

### Pondération des contenus

Les contenus sont ordonnés par :
1. `metadata.training.training_weight` (DESC) - Priorité aux contenus avec poids élevé
2. `metadata.quality_score` (DESC) - Ensuite par qualité

**Poids d'entraînement** :
- `1.0` = Poids normal (contenu standard)
- `1.5` = Poids élevé (contenu important)
- `2.0` = Double poids (contenu critique)
- `0.5` = Demi-poids (contenu secondaire)

> 💡 **Note** : La duplication des contenus selon leur poids peut être gérée côté client lors de la génération du dataset final.

---

## 📊 Format de Données

### Structure du dataset

Chaque ligne JSONL contient :
- **Identifiants** : `id`, `slug`, `domain`, `topic`, `content_type`
- **Contenu** : `content` (text_key, code, prompt, json, examples, media)
- **Métadonnées** : `metadata` (quality_score, training_weight, analytics)
- **Versioning** : `dataset_version`, `exported_at`

### Métadonnées incluses

- `quality_score` : Score de qualité (0-1)
- `training_weight` : Poids d'entraînement (0-2)
- `training_versions` : Versions de datasets précédents
- `analytics` : Métriques d'usage (view_count, ai_usage_count)

---

## 🔄 Workflow d'Export

### 1. Préparer les contenus

```sql
-- Marquer les contenus pour inclusion dans les datasets
UPDATE knowledge_content SET
    metadata.training.included_in_training = true,
    metadata.training.training_weight = 1.5
WHERE topic.domain->identity.code = "SURREAL_DB"
    AND metadata.quality_score >= 0.8
    AND metadata.is_active = true;
```

### 2. Exporter le dataset

```sql
-- Générer l'export
SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.7, "v1.0", true);
```

### 3. Mettre à jour les métadonnées

```sql
-- Enregistrer que les contenus ont été utilisés dans cette version
UPDATE knowledge_content SET
    metadata.training.training_versions = array::append(metadata.training.training_versions, "v1.0"),
    metadata.training.last_training_date = time::now()
WHERE topic.domain->identity.code = "SURREAL_DB"
    AND metadata.training.included_in_training = true
    AND metadata.quality_score >= 0.7;
```

---

## 📈 Statistiques d'Export

La fonction retourne des statistiques détaillées :

- `total_contents_found` : Nombre de contenus éligibles
- `total_items_exported` : Nombre d'items dans le dataset
- `avg_quality_score` : Qualité moyenne des contenus exportés
- `avg_training_weight` : Poids moyen d'entraînement

Ces statistiques permettent de :
- Valider la qualité du dataset généré
- Analyser la distribution des contenus
- Optimiser les critères de filtrage

---

## 🎯 Cas d'Usage

### Export pour fine-tuning initial

```sql
-- Premier export avec qualité minimale élevée
SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.9, "v1.0", false);
```

### Export incrémental

```sql
-- Exporter uniquement les nouveaux contenus marqués
SELECT * FROM fn::knowledge_export_domain_for_training("SURREAL_DB", 0.7, "v1.1", true);
```

### Export pour domaine spécifique

```sql
-- Exporter un domaine entier pour entraînement spécialisé
SELECT * FROM fn::knowledge_export_domain_for_training("BUSINESS", 0.8, "business_v1.0", false);
```

---

## 🎯 Avantages

1. **Format structuré** : Données prêtes pour conversion JSONL
2. **Filtrage intelligent** : Qualité et métadonnées d'entraînement
3. **Pondération** : Support des poids d'entraînement
4. **Versioning** : Tracking des versions de datasets
5. **Statistiques** : Métriques détaillées pour validation

---

## 📚 Références

- **Métadonnées d'entraînement** : `knowledge/documentation/06_Knowledge_Content.md` (section `metadata.training`)
- **Fonctions analytics** : `function/analytics/README.md`
- **Schéma complet** : `knowledge/documentation/SCHEMA_Knowledge_System.md`

---

## 🔄 Pipeline d'Export Automatique

### Fonctions de gestion des exports

Le système inclut des fonctions pour gérer le pipeline d'export automatique :

#### 1. `fn::knowledge_export_create_dataset()`

Crée un export de dataset avec versioning automatique et tracking complet.

**Paramètres** :
- `$domain_code` : Code du domaine (ex: `"SURREAL_DB"`)
- `$min_quality_score` : Score de qualité minimum (optionnel, défaut: `0.7`)
- `$export_type` : Type d'export (optionnel, défaut: `"manual"`) - `"manual"`, `"scheduled"`, `"automatic"`, `"triggered"`
- `$created_by` : Identifiant créateur (optionnel)
- `$description` : Description de l'export (optionnel)
- `$auto_version` : Génération automatique de version (optionnel, défaut: `true`)

**Retourne** :
```json
{
  "success": true,
  "export_record": {...},
  "export_stats": {...},
  "version": "v1.0",
  "dataset_name": "SURREAL_DB_v1.0"
}
```

**Exemple** :
```sql
-- Créer un export avec versioning automatique
SELECT * FROM fn::knowledge_export_create_dataset("SURREAL_DB", 0.7, "manual", "user_123", "Export initial", true);

-- Créer un export planifié
SELECT * FROM fn::knowledge_export_create_dataset("SURREAL_DB", 0.8, "scheduled", "system", "Export hebdomadaire", true);
```

#### 2. `fn::knowledge_export_list_datasets()`

Liste les exports de datasets avec filtres optionnels.

**Paramètres** :
- `$domain_code` : Filtrer par domaine (optionnel)
- `$active_only` : Uniquement les exports actifs (optionnel, défaut: `true`)
- `$limit` : Nombre maximum de résultats (optionnel, défaut: `50`)

**Exemple** :
```sql
-- Lister tous les exports d'un domaine
SELECT * FROM fn::knowledge_export_list_datasets("SURREAL_DB", true, 20);

-- Lister tous les exports (tous domaines)
SELECT * FROM fn::knowledge_export_list_datasets(NONE, true, 100);
```

#### 3. `fn::knowledge_export_auto_version()`

Génère automatiquement la prochaine version pour un domaine.

**Paramètres** :
- `$domain_code` : Code du domaine

**Exemple** :
```sql
-- Obtenir la prochaine version
SELECT * FROM fn::knowledge_export_auto_version("SURREAL_DB");
-- Retourne: { "next_version": "v1.1", "current_version": "v1.0", ... }
```

---

## 📋 Table de Tracking : `knowledge_dataset_export`

La table `knowledge_dataset_export` permet de tracker tous les exports avec :

- **Identité** : version, nom, description
- **Export** : paramètres et statistiques (qualité, nombre d'items)
- **Provenance** : créateur, type d'export, chemin fichier, hash
- **Métadonnées** : dates, statut actif, expiration, notes

**Avantages** :
- 📊 Historique complet des exports
- 🔍 Traçabilité de provenance
- 📈 Suivi des versions de datasets
- 🗂️ Gestion de fichiers et intégrité (hash)

---

## 🤖 Scripts d'Automatisation

### Export périodique (cron/scheduled task)

```javascript
// Script Node.js pour export automatique hebdomadaire
const Surreal = require('surrealdb');

async function scheduledExport() {
  const db = new Surreal();
  await db.connect('wss://...');
  await db.signin({ username: 'admin', password: 'admin' });
  await db.use({ namespace: 'Lyxal_Solution', database: 'Developpement' });

  // Créer l'export avec versioning automatique
  const result = await db.query(`
    SELECT * FROM fn::knowledge_export_create_dataset(
      "SURREAL_DB",
      0.7,
      "scheduled",
      "automation_system",
      "Export hebdomadaire automatique",
      true
    )
  `);

  const exportData = result[0].result[0];
  
  if (exportData.success) {
    // Générer le fichier JSONL
    const exportResult = await db.query(`
      SELECT * FROM fn::knowledge_export_domain_for_training(
        "SURREAL_DB",
        0.7,
        "${exportData.version}",
        false
      )
    `);
    
    const fs = require('fs');
    const jsonl = exportResult[0].result[0].data
      .map(item => JSON.stringify(item))
      .join('\n');
    
    const filename = `dataset_${exportData.version}_${Date.now()}.jsonl`;
    fs.writeFileSync(filename, jsonl);
    
    // Mettre à jour le chemin du fichier dans l'export
    await db.query(`
      UPDATE ${exportData.export_record.id} SET
        provenance.file_path = "${filename}",
        provenance.file_size_bytes = ${Buffer.byteLength(jsonl, 'utf8')}
    `);
    
    console.log(`Export créé: ${exportData.version} - ${filename}`);
  }
}

// Exécuter tous les dimanches à 2h du matin
// (utiliser cron ou scheduler système)
```

### Export déclenché par événement

```javascript
// Export automatique quand nouveau contenu de haute qualité est ajouté
async function onNewHighQualityContent(contentId) {
  const db = new Surreal();
  // ... connexion ...
  
  // Vérifier si on doit déclencher un export
  const highQualityCount = await db.query(`
    SELECT VALUE count()
    FROM knowledge_content
    WHERE topic.domain->identity.code = "SURREAL_DB"
      AND metadata.is_active = true
      AND metadata.quality_score >= 0.8
      AND metadata.training.included_in_training = true
  `);
  
  // Si plus de 10 nouveaux contenus de haute qualité, créer export
  if (highQualityCount[0].result[0] > 10) {
    await db.query(`
      SELECT * FROM fn::knowledge_export_create_dataset(
        "SURREAL_DB",
        0.8,
        "triggered",
        "system",
        "Export déclenché: nouveau contenu haute qualité",
        true
      )
    `);
  }
}
```

---

**Dernière mise à jour** : 2025


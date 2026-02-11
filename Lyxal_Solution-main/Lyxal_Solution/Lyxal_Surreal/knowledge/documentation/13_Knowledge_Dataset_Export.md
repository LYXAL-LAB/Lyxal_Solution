# 📦 Knowledge Dataset Export – Tracking des Exports d'Entraînement

## 🎯 Objectif

La table `knowledge_dataset_export` permet de **tracker tous les exports de datasets d'entraînement IA** avec versioning automatique, provenance et métadonnées complètes.

---

## 📊 Vue d'Ensemble

| Aspect | Description |
|--------|-------------|
| **Type** | `NORMAL SCHEMAFULL` |
| **Rôle** | Tracking des exports de datasets d'entraînement |
| **Dépendances** | `knowledge_domain` |
| **Relations** | `domain` → `knowledge_domain` (REJECT) |

---

## 🧱 Structure des Champs

### Identité (`identity`)

| Champ | Type | Description |
|-------|------|-------------|
| `identity.version` | `string` | Version du dataset (ex: `"v1.0"`, `"v1.1"`, `"v2.0"`) |
| `identity.name` | `string` UNIQUE | Nom unique du dataset (ex: `"surreal_db_v1.0"`) |
| `identity.description` | `option<string>` | Description de l'export (optionnel) |

### Export (`export`)

| Champ | Type | Description |
|-------|------|-------------|
| `export.min_quality_score` | `number` (0-1) | Score de qualité minimum utilisé (défaut: `0.7`) |
| `export.include_only_marked` | `bool` | Export uniquement des contenus marqués (défaut: `false`) |
| `export.total_contents_found` | `int` | Nombre total de contenus éligibles trouvés |
| `export.total_items_exported` | `int` | Nombre total d'items exportés |
| `export.avg_quality_score` | `option<number>` | Score de qualité moyen des contenus exportés |
| `export.avg_training_weight` | `option<number>` | Poids d'entraînement moyen |

### Provenance (`provenance`)

| Champ | Type | Description |
|-------|------|-------------|
| `provenance.created_by` | `option<string>` | Identifiant créateur (utilisateur/système) |
| `provenance.export_type` | `string` | Type d'export : `"manual"`, `"scheduled"`, `"automatic"`, `"triggered"` |
| `provenance.trigger_reason` | `option<string>` | Raison du déclenchement si `export_type = "triggered"` |
| `provenance.source_version` | `option<string>` | Version source si basé sur un export précédent |
| `provenance.file_path` | `option<string>` | Chemin du fichier JSONL généré |
| `provenance.file_size_bytes` | `option<int>` | Taille du fichier en octets |
| `provenance.file_hash` | `option<string>` | Hash SHA-256 du fichier pour intégrité |

### Métadonnées (`metadata`)

| Champ | Type | Description |
|-------|------|-------------|
| `metadata.is_active` | `bool` | L'export est actif (défaut: `true`) |
| `metadata.created_at` | `datetime` | Date de création (défaut: `time::now()`) |
| `metadata.updated_at` | `datetime` | Date de dernière mise à jour |
| `metadata.expires_at` | `option<datetime>` | Date d'expiration (pour nettoyage automatique) |
| `metadata.notes` | `option<string>` | Notes libres sur l'export |

---

## 🔍 Index

| Index | Champs | Type | Rôle |
|-------|--------|------|------|
| `idx_dataset_export_domain` | `domain` | Normal | Recherche par domaine |
| `idx_dataset_export_version` | `identity.version` | Normal | Recherche par version |
| `idx_dataset_export_name` | `identity.name` | UNIQUE | Recherche par nom unique |
| `idx_dataset_export_active` | `metadata.is_active` | Normal | Filtrage par statut actif |
| `idx_dataset_export_created` | `metadata.created_at` | Normal | Tri par date de création |
| `idx_dataset_export_domain_version` | `domain, identity.version` | Composite | Recherche par domaine et version |

---

## 📝 Exemples d'Utilisation

### Créer un export avec versioning automatique

```surql
-- Utiliser la fonction de création d'export
SELECT * FROM fn::knowledge_export_create_dataset(
    "SURREAL_DB",
    0.7,
    "manual",
    "user_123",
    "Export initial pour fine-tuning",
    true  -- auto_version
);
```

### Lister les exports d'un domaine

```surql
-- Lister tous les exports actifs d'un domaine
SELECT * FROM fn::knowledge_export_list_datasets("SURREAL_DB", true, 20);

-- Voir les détails d'un export spécifique
SELECT * FROM knowledge_dataset_export 
WHERE domain->identity.code = "SURREAL_DB"
    AND identity.version = "v1.0"
LIMIT 1
FETCH domain;
```

### Obtenir la prochaine version

```surql
-- Générer automatiquement la prochaine version
SELECT * FROM fn::knowledge_export_auto_version("SURREAL_DB");
-- Retourne: { "next_version": "v1.1", "current_version": "v1.0", ... }
```

### Mettre à jour les métadonnées de fichier

```surql
-- Après génération du fichier JSONL, mettre à jour le chemin et hash
UPDATE knowledge_dataset_export:export_id SET
    provenance.file_path = "/exports/dataset_v1.0_20250115.jsonl",
    provenance.file_size_bytes = 1048576,
    provenance.file_hash = "sha256:abc123...",
    metadata.updated_at = time::now()
WHERE id = knowledge_dataset_export:export_id;
```

### Marquer un export comme expiré

```surql
-- Marquer les anciens exports pour nettoyage
UPDATE knowledge_dataset_export SET
    metadata.is_active = false,
    metadata.expires_at = time::now() + duration::days(30)
WHERE metadata.created_at < time::now() - duration::days(90)
    AND metadata.is_active = true;
```

---

## 🔄 Workflow Complet

### 1. Création d'export

```surql
-- Créer un export avec toutes les métadonnées
LET $export = SELECT * FROM fn::knowledge_export_create_dataset(
    "SURREAL_DB",
    0.7,
    "scheduled",
    "automation_system",
    "Export hebdomadaire automatique",
    true
);
```

### 2. Génération du fichier JSONL

```javascript
// Script externe pour générer le fichier
const exportResult = await db.query(`
  SELECT * FROM fn::knowledge_export_domain_for_training(
    "SURREAL_DB",
    0.7,
    "${export.version}",
    false
  )
`);

const jsonl = exportResult[0].result[0].data
  .map(item => JSON.stringify(item))
  .join('\n');
```

### 3. Sauvegarde et tracking

```surql
-- Mettre à jour l'export avec les informations du fichier
UPDATE knowledge_dataset_export:export_id SET
    provenance.file_path = "/exports/dataset_v1.0.jsonl",
    provenance.file_size_bytes = 1048576,
    provenance.file_hash = "sha256:...",
    metadata.updated_at = time::now();
```

---

## 🎯 Cas d'Usage

### Export périodique automatique

Les exports peuvent être créés automatiquement selon un calendrier :
- Export hebdomadaire avec `export_type = "scheduled"`
- Export mensuel avec versioning automatique
- Nettoyage automatique des anciens exports

### Export déclenché par événement

Les exports peuvent être déclenchés automatiquement :
- Quand nouveau contenu de haute qualité est ajouté (`export_type = "triggered"`)
- Quand un seuil de qualité est atteint
- Quand un certain nombre de contenus sont marqués pour entraînement

### Traçabilité complète

Chaque export est tracé avec :
- Qui l'a créé (`created_by`)
- Comment il a été créé (`export_type`)
- Quand il a été créé (`created_at`)
- Où le fichier est stocké (`file_path`)
- Intégrité du fichier (`file_hash`)

---

## 📚 Références

- **Fonction d'export** : `function/training/fn_knowledge_export_domain_for_training.surql`
- **Fonction de création** : `function/training/fn_knowledge_export_create_dataset.surql`
- **Fonction de listing** : `function/training/fn_knowledge_export_list_datasets.surql`
- **Schéma complet** : `SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


# 📜 Scripts d'Automatisation – Module Knowledge

Ce dossier contient tous les scripts d'automatisation et d'utilitaires pour le module Knowledge.

---

## 📋 Scripts Disponibles

### 1. 📥 Import (`import/`)

#### `import-knowledge.mjs`

Importe tous les schémas de tables, analyseurs et fonctions dans SurrealDB.

**Usage** :
```bash
node script/import/import-knowledge.mjs
```

**Variables d'environnement** :
- `SURREALDB_URL` : URL de connexion (défaut: valeur dans script)
- `SURREALDB_USER` : Utilisateur (défaut: "admin")
- `SURREALDB_PASS` : Mot de passe (défaut: "admin")
- `SURREALDB_NS` : Namespace (défaut: "Lyxal_Solution")
- `SURREALDB_DB` : Database (défaut: "Developpement")
- `ROOT_KNOWLEDGE_DIR` : Chemin vers le dossier knowledge/ (défaut: auto)

---

### 2. 📤 Export (`export/`)

#### `export-dataset-to-jsonl.mjs`

Exporte un domaine de connaissance au format JSONL pour entraînement IA.

**Usage** :
```bash
node script/export/export-dataset-to-jsonl.mjs <domain_code> [min_quality] [version] [include_only_marked] [update_record]
```

**Exemples** :
```bash
# Export de base
node script/export/export-dataset-to-jsonl.mjs SURREAL_DB

# Export avec qualité minimale personnalisée
node script/export/export-dataset-to-jsonl.mjs SURREAL_DB 0.8

# Export avec version spécifique
node script/export/export-dataset-to-jsonl.mjs SURREAL_DB 0.7 v1.0

# Export uniquement des contenus marqués
node script/export/export-dataset-to-jsonl.mjs SURREAL_DB 0.7 v1.0 true
```

**Variables d'environnement** :
- `EXPORT_OUTPUT_DIR` : Répertoire de sortie (défaut: `./exports`)
- `EXPORT_DOMAIN_CODE` : Code domaine par défaut
- `EXPORT_MIN_QUALITY` : Qualité minimale (0.7)
- `EXPORT_VERSION` : Version du dataset
- `EXPORT_ONLY_MARKED` : Uniquement marqués (true/false)
- `EXPORT_UPDATE_RECORD` : Mettre à jour l'enregistrement (true/false)

**Fichiers générés** :
- Format : `dataset_<domain>_<version>_<date>.jsonl`
- Emplacement : `exports/` (ou `EXPORT_OUTPUT_DIR`)
- Inclut : Hash SHA-256 pour vérification d'intégrité

---

### 3. ⏰ Scheduler (`scheduler/`)

#### `scheduled-export.mjs`

Script pour planifier des exports automatiques (cron, scheduled tasks, cloud functions).

**Usage** :
```bash
node script/scheduler/scheduled-export.mjs
```

**Configuration** :
Modifier le tableau `SCHEDULED_EXPORTS` dans le script pour définir les exports planifiés :

```javascript
const SCHEDULED_EXPORTS = [
  {
    domain_code: 'SURREAL_DB',
    min_quality_score: 0.7,
    export_type: 'scheduled',
    created_by: 'automation_system',
    description: 'Export hebdomadaire automatique',
    schedule: 'weekly',
  },
];
```

**Intégration avec cron (Linux/Mac)** :
```bash
# Tous les dimanches à 2h du matin
0 2 * * 0 cd /path/to/knowledge && node script/scheduler/scheduled-export.mjs
```

**Intégration avec GitHub Actions** :
```yaml
name: Scheduled Export
on:
  schedule:
    - cron: '0 2 * * 0'  # Dimanche 2h
jobs:
  export:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install
      - run: node script/scheduler/scheduled-export.mjs
        env:
          SURREALDB_URL: ${{ secrets.SURREALDB_URL }}
          SURREALDB_USER: ${{ secrets.SURREALDB_USER }}
          SURREALDB_PASS: ${{ secrets.SURREALDB_PASS }}
```

---

### 4. 🧹 Maintenance (`maintenance/`)

#### `cleanup-old-exports.mjs`

Nettoie les exports anciens en les marquant comme inactifs.

**Usage** :
```bash
# Mode simulation (dry-run)
node script/maintenance/cleanup-old-exports.mjs 90 true

# Nettoyage réel des exports > 90 jours
node script/maintenance/cleanup-old-exports.mjs 90 false
```

**Arguments** :
1. `days_old` : Nombre de jours avant nettoyage (défaut: 90)
2. `dry_run` : Mode simulation (true/false, défaut: false)

**Variables d'environnement** :
- `CLEANUP_DAYS_OLD` : Nombre de jours (90)
- `CLEANUP_DRY_RUN` : Mode simulation (true/false)

**Actions** :
- Marque les exports comme `is_active = false`
- Définit `expires_at` à 30 jours dans le futur
- **Note** : Ne supprime pas les fichiers physiques (à faire manuellement)

---

### 5. ✅ Validation (`validate/`)

#### `validate-knowledge-system.mjs`

Vérifie que toutes les tables, fonctions et analyseurs sont correctement installés.

**Usage** :
```bash
node script/validate/validate-knowledge-system.mjs
```

**Vérifications** :
- ✅ Connexion à SurrealDB
- ✅ Tables attendues (14 tables)
- ✅ Analyseurs attendus (1 analyseur)
- ✅ Fonctions knowledge (patterns vérifiés)
- ✅ Tests de fonctionnalités de base

**Code de sortie** :
- `0` : Système validé
- `1` : Éléments manquants ou erreurs

---

## ⚙️ Configuration

### Fichier `.env`

Créer un fichier `.env` à la racine du dossier `knowledge/` basé sur `.env.example` :

```bash
cp .env.example .env
# Puis éditer .env avec vos valeurs réelles
```

### Variables communes

Tous les scripts utilisent ces variables d'environnement :

```bash
SURREALDB_URL=wss://your-instance.surreal.cloud/rpc
SURREALDB_USER=admin
SURREALDB_PASS=your_password
SURREALDB_NS=Lyxal_Solution
SURREALDB_DB=Developpement
```

---

## 📚 Workflow Complet

### 1. Installation initiale

```bash
# 1. Installer les dépendances (si nécessaire)
npm install surrealdb

# 2. Configurer .env
cp .env.example .env
# Éditer .env

# 3. Importer les schémas
node script/import/import-knowledge.mjs

# 4. Valider l'installation
node script/validate/validate-knowledge-system.mjs
```

### 2. Export manuel

```bash
# Exporter un domaine
node script/export/export-dataset-to-jsonl.mjs SURREAL_DB 0.7 v1.0
```

### 3. Export automatique

```bash
# Configurer le scheduler (voir section Scheduler)
node script/scheduler/scheduled-export.mjs
```

### 4. Maintenance

```bash
# Nettoyer les anciens exports (> 90 jours)
node script/maintenance/cleanup-old-exports.mjs 90 false
```

---

## 🐛 Dépannage

### Erreur de connexion

Vérifier les variables d'environnement :
```bash
echo $SURREALDB_URL
echo $SURREALDB_USER
```

### Tables manquantes

Réimporter les schémas :
```bash
node script/import/import-knowledge.mjs
```

### Fonctions non disponibles

Vérifier que les fonctions ont été importées :
```bash
node script/validate/validate-knowledge-system.mjs
```

---

## 📚 Références

- **Documentation complète** : `documentation/`
- **Fonctions d'export** : `function/training/README.md`
- **Schéma système** : `documentation/SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


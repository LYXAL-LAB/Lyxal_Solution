# 🚀 Guide d'Installation et Configuration – Module Knowledge

Guide complet pour installer et configurer le module Knowledge System.

---

## 📋 Prérequis

### 1. Node.js

Version 18+ recommandée :

```bash
node --version  # v18+
```

### 2. Package surrealdb

```bash
npm install surrealdb
```

### 3. SurrealDB actif

- Instance SurrealDB accessible (local ou cloud)
- Credentials admin configurés
- Namespace et Database créés

---

## ⚙️ Configuration

### 1. Créer le fichier `.env`

À la racine du dossier `knowledge/`, créer un fichier `.env` avec :

```bash
# Connexion SurrealDB
SURREALDB_URL=wss://your-instance.surreal.cloud/rpc
SURREALDB_USER=admin
SURREALDB_PASS=your_password_here

# Namespace et Database
SURREALDB_NS=Lyxal_Solution
SURREALDB_DB=Developpement

# Répertoire racine (optionnel, auto-détecté)
ROOT_KNOWLEDGE_DIR=

# Configuration des Exports (optionnel)
EXPORT_OUTPUT_DIR=./exports
EXPORT_DOMAIN_CODE=SURREAL_DB
EXPORT_MIN_QUALITY=0.7

# Configuration du Nettoyage (optionnel)
CLEANUP_DAYS_OLD=90
CLEANUP_DRY_RUN=false
```

> **Note** : Voir `script/.env.example` pour un exemple complet.

---

## 📥 Installation

### Étape 1 : Importer les schémas

```bash
cd knowledge
node script/import/import-knowledge.mjs
```

Ce script importe :
- ✅ Analyseurs (`analyzer/`)
- ✅ Tables (`database/`)
- ✅ Fonctions (`function/`)

**Ordre automatique** : Les dépendances sont respectées automatiquement.

### Étape 2 : Valider l'installation

```bash
node script/validate/validate-knowledge-system.mjs
```

Vérifie :
- ✅ Connexion SurrealDB
- ✅ 14 tables créées
- ✅ 1 analyseur créé
- ✅ Fonctions disponibles

### Étape 3 : Vérifier manuellement (optionnel)

```surql
-- Vérifier les tables
INFO FOR DB;

-- Vérifier les fonctions
INFO FOR NS;

-- Tester une fonction
SELECT * FROM fn::knowledge_get_domain_overview_for_ai("SURREAL_DB");
```

---

## 🧪 Tests Rapides

### Test 1 : Fonction d'export

```bash
node script/export/export-dataset-to-jsonl.mjs SURREAL_DB 0.7
```

### Test 2 : Analytics

```surql
SELECT * FROM fn::knowledge_analytics_get_global_stats();
```

### Test 3 : Tracking

```surql
-- Simuler un tracking (remplacer content_id par un ID réel)
SELECT * FROM fn::knowledge_track_content_access(knowledge_content:some_slug, true);
```

---

## 🔧 Configuration Avancée

### Exports automatiques

Éditer `script/scheduler/scheduled-export.mjs` :

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

### Intégration avec cron

```bash
# Tous les dimanches à 2h du matin
0 2 * * 0 cd /path/to/knowledge && node script/scheduler/scheduled-export.mjs
```

### Intégration avec GitHub Actions

Exemple dans `.github/workflows/scheduled-export.yml` :

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

## 📚 Documentation Complète

- **Scripts** : `script/README.md`
- **Fonctions** : `function/README.md`
- **Schéma** : `documentation/SCHEMA_Knowledge_System.md`
- **Guide d'utilisation** : `documentation/09_How_AI_Should_Use_Knowledge.md`

---

## 🐛 Dépannage

### Erreur de connexion

```bash
# Vérifier les variables d'environnement
echo $SURREALDB_URL
echo $SURREALDB_USER
```

### Tables manquantes

Réimporter les schémas :
```bash
node script/import/import-knowledge.mjs
```

### Erreur "Function not found"

Vérifier que les fonctions ont été importées :
```bash
node script/validate/validate-knowledge-system.mjs
```

### Erreur d'analyseur

Vérifier que l'analyseur est créé :
```surql
INFO FOR NS;
-- Chercher: knowledge_keywords_analyzer
```

---

## ✅ Checklist d'Installation

- [ ] Node.js installé (v18+)
- [ ] Package `surrealdb` installé
- [ ] Fichier `.env` configuré
- [ ] SurrealDB accessible
- [ ] Schémas importés (`import-knowledge.mjs`)
- [ ] Système validé (`validate-knowledge-system.mjs`)
- [ ] Test d'export réussi (optionnel)
- [ ] Scripts de scheduler configurés (optionnel)

---

**Dernière mise à jour** : 2025


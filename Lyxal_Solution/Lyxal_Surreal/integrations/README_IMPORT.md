# 📦 Guide d'Import - Module Integrations

**Date** : 2025-10-30  
**Version** : 1.0  
**Statut** : ✅ Prêt pour import

---

## 📋 Vue d'Ensemble

Ce guide explique comment importer **tous les seeds** du module `integrations` dans SurrealDB.

**Seeds disponibles** :
- **127 batches** (381 fichiers .surql)
- **5,050 records** (credential_type, provider, service, uses_credential, resource, tool)
- **18,100 clés i18n**
- **90,500 traductions** (5 langues: FR, EN, IT, DE, ES)
- **~35 MB** de données

---

## 🔧 Prérequis

### 1. SurrealDB Installé et Démarré

```bash
# Installer SurrealDB (si pas déjà fait)
# Windows: https://surrealdb.com/install
# ou via Chocolatey: choco install surrealdb

# Démarrer SurrealDB
surreal start --user root --pass root memory
```

### 2. Tables de Base Créées

**IMPORTANT** : Avant d'importer les seeds, créez ces tables de base :

```sql
-- 1. Table language (5 langues)
CREATE language:fr SET code = "fr", name = "Français", native_name = "Français", is_active = true;
CREATE language:en SET code = "en", name = "English", native_name = "English", is_active = true;
CREATE language:it SET code = "it", name = "Italian", native_name = "Italiano", is_active = true;
CREATE language:de SET code = "de", name = "German", native_name = "Deutsch", is_active = true;
CREATE language:es SET code = "es", name = "Spanish", native_name = "Español", is_active = true;

-- 2. Table i18n_key (définie dans le schema)
DEFINE TABLE i18n_key SCHEMAFULL;
DEFINE FIELD description ON i18n_key TYPE string;
-- ... (voir schema complet)

-- 3. Table logo_brand (si utilisée)
DEFINE TABLE logo_brand SCHEMAFULL;
-- ... (voir schema)

-- 4. Table url (si utilisée)
DEFINE TABLE url SCHEMAFULL;
-- ... (voir schema)

-- 5. Table icon (si utilisée)
DEFINE TABLE icon SCHEMAFULL;
-- ... (voir schema)
```

### 3. PowerShell (Windows)

Le script d'import est en PowerShell. Sur Windows, PowerShell est installé par défaut.

---

## 🚀 Import Automatique (Recommandé)

### Utilisation du Script

```powershell
# Aller dans le dossier integrations
cd C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations

# Exécuter le script d'import
.\IMPORT_ALL_SEEDS.ps1
```

### Paramètres Personnalisés

```powershell
# Avec paramètres personnalisés
.\IMPORT_ALL_SEEDS.ps1 `
    -SurrealHost "http://localhost:8000" `
    -Username "root" `
    -Password "root" `
    -Namespace "lyxal" `
    -Database "main"
```

---

## 📝 Import Manuel (Étape par Étape)

Si vous préférez importer manuellement, voici l'ordre à respecter :

### Ordre d'Import (CRITIQUE)

**IMPORTANT** : Respecter cet ordre pour éviter les erreurs de dépendances !

```
1. Tables de base
   ↓
2. credential_type (36 batches)
   ↓
3. provider (9 batches)
   ↓
4. service (21 batches)
   ↓
5. uses_credential (14 batches)
   ↓
6. resource (22 batches)
   ↓
7. tool (25 batches)
```

### Exemple d'Import Manuel

```powershell
# Étape 2: credential_type
cd reference\credentials\credential_type

# Seeds
for ($i=1; $i -le 36; $i++) {
    surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main "credential_type_batch${i}_seeds.surql"
}

# i18n_keys
for ($i=1; $i -le 36; $i++) {
    surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main "credential_type_batch${i}_i18n_keys.surql"
}

# i18n_translations
for ($i=1; $i -le 36; $i++) {
    surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main "credential_type_batch${i}_i18n_translations.surql"
}

# ... Répéter pour toutes les tables
```

---

## 📊 Détails des Imports

### Étape 2: credential_type (36 batches)

| Type | Batches | Records |
|------|---------|---------|
| Seeds | 36 | 419 |
| i18n_keys | 36 | 1,257 |
| i18n_translations | 36 | 6,285 |

**Temps estimé** : 5-10 minutes

### Étape 3: provider (9 batches)

| Type | Batches | Records |
|------|---------|---------|
| Seeds | 9 | 266 |
| i18n_keys | 9 | 532 |
| i18n_translations | 9 | 2,660 |

**Temps estimé** : 2-5 minutes

### Étape 4: service (21 batches)

| Type | Batches | Records |
|------|---------|---------|
| Seeds | 21 | 419 |
| i18n_keys | 21 | 838 |
| i18n_translations | 21 | 4,190 |

**Temps estimé** : 3-7 minutes

### Étape 5: uses_credential (14 batches + 2 fichiers)

| Type | Batches | Records |
|------|---------|---------|
| Seeds | 14 | 419 |
| i18n_keys | 1 | 20 |
| i18n_translations | 1 | 100 |

**Temps estimé** : 2-5 minutes

### Étape 6: resource (22 batches)

| Type | Batches | Records |
|------|---------|---------|
| Seeds | 22 | 1,091 |
| i18n_keys | 22 | 3,273 |
| i18n_translations | 22 | 16,365 |

**Temps estimé** : 4-10 minutes

### Étape 7: tool (25 batches)

| Type | Batches | Records |
|------|---------|---------|
| Seeds | 25 | 2,436 |
| i18n_keys | 25 | 12,180 |
| i18n_translations | 25 | 60,900 |

**Temps estimé** : 5-15 minutes

---

## ⏱️ Temps Total Estimé

| Méthode | Durée |
|---------|-------|
| **Script automatique** | 20-50 minutes |
| **Import manuel** | 30-60 minutes |

**Facteurs** : Vitesse de votre machine, charge de SurrealDB, disque SSD vs HDD.

---

## ✅ Vérification Post-Import

Après l'import, vérifiez que tout est OK :

```sql
-- Compter les records par table
SELECT count() FROM credential_type;  -- Attendu: 419
SELECT count() FROM provider;          -- Attendu: 266
SELECT count() FROM service;           -- Attendu: 419
SELECT count() FROM uses_credential;   -- Attendu: 419
SELECT count() FROM resource;          -- Attendu: 1091
SELECT count() FROM tool;              -- Attendu: 2436

-- Total attendu: 5,050 records
```

```sql
-- Vérifier les clés i18n
SELECT count() FROM i18n_key;          -- Attendu: ~18,100

-- Vérifier les traductions
SELECT count() FROM translation;       -- Attendu: ~90,500
```

---

## 🐛 Troubleshooting

### Erreur: "Table does not exist"

**Problème** : Les tables de base (language, i18n_key, etc.) n'existent pas.

**Solution** : Créer les tables de base avant l'import (voir section Prérequis).

### Erreur: "Foreign key constraint violated"

**Problème** : Import dans le mauvais ordre (ex: resource avant service).

**Solution** : Respecter l'ordre d'import défini dans ce guide.

### Erreur: "File not found"

**Problème** : Le script ne trouve pas les fichiers .surql.

**Solution** : Vérifier que vous êtes dans le bon dossier :
```powershell
cd C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\Lyxal_Surreal\integrations
```

### Import Très Lent

**Problème** : L'import prend plus de 2 heures.

**Solutions** :
- Augmenter la RAM de SurrealDB
- Utiliser un disque SSD
- Importer en plusieurs fois (faire des pauses entre les batches)

---

## 📦 Structure des Fichiers

```
integrations/
├── reference/
│   ├── credentials/
│   │   ├── credential_type/
│   │   │   ├── credential_type_batch1_seeds.surql
│   │   │   ├── credential_type_batch1_i18n_keys.surql
│   │   │   ├── credential_type_batch1_i18n_translations.surql
│   │   │   └── ... (36 batches)
│   │   └── uses_credentials/
│   │       ├── uses_credential_batch1_seeds.surql
│   │       └── ... (14 batches)
│   ├── Provider/
│   │   ├── provider_batch1_seeds.surql
│   │   └── ... (9 batches)
│   ├── service/
│   │   ├── service_batch1_seeds.surql
│   │   └── ... (21 batches)
│   ├── resource/
│   │   ├── resource_batch1_seeds.surql
│   │   └── ... (22 batches)
│   └── tool/
│       ├── tool_batch1_seeds.surql
│       └── ... (25 batches)
├── IMPORT_ALL_SEEDS.ps1          ← Script d'import automatique
└── README_IMPORT.md              ← Ce fichier
```

---

## 🎯 Prochaines Étapes

Après l'import réussi :

1. ✅ Vérifier les counts
2. ✅ Tester quelques requêtes
3. ✅ Valider les relations (service → provider, resource → service, tool → resource)
4. ✅ Tester l'affichage dans l'UI (Lyxal Studio)

---

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifier les logs du script d'import
2. Vérifier les logs de SurrealDB
3. Vérifier que toutes les dépendances sont satisfaites
4. Consulter la documentation SurrealDB : https://surrealdb.com/docs

---

**Bonne chance avec l'import ! 🚀**


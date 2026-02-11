# 📦 Script d'Import - Module Integrations

Script Node.js pour importer les schémas et seeds du module **Integrations** dans SurrealDB.

---

## 🎯 Fonctionnalités

- ✅ Import des schémas (tables, fields, indexes)
- ✅ Import des seeds (données) [optionnel]
- ✅ Ordre d'import intelligent (dépendances respectées)
- ✅ Rapport détaillé avec statistiques
- ✅ Gestion des erreurs et continuation
- ✅ Exclusion automatique des fichiers de test/doc
- ✅ Comptage des records par table

---

## 📋 Prérequis

### **1. Node.js**
```bash
node --version  # v18+ recommandé
```

### **2. Package surrealdb**
```bash
npm install surrealdb
```

### **3. SurrealDB actif**
- SurrealDB doit être accessible (local ou cloud)
- Credentials admin configurés

---

## 🚀 Utilisation

### **Mode 1 : Schemas uniquement (rapide)**

Import uniquement des schémas de tables (sans les données).

```bash
node import-integrations.mjs
```

**Temps estimé** : ~10-30 secondes  
**Fichiers importés** : ~10-15 schemas

---

### **Mode 2 : Schemas + Seeds (complet)**

Import des schémas + toutes les données (79,940 seeds).

```bash
# Avec variable d'environnement
IMPORT_SEEDS=true node import-integrations.mjs

# Ou avec flag
node import-integrations.mjs --seeds
```

**⚠️ Attention** :
- **Temps estimé** : 10-30 minutes
- **79,940 records** à importer
- **Peut échouer** sur certains seeds volumineux
- Recommandé pour **tester la fonction** `fn::execute_tool()`

---

## ⚙️ Configuration

### **Variables d'environnement**

```bash
# URL SurrealDB
SURREALDB_URL=wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc

# Credentials
SURREALDB_USER=admin
SURREALDB_PASS=admin

# Namespace et Database
SURREALDB_NS=Lyxal_Solution
SURREALDB_DB=Labs

# Import des seeds (true/false)
IMPORT_SEEDS=false

# Chemin racine (par défaut: parent du dossier script)
ROOT_INTEGRATIONS_DIR=/path/to/integrations
```

### **Exemple avec configuration custom**

```bash
SURREALDB_NS=MyNamespace \
SURREALDB_DB=MyDatabase \
IMPORT_SEEDS=true \
node import-integrations.mjs
```

---

## 📊 Ordre d'Import

### **1. Schemas (database/)**

```
1. credentials/
   - auth_type.surql
   - credential_type.surql
   - transmission_method.surql
   - uses_credential.surql

2. provider/
   - provider.surql

3. service/
   - service.surql

4. resource/
   - resource.surql

5. tool/
   - tool.surql

6. parameter/
   - parameter.surql

7. error_mapping/
   - error_mapping.surql

8. response_mapping/
   - response_mapping.surql (si créé)

9. webhook_config/
   - webhook_config.surql (si créé)
```

### **2. Seeds (reference/)** [si --seeds]

```
1. credentials/
   - auth_type_seeds.surql
   - credential_type_batch*.surql
   - ...

2. Provider/
   - provider_batch1_seeds.surql
   - provider_batch2_seeds.surql
   - ...
   - provider_i18n_keys.surql
   - provider_i18n_translations.surql

3. service/
   - service_batch*.surql
   - service_i18n_*.surql

4. resource/
   - resource_batch*.surql (22 batches)
   - resource_i18n_*.surql

5. tool/
   - tool_batch*.surql (25 batches)
   - tool_i18n_*.surql

6. parameter/
   - parameter_batch*.surql (25 batches)
   - parameter_i18n_*.surql

7. error_mapping/
   - error_mapping_seeds.surql
   - error_mapping_i18n_*.surql
```

---

## 📄 Fichiers Exclus

Le script exclut automatiquement :

**Fichiers spécifiques** :
- `example_queries.surql` (exemples)
- `integration_schema.surql` (documentation)

**Patterns exclus** :
- Fichiers de test (`*test*.surql`)
- Fichiers d'exemple (`*example*.surql`)
- Documentation (`README.md`, `INDEX.md`, `_LIST.md`)
- Analyses (`*ANALYSE*.md`, `*REFACTORING*.md`)
- Scripts Python (`*.py`)

---

## 📊 Rapport d'Import

### **Exemple de sortie**

```
═══════════════════════════════════════════════════════════════
  IMPORT MODULE INTEGRATIONS - Lyxal Solution
═══════════════════════════════════════════════════════════════

🔌 Connexion à SurrealDB...
   URL: wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc
   ✅ Connecté

📦 Configuration:
   Namespace: Lyxal_Solution
   Database:  Labs
   ✅ Namespace et Database sélectionnés

📊 État actuel de la base:
   Tables totales: 45
   Tables integrations existantes: 0

📁 Collecte des fichiers .surql...
   Racine: C:\...\integrations
   ✓ credentials: 4 fichier(s)
   ✓ provider: 1 fichier(s)
   ✓ service: 1 fichier(s)
   ✓ tool: 1 fichier(s)
   ✓ parameter: 1 fichier(s)

   ⏭️  Import des SEEDS désactivé (schemas uniquement)
      Pour importer les seeds: IMPORT_SEEDS=true ou --seeds

   📊 Total: 8 fichier(s) à importer
      - Schemas: 8
      - Seeds:   0

═══════════════════════════════════════════════════════════════
  IMPORT EN COURS...
═══════════════════════════════════════════════════════════════

[1/8] 📄 credentials/auth_type.surql
         ✅ OK (125ms)

[2/8] 📄 provider/provider.surql
         ✅ OK (234ms)

...

═══════════════════════════════════════════════════════════════
  RAPPORT FINAL
═══════════════════════════════════════════════════════════════

✅ Succès:  8 / 8
❌ Échecs:  0 / 8
📊 Taux de réussite: 100.0%

📊 État final de la base:
   Tables totales: 53
   Tables integrations: 8

   Tables integrations créées:
   - auth_type                    : 7 record(s)
   - provider                     : 0 record(s)
   - service                      : 0 record(s)
   - tool                         : 0 record(s)
   - parameter                    : 0 record(s)
   - error_mapping                : 0 record(s)

═══════════════════════════════════════════════════════════════
  IMPORT TERMINÉ
═══════════════════════════════════════════════════════════════

✅ Tous les fichiers ont été importés avec succès!

🔌 Connexion fermée.
```

---

## ❌ Gestion des Erreurs

### **Le script continue malgré les erreurs**

Si un fichier échoue, le script :
1. ❌ Affiche l'erreur
2. 📝 Enregistre l'échec
3. ⏭️ Continue avec les fichiers suivants
4. 📊 Affiche un rapport final avec la liste des échecs

### **Exemple d'échec**

```
[15/50] 📄 tool/tool_batch5_seeds.surql
         ❌ ERREUR: Database record `service:invalid_service` not found

...

═══════════════════════════════════════════════════════════════
  FICHIERS EN ÉCHEC
═══════════════════════════════════════════════════════════════

❌ reference/tool/tool_batch5_seeds.surql
   → Database record `service:invalid_service` not found
```

---

## 🧪 Tests

### **Test 1 : Vérifier la connexion**

```bash
node import-integrations.mjs
```

Si échec de connexion :
- Vérifier l'URL SurrealDB
- Vérifier les credentials
- Vérifier que SurrealDB est actif

---

### **Test 2 : Import des schemas uniquement**

```bash
node import-integrations.mjs
```

**Attendu** :
- ✅ 8-15 fichiers importés
- ✅ Tables créées (provider, service, tool, etc.)
- ⏱️ Durée : ~10-30 secondes

---

### **Test 3 : Vérifier les tables créées**

```sql
-- Dans SurrealDB
INFO FOR DB;

-- Compter les tables integrations
SELECT * FROM (
  SELECT id, count() as count FROM auth_type GROUP ALL
  UNION
  SELECT id, count() as count FROM provider GROUP ALL
  UNION
  SELECT id, count() as count FROM service GROUP ALL
);
```

---

### **Test 4 : Import avec seeds (optionnel)**

```bash
IMPORT_SEEDS=true node import-integrations.mjs
```

**Attendu** :
- ✅ 100+ fichiers importés
- ✅ 79,940+ records créés
- ⏱️ Durée : ~10-30 minutes
- ⚠️ Possibles échecs sur certains batches

---

## 🐛 Résolution de Problèmes

### **Erreur : `Cannot find module 'surrealdb'`**

```bash
npm install surrealdb
```

---

### **Erreur : `Connection failed`**

- Vérifier que SurrealDB est actif
- Vérifier l'URL (wss:// ou ws://)
- Vérifier les credentials

---

### **Erreur : `Database record not found`**

- Les seeds ont des dépendances entre eux
- Importer d'abord les schemas
- Respecter l'ordre : credentials → provider → service → tool → parameter

---

### **Import trop lent avec seeds**

- Normal : 79,940 records = 10-30 minutes
- Désactiver les seeds : `node import-integrations.mjs` (sans --seeds)
- Importer uniquement certains modules manuellement

---

### **Out of memory**

Si le script plante avec une erreur mémoire :

```bash
# Augmenter la mémoire Node.js
NODE_OPTIONS="--max-old-space-size=4096" node import-integrations.mjs --seeds
```

---

## 📚 Fichiers Complémentaires

### **Dans le dossier `integrations/`**

```
integrations/
├── script/
│   ├── import-integrations.mjs  (ce script)
│   └── README.md                (ce fichier)
├── database/
│   ├── credentials/
│   ├── provider/
│   ├── service/
│   └── ...
├── reference/
│   ├── credentials/
│   ├── Provider/
│   ├── service/
│   └── ...
└── RECAP_COMPLET_INTEGRATIONS.md
```

---

## 🔗 Liens Utiles

- **RECAP_COMPLET_INTEGRATIONS.md** : Vue d'ensemble du module
- **fn_execute_tool.surql** : Fonction générique pour exécuter les tools
- **fn_execute_tool_LIMITATIONS.md** : Limitations de la fonction
- **COMPARAISON_APPROCHES_BUNNY_VS_N8N.md** : Comparaison des approches

---

## ✅ Checklist d'Utilisation

### **Avant l'import**

- [ ] Node.js installé (v18+)
- [ ] Package `surrealdb` installé (`npm install surrealdb`)
- [ ] SurrealDB actif et accessible
- [ ] Credentials configurés

### **Import schemas**

- [ ] `node import-integrations.mjs`
- [ ] Vérifier le rapport final (succès > 90%)
- [ ] Vérifier les tables créées

### **Import seeds (optionnel)**

- [ ] `IMPORT_SEEDS=true node import-integrations.mjs`
- [ ] Patience (10-30 minutes)
- [ ] Vérifier les records créés

### **Test de la fonction**

- [ ] Importer `fn_execute_tool.surql`
- [ ] Créer les tables `user_service_credential` et `integration_log`
- [ ] Tester avec un appel simple

---

## 📊 Statistiques

| Métrique | Schemas | Avec Seeds |
|----------|---------|------------|
| **Fichiers** | ~10-15 | ~100-150 |
| **Records** | ~7 | ~79,940 |
| **Durée** | ~10-30s | ~10-30min |
| **Taille** | ~50KB | ~50-100MB |

---

**Date** : 30 octobre 2025  
**Auteur** : Claude (Assistant IA)  
**Version** : 1.0


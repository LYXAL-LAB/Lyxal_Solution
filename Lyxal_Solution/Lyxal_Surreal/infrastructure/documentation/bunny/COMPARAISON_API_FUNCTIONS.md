# 🔍 Analyse de Correspondance - API Bunny vs Fonctions Créées

**Date** : 2025-01-27  
**Objectif** : Comparer les fichiers JSON de documentation Bunny avec les fonctions API créées pour vérifier la correspondance des noms et catégories.

---

## 📋 Fichiers JSON de Documentation

### Fichiers Disponibles

1. **`bunnynet-api-1.json`** - API principale Bunny.net
2. **`bunnynet-edge-storage-api.json`** - API Edge Storage
3. **`edge-scripting-api.json`** - API Edge Scripting
4. **`stream-api.json`** - API Stream (Video)
5. **`bunny-shield-api.json`** - API Shield

---

## 🗂️ Catégories Identifiées dans les JSON

### 1. bunnynet-api-1.json

**Tags/Catégories identifiés** (extraits du JSON) :

| Tag JSON | Path API | Dossier Correspondant | Statut |
|----------|----------|----------------------|--------|
| `Countries` | `/country` | `country/` | ✅ Présent |
| `DNS Zone` | `/dnszone` | `dns_zone/` | ✅ Présent |
| `Pull Zone` | `/pullzone` | `pull__zone/` | ✅ Présent |
| `Purge` | `/purge` | `purge/` | ✅ Présent |
| `Region` | `/region` | `region/` | ✅ Présent |
| `Statistics` | `/statistics` | `statistics/` | ✅ Présent |
| `Storage Zone` | `/storagezone` | `storage__zone/` | ✅ Présent |
| `Stream Video Library` | `/stream/video/library` | `stream__video__library/` | ✅ Présent |
| `User` | `/user` | `user/` | ✅ Présent |
| `API Keys` | `/apikey` | `a_p_i__keys/` | ✅ Présent |
| `OEmbed` | `/oembed` | `o_embed/` | ✅ Présent |

### 2. edge-scripting-api.json

**Tags/Catégories identifiés** :

| Tag JSON | Path API | Dossier Correspondant | Statut |
|----------|----------|----------------------|--------|
| `Edge Script` | `/compute/script` | `edge__script/` | ✅ Présent |
| `Code` | `/compute/script/{id}/code` | `code/` | ✅ Présent |
| `Release` | `/compute/script/{id}/release` | `release/` | ✅ Présent |
| `Variable` | `/compute/script/{id}/variable` | `variable/` | ✅ Présent |
| `Secret` | `/compute/script/{id}/secret` | `secret/` | ✅ Présent |

### 3. stream-api.json

**Tags/Catégories identifiés** :

| Tag JSON | Path API | Dossier Correspondant | Statut |
|----------|----------|----------------------|--------|
| `Manage Videos` | `/library/{libraryId}/videos` | `manage__videos/` | ✅ Présent |
| `Manage Collections` | `/library/{libraryId}/collections` | `manage__collections/` | ✅ Présent |
| `Stream Video Library` | `/library` | `stream__video__library/` | ✅ Présent |

### 4. bunnynet-edge-storage-api.json

**Tags/Catégories identifiés** :

| Tag JSON | Path API | Dossier Correspondant | Statut |
|----------|----------|----------------------|--------|
| `Storage` | `/storage` | ❌ **MANQUANT** | ⚠️ Pas de dossier `edge_storage/` |
| `File` | `/storage/{storageZoneName}` | ❌ **MANQUANT** | ⚠️ Pas de dossier `edge_storage/` |

**Note** : L'API Edge Storage est différente de l'API Storage Zone principale. Il faudrait un dossier séparé `edge_storage/`.

### 5. bunny-shield-api.json

**Tags/Catégories identifiés** :

| Tag JSON | Path API | Dossier Correspondant | Statut |
|----------|----------|----------------------|--------|
| `WAF` | `/shield/waf` | ❌ **MANQUANT** | ⚠️ Pas de dossier `waf/` |
| `Rate Limit` | `/shield/ratelimit` | ❌ **MANQUANT** | ⚠️ Pas de dossier `ratelimit/` |
| `DDoS` | `/shield/ddos` | ❌ **MANQUANT** | ⚠️ Pas de dossier `ddos/` |
| `Metrics` | `/shield/metrics` | ❌ **MANQUANT** | ⚠️ Pas de dossier `shield_metrics/` |
| `EventLogs` | `/shield/event-logs` | ❌ **MANQUANT** | ⚠️ Pas de dossier `shield_event_logs/` |
| `Custom Rule` | `/shield/waf/customrule` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |
| `Individual Rate Limit` | `/shield/ratelimit/individual` | ❌ **MANQUANT** | ⚠️ Peut être dans `ratelimit/` |
| `Rule Group` | `/shield/waf/rulegroup` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |
| `Main Rule Group` | `/shield/waf/mainrulegroup` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |
| `Rule Metrics` | `/shield/waf/rulemetrics` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |
| `WAF Profile` | `/shield/waf/profile` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |
| `Zone Rate Limit` | `/shield/ratelimit/zone` | ❌ **MANQUANT** | ⚠️ Peut être dans `ratelimit/` |
| `Zone Rate Limit Metrics` | `/shield/ratelimit/zonemetrics` | ❌ **MANQUANT** | ⚠️ Peut être dans `ratelimit/` |
| `Shield Zone Rate Limit` | `/shield/ratelimit/shieldzone` | ❌ **MANQUANT** | ⚠️ Peut être dans `ratelimit/` |
| `Shield Zone Rate Limit Metrics` | `/shield/ratelimit/shieldzonemetrics` | ❌ **MANQUANT** | ⚠️ Peut être dans `ratelimit/` |
| `Shield Zone Metrics` | `/shield/metrics/shieldzone` | ❌ **MANQUANT** | ⚠️ Peut être dans `shield_metrics/` |
| `WAF Mapped Enum` | `/shield/waf/mappedenum` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |
| `WAF Mapped Enum List` | `/shield/waf/mappedenumlist` | ❌ **MANQUANT** | ⚠️ Peut être dans `waf/` |

**Note** : L'API Shield est complètement absente. Il faudrait créer les dossiers suivants :
- `shield/` ou `waf/` pour les fonctions WAF
- `ratelimit/` pour les fonctions Rate Limiting
- `ddos/` pour les fonctions DDoS
- `shield_metrics/` pour les métriques Shield

---

## 📁 Dossiers Existants dans bunny_net_api

### Structure Actuelle

```
bunny_net_api/
├── a_p_i__keys/              (1 fichier)
├── code/                     (2 fichiers)
├── country/                  (4 fichiers + README)
├── dns_zone/                 (14 fichiers)
├── edge__script/             (7 fichiers)
├── manage__collections/      (5 fichiers)
├── manage__videos/           (21 fichiers)
├── o_embed/                  (1 fichier)
├── pull__zone/               (26 fichiers)
├── purge/                    (1 fichier)
├── region/                   (1 fichier)
├── release/                  (4 fichiers)
├── secret/                   (5 fichiers)
├── statistics/               (1 fichier)
├── storage__zone/            (9 fichiers)
├── stream__video__library/   (16 fichiers)
├── user/                     (1 fichier)
└── variable/                 (5 fichiers)
```

---

## ✅ Analyse de Correspondance

### Correspondances Exactes ✅

| Catégorie JSON | Dossier Existant | Statut | Notes |
|----------------|------------------|--------|-------|
| `Countries` | `country/` | ✅ | Correspondance exacte |
| `DNS Zone` | `dns_zone/` | ✅ | Correspondance exacte (snake_case) |
| `Pull Zone` | `pull__zone/` | ✅ | Correspondance (double underscore = séparateur) |
| `Purge` | `purge/` | ✅ | Correspondance exacte |
| `Region` | `region/` | ✅ | Correspondance exacte |
| `Statistics` | `statistics/` | ✅ | Correspondance exacte |
| `Storage Zone` | `storage__zone/` | ✅ | Correspondance (double underscore) |
| `Stream Video Library` | `stream__video__library/` | ✅ | Correspondance (double underscore) |
| `User` | `user/` | ✅ | Correspondance exacte |
| `API Keys` | `a_p_i__keys/` | ✅ | Correspondance (double underscore) |
| `Edge Script` | `edge__script/` | ✅ | Correspondance (double underscore) |
| `Code` | `code/` | ✅ | Correspondance exacte |
| `Release` | `release/` | ✅ | Correspondance exacte |
| `Variable` | `variable/` | ✅ | Correspondance exacte |
| `Secret` | `secret/` | ✅ | Correspondance exacte |
| `Manage Videos` | `manage__videos/` | ✅ | Correspondance (double underscore) |
| `Manage Collections` | `manage__collections/` | ✅ | Correspondance (double underscore) |
| `OEmbed` | `o_embed/` | ✅ | Correspondance (underscore) |

---

## ⚠️ Correspondances Partielles ou À Vérifier

| Catégorie JSON | Dossier Existant | Statut | Notes |
|----------------|------------------|--------|-------|
| `Shield` | ❌ **MANQUANT** | ⚠️ | Pas de dossier `shield/` |
| `WAF` | ❌ **MANQUANT** | ⚠️ | Pas de dossier `waf/` |
| `Rate Limit` | ❌ **MANQUANT** | ⚠️ | Pas de dossier `ratelimit/` |
| `DDoS` | ❌ **MANQUANT** | ⚠️ | Pas de dossier `ddos/` |
| `Storage` (Edge Storage) | ❌ **MANQUANT** | ⚠️ | Pas de dossier `edge_storage/` ou `storage/` |

---

## 📊 Résumé des Correspondances

### ✅ Catégories Présentes (18/23)

1. ✅ `country/` → Countries
2. ✅ `dns_zone/` → DNS Zone
3. ✅ `pull__zone/` → Pull Zone
4. ✅ `purge/` → Purge
5. ✅ `region/` → Region
6. ✅ `statistics/` → Statistics
7. ✅ `storage__zone/` → Storage Zone
8. ✅ `stream__video__library/` → Stream Video Library
9. ✅ `user/` → User
10. ✅ `a_p_i__keys/` → API Keys
11. ✅ `edge__script/` → Edge Script
12. ✅ `code/` → Code
13. ✅ `release/` → Release
14. ✅ `variable/` → Variable
15. ✅ `secret/` → Secret
16. ✅ `manage__videos/` → Manage Videos
17. ✅ `manage__collections/` → Manage Collections
18. ✅ `o_embed/` → OEmbed

### ❌ Catégories Manquantes (Plusieurs APIs complètes manquantes)

#### API Shield (bunny-shield-api.json) - **COMPLÈTEMENT ABSENTE**

1. ❌ `shield/` ou `waf/` → WAF (18+ endpoints)
2. ❌ `ratelimit/` → Rate Limiting (6+ endpoints)
3. ❌ `ddos/` → DDoS (endpoints)
4. ❌ `shield_metrics/` → Métriques Shield (endpoints)
5. ❌ `shield_event_logs/` → Event Logs Shield (endpoints)

#### API Edge Storage (bunny-edge-storage-api.json) - **ABSENTE**

6. ❌ `edge_storage/` → Edge Storage API (différente de Storage Zone)

**Total estimé** : ~30+ endpoints manquants dans l'API Shield + Edge Storage

---

## 🔍 Analyse des Noms de Fonctions

### Pattern de Nommage Actuel

**Format observé** : `fn_bunny_<endpoint>_<operation>`

**Exemples** :
- `fn_bunny_add_dns_zone.surql`
- `fn_bunny_get_dns_zone.surql`
- `fn_bunny_update_dns_record.surql`

### Correspondance avec OperationId JSON

**Format JSON** : `OperationId` dans les endpoints

**Exemples** :
- `DnsZonePublic_Index` → Devrait être `fn_bunny_dns_zone_public__index`
- `GetEdgeScriptCodeEndpoint_GetCode` → `fn_bunny_get_edge_script_code_endpoint__get_code` ✅

**Observation** : Les noms de fonctions semblent suivre le pattern `operationId` mais avec le préfixe `fn_bunny_`.

---

## 📝 Recommandations

### 1. Créer les Dossiers Manquants

Créer les dossiers suivants pour les APIs Shield et Edge Storage :

```
bunny_net_api/
├── shield/                    (ou waf/ - à décider)
│   ├── fn_bunny_waf_*.surql
│   ├── fn_bunny_waf_custom_rule_*.surql
│   ├── fn_bunny_waf_rule_group_*.surql
│   ├── fn_bunny_waf_rule_main_group_*.surql
│   ├── fn_bunny_waf_rule_metrics_*.surql
│   ├── fn_bunny_waf_profile_*.surql
│   ├── fn_bunny_waf_mapped_enum_*.surql
│   └── ...
├── ratelimit/
│   ├── fn_bunny_ratelimit_*.surql
│   ├── fn_bunny_ratelimit_individual_*.surql
│   ├── fn_bunny_ratelimit_zone_*.surql
│   ├── fn_bunny_ratelimit_shield_zone_*.surql
│   └── ...
├── ddos/
│   ├── fn_bunny_ddos_*.surql
│   └── ...
├── shield_metrics/
│   ├── fn_bunny_shield_zone_metrics_*.surql
│   └── ...
├── shield_event_logs/
│   ├── fn_bunny_shield_event_logs_*.surql
│   └── ...
└── edge_storage/  (différent de storage__zone/)
    ├── fn_bunny_edge_storage_*.surql
    └── ...
```

**Note** : L'API Shield est volumineuse avec ~30+ endpoints. Il faudra créer toutes les fonctions correspondantes.

### 2. Vérifier la Correspondance des Noms

Pour chaque fonction existante, vérifier que :
- Le nom correspond à l'`operationId` du JSON
- Le format suit le pattern : `fn_bunny_<category>_<operation>`

### 3. Harmoniser les Noms de Dossiers

Les dossiers utilisent `__` (double underscore) comme séparateur pour les mots composés. C'est cohérent mais il faudrait vérifier :
- Si c'est la convention choisie
- Si tous les dossiers suivent cette convention

---

## 🎯 Prochaines Étapes

1. **Créer les dossiers manquants** pour Shield et Edge Storage
2. **Extraire les endpoints** des fichiers JSON manquants
3. **Générer les fonctions** correspondantes
4. **Vérifier la correspondance** nom de fonction ↔ operationId
5. **Documenter** les écarts identifiés

---

## 📚 Références

- **Fichiers JSON** : `infrastructure/documentation/bunny/*.json`
- **Fonctions existantes** : `infrastructure/resources/bunny/bunny_net_api/**/*.surql`
- **Documentation** : `infrastructure/documentation/bunny/`

---

**Analyse de correspondance API Bunny vs Fonctions créées** 🔍✨


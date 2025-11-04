# 📊 Mapping : Fichiers JSON ↔ Catégories API Bunny

**Date** : 2025-01-27

---

## 🗂️ Les 5 Grandes Catégories d'API Bunny

Il y a **5 fichiers JSON** qui correspondent à **5 grandes catégories d'API Bunny** :

| # | Fichier JSON | Titre API | Catégories Incluses | Statut dans Resources |
|---|--------------|-----------|---------------------|----------------------|
| 1 | `bunnynet-api-1.json` | **bunny.net API** | DNS Zone, Pull Zone, Storage Zone, Purge, Region, Statistics, User, API Keys, OEmbed, Stream Video Library | ✅ **Partiellement présent** |
| 2 | `bunnynet-edge-storage-api.json` | **bunny.net Edge Storage API** | Manage Files (upload/download/delete/list) | ❌ **MANQUANT** |
| 3 | `edge-scripting-api.json` | **Edge Scripting API** | Edge Script, Code, Release, Variable, Secret | ✅ **Présent** |
| 4 | `stream-api.json` | **Stream API** | Manage Videos, Manage Collections, Stream Video Library | ✅ **Présent** |
| 5 | `bunny-shield-api.json` | **Bunny Shield API** | WAF, Rate Limit, DDoS, Metrics, EventLogs | ❌ **MANQUANT** |

---

## 📋 Détail par Catégorie

### 1. `bunnynet-api-1.json` - API Principale Bunny.net

**Catégories incluses** (dans `bunnynet-api-1.json`) :

| Catégorie | Dossier Correspondant | Statut |
|-----------|----------------------|--------|
| `Countries` | `country/` | ✅ Présent |
| `DNS Zone` | `dns_zone/` | ✅ Présent |
| `Pull Zone` | `pull__zone/` | ✅ Présent |
| `Purge` | `purge/` | ✅ Présent |
| `Region` | `region/` | ✅ Présent |
| `Statistics` | `statistics/` | ✅ Présent |
| `Storage Zone` | `storage__zone/` | ✅ Présent |
| `Stream Video Library` | `stream__video__library/` | ✅ Présent |
| `User` | `user/` | ✅ Présent |
| `API Keys` | `a_p_i__keys/` | ✅ Présent |
| `OEmbed` | `o_embed/` | ✅ Présent |

**Conclusion** : ✅ **Complète** - Toutes les catégories sont présentes dans les resources.

---

### 2. `bunnynet-edge-storage-api.json` - Edge Storage API

**Catégories incluses** :

| Catégorie | Dossier Correspondant | Statut |
|-----------|----------------------|--------|
| `Manage Files` | ❌ **MANQUANT** | ❌ Pas de dossier `edge_storage/` |

**Endpoints principaux** :
- `GET /{storageZoneName}/{path}/{fileName}` → Download File
- `PUT /{storageZoneName}/{path}/{fileName}` → Upload File
- `DELETE /{storageZoneName}/{path}/{fileName}` → Delete File
- `GET /{storageZoneName}/{path}/` → List Files

**Conclusion** : ❌ **MANQUANTE** - Aucune fonction Edge Storage API dans les resources.

---

### 3. `edge-scripting-api.json` - Edge Scripting API

**Catégories incluses** :

| Catégorie | Dossier Correspondant | Statut |
|-----------|----------------------|--------|
| `Edge Script` | `edge__script/` | ✅ Présent |
| `Code` | `code/` | ✅ Présent |
| `Release` | `release/` | ✅ Présent |
| `Variable` | `variable/` | ✅ Présent |
| `Secret` | `secret/` | ✅ Présent |

**Conclusion** : ✅ **Complète** - Toutes les catégories sont présentes dans les resources.

---

### 4. `stream-api.json` - Stream API

**Catégories incluses** :

| Catégorie | Dossier Correspondant | Statut |
|-----------|----------------------|--------|
| `Manage Videos` | `manage__videos/` | ✅ Présent |
| `Manage Collections` | `manage__collections/` | ✅ Présent |
| `Stream Video Library` | `stream__video__library/` | ✅ Présent |

**Conclusion** : ✅ **Complète** - Toutes les catégories sont présentes dans les resources.

---

### 5. `bunny-shield-api.json` - Shield API

**Catégories incluses** :

| Catégorie | Dossier Correspondant | Statut |
|-----------|----------------------|--------|
| `WAF` | ❌ **MANQUANT** | ❌ Pas de dossier `waf/` ou `shield/` |
| `Rate Limit` | ❌ **MANQUANT** | ❌ Pas de dossier `ratelimit/` |
| `DDoS` | ❌ **MANQUANT** | ❌ Pas de dossier `ddos/` |
| `Metrics` | ❌ **MANQUANT** | ❌ Pas de dossier `shield_metrics/` |
| `EventLogs` | ❌ **MANQUANT** | ❌ Pas de dossier `shield_event_logs/` |
| `Custom Rule` | ❌ **MANQUANT** | ❌ (fait partie de WAF) |
| `Rule Group` | ❌ **MANQUANT** | ❌ (fait partie de WAF) |
| `Main Rule Group` | ❌ **MANQUANT** | ❌ (fait partie de WAF) |
| `Rule Metrics` | ❌ **MANQUANT** | ❌ (fait partie de WAF) |
| `WAF Profile` | ❌ **MANQUANT** | ❌ (fait partie de WAF) |
| `Individual Rate Limit` | ❌ **MANQUANT** | ❌ (fait partie de Rate Limit) |
| `Zone Rate Limit` | ❌ **MANQUANT** | ❌ (fait partie de Rate Limit) |
| `Shield Zone Rate Limit` | ❌ **MANQUANT** | ❌ (fait partie de Rate Limit) |
| `WAF Mapped Enum` | ❌ **MANQUANT** | ❌ (fait partie de WAF) |

**Conclusion** : ❌ **COMPLÈTEMENT MANQUANTE** - Aucune fonction Shield API dans les resources (~30+ endpoints manquants).

---

## 📊 Résumé Global

| Fichier JSON | Statut | Catégories Présentes | Catégories Manquantes |
|--------------|--------|----------------------|----------------------|
| `bunnynet-api-1.json` | ✅ **Complète** | 11/11 | 0 |
| `edge-scripting-api.json` | ✅ **Complète** | 5/5 | 0 |
| `stream-api.json` | ✅ **Complète** | 3/3 | 0 |
| `bunnynet-edge-storage-api.json` | ❌ **Manquante** | 0/1 | 1 |
| `bunny-shield-api.json` | ❌ **Manquante** | 0/14 | 14 |

**Total** : 
- ✅ **3 APIs complètes** sur 5
- ❌ **2 APIs manquantes** : Edge Storage + Shield

---

## 🎯 Ordre Recommandé de Création

### Phase 1 : Edge Storage API (Petite)
- **Fichier** : `bunnynet-edge-storage-api.json`
- **Dossier** : `edge_storage/`
- **Endpoints** : ~10-15 endpoints
- **Complexité** : Faible

### Phase 2 : Shield API (Grande)
- **Fichier** : `bunny-shield-api.json`
- **Dossiers** : `waf/`, `ratelimit/`, `ddos/`, `shield_metrics/`, `shield_event_logs/`
- **Endpoints** : ~30+ endpoints
- **Complexité** : Élevée

---

## 📝 Notes Importantes

### Distinction Edge Storage vs Storage Zone

- **Storage Zone API** (`storage__zone/`) : Gestion des **zones** (créer/modifier/supprimer zones)
- **Edge Storage API** (`edge_storage/`) : Gestion des **fichiers** dans les zones (upload/download/delete/list)

Ce sont **2 APIs différentes** avec des endpoints différents !

---

**Mapping complet des 5 grandes catégories d'API Bunny** 📊✨


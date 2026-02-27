# Dispatch Plan : Organisation Modulaire de Lyxal Backend

Ce document définit la répartition des composants entre le noyau (`lyxal_core`) et les modules fonctionnels (`lyxal_backend`). L'objectif est de garantir une architecture "Full Rust" modulaire, isolée et performante.

---

## 🏛️ 1. Lyxal_Core (Le Kernel / Noyau Dur)
Ce dossier contient uniquement les briques fondamentales du système. C'est l'OS de données.

| Composant | Source (SurrealDB Core) | Rôle |
| :--- | :--- | :--- |
| **Identity (IAM)** | `iam/` | Gestion native des utilisateurs, rôles et permissions au niveau NS/DB. |
| **Storage (KVS)** | `kvs/` | Interface avec **LyxalKV** (LSM-Tree). |
| **Execution Engine** | `sql/`, `exe/`, `expr/` | Moteur de calcul, parser SurrealQL et exécuteur de requêtes. |
| **Metadata** | `catalog/`, `ctx/` | Catalogue système, gestion des contextes et transactions. |
| **Base Types** | `val/`, `key/`, `err/` | Structures de données fondamentales (Value, Key, Error). |

---

## 📦 2. Modules Fonctionnels (Crates Lyxal_Backend)
Ces modules sont extraits du périmètre "Base de données" pour devenir des services indépendants gravitant autour du noyau.

### 🗄️ Stockage & Objets
* **`lyxal_bucket`** (extrait de `buc/`) : Gestion du stockage d'objets (S3-compatible, images, docs).
* **`lyxal_dav`** (extrait de **Stalwart**) : Protocoles de synchronisation CalDAV / CardDAV / WebDAV.

### ⚙️ Logique & Calcul
* **`lyxal_functions`** (extrait de `fnc/`) : Bibliothèque de fonctions natives (IA, NLP, traitements métier).
* **`lyxal_api_engine`** (extrait de `api/`) : Moteur de traduction des requêtes et gestion des endpoints externes.
* **`lyxal_rpc`** (extrait de `rpc/`) : Couche de communication temps-réel et WebSockets.

### 🌐 Interfaces & Intégration
* **`lyxal_studio_bridge`** (extrait de `surrealism/`) : Lien natif avec l'interface de "Vibe Coding" (Lyxal Studio).
* **`lyxal_email`** (extrait de **Stalwart**) : Serveur SMTP / IMAP modulaire.
* **`lyxal_server`** : Le binaire principal d'orchestration qui assemble le noyau et les modules choisis.

---

## 🎯 Avantages de cette Organisation

1. **Isolation Stricte** : Une erreur dans un module (`lyxal_functions`) ne fait pas planter le noyau de données (`lyxal_core`).
2. **Déploiement Sélectif** : Possibilité de compiler des instances "Light" (ex: uniquement Core + DAV) pour l'Edge Computing.
3. **Maintenance Simplifiée** : Les mises à jour du moteur SurrealDB (le Core) sont séparées du développement des fonctionnalités métier.
4. **Parallélisme** : Les équipes peuvent travailler sur le module Email sans toucher au code sensible de la base de données.

---
*Plan de dispatch validé pour la Lyxal Solution Architecture.*

# Spécification Technique : Mapping des Fonctions proxy::* (LyxalQL -> Sōzu)

Ce document définit l'interface exacte (API Surface) que le binaire Lyxal doit exposer via LyxalQL pour piloter le moteur Sōzu. Chaque fonction doit être implémentée dans `lyxal_db/core/src/fnc/proxy.rs`.

## 1. Module proxy::ingress (Gestion des points d'entrée)

| Fonction LyxalQL | Arguments | Action Rust (Sōzu lib) | Retour |
| :--- | :--- | :--- | :--- |
| `proxy::ingress::add` | `(host: str, port: int, opts: obj)` | `WorkerRequest::AddHttpFrontend` | `object` |
| `proxy::ingress::remove` | `(host: str, port: int)` | `WorkerRequest::RemoveHttpFrontend` | `bool` |
| `proxy::ingress::update` | `(host: str, opts: obj)` | `WorkerRequest::AddHttpFrontend` (upsert) | `bool` |
| `proxy::ingress::list` | `()` | Consultation de la `FrontendMap` en RAM | `array` |
| `proxy::ingress::maintenance` | `(host: str, enable: bool)` | Modification du `RulePosition` ou réponse 503 forcée | `bool` |

## 2. Module proxy::cluster (Gestion du routage interne)

| Fonction LyxalQL | Arguments | Action Rust (Sōzu lib) | Retour |
| :--- | :--- | :--- | :--- |
| `proxy::cluster::add` | `(id: str, algo: str)` | `WorkerRequest::AddCluster` | `bool` |
| `proxy::cluster::remove` | `(id: str)` | `WorkerRequest::RemoveCluster` | `bool` |
| `proxy::cluster::add_backend` | `(cluster: str, b_id: str, addr: str)` | `WorkerRequest::AddBackend` | `bool` |
| `proxy::cluster::remove_backend` | `(cluster: str, b_id: str)` | `WorkerRequest::RemoveBackend` | `bool` |
| `proxy::cluster::set_weight` | `(cluster: str, b_id: str, w: int)` | Modification des `LoadBalancingParams` | `bool` |

## 3. Module proxy::ssl (Gestion de la sécurité TLS)

| Fonction LyxalQL | Arguments | Action Rust (Sōzu lib) | Retour |
| :--- | :--- | :--- | :--- |
| `proxy::ssl::add_cert` | `(domain: str, cert: str, key: str)` | `WorkerRequest::AddCertificate` | `bool` |
| `proxy::ssl::remove_cert` | `(domain: str)` | `WorkerRequest::RemoveCertificate` | `bool` |
| `proxy::ssl::status` | `(domain: str)` | Consultation du `CertificateResolver` | `object` |

## 4. Module proxy::metrics (Observabilité & Statistiques)

| Fonction LyxalQL | Arguments | Action Rust (Sōzu lib) | Retour |
| :--- | :--- | :--- | :--- |
| `proxy::metrics::get` | `(id: str)` | `LocalDrain::query` + `to_filtered()` | `object` |
| `proxy::metrics::global` | `()` | `LocalDrain::dump_all` | `object` |
| `proxy::metrics::reset` | `(id: option<str>)` | `LocalDrain::clear` | `bool` |

## 5. Module proxy::system (Pilotage du moteur)

| Fonction LyxalQL | Arguments | Action Rust (Sōzu lib) | Retour |
| :--- | :--- | :--- | :--- |
| `proxy::system::config` | `(key: str, val: any)` | Modification de la `ServerConfig` en RAM | `bool` |
| `proxy::system::status` | `()` | Santé du thread Worker (Ping/Pong interne) | `object` |
| `proxy::system::upgrade` | `()` | Trigger du mécanisme de Hot-Upgrade de Sōzu | `bool` |

---

## Règles de Validation (Zéro Erreur)

1. **Type Checking** : Chaque fonction doit valider ses types via le système `Value` de Lyxal avant d'envoyer la commande à Sōzu.
2. **Atomicité** : Si une commande `proxy::*` échoue dans Sōzu, la transaction Lyxal doit pouvoir être annulée (ou l'erreur doit être propagée clairement au MCP).
3. **Audit** : Toute exécution de ces fonctions doit être logguée dans une table système `proxy_audit`.

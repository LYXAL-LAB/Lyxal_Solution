# RAPPORT D'AUDIT : Conformité Schéma SurrealDB vs Spécification Protobuf Sōzu
**Statut :** "Google-Grade" Technical Review
**Version :** 1.0
**Cible :** lyxal_solution_backend / lyxal_proxy

## 1. Executive Summary
L'objectif de cet audit est de garantir une correspondance binaire de 100% entre les tables SurrealDB (`.surql`) et les structures Protobuf (`command.rs`). Toute divergence à ce stade provoquerait des erreurs de runtime ou des pertes de fonctionnalités dans le moteur Sōzu intégré.

---

## 2. Analyse de la Table : proxy_ingress (Frontends)
| Champ Protobuf (Sōzu) | Champ SurrealDB | Statut | Recommandation |
| :--- | :--- | :--- | :--- |
| `hostname` | `configuration.hostname` | ✅ **CONFORME** | RAS. |
| `address.port` | `configuration.port` | ✅ **CONFORME** | RAS. |
| `cluster_id` | `configuration.cluster` | ✅ **CONFORME** | Mapping Record ID -> String requis. |
| `path` (PathRule) | **MANQUANT** | ❌ **CRITIQUE** | Ajouter `configuration.path_value` (string) et `configuration.path_kind` (enum: PREFIX, REGEX, EQUALS). |
| `method` | **MANQUANT** | ⚠️ **MINEUR** | Ajouter `configuration.method` (option<string>) pour filtrage verbes HTTP. |
| `position` | **MANQUANT** | ⚠️ **MINEUR** | Ajouter `configuration.rule_position` (int) pour priorité de routage. |
| `tags` | `application.lyxal_proxy` | 🔄 **PARTIEL** | Sōzu attend une Map. Ajouter `configuration.tags` (object) pour métadonnées custom. |

---

## 3. Analyse de la Table : proxy_cluster (Logical Groups)
| Champ Protobuf (Sōzu) | Champ SurrealDB | Statut | Recommandation |
| :--- | :--- | :--- | :--- |
| `cluster_id` | `id` | ✅ **CONFORME** | RAS. |
| `load_balancing` | `configuration.load_balancing` | ✅ **CONFORME** | RAS. |
| `sticky_session` | `configuration.sticky_session` | ✅ **CONFORME** | RAS. |
| `https_redirect` | **MANQUANT** | ❌ **MAJEUR** | Ajouter `configuration.https_redirect` (bool) pour forçage TLS natif. |
| `answer_503` | **MANQUANT** | ⚠️ **MINEUR** | Ajouter `configuration.custom_503_html` (option<string>). |
| `proxy_protocol` | **MANQUANT** | ⚠️ **SYSTEM** | Ajouter `configuration.proxy_protocol` (enum) pour compatibilité Cloud (AWS/GC). |

---

## 4. Analyse de la Table : proxy_backend (Targets)
| Champ Protobuf (Sōzu) | Champ SurrealDB | Statut | Recommandation |
| :--- | :--- | :--- | :--- |
| `cluster_id` | `configuration.cluster` | ✅ **CONFORME** | RAS. |
| `backend_id` | `id` | ✅ **CONFORME** | RAS. |
| `address` | `configuration.address` | ✅ **CONFORME** | Format "IP:Port" doit être parsé par le binaire Rust. |
| `weight` | `configuration.weight` | ✅ **CONFORME** | RAS. |
| `backup` | **MANQUANT** | ⚠️ **MINEUR** | Ajouter `configuration.is_backup` (bool) pour failover. |

---

## 5. Analyse de la Table : proxy_certificate_ssl (Security)
| Champ Protobuf (Sōzu) | Champ SurrealDB | Statut | Recommandation |
| :--- | :--- | :--- | :--- |
| `certificate` | **MANQUANT** | ❌ **BLOQUANT** | Créer la table. Champ `data.cert_pem` (string). |
| `key` | **MANQUANT** | ❌ **BLOQUANT** | Champ `data.key_pem` (string) avec chiffrement SurrealDB. |
| `names` | **MANQUANT** | ⚠️ **MAJEUR** | Champ `identity.sans` (array<string>) pour certificats multi-domaines. |
| `expired_at` | **MANQUANT** | ⚠️ **MAJEUR** | Champ `timestamp.expires_at` (datetime) pour alertes IA. |

---

## 6. Analyse des Tables de Configuration Système (Listeners)
Sōzu a besoin de paramètres de listeners (HTTP/HTTPS/TCP) qui ne sont pas dans vos tables actuelles.
- **Déficit :** Il manque une table `proxy_listener` pour configurer les timeouts (`front_timeout`, `back_timeout`, `connect_timeout`).
- **Impact :** Sans cela, le binaire Lyxal utilisera des valeurs codées "en dur", ce qui empêche l'IA d'optimiser le réseau pour des charges spécifiques.

---

## 7. Checklist de Remédiation (Plan d'Action)
1. [ ] **Mettre à jour `proxy_ingress.surql`** : Ajouter Path (Value/Kind) et Tags.
2. [ ] **Mettre à jour `proxy_cluster.surql`** : Ajouter https_redirect et custom_503.
3. [ ] **Créer `proxy_certificate_ssl.surql\`** : Définir le stockage sécurisé des clés.
4. [ ] **Créer `proxy_listener.surql`** : Pour le réglage fin des timeouts réseau.

---
**Conclusion :** Le schéma actuel est fonctionnel pour du routage simple, mais insuffisant pour un produit "Enterprise-Grade" gérant le SSL automatique et le routage granulaire (chemins/regex). Une mise à jour des fichiers `.surql` est requise avant d'entamer le mapping Rust.

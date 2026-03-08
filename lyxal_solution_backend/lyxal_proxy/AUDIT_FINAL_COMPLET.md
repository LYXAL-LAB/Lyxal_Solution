# RAPPORT D'AUDIT FINAL : CONFORMITÉ BDD VS TYPES RUST (SŌZU CORE)
**Objectif :** Vérification de l'exhaustivité des champs pour un pilotage "Zéro Erreur" via MCP.
**Référence :** `lyxal_types_proxy/src/command.rs` (Protobuf généré)

---

## 1. ANALYSE COMPARATIVE DES STRUCTURES

### A. Entités Ingress (Frontends)
*Protobuf : `RequestHttpFrontend` & `RequestTcpFrontend`*

| Champ Protobuf (Sōzu) | État dans la BDD actuelle | Verdict |
| :--- | :--- | :--- |
| `hostname` | `configuration.hostname` | ✅ Conforme |
| `address.port` | `configuration.port` | ✅ Conforme |
| `path` (PathRule) | **ABSENT** | ❌ **MANQUANT** : Sōzu nécessite un chemin (ex: "/", "/api"). |
| `method` (String) | **ABSENT** | ❌ **MANQUANT** : Optionnel mais nécessaire pour le filtrage REST. |
| `position` (Enum) | **ABSENT** | ❌ **MANQUANT** : Définit l'ordre de priorité (PRE/POST/TREE). |
| `tags` (Map) | `application.lyxal_proxy` | ✅ Conforme |

### B. Entités Cluster (Routage)
*Protobuf : `Cluster`*

| Champ Protobuf (Sōzu) | État dans la BDD actuelle | Verdict |
| :--- | :--- | :--- |
| `cluster_id` | `id` | ✅ Conforme |
| `sticky_session` | `configuration.sticky_session` | ✅ Conforme |
| `load_balancing` | `configuration.load_balancing` | ✅ Conforme |
| `https_redirect` | **ABSENT** | ❌ **MANQUANT** : Vital pour la sécurité automatique. |
| `answer_503` | **ABSENT** | ❌ **MANQUANT** : Nécessaire pour les pages de maintenance personnalisées. |
| `load_metric` (Enum) | **ABSENT** | ❌ **MANQUANT** : Définit la mesure de charge (Connections/Requests). |

### C. Entités Backend (Cibles)
*Protobuf : `AddBackend`*

| Champ Protobuf (Sōzu) | État dans la BDD actuelle | Verdict |
| :--- | :--- | :--- |
| `backend_id` | `id` | ✅ Conforme |
| `address` | `configuration.address` | ✅ Conforme |
| `weight` | `configuration.weight` | ✅ Conforme |
| `backup` (Bool) | **ABSENT** | ❌ **MANQUANT** : Indispensable pour la haute disponibilité (failover). |
| `sticky_id` | **ABSENT** | ❌ **MANQUANT** : Pour la persistance de session précise. |

---

## 2. TABLES MANQUANTES (OBLIGATOIRES POUR SŌZU)

Selon le fichier des types Rust (`command.rs`), les fonctionnalités suivantes ne peuvent pas être activées avec les tables actuelles :

1.  **Table `proxy_certificate_ssl`** :
    *   Sōzu a besoin des messages `AddCertificate`, `RemoveCertificate`.
    *   Champs requis : `certificate` (Fullchain), `key` (Private Key), `expired_at` (Timestamp).
    *   **Statut : ❌ TOTALEMENT MANQUANTE.**

2.  **Table `proxy_settings` (Config Moteur)** :
    *   Sōzu a besoin du message `ServerConfig`.
    *   Champs requis : `max_connections`, `buffer_size`, `front_timeout`, `back_timeout`.
    *   **Statut : ❌ TOTALEMENT MANQUANTE.**

3.  **Table `proxy_listener` (Écoute réseau)** :
    *   Sōzu a besoin de `HttpListenerConfig`, `HttpsListenerConfig`.
    *   **Statut : ❌ TOTALEMENT MANQUANTE.**

---

## 3. CONCLUSION DE L'AUDIT

**La base de données n'est pas encore 100% "Google-Grade".**

Bien que la structure soit propre et modulaire, il y a une **rupture de compatibilité** entre les tables actuelles et les capacités réelles du moteur Sōzu définies dans vos types Rust. Une IA (MCP) ne pourrait pas configurer le HTTPS, gérer le failover (backup) ou optimiser les performances du moteur sans les champs et tables listés ci-dessus.

---

## 4. CHECKLIST DE REMÉDIATION FINALE

- [ ] Créer la table `proxy_certificate_ssl.surql` (Certificats/Clés).
- [ ] Créer la table `proxy_settings.surql` (Configuration globale du binaire).
- [ ] Ajouter `path` et `path_kind` dans `proxy_ingress.surql`.
- [ ] Ajouter `https_redirect` et `load_metric` dans `proxy_cluster.surql`.
- [ ] Ajouter `is_backup` dans `proxy_backend.surql`.

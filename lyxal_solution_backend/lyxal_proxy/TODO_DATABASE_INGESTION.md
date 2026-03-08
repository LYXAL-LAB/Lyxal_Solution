# TODO: Architecture Data-Driven pour Lyxal Proxy (Sōzu + SurrealDB)

Ce document définit la structure des tables et des événements SurrealDB nécessaires pour piloter le moteur Sōzu de manière persistante et via SQL.

## 1. Schéma des Tables (Data Model)

### A. Table `proxy_ingress` (Les Frontends)
Stocke les points d'entrée publics (domaines, ports, SSL).
- `hostname`: String (ex: "vibe.com")
- `port`: Int (ex: 443)
- `ssl`: Boolean
- `certificate_id`: Record<proxy_certificate> (Optionnel)
- `cluster_id`: Record<proxy_cluster>
- `status`: "active" | "maintenance" | "disabled"

### B. Table `proxy_cluster` (Le Routage)
Définit comment le trafic est réparti.
- `name`: String (ID unique du cluster)
- `load_balancing`: "round_robin" | "least_conn" | "random"
- `sticky_session`: Boolean
- `health_check`: Object { path: String, interval: Duration }

### C. Table `proxy_backend` (Les Cibles)
Les serveurs réels vers lesquels Sōzu envoie le trafic.
- `cluster_id`: Record<proxy_cluster>
- `address`: String (ex: "127.0.0.1:8080")
- `weight`: Int (par défaut 100)
- `enabled`: Boolean

### D. Table `proxy_metrics` (L'Observation)
Table de type "Time-Series" ou mise à jour périodique pour l'IA.
- `target_id`: Record<proxy_ingress | proxy_cluster>
- `request_count`: Int
- `error_rate`: Float
- `latency_p99`: Duration
- `last_update`: Datetime

## 2. Événements (Event Handlers / Triggers)

Pour chaque modification SQL, un événement doit synchroniser la RAM de Sōzu :

- **EVENT `sync_ingress` ON `proxy_ingress`**:
  - `AFTER CREATE`: Appelle `proxy::ingress::add($after)`
  - `AFTER UPDATE`: Appelle `proxy::ingress::update($after)`
  - `AFTER DELETE`: Appelle `proxy::ingress::del($before)`

- **EVENT `sync_backend` ON `proxy_backend`**:
  - `AFTER CREATE/UPDATE`: Met à jour la liste des backends dans le worker Sōzu correspondant.

## 3. Fonctions Natives à Implémenter (`lyxal_db/core/src/fnc/proxy.rs`)

### Catégorie `proxy::ingress`
- `fn add(host, options)`: Enregistre un nouveau frontend dans Sōzu.
- `fn remove(host)`: Supprime un frontend.
- `fn set_maintenance(host, bool)`: Bascule instantanée en mode maintenance.

### Catégorie `proxy::cluster`
- `fn add_backend(cluster, addr)`: Ajoute une cible de routage.
- `fn remove_backend(cluster, addr)`: Retire une cible proprement (Drain).

### Catégorie `proxy::metrics`
- `fn get(id)`: Appelle `to_filtered()` sur le worker Sōzu et retourne la `Value`.

## 4. Intégration MCP (Model Context Protocol)

- Exposer l'outil `query_proxy_state`: Permet à l'IA de faire un `SELECT` sur les tables ci-dessus.
- Exposer l'outil `configure_proxy`: Permet à l'IA d'exécuter des fonctions `proxy::*` via SQL.

---
*Note: Ce schéma garantit que Sōzu reste ultra-rapide (RAM) tout en devenant totalement pilotable par l'IA via SurrealQL.*

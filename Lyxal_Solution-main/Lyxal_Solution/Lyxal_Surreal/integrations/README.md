## Module: integrations (draft)

### Périmètre
- Fournisseurs (providers) et actions (nodes) réutilisables par toute l’application.
- Adapters de requêtes HTTP (fetch) par provider.
- Miroirs des ressources externes (copie de référence locale).
- Gestion des credentials (références; détails sensibles gérés ailleurs ou chiffrés).
- Hors périmètre: workflows et orchestration (module automation).

### Structure envisagée
- database/
  - providers, nodes, mirrors (tables génériques)
- resources/
  - fonctions d’exécution `fn::integrations_node_<key>_execute($inputs, $ctx)`
  - adapters `fn::integrations_provider_<name>_fetch(...)`
- reference/
  - tags, catégories, jeux de données initiaux (optionnel)

### Conventions
- Nommage node: `<provider>:<action>` (ex: `bunny:dnszone_create`).
- Enum `node_type`: api_action, data_transform, trigger, control_flow, storage, utility.
- Exécution standard: `fn::integrations_node_<key>_execute($inputs, $ctx)`
  - $inputs = uniquement variables dynamiques exposées en UI
  - $ctx = credential_id, env, tracing
- Adapters provider: `fn::integrations_provider_<name>_fetch($path, $method, $headers?, $query?, $body?)`
  - Injecte base_url, auth, retries, error mapping, rate-limit.

### Miroirs de ressources externes
- Table générique avec: provider, resource_type, external_id (UNIQUE par provider), name/slug, status, payload_json, last_synced_at, sync_status, sync_error.
- Flux CRUD: API → upsert miroir; lecture UI depuis le miroir; “sync now” pour rafraîchir.
- Normalisation minimale: dupliquer en colonnes indexées les champs très filtrés.

### Exécution (scripting fetch activé)
- Les fonctions d’exécution utilisent `fetch(...)` JS côté Surreal.
- Les nodes API fixent method/url/headers dans la fonction; seules les variables utiles sont demandées en $inputs.

### Intégration avec automation
- Automation consomme les nodes via des workflows, mais ne les définit pas.
- Ordre d’import recommandé: system → storage → integrations → builder → automation → deploy.

# Node - Définition et périmètre (draft)

## Qu’est-ce qu’un "node" dans notre système ?
- Identité fonctionnelle exécutable: une unité de traitement/action que l’on peut configurer et exécuter.
- Porte une logique d’exécution (fn::automation_node_<key>_execute) et une définition design-time (params, UI, doc).
- Est versionnable/confiurable indépendamment d’un provider.

## Exemple
- Node "HTTP Request": exécute une requête HTTP paramétrable.
- Node "Bunny - Upload": envoie un fichier sur Bunny Storage.

## Node vs Provider
- Provider (ex: Bunny) = organisation/service qui expose des APIs/ressources.
- Node = une opération concrète (ou un groupe cohérent d’opérations) appuyée sur ce provider.
- Un provider peut avoir plusieurs nodes (Upload, List, Delete, etc.).

## Conséquences de modélisation
- Table automation_node = identité du node (name, key, display_name, icon, usable_as_tool, routing_json, ...).
- Provider (organisation) vit ailleurs (ex: table organisation/service) et est référencé par des nodes si utile.
- Les paramètres d’un node (automation_node_param*) décrivent l’UI/design-time; l’exécution appelle une fn dédiée.

## Ouvert
- Granularité: un node par opération ou node multi-opérations avec paramètre "operation" ?
- Partage de credentials entre nodes du même provider.

## Choix (draft à valider avant implémentation)
- Lier chaque node à une catégorie et une sous-catégorie (taxonomie visible).
- Champs minimaux d’un node: name (unique), provider (optionnel), category, subcategory, node_type.
- Enum node_type (extensible):
  - api_action: appelle une API externe (method/url/headers prédéfinis dans la fn, UI n’affiche que les variables dynamiques)
  - data_transform: transformation locale de données
  - trigger: déclencheur (webhook/event)
  - control_flow: contrôle de flux (if/switch/merge)
  - storage: opérations de stockage (ex: Bunny Storage)
  - utility: utilitaires (uuid, now, etc.)

### Pattern d’exécution (1 fn = 1 node)
- Nom: fn::automation_node_<key>_execute($inputs, $ctx)
- $inputs: uniquement les variables dynamiques (ex: domain)
- $ctx: contexte d’exécution (ex: credential_id, env)
- La fn embarque method/url/headers par défaut; utilise fetch (scripting activé)

Exemple (schéma d’intention, sans implémenter):
```sql
-- fn::automation_node_bunny_dnszone_create_execute($inputs, $ctx)
-- inputs attendus: { domain: string, credential_id?: string }
-- method/url/headers fixés dans la fn; body construit depuis inputs
```

### Inputs runtime minimaux (sans credentials pour l’instant)
- method: fixé dans la fn pour api_action (ex: POST)
- url (ou base_url + path): fixé dans la fn
- headers: fixés par défaut dans la fn (accept/json)
- query: optionnel
- body: construit depuis $inputs
- UI par node: formulaire spécifique ne montrant que les variables dynamiques (ex: domain)

## Principe: miroir des ressources externes (tous providers)
- Objectif: conserver dans Surreal une copie de référence des ressources créées/consultées via les APIs externes (Bunny, Google, Facebook, ...).
- Bénéfices: UI rapide, recherche/tri/index, centralisation des données, moins d’appels externes, DX simplifiée.
- Modèle minimal (par ressource):
  - provider, external_id (UNIQUE avec provider)
  - credential, environment (si pertinent)
  - name/slug, status, payload_json (réponse brute filtrée)
  - last_synced_at, sync_status, sync_error
- Flux:
  - create/update/delete: exécuter l’API → upsert du miroir avec la réponse → timestamps/sync_status
  - read/list: lire depuis le miroir; bouton/endpoint “sync now” pour rafraîchir à la demande
- Sécurité: ne pas persister de secrets dans payload_json; gérer les accès via permissions.
- Cohérence: éventuelle; on expose last_synced_at + sync_status pour transparence.

### Feuille de route — Menu 100% dynamique piloté par SurrealDB

#### Objectif
- **But**: Remplacer la liste statique du menu par des items chargés depuis SurrealDB, filtrés par modules/roles, avec icônes et événements déclaratifs.
- **Résultat**: Un menu entièrement configurable sans changer le code frontend; mise à jour en temps réel possible.

#### Portée
- Backend (SurrealDB): tables, ressources (CRUD/list), données de référence, orchestration de déploiement.
- Frontend (Lyxal_Portal): service de chargement, registres d’icônes/événements, intégration dans `Sidebar`, option live.

#### Conventions projet (rappel)
- `DEFINE ... IF NOT EXISTS` pour idempotence.
- Fonctions Surreal: `RETURN function() { ... }` (sans `async`).
- Logs d’étapes: log start/done systématiques.
- Paramètres passés en arguments simples (strings), pas d’objets imbriqués.

## Phase 1 — Schéma base (module conseillé: `system/ui`)
- Table `ui_menu_item` (TYPE NORMAL, SCHEMAFULL, PERMISSIONS FULL)
  - Champs:
    - `key` (string, unique): clé technique.
    - `name_i18n` (option<string>): clé i18n du libellé.
    - `tooltip_i18n` (option<string>): clé i18n du tooltip.
    - `route` (option<string>): chemin de navigation.
    - `icon_key` (option<string>): clé d’icône (mappée côté UI).
    - `order` (int, défaut 0): tri dans le parent.
    - `parent` (option<record<ui_menu_item>>): hiérarchie.
    - `module_key` (option<string>): clé de module (ex: `dashboard`, `integrations`).
    - `roles` (option<array<string>>): rôles autorisés (facultatif, pour futur auth).
    - `event_key` (option<string>): événement logique (fallback si pas de `route`).
    - `enabled` (bool, défaut true).
    - `created_at`/`updated_at` (datetime auto).
  - Index:
    - `key UNIQUE` pour unicité.
    - (Optionnel) index de tri `parent, order`.

Exemple Surreal (extrait):
```sql
DEFINE TABLE IF NOT EXISTS ui_menu_item SCHEMAFULL TYPE NORMAL
  COMMENT 'Items du menu principal pilotés par la base.'
  PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS key ON TABLE ui_menu_item TYPE string
  ASSERT string::len($value) > 0;
DEFINE FIELD IF NOT EXISTS name_i18n ON TABLE ui_menu_item TYPE option<string>;
DEFINE FIELD IF NOT EXISTS tooltip_i18n ON TABLE ui_menu_item TYPE option<string>;
DEFINE FIELD IF NOT EXISTS route ON TABLE ui_menu_item TYPE option<string>;
DEFINE FIELD IF NOT EXISTS icon_key ON TABLE ui_menu_item TYPE option<string>;
DEFINE FIELD IF NOT EXISTS order ON TABLE ui_menu_item TYPE int VALUE $value OR 0;
DEFINE FIELD IF NOT EXISTS parent ON TABLE ui_menu_item TYPE option<record<ui_menu_item>>;
DEFINE FIELD IF NOT EXISTS module_key ON TABLE ui_menu_item TYPE option<string>;
DEFINE FIELD IF NOT EXISTS roles ON TABLE ui_menu_item TYPE option<array<string>>;
DEFINE FIELD IF NOT EXISTS event_key ON TABLE ui_menu_item TYPE option<string>;
DEFINE FIELD IF NOT EXISTS enabled ON TABLE ui_menu_item TYPE bool VALUE $value OR true;
DEFINE FIELD IF NOT EXISTS created_at ON TABLE ui_menu_item TYPE datetime VALUE $value OR time::now();
DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ui_menu_item TYPE datetime VALUE $value OR time::now();

DEFINE INDEX IF NOT EXISTS ui_menu_key_unique ON TABLE ui_menu_item FIELDS key UNIQUE;
```

(Optionnel) Table `ui_menu_event` si on veut déclarer les événements de manière stricte: `key`, `description`, `params_schema_json`.

## Phase 2 — Ressources Surreal (CRUD + listing)
- Fonctions à créer (exemples):
  - `fn::ui_menu_item_create(key, name_i18n, tooltip_i18n, route, icon_key, order, parent, module_key, roles, event_key, enabled)`
  - `fn::ui_menu_item_update(key, ...)`
  - `fn::ui_menu_item_delete(key)`
  - `fn::ui_menu_item_get(key)`
  - `fn::ui_menu_item_list($only_enabled: option<bool>, $module_key: option<string>)` (filtrage + tri parent/order)
- Règles:
  - Validations minimales (clé non vide, unicité).
  - Timestamps `created_at/updated_at`.
  - Logs `start`/`done` avec `run_id`.
- Données de référence initiales (racine):
  - `dashboard`, `investors`, `platforms`, `analytics`, `finance`, `integrations`, `settings` avec `module_key` aligné à `config.ui.modules`.

## Phase 3 — Orchestration de déploiement
- Créer:
  - `fn::ui_database_deploy_initialise` / `fn::ui_database_deploy`
  - `fn::ui_resources_deploy_initialise` / `fn::ui_resources_deploy`
  - `fn::ui_reference_deploy_initialise` / `fn::ui_reference_deploy`
  - `fn::ui_deploy_initialise` / `fn::ui_deploy`
- Intégrer `ui_deploy` dans `deploy/deploy_general.surql` (nouvelle étape UI). Conserver l’ordre global.

## Phase 4 — Frontend (Lyxal_Portal)
- Service `MenuService`:
  - `list(): Promise<MenuItem[]>` via Surreal (puis live query plus tard).
  - Fallback local si indisponible.
- Registre d’icônes:
  - Mapping `icon_key -> <Icon />` (SVGs existants + nouveaux).
- Registre d’événements:
  - Mapping `event_key -> handler()` (ex: `openIntegrations` → navigate `/integrations`).
  - Règle d’exécution: si `route` existe → navigate; sinon si `event_key` → handler.
- Intégration `Sidebar`:
  - Remplacer la liste statique par `MenuService.list()`.
  - Filtrer côté UI avec `config.ui.modules[module_key] !== false` et rôles utilisateur.
  - Option: activer live query pour mise à jour en temps réel.

## Phase 5 — Sécurité & rôles
- Décider du filtrage:
  - Côté DB (permissions/claims) et/ou côté UI (rôles du user).
- Prévoir intégration auth ultérieure (claims dans contexte des requêtes).

## Phase 6 — i18n
- Stocker des clés (`name_i18n`, `tooltip_i18n`) en base.
- Résolution côté UI via la librairie i18n; fallback sur la clé brute.

## Phase 7 — Feature flag & migration progressive
- Ajouter `config.ui.useDynamicMenu` (bool).
- Étape 1: charger dynamique si flag `true`, sinon liste statique.
- Étape 2: activer par défaut; supprimer la liste statique.

## Phase 8 — Tests & validation
- Backend: tests des fonctions de liste/tri/filtre.
- UI: rendu, tooltips, navigation, icônes, rôles, modules désactivés.
- Cas limites: item sans route mais avec `event_key`, hiérarchie profonde, modules off.

## Phase 9 — Performance
- Index `key` et `(parent, order)`.
- Projections minimales côté requêtes.
- Mémoïsation côté UI; cache léger; invalidation via live query.

## Livrables
- SurrealDB: `.surql` (tables, ressources, références, déploi UI + intégration dans `deploy_general`).
- Frontend: `MenuService`, registres `icons`/`events`, `Sidebar` dynamique.
- Documentation: ce fichier + exemples d’items et d’événements.

## Exemple d’item (référence)
```sql
RETURN fn::ui_menu_item_create(
  'integrations',
  'menu.integrations.name',
  'menu.integrations.tooltip',
  '/integrations',
  'integrations',
  50,
  NONE,
  'integrations',
  ['admin'],
  NONE,
  true
);
```

## Exemple d’utilisation côté UI (idée)
```ts
type MenuItem = {
  key: string;
  name: string; // résolu depuis name_i18n
  tooltip?: string; // résolu depuis tooltip_i18n
  route?: string;
  iconKey?: string;
  order: number;
  parent?: string;
  moduleKey?: string;
  roles?: string[];
  eventKey?: string;
  enabled: boolean;
};

const eventRegistry: Record<string, () => void> = {
  openIntegrations: () => navigate('/integrations'),
};

const items = (await MenuService.list()).filter(i =>
  i.enabled !== false &&
  (i.moduleKey ? config.ui?.modules?.[i.moduleKey as keyof typeof config.ui.modules] !== false : true)
);

function onClick(item: MenuItem) {
  if (item.route) navigate(item.route);
  else if (item.eventKey) eventRegistry[item.eventKey]?.();
}
```



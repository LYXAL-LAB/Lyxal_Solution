# Plan d'implémentation — plusieurs hôtes sur une même base

Décision du CTO du 19 novembre 2026 (programme courrier, agendas et contacts, §4.3 et P3) : un
hôte dédié `apps/lyxal-groupware` tournera à côté de `apps/lyxal-server` sur la même base
SurrealDB, et le moteur est corrigé pour que **chaque hôte ne traite que les événements et les
tâches de ses propres modules**. Ce plan décrit ce correctif. Il doit être validé avant le lot 3
du programme. Aucune ligne de code avant la validation du CTO (`.agents/AGENTS.md` §3).

Touche : `lyxal_runtime`, `lyxal_event`, `lyxal_scheduler`, `apps/lyxal-server`, la documentation
(`.agents/AGENTS.md` §5.6.4 et §5.8, skill `lyxal-runtime-integration`, README des trois crates).
Aucun besoin nouveau dans `lyxal_core` ni dans `lyxal_crypto`.

Méthode : constats vérifiés **par lecture du code** (références `fichier:ligne`). Rien n'a été
compilé ni exécuté pour ce plan ; le seul essai réel est celui du lot 0
(`crates/lyxal_runtime/tests/it/two_hosts_shared_database_tests.rs`, moteur d'événements
désactivé, ligne 180). Ce qui n'est pas vérifié est marqué « non vérifié ».

## 1. Ce que l'on veut, en clair

- Deux programmes différents (`lyxal-server`, `lyxal-groupware`) utilisent la même base. Chacun
  a ses modules. Certains modules sont communs (par exemple `lyxal_auth`).
- Un événement destiné à un traitement du courrier est traité par `lyxal-groupware`, jamais par
  `lyxal-server`, et inversement. Même règle pour les tâches planifiées.
- Si un des deux programmes est arrêté, ses événements et ses tâches **attendent** son retour.
  Rien n'est perdu, rien n'est classé « en échec » à cause de cette absence. L'autre programme
  continue normalement et **signale** l'attente dans son état de santé.
- On peut lancer plusieurs copies du même programme (montée en charge) : elles se répartissent
  le travail comme aujourd'hui, avec un seul « chef » par responsabilité.

## 2. Constats

| N° | Constat | Preuve | Gravité |
| :- | :--- | :--- | :--- |
| **K1** | Un seul bail pour toute la base : `event_stream_lease:outbox_leader`. Le worker élu lit **toutes** les livraisons en attente et cherche le handler dans le registre de **son** processus, par type d'événement. Handler absent : la livraison est comptée en échec, réessayée, puis mise en dead letter. Le handler de l'autre hôte n'est jamais appelé. | bail : `crates/lyxal_event/functions/event_lease_acquire.surql:32` (et 5 autres fonctions, même identifiant) ; lecture sans filtre d'hôte : `functions/event_delivery_fetch_pending.surql:51-60` ; registre du processus : `crates/lyxal_runtime/src/runtime.rs:356-376` ; handler absent : `crates/lyxal_event/src/engine/consumer_bridge.rs:294-306` puis `:514-524` | Bloquant |
| **K2** | Le filtre `instance_id` ne sépare pas les hôtes : les événements émis par la base portent `instance_id: "default"` ; un worker réglé sur une autre valeur ne les lit jamais (ils restent `pending`). `lyxal-server` le laisse donc vide. | `functions/event_publish.surql:16` ; `event_delivery_fetch_pending.surql:55` ; `apps/lyxal-server/src/runtime.rs:65-71` | Explique « en attente pour toujours » |
| **K3** | `start_all` rappelle `LyxalModule::install`, hors bail, pour tout module resté à l'état `Registered`. C'est le cas de chaque module dont la release était déjà installée (deuxième hôte, et **tout redémarrage**) : l'installateur rend `AlreadyInstalled` sans changer l'état local. | `crates/lyxal_runtime/src/runtime.rs:733-735` ; `src/package/installer.rs:366-381` ; `runtime.rs:598-603` | Contredit §5.8.2 |
| **K4** | Réconciliateur, mode strict : tout module **vu dans la base** et absent de l'état désiré devient `Absent`, donc aussi les modules de l'autre hôte. L'action `MarkInactive` n'écrit rien si le module n'est pas dans le registre local, mais elle est rangée dans `executed` avec `success: true`. | `src/reconciler/differ.rs:66-74` ; `src/reconciler/reconciler.rs:281-309` ; essai : `two_hosts_shared_database_tests.rs:485-491` | Faux compte rendu |
| **K5** | Planificateur : l'exécuteur donne déjà la liste de ses handlers et laisse les tâches des autres… **sauf** celles qui attendent depuis plus que leur délai maximal : il les réserve et les termine en `SCHEDULER_HANDLER_NOT_FOUND` (échec réessayable, donc exécution `dead` après épuisement). Un hôte arrêté plus longtemps que le délai d'une tâche perd donc ses exécutions. | `crates/lyxal_scheduler/functions/scheduler_worker.surql:94-99` et `:108` ; `src/engine/attempt.rs:104-108` ; `src/engine/executor.rs:121` | Bloquant (non essayé) |
| **K6** | Sonde du planificateur : un hôte se déclare « dégradé » dès qu'une file n'a pas d'exécuteur **sur lui**, même si l'autre hôte la sert. Les exécuteurs sont créés une fois, au démarrage, pour les files connues à ce moment. | `crates/lyxal_scheduler/src/health.rs:55-60` et `:69-73` ; `apps/lyxal-server/src/modules/scheduler.rs:89-110` | Fausse alerte |
| **K7** | Une release déjà installée n'est jamais comparée au contenu du binaire qui démarre : deux binaires de commits différents, même numéro `0.1.0`, donnent une base au contenu de l'un et un programme qui croit avoir le sien. Le champ `runtime_release.checksum` existe mais l'installateur ne le remplit pas. | `installer.rs:192-199` ; `crates/lyxal_runtime/schema/fields.surql:18` ; `src/store/models.rs:83` | Risque silencieux |
| **K8** | Le socle (`lyxal_core`, `lyxal_error`, schéma du runtime) est réinstallé par `DEFINE … OVERWRITE` à chaque démarrage de chaque binaire, et par la commande de reprise des migrations, sans bail ni trace : le dernier démarré impose sa version. | `apps/lyxal-server/src/modules/mod.rs:122-144` ; `src/runtime.rs:46-49` et `:57` | Risque silencieux |
| **K9** | `runtime_worker` et `runtime_health` sont rangés par nœud (correct), mais l'identifiant de nœud est tiré au sort à chaque démarrage et aucune fonction ne supprime les lignes : elles s'accumulent, et rien ne dit à quel hôte appartient un nœud. | `schema/indexes.surql:15-17` ; `src/lock/node_id.rs:17-19` ; `functions/runtime_worker.surql` (aucun `DELETE`) | Mineur |

Points examinés **sans défaut** pour plusieurs hôtes :

- **Planificateur élu** (bail `leader`, clé `scheduler`) : son travail (échéances, rattrapage, reprise des baux expirés) est en base ou en Rust générique ; il n'utilise aucun handler (`src/engine/leader.rs`, `src/engine/mod.rs:29`).
- **Tâches `function`** : appel d'une fonction SurrealQL de la base (`attempt.rs:125-145`) ; **tâches `event`** (publications différées) : `fn::scheduler_run_publish` (`attempt.rs:147-158`). Aucun code propre à un hôte.
- **Ventilation et purge des événements** : en base ; la ventilation est protégée par un index unique (`schema/event_delivery.surql`, `idx_delivery_unique_fanout`) ; la purge ne supprime jamais une livraison en attente ni son événement (`functions/event_purge_garbage.surql:30-46`).
- **Curseurs** : déjà un par abonnement (`functions/event_delivery_assign_seq.surql:88-102`).
- **Santé** : les sondes sont celles du processus (`src/health/engine.rs:105`) ; `runtime_module` ne porte aucun état d'exécution (`schema/fields.surql:6-10`).
- **Workers de `lyxal_notification` et de `lyxal_pipeline_ingestion`** : réservation par jeton sur leurs propres tables (`functions/notification_broadcast.surql:15-40`, `src/worker/ingestion_worker.rs:14`) ; ils ne tournent que sur l'hôte qui les enregistre. **Fil en temps réel** : une requête `LIVE SELECT` par processus, pour ses propres clients (`apps/lyxal-server/src/modules/notification_feed.rs:3`). Lus rapidement, non essayés à deux hôtes.

## 3. Cible

### 3.1. Vocabulaire

| Terme | Définition | Exemple |
| :--- | :--- | :--- |
| **Hôte** | Le rôle d'un binaire : un nom stable, le même pour toutes ses copies. Constante du binaire, égale à l'`id` de son manifeste d'hôte (`apps/lyxal-server/src/modules/mod.rs:73`). Format d'un identifiant de module (`^[a-z][a-z0-9_]*$`, 64 caractères au plus). Non réglable par configuration : deux noms pour un même binaire créeraient deux propriétaires pour les mêmes abonnements. | `lyxal_server`, `lyxal_groupware` |
| **Nœud** | Un processus en cours. Identifiant tiré au sort au démarrage, comme aujourd'hui (`NodeId::generate`). Sert aux baux. | `node-0193…` |

### 3.2. Comment la base sait qui sert quoi

| Sujet | Où c'est écrit | Écrit quand | Nettoyé quand |
| :--- | :--- | :--- | :--- |
| Nœuds en marche, leur hôte, leurs modules | nouvelle table `runtime_node` | au démarrage, puis toutes les 10 s (battement) | à l'arrêt propre ; après 7 jours sans battement, avec les lignes `runtime_worker` et `runtime_health` du nœud |
| Hôte d'un abonnement | nouveau champ `event_subscription.host`, recopié sur chaque livraison (`event_delivery.host`) | à l'enregistrement de l'abonnement par l'hôte qui porte le handler | jamais seul : changement d'hôte par une fonction d'exploitation (§5.2) |
| Chef des événements d'un hôte | `event_stream_lease:<hôte>` (un bail par hôte) | élection, comme aujourd'hui | expire seul (5 s) |
| Handlers de tâches d'un nœud | `scheduler_node` (existe), plus le champ `host` | à chaque réservation | ligne ignorée après 1 min sans réservation (existant) |

### 3.3. Garanties

1. Une livraison n'est lue, numérotée, exécutée et soldée que par le chef de l'hôte de son abonnement. Aucun autre hôte ne la touche : ni essai compté, ni dead letter.
2. Une tâche `handler` n'est réservée que par un nœud qui a ce handler, quelle que soit son attente.
3. Hôte absent : ses livraisons restent `pending` et ses exécutions `queued`, sans limite de durée. L'hôte présent le signale (sondes, §5.4).
4. Livraison au moins une fois, numéros sans trou par abonnement, curseur contigu, garde de génération, barrière dead letter, reprise après coupure : inchangés (§4.2).
5. Plusieurs nœuds d'un même hôte : un seul chef des événements pour cet hôte ; un seul planificateur pour toute la base.
6. Un hôte arrêté ne bloque ni l'installation, ni le démarrage, ni le travail de l'autre.

## 4. Options

### 4.1. Moteur d'événements

| Option | Principe | Curseur et contiguïté | Bilan |
| :--- | :--- | :--- | :--- |
| **A — un chef par hôte** *(recommandée)* | Bail par hôte. Chaque abonnement appartient à un hôte. Le chef d'un hôte ne lit que les livraisons de son hôte. | Inchangés : un curseur par abonnement, un seul écrivain par abonnement (le chef de son hôte). `fn::event_flush_batch` garde sa logique ; seule la garde change de bail. | Modifie 9 fonctions et 3 tables, peu de Rust. Les hôtes sont indépendants. |
| **B — un numéroteur global, un distributeur par hôte** | Un chef unique attribue les numéros ; chaque hôte exécute ses livraisons. | Deux écrivains par abonnement (numéro, puis solde) : il faut un état durable de passage de main et une deuxième garde. Aujourd'hui numérotation, verrou et mise en file se font en un seul geste (`worker.rs:569-579`). | Réécrit le cœur du moteur ; le chef global reste un point commun aux deux hôtes. Écartée. |
| **C — le chef saute ce qu'il ne sait pas traiter** | Bail unique ; handler absent = livraison laissée. | Inchangés. | Tant que A est chef, personne ne sert B : il faudrait un deuxième chef, donc l'option A. Écartée. |
| A' — un bail par abonnement | Variante plus fine de A. | Inchangés. | Un battement par abonnement toutes les 2 s, sans besoin actuel. Écartée. |

Conséquences de A :

- **Hôte absent** : la ventilation crée quand même ses livraisons (elle se fait en base, par n'importe quel hôte). Elles attendent. Aucune dead letter pour absence. Une alerte apparaît après un délai (H4).
- **Même type d'événement écouté sur deux hôtes** : deux abonnements, un par hôte, donc deux livraisons ; chacune va au handler de son hôte. Fonctionne.
- **Même abonnement réclamé par deux hôtes** : refus à l'enregistrement (`EVENT_SUBSCRIPTION_HOST_CONFLICT`) ; le second hôte ne démarre pas. C'est une erreur de montage, pas un cas d'exploitation.
- **Deux handlers pour un même type dans un même hôte** : toujours refusé (`crates/lyxal_event/src/handler/registry.rs:33-37` ; le champ `handler_name` de l'abonnement ne sert pas au choix du handler). Ce n'est pas un défaut de plusieurs hôtes : laissé hors de ce plan (H9).

### 4.2. Effet sur les invariants du §5.6.4

| Invariant | Avant | Après |
| :--- | :--- | :--- |
| Garde de génération | sur `event_stream_lease:outbox_leader` | sur `event_stream_lease:<hôte>`, **plus** un contrôle dans la même écriture : l'abonnement appartient à cet hôte, sinon `EVENT_SUBSCRIPTION_NOT_OWNED` |
| Contiguïté sans trou | curseur `prog_<abonnement>` | identique |
| Barrière dead letter | `fn::event_dead_letter_transfer` avant le curseur | identique, garde du bail de l'hôte |
| Reprise après coupure | relecture à l'expiration de `locked_until`, numéro conservé | identique, par hôte |

### 4.3. Planificateur

| Question | Choix | Raison |
| :--- | :--- | :--- |
| Qui exécute une tâche `handler` ? | Le nœud qui **a le handler** (liste déjà envoyée à chaque réservation). On supprime l'exception du délai dépassé. Pas de champ « hôte » sur la tâche. | Une seule source : le code réellement chargé. Rien à tenir à jour ; une tâche servie par deux hôtes reste possible. |
| Tâches `function` et `event` | Tout hôte qui héberge `lyxal_scheduler` peut les exécuter. | Elles ne lancent que du SurrealQL présent dans la base. Les restreindre ferait attendre des tâches sans raison quand un hôte est arrêté. Les places d'une file sont déjà communes (`scheduler_worker.surql:33`). |
| Élection du planificateur | Une seule pour la base (inchangée). | Il n'exécute aucun code de module. Deux planificateurs doubleraient les exécutions. |
| Trois tâches de `lyxal-server` (`auth.purge`, `storage.cleanup`, `secrets.maintenance`) | Inchangées : déclarées par ses seeds, handlers inscrits par lui seul (`apps/lyxal-server/src/modules/tasks.rs`). `lyxal-groupware` ne les réserve jamais. `lyxal-server` arrêté : elles attendent. | Découle du premier choix. |
| Ce que voit l'exploitant | Sonde `lyxal_scheduler` de l'hôte présent : « dégradé », avec les tâches sans nœud actif, le nombre d'exécutions en attente, la plus ancienne et le dernier hôte qui les servait. Une file n'est signalée que si **aucun** nœud ne la sert. | Corrige K6 ; le message « sans handler sur aucun nœud actif » existe déjà (`health.rs:79-84`). |

## 5. Contrats

Régime zéro dette (§0) : les contrats changent sans alias, tous les appelants sont mis à jour dans
le même lot. `lyxal_event` et `lyxal_runtime` n'ont pas de migration à réécrire pour ces tables
(schémas rejoués) ; pour `lyxal_scheduler`, `schema/03_scheduler_queue.surql` est modifié en place.
Une base de développement existante est supprimée et recréée.

Fonctions de `lyxal_core` réutilisées : `fn::validation_object_execute` (fonctions publiques),
primitives `fn::validation_required_string`, `fn::validation_regex`, `fn::validation_integer`,
`fn::validation_record_id`, `fn::validation_language_code` (fonctions internes du moteur
d'événements, comme aujourd'hui). Fonctions Core manquantes : aucune. Besoin crypto : aucun
(l'empreinte d'une release utilise `lyxal_crypto::hash::sha256_hex`, déjà employée par
`crates/lyxal_runtime/src/migration/checksum.rs`).

### 5.1. `lyxal_runtime`

| Élément | Changement |
| :--- | :--- |
| Rust `HostId` (nouveau, à côté de `NodeId`) | `HostId::new(&str) -> Result<HostId, RuntimeError>` (format du §3.1). |
| `RuntimeConfig::new(host: HostId)` | L'hôte devient obligatoire ; `Default` retiré. `LyxalRuntime::host_id()`. Environ 45 appels à mettre à jour (43 dans les tests du crate, 2 dans `apps/lyxal-server`). |
| Table `runtime_node` (nouvelle) | `node_id` (unique), `host`, `modules: array<string>`, `foundation_checksum`, `started_at`, `seen_at`. `PERMISSIONS NONE`. |
| `fn::runtime_node_upsert($params)` | `{ node_id, host, modules, foundation_checksum }` → ligne écrite. `RuntimeNodeUpsertParams` / `RuntimeNode`. |
| `fn::runtime_node_remove($params)` | `{ node_id }` ; supprime aussi `runtime_worker` et `runtime_health` du nœud. |
| `fn::runtime_node_list($params)` | `{ alive_within }` → nœuds avec `alive: bool`. |
| `fn::runtime_node_purge($params)` | `{ older_than }` (7 j par défaut) → nombre de nœuds retirés, avec leurs lignes. |
| Worker `lyxal_runtime.presence` | Battement toutes les 10 s, purge une fois par heure. `Optional`. |
| Hook `install` | Appelé **seulement** par l'installateur, sous bail, une fois par release pour toute la base. `AlreadyInstalled` passe l'état local à `Installed` sans hook (nouvelle `LifecycleManager::mark_installed`). `start_all` ne l'appelle plus (`runtime.rs:733-735` retiré) : un module `Registered` au démarrage est une erreur `InvalidStateTransition`. `install_all` reste pour les runtimes sans base (tests). Règle documentée : `install` = écriture en base, rejouable ; tout réglage propre au processus va dans `start`. |
| Empreinte de release | L'installateur remplit `runtime_release.checksum` (SHA-256 des fichiers de `[resources]`, chemin et contenu, dans l'ordre déclaré). Release installée avec une autre empreinte : refus `RUNTIME_RELEASE_CHECKSUM_MISMATCH` (nouveau code). |
| Socle | Nouvelle `lyxal_runtime::schema::install_foundation(client, node, modules)` : installation sous bail d'installation (clé réservée `foundation`), empreinte écrite dans `runtime_foundation:current` (`checksum`, `host`, `node_id`, `installed_at`). Un binaire d'empreinte différente réinstalle (comme aujourd'hui) et l'écrit ; les autres nœuds le voient à leur battement et leur sonde passe à « dégradé ». |
| Réconciliateur | Le mode strict ne vise que les modules **enregistrés dans ce runtime**. Les autres modules de la base sont listés dans `ReconciliationPlan::foreign_modules` (module, hôtes vivants qui le déclarent), sans action. `MarkInactive` sur un module non enregistré : échec `UnknownModule`, plus jamais « exécuté ». |
| Erreurs (`error/runtime.surql`) | `RUNTIME_RELEASE_CHECKSUM_MISMATCH`, `RUNTIME_HOST_INVALID`. |

### 5.2. `lyxal_event`

| Élément | Changement |
| :--- | :--- |
| `event_subscription` | + `host: string` (obligatoire, format du §3.1) ; index `(host)`. |
| `event_delivery` | + `host: string` ; `idx_delivery_claim_eligibility` devient `(host, status, next_retry_at)`. |
| `event_stream_lease` | + `host: string` ; identifiant de l'enregistrement = hôte. `outbox_leader` disparaît. |
| `fn::event_subscription_register($params)` | + `host` obligatoire. Abonnement existant d'un autre hôte : `EVENT_SUBSCRIPTION_HOST_CONFLICT`. |
| `fn::event_subscription_transfer($params)` (nouvelle) | `{ name, host }` : change l'hôte de l'abonnement et de ses livraisons non soldées. Refus `EVENT_HOST_ACTIVE` si le bail de l'ancien hôte est encore vivant. Session système. `SubscriptionTransferParams` / `SubscriptionTransferResult`. |
| `fn::event_fanout` | Recopie `host` de l'abonnement sur la livraison. |
| `fn::event_delivery_fetch_pending` | + `host` obligatoire, filtre `host = $host`. Les livraisons orphelines (abonnement supprimé) restent à l'hôte inscrit sur la livraison. |
| `fn::event_lease_acquire`, `_renew`, `_release` | + `host` obligatoire. |
| `fn::event_delivery_assign_seq`, `fn::event_flush_batch`, `fn::event_dead_letter_transfer` | + `host` obligatoire ; garde sur le bail de l'hôte ; contrôle de propriété (§4.2). |
| `fn::event_backlog($params)` (nouvelle) | `{ older_than }` (5 min par défaut) → par hôte : livraisons en attente, date de la plus ancienne, `leader_alive`, `leader_node`. `EventBacklogParams` / `EventBacklog`. |
| Erreurs (`error/events.surql`) | `EVENT_SUBSCRIPTION_HOST_CONFLICT`, `EVENT_SUBSCRIPTION_NOT_OWNED`, `EVENT_HOST_ACTIVE`. |
| Rust | `EventWorkerConfig::new(host)` (champ `host` obligatoire, `Default` retiré) ; `OutboxLeaseManager::new(client, host, node_id, ttl)` ; `EventSubscription::new(…, host)` ; DTO `host` dans `engine/dto.rs`. `EventConsumerModule` et `HandlerRegistry` inchangés. Le runtime remplit `host` depuis `RuntimeConfig`. |
| Sonde (nouvelle) | `EventEngineHealthCheck`, enregistrée par le runtime pour `lyxal_event` : « dégradé » si un hôte a des livraisons plus anciennes que le seuil et aucun chef vivant ; le message nomme l'hôte et le nombre. |

Le filtre `instance_id` (K2) n'est pas touché : il ne sert pas à séparer les hôtes et les deux
hôtes le laissent vide.

### 5.3. `lyxal_scheduler`

| Élément | Changement |
| :--- | :--- |
| `fn::scheduler_run_claim($params)` | `handlers` devient obligatoire (liste vide permise) ; + `host` obligatoire, écrit dans `scheduler_node` ; la condition `OR available_at + task.timeout <= $now` est retirée (`scheduler_worker.surql:108`). |
| `scheduler_node` | + `host: string`. |
| `fn::scheduler_health($params)` | `queues[]` gagne `served` (un nœud vivant sert la file) ; + `unserved_tasks: [{ task, waiting, oldest, last_host }]`. |
| Rust | `RunClaimParams { handlers: Vec<String>, host: String, … }` ; `SchedulerEngine::new(store, handlers, node, host)` ; `Health` et `SchedulerHealthCheck` suivent. `SCHEDULER_HANDLER_NOT_FOUND` reste la réponse d'un exécuteur sans handler (`attempt.rs:104`), qui n'arrive plus par la voie normale. Trait `TaskHandler` et `HandlerRegistry` inchangés. |

### 5.4. `apps/lyxal-server`

- `HOST_ID = "lyxal_server"` (l'actuel `SERVER_MODULE_ID`), passé à `RuntimeConfig::new`, à `SchedulerEngine::new` et aux abonnements (`modules/notification.rs:256`, `modules/ingestion.rs:136`).
- `modules::install_foundation` appelle la fonction du runtime (§5.1) ; la commande `runtime migrations` aussi (`src/runtime.rs:46-49`).
- **Aucune clé de configuration nouvelle** (l'hôte est une constante). `application.instance_id` reste une étiquette de journal.
- Route système des modules (`src/http/handlers.rs:8`, `RuntimeObserver`) : ajoute les nœuds vivants et leur hôte.

## 6. Lots

Une demande de fusion par lot, dans cet ordre. Taille par rapport aux lots déjà faits du dépôt.

| Lot | Contenu | Taille | Tests du lot |
| :- | :--- | :- | :--- |
| **1 — Runtime** | `HostId`, `runtime_node` et battement, hook `install` (K3), réconciliateur (K4), empreinte de release (K7), socle sous bail (K8), purge des lignes (K9). | M | Hook : appelé une fois pour un module commun à deux hôtes, zéro fois au redémarrage (retire la réserve notée dans `two_hosts_shared_database_tests.rs`). Réconciliateur strict : aucune action sur le module de l'autre hôte, `foreign_modules` rempli, `executed` vide. Empreinte : même version, contenu différent → refus. Socle : deux démarrages simultanés, un seul sous bail. Présence : ligne écrite, retirée à l'arrêt, purgée après le délai. Tests `.test.surql` des fonctions `runtime_node_*`. |
| **2 — Événements** | Bail par hôte, hôte sur abonnement et livraison, garde et propriété, transfert, `fn::event_backlog`, sonde. | L | Deux hôtes, handlers différents, une base : chaque événement atteint son handler sur le bon hôte, une fois, `event_dead_letter` vide. Un hôte arrêté : ses livraisons restent `pending`, `attempts = 0` ; l'autre livre les siennes ; au retour, tout est livré dans l'ordre des numéros. Deux nœuds du même hôte : un seul chef ; chef tué : le second reprend, numéros conservés, écriture de l'ancien refusée (`EVENT_STALE_LEADER_FENCED`). Écriture sur l'abonnement d'un autre hôte : `EVENT_SUBSCRIPTION_NOT_OWNED`. Conflit d'abonnement, transfert refusé puis accepté. Même type écouté sur deux hôtes. Les tests actuels de `crates/lyxal_event/tests/it/` adaptés (hôte unique). |
| **3 — Planificateur** | Réservation stricte (K5), `host` sur `scheduler_node`, sonde (K6). | S | Deux hôtes : tâche `handler` de B jamais réservée par A, même après son délai ; B arrêté : exécution `queued`, `attempt = 0`, sonde de A « dégradé » et nomme la tâche ; au retour de B, exécutée. Tâches `function` et `event` exécutées par l'un ou l'autre. Un seul planificateur élu pour les deux hôtes ; bascule quand il s'arrête. File servie par l'autre hôte : pas d'alerte. |
| **4 — Hôte, preuves, documentation** | Câblage de `lyxal-server`, route des nœuds, `two_hosts_shared_database_tests.rs` étendu **moteur d'événements activé** (installation, démarrage, réconciliation, redémarrage, arrêt), essai de `lyxal-server` à côté d'un second hôte d'essai (`runtime::start_with`) : les trois tâches de l'hôte ne sont exécutées que par lui ; mise à jour de `.agents/AGENTS.md` §5.6.4 et §5.8, du skill `lyxal-runtime-integration`, des README et de `docs/ARCHITECTURE.md`, `docs/SURREALQL_API.md` de `lyxal_event` ; §4.3 du plan de programme. | M | Ceux cités, plus `scripts/ci/test_lyxal_modules.py` et la suite du dépôt. |

Le lot 3 ne dépend que du lot 1 et peut se faire en parallèle du lot 2.

## 7. Décisions du CTO

À valider par le CTO.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **H1** | Nom et identité d'un hôte | Chaque binaire a un nom fixe, inscrit dans son code : `lyxal_server`, `lyxal_groupware`. Toutes les copies d'un même binaire portent ce nom. Pas de réglage par configuration. |
| **H2** | Moteur d'événements | Option A : un chef par hôte ; chaque abonnement appartient à un hôte ; un hôte ne lit que ses livraisons. Deux hôtes qui réclament le même abonnement : le second refuse de démarrer. |
| **H3** | Planificateur | Une tâche à code Rust n'est prise que par un processus qui a ce code, sans exception de délai. Un seul planificateur élu pour toute la base. |
| **H4** | Hôte absent | Ses événements et ses tâches attendent, sans limite et sans échec. L'hôte présent passe son état de santé à « dégradé » après 5 minutes d'attente et nomme l'hôte absent. Aucune mise en dead letter automatique, même après un long délai : l'exploitant décide (annuler, ou déplacer l'abonnement). |
| **H5** | Tâches qui n'appellent que du SurrealQL (et publications différées) | Exécutées par n'importe quel hôte : elles ne dépendent d'aucun binaire. |
| **H6** | Hook d'installation d'un module | Exécuté une seule fois par version de module pour toute la base, sous bail, par le premier hôte qui installe. Un hôte qui arrive après, ou qui redémarre, ne le rejoue pas. Conséquence : la planification de purge de `lyxal_notification` n'est plus recréée à chaque démarrage si quelqu'un l'a supprimée (`crates/lyxal_notification/src/module.rs:86-95`). |
| **H7** | Deux binaires de versions différentes | Les deux hôtes se déploient ensemble, du même commit. Garde-fous : un module commun au contenu différent sous le même numéro fait refuser le démarrage ; un socle remplacé par un autre binaire met l'autre hôte en « dégradé ». |
| **H8** | Changement d'hôte d'un abonnement | Fonction d'exploitation `fn::event_subscription_transfer`, refusée tant que l'ancien hôte est en marche. Pas de bascule automatique. |
| **H9** | Hors de ce plan | (a) Deux modules d'un **même** hôte qui écoutent le même type d'événement : limite existante, à inscrire à la `ROADMAP.md` de `lyxal_event`, à lever avant le premier cas dans `lyxal-groupware`. (b) Filtre `instance_id`. (c) Files réservées à un hôte. (d) Exécuteur créé à chaud pour une file apparue après le démarrage. (e) Création de `apps/lyxal-groupware` (lot 3 du programme). |

## 8. Vérification

- Par lot : `cargo fmt --check`, `cargo clippy` sans avertissement, tests des crates touchés, `scripts/ci/test_lyxal_modules.py`.
- Fin du lot 4 : suite complète du dépôt ; les cinq tests actuels de `two_hosts_shared_database_tests.rs` passent avec le moteur d'événements activé ; plus aucune occurrence de `outbox_leader` dans le dépôt.
- Chaque fonction SurrealQL ajoutée ou modifiée a son test `.test.surql` (cas nominal, paramètres refusés, identité non autorisée).

## 9. Hors périmètre

Les points de H9. Plusieurs bases ou plusieurs organisations par hôte. Répartition de charge entre
nœuds d'un même hôte pour les événements (un seul chef par hôte, comme aujourd'hui). Mise à jour
sans arrêt d'un hôte pendant que l'autre tourne avec une autre version (H7 l'interdit). Outil
d'exploitation au-delà des sondes et de la fonction de transfert.

## 10. Risques

| Risque | Détail | Réponse |
| :--- | :--- | :--- |
| Code d'ordre et de garde du moteur d'événements | Le lot 2 modifie les trois fonctions qui tiennent la garde de génération et le curseur. Une erreur peut perdre ou doubler une livraison. | Logique du curseur non touchée ; seuls l'identifiant du bail et un contrôle de propriété changent. Tests de bascule et de garde exigés au lot 2 ; tests actuels conservés. |
| SurrealDB 3.3.4 | Les gardes reposent sur une écriture conditionnelle dans la fonction (`UPDATE … WHERE generation = …`). Comportement sous écritures concurrentes de deux hôtes sur des baux différents : attendu sans conflit (enregistrements distincts), **non vérifié**. Ventilation simultanée par deux hôtes : protégée par l'index unique, conflit à réessayer, **non essayé**. | Tests à deux hôtes sur moteur embarqué au lot 2 ; un essai sur moteur distant (`ws://`) avant la fusion du lot 4. |
| Nouvel index de `event_delivery` | Le filtre par hôte change le plan de lecture des livraisons en attente. Coût non mesuré. | Mesure sur 100 000 livraisons au lot 2. |
| Hook `install` | Des tests du dépôt comptent peut-être sur l'installation implicite de `start_all` (21 appels à `start_all`, non triés). | Tri au lot 1 ; ajout d'`install_all` ou de `install_packages` là où il manque. |
| Empreinte de release | En développement, modifier un fichier `.surql` sans recréer la base fera refuser le démarrage, au lieu d'être ignoré en silence comme aujourd'hui. | Voulu (§0.3.2 : la base de développement est recréée). Message d'erreur explicite. |
| Tâche sans aucun hôte | Une tâche dont le handler n'existe nulle part n'échoue plus seule : elle attend. | Sonde « dégradé » avec le nom de la tâche (H4). |
| Faits non vérifiés | Durée exacte avant dead letter (« environ 3 s », rapport du lot 0) ; comportement des workers de notification et d'ingestion à deux hôtes ; purge simultanée par deux hôtes ; `fn::event_dead_letter_replay` et `fn::event_delivery_failure` (non relues, à contrôler au lot 2). | Contrôle au lot concerné ; tout écart est signalé au CTO avant de continuer. |

## 11. Checklist (§13)

- **Architecture** : responsabilités dans leurs crates (hôte et présence : runtime ; propriété des abonnements : `lyxal_event` ; réservation : `lyxal_scheduler`). Aucune dépendance nouvelle entre crates ; `lyxal_event` ne dépend pas de `lyxal_runtime` (il reçoit l'hôte en `String`). Pas de cycle.
- **Core** : validation par `lyxal_core` (§5) ; aucune primitive recopiée ; aucun `THROW` pour une donnée invalide (les `THROW` de garde existants restent des refus de concurrence).
- **SurrealQL** : `$params: object`, `fn::result_ok` / `fn::error_result`, `COMMENT`, fonctions sous 300 lignes, tests `.test.surql`.
- **Rust** : `XxxParams` / `XxxResult` nommés (§5), wrappers `call_fn`, aucun `panic!`, aucun `raw_query()` métier.
- **Erreurs** : cinq codes nouveaux, préfixés (`RUNTIME_`, `EVENT_`) ; aucune erreur masquée (K4 corrigé).
- **Événements** : producteurs inchangés ; garde, contiguïté, barrière dead letter et reprise conservées (§4.2) ; handlers toujours idempotents.
- **Cryptographie** : aucune primitive nouvelle ; `lyxal_crypto::hash::sha256_hex` seulement.
- **Zéro dette** : aucun alias (`outbox_leader`, `Default` des configurations, paramètre `handlers` optionnel : retirés) ; tous les appelants mis à jour dans le lot ; schémas réécrits en place ; versions `0.y.z`.
- **Validation CTO** : décisions H1 à H9 ; aucun besoin Core ni crypto à signaler.

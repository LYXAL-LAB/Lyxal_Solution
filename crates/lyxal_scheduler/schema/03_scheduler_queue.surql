-- ============================================================================
-- TABLES : scheduler_queue, scheduler_slot
-- MODULE : lyxal_scheduler
-- RÔLE   : Files d'exécution et compteurs de places (file, organisation dans la file)
-- ============================================================================
-- Deux limites tenues par compteurs, chacun modifié par une écriture conditionnelle (aucun
-- dépassement entre deux nœuds) : places de la file (running < concurrency) et places d'une
-- organisation dans la file (scheduler_slot, réglage tenant_concurrency). Les compteurs ne
-- changent que par la réservation et la fin d'une exécution (moteur : session système ou
-- scheduler.worker) : garde scheduler_queue_update_guard pour les files, permissions de la
-- table pour scheduler_slot (écriture par le moteur seulement).

DEFINE TABLE OVERWRITE scheduler_queue
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "catalog" })
        FOR update WHERE fn::scheduler_can({ action: "installation" }) OR fn::scheduler_can({ action: "worker" })
        FOR create, delete NONE
    COMMENT "Files d'exécution : concurrence, places occupées, pause";

DEFINE FIELD OVERWRITE concurrency ON TABLE scheduler_queue
    TYPE int
    DEFAULT 10
    ASSERT $value >= 1 AND $value <= 10000
    COMMENT "Exécutions simultanées de la file, tous nœuds confondus";

DEFINE FIELD OVERWRITE running ON TABLE scheduler_queue
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0 AND $value <= $this.concurrency
    COMMENT "Places occupées (jamais négatif ni au-delà de concurrency)";

DEFINE FIELD OVERWRITE paused ON TABLE scheduler_queue
    TYPE bool
    DEFAULT false
    COMMENT "File en pause : rien n'est réservé";

DEFINE FIELD OVERWRITE paused_reason ON TABLE scheduler_queue
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 256
    COMMENT "Motif de la pause";

DEFINE FIELD OVERWRITE description ON TABLE scheduler_queue
    TYPE object
    DEFAULT {}
    COMMENT "Description par langue ({ fr, en })";

DEFINE FIELD OVERWRITE description.* ON TABLE scheduler_queue
    TYPE string;

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_queue
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE TABLE OVERWRITE scheduler_slot
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "read", tenant: tenant }) OR fn::scheduler_can({ action: "worker" })
        FOR create, update WHERE fn::scheduler_can({ action: "worker" })
        FOR delete NONE
    COMMENT "Places occupées par une organisation dans une file (identifiant [file, portée])";

DEFINE FIELD OVERWRITE queue ON TABLE scheduler_slot
    TYPE record<scheduler_queue>
    READONLY
    COMMENT "File";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_slot
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_slot
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE running ON TABLE scheduler_slot
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Places occupées par la portée dans la file";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_slot
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_slot_queue ON TABLE scheduler_slot FIELDS queue, scope_key UNIQUE;

-- Exécuteurs actifs (sonde de santé) : hôte et handlers de chaque nœud qui sert une file,
-- réécrits à chaque réservation (fn::scheduler_run_claim), élagués après un jour sans réservation
-- (fn::scheduler_run_prune). Une file ou une tâche handler n'est signalée que si aucun nœud actif
-- (réservation ou battement dans la dernière minute) ne la sert ; l'hôte du dernier nœud qui
-- servait la tâche est alors nommé.

DEFINE TABLE OVERWRITE scheduler_node
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE fn::scheduler_can({ action: "worker" })
    COMMENT "Exécuteurs actifs : hôte et handlers inscrits par nœud et par file (identifiant [nœud, file])";

DEFINE FIELD OVERWRITE node ON TABLE scheduler_node
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nœud";

DEFINE FIELD OVERWRITE host ON TABLE scheduler_node
    TYPE string
    ASSERT string::matches($value, "^[a-z][a-z0-9_]{0,63}$")
    COMMENT "Hôte du nœud (rôle du binaire, le même pour toutes ses copies)";

DEFINE FIELD OVERWRITE queue ON TABLE scheduler_node
    TYPE record<scheduler_queue>
    COMMENT "File servie";

DEFINE FIELD OVERWRITE handlers ON TABLE scheduler_node
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 1000
    COMMENT "Tâches handler dont le nœud a le code";

DEFINE FIELD OVERWRITE seen_at ON TABLE scheduler_node
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière réservation ou dernier battement du nœud dans la file";

DEFINE INDEX OVERWRITE scheduler_node_seen ON TABLE scheduler_node FIELDS seen_at;

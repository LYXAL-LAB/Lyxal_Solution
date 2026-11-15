-- ============================================================================
-- TABLE  : scheduler_run
-- MODULE : lyxal_scheduler
-- RÔLE   : Exécutions : une fois, créée, réservée sous bail, exécutée, retentée, terminée
-- ============================================================================
-- Identifiant [planification, date prévue] pour une échéance ou un rejeu de période (une même
-- échéance ne crée jamais deux exécutions), aléatoire pour une exécution déclenchée, différée
-- ou relancée. États :
--   waiting ──(précédente terminée)──► queued ──(réservation)──► running ──► completed
--   queued ◄──── retrying ◄───(échec, tentatives restantes)── running ──► dead
--   waiting / queued / retrying ──(annulation)──► cancelled ; running ──(annulation acquittée)──► cancelled
--   (chevauchement skip, création) ──► skipped
-- Transitions, champs figés et jeton du bail gardés par scheduler_run_update_guard
-- (fn::scheduler_run_update_refusal) ; le jeton du bail n'est lisible que par le moteur.

DEFINE TABLE OVERWRITE scheduler_run
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "read", tenant: tenant }) OR fn::scheduler_can({ action: "worker" })
        FOR create WHERE fn::scheduler_can({ action: "write", tenant: tenant, task: task })
            OR (origin = "retry" AND fn::scheduler_can({ action: "run_manage", tenant: tenant }))
            OR fn::scheduler_can({ action: "worker" })
        FOR update WHERE fn::scheduler_can({ action: "write", tenant: tenant })
            OR fn::scheduler_can({ action: "run_manage", tenant: tenant })
            OR fn::scheduler_can({ action: "worker" })
        FOR delete WHERE fn::scheduler_can({ action: "worker" })
    COMMENT "Exécutions d'une tâche : état, tentatives, bail, résultat court, erreur ; jamais lu sans droit";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_run
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_run
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation (compteurs, limites)";

DEFINE FIELD OVERWRITE schedule ON TABLE scheduler_run
    TYPE option<record<scheduler_schedule>>
    COMMENT "Planification d'origine (NONE : exécution différée) ; l'historique reste après la suppression de la planification";

DEFINE FIELD OVERWRITE task ON TABLE scheduler_run
    TYPE record<scheduler_task>
    COMMENT "Tâche exécutée (figée)";

DEFINE FIELD OVERWRITE args ON TABLE scheduler_run
    TYPE object
    FLEXIBLE
    DEFAULT {}
    COMMENT "Arguments de l'exécution (figés), contrôlés par le schéma de la tâche ; jamais de secret";

DEFINE FIELD OVERWRITE queue ON TABLE scheduler_run
    TYPE record<scheduler_queue>
    COMMENT "File d'exécution (figée)";

DEFINE FIELD OVERWRITE priority ON TABLE scheduler_run
    TYPE int
    ASSERT $value >= 0 AND $value <= 9
    COMMENT "Priorité (0 : la plus haute)";

DEFINE FIELD OVERWRITE origin ON TABLE scheduler_run
    TYPE string
    ASSERT $value IN ["schedule", "backfill", "trigger", "enqueue", "retry"]
    COMMENT "Origine : échéance, rejeu de période, déclenchement immédiat, exécution différée, relance (figée)";

DEFINE FIELD OVERWRITE scheduled_for ON TABLE scheduler_run
    TYPE datetime
    COMMENT "Date prévue, figée à travers les tentatives";

DEFINE FIELD OVERWRITE available_at ON TABLE scheduler_run
    TYPE datetime
    COMMENT "Date à partir de laquelle la tentative suivante peut être réservée";

DEFINE FIELD OVERWRITE state ON TABLE scheduler_run
    TYPE string
    ASSERT $value IN ["waiting", "queued", "running", "retrying", "completed", "dead", "cancelled", "skipped"]
    COMMENT "État : waiting, queued, running, retrying, completed, dead, cancelled, skipped";

DEFINE FIELD OVERWRITE attempt ON TABLE scheduler_run
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Tentatives commencées";

DEFINE FIELD OVERWRITE max_attempts ON TABLE scheduler_run
    TYPE int
    ASSERT $value >= 1 AND $value <= 10
    COMMENT "Tentatives permises (politique de la tâche à la création, figée)";

DEFINE FIELD OVERWRITE unique_key ON TABLE scheduler_run
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 256)
    COMMENT "Clé d'unicité d'une exécution différée (fournie, ou empreinte des arguments), figée";

DEFINE FIELD OVERWRITE lease ON TABLE scheduler_run
    TYPE option<string>
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "worker" })
    COMMENT "Jeton du bail en cours (lisible par le moteur seulement) : exigé par chaque fin d'exécution";

DEFINE FIELD OVERWRITE lease_node ON TABLE scheduler_run
    TYPE option<string>
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Nœud qui détient le bail";

DEFINE FIELD OVERWRITE locked_until ON TABLE scheduler_run
    TYPE option<datetime>
    COMMENT "Échéance du bail (passée : l'exécution est reprise)";

DEFINE FIELD OVERWRITE cancel_requested ON TABLE scheduler_run
    TYPE bool
    DEFAULT false
    COMMENT "Annulation demandée pendant l'exécution (le moteur l'apprend au battement)";

DEFINE FIELD OVERWRITE cancel_reason ON TABLE scheduler_run
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 256
    COMMENT "Motif de l'annulation";

DEFINE FIELD OVERWRITE started_at ON TABLE scheduler_run
    TYPE option<datetime>
    COMMENT "Début de la dernière tentative";

DEFINE FIELD OVERWRITE finished_at ON TABLE scheduler_run
    TYPE option<datetime>
    COMMENT "Fin (état terminal)";

DEFINE FIELD OVERWRITE duration_ms ON TABLE scheduler_run
    TYPE option<int>
    ASSERT $value IS NONE OR $value >= 0
    COMMENT "Durée de la dernière tentative, en millisecondes";

DEFINE FIELD OVERWRITE result ON TABLE scheduler_run
    TYPE option<object>
    FLEXIBLE
    ASSERT $value IS NONE OR bytes::len(<bytes> <string> $value) <= 4096
    COMMENT "Résultat court (4 Kio au plus)";

DEFINE FIELD OVERWRITE error ON TABLE scheduler_run
    TYPE option<object>
    COMMENT "Dernière erreur : { code, message, retryable }";

DEFINE FIELD OVERWRITE error.code ON TABLE scheduler_run
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128;

DEFINE FIELD OVERWRITE error.message ON TABLE scheduler_run
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1000;

DEFINE FIELD OVERWRITE error.retryable ON TABLE scheduler_run
    TYPE bool;

DEFINE FIELD OVERWRITE created_by ON TABLE scheduler_run
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité à l'origine d'une exécution déclenchée, différée ou relancée";

DEFINE FIELD OVERWRITE created_at ON TABLE scheduler_run
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_run
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_run_claim ON TABLE scheduler_run FIELDS queue, state, priority, available_at;
DEFINE INDEX OVERWRITE scheduler_run_schedule ON TABLE scheduler_run FIELDS schedule, state;
DEFINE INDEX OVERWRITE scheduler_run_scope ON TABLE scheduler_run FIELDS scope_key, state;
DEFINE INDEX OVERWRITE scheduler_run_unique ON TABLE scheduler_run FIELDS task, scope_key, unique_key;
DEFINE INDEX OVERWRITE scheduler_run_lease ON TABLE scheduler_run FIELDS state, locked_until;

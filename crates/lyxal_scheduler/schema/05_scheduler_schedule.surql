-- ============================================================================
-- TABLE  : scheduler_schedule
-- MODULE : lyxal_scheduler
-- RÔLE   : Planifications : « quand » exécuter une tâche, avec quels arguments
-- ============================================================================
-- Créée par une personne ou un module, pour une organisation (ou l'installation). Le calcul des
-- dates (cron, intervalles, fuseau, calendriers) est fait par Rust, qui écrit next_fire_at par
-- fn::scheduler_schedule_next_set ou fn::scheduler_schedule_fire (moteur seulement). Toute
-- modification de spec, calendars ou paused remet next_fire_at à NONE (date à recalculer).
-- Les transitions et champs réservés au moteur sont gardés par scheduler_schedule_update_guard
-- (fn::scheduler_schedule_update_refusal), qui vaut aussi pour une écriture directe.

DEFINE TABLE OVERWRITE scheduler_schedule
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::scheduler_can({ action: "read", tenant: tenant }) OR fn::scheduler_can({ action: "worker" })
        FOR create WHERE fn::scheduler_can({ action: "write", tenant: tenant, task: task })
        FOR update WHERE fn::scheduler_can({ action: "write", tenant: tenant }) OR fn::scheduler_can({ action: "worker" })
        FOR delete WHERE fn::scheduler_can({ action: "write", tenant: tenant })
    COMMENT "Planifications d'une tâche : règles de dates, arguments, chevauchement, rattrapage, pause, prochaine échéance";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_schedule
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_schedule
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité du nom : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE name ON TABLE scheduler_schedule
    TYPE string
    READONLY
    ASSERT fn::validation_slug($value, 128).valid
    COMMENT "Nom de la planification (slug), unique dans sa portée";

DEFINE FIELD OVERWRITE task ON TABLE scheduler_schedule
    TYPE record<scheduler_task>
    READONLY
    COMMENT "Tâche exécutée";

DEFINE FIELD OVERWRITE args ON TABLE scheduler_schedule
    TYPE object
    FLEXIBLE
    DEFAULT {}
    COMMENT "Arguments passés à chaque exécution, contrôlés par le schéma de la tâche ; jamais de secret";

DEFINE FIELD OVERWRITE spec ON TABLE scheduler_schedule
    TYPE object
    COMMENT "Règles de dates : { cron, every, at, exclude_cron, timezone, start_at, end_at, jitter }";

DEFINE FIELD OVERWRITE spec.cron ON TABLE scheduler_schedule TYPE array<string> DEFAULT [];
DEFINE FIELD OVERWRITE spec.every ON TABLE scheduler_schedule TYPE array<duration> DEFAULT [];
DEFINE FIELD OVERWRITE spec.at ON TABLE scheduler_schedule TYPE option<datetime>;
DEFINE FIELD OVERWRITE spec.exclude_cron ON TABLE scheduler_schedule TYPE array<string> DEFAULT [];
DEFINE FIELD OVERWRITE spec.timezone ON TABLE scheduler_schedule TYPE string DEFAULT "UTC";
DEFINE FIELD OVERWRITE spec.start_at ON TABLE scheduler_schedule TYPE option<datetime>;
DEFINE FIELD OVERWRITE spec.end_at ON TABLE scheduler_schedule TYPE option<datetime>;
DEFINE FIELD OVERWRITE spec.jitter ON TABLE scheduler_schedule TYPE option<duration>;

DEFINE FIELD OVERWRITE calendars ON TABLE scheduler_schedule
    TYPE array<record<scheduler_calendar>>
    DEFAULT []
    ASSERT array::len($value) <= 10
    COMMENT "Calendriers d'exceptions de la même portée (10 au plus)";

DEFINE FIELD OVERWRITE overlap ON TABLE scheduler_schedule
    TYPE string
    DEFAULT "skip"
    ASSERT $value IN ["skip", "buffer_one", "buffer_all", "cancel_other", "allow_all"]
    COMMENT "Chevauchement : skip (défaut), buffer_one, buffer_all, cancel_other, allow_all";

DEFINE FIELD OVERWRITE catchup ON TABLE scheduler_schedule
    TYPE string
    DEFAULT "last"
    ASSERT $value IN ["last", "all", "none"]
    COMMENT "Rattrapage des échéances manquées : last (la dernière dans la fenêtre, défaut), all (toutes dans la fenêtre), none (aucune)";

DEFINE FIELD OVERWRITE catchup_window ON TABLE scheduler_schedule
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 1m AND $value <= 30d)
    COMMENT "Fenêtre de rattrapage (NONE : réglage effectif de la portée)";

DEFINE FIELD OVERWRITE remaining ON TABLE scheduler_schedule
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 0 AND $value <= 1000000)
    COMMENT "Exécutions restantes (NONE : illimité) ; à 0 la planification est terminée";

DEFINE FIELD OVERWRITE paused ON TABLE scheduler_schedule
    TYPE bool
    DEFAULT false
    COMMENT "En pause : aucune échéance n'est créée";

DEFINE FIELD OVERWRITE paused_reason ON TABLE scheduler_schedule
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 256
    COMMENT "Motif de la pause (failure : pause sur échec)";

DEFINE FIELD OVERWRITE pause_on_failure ON TABLE scheduler_schedule
    TYPE bool
    DEFAULT false
    COMMENT "Mise en pause quand une exécution finit en dead";

DEFINE FIELD OVERWRITE state ON TABLE scheduler_schedule
    TYPE string
    DEFAULT "active"
    ASSERT $value IN ["active", "completed", "invalid"]
    COMMENT "État : active, completed (plus d'échéance), invalid (règles refusées par le calcul des dates)";

DEFINE FIELD OVERWRITE invalid_reason ON TABLE scheduler_schedule
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1000
    COMMENT "Motif d'invalidité écrit par le moteur";

DEFINE FIELD OVERWRITE next_fire_at ON TABLE scheduler_schedule
    TYPE option<datetime>
    COMMENT "Prochaine échéance (écrite par le moteur ; NONE : à calculer)";

DEFINE FIELD OVERWRITE last_fire_at ON TABLE scheduler_schedule
    TYPE option<datetime>
    COMMENT "Dernière échéance traitée";

DEFINE FIELD OVERWRITE last_run ON TABLE scheduler_schedule
    TYPE option<record<scheduler_run>>
    COMMENT "Dernière exécution créée par une échéance";

DEFINE FIELD OVERWRITE last_state ON TABLE scheduler_schedule
    TYPE option<string>
    COMMENT "État de la dernière exécution";

DEFINE FIELD OVERWRITE created_by ON TABLE scheduler_schedule
    TYPE option<record<auth_identity>>
    REFERENCE ON DELETE UNSET
    COMMENT "Identité qui a créé la planification (NONE : session système, compte de service ou identité supprimée)";

DEFINE FIELD OVERWRITE created_at ON TABLE scheduler_schedule
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_schedule
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_schedule_name ON TABLE scheduler_schedule FIELDS scope_key, name UNIQUE;
DEFINE INDEX OVERWRITE scheduler_schedule_due ON TABLE scheduler_schedule FIELDS state, paused, next_fire_at;
DEFINE INDEX OVERWRITE scheduler_schedule_task ON TABLE scheduler_schedule FIELDS task;

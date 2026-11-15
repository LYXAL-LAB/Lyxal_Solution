-- ============================================================================
-- FONCTIONS : files d'exécution
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Les files sont créées par le seed du module (default, maintenance). Leur compteur de places
-- n'est modifié que par la réservation et la fin d'une exécution (moteur).

-- ----------------------------------------------------------------------------
-- fn::scheduler_queue_update_refusal (interne, garde de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_queue_update_refusal($before: object, $after: object) -> option<string> {
    IF $before.running != $after.running AND !fn::scheduler_can({ action: "worker" }) { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    IF ($before.concurrency != $after.concurrency OR $before.description != $after.description) AND !fn::auth_session_valid({}).system { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    IF ($before.paused != $after.paused OR $before.paused_reason != $after.paused_reason) AND !fn::scheduler_can({ action: "installation" }) { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    RETURN NONE;
} COMMENT "Interne : refus d'une modification de file ($before, $after) : compteur de places par le moteur seulement (réservation et fin) ; concurrence et description par la session système ; pause par scheduler.installation.manage. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_queue_record (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_queue_record($name: string) -> record<scheduler_queue> {
    RETURN type::record("scheduler_queue", $name);
} COMMENT "Interne : enregistrement d'une file d'après son nom";

-- ----------------------------------------------------------------------------
-- fn::scheduler_queue_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_queue_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "catalog" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $queues = (SELECT * FROM scheduler_queue ORDER BY id ASC);
    -- Places par organisation : celles que l'appelant peut lire (son organisation, ou toutes pour l'installation et le moteur)
    RETURN fn::result_ok(array::map($queues, |$q| object::extend($q, {
        slots: (SELECT scope_key, running FROM scheduler_slot WHERE queue = $q.id AND running > 0 ORDER BY scope_key ASC)
    })));
} COMMENT "Files avec leurs places occupées : concurrence, running, pause, et places par organisation lisibles par l'appelant (slots). Droit : lecture ou écriture dans l'organisation active, installation ou moteur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_queue_pause
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_queue_pause($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            queue: { pipeline: [{ rule: "slug", options: { max_length: 64 } }], required: true },
            reason: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "installation" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $id = fn::scheduler_queue_record($p.queue);
    IF !record::exists($id) { RETURN fn::error_result("SCHEDULER_QUEUE_NOT_FOUND", $p.language, { queue: $p.queue }); };
    LET $updated = (UPDATE ONLY $id SET paused = true, paused_reason = $p.reason);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_queue" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Met une file en pause ({ queue, reason }) : plus aucune exécution n'y est réservée ; celles en cours se terminent. Droit : scheduler.installation.manage";

-- ----------------------------------------------------------------------------
-- fn::scheduler_queue_resume
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_queue_resume($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            queue: { pipeline: [{ rule: "slug", options: { max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "installation" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $id = fn::scheduler_queue_record($p.queue);
    IF !record::exists($id) { RETURN fn::error_result("SCHEDULER_QUEUE_NOT_FOUND", $p.language, { queue: $p.queue }); };
    LET $updated = (UPDATE ONLY $id SET paused = false, paused_reason = NONE);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_queue" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Reprend une file en pause ({ queue }). Droit : scheduler.installation.manage";

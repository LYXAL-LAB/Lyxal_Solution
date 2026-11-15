-- ============================================================================
-- FONCTIONS : chevauchement, création d'exécutions d'une planification, déclenchement, rejeu
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Une exécution est « active » pour le chevauchement tant qu'elle est waiting, queued, running
-- ou retrying. Politiques (S6, modèle Temporal) :
--   skip         : une exécution active existe → la nouvelle est skipped (défaut) ;
--   buffer_one   : la nouvelle attend (waiting) ; s'il y en a déjà une en attente → skipped ;
--   buffer_all   : toutes attendent, libérées une à une dans l'ordre des dates prévues ;
--   cancel_other : les autres sont annulées (celle qui tourne reçoit une demande d'annulation et
--                  la nouvelle attend sa fin) ;
--   allow_all    : la nouvelle est mise en file sans attendre.

-- ----------------------------------------------------------------------------
-- fn::scheduler_overlap_apply (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_overlap_apply($schedule: record<scheduler_schedule>, $overlap: string) -> string {
    LET $active = (SELECT id, state FROM scheduler_run WHERE schedule = $schedule AND state IN ["waiting", "queued", "running", "retrying"]);
    IF array::len($active) = 0 OR $overlap = "allow_all" { RETURN "queued"; };
    IF $overlap = "skip" { RETURN "skipped"; };
    IF $overlap = "buffer_all" { RETURN "waiting"; };
    IF $overlap = "buffer_one" { RETURN IF array::any($active, |$r| $r.state = "waiting") { "skipped" } ELSE { "waiting" }; };
    -- cancel_other
    UPDATE scheduler_run SET state = "cancelled", finished_at = time::now(), cancel_reason = "overlap"
        WHERE schedule = $schedule AND state IN ["waiting", "queued", "retrying"];
    UPDATE scheduler_run SET cancel_requested = true, cancel_reason = "overlap"
        WHERE schedule = $schedule AND state = "running" AND !cancel_requested;
    RETURN IF array::any($active, |$r| $r.state = "running") { "waiting" } ELSE { "queued" };
} COMMENT "Interne : applique la politique de chevauchement ($schedule, $overlap : skip, buffer_one, buffer_all, cancel_other, allow_all) avant la création d'une exécution et renvoie son état initial (queued, waiting ou skipped) ; cancel_other annule les autres exécutions actives";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_spawn (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_spawn($schedule: object, $task: object, $id: option<record<scheduler_run>>, $scheduled_for: datetime, $origin: string, $overlap: string) -> option<object> {
    -- Une même échéance ne crée jamais deux exécutions : un doublon est ignoré
    IF $id IS NOT NONE AND record::exists($id) { RETURN NONE; };
    LET $state = fn::scheduler_overlap_apply($schedule.id, $overlap);
    LET $now = time::now();
    LET $content = {
        tenant: $schedule.tenant,
        schedule: $schedule.id,
        task: $schedule.task,
        args: $schedule.args,
        queue: $task.queue,
        priority: $task.priority,
        origin: $origin,
        scheduled_for: $scheduled_for,
        available_at: $scheduled_for,
        state: $state,
        max_attempts: $task.retry.max_attempts,
        finished_at: IF $state = "skipped" { $now } ELSE { NONE },
        created_by: IF $origin = "trigger" { fn::scheduler_caller().identity } ELSE { NONE }
    };
    RETURN IF $id IS NONE { (CREATE ONLY scheduler_run CONTENT $content) } ELSE { (CREATE ONLY $id CONTENT $content) };
} COMMENT "Interne : crée une exécution d'une planification ($schedule, $task lues ; $id : [planification, date prévue] ou NONE pour un identifiant aléatoire ; $scheduled_for ; $origin : schedule, backfill, trigger ; $overlap) après la politique de chevauchement. Identifiant déjà pris : NONE (doublon ignoré)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_release (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_release($schedule: option<record<scheduler_schedule>>) -> option<object> {
    IF $schedule IS NONE { RETURN NONE; };
    LET $busy = (SELECT VALUE id FROM scheduler_run WHERE schedule = $schedule AND state IN ["queued", "running", "retrying"] LIMIT 1);
    IF array::len($busy) > 0 { RETURN NONE; };
    LET $next = (SELECT id FROM scheduler_run WHERE schedule = $schedule AND state = "waiting" ORDER BY scheduled_for ASC LIMIT 1);
    IF array::len($next) = 0 { RETURN NONE; };
    RETURN (UPDATE ONLY $next[0].id SET state = "queued");
} COMMENT "Interne : libère la plus ancienne exécution waiting d'une planification (→ queued) quand aucune autre n'est queued, running ou retrying ; renvoie l'exécution libérée ou NONE";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_trigger
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_trigger($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            overlap: { pipeline: [{ rule: "enum", options: { allowed: ["skip", "buffer_one", "buffer_all", "cancel_other", "allow_all"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF !fn::scheduler_can({ action: "write", tenant: $schedule.tenant, task: $schedule.task }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    IF $schedule.state != "active" { RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { state: $schedule.state }); };
    LET $task = (SELECT * FROM ONLY $schedule.task);
    LET $usable = fn::scheduler_task_usable($task, $schedule.tenant);
    IF $usable IS NOT NONE { RETURN fn::error_result($usable, $p.language, { task: <string> $schedule.task }); };
    LET $full = fn::scheduler_pending_full($schedule.tenant);
    IF $full IS NOT NONE { RETURN fn::error_result("SCHEDULER_LIMIT_REACHED", $p.language, { limit: "max_pending_runs", max: $full }); };
    LET $run = fn::scheduler_run_spawn($schedule, $task, NONE, time::now(), "trigger", $p.overlap ?? $schedule.overlap);
    IF $run == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_run" }); };
    RETURN fn::result_ok($run);
} COMMENT "Déclenche tout de suite une planification active, même en pause ({ schedule, overlap : celui de la planification par défaut }) : nouvelle exécution (origin: trigger) soumise au chevauchement (queued, waiting ou skipped). Droit : écriture et permission propre de la tâche";

-- ----------------------------------------------------------------------------
-- fn::scheduler_backfill_refusal (interne, garde de création)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_backfill_refusal($after: object) -> option<string> {
    LET $schedule = (SELECT tenant FROM ONLY $after.schedule);
    IF $schedule == NONE { RETURN "SCHEDULER_SCHEDULE_NOT_FOUND"; };
    IF $schedule.tenant != $after.tenant OR $after.state != "pending" OR $after.runs_created != 0 { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    IF $after.to > time::now() OR $after.from >= $after.to OR $after.to - $after.from > 366d { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    LET $open = (SELECT VALUE id FROM scheduler_backfill WHERE schedule = $after.schedule AND id != $after.id AND state IN ["pending", "running"] LIMIT 1);
    IF array::len($open) > 0 { RETURN "SCHEDULER_BACKFILL_RUNNING"; };
    LET $caller = fn::scheduler_caller();
    RETURN IF !$caller.system AND $after.requested_by != $caller.identity { "SCHEDULER_PERMISSION_DENIED" } ELSE { NONE };
} COMMENT "Interne : refus d'une demande de rejeu ($after) : planification existante de la même organisation ; état initial pending ; période passée, from < to, un an au plus ; aucun autre rejeu en cours de la planification (SCHEDULER_BACKFILL_RUNNING) ; demandeur = appelant hors session système. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_backfill
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_backfill($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            from: { pipeline: [{ rule: "past_datetime", options: { allow_equal: false } }], required: true },
            to: { pipeline: [{ rule: "past_datetime", options: { allow_equal: true } }], required: true },
            overlap: { pipeline: [{ rule: "enum", options: { allowed: ["skip", "buffer_one", "buffer_all", "cancel_other", "allow_all"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF $p.from >= $p.to OR $p.to - $p.from > 366d {
        RETURN fn::scheduler_invalid($params, { to: [{ code: "CORE_VALIDATION_RANGE_ORDER", details: { start: $p.from, end: $p.to, allow_equal: false, max: 366d } }] });
    };
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF !fn::scheduler_can({ action: "write", tenant: $schedule.tenant, task: $schedule.task }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $open = (SELECT VALUE id FROM scheduler_backfill WHERE schedule = $schedule.id AND state IN ["pending", "running"] LIMIT 1);
    IF array::len($open) > 0 { RETURN fn::error_result("SCHEDULER_BACKFILL_RUNNING", $p.language, { backfill: <string> $open[0] }); };
    LET $created = (CREATE ONLY scheduler_backfill CONTENT {
        schedule: $schedule.id,
        tenant: $schedule.tenant,
        from: $p.from,
        to: $p.to,
        overlap: $p.overlap,
        requested_by: fn::scheduler_caller().identity
    });
    IF $created == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_backfill" }); };
    RETURN fn::result_ok($created);
} COMMENT "Demande le rejeu d'une période passée d'une planification ({ schedule, from, to, overlap }) : from < to ≤ maintenant, un an au plus ; un seul rejeu en cours par planification (SCHEDULER_BACKFILL_RUNNING). Le moteur calcule les échéances de la période et crée les exécutions (origin: backfill), une échéance déjà exécutée étant ignorée. Droit : écriture et permission propre de la tâche";

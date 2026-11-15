-- ============================================================================
-- FONCTIONS : moteur — échéances, rattrapage, rejeu de période
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Appelées par le planificateur Rust (lot 3), sous la session système ou un compte de service
-- scheduler.worker. Rust calcule les dates (cron, intervalles, fuseau, calendriers) ; ces
-- fonctions appliquent le rattrapage, le chevauchement et les règles d'état.

-- ----------------------------------------------------------------------------
-- fn::scheduler_due_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_due_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $disabled = (SELECT VALUE id FROM scheduler_task WHERE state = "disabled");
    -- next_fire_at NONE : à calculer (NONE se compare comme inférieur à toute date : condition explicite)
    LET $schedules = (SELECT id, tenant, task, spec, calendars, catchup, catchup_window, next_fire_at, last_fire_at, created_at FROM scheduler_schedule
        WHERE state = "active" AND paused = false AND task NOTINSIDE $disabled AND (next_fire_at IS NONE OR next_fire_at <= $now)
        ORDER BY next_fire_at ASC LIMIT $p.limit);
    LET $backfills = (SELECT id, schedule, from, to, overlap, state FROM scheduler_backfill WHERE state IN ["pending", "running"] ORDER BY created_at ASC LIMIT $p.limit);
    RETURN fn::result_ok({
        now: $now,
        schedules: array::map($schedules, |$s| object::extend($s, {
            catchup_window: $s.catchup_window ?? fn::scheduler_settings_effective({ tenant: $s.tenant }).catchup_window,
            calendars: (SELECT id, rules FROM scheduler_calendar WHERE id IN $s.calendars)
        })),
        backfills: array::map($backfills, |$b| object::extend($b, {
            spec: (SELECT VALUE spec FROM ONLY $b.schedule),
            created_at: (SELECT VALUE created_at FROM ONLY $b.schedule),
            calendars: (SELECT id, rules FROM scheduler_calendar WHERE id IN (SELECT VALUE calendars FROM ONLY $b.schedule))
        }))
    });
} COMMENT "Moteur : planifications actives, hors pause, de tâches actives, dont la prochaine échéance est passée ou à calculer (next_fire_at NONE), avec leurs règles, calendriers, création (ancre des intervalles, U3) et fenêtre de rattrapage effective ; rejeux en attente ou en cours avec les règles, les calendriers et la création de leur planification ({ limit (1000 au plus) }) : { now, schedules, backfills }. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_catchup_select (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_catchup_select($times: array<datetime>, $policy: string, $window: duration, $now: datetime) -> array<datetime> {
    LET $sorted = array::sort::asc(array::distinct($times));
    IF array::len($sorted) = 0 { RETURN []; };
    LET $eligible = array::filter($sorted, |$t| $t >= $now - $window);
    RETURN IF $policy = "all" { $eligible }
        ELSE IF $policy = "last" { array::slice($eligible, -1) }
        -- none : seule l'échéance courante (moins d'une minute de retard) est exécutée
        ELSE IF array::last($sorted) >= $now - 1m { [array::last($sorted)] }
        ELSE { [] };
} COMMENT "Interne : échéances à exécuter parmi les dates manquées fournies ($times, $policy : last, all, none ; $window ; $now) : all → toutes celles de la fenêtre de rattrapage ; last → la plus récente de la fenêtre ; none → la plus récente seulement si elle a moins d'une minute de retard. Dates triées, sans doublon";

-- ----------------------------------------------------------------------------
-- fn::scheduler_fire_times_pipeline (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_fire_times_pipeline($at: array) -> array {
    RETURN [{ rule: "array" }, { rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
        fields: {
            at: { pipeline: $at, required: true },
            available_at: { pipeline: [{ rule: "datetime" }], required: true }
        },
        unknown_keys: "reject"
    } } }] } }];
} COMMENT "Interne : pipeline du moteur de validation pour une liste d'échéances (1000 au plus) { at : date prévue contrôlée par $at, available_at : date de disponibilité }";

-- ----------------------------------------------------------------------------
-- fn::scheduler_fire_times_disordered (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_fire_times_disordered($fire_times: array) -> bool {
    RETURN array::any($fire_times, |$f| $f.available_at < $f.at);
} COMMENT "Interne : vrai si une échéance est disponible avant sa date prévue (le décalage aléatoire ne fait que retarder, U5)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_fire_times_invalid (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_fire_times_invalid($params: any) -> object {
    RETURN fn::scheduler_invalid($params, { fire_times: [{ code: "CORE_VALIDATION_RANGE_ORDER", details: { start: "at", end: "available_at", allow_equal: true } }] });
} COMMENT "Interne : erreur SCHEDULER_INVALID_PARAMETERS d'une échéance disponible avant sa date prévue";

-- ----------------------------------------------------------------------------
-- fn::scheduler_fire_available (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_fire_available($fire_times: array, $at: datetime) -> datetime {
    LET $found = array::filter($fire_times, |$f| $f.at = $at);
    RETURN IF array::len($found) = 0 { $at } ELSE { $found[0].available_at };
} COMMENT "Interne : date de disponibilité de l'échéance $at parmi $fire_times (la première fournie pour cette date ; $at si elle est absente)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_fire
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_fire($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            fire_times: { pipeline: fn::scheduler_fire_times_pipeline([{ rule: "past_datetime", options: { allow_equal: true } }]), required: true },
            next_fire_at: { pipeline: [{ rule: "datetime" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF fn::scheduler_fire_times_disordered($p.fire_times) { RETURN fn::scheduler_fire_times_invalid($params); };
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF $schedule.state != "active" OR $schedule.paused { RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { state: $schedule.state, paused: $schedule.paused }); };
    LET $task = (SELECT * FROM ONLY $schedule.task);
    IF $task == NONE { RETURN fn::error_result("SCHEDULER_TASK_NOT_FOUND", $p.language, { task: <string> $schedule.task }); };
    IF $task.state != "active" { RETURN fn::error_result("SCHEDULER_TASK_DISABLED", $p.language, { task: <string> $schedule.task }); };
    LET $now = time::now();
    LET $window = $schedule.catchup_window ?? fn::scheduler_settings_effective({ tenant: $schedule.tenant }).catchup_window;
    LET $selected = fn::scheduler_catchup_select($p.fire_times.at, $schedule.catchup, $window, $now);
    -- Exécutions restantes : au plus autant de créations
    LET $capped = IF $schedule.remaining IS NONE { $selected } ELSE { array::slice($selected, 0, $schedule.remaining) };
    LET $runs = array::fold($capped, [], |$acc, $t| {
        LET $run = fn::scheduler_run_spawn($schedule, $task, type::record("scheduler_run", [$schedule.id, $t]), $t, fn::scheduler_fire_available($p.fire_times, $t), "schedule", $schedule.overlap);
        RETURN IF $run == NONE { $acc } ELSE { array::append($acc, { id: $run.id, state: $run.state, scheduled_for: $run.scheduled_for }) };
    });
    LET $remaining = IF $schedule.remaining IS NONE { NONE } ELSE { $schedule.remaining - array::len($runs) };
    LET $done = $remaining = 0 OR $p.next_fire_at IS NONE;
    LET $last = array::last($runs);
    LET $sorted = array::sort::asc($p.fire_times.at);
    LET $updated = (UPDATE ONLY $schedule.id SET
        next_fire_at = IF $done { NONE } ELSE { $p.next_fire_at },
        last_fire_at = IF array::len($sorted) = 0 { last_fire_at } ELSE { array::last($sorted) },
        last_run = IF $last IS NONE { last_run } ELSE { $last.id },
        last_state = IF $last IS NONE { last_state } ELSE { $last.state },
        remaining = $remaining,
        state = IF $done { "completed" } ELSE { state });
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }); };
    RETURN fn::result_ok({ runs: $runs, ignored: array::len($p.fire_times) - array::len($runs), schedule: $updated });
} COMMENT "Moteur : traite les échéances d'une planification ({ schedule, fire_times : échéances passées calculées par Rust, chacune { at : date prévue, available_at : date de disponibilité décalée par le décalage aléatoire (U5), jamais avant at }, next_fire_at : prochaine échéance, NONE s'il n'y en a plus }) : rattrapage (last, all, none dans la fenêtre), au plus remaining créations, exécutions scheduler_run:[planification, date] (une échéance déjà créée est ignorée) soumises au chevauchement ; décrémente remaining ; planification terminée (completed) à 0 ou sans prochaine échéance. { runs, ignored, schedule }. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_next_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_next_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            next_fire_at: { pipeline: [{ rule: "datetime" }] },
            invalid_reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 1000 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF ($p.next_fire_at IS NONE) = ($p.invalid_reason IS NONE) {
        RETURN fn::scheduler_invalid($params, { "$": [{ code: "CORE_VALIDATION_COMBINATION", details: { allowed: ["next_fire_at", "invalid_reason"], max: 1 } }] });
    };
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF $schedule.state != "active" { RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { state: $schedule.state }); };
    LET $updated = IF $p.invalid_reason IS NOT NONE {
        (UPDATE ONLY $schedule.id SET state = "invalid", invalid_reason = $p.invalid_reason, next_fire_at = NONE)
    } ELSE {
        (UPDATE ONLY $schedule.id SET next_fire_at = $p.next_fire_at)
    };
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Moteur : écrit la prochaine échéance calculée par Rust ({ schedule, next_fire_at }) ou déclare la planification invalide ({ schedule, invalid_reason } : expression cron ou fuseau refusés) ; un seul des deux. Planification non active : SCHEDULER_SCHEDULE_STATE_INVALID. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_backfill_fire
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_backfill_fire($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            backfill: { pipeline: fn::scheduler_ref("scheduler_backfill"), required: true },
            fire_times: { pipeline: fn::scheduler_fire_times_pipeline([{ rule: "datetime" }]), required: true },
            done: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF fn::scheduler_fire_times_disordered($p.fire_times) { RETURN fn::scheduler_fire_times_invalid($params); };
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $backfill = (SELECT * FROM ONLY $p.backfill);
    IF $backfill == NONE OR $backfill.state NOTINSIDE ["pending", "running"] {
        RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { backfill: <string> $p.backfill, state: $backfill.state });
    };
    IF array::any($p.fire_times.at, |$t| $t < $backfill.from OR $t > $backfill.to) {
        RETURN fn::scheduler_invalid($params, { fire_times: [{ code: "CORE_VALIDATION_TOO_LARGE", details: { min: $backfill.from, max: $backfill.to } }] });
    };
    LET $schedule = (SELECT * FROM ONLY $backfill.schedule);
    LET $task = (SELECT * FROM ONLY $schedule.task);
    IF $task.state != "active" { RETURN fn::error_result("SCHEDULER_TASK_DISABLED", $p.language, { task: <string> $schedule.task }); };
    LET $overlap = $backfill.overlap ?? $schedule.overlap;
    LET $runs = array::fold(array::sort::asc(array::distinct($p.fire_times.at)), [], |$acc, $t| {
        LET $run = fn::scheduler_run_spawn($schedule, $task, type::record("scheduler_run", [$schedule.id, $t]), $t, fn::scheduler_fire_available($p.fire_times, $t), "backfill", $overlap);
        RETURN IF $run == NONE { $acc } ELSE { array::append($acc, { id: $run.id, state: $run.state, scheduled_for: $run.scheduled_for }) };
    });
    LET $updated = (UPDATE ONLY $backfill.id SET state = IF $p.done { "done" } ELSE { "running" }, runs_created += array::len($runs));
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_backfill" }); };
    RETURN fn::result_ok({ runs: $runs, backfill: $updated });
} COMMENT "Moteur : crée les exécutions d'un rejeu de période ({ backfill, fire_times : échéances de la période calculées par Rust, chacune { at, available_at (jamais avant at) }, done : dernier lot }) : scheduler_run:[planification, date] (origin: backfill ; une échéance déjà exécutée est ignorée), chevauchement du rejeu ou de la planification ; rejeu running, puis done. { runs, backfill }. Droit : session système ou scheduler.worker";

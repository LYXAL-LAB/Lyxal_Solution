-- ============================================================================
-- FONCTIONS : exécutions (gardes, exécutions différées, lecture, annulation, relance)
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Les gardes (fn::scheduler_run_create_refusal, _update_refusal, _delete_refusal) valent aussi
-- pour une écriture directe dans la table : transitions d'état, champs figés, jeton du bail.

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_create_refusal (interne, garde de création)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_create_refusal($after: object) -> option<string> {
    LET $engine = fn::scheduler_can({ action: "worker" });
    LET $caller = fn::scheduler_caller();
    IF $after.state NOTINSIDE ["queued", "waiting", "skipped"] OR $after.attempt != 0 OR $after.lease IS NOT NONE
        OR $after.locked_until IS NOT NONE OR $after.started_at IS NOT NONE OR $after.result IS NOT NONE OR $after.error IS NOT NONE
        OR $after.cancel_requested OR ($after.finished_at IS NOT NONE) != ($after.state = "skipped") {
        RETURN "SCHEDULER_RUN_STATE_INVALID";
    };
    -- Échéance et rejeu de période : moteur seulement, identifiant [planification, date prévue]
    IF $after.origin IN ["schedule", "backfill"] {
        IF !$engine { RETURN "SCHEDULER_PERMISSION_DENIED"; };
        IF $after.schedule IS NONE OR record::id($after.id) != [$after.schedule, $after.scheduled_for] { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    } ELSE IF !$caller.system AND $after.created_by != $caller.identity {
        RETURN "SCHEDULER_PERMISSION_DENIED";
    };
    IF ($after.origin = "enqueue") != ($after.schedule IS NONE) AND $after.origin != "retry" { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    IF $after.schedule IS NONE AND $after.state != "queued" { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    -- Relance : d'une exécution dead ou cancelled lisible, dont elle reprend l'organisation, la
    -- tâche, les arguments et la planification (si elle existe encore) ; jamais créée librement
    IF ($after.origin = "retry") != ($after.retry_of IS NOT NONE) { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    IF $after.origin = "retry" {
        LET $origin = (SELECT tenant, schedule, task, args, state FROM ONLY $after.retry_of);
        IF $origin == NONE { RETURN "SCHEDULER_RUN_NOT_FOUND"; };
        IF $origin.state NOTINSIDE ["dead", "cancelled"] OR $origin.tenant != $after.tenant OR $origin.task != $after.task OR $origin.args != $after.args
            OR $after.schedule != (IF $origin.schedule IS NOT NONE AND record::exists($origin.schedule) { $origin.schedule } ELSE { NONE }) {
            RETURN "SCHEDULER_RUN_STATE_INVALID";
        };
    };
    IF $after.schedule IS NOT NONE {
        LET $schedule = (SELECT tenant, task FROM ONLY $after.schedule);
        IF $schedule == NONE { RETURN "SCHEDULER_SCHEDULE_NOT_FOUND"; };
        IF $schedule.tenant != $after.tenant OR $schedule.task != $after.task { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    };
    LET $task = (SELECT * FROM ONLY $after.task);
    LET $usable = fn::scheduler_task_usable($task, $after.tenant);
    IF $usable IS NOT NONE { RETURN $usable; };
    IF $after.queue != $task.queue OR $after.max_attempts != $task.retry.max_attempts { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    LET $args = fn::scheduler_args_check($task, $after.args, $after.tenant);
    IF !$args.valid OR $args.value != $after.args { RETURN "SCHEDULER_ARGS_INVALID"; };
    RETURN NONE;
} COMMENT "Interne : refus de création d'une exécution ($after) : état initial (queued, waiting ou skipped, sans tentative ni bail) ; échéance et rejeu par le moteur, identifiant [planification, date prévue] ; auteur = appelant hors session système ; planification de la même organisation et de la même tâche ; exécution différée sans planification ; relance (et elle seule) avec retry_of, exécution dead ou cancelled lisible de la même organisation, de la même tâche et des mêmes arguments, planification d'origine reprise si elle existe encore ; tâche utilisable, file et tentatives de la tâche ; arguments conformes. La permission propre de la tâche est exigée par les permissions de la table. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_update_refusal (interne, garde de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_update_refusal($before: object, $after: object) -> option<string> {
    LET $engine = fn::scheduler_can({ action: "worker" });
    LET $frozen = ["schedule", "task", "args", "queue", "origin", "retry_of", "scheduled_for", "unique_key", "max_attempts", "priority"];
    IF array::any($frozen, |$f| $before[$f] != $after[$f]) { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    IF $before.created_by != $after.created_by AND !($after.created_by IS NONE AND $before.created_by IS NOT NONE AND !record::exists($before.created_by)) {
        RETURN "SCHEDULER_RUN_STATE_INVALID";
    };
    IF $before.cancel_requested AND !$after.cancel_requested { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    -- Annulation (ou demande d'annulation) : scheduler.run.manage ou moteur ; sans ce droit,
    -- seulement les exécutions d'une planification supprimée (fn::scheduler_schedule_delete),
    -- par une personne qui lit l'organisation (sans lecture, record::exists vaudrait faux)
    IF !$engine AND (($before.state != "cancelled" AND $after.state = "cancelled") OR (!$before.cancel_requested AND $after.cancel_requested))
        AND !fn::scheduler_can({ action: "run_manage", tenant: $before.tenant })
        AND !($before.schedule IS NOT NONE AND fn::scheduler_can({ action: "read", tenant: $before.tenant }) AND !record::exists($before.schedule)) {
        RETURN "SCHEDULER_PERMISSION_DENIED";
    };
    LET $terminal = ["completed", "dead", "cancelled", "skipped"];
    IF $before.state IN $terminal { RETURN IF $before.state != $after.state OR $before.result != $after.result OR $before.error != $after.error OR $before.finished_at != $after.finished_at { "SCHEDULER_RUN_STATE_INVALID" } ELSE { NONE }; };
    -- Champs du moteur : tentative, bail, dates, résultat, erreur
    LET $engine_fields = array::any(["attempt", "lease", "lease_node", "locked_until", "started_at", "duration_ms", "result", "error", "available_at"], |$f| $before[$f] != $after[$f]);
    IF $before.state = $after.state {
        IF $engine_fields AND (!$engine OR $before.state != "running" OR $before.lease != $after.lease OR $before.attempt != $after.attempt) { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
        IF !$before.cancel_requested AND $after.cancel_requested AND $before.state != "running" { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
        RETURN NONE;
    };
    LET $allowed = {
        waiting: ["queued", "cancelled"],
        queued: ["running", "cancelled"],
        retrying: ["running", "cancelled"],
        running: ["completed", "retrying", "dead", "cancelled"]
    }[$before.state];
    IF $after.state NOTINSIDE $allowed { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    IF $after.state IN $terminal AND $after.finished_at IS NONE { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    -- Libération d'une exécution en attente : aucune autre exécution active de la planification
    IF $before.state = "waiting" AND $after.state = "queued" {
        LET $busy = (SELECT VALUE id FROM scheduler_run WHERE schedule = $before.schedule AND id != $before.id AND state IN ["queued", "running", "retrying"] LIMIT 1);
        RETURN IF array::len($busy) > 0 OR $engine_fields { "SCHEDULER_RUN_STATE_INVALID" } ELSE { NONE };
    };
    -- Annulation d'une exécution qui ne tourne pas (droit contrôlé plus haut)
    IF $before.state != "running" AND $after.state = "cancelled" {
        RETURN IF $engine_fields { "SCHEDULER_RUN_STATE_INVALID" } ELSE { NONE };
    };
    IF !$engine { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    -- Réservation : bail nouveau, tentative suivante, échéance du bail dans le futur
    IF $after.state = "running" {
        RETURN IF $after.lease IS NONE OR $after.lease = $before.lease OR $after.attempt != $before.attempt + 1 OR $after.attempt > $after.max_attempts
            OR $after.locked_until IS NONE OR $after.locked_until <= time::now() OR $after.started_at IS NONE { "SCHEDULER_RUN_STATE_INVALID" } ELSE { NONE };
    };
    -- Fin d'une tentative : bail rendu ; échec avec erreur ; nouvelle tentative seulement s'il en reste
    IF $after.lease IS NOT NONE OR $after.locked_until IS NOT NONE OR $after.attempt != $before.attempt { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    IF $after.state IN ["retrying", "dead"] AND $after.error IS NONE { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    IF $after.state = "retrying" AND ($after.attempt >= $after.max_attempts OR $after.finished_at IS NOT NONE) { RETURN "SCHEDULER_RUN_STATE_INVALID"; };
    RETURN NONE;
} COMMENT "Interne : refus d'une modification d'exécution ($before, $after) : planification, tâche, arguments, file, origine, exécution relancée, date prévue, clé d'unicité, tentatives permises et priorité figés ; état terminal figé ; demande d'annulation irréversible ; annulation et demande d'annulation par scheduler.run.manage ou le moteur (sinon seulement les exécutions d'une planification supprimée) ; transitions waiting → queued (aucune autre exécution active de la planification) | cancelled, queued | retrying → running (moteur) | cancelled, running → completed | retrying | dead | cancelled (moteur) ; réservation avec un bail nouveau et la tentative suivante ; fin avec le bail rendu, erreur pour retrying et dead, retrying seulement s'il reste des tentatives ; champs du moteur (bail, tentative, dates, résultat, erreur) par le moteur seulement. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_delete_refusal (interne, garde de suppression)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_delete_refusal($before: object) -> option<string> {
    IF $before.tenant IS NOT NONE AND !record::exists($before.tenant) { RETURN NONE; };
    RETURN IF $before.state IN ["completed", "dead", "cancelled", "skipped"] { NONE } ELSE { "SCHEDULER_RUN_STATE_INVALID" };
} COMMENT "Interne : refus de suppression d'une exécution non terminée (élagage des seules exécutions terminées) ; la suppression d'une organisation emporte ses exécutions. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_pending_full (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_pending_full($tenant: option<record<auth_organization>>) -> option<int> {
    LET $max = fn::scheduler_settings_effective({ tenant: $tenant }).max_pending_runs;
    LET $pending = count(SELECT VALUE id FROM scheduler_run WHERE scope_key = fn::scheduler_scope_key($tenant) AND state IN ["waiting", "queued", "retrying"]);
    RETURN IF $pending >= $max { $max } ELSE { NONE };
} COMMENT "Interne : limite max_pending_runs de la portée si elle est atteinte (exécutions waiting, queued ou retrying), sinon NONE";

-- ----------------------------------------------------------------------------
-- fn::scheduler_pending_room (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_pending_room($tenant: option<record<auth_organization>>) -> int {
    LET $max = fn::scheduler_settings_effective({ tenant: $tenant }).max_pending_runs;
    LET $pending = count(SELECT VALUE id FROM scheduler_run WHERE scope_key = fn::scheduler_scope_key($tenant) AND state IN ["waiting", "queued", "retrying"]);
    RETURN math::max([$max - $pending, 0]);
} COMMENT "Interne : places restantes sous la limite max_pending_runs de la portée (exécutions waiting, queued ou retrying), jamais négatif ; utilisé par les échéances et les rejeux de période";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_enqueue
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_enqueue($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            task: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }], required: true },
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            args: { pipeline: [{ rule: "is_object" }], default: {} },
            run_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            delay: { pipeline: [{ rule: "duration", options: { min_value: 1s, max_value: 366d } }] },
            priority: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 9 } }] },
            unique_key: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF $p.run_at IS NOT NONE AND $p.delay IS NOT NONE {
        RETURN fn::scheduler_invalid($params, { "$": [{ code: "CORE_VALIDATION_COMBINATION", details: { present: ["run_at", "delay"], max: 1 } }] });
    };
    IF !fn::scheduler_can({ action: "write", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $task_id = fn::scheduler_task_record($p.task);
    LET $task = (SELECT * FROM ONLY $task_id);
    LET $usable = fn::scheduler_task_usable($task, $p.tenant);
    IF $usable IS NOT NONE { RETURN fn::error_result($usable, $p.language, { task: $p.task }); };
    IF !fn::scheduler_can({ action: "write", tenant: $p.tenant, task: $task_id }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, { task: $p.task }); };
    LET $args = fn::scheduler_args_check($task, $p.args, $p.tenant);
    IF !$args.valid { RETURN fn::error_result("SCHEDULER_ARGS_INVALID", $p.language, { fields: $args.details }); };
    -- Unicité (modèle Oban) : clé fournie, sinon empreinte des arguments
    LET $key = IF $p.unique_key IS NOT NONE { $p.unique_key } ELSE IF $task.unique_for IS NOT NONE { fn::security_hash_object($args.value, "sha256").hash } ELSE { NONE };
    IF $task.unique_for IS NOT NONE {
        LET $existing = (SELECT * FROM scheduler_run
            WHERE task = $task_id AND scope_key = fn::scheduler_scope_key($p.tenant) AND unique_key = $key
                AND state IN ["waiting", "queued", "running", "retrying"] AND created_at > time::now() - $task.unique_for
            ORDER BY created_at DESC LIMIT 1);
        IF array::len($existing) > 0 { RETURN fn::result_ok(object::extend($existing[0], { duplicate: true })); };
    };
    LET $full = fn::scheduler_pending_full($p.tenant);
    IF $full IS NOT NONE { RETURN fn::error_result("SCHEDULER_LIMIT_REACHED", $p.language, { limit: "max_pending_runs", max: $full }); };
    LET $at = $p.run_at ?? (time::now() + ($p.delay ?? 0s));
    LET $created = (CREATE ONLY scheduler_run CONTENT {
        tenant: $p.tenant,
        task: $task_id,
        args: $args.value,
        queue: $task.queue,
        priority: $p.priority ?? $task.priority,
        origin: "enqueue",
        scheduled_for: $at,
        available_at: $at,
        state: "queued",
        max_attempts: $task.retry.max_attempts,
        unique_key: $key,
        created_by: fn::scheduler_caller().identity
    });
    IF $created == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_run" }); };
    RETURN fn::result_ok(object::extend($created, { duplicate: false }));
} COMMENT "Crée une exécution différée ou immédiate d'une tâche ({ task, tenant, args, run_at (future) ou delay, priority, unique_key }) ; arguments contrôlés par le schéma de la tâche ; une tâche avec unique_for renvoie l'exécution non terminée de même clé (fournie, ou empreinte des arguments) créée depuis moins de unique_for (duplicate: true) ; limite max_pending_runs (SCHEDULER_LIMIT_REACHED). Droit : écriture et permission propre de la tâche";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $run = (SELECT * FROM ONLY $p.run);
    IF $run == NONE { RETURN fn::error_result("SCHEDULER_RUN_NOT_FOUND", $p.language, { run: <string> $p.run }); };
    RETURN fn::result_ok($run);
} COMMENT "Exécution ({ run }) ; le jeton du bail n'est rendu qu'au moteur ; une exécution illisible est introuvable (SCHEDULER_RUN_NOT_FOUND). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule") },
            task: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["waiting", "queued", "running", "retrying", "completed", "dead", "cancelled", "skipped"], case_sensitive: true } }] },
            since: { pipeline: [{ rule: "datetime" }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $task = IF $p.task IS NONE { NONE } ELSE { fn::scheduler_task_record($p.task) };
    LET $all = (SELECT * FROM scheduler_run
        WHERE scope_key = fn::scheduler_scope_key($p.tenant)
            AND ($p.schedule IS NONE OR schedule = $p.schedule)
            AND ($task IS NONE OR task = $task)
            AND ($p.state IS NONE OR state = $p.state)
            AND ($p.since IS NONE OR scheduled_for >= $p.since)
        ORDER BY scheduled_for DESC, id DESC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Exécutions d'une portée ({ tenant, schedule, task, state, since (date prévue), limit (500 au plus), start }), les plus récentes d'abord puis par identifiant décroissant à date prévue égale (ordre total) : { items, total }. Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_cancel
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_cancel($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            reason: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $run = (SELECT * FROM ONLY $p.run);
    IF $run == NONE { RETURN fn::error_result("SCHEDULER_RUN_NOT_FOUND", $p.language, { run: <string> $p.run }); };
    IF !fn::scheduler_can({ action: "run_manage", tenant: $run.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $updated = IF $run.state = "running" {
        IF $run.cancel_requested { NONE } ELSE { (UPDATE ONLY $run.id SET cancel_requested = true, cancel_reason = $p.reason) }
    } ELSE IF $run.state IN ["waiting", "queued", "retrying"] {
        (UPDATE ONLY $run.id SET state = "cancelled", finished_at = time::now(), cancel_reason = $p.reason)
    } ELSE { NONE };
    IF $updated == NONE AND ($run.state NOTINSIDE ["running", "waiting", "queued", "retrying"] OR $run.cancel_requested) {
        RETURN fn::error_result("SCHEDULER_RUN_STATE_INVALID", $p.language, { state: $run.state });
    };
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_run" }); };
    -- Une exécution en attente de la planification peut prendre la place libérée
    IF $updated.state = "cancelled" { fn::scheduler_run_release($run.schedule); };
    RETURN fn::result_ok($updated);
} COMMENT "Annule une exécution ({ run, reason }) : waiting, queued ou retrying → cancelled ; running → demande d'annulation (cancel_requested), acquittée par le moteur au battement puis à la fin de la tentative. Terminée ou déjà en annulation : SCHEDULER_RUN_STATE_INVALID. Droit : exécutions";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_retry
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_retry($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $run = (SELECT * FROM ONLY $p.run);
    IF $run == NONE { RETURN fn::error_result("SCHEDULER_RUN_NOT_FOUND", $p.language, { run: <string> $p.run }); };
    IF !fn::scheduler_can({ action: "run_manage", tenant: $run.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    -- Relancer fait exécuter la tâche : sa permission propre est exigée (Y1)
    IF !fn::scheduler_can({ action: "run_manage", tenant: $run.tenant, task: $run.task }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, { task: record::id($run.task) }); };
    IF $run.state NOTINSIDE ["dead", "cancelled"] { RETURN fn::error_result("SCHEDULER_RUN_STATE_INVALID", $p.language, { state: $run.state }); };
    LET $task = (SELECT * FROM ONLY $run.task);
    LET $usable = fn::scheduler_task_usable($task, $run.tenant);
    IF $usable IS NOT NONE { RETURN fn::error_result($usable, $p.language, { task: <string> $run.task }); };
    LET $full = fn::scheduler_pending_full($run.tenant);
    IF $full IS NOT NONE { RETURN fn::error_result("SCHEDULER_LIMIT_REACHED", $p.language, { limit: "max_pending_runs", max: $full }); };
    -- La planification d'origine a pu être supprimée : la relance devient indépendante
    LET $schedule = IF $run.schedule IS NOT NONE AND record::exists($run.schedule) { $run.schedule } ELSE { NONE };
    LET $now = time::now();
    LET $created = (CREATE ONLY scheduler_run CONTENT {
        tenant: $run.tenant,
        schedule: $schedule,
        task: $run.task,
        args: $run.args,
        queue: $task.queue,
        priority: $run.priority,
        origin: "retry",
        retry_of: $run.id,
        scheduled_for: $now,
        available_at: $now,
        state: "queued",
        max_attempts: $task.retry.max_attempts,
        created_by: fn::scheduler_caller().identity
    });
    IF $created == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_run" }); };
    RETURN fn::result_ok($created);
} COMMENT "Relance une exécution dead ou cancelled ({ run }) : nouvelle exécution immédiate (origin: retry, retry_of : l'exécution relancée) avec les mêmes arguments, tentatives remises à zéro ; l'exécution d'origine reste dans l'historique. Tâche désactivée : SCHEDULER_TASK_DISABLED. Droit : exécutions et permission propre de la tâche";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_ref
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_ref($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: [{ rule: "surql_record_string", options: { expected_table: "scheduler_run" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    -- Identifiant natif (les identifiants composés [planification, date] compris) : la chaîne, entièrement
    -- valide (surql_record_string ci-dessus), est relue telle quelle, puis contrôlée à son tour
    LET $native = fn::validation_record_id(type::record($p.run), ["scheduler_run"]);
    IF !$native.valid { RETURN fn::scheduler_invalid($params, { run: [$native.code] }); };
    RETURN fn::result_ok($native.value);
} COMMENT "Identifiant natif d'une exécution d'après sa forme texte SurrealQL complète ({ run : « scheduler_run:clé » ou « scheduler_run:[planification, date] » }), utilisé par les routes de l'hôte après le décodage base64url (RunRef) : chaîne contrôlée par la règle surql_record_string du Core limitée à scheduler_run (identifiant entier sous sa forme texte canonique), convertie, puis contrôlée par la règle record_id limitée à scheduler_run ; ni lecture ni écriture. Aucune autre table acceptée (SCHEDULER_INVALID_PARAMETERS). Droit : aucun";

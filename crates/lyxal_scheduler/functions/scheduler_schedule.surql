-- ============================================================================
-- FONCTIONS : planifications
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Une planification dit « quand » exécuter une tâche, avec quels arguments. La permission propre
-- de la tâche est contrôlée à la création et à chaque modification (T2) ; la pause, la reprise
-- et la suppression n'exigent que scheduler.schedule.write (un gestionnaire arrête une
-- planification dont l'auteur a perdu le droit). Les gardes valent aussi pour une écriture
-- directe dans la table.

-- ----------------------------------------------------------------------------
-- fn::scheduler_spec_check (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_spec_check($spec: any) -> object {
    LET $cron = [
        { rule: "array_of_strings", options: { allow_empty: true } },
        { rule: "array_length", options: { max_length: 10 } },
        { rule: "each", options: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] } }
    ];
    LET $report = fn::validation_object_execute($spec, {
        fields: {
            cron: { pipeline: $cron, default: [] },
            every: { pipeline: [{ rule: "array" }, { rule: "array_length", options: { max_length: 10 } }, { rule: "each", options: { pipeline: [{ rule: "duration", options: { min_value: 1s, max_value: 366d } }] } }], default: [] },
            at: { pipeline: [{ rule: "datetime" }] },
            exclude_cron: { pipeline: $cron, default: [] },
            timezone: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], default: "UTC" },
            start_at: { pipeline: [{ rule: "datetime" }] },
            end_at: { pipeline: [{ rule: "datetime" }] },
            jitter: { pipeline: [{ rule: "duration", options: { min_value: 0s, max_value: 1h } }] }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid { RETURN { valid: false, value: NONE, by_field: $report.by_field }; };
    LET $s = $report.value;
    -- Règles propres à la forme d'une planification : au moins une règle ; début avant la fin
    IF array::len($s.cron) = 0 AND array::len($s.every) = 0 AND $s.at IS NONE {
        RETURN { valid: false, value: NONE, by_field: { "$": [{ code: "CORE_VALIDATION_REQUIRED", details: { one_of: ["cron", "every", "at"] } }] } };
    };
    IF $s.start_at IS NOT NONE AND $s.end_at IS NOT NONE AND $s.end_at <= $s.start_at {
        RETURN { valid: false, value: NONE, by_field: { end_at: [{ code: "CORE_VALIDATION_RANGE_ORDER", details: { start: $s.start_at, end: $s.end_at, allow_equal: false } }] } };
    };
    RETURN { valid: true, value: $s, by_field: {} };
} COMMENT "Interne : contrôle la forme des règles de dates d'une planification ({ cron, every, at, exclude_cron, timezone, start_at, end_at, jitter }) par le moteur du Core : listes de 10 au plus, expressions de 1 à 128 caractères, intervalles de 1 s à 366 jours, fuseau non vide (UTC par défaut), décalage aléatoire d'une heure au plus ; au moins une règle cron, un intervalle ou une date unique ; début avant la fin. La syntaxe cron et le nom du fuseau sont contrôlés par le calcul des dates en Rust. { valid, value, by_field }";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendars_valid (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendars_valid($calendars: array, $scope_key: string) -> bool {
    LET $found = (SELECT VALUE id FROM scheduler_calendar WHERE id IN $calendars AND scope_key = $scope_key);
    RETURN array::len($found) = array::len(array::distinct($calendars));
} COMMENT "Interne : vrai si chaque calendrier existe, est lisible par l'appelant et appartient à la portée de la planification";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_content_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_content_refusal($after: object) -> option<string> {
    LET $spec = fn::scheduler_spec_check($after.spec);
    IF !$spec.valid { RETURN "SCHEDULER_SPEC_INVALID"; };
    LET $task = (SELECT * FROM ONLY $after.task);
    LET $usable = fn::scheduler_task_usable($task, $after.tenant);
    IF $usable IS NOT NONE { RETURN $usable; };
    LET $args = fn::scheduler_args_check($task, $after.args, $after.tenant);
    IF !$args.valid OR $args.value != $after.args { RETURN "SCHEDULER_ARGS_INVALID"; };
    IF !fn::scheduler_calendars_valid($after.calendars, $after.scope_key) { RETURN "SCHEDULER_CALENDAR_NOT_FOUND"; };
    RETURN NONE;
} COMMENT "Interne : refus du contenu d'une planification ($after) : règles de dates, tâche utilisable (existante, active, de la bonne portée), arguments conformes au schéma de la tâche, calendriers de la même portée. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_create_refusal (interne, garde de création)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_create_refusal($after: object) -> option<string> {
    IF $after.state != "active" OR $after.next_fire_at IS NOT NONE OR $after.last_fire_at IS NOT NONE OR $after.last_run IS NOT NONE
        OR $after.last_state IS NOT NONE OR $after.invalid_reason IS NOT NONE OR $after.remaining = 0 {
        RETURN "SCHEDULER_SCHEDULE_STATE_INVALID";
    };
    LET $caller = fn::scheduler_caller();
    IF !$caller.system AND $after.created_by != $caller.identity { RETURN "SCHEDULER_PERMISSION_DENIED"; };
    LET $content = fn::scheduler_schedule_content_refusal($after);
    IF $content IS NOT NONE { RETURN $content; };
    LET $count = count(SELECT VALUE id FROM scheduler_schedule WHERE scope_key = $after.scope_key);
    IF $count > fn::scheduler_settings_effective({ tenant: $after.tenant }).max_schedules { RETURN "SCHEDULER_LIMIT_REACHED"; };
    RETURN NONE;
} COMMENT "Interne : refus de création d'une planification ($after) : état initial (active, sans échéance ni dernière exécution) ; auteur = appelant hors session système ; contenu valide ; limite max_schedules de la portée. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_update_refusal (interne, garde de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_update_refusal($before: object, $after: object) -> option<string> {
    LET $engine = fn::scheduler_can({ action: "worker" });
    -- Auteur figé, sauf effacement par la suppression de l'identité
    IF $before.created_by != $after.created_by AND !($after.created_by IS NONE AND $before.created_by IS NOT NONE AND !record::exists($before.created_by)) {
        RETURN "SCHEDULER_PERMISSION_DENIED";
    };
    -- Champs du moteur : prochaine échéance (sauf remise à calculer), dernière exécution, motif d'invalidité
    LET $engine_fields = array::any(["last_fire_at", "last_run", "last_state"], |$f| $before[$f] != $after[$f])
        OR ($before.next_fire_at != $after.next_fire_at AND $after.next_fire_at IS NOT NONE)
        OR ($before.invalid_reason != $after.invalid_reason AND $after.invalid_reason IS NOT NONE);
    IF $engine_fields AND !$engine { RETURN "SCHEDULER_SCHEDULE_STATE_INVALID"; };
    LET $user_fields = array::filter(["args", "spec", "calendars", "overlap", "catchup", "catchup_window", "pause_on_failure"], |$f| $before[$f] != $after[$f]);
    IF $before.state = "completed" AND (array::len($user_fields) > 0 OR $after.state != "completed" OR (!$before.paused AND $after.paused)) { RETURN "SCHEDULER_SCHEDULE_STATE_INVALID"; };
    -- Toute modification des règles, des calendriers ou de la pause remet la prochaine échéance à calculer
    IF ($before.spec != $after.spec OR $before.calendars != $after.calendars OR $before.paused != $after.paused) AND $after.next_fire_at IS NOT NONE {
        RETURN "SCHEDULER_SCHEDULE_STATE_INVALID";
    };
    IF $before.state != $after.state {
        LET $allowed = IF $engine { { active: ["completed", "invalid"], invalid: ["active", "completed"] } } ELSE { { invalid: ["active"] } };
        IF $after.state NOTINSIDE ($allowed[$before.state] ?? []) { RETURN "SCHEDULER_SCHEDULE_STATE_INVALID"; };
        IF $after.state = "invalid" AND $after.invalid_reason IS NONE { RETURN "SCHEDULER_SCHEDULE_STATE_INVALID"; };
        IF $before.state = "invalid" AND $after.state = "active" AND ($after.invalid_reason IS NOT NONE OR $after.next_fire_at IS NOT NONE) { RETURN "SCHEDULER_SCHEDULE_STATE_INVALID"; };
    };
    -- Arguments, règles, calendriers et politiques : permission propre de la tâche (T2) et contenu valide
    IF array::len($user_fields) > 0 {
        IF !fn::scheduler_can({ action: "write", tenant: $before.tenant, task: $before.task }) { RETURN "SCHEDULER_PERMISSION_DENIED"; };
        LET $content = fn::scheduler_schedule_content_refusal($after);
        IF $content IS NOT NONE { RETURN $content; };
    };
    -- Exécutions restantes : le moteur décrémente ; une personne fixe une nouvelle valeur avec le droit de la tâche
    IF $before.remaining != $after.remaining AND !$engine AND !fn::scheduler_can({ action: "write", tenant: $before.tenant, task: $before.task }) {
        RETURN "SCHEDULER_PERMISSION_DENIED";
    };
    RETURN NONE;
} COMMENT "Interne : refus d'une modification de planification ($before, $after) : auteur figé ; prochaine échéance, dernière exécution et invalidité écrites par le moteur seulement (une remise à calculer est permise) ; planification terminée figée ; modification des règles, des calendriers ou de la pause avec prochaine échéance remise à NONE ; transitions active → completed | invalid (moteur), invalid → active (règles corrigées) ; arguments, règles, calendriers, politiques et exécutions restantes avec la permission propre de la tâche et un contenu valide. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_view($id: record<scheduler_schedule>) -> option<object> {
    LET $schedule = (SELECT * FROM ONLY $id);
    IF $schedule == NONE { RETURN NONE; };
    RETURN object::extend($schedule, {
        recent_runs: (SELECT id, state, origin, scheduled_for, attempt, finished_at, error FROM scheduler_run
            WHERE schedule = $id ORDER BY scheduled_for DESC LIMIT 10)
    });
} COMMENT "Interne : planification et ses 10 dernières exécutions lisibles (identifiant, état, origine, date prévue, tentative, fin, erreur)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_fields (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_fields() -> object {
    RETURN {
        args: { pipeline: [{ rule: "is_object" }] },
        spec: { pipeline: [{ rule: "is_object" }] },
        calendars: { pipeline: [{ rule: "array" }, { rule: "array_length", options: { max_length: 10 } }, { rule: "each", options: { pipeline: fn::scheduler_ref("scheduler_calendar") } }] },
        overlap: { pipeline: [{ rule: "enum", options: { allowed: ["skip", "buffer_one", "buffer_all", "cancel_other", "allow_all"], case_sensitive: true } }] },
        catchup: { pipeline: [{ rule: "enum", options: { allowed: ["last", "all", "none"], case_sensitive: true } }] },
        catchup_window: { pipeline: [{ rule: "duration", options: { min_value: 1m, max_value: 30d } }] },
        remaining: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000000 } }] },
        pause_on_failure: { pipeline: [{ rule: "boolean" }] },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
    };
} COMMENT "Interne : schéma du moteur de validation des champs modifiables d'une planification (create et update)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::scheduler_schedule_fields(), {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            name: { pipeline: [{ rule: "slug", options: { max_length: 128 } }], required: true },
            task: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }], required: true },
            spec: { pipeline: [{ rule: "is_object" }], required: true },
            paused: { pipeline: [{ rule: "boolean" }], default: false },
            paused_reason: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] }
        }),
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $spec = fn::scheduler_spec_check($p.spec);
    IF !$spec.valid { RETURN fn::error_result("SCHEDULER_SPEC_INVALID", $p.language, { fields: $spec.by_field }); };
    IF !fn::scheduler_can({ action: "write", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $task_id = fn::scheduler_task_record($p.task);
    LET $task = (SELECT * FROM ONLY $task_id);
    LET $usable = fn::scheduler_task_usable($task, $p.tenant);
    IF $usable IS NOT NONE { RETURN fn::error_result($usable, $p.language, { task: $p.task }); };
    IF !fn::scheduler_can({ action: "write", tenant: $p.tenant, task: $task_id }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, { task: $p.task }); };
    LET $args = fn::scheduler_args_check($task, $p.args, $p.tenant);
    IF !$args.valid { RETURN fn::error_result("SCHEDULER_ARGS_INVALID", $p.language, { fields: $args.details }); };
    LET $scope = fn::scheduler_scope_key($p.tenant);
    LET $calendars = array::distinct($p.calendars ?? []);
    IF !fn::scheduler_calendars_valid($calendars, $scope) { RETURN fn::error_result("SCHEDULER_CALENDAR_NOT_FOUND", $p.language, {}); };
    LET $max = fn::scheduler_settings_effective({ tenant: $p.tenant }).max_schedules;
    IF count(SELECT VALUE id FROM scheduler_schedule WHERE scope_key = $scope) >= $max { RETURN fn::error_result("SCHEDULER_LIMIT_REACHED", $p.language, { limit: "max_schedules", max: $max }); };
    LET $inserted = (INSERT IGNORE INTO scheduler_schedule {
        tenant: $p.tenant,
        name: $p.name,
        task: $task_id,
        args: $args.value,
        spec: $spec.value,
        calendars: $calendars,
        overlap: $p.overlap ?? "skip",
        catchup: $p.catchup ?? "last",
        catchup_window: $p.catchup_window,
        remaining: $p.remaining,
        paused: $p.paused,
        paused_reason: IF $p.paused { $p.paused_reason } ELSE { NONE },
        pause_on_failure: $p.pause_on_failure ?? false,
        created_by: fn::scheduler_caller().identity
    });
    IF array::len($inserted) = 0 {
        -- Doublon de nom, ou écriture filtrée par les permissions de la table
        LET $existing = (SELECT VALUE id FROM scheduler_schedule WHERE scope_key = $scope AND name = $p.name LIMIT 1);
        RETURN IF array::len($existing) > 0 { fn::error_result("SCHEDULER_SCHEDULE_EXISTS", $p.language, { name: $p.name }) }
            ELSE { fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }) };
    };
    RETURN fn::result_ok(fn::scheduler_schedule_view($inserted[0].id));
} COMMENT "Crée une planification ({ name, task, spec, tenant, args, calendars, overlap, catchup, catchup_window, remaining, pause_on_failure, paused, paused_reason }) d'une tâche active de la bonne portée ; arguments contrôlés par le schéma de la tâche ; nom unique dans la portée (SCHEDULER_SCHEDULE_EXISTS) ; limite max_schedules (SCHEDULER_LIMIT_REACHED). La prochaine échéance est à calculer (next_fire_at NONE). Droit : écriture et permission propre de la tâche";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::scheduler_schedule_fields(), {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["catchup_window", "remaining", "calendars"], case_sensitive: true } }] } }], default: [] }
        }),
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $spec = IF $p.spec IS NONE { NONE } ELSE { fn::scheduler_spec_check($p.spec) };
    IF $spec IS NOT NONE AND !$spec.valid { RETURN fn::error_result("SCHEDULER_SPEC_INVALID", $p.language, { fields: $spec.by_field }); };
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF !fn::scheduler_can({ action: "write", tenant: $schedule.tenant, task: $schedule.task }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    IF $schedule.state = "completed" { RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { state: $schedule.state }); };
    LET $task = (SELECT * FROM ONLY $schedule.task);
    LET $args = IF $p.args IS NONE { { valid: true, value: $schedule.args } } ELSE { fn::scheduler_args_check($task, $p.args, $schedule.tenant) };
    IF !$args.valid { RETURN fn::error_result("SCHEDULER_ARGS_INVALID", $p.language, { fields: $args.details }); };
    LET $calendars = IF "calendars" IN $p.clear { [] } ELSE IF $p.calendars IS NONE { $schedule.calendars } ELSE { array::distinct($p.calendars) };
    IF !fn::scheduler_calendars_valid($calendars, $schedule.scope_key) { RETURN fn::error_result("SCHEDULER_CALENDAR_NOT_FOUND", $p.language, {}); };
    LET $new_spec = $spec.value ?? $schedule.spec;
    LET $recompute = $new_spec != $schedule.spec OR $calendars != $schedule.calendars;
    -- Règles corrigées : une planification invalide redevient active, à recalculer
    LET $revive = $schedule.state = "invalid" AND $recompute;
    LET $updated = (UPDATE ONLY $schedule.id SET
        args = $args.value,
        spec = $new_spec,
        calendars = $calendars,
        overlap = $p.overlap ?? overlap,
        catchup = $p.catchup ?? catchup,
        catchup_window = IF "catchup_window" IN $p.clear { NONE } ELSE { $p.catchup_window ?? catchup_window },
        remaining = IF "remaining" IN $p.clear { NONE } ELSE { $p.remaining ?? remaining },
        pause_on_failure = $p.pause_on_failure ?? pause_on_failure,
        next_fire_at = IF $recompute { NONE } ELSE { next_fire_at },
        state = IF $revive { "active" } ELSE { state },
        invalid_reason = IF $revive { NONE } ELSE { invalid_reason });
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }); };
    RETURN fn::result_ok(fn::scheduler_schedule_view($schedule.id));
} COMMENT "Modifie une planification ({ schedule, args, spec, calendars, overlap, catchup, catchup_window, remaining, pause_on_failure, clear : catchup_window, remaining, calendars }) : un champ absent est conservé ; le nom et la tâche ne changent pas. Des règles ou des calendriers nouveaux remettent la prochaine échéance à calculer et rendent active une planification invalide. Planification terminée : SCHEDULER_SCHEDULE_STATE_INVALID. Droit : écriture et permission propre de la tâche";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $view = fn::scheduler_schedule_view($p.schedule);
    IF $view == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    RETURN fn::result_ok($view);
} COMMENT "Planification et ses 10 dernières exécutions ({ schedule }) ; une planification illisible est introuvable (SCHEDULER_SCHEDULE_NOT_FOUND). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            task: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "completed", "invalid"], case_sensitive: true } }] },
            paused: { pipeline: [{ rule: "boolean" }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $task = IF $p.task IS NONE { NONE } ELSE { fn::scheduler_task_record($p.task) };
    LET $all = (SELECT * FROM scheduler_schedule
        WHERE scope_key = fn::scheduler_scope_key($p.tenant)
            AND ($task IS NONE OR task = $task)
            AND ($p.state IS NONE OR state = $p.state)
            AND ($p.paused IS NONE OR paused = $p.paused)
        ORDER BY name ASC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Planifications d'une portée ({ tenant, task, state, paused, limit (500 au plus), start }), par nom : { items, total }. Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_pause
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_pause($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            reason: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF !fn::scheduler_can({ action: "write", tenant: $schedule.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    IF $schedule.paused OR $schedule.state = "completed" { RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { state: $schedule.state, paused: $schedule.paused }); };
    LET $updated = (UPDATE ONLY $schedule.id SET paused = true, paused_reason = $p.reason, next_fire_at = NONE);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }); };
    RETURN fn::result_ok(fn::scheduler_schedule_view($schedule.id));
} COMMENT "Met une planification en pause ({ schedule, reason }) : aucune échéance n'est créée ; les exécutions déjà créées continuent. Déjà en pause ou terminée : SCHEDULER_SCHEDULE_STATE_INVALID. Droit : écriture (sans la permission de la tâche)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_resume
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_resume($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF !fn::scheduler_can({ action: "write", tenant: $schedule.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    IF !$schedule.paused OR $schedule.state = "completed" { RETURN fn::error_result("SCHEDULER_SCHEDULE_STATE_INVALID", $p.language, { state: $schedule.state, paused: $schedule.paused }); };
    LET $updated = (UPDATE ONLY $schedule.id SET paused = false, paused_reason = NONE, next_fire_at = NONE);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }); };
    RETURN fn::result_ok(fn::scheduler_schedule_view($schedule.id));
} COMMENT "Reprend une planification en pause ({ schedule }) ; la prochaine échéance est recalculée à partir de maintenant (les échéances manquées pendant la pause suivent le rattrapage). Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_schedule_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_schedule_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $schedule = (SELECT * FROM ONLY $p.schedule);
    IF $schedule == NONE { RETURN fn::error_result("SCHEDULER_SCHEDULE_NOT_FOUND", $p.language, { schedule: <string> $p.schedule }); };
    IF !fn::scheduler_can({ action: "write", tenant: $schedule.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    -- Exécutions en attente annulées ; celle en cours reçoit une demande d'annulation ; l'historique reste
    UPDATE scheduler_run SET state = "cancelled", finished_at = time::now(), cancel_reason = "schedule_deleted"
        WHERE schedule = $schedule.id AND state IN ["waiting", "queued", "retrying"];
    UPDATE scheduler_run SET cancel_requested = true, cancel_reason = "schedule_deleted"
        WHERE schedule = $schedule.id AND state = "running" AND !cancel_requested;
    LET $deleted = (DELETE ONLY $schedule.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_schedule" }); };
    RETURN fn::result_ok({ deleted: <string> $schedule.id });
} COMMENT "Supprime une planification ({ schedule }) : ses exécutions en attente sont annulées, celle en cours reçoit une demande d'annulation, ses rejeux sont supprimés ; l'historique des exécutions est gardé. Droit : écriture (sans la permission de la tâche)";

-- lyxal-test: assertions
-- Fonctions internes appelées directement : portée, langue, erreur de paramètres, références,
-- réglages effectifs, journal et bus, contrôles (tâche, arguments, règles de dates, calendriers,
-- rattrapage), gardes (tâches, files, calendriers, planifications, rejeux, exécutions),
-- chevauchement, création et libération d'exécutions, réservation et fin sous bail.
--
-- identité admin: {"id": "auth_session:admin", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "scheduler.run.manage", "scheduler.calendar.write", "scheduler.settings.manage", "essai.rapport.run"]}
-- identité redacteur: {"id": "auth_session:redacteur", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "essai.rapport.run"]}
-- identité sanstache: {"id": "auth_session:sanstache", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write"]}
-- identité lecteur: {"id": "auth_session:lecteur", "pv": 1, "permissions": ["scheduler.schedule.read"]}
-- identité operateur: {"id": "auth_session:operateur", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.run.manage"]}
-- identité membre: {"id": "auth_session:membre", "pv": 1, "permissions": []}
-- identité autre: {"id": "auth_session:autre", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "scheduler.run.manage", "scheduler.calendar.write", "scheduler.settings.manage", "essai.rapport.run"]}
-- identité plateforme: {"id": "auth_session:plateforme", "pv": 1, "permissions": ["scheduler.installation.manage"]}
-- identité worker: {"id": "auth_session:worker", "pv": 1, "permissions": ["scheduler.worker"]}

-- préparation: organisations, identités, sessions et tâches d'essai déclarées en session système
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $n IN ["admin", "redacteur", "sanstache", "lecteur", "operateur", "membre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    FOR $n IN ["plateforme", "worker"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    -- Permission propre d'une tâche d'essai, déclarée par son module
    CREATE auth_permission:⟨essai.rapport.run⟩ CONTENT { code: "essai.rapport.run", module: "lyxal_essai", scope: "organization", description: { fr: "Planifier le rapport", en: "Schedule the report" } };
    -- Tâches d'essai (seed d'un module fictif lyxal_essai)
    CREATE scheduler_task:⟨essai.rapport⟩ CONTENT {
        module: "lyxal_essai", executor: "handler", target: "essai.rapport", permission: "essai.rapport.run",
        description: { fr: "Rapport", en: "Report" },
        args_schema: { fields: { format: { pipeline: [{ rule: "enum", options: { allowed: ["pdf", "csv"], case_sensitive: true } }], required: true }, note: { pipeline: [{ rule: "optional_string", options: { max_length: 2000 } }] } }, unknown_keys: "reject" },
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 10s, max_delay: 30s }, timeout: 1m
    };
    CREATE scheduler_task:⟨essai.purge⟩ CONTENT {
        module: "lyxal_essai", executor: "function", target: "essai_purge", queue: scheduler_queue:maintenance, priority: 7,
        unique_for: 1h, retry: { max_attempts: 2, strategy: "fixed", initial_delay: 5s, max_delay: 5s }
    };
    CREATE scheduler_task:⟨essai.global⟩ CONTENT {
        module: "lyxal_essai", executor: "event", target: "essai.global.tick", scope: "installation",
        retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
    };
    -- Table de passage d'identifiants entre identités (lisible par tous)
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- test: portée, chaîne d'organisation, langue, erreur de paramètres, enregistrements
RETURN fn::scheduler_scope_key(NONE) = "installation" AND fn::scheduler_scope_key(auth_organization:alpha) = "alpha"
    AND fn::scheduler_tenant_string(NONE) IS NONE AND fn::scheduler_tenant_string(auth_organization:alpha) = "auth_organization:alpha"
    AND fn::scheduler_language({ language: "en" }) = "en" AND fn::scheduler_language({ language: 3 }) IS NONE AND fn::scheduler_language("x") IS NONE
    AND fn::scheduler_invalid({ language: "en" }, { a: ["X"] }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_invalid({}, { a: ["X"] }).error.details.fields = { a: ["X"] }
    AND fn::scheduler_task_record("essai.rapport") = scheduler_task:⟨essai.rapport⟩
    AND fn::scheduler_queue_record("default") = scheduler_queue:default
    AND fn::scheduler_slot_record(scheduler_queue:default, "alpha") = scheduler_slot:["default", "alpha"]
    AND fn::scheduler_lease_margin() = 1m;

-- test: référence d'enregistrement : identifiant natif ou chaîne, table contrôlée
RETURN fn::validation_object_execute({ r: "scheduler_run:abc" }, { fields: { r: { pipeline: fn::scheduler_ref("scheduler_run") } } }, 20).value.r = scheduler_run:abc
    AND fn::validation_object_execute({ r: scheduler_run:[scheduler_schedule:x, d"2026-01-01T00:00:00Z"] }, { fields: { r: { pipeline: fn::scheduler_ref("scheduler_run") } } }, 20).valid
    AND !fn::validation_object_execute({ r: scheduler_task:x }, { fields: { r: { pipeline: fn::scheduler_ref("scheduler_run") } } }, 20).valid
    AND !fn::validation_object_execute({ r: "autre:x" }, { fields: { r: { pipeline: fn::scheduler_ref("scheduler_run") } } }, 20).valid;

-- test: schéma des champs d'une planification partagé par create et update
RETURN object::keys(fn::scheduler_schedule_fields()) == ["args", "calendars", "catchup", "catchup_window", "language", "overlap", "pause_on_failure", "remaining", "spec"];

-- test: règles de dates : normalisées, valeurs par défaut
RETURN fn::scheduler_spec_check({ every: [1h] }).value == { cron: [], every: [1h], exclude_cron: [], timezone: "UTC" }
    AND fn::scheduler_spec_check({ at: d"2027-01-01T09:00:00Z" }).valid
    AND !fn::scheduler_spec_check("x").valid
    AND fn::scheduler_spec_check({}).by_field["$"][0].code = "CORE_VALIDATION_REQUIRED";

-- test: règles d'un calendrier : normalisées ou refusées
RETURN fn::scheduler_calendar_rules_check([{ mode: "include", kind: "weekdays", values: [1, 5] }]).valid
    AND !fn::scheduler_calendar_rules_check("x").valid
    AND !fn::scheduler_calendar_rules_check([{ mode: "include", kind: "time_range", values: ["25:00-26:00"] }]).valid;

-- test: rattrapage : sélection selon la politique et la fenêtre
{
    LET $now = d"2026-06-01T12:00:00Z";
    LET $t = [d"2026-06-01T09:00:00Z", d"2026-06-01T11:30:00Z", d"2026-06-01T11:59:30Z", d"2026-06-01T11:30:00Z"];
    RETURN fn::scheduler_catchup_select($t, "all", 1h, $now) = [d"2026-06-01T11:30:00Z", d"2026-06-01T11:59:30Z"]
        AND fn::scheduler_catchup_select($t, "last", 1h, $now) = [d"2026-06-01T11:59:30Z"]
        AND fn::scheduler_catchup_select($t, "none", 1h, $now) = [d"2026-06-01T11:59:30Z"]
        AND fn::scheduler_catchup_select([d"2026-06-01T11:30:00Z"], "none", 1h, $now) = []
        AND fn::scheduler_catchup_select([d"2026-06-01T09:00:00Z"], "last", 1h, $now) = []
        AND fn::scheduler_catchup_select([], "all", 1h, $now) = [];
};

-- test: échéances fournies par le moteur : pipeline, ordre de la disponibilité, disponibilité d'une date
{
    LET $t = d"2026-06-01T12:00:00Z";
    LET $times = [{ at: $t, available_at: $t + 30s }, { at: $t + 1h, available_at: $t + 1h }];
    LET $ok = fn::validation_object_execute({ f: $times }, { fields: { f: { pipeline: fn::scheduler_fire_times_pipeline([{ rule: "datetime" }]) } }, unknown_keys: "reject" }, 20);
    LET $ko = fn::validation_object_execute({ f: [{ at: $t }] }, { fields: { f: { pipeline: fn::scheduler_fire_times_pipeline([{ rule: "datetime" }]) } }, unknown_keys: "reject" }, 20);
    RETURN $ok.valid AND !$ko.valid
        AND !fn::scheduler_fire_times_disordered($times)
        AND fn::scheduler_fire_times_disordered([{ at: $t, available_at: $t - 1s }])
        AND fn::scheduler_fire_times_invalid({ language: "en" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_fire_available($times, $t) = $t + 30s
        AND fn::scheduler_fire_available($times, $t + 2h) = $t + 2h;
};

-- test: tâche utilisable et arguments
{
    LET $task = (SELECT * FROM ONLY scheduler_task:⟨essai.rapport⟩);
    RETURN fn::scheduler_task_usable($task, auth_organization:alpha) IS NONE
        AND fn::scheduler_task_usable(NONE, auth_organization:alpha) = "SCHEDULER_TASK_NOT_FOUND"
        AND fn::scheduler_task_usable($task, NONE) = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_task_usable(object::extend($task, { state: "disabled" }), auth_organization:alpha) = "SCHEDULER_TASK_DISABLED"
        AND fn::scheduler_args_check($task, { format: "pdf" }, auth_organization:alpha).value = { format: "pdf" }
        AND !fn::scheduler_args_check($task, "texte", auth_organization:alpha).valid
        AND fn::scheduler_args_check((SELECT * FROM ONLY scheduler_task:⟨essai.purge⟩), NONE, auth_organization:alpha).value = {}
        AND !fn::scheduler_args_check((SELECT * FROM ONLY scheduler_task:⟨essai.purge⟩), { a: 1 }, auth_organization:alpha).valid;
};

-- test: gardes de tâche appelées directement
{
    LET $task = (SELECT * FROM ONLY scheduler_task:⟨essai.rapport⟩);
    RETURN fn::scheduler_task_create_refusal($task) IS NONE
        AND fn::scheduler_task_create_refusal(object::extend($task, { module: "lyxal_x" })) = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_task_update_refusal($task, object::extend($task, { state: "disabled" })) IS NONE
        AND fn::scheduler_task_update_refusal($task, object::extend($task, { timeout: 2m })) = "SCHEDULER_PERMISSION_DENIED";
};

-- test: garde de file appelée directement
{
    LET $q = (SELECT * FROM ONLY scheduler_queue:default);
    RETURN fn::scheduler_queue_update_refusal($q, object::extend($q, { paused: true })) IS NONE
        AND fn::scheduler_queue_update_refusal($q, object::extend($q, { running: 1 })) IS NONE;
};

-- test: garde de file : une personne ne touche pas au compteur
-- en tant que: plateforme
{
    LET $q = (SELECT * FROM ONLY scheduler_queue:default);
    RETURN fn::scheduler_queue_update_refusal($q, object::extend($q, { running: 1 })) = "SCHEDULER_PERMISSION_DENIED"
        AND fn::scheduler_queue_update_refusal($q, object::extend($q, { paused: true })) IS NONE;
};

-- préparation: calendrier, planification, exécution et rejeu d'essai
{
    LET $cal = fn::scheduler_calendar_create({ tenant: auth_organization:alpha, name: "cal", rules: [{ mode: "include", kind: "weekdays", values: [1] }] }).data;
    LET $s = fn::scheduler_schedule_create({ tenant: auth_organization:alpha, name: "interne", task: "essai.rapport", args: { format: "pdf" }, spec: { every: [1h] }, calendars: [$cal.id], overlap: "buffer_all" }).data;
    LET $b = fn::scheduler_schedule_backfill({ schedule: $s.id, from: time::now() - 2d, to: time::now() - 1d }).data;
    CREATE passe:i SET cal = $cal, schedule = $s.id, backfill = $b;
};

-- test: gardes de calendrier, de planification et de rejeu appelées directement
{
    LET $i = (SELECT * FROM ONLY passe:i);
    LET $s = (SELECT * FROM ONLY $i.schedule);
    RETURN fn::scheduler_calendar_write_refusal(NONE, $i.cal) IS NONE
        AND fn::scheduler_calendar_write_refusal($i.cal, object::extend($i.cal, { rules: [] })) = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_calendar_delete_refusal($i.cal) = "SCHEDULER_CALENDAR_IN_USE"
        AND fn::scheduler_calendars_valid([$i.cal.id], "alpha") AND !fn::scheduler_calendars_valid([$i.cal.id], "beta")
        AND fn::scheduler_schedule_content_refusal($s) IS NONE
        AND fn::scheduler_schedule_content_refusal(object::extend($s, { args: { format: "x" } })) = "SCHEDULER_ARGS_INVALID"
        AND fn::scheduler_schedule_create_refusal($s) IS NONE
        AND fn::scheduler_schedule_create_refusal(object::extend($s, { state: "completed" })) = "SCHEDULER_SCHEDULE_STATE_INVALID"
        AND fn::scheduler_schedule_update_refusal($s, object::extend($s, { overlap: "skip" })) IS NONE
        AND fn::scheduler_schedule_update_refusal($s, object::extend($s, { spec: { every: [2h], cron: [], exclude_cron: [], timezone: "UTC" }, next_fire_at: time::now() })) = "SCHEDULER_SCHEDULE_STATE_INVALID"
        AND fn::scheduler_backfill_refusal($i.backfill) IS NONE
        AND fn::scheduler_backfill_refusal(object::extend($i.backfill, { to: time::now() + 1d })) = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_view($s.id).recent_runs = [];
};

-- test: chevauchement, création d'exécution d'une planification, doublon ignoré, libération
{
    LET $s = (SELECT * FROM ONLY (SELECT VALUE schedule FROM ONLY passe:i));
    LET $task = (SELECT * FROM ONLY $s.task);
    LET $first_state = fn::scheduler_overlap_apply($s.id, "buffer_all");
    LET $t1 = time::now() - 2m;
    LET $a = fn::scheduler_run_spawn($s, $task, type::record("scheduler_run", [$s.id, $t1]), $t1, $t1 + 1s, "schedule", "buffer_all");
    LET $dup = fn::scheduler_run_spawn($s, $task, type::record("scheduler_run", [$s.id, $t1]), $t1, $t1, "schedule", "buffer_all");
    LET $b = fn::scheduler_run_spawn($s, $task, NONE, time::now(), time::now(), "trigger", "buffer_all");
    LET $busy = fn::scheduler_run_release($s.id);
    UPDATE passe:i SET run_a = $a.id, run_b = $b.id;
    RETURN $first_state = "queued" AND $a.state = "queued" AND $a.available_at = $t1 + 1s AND $a.scheduled_for = $t1 AND $dup IS NONE AND $b.state = "waiting" AND $b.origin = "trigger"
        AND $busy IS NONE AND fn::scheduler_run_release(NONE) IS NONE
        AND fn::scheduler_overlap_apply($s.id, "skip") = "skipped" AND fn::scheduler_overlap_apply($s.id, "buffer_one") = "skipped"
        AND fn::scheduler_overlap_apply($s.id, "allow_all") = "queued"
        AND fn::scheduler_pending_full(auth_organization:alpha) IS NONE;
};

-- test: gardes d'exécution appelées directement
{
    LET $a = (SELECT * FROM ONLY (SELECT VALUE run_a FROM ONLY passe:i));
    RETURN fn::scheduler_run_create_refusal($a) IS NONE
        AND fn::scheduler_run_create_refusal(object::extend($a, { state: "running" })) = "SCHEDULER_RUN_STATE_INVALID"
        AND fn::scheduler_run_update_refusal($a, object::extend($a, { state: "cancelled", finished_at: time::now() })) IS NONE
        AND fn::scheduler_run_update_refusal($a, object::extend($a, { state: "completed", finished_at: time::now() })) = "SCHEDULER_RUN_STATE_INVALID"
        AND fn::scheduler_run_delete_refusal($a) = "SCHEDULER_RUN_STATE_INVALID"
        AND fn::scheduler_run_delete_refusal(object::extend($a, { state: "completed" })) IS NONE;
};

-- test: réservation d'une candidate, bail, issue d'échec, fin sous bail, libération de l'exécution en attente
{
    LET $a = (SELECT * FROM ONLY (SELECT VALUE run_a FROM ONLY passe:i));
    LET $claimed = fn::scheduler_run_claim_one($a, "n1", time::now());
    LET $leased = fn::scheduler_run_leased($a.id, $claimed.run.lease);
    LET $wrong = fn::scheduler_run_leased($a.id, "autre");
    LET $outcome = fn::scheduler_failure_outcome($leased.run, { code: "X", retryable: false });
    LET $end = fn::scheduler_run_end($leased.run, $claimed.run.lease, { state: "completed", result: { ok: true } });
    LET $again = fn::scheduler_run_end($leased.run, $claimed.run.lease, { state: "completed" });
    LET $b = (SELECT VALUE state FROM ONLY (SELECT VALUE run_b FROM ONLY passe:i));
    RETURN !$claimed.full AND $claimed.run.attempt = 1 AND $leased.code IS NONE AND $wrong.code = "SCHEDULER_LEASE_LOST"
        AND fn::scheduler_run_leased(scheduler_run:inconnue, "x").code = "SCHEDULER_RUN_NOT_FOUND"
        AND $outcome = { state: "dead", error: { code: "X", retryable: false } }
        AND fn::scheduler_failure_outcome(object::extend($leased.run, { cancel_requested: true }), { code: "X", retryable: true }).state = "cancelled"
        AND fn::scheduler_failure_outcome($leased.run, { code: "X", retryable: true }).state = "retrying"
        AND $end.state = "completed" AND $again IS NONE AND $b = "queued";
};

-- test: journal et bus écrits directement par la session système ; charges sans arguments
{
    LET $s = (SELECT * FROM ONLY (SELECT VALUE schedule FROM ONLY passe:i));
    LET $run = (SELECT * FROM ONLY (SELECT VALUE run_a FROM ONLY passe:i));
    LET $entry = fn::scheduler_audit_write({ tenant: auth_organization:alpha, action: "test.write", details: { a: 1 } });
    LET $published = fn::scheduler_publish("scheduler.test.done", $s.id, fn::scheduler_schedule_payload($s, { x: 1 }));
    LET $p = fn::scheduler_run_payload($run);
    RETURN $entry.action = "test.write" AND $entry.session_kind = "system" AND $entry.actor IS NONE AND $published
        AND count(SELECT * FROM event_outbox WHERE event_type = "scheduler.test.done") = 1
        AND fn::scheduler_schedule_payload($s, {}).task = "essai.rapport" AND !object::keys(fn::scheduler_schedule_payload($s, {})).any(|$k| $k = "args")
        AND $p.task = "essai.rapport" AND $p.attempt = 1 AND $p.error_code IS NONE AND !object::keys($p).any(|$k| $k IN ["args", "result"]);
};

-- lyxal-test: assertions
-- Échéances (moteur, dates fournies à la place du calcul Rust) : liste des planifications dues,
-- une même date ne crée qu'une exécution, rattrapage last, all et none dans et hors de la
-- fenêtre, exécutions restantes, fin de planification, prochaine échéance, planification en
-- pause ou tâche désactivée, rejeu de période, droits du moteur.
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

-- préparation: planifications d'essai (chevauchement allow_all pour isoler le rattrapage)
{
    FOR $c IN ["last", "all", "none"] {
        fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "rattrapage-" + $c, task: "essai.rapport", args: { format: "pdf" }, spec: { every: [10m] }, catchup: $c, overlap: "allow_all" });
    };
    fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "trois-fois", task: "essai.rapport", args: { format: "pdf" }, spec: { every: [1m] }, remaining: 3, overlap: "allow_all", catchup: "all" });
    fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "en-pause", task: "essai.rapport", args: { format: "pdf" }, spec: { every: [1m] }, paused: true, paused_reason: "Essai" });
};

-- test: planifications dues : à calculer ou échues, hors pause ; fenêtre de rattrapage effective jointe
-- en tant que: worker
{
    LET $d = fn::scheduler_due_list({});
    RETURN $d.ok AND array::len($d.data.schedules) = 4
        AND $d.data.schedules.all(|$s| $s.catchup_window = 1h AND $s.calendars = [])
        AND $d.data.backfills = [];
};

-- test: une même date ne crée qu'une exécution (deux appels de fire)
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-all" LIMIT 1);
    LET $t = time::now() - 5m;
    LET $a = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [$t], next_fire_at: time::now() + 5m });
    LET $b = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [$t, $t], next_fire_at: time::now() + 5m });
    RETURN array::len($a.data.runs) = 1 AND $a.data.runs[0].id = type::record("scheduler_run", [$s, $t])
        AND array::len($b.data.runs) = 0 AND $b.data.ignored = 2
        AND count(SELECT * FROM scheduler_run WHERE schedule = $s) = 1
        AND $b.data.schedule.last_fire_at = $t AND $b.data.schedule.next_fire_at > time::now();
};

-- test: création directe d'une échéance en double refusée par la base
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
{
    LET $r = (SELECT * FROM ONLY scheduler_run LIMIT 1);
    CREATE scheduler_run CONTENT { tenant: $r.tenant, schedule: $r.schedule, task: $r.task, args: $r.args, queue: $r.queue, priority: 5, origin: "schedule", scheduled_for: $r.scheduled_for, available_at: $r.scheduled_for, state: "queued", max_attempts: 3 };
};

-- test: rattrapage all : toutes les échéances de la fenêtre, pas celles d'avant
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-all" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3h, time::now() - 2h, time::now() - 50m, time::now() - 20m, time::now() - 2m], next_fire_at: time::now() + 8m });
    RETURN array::len($f.data.runs) = 3 AND $f.data.ignored = 2 AND $f.data.runs.all(|$r| $r.state = "queued");
};

-- test: rattrapage last : la plus récente de la fenêtre seulement
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-last" LIMIT 1);
    LET $t = time::now() - 20m;
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3h, time::now() - 50m, $t], next_fire_at: time::now() + 1h });
    LET $g = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3h, time::now() - 2h], next_fire_at: time::now() + 1h });
    RETURN array::len($f.data.runs) = 1 AND $f.data.runs[0].scheduled_for = $t AND array::len($g.data.runs) = 0 AND $g.data.ignored = 2;
};

-- test: rattrapage none : seulement l'échéance courante (moins d'une minute de retard)
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-none" LIMIT 1);
    LET $late = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 30m, time::now() - 10m], next_fire_at: time::now() + 1h });
    LET $now = time::now() - 5s;
    LET $on_time = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 20m, $now], next_fire_at: time::now() + 1h });
    RETURN array::len($late.data.runs) = 0 AND array::len($on_time.data.runs) = 1 AND $on_time.data.runs[0].scheduled_for = $now;
};

-- test: fenêtre de rattrapage propre à la planification
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-all" LIMIT 1);
    fn::scheduler_schedule_update({ schedule: $s, catchup_window: 4h });
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3h], next_fire_at: time::now() + 1h });
    RETURN array::len($f.data.runs) = 1;
};

-- test: exécutions restantes : au plus autant de créations, puis planification terminée
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "trois-fois" LIMIT 1);
    LET $a = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 4m, time::now() - 3m], next_fire_at: time::now() + 1m });
    LET $mid = $a.data.schedule;
    UPDATE passe:t SET id_schedule = $s;
    LET $b = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 2m, time::now() - 1m], next_fire_at: time::now() + 1m });
    RETURN array::len($a.data.runs) = 2 AND $mid.remaining = 1 AND $mid.state = "active"
        AND array::len($b.data.runs) = 1 AND $b.data.schedule.remaining = 0 AND $b.data.schedule.state = "completed" AND $b.data.schedule.next_fire_at IS NONE
        AND fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now()], next_fire_at: time::now() + 1m }).error.code = "SCHEDULER_SCHEDULE_STATE_INVALID";
};

-- test: planification terminée : plus de modification ni de pause
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "trois-fois" LIMIT 1);
    RETURN fn::scheduler_schedule_update({ schedule: $s, remaining: 5 }).error.code = "SCHEDULER_SCHEDULE_STATE_INVALID"
        AND fn::scheduler_schedule_pause({ schedule: $s }).error.code = "SCHEDULER_SCHEDULE_STATE_INVALID"
        AND fn::scheduler_schedule_trigger({ schedule: $s }).error.code = "SCHEDULER_SCHEDULE_STATE_INVALID";
};

-- test: sans prochaine échéance, la planification se termine
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-none" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [] });
    RETURN $f.data.schedule.state = "completed" AND $f.data.runs = []
        AND fn::scheduler_schedule_next_set({ schedule: $s, next_fire_at: time::now() + 1h }).error.code = "SCHEDULER_SCHEDULE_STATE_INVALID";
};

-- test: planification en pause et tâche désactivée : pas d'échéance ; absentes de la liste
{
    LET $p = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "en-pause" LIMIT 1);
    LET $l = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-last" LIMIT 1);
    LET $paused = fn::scheduler_schedule_fire({ schedule: $p, fire_times: [time::now()], next_fire_at: time::now() + 1m });
    UPDATE $l SET next_fire_at = NONE, spec.every = [11m];
    fn::scheduler_task_set_state({ task: "essai.rapport", state: "disabled" });
    LET $disabled = fn::scheduler_schedule_fire({ schedule: $l, fire_times: [time::now()], next_fire_at: time::now() + 1m });
    LET $due = fn::scheduler_due_list({ limit: 50 }).data.schedules;
    fn::scheduler_task_set_state({ task: "essai.rapport", state: "active" });
    LET $due_after = fn::scheduler_due_list({ limit: 50 }).data.schedules.id;
    RETURN $paused.error.code = "SCHEDULER_SCHEDULE_STATE_INVALID" AND $disabled.error.code = "SCHEDULER_TASK_DISABLED"
        AND array::len($due) = 0 AND $l IN $due_after AND $p NOTINSIDE $due_after;
};

-- test: dates futures et paramètres faux refusés
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-last" LIMIT 1);
    RETURN fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() + 1h], next_fire_at: time::now() + 2h }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_fire({ schedule: $s }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_fire({ schedule: "scheduler_schedule:inconnue", fire_times: [] }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND"
        AND fn::scheduler_due_list({ limit: 0 }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: seul le moteur traite les échéances
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-last" LIMIT 1);
    RETURN [
        fn::scheduler_due_list({}),
        fn::scheduler_schedule_fire({ schedule: $s, fire_times: [], next_fire_at: time::now() + 1h }),
        fn::scheduler_schedule_next_set({ schedule: $s, next_fire_at: time::now() + 1h }),
        fn::scheduler_backfill_fire({ backfill: "scheduler_backfill:x", fire_times: [] })
    ].all(|$r| $r.error.code = "SCHEDULER_PERMISSION_DENIED");
};

-- test: une personne ne crée pas d'échéance directement
-- en tant que: admin
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
{
    LET $s = (SELECT * FROM ONLY scheduler_schedule WHERE name = "rattrapage-last" LIMIT 1);
    LET $t = time::now() - 1m;
    CREATE type::record("scheduler_run", [$s.id, $t]) CONTENT { tenant: $s.tenant, schedule: $s.id, task: $s.task, args: $s.args, queue: scheduler_queue:default, priority: 5, origin: "schedule", scheduled_for: $t, available_at: $t, state: "queued", max_attempts: 3 };
};

-- préparation: demande de rejeu sur la planification rattrapage-last
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-last" LIMIT 1);
    LET $b = fn::scheduler_schedule_backfill({ schedule: $s, from: time::now() - 1d, to: time::now() - 1h, overlap: "allow_all" });
    UPSERT passe:b SET id_backfill = $b.data.id, from = $b.data.from;
};

-- test: rejeu de période : exécutions créées, doublon ignoré, bornes, fin
-- en tant que: worker
{
    LET $b = (SELECT VALUE id_backfill FROM ONLY passe:b);
    LET $from = (SELECT VALUE from FROM ONLY passe:b);
    LET $listed = fn::scheduler_due_list({}).data.backfills;
    LET $one = fn::scheduler_backfill_fire({ backfill: $b, fire_times: [$from + 1h, $from + 2h] });
    LET $two = fn::scheduler_backfill_fire({ backfill: $b, fire_times: [$from + 2h, $from + 3h], done: true });
    RETURN $listed[0].id = $b AND $listed[0].spec.every = [11m]
        AND array::len($one.data.runs) = 2 AND $one.data.backfill.state = "running" AND $one.data.runs.all(|$r| string::starts_with(<string> $r.id, "scheduler_run:["))
        AND array::len($two.data.runs) = 1 AND $two.data.backfill.state = "done" AND $two.data.backfill.runs_created = 3
        AND count(SELECT * FROM scheduler_run WHERE origin = "backfill") = 3
        AND fn::scheduler_backfill_fire({ backfill: $b, fire_times: [] }).error.code = "SCHEDULER_SCHEDULE_STATE_INVALID";
};

-- test: dates hors de la période refusées
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "rattrapage-all" LIMIT 1);
    LET $b = fn::scheduler_schedule_backfill({ schedule: $s, from: time::now() - 2d, to: time::now() - 1d }).data.id;
    RETURN fn::scheduler_backfill_fire({ backfill: $b, fire_times: [time::now() - 3d] }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_backfill_fire({ backfill: $b, fire_times: [time::now() - 1h] }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

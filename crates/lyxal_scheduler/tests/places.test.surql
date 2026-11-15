-- lyxal-test: assertions
-- Places et élagage (moteur) : une organisation pleine dont les exécutions sont en tête de file
-- ne bloque jamais les autres ; places rendues après la suppression d'une organisation qui avait
-- des exécutions en cours ; un lot d'exécutions gardées ne bloque jamais l'élagage des suivantes.
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

-- préparation: alpha limitée à une place ; 12 exécutions d'alpha en tête de file, puis une de beta
{
    fn::scheduler_settings_set({ tenant: auth_organization:alpha, tenant_concurrency: 1 });
    UPDATE scheduler_queue:default SET concurrency = 5;
    FOR $i IN <array> (1..13) {
        fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.rapport", args: { format: "pdf" } });
    };
    fn::scheduler_run_enqueue({ tenant: auth_organization:beta, task: "essai.rapport", args: { format: "csv" }, delay: 1s });
};

-- test: alpha réserve sa seule place
-- en tant que: worker
{
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", limit: 1 }).data.items;
    RETURN array::len($c) = 1 AND $c[0].tenant = auth_organization:alpha;
};

-- test: alpha pleine, ses exécutions en tête de file ne masquent pas celle de beta
-- en tant que: worker
{
    sleep(1100ms);
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", limit: 1 }).data.items;
    LET $q = (SELECT VALUE running FROM ONLY scheduler_queue:default);
    RETURN array::len($c) = 1 AND $c[0].tenant = auth_organization:beta AND $q = 2;
};

-- préparation: suppression de l'organisation alpha, qui avait une exécution en cours
DELETE auth_organization:alpha;

-- test: la reprise recale les places de la file sur les exécutions réellement en cours
-- en tant que: worker
{
    LET $before = (SELECT VALUE running FROM ONLY scheduler_queue:default);
    LET $r = fn::scheduler_run_rescue({});
    LET $after = (SELECT VALUE running FROM ONLY scheduler_queue:default);
    RETURN $before = 2 AND $r.data.reconciled >= 1 AND $after = 1 AND fn::scheduler_run_rescue({}).data.reconciled = 0;
};

-- préparation: beta garde 3 exécutions par planification ; « ancienne » : 3 exécutions il y a 60 jours (gardées) ; « recente » : 5 il y a 40 jours (2 à élaguer)
{
    fn::scheduler_settings_set({ tenant: auth_organization:beta, keep_last_runs: 3 });
    LET $a = fn::scheduler_schedule_create({ tenant: auth_organization:beta, name: "ancienne", task: "essai.purge", spec: { every: [1h] } }).data;
    LET $b = fn::scheduler_schedule_create({ tenant: auth_organization:beta, name: "recente", task: "essai.purge", spec: { every: [1h] } }).data;
    FOR $item IN [{ s: $a, days: 60d, n: 3 }, { s: $b, days: 40d, n: 5 }] {
        FOR $i IN <array> (1..($item.n + 1)) {
            LET $t = time::now() - $item.days - duration::from_hours($i);
            CREATE type::record("scheduler_run", [$item.s.id, $t]) CONTENT { tenant: $item.s.tenant, schedule: $item.s.id, task: $item.s.task, args: {}, queue: scheduler_queue:maintenance, priority: 7, origin: "schedule", scheduled_for: $t, available_at: $t, state: "skipped", finished_at: $t, max_attempts: 2 };
        };
    };
    UPSERT passe:e SET ancienne = $a.id, recente = $b.id;
};

-- test: les plus anciennes, gardées, ne bloquent pas l'élagage des suivantes
-- en tant que: worker
{
    LET $e = (SELECT * FROM ONLY passe:e);
    LET $oldest = (SELECT id, tenant, schedule, scheduled_for, finished_at FROM scheduler_run WHERE schedule = $e.ancienne ORDER BY scheduled_for ASC LIMIT 1)[0];
    LET $kept = fn::scheduler_run_prunable($oldest.id, $oldest.tenant, $oldest.schedule, $oldest.scheduled_for, $oldest.finished_at, time::now());
    LET $p = fn::scheduler_run_prune({ limit: 3 });
    RETURN !$kept AND $p.data.deleted = 2
        AND count(SELECT * FROM scheduler_run WHERE schedule = $e.ancienne) = 3
        AND count(SELECT * FROM scheduler_run WHERE schedule = $e.recente) = 3;
};

-- test: recalage des compteurs déjà justes : aucun changement
-- en tant que: worker
RETURN fn::scheduler_counters_reconcile() = 0;

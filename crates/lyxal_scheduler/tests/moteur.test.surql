-- lyxal-test: assertions
-- Moteur (lot 3) : échéances avec date de disponibilité décalée (décalage aléatoire, U5) et
-- refus d'une disponibilité avant la date prévue, réservation limitée aux handlers du nœud et
-- exécuteur et cible rendus, handler absent réservé après son délai maximal, publication
-- différée et fin dans la même transaction (succès, jeton périmé, tâche qui n'est pas event,
-- publication refusée qui annule la fin), sonde de santé, droits du moteur.
--
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
    -- Fondation de l'hôte : module fictif lyxal_essai installé (release du runtime), bail du planificateur tenu par le nœud n1
    fn::runtime_module_upsert({ module_id: "lyxal_essai", name: "Essai" });
    fn::runtime_release_register({ module_id: "lyxal_essai", version: "0.1.0", manifest_version: 1, status: "Installed" });
    fn::runtime_lease_acquire({ kind: "leader", key: "scheduler", node_id: "n1", ttl_seconds: 86400 });
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
        module: "lyxal_essai", executor: "event", target: "essai.rappel.envoi", scope: "installation",
        retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
    };
    -- Table de passage d'identifiants entre identités (lisible par tous)
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};


-- préparation: planification d'alpha (chevauchement allow_all) et tâche handler sans code sur le nœud
{
    LET $s = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "decale", task: "essai.rapport", args: { format: "csv" }, spec: { every: [10m] }, overlap: "allow_all", catchup: "all" }).data.id;
    UPSERT passe:m SET schedule = $s;
};

-- test: échéances avec disponibilité décalée : identité [planification, date prévue], réservation à la date de disponibilité
{
    LET $s = (SELECT VALUE schedule FROM ONLY passe:m);
    LET $t = time::now() - 1m;
    LET $f = fn::scheduler_schedule_fire({ node: "n1", generation: 1, schedule: $s, fire_times: [{ at: $t, available_at: $t + 10m }], next_fire_at: time::now() + 9m });
    LET $run = (SELECT * FROM ONLY $f.data.runs[0].id);
    RETURN $f.ok AND $f.data.runs[0].id = type::record("scheduler_run", [$s, $t]) AND $run.scheduled_for = $t AND $run.available_at = $t + 10m
        AND fn::scheduler_run_claim({ queue: "default", node: "n1", limit: 10 }).data.items = [];
};

-- test: disponibilité avant la date prévue refusée (échéance et rejeu)
{
    LET $s = (SELECT VALUE schedule FROM ONLY passe:m);
    LET $t = time::now() - 2m;
    RETURN fn::scheduler_schedule_fire({ node: "n1", generation: 1, schedule: $s, fire_times: [{ at: $t, available_at: $t - 1s }], next_fire_at: time::now() + 9m }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_fire({ node: "n1", generation: 1, schedule: $s, fire_times: [{ at: $t }], next_fire_at: time::now() + 9m }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_backfill_fire({ node: "n1", generation: 1, backfill: "scheduler_backfill:x", fire_times: [{ at: $t, available_at: $t - 1s }] }).error.details.fields.fire_times[0].code = "CORE_VALIDATION_RANGE_ORDER"
        AND fn::scheduler_due_list({}).data.schedules.all(|$d| $d.created_at IS NOT NONE);
};

-- préparation: tâche de publication différée avec arguments ; deux exécutions immédiates : handler d'alpha, publication différée de l'installation
{
    CREATE scheduler_task:⟨essai.rappel⟩ CONTENT {
        module: "lyxal_essai", executor: "event", target: "essai.rappel.envoi", scope: "installation",
        args_schema: { fields: { lot: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true } }, unknown_keys: "reject" },
        retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
    };
    LET $h = fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.rapport", args: { format: "pdf", note: "h" } }).data.id;
    LET $e = fn::scheduler_run_enqueue({ task: "essai.rappel", args: { lot: 7 } }).data.id;
    UPSERT passe:m MERGE { handler_run: $h, event_run: $e };
};

-- test: un nœud sans le code d'une tâche handler ne la réserve pas ; exécuteur et cible rendus
-- en tant que: worker
{
    LET $h = (SELECT VALUE handler_run FROM ONLY passe:m);
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", limit: 10, handlers: [] });
    LET $e = $c.data.items[0];
    UPSERT passe:m MERGE { event_claim: $e };
    RETURN array::len($c.data.items) = 1 AND $e.executor = "event" AND $e.target = "essai.rappel.envoi" AND !$e.cancel_requested
        AND (SELECT VALUE state FROM ONLY $h) = "queued"
        AND fn::scheduler_run_claim({ queue: "default", node: "n1", handlers: ["Pas Un Nom"] }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- préparation: tâche handler de délai maximal court (1 s), sans code sur le nœud ; une exécution immédiate
{
    CREATE scheduler_task:⟨essai.court⟩ CONTENT {
        module: "lyxal_essai", executor: "handler", target: "essai.court", timeout: 1s, scope: "installation",
        retry: { max_attempts: 2, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
    };
    LET $c = fn::scheduler_run_enqueue({ task: "essai.court" }).data.id;
    UPSERT passe:m MERGE { court_run: $c };
};

-- test: handler absent réservé après son délai maximal, puis terminé en échec SCHEDULER_HANDLER_NOT_FOUND
{
    LET $c = (SELECT VALUE court_run FROM ONLY passe:m);
    SLEEP 1100ms;
    LET $found = fn::scheduler_run_claim({ queue: "default", node: "n1", handlers: [] }).data.items;
    LET $f = fn::scheduler_run_fail({ run: $found[0].id, lease: $found[0].lease, error: { code: "SCHEDULER_HANDLER_NOT_FOUND" } });
    RETURN array::len($found) = 1 AND $found[0].id = $c AND $found[0].executor = "handler" AND $found[0].target = "essai.court"
        AND $f.data.state = "retrying" AND $f.data.error.code = "SCHEDULER_HANDLER_NOT_FOUND";
};

-- test: publication différée refusée hors session système : la fin de l'exécution est annulée
-- en tant que: worker
-- attendu-erreur: EVENT_WRITE_FORBIDDEN
{
    LET $e = (SELECT VALUE event_claim FROM ONLY passe:m);
    RETURN fn::scheduler_run_publish({ run: $e.id, lease: $e.lease });
};

-- test: l'exécution est toujours en cours après la publication refusée, et rien n'est publié
{
    LET $e = (SELECT VALUE event_claim FROM ONLY passe:m);
    RETURN (SELECT VALUE state FROM ONLY $e.id) = "running" AND count(SELECT * FROM event_outbox WHERE event_type = "essai.rappel.envoi") = 0;
};

-- test: publication différée et fin dans la même transaction : charge = arguments, source = exécution, métadonnées
{
    LET $e = (SELECT VALUE event_claim FROM ONLY passe:m);
    LET $p = fn::scheduler_run_publish({ run: $e.id, lease: $e.lease });
    LET $out = (SELECT * FROM event_outbox WHERE event_type = "essai.rappel.envoi");
    RETURN $p.ok AND $p.data.state = "completed" AND $p.data.result.event_type = "essai.rappel.envoi"
        AND array::len($out) = 1 AND $out[0].event_id = $p.data.result.event_id AND $out[0].producer = "lyxal_essai"
        AND $out[0].source = $e.id AND $out[0].payload = { lot: 7 }
        AND $out[0].metadata.attempt = 1 AND $out[0].metadata.scheduled_for = <string> $e.scheduled_for AND $out[0].metadata.tenant IS NONE;
};

-- test: publication avec un jeton périmé : rien n'est publié
{
    LET $e = (SELECT VALUE event_claim FROM ONLY passe:m);
    RETURN fn::scheduler_run_publish({ run: $e.id, lease: $e.lease }).error.code = "SCHEDULER_LEASE_LOST"
        AND count(SELECT * FROM event_outbox WHERE event_type = "essai.rappel.envoi") = 1;
};

-- test: publication d'une tâche qui n'est pas event refusée
{
    LET $h = (SELECT VALUE handler_run FROM ONLY passe:m);
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", handlers: ["essai.rapport"] }).data.items.filter(|$r| $r.id = $h)[0];
    LET $p = fn::scheduler_run_publish({ run: $c.id, lease: $c.lease });
    fn::scheduler_run_complete({ run: $c.id, lease: $c.lease });
    RETURN $p.error.code = "SCHEDULER_INVALID_PARAMETERS" AND $p.error.details.fields.run[0].details.executor = "handler"
        AND fn::scheduler_run_publish({ run: $c.id }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- préparation: une exécution immédiate qui ne sera pas réservée
{
    fn::scheduler_run_enqueue({ task: "essai.rappel", args: { lot: 8 } });
};

-- test: sonde de santé : files, exécutions en retard, tâches handler actives ; aucune donnée d'organisation
{
    SLEEP 1100ms;
    LET $h = fn::scheduler_health({});
    LET $late = fn::scheduler_health({ late_after: 1s });
    RETURN $h.ok AND $h.data.queues.name = ["default", "maintenance"] AND $h.data.queues.all(|$q| !$q.paused)
        AND $h.data.handler_tasks = ["essai.court", "essai.rapport"] AND $h.data.late = 0
        AND $late.data.late >= 1 AND !string::contains(<string> $h.data, "alpha")
        AND fn::scheduler_health({ late_after: 0s }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: la sonde est lisible par le compte de service du moteur
-- en tant que: worker
RETURN fn::scheduler_health({}).ok;

-- test: seul le moteur publie une exécution et lit la santé
-- en tant que: admin
{
    LET $e = (SELECT VALUE event_claim FROM ONLY passe:m);
    RETURN [
        fn::scheduler_run_publish({ run: <string> $e.id, lease: "00000000-0000-7000-8000-000000000000" }),
        fn::scheduler_health({})
    ].all(|$r| $r.error.code = "SCHEDULER_PERMISSION_DENIED");
};

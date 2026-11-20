-- lyxal-test: assertions
-- Réservation et fin (moteur) : priorité puis date, file en pause, places de la file et de
-- l'organisation jamais dépassées, une organisation pleine n'en bloque pas une autre, bail
-- (jeton, battement, jeton périmé refusé), succès, nouvelle tentative avec délai croissant et
-- plafonné, dead, pause sur échec, annulation demandée pendant l'exécution, reprise d'un bail
-- expiré, élagage qui garde les N dernières, droits du moteur.
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
        module: "lyxal_essai", executor: "event", target: "essai.global.tick", scope: "installation",
        retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
    };
    -- Table de passage d'identifiants entre identités (lisible par tous)
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: trois exécutions immédiates d'alpha, de priorités 5, 1 et 5
{
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.rapport", args: { format: "pdf", note: "a" } });
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.rapport", args: { format: "pdf", note: "b" }, priority: 1 });
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.rapport", args: { format: "pdf", note: "c" } });
    UPDATE scheduler_queue:default SET concurrency = 2;
};

-- test: file en pause : rien n'est réservé
-- en tant que: worker
{
    LET $paused = (SELECT VALUE paused FROM ONLY scheduler_queue:default);
    RETURN !$paused;
};

-- test: pause de la file par la plateforme
-- en tant que: plateforme
RETURN fn::scheduler_queue_pause({ queue: "default", reason: "Maintenance" }).ok;

-- test: le moteur ne réserve rien dans une file en pause ; file inconnue
-- en tant que: worker
RETURN fn::scheduler_run_claim({ queue: "default", node: "n1", host: "hote_essai", handlers: ["essai.rapport"] }).data == { items: [], paused: true }
    AND fn::scheduler_run_claim({ queue: "inconnue", node: "n1", host: "hote_essai", handlers: ["essai.rapport"] }).error.code = "SCHEDULER_QUEUE_NOT_FOUND"
    AND fn::scheduler_run_claim({ queue: "default", node: "", host: "hote_essai", handlers: ["essai.rapport"] }).error.code = "SCHEDULER_INVALID_PARAMETERS";

-- test: reprise de la file
-- en tant que: plateforme
RETURN fn::scheduler_queue_resume({ queue: "default" }).ok;

-- test: réservation par priorité puis date, dans les places de la file ; bail rendu au moteur
-- en tant que: worker
{
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", host: "hote_essai", handlers: ["essai.rapport"], limit: 5 });
    UPSERT passe:r SET a = $c.data.items[0], b = $c.data.items[1];
    RETURN array::len($c.data.items) = 2 AND $c.data.items.args.note = ["b", "a"] AND $c.data.items.all(|$r| $r.attempt = 1 AND string::len($r.lease) = 36 AND $r.lease_node = "n1" AND $r.timeout = 1m)
        AND $c.data.items[0].locked_until > time::now() + 1m AND $c.data.items[0].locked_until <= time::now() + 2m
        AND (SELECT VALUE running FROM ONLY scheduler_queue:default) = 2
        AND (SELECT VALUE running FROM ONLY scheduler_slot:["default", "alpha"]) = 2;
};

-- test: file pleine : plus rien n'est réservé
-- en tant que: worker
RETURN fn::scheduler_run_claim({ queue: "default", node: "n2", host: "hote_essai", handlers: ["essai.rapport"] }).data.items = [];

-- test: places visibles dans la liste des files
-- en tant que: lecteur
RETURN fn::scheduler_queue_list({}).data[0].slots == [{ scope_key: "alpha", running: 2 }];

-- test: jeton de bail lisible par le moteur seulement
-- en tant que: lecteur
RETURN (SELECT VALUE lease FROM ONLY (SELECT VALUE a.id FROM ONLY passe:r)) IS NONE;

-- test: battement : bail prolongé ; jeton périmé refusé
-- en tant que: worker
{
    LET $a = (SELECT VALUE a FROM ONLY passe:r);
    LET $h = fn::scheduler_run_heartbeat({ run: $a.id, lease: $a.lease });
    LET $bad = fn::scheduler_run_heartbeat({ run: $a.id, lease: "00000000-0000-7000-8000-000000000000" });
    RETURN $h.ok AND !$h.data.cancel_requested AND $h.data.locked_until >= $a.locked_until AND $bad.error.code = "SCHEDULER_LEASE_LOST"
        AND fn::scheduler_run_heartbeat({ run: "scheduler_run:inconnue", lease: $a.lease }).error.code = "SCHEDULER_RUN_NOT_FOUND";
};

-- test: fin avec un jeton périmé refusée (garde de génération)
-- en tant que: worker
{
    LET $a = (SELECT VALUE a FROM ONLY passe:r);
    RETURN fn::scheduler_run_complete({ run: $a.id, lease: "00000000-0000-7000-8000-000000000000" }).error.code = "SCHEDULER_LEASE_LOST"
        AND fn::scheduler_run_fail({ run: $a.id, lease: "00000000-0000-7000-8000-000000000000", error: { code: "X" } }).error.code = "SCHEDULER_LEASE_LOST";
};

-- test: annulation demandée pendant l'exécution, vue au battement
-- en tant que: operateur
{
    LET $b = (SELECT VALUE b FROM ONLY passe:r);
    LET $c = fn::scheduler_run_cancel({ run: $b.id, reason: "Trop long" });
    RETURN $c.data.state = "running" AND $c.data.cancel_requested AND fn::scheduler_run_cancel({ run: $b.id }).error.code = "SCHEDULER_RUN_STATE_INVALID";
};

-- test: la demande d'annulation ne se retire pas
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE b.id FROM ONLY passe:r) SET cancel_requested = false;

-- test: succès : résultat court, places rendues ; la troisième prend la place
-- en tant que: worker
{
    LET $b = (SELECT VALUE b FROM ONLY passe:r);
    LET $h = fn::scheduler_run_heartbeat({ run: $b.id, lease: $b.lease });
    LET $done = fn::scheduler_run_complete({ run: $b.id, lease: $b.lease, result: { pages: 12 } });
    LET $running_after = (SELECT VALUE running FROM ONLY scheduler_queue:default);
    LET $next = fn::scheduler_run_claim({ queue: "default", node: "n2", host: "hote_essai", handlers: ["essai.rapport"] });
    UPDATE passe:r SET c = $next.data.items[0];
    RETURN $h.data.cancel_requested AND $done.data.state = "completed" AND $done.data.result = { pages: 12 } AND $done.data.lease IS NONE
        AND $done.data.finished_at IS NOT NONE AND $done.data.duration_ms >= 0 AND $running_after = 1
        AND $next.data.items.args.note = ["c"]
        AND fn::scheduler_run_complete({ run: $b.id, lease: $b.lease }).error.code = "SCHEDULER_LEASE_LOST";
};

-- test: résultat trop long refusé
-- en tant que: worker
{
    LET $c = (SELECT VALUE c FROM ONLY passe:r);
    RETURN fn::scheduler_run_complete({ run: $c.id, lease: $c.lease, result: { texte: string::repeat("x", 5000) } }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: échec retentable : nouvelle tentative après le délai de la stratégie (gigue comprise), places rendues
-- en tant que: worker
{
    LET $a = (SELECT VALUE a FROM ONLY passe:r);
    LET $f = fn::scheduler_run_fail({ run: $a.id, lease: $a.lease, error: { code: "SMTP_DOWN", message: string::repeat("m", 1500) } });
    RETURN $f.data.state = "retrying" AND $f.data.attempt = 1 AND $f.data.error.code = "SMTP_DOWN" AND string::len($f.data.error.message) = 1000
        AND $f.data.error.retryable AND $f.data.available_at <= time::now() + 10s AND $f.data.finished_at IS NONE AND $f.data.lease IS NONE
        AND (SELECT VALUE running FROM ONLY scheduler_slot:["default", "alpha"]) = 1;
};

-- test: délai croissant et plafonné (gigue 1) : exponentiel, linéaire, fixe
RETURN [1, 2, 3, 4].map(|$n| fn::scheduler_retry_delay({ strategy: "exponential", initial_delay: 10s, max_delay: 30s }, $n, 1f)) == [10s, 20s, 30s, 30s]
    AND [1, 2, 3].map(|$n| fn::scheduler_retry_delay({ strategy: "linear", initial_delay: 10s, max_delay: 25s }, $n, 1f)) == [10s, 20s, 25s]
    AND [1, 5].map(|$n| fn::scheduler_retry_delay({ strategy: "fixed", initial_delay: 5s, max_delay: 5s }, $n, 1f)) == [5s, 5s]
    AND fn::scheduler_retry_delay({ strategy: "exponential", initial_delay: 10s, max_delay: 30s }, 2, 0.5f) == 10s
    AND fn::scheduler_retry_delay({ strategy: "exponential", initial_delay: 10s, max_delay: 30s }, 2, 0f) == 0s;

-- test: une exécution en attente de nouvelle tentative n'est pas réservée avant son délai
-- en tant que: worker
{
    LET $a = (SELECT VALUE a FROM ONLY passe:r);
    LET $avail = (SELECT VALUE available_at FROM ONLY $a.id);
    -- Délai tiré au hasard (gigue) : l'heure est lue avant et après la réservation ; un délai
    -- échu entre les deux lectures admet les deux issues
    LET $start = time::now();
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n3", host: "hote_essai", handlers: ["essai.rapport"] });
    LET $end = time::now();
    RETURN IF $avail > $end { $c.data.items = [] }
        ELSE IF $avail <= $start { $c.data.items[0].attempt = 2 }
        ELSE { $c.data.items = [] OR $c.data.items[0].attempt = 2 };
};

-- test: échec non retentable : dead tout de suite
-- en tant que: worker
{
    LET $c = (SELECT VALUE c FROM ONLY passe:r);
    LET $f = fn::scheduler_run_fail({ run: $c.id, lease: $c.lease, error: { code: "BAD_INPUT" }, retryable: false });
    RETURN $f.data.state = "dead" AND $f.data.finished_at IS NOT NONE AND !$f.data.error.retryable
        AND fn::scheduler_run_fail({ run: $c.id, lease: $c.lease, error: {} }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- préparation: organisation pleine dans la file maintenance (1 place pour alpha) ; deux exécutions d'alpha, une de beta
{
    UPDATE scheduler_queue:default SET concurrency = 10;
    fn::scheduler_settings_set({ tenant: auth_organization:alpha, tenant_concurrency: 1 });
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.purge", unique_key: "a1" });
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.purge", unique_key: "a2" });
    fn::scheduler_run_enqueue({ tenant: auth_organization:beta, task: "essai.purge", unique_key: "b1" });
};

-- test: une organisation pleine n'en bloque pas une autre ; places jamais dépassées
-- en tant que: worker
{
    LET $c = fn::scheduler_run_claim({ queue: "maintenance", node: "n1", host: "hote_essai", handlers: ["essai.rapport"], limit: 10 });
    UPSERT passe:m SET items = $c.data.items;
    RETURN array::sort($c.data.items.map(|$r| record::id($r.tenant))) = ["alpha", "beta"]
        AND (SELECT VALUE running FROM ONLY scheduler_slot:["maintenance", "alpha"]) = 1
        AND (SELECT VALUE running FROM ONLY scheduler_slot:["maintenance", "beta"]) = 1
        AND (SELECT VALUE running FROM ONLY scheduler_queue:maintenance) = 2
        AND fn::scheduler_run_claim({ queue: "maintenance", node: "n1", host: "hote_essai", handlers: ["essai.rapport"] }).data.items = [];
};

-- test: compteur de places d'une organisation protégé
-- en tant que: admin
RETURN array::len(UPDATE scheduler_slot:["maintenance", "alpha"] SET running = 0) = 0;

-- test: reprise d'un bail expiré : nouvelle tentative, erreur SCHEDULER_LEASE_LOST, places rendues ; l'ancien jeton ne vaut plus
{
    LET $alpha = (SELECT VALUE items FROM ONLY passe:m).filter(|$r| $r.tenant = auth_organization:alpha)[0];
    UPDATE $alpha.id SET locked_until = time::now() - 1s;
    LET $r = fn::scheduler_run_rescue({ node: "n1", generation: 1, limit: 10 });
    LET $run = (SELECT * FROM ONLY $alpha.id);
    RETURN $r.data.rescued = [{ id: $alpha.id, state: "retrying" }] AND $run.error.code = "SCHEDULER_LEASE_LOST" AND $run.attempt = 1
        AND (SELECT VALUE running FROM ONLY scheduler_slot:["maintenance", "alpha"]) = 0
        AND fn::scheduler_run_complete({ run: $alpha.id, lease: $alpha.lease }).error.code = "SCHEDULER_LEASE_LOST"
        AND fn::scheduler_run_rescue({ node: "n1", generation: 1 }).data.rescued = [];
};

-- test: une personne ne prolonge pas un bail
-- en tant que: operateur
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE items[0].id FROM ONLY passe:m) SET locked_until = time::now() + 1d;

-- préparation: planification d'installation en pause sur échec, une échéance réservée
{
    LET $s = fn::scheduler_schedule_create({ name: "tic", task: "essai.global", spec: { every: [1m] }, pause_on_failure: true }).data.id;
    fn::scheduler_schedule_next_set({ node: "n1", generation: 1, schedule: $s, next_fire_at: time::now() + 1m });
    fn::scheduler_schedule_fire({ node: "n1", generation: 1, schedule: $s, fire_times: [{ at: time::now() - 10s, available_at: time::now() - 10s }], next_fire_at: time::now() + 1m });
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", host: "hote_essai", handlers: ["essai.rapport"], limit: 10 }).data.items.filter(|$r| $r.schedule = $s)[0];
    UPSERT passe:g SET schedule = $s, run = $c;
};

-- test: dernière tentative en échec : dead, planification mise en pause, état reporté
-- en tant que: worker
{
    LET $g = (SELECT * FROM ONLY passe:g);
    LET $f = fn::scheduler_run_fail({ run: $g.run.id, lease: $g.run.lease, error: { code: "TIMEOUT" } });
    LET $s = (SELECT * FROM ONLY $g.schedule);
    RETURN $f.data.state = "dead" AND $s.paused AND $s.paused_reason = "failure" AND $s.next_fire_at IS NONE AND $s.last_state = "dead";
};

-- test: relance d'une exécution dead par la plateforme
-- en tant que: plateforme
RETURN fn::scheduler_run_retry({ run: (SELECT VALUE run.id FROM ONLY passe:g) }).data.origin = "retry";

-- préparation: historique ancien d'une planification (12 exécutions sautées il y a 40 jours) et conservation de 3
{
    fn::scheduler_settings_set({ tenant: auth_organization:alpha, keep_last_runs: 3 });
    LET $s = fn::scheduler_schedule_create({ tenant: auth_organization:alpha, name: "vieille", task: "essai.purge", spec: { every: [1h] } }).data;
    FOR $i IN <array> (1..13) {
        LET $t = time::now() - 40d - duration::from_hours($i);
        CREATE type::record("scheduler_run", [$s.id, $t]) CONTENT { tenant: $s.tenant, schedule: $s.id, task: $s.task, args: {}, queue: scheduler_queue:maintenance, priority: 7, origin: "schedule", scheduled_for: $t, available_at: $t, state: "skipped", finished_at: $t, max_attempts: 2 };
    };
    UPSERT passe:p SET schedule = $s.id;
};

-- test: élagage : terminées anciennes supprimées, les 3 dernières de la planification gardées, récentes gardées
{
    LET $s = (SELECT VALUE schedule FROM ONLY passe:p);
    LET $count_before = count(SELECT * FROM scheduler_run);
    LET $p = fn::scheduler_run_prune({ node: "n1", generation: 1, limit: 100 });
    LET $kept = (SELECT VALUE scheduled_for FROM scheduler_run WHERE schedule = $s ORDER BY scheduled_for DESC);
    RETURN $p.data.deleted = 9 AND count(SELECT * FROM scheduler_run) = $count_before - 9 AND array::len($kept) = 3
        AND $kept[0] > time::now() - 40d - 2h
        AND fn::scheduler_run_prune({ node: "n1", generation: 1 }).data.deleted = 0;
};

-- test: seul le moteur réserve, bat, termine, reprend et élague
-- en tant que: admin
{
    LET $a = (SELECT VALUE a FROM ONLY passe:r);
    RETURN [
        fn::scheduler_run_claim({ queue: "default", node: "n1", host: "hote_essai", handlers: ["essai.rapport"] }),
        fn::scheduler_run_heartbeat({ run: <string> $a.id, lease: "00000000-0000-7000-8000-000000000000" }),
        fn::scheduler_run_complete({ run: <string> $a.id, lease: "00000000-0000-7000-8000-000000000000" }),
        fn::scheduler_run_fail({ run: <string> $a.id, lease: "00000000-0000-7000-8000-000000000000", error: { code: "X" } }),
        fn::scheduler_run_rescue({ node: "n1", generation: 1 }),
        fn::scheduler_run_prune({ node: "n1", generation: 1 })
    ].all(|$r| $r.error.code = "SCHEDULER_PERMISSION_DENIED");
};

-- test: fins d'exécution publiées sur le bus avec code d'erreur, jamais d'arguments ni de résultat
{
    LET $types = (SELECT VALUE event_type FROM event_outbox WHERE string::starts_with(event_type, "scheduler.run.") AND event_type != "scheduler.run.skipped" ORDER BY created_at);
    LET $bus = <string> (SELECT payload FROM event_outbox WHERE string::starts_with(event_type, "scheduler.run."));
    RETURN $types = ["scheduler.run.completed", "scheduler.run.failed", "scheduler.run.dead", "scheduler.run.failed", "scheduler.run.dead"]
        AND (SELECT VALUE payload.error_code FROM event_outbox WHERE event_type = "scheduler.run.dead" ORDER BY created_at) = ["BAD_INPUT", "TIMEOUT"]
        AND !string::contains($bus, "pages") AND !string::contains($bus, "note");
};

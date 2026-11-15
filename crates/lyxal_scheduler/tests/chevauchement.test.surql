-- lyxal-test: assertions
-- Chevauchement : chaque politique (skip → skipped, buffer_one, buffer_all → waiting puis
-- libérée dans l'ordre, cancel_other, allow_all), libération à la fin d'une exécution et après
-- une annulation, garde de libération, déclenchement immédiat soumis au chevauchement.
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

-- préparation: une planification par politique
{
    FOR $o IN ["skip", "buffer_one", "buffer_all", "cancel_other", "allow_all"] {
        fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "p-" + string::replace($o, "_", "-"), task: "essai.rapport", args: { format: "pdf" }, spec: { every: [1m] }, catchup: "all", overlap: $o });
    };
};

-- test: skip : une exécution active, les suivantes sautées et publiées
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-skip" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3m, time::now() - 2m, time::now() - 1m], next_fire_at: time::now() + 1m });
    RETURN $f.data.runs.state = ["queued", "skipped", "skipped"] AND $f.data.schedule.last_state = "skipped"
        AND count(SELECT * FROM scheduler_run WHERE schedule = $s AND state = "skipped" AND finished_at IS NOT NONE) = 2;
};

-- test: exécutions sautées publiées sur le bus
RETURN count(SELECT * FROM event_outbox WHERE event_type = "scheduler.run.skipped") = 2;

-- test: buffer_one : une seule en attente, les suivantes sautées
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-buffer-one" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3m, time::now() - 2m, time::now() - 1m], next_fire_at: time::now() + 1m });
    RETURN $f.data.runs.state = ["queued", "waiting", "skipped"];
};

-- test: buffer_all : toutes en attente derrière la première
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-buffer-all" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3m, time::now() - 2m, time::now() - 1m], next_fire_at: time::now() + 1m });
    RETURN $f.data.runs.state = ["queued", "waiting", "waiting"];
};

-- test: allow_all : toutes en file
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-allow-all" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3m, time::now() - 2m, time::now() - 1m], next_fire_at: time::now() + 1m });
    RETURN $f.data.runs.state = ["queued", "queued", "queued"];
};

-- test: buffer_all : les exécutions en attente sont libérées une à une, dans l'ordre
-- en tant que: operateur
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-buffer-all" LIMIT 1);
    LET $first = (SELECT VALUE id FROM ONLY scheduler_run WHERE schedule = $s AND state = "queued" LIMIT 1);
    -- La première est annulée par une personne : la suivante prend la place
    LET $cancel = fn::scheduler_run_cancel({ run: $first });
    LET $states = (SELECT VALUE state FROM scheduler_run WHERE schedule = $s ORDER BY scheduled_for);
    RETURN $cancel.data.state = "cancelled" AND $states = ["cancelled", "queued", "waiting"];
};

-- test: cancel_other sans exécution en cours : les précédentes annulées, la dernière en file
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-cancel-other" LIMIT 1);
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 3m, time::now() - 2m], next_fire_at: time::now() + 1m });
    RETURN $f.data.runs.state = ["queued", "queued"]
        AND (SELECT VALUE state FROM scheduler_run WHERE schedule = $s ORDER BY scheduled_for) = ["cancelled", "queued"]
        AND (SELECT VALUE cancel_reason FROM scheduler_run WHERE schedule = $s AND state = "cancelled") = ["overlap"];
};

-- test: cancel_other avec une exécution en cours : demande d'annulation, la nouvelle attend
-- en tant que: worker
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-cancel-other" LIMIT 1);
    LET $c = fn::scheduler_run_claim({ queue: "default", node: "n1", limit: 100 }).data.items;
    LET $mine = $c.filter(|$r| $r.schedule = $s)[0];
    UPSERT passe:co SET run = $mine.id, lease = $mine.lease;
    LET $f = fn::scheduler_schedule_fire({ schedule: $s, fire_times: [time::now() - 1m], next_fire_at: time::now() + 1m });
    LET $running = (SELECT * FROM ONLY $mine.id);
    RETURN $f.data.runs.state = ["waiting"] AND $running.state = "running" AND $running.cancel_requested AND $running.cancel_reason = "overlap";
};

-- test: la fin acquittée de l'annulée libère l'exécution en attente
-- en tant que: worker
{
    LET $p = (SELECT * FROM ONLY passe:co);
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-cancel-other" LIMIT 1);
    LET $h = fn::scheduler_run_heartbeat({ run: $p.run, lease: $p.lease });
    LET $end = fn::scheduler_run_fail({ run: $p.run, lease: $p.lease, error: { code: "CANCELLED", message: "Arrêt demandé" } });
    RETURN $h.data.cancel_requested AND $end.data.state = "cancelled"
        AND (SELECT VALUE state FROM scheduler_run WHERE schedule = $s ORDER BY scheduled_for) = ["cancelled", "cancelled", "queued"];
};

-- test: une exécution en attente ne passe pas devant une exécution active (garde)
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
{
    LET $s = (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-buffer-all" LIMIT 1);
    UPDATE scheduler_run SET state = "queued" WHERE schedule = $s AND state = "waiting";
};

-- test: déclenchement immédiat soumis au chevauchement de la planification, ou à celui demandé
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id FROM ONLY scheduler_schedule WHERE name = "p-skip" LIMIT 1);
    LET $a = fn::scheduler_schedule_trigger({ schedule: $s });
    LET $b = fn::scheduler_schedule_trigger({ schedule: $s, overlap: "allow_all" });
    RETURN $a.data.state = "skipped" AND $b.data.state = "queued" AND $b.data.origin = "trigger";
};

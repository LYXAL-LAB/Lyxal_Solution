-- lyxal-test: assertions
-- Journal et bus : une entrée par action d'une personne (réglages, planification créée,
-- modifiée, mise en pause, reprise, déclenchée, rejouée, supprimée), auteur, type de session et
-- adresse, aucun argument ; le moteur ne journalise pas ses échéances ; lecture filtrée ; ajout
-- seul ; isolation ; événements scheduler.schedule.* publiés sans arguments ; suppression d'une
-- organisation.
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

-- préparation: actions d'un rédacteur sur une planification d'alpha
-- en tant que: redacteur
{
    LET $s = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "journal", task: "essai.rapport", args: { format: "pdf", note: "SECRETNOTE" }, spec: { every: [1h] } }).data.id;
    fn::scheduler_schedule_update({ schedule: $s, overlap: "allow_all" });
    fn::scheduler_schedule_pause({ schedule: $s, reason: "Essai" });
    fn::scheduler_schedule_resume({ schedule: $s });
    fn::scheduler_schedule_trigger({ schedule: $s });
    fn::scheduler_schedule_backfill({ schedule: $s, from: time::now() - 2d, to: time::now() - 1d });
    CREATE passe:j SET id_schedule = $s;
};

-- préparation: le moteur traite une échéance (non journalisée)
{
    LET $s = (SELECT VALUE id_schedule FROM ONLY passe:j);
    fn::scheduler_schedule_next_set({ schedule: $s, next_fire_at: time::now() + 1h });
    fn::scheduler_schedule_fire({ schedule: $s, fire_times: [{ at: time::now() - 1m, available_at: time::now() - 1m }], next_fire_at: time::now() + 1h });
};

-- test: une entrée par action, dans l'ordre ; auteur, session, jamais d'arguments
{
    LET $e = (SELECT * FROM scheduler_audit WHERE scope_key = "alpha" ORDER BY created_at ASC, id ASC);
    RETURN $e.action = ["schedule.create", "schedule.update", "schedule.pause", "schedule.resume", "run.trigger", "schedule.backfill"]
        AND $e.all(|$x| $x.actor = "auth_identity:redacteur" AND $x.session_kind = "interactive")
        AND $e[1].details.fields = ["overlap"] AND $e[2].details.reason = "Essai"
        AND $e[0].schedule = <string> (SELECT VALUE id_schedule FROM ONLY passe:j)
        AND !string::contains(<string> $e, "SECRETNOTE");
};

-- test: événements de planification publiés, sans arguments
{
    LET $bus = (SELECT event_type, payload FROM event_outbox WHERE string::starts_with(event_type, "scheduler.schedule.") ORDER BY created_at ASC);
    RETURN $bus.event_type = ["scheduler.schedule.created", "scheduler.schedule.updated", "scheduler.schedule.paused", "scheduler.schedule.resumed"]
        AND $bus[0].payload.task = "essai.rapport" AND $bus[0].payload.tenant = "auth_organization:alpha" AND $bus[1].payload.fields = ["overlap"]
        AND !string::contains(<string> $bus, "SECRETNOTE") AND !string::contains(<string> (SELECT * FROM event_outbox), "SECRETNOTE");
};

-- test: lecture du journal par un lecteur : plus récent d'abord, filtres
-- en tant que: lecteur
{
    LET $s = <string> (SELECT VALUE id_schedule FROM ONLY passe:j);
    LET $all = fn::scheduler_audit_list({ tenant: "auth_organization:alpha" });
    LET $pause = fn::scheduler_audit_list({ tenant: "auth_organization:alpha", action: "schedule.pause" });
    LET $sched = fn::scheduler_audit_list({ tenant: "auth_organization:alpha", schedule: $s, since: time::now() - 1h, limit: 2, start: 1 });
    RETURN $all.data.total = 6 AND $all.data.items[0].action = "schedule.backfill"
        AND $pause.data.total = 1 AND $sched.data.total = 6 AND array::len($sched.data.items) = 2;
};

-- test: le journal est en ajout seul, même pour un administrateur
-- en tant que: admin
{
    LET $c = (CREATE scheduler_audit CONTENT { tenant: auth_organization:alpha, action: "faux.ajout" });
    LET $u = (UPDATE scheduler_audit SET action = "x");
    LET $d = (DELETE scheduler_audit RETURN BEFORE);
    RETURN array::len($c) = 0 AND array::len($u) = 0 AND array::len($d) = 0 AND fn::scheduler_audit_list({ tenant: "auth_organization:alpha" }).data.total = 6;
};

-- test: organisations isolées
-- en tant que: autre
RETURN fn::scheduler_audit_list({ tenant: "auth_organization:alpha" }).error.code = "SCHEDULER_PERMISSION_DENIED"
    AND fn::scheduler_audit_list({ tenant: "auth_organization:beta" }).data.total = 0
    AND array::len(SELECT * FROM scheduler_audit) = 0;

-- test: suppression d'une planification journalisée et publiée
-- en tant que: redacteur
{
    fn::scheduler_schedule_delete({ schedule: <string> (SELECT VALUE id_schedule FROM ONLY passe:j) });
    RETURN fn::scheduler_audit_list({ tenant: "auth_organization:alpha", action: "schedule.delete" }).data.total = 1;
};

-- test: publication de la suppression et de la fin d'une planification
RETURN count(SELECT * FROM event_outbox WHERE event_type = "scheduler.schedule.deleted") = 1;

-- test: la suppression d'une organisation emporte planifications, exécutions, journal et réglages, sans entrée nouvelle
{
    fn::scheduler_settings_set({ tenant: auth_organization:alpha, keep_last_runs: 2 });
    fn::scheduler_schedule_create({ tenant: auth_organization:alpha, name: "orpheline", task: "essai.purge", spec: { every: [1h] } });
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.purge" });
    DELETE auth_organization:alpha;
    RETURN count(SELECT * FROM scheduler_schedule WHERE scope_key = "alpha") = 0
        AND count(SELECT * FROM scheduler_run WHERE scope_key = "alpha") = 0
        AND count(SELECT * FROM scheduler_audit WHERE scope_key = "alpha") = 0
        AND count(SELECT * FROM scheduler_settings WHERE scope_key = "alpha") = 0;
};

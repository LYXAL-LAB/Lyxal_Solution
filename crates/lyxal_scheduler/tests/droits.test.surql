-- lyxal-test: assertions
-- Droits : permissions et rôles créés par le seed, files du seed, rejeu des seeds ;
-- fn::scheduler_can par action, par portée et avec la permission propre d'une tâche ;
-- organisations isolées ; installation ; moteur ; écritures filtrées par les permissions ;
-- membre sans permission refusé par chaque fonction. Réglages : valeurs effectives, bornes.
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

-- test: permissions et rôles créés par le seed ; organization_admin reçoit les permissions d'organisation, platform_admin l'installation, aucun rôle le moteur
RETURN (SELECT VALUE code FROM auth_permission WHERE module = "lyxal_scheduler" ORDER BY code) == ["scheduler.calendar.write", "scheduler.installation.manage", "scheduler.run.manage", "scheduler.schedule.read", "scheduler.schedule.write", "scheduler.settings.manage", "scheduler.worker"]
    AND array::sort((SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_admin).filter(|$c| string::starts_with($c, "scheduler."))) == ["scheduler.calendar.write", "scheduler.run.manage", "scheduler.schedule.read", "scheduler.schedule.write", "scheduler.settings.manage"]
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin).filter(|$c| string::starts_with($c, "scheduler.")) == ["scheduler.installation.manage"]
    AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨scheduler.worker⟩) == 0;

-- test: files default et maintenance créées par le seed, complètes
RETURN (SELECT VALUE [record::id(id), concurrency, running, paused] FROM scheduler_queue ORDER BY id) == [["default", 10, 0, false], ["maintenance", 2, 0, false]];

-- test: rejeu des seeds sans doublon ni écrasement
{
    UPDATE scheduler_queue:maintenance SET concurrency = 3;
    IF !record::exists(scheduler_queue:maintenance) THEN (
        CREATE scheduler_queue:maintenance CONTENT { concurrency: 2, running: 0, paused: false, updated_at: time::now() }
    ) END;
    IF !record::exists(auth_permission:⟨scheduler.worker⟩) THEN (
        CREATE auth_permission:⟨scheduler.worker⟩ CONTENT { code: "scheduler.worker", module: "lyxal_scheduler", scope: "installation", description: { fr: "x", en: "x" } }
    ) END;
    IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨scheduler.run.manage⟩) = 0 THEN (
        RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨scheduler.run.manage⟩
    ) END;
    LET $ok = array::len(SELECT * FROM auth_permission WHERE module = "lyxal_scheduler") = 7
        AND (SELECT VALUE concurrency FROM ONLY scheduler_queue:maintenance) = 3
        AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨scheduler.run.manage⟩) = 1;
    UPDATE scheduler_queue:maintenance SET concurrency = 2;
    RETURN $ok;
};

-- test: la session système peut tout, partout
RETURN ["read", "write", "run_manage", "calendar", "settings", "catalog", "installation", "worker"].all(|$a| fn::scheduler_can({ action: $a, tenant: auth_organization:alpha }) AND fn::scheduler_can({ action: $a }))
    AND fn::scheduler_can({ action: "write", tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩ })
    AND fn::scheduler_caller().system AND fn::scheduler_caller().identity IS NONE;

-- test: administrateur : tout dans son organisation, rien ailleurs, ni l'installation ni le moteur
-- en tant que: admin
RETURN ["read", "write", "run_manage", "calendar", "settings", "catalog"].all(|$a| fn::scheduler_can({ action: $a, tenant: auth_organization:alpha }))
    AND !["read", "write", "run_manage", "calendar", "settings"].any(|$a| fn::scheduler_can({ action: $a, tenant: auth_organization:beta }))
    AND !["read", "write", "installation", "worker"].any(|$a| fn::scheduler_can({ action: $a }))
    AND !fn::scheduler_can({ action: "inconnue", tenant: auth_organization:alpha })
    AND fn::scheduler_can({ action: "write", tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩ })
    AND fn::scheduler_caller().identity = auth_identity:admin AND fn::scheduler_caller().kind = "interactive";

-- test: permission propre de la tâche : écriture sans elle refusée pour cette tâche seulement ; tâche inconnue refusée
-- en tant que: sanstache
RETURN fn::scheduler_can({ action: "write", tenant: auth_organization:alpha })
    AND !fn::scheduler_can({ action: "write", tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩ })
    AND fn::scheduler_can({ action: "write", tenant: auth_organization:alpha, task: scheduler_task:⟨essai.purge⟩ })
    AND !fn::scheduler_can({ action: "write", tenant: auth_organization:alpha, task: scheduler_task:⟨essai.inconnue⟩ })
    AND !fn::scheduler_can({ action: "write", tenant: auth_organization:alpha, task: "essai.purge" });

-- test: lecteur : lecture et catalogue seulement
-- en tant que: lecteur
RETURN fn::scheduler_can({ action: "read", tenant: auth_organization:alpha }) AND fn::scheduler_can({ action: "catalog" })
    AND !["write", "run_manage", "calendar", "settings"].any(|$a| fn::scheduler_can({ action: $a, tenant: auth_organization:alpha }));

-- test: membre sans permission : ni lecture ni catalogue
-- en tant que: membre
RETURN !["read", "write", "run_manage", "calendar", "settings"].any(|$a| fn::scheduler_can({ action: $a, tenant: auth_organization:alpha }))
    AND !fn::scheduler_can({ action: "catalog" });

-- test: plateforme : l'installation et le catalogue, aucune organisation
-- en tant que: plateforme
RETURN ["read", "write", "calendar", "settings", "catalog", "installation"].all(|$a| fn::scheduler_can({ action: $a }))
    AND !fn::scheduler_can({ action: "read", tenant: auth_organization:alpha }) AND !fn::scheduler_can({ action: "worker" });

-- test: compte du moteur : worker et catalogue, aucune organisation ni l'installation
-- en tant que: worker
RETURN fn::scheduler_can({ action: "worker" }) AND fn::scheduler_can({ action: "catalog" })
    AND !fn::scheduler_can({ action: "read", tenant: auth_organization:alpha }) AND !fn::scheduler_can({ action: "installation" });

-- test: réglages par défaut (aucune ligne)
RETURN fn::scheduler_settings_get({}).data == { own: NONE, effective: { catchup_window: 1h, run_retention: 30d, keep_last_runs: 10, tenant_concurrency: 10, max_schedules: 1000, max_pending_runs: 10000, max_args_bytes: 16384 } };

-- test: réglages de l'installation par la plateforme, hérités par une organisation
-- en tant que: plateforme
{
    LET $r = fn::scheduler_settings_set({ run_retention: 60d, tenant_concurrency: 4 });
    RETURN $r.ok AND $r.data.own.scope_key = "installation" AND $r.data.effective.run_retention = 60d
        AND fn::scheduler_settings_effective({ tenant: auth_organization:alpha }).tenant_concurrency = 4;
};

-- test: réglages de l'organisation : surcharge, effacement par clear, retour à l'installation
-- en tant que: admin
{
    LET $a = fn::scheduler_settings_set({ tenant: "auth_organization:alpha", tenant_concurrency: 2, keep_last_runs: 3 });
    LET $b = fn::scheduler_settings_set({ tenant: "auth_organization:alpha", clear: ["tenant_concurrency"] });
    LET $g = fn::scheduler_settings_get({ tenant: "auth_organization:alpha" });
    RETURN $a.ok AND $a.data.effective.tenant_concurrency = 2 AND $a.data.own.scope_key = "alpha"
        AND $b.data.own.tenant_concurrency IS NONE AND $b.data.own.keep_last_runs = 3
        AND $g.data.effective.tenant_concurrency = 4 AND $g.data.effective.run_retention = 60d AND $g.data.effective.keep_last_runs = 3;
};

-- test: réglages hors bornes et champ inconnu refusés
-- en tant que: admin
RETURN [
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", catchup_window: 10s }),
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", tenant_concurrency: 0 }),
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", max_args_bytes: 100 }),
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", clear: ["inconnu"] }),
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", inconnu: 1 }),
    fn::scheduler_settings_get({ tenant: "pas_une_org:x" })
].all(|$r| $r.error.code = "SCHEDULER_INVALID_PARAMETERS");

-- test: organisations isolées : beta ne lit ni ne règle alpha
-- en tant que: autre
RETURN fn::scheduler_settings_get({ tenant: "auth_organization:alpha" }).error.code = "SCHEDULER_PERMISSION_DENIED"
    AND fn::scheduler_settings_set({ tenant: "auth_organization:alpha", keep_last_runs: 1 }).error.code = "SCHEDULER_PERMISSION_DENIED"
    AND array::len(SELECT * FROM scheduler_settings WHERE scope_key = "alpha") = 0
    AND fn::scheduler_settings_get({ tenant: "auth_organization:beta" }).ok;

-- test: écriture filtrée par les permissions de table : rien n'est écrit
-- en tant que: lecteur
{
    LET $w = (UPDATE scheduler_settings:alpha SET keep_last_runs = 1);
    LET $c = (CREATE scheduler_settings:beta CONTENT { tenant: auth_organization:beta });
    RETURN array::len($w) = 0 AND array::len($c) = 0;
};

-- test: membre sans permission : chaque fonction refuse
-- en tant que: membre
{
    LET $alpha = "auth_organization:alpha";
    RETURN [
        fn::scheduler_settings_get({ tenant: $alpha }),
        fn::scheduler_settings_set({ tenant: $alpha, keep_last_runs: 1 }),
        fn::scheduler_task_list({}),
        fn::scheduler_task_get({ task: "essai.rapport" }),
        fn::scheduler_task_set_state({ task: "essai.rapport", state: "disabled" }),
        fn::scheduler_queue_list({}),
        fn::scheduler_queue_pause({ queue: "default" }),
        fn::scheduler_queue_resume({ queue: "default" }),
        fn::scheduler_calendar_create({ tenant: $alpha, name: "feries", rules: [{ mode: "exclude", kind: "weekdays", values: [7] }] }),
        fn::scheduler_calendar_list({ tenant: $alpha }),
        fn::scheduler_schedule_create({ tenant: $alpha, name: "x", task: "essai.purge", spec: { every: [1h] } }),
        fn::scheduler_schedule_list({ tenant: $alpha }),
        fn::scheduler_run_enqueue({ tenant: $alpha, task: "essai.purge" }),
        fn::scheduler_run_list({ tenant: $alpha }),
        fn::scheduler_audit_list({ tenant: $alpha }),
        fn::scheduler_due_list({}),
        fn::scheduler_run_claim({ queue: "default", node: "n1", host: "hote_essai", handlers: ["essai.rapport"] }),
        fn::scheduler_run_rescue({ node: "n1", generation: 1 }),
        fn::scheduler_run_prune({ node: "n1", generation: 1 })
    ].all(|$r| $r.error.code = "SCHEDULER_PERMISSION_DENIED");
};

-- préparation: tables fermées à l'écriture, pour vérifier le contrôle de l'écriture principale
{
    DEFINE TABLE OVERWRITE scheduler_settings TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE scheduler_calendar TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE scheduler_schedule TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE scheduler_run TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
};

-- test: écriture principale refusée par la table : erreur explicite, jamais un faux succès
-- en tant que: admin
RETURN [
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", keep_last_runs: 3 }),
    fn::scheduler_calendar_create({ tenant: "auth_organization:alpha", name: "ferme", rules: [{ mode: "include", kind: "weekdays", values: [1] }] }),
    fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "fermee", task: "essai.purge", spec: { every: [1h] } }),
    fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge" })
].all(|$r| $r.error.code = "SCHEDULER_WRITE_FORBIDDEN");

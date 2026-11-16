-- lyxal-test: assertions
-- Calendriers : règles valides et fausses (forme et valeurs par kind), unicité du nom dans la
-- portée, modification qui remet à calculer les planifications qui l'utilisent, lecture, liste,
-- suppression refusée tant qu'une planification l'utilise, droits et isolation, journal.
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

-- test: création d'un calendrier avec chaque sorte de règle
-- en tant que: admin
{
    LET $c = fn::scheduler_calendar_create({ tenant: "auth_organization:alpha", name: "ouvres", description: "Jours ouvrés", rules: [
        { mode: "exclude", kind: "dates", values: ["2026-12-25", "2027-01-01"] },
        { mode: "exclude", kind: "annual", values: ["05-01", "07-14"] },
        { mode: "include", kind: "weekdays", values: [1, 2, 3, 4, 5] },
        { mode: "exclude", kind: "monthdays", values: [31] },
        { mode: "include", kind: "time_range", values: ["08:00-18:00", "22:00-02:00"] }
    ] });
    CREATE passe:cal SET id_cal = $c.data.id;
    RETURN $c.ok AND $c.data.scope_key = "alpha" AND array::len($c.data.rules) = 5 AND $c.data.created_by = auth_identity:admin;
};

-- test: règles fausses refusées (mode, kind, valeurs par kind, liste vide, clé inconnue)
-- en tant que: admin
RETURN [
    [{ mode: "peut-être", kind: "dates", values: ["2026-12-25"] }],
    [{ mode: "exclude", kind: "lunaire", values: [1] }],
    [{ mode: "exclude", kind: "dates", values: ["25/12/2026"] }],
    [{ mode: "exclude", kind: "annual", values: ["13-01"] }],
    [{ mode: "exclude", kind: "weekdays", values: [8] }],
    [{ mode: "exclude", kind: "monthdays", values: [0] }],
    [{ mode: "include", kind: "time_range", values: ["8h-18h"] }],
    [{ mode: "include", kind: "weekdays", values: [] }],
    [{ mode: "include", kind: "weekdays", values: [1], extra: true }],
    []
].all(|$rules| fn::scheduler_calendar_create({ tenant: "auth_organization:alpha", name: "faux", rules: $rules }).error.code = "SCHEDULER_INVALID_PARAMETERS")
    AND fn::scheduler_calendar_create({ tenant: "auth_organization:alpha", name: "Pas Un Slug", rules: [{ mode: "include", kind: "weekdays", values: [1] }] }).error.code = "SCHEDULER_INVALID_PARAMETERS";

-- test: règles fausses refusées aussi pour une écriture directe
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_calendar CONTENT { tenant: auth_organization:alpha, name: "direct", rules: [{ mode: "include", kind: "weekdays", values: [9] }] };

-- test: nom unique dans la portée ; même nom permis dans une autre organisation
-- en tant que: admin
RETURN fn::scheduler_calendar_create({ tenant: "auth_organization:alpha", name: "ouvres", rules: [{ mode: "include", kind: "weekdays", values: [1] }] }).error.code = "SCHEDULER_CALENDAR_EXISTS";

-- test: même nom dans beta ; beta ne voit pas alpha
-- en tant que: autre
{
    LET $c = fn::scheduler_calendar_create({ tenant: "auth_organization:beta", name: "ouvres", rules: [{ mode: "include", kind: "weekdays", values: [1] }] });
    LET $cal = <string> (SELECT VALUE id_cal FROM ONLY passe:cal);
    RETURN $c.ok AND $c.data.scope_key = "beta"
        AND fn::scheduler_calendar_get({ calendar: $cal }).error.code = "SCHEDULER_CALENDAR_NOT_FOUND"
        AND fn::scheduler_calendar_update({ calendar: $cal, description: "x" }).error.code = "SCHEDULER_CALENDAR_NOT_FOUND"
        AND fn::scheduler_calendar_delete({ calendar: $cal }).error.code = "SCHEDULER_CALENDAR_NOT_FOUND"
        AND fn::scheduler_calendar_list({ tenant: "auth_organization:alpha" }).error.code = "SCHEDULER_PERMISSION_DENIED"
        AND fn::scheduler_calendar_list({ tenant: "auth_organization:beta" }).data.total = 1;
};

-- test: un lecteur lit et liste, sans écrire
-- en tant que: lecteur
{
    LET $cal = <string> (SELECT VALUE id_cal FROM ONLY passe:cal);
    RETURN fn::scheduler_calendar_get({ calendar: $cal }).data.name = "ouvres"
        AND fn::scheduler_calendar_list({ tenant: "auth_organization:alpha", limit: 10 }).data.total = 1
        AND fn::scheduler_calendar_update({ calendar: $cal, description: "x" }).error.code = "SCHEDULER_PERMISSION_DENIED"
        AND fn::scheduler_calendar_delete({ calendar: $cal }).error.code = "SCHEDULER_PERMISSION_DENIED"
        AND fn::scheduler_calendar_create({ tenant: "auth_organization:alpha", name: "x", rules: [{ mode: "include", kind: "weekdays", values: [1] }] }).error.code = "SCHEDULER_PERMISSION_DENIED";
};

-- préparation: planification qui utilise le calendrier, échéance déjà calculée
-- en tant que: admin
{
    LET $cal = <string> (SELECT VALUE id_cal FROM ONLY passe:cal);
    LET $s = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "rapport", task: "essai.rapport", args: { format: "pdf" }, spec: { cron: ["0 9 * * *"] }, calendars: [$cal] });
    UPDATE passe:cal SET id_schedule = $s.data.id;
};

-- préparation: le moteur écrit la prochaine échéance
fn::scheduler_schedule_next_set({ node: "n1", generation: 1, schedule: (SELECT VALUE id_schedule FROM ONLY passe:cal), next_fire_at: time::now() + 1d });

-- test: la fiche montre les planifications qui l'utilisent ; suppression refusée
-- en tant que: admin
{
    LET $cal = <string> (SELECT VALUE id_cal FROM ONLY passe:cal);
    RETURN fn::scheduler_calendar_get({ calendar: $cal }).data.schedules = [(SELECT VALUE id_schedule FROM ONLY passe:cal)]
        AND fn::scheduler_calendar_delete({ calendar: $cal }).error.code = "SCHEDULER_CALENDAR_IN_USE";
};

-- test: suppression directe d'un calendrier utilisé refusée
-- attendu-erreur: SCHEDULER_CALENDAR_IN_USE
DELETE (SELECT VALUE id_cal FROM ONLY passe:cal);

-- test: nouvelles règles : la planification recalcule sa prochaine échéance ; description effacée par clear
-- en tant que: admin
{
    LET $cal = <string> (SELECT VALUE id_cal FROM ONLY passe:cal);
    LET $u = fn::scheduler_calendar_update({ calendar: $cal, rules: [{ mode: "include", kind: "weekdays", values: [1, 2] }], clear: ["description"] });
    RETURN $u.ok AND array::len($u.data.rules) = 1 AND $u.data.description IS NONE AND $u.data.name = "ouvres"
        AND (SELECT VALUE next_fire_at FROM ONLY (SELECT VALUE id_schedule FROM ONLY passe:cal)) IS NONE
        AND fn::scheduler_calendar_update({ calendar: $cal, rules: [{ mode: "include", kind: "weekdays", values: [0] }] }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_calendar_update({ calendar: "scheduler_calendar:inconnu" }).error.code = "SCHEDULER_CALENDAR_NOT_FOUND";
};

-- test: un calendrier d'une autre organisation n'est pas utilisable
-- en tant que: admin
RETURN fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "x", task: "essai.purge", spec: { every: [1h] },
    calendars: [<string> (SELECT VALUE id FROM ONLY scheduler_calendar WHERE scope_key = "beta" LIMIT 1)] }).error.code = "SCHEDULER_CALENDAR_NOT_FOUND";

-- test: auteur figé
-- en tant que: admin
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE id_cal FROM ONLY passe:cal) SET created_by = auth_identity:lecteur;

-- test: une fois libéré, le calendrier se supprime
-- en tant que: admin
{
    LET $cal = <string> (SELECT VALUE id_cal FROM ONLY passe:cal);
    fn::scheduler_schedule_update({ schedule: (SELECT VALUE id_schedule FROM ONLY passe:cal), clear: ["calendars"] });
    LET $d = fn::scheduler_calendar_delete({ calendar: $cal });
    RETURN $d.data.deleted = $cal AND fn::scheduler_calendar_list({ tenant: "auth_organization:alpha" }).data.total = 0;
};

-- test: calendriers journalisés
RETURN (SELECT VALUE action FROM scheduler_audit WHERE scope_key = "alpha" AND string::starts_with(action, "calendar.") ORDER BY created_at) = ["calendar.create", "calendar.update", "calendar.delete"];

-- test: calendrier de l'installation par la plateforme
-- en tant que: plateforme
RETURN fn::scheduler_calendar_create({ name: "feries", rules: [{ mode: "exclude", kind: "annual", values: ["01-01"] }] }).data.scope_key = "installation"
    AND fn::scheduler_calendar_list({}).data.total = 1;

-- test: la suppression de l'organisation emporte ses calendriers
{
    DELETE auth_organization:beta;
    RETURN count(SELECT * FROM scheduler_calendar WHERE scope_key = "beta") = 0;
};

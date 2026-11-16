-- lyxal-test: assertions
-- Exécutions différées et immédiates : run_at, delay, priorité, arguments, unicité (duplicate,
-- clé fournie ou empreinte des arguments), limite d'attente ; lecture, liste ; annulation ;
-- relance d'une exécution dead ou cancelled ; champs figés, transitions interdites, jeton du
-- bail illisible hors moteur ; droits et isolation.
--
-- identité admin: {"id": "auth_session:admin", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "scheduler.run.manage", "scheduler.calendar.write", "scheduler.settings.manage", "essai.rapport.run"]}
-- identité redacteur: {"id": "auth_session:redacteur", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "essai.rapport.run"]}
-- identité sanstache: {"id": "auth_session:sanstache", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write"]}
-- identité lecteur: {"id": "auth_session:lecteur", "pv": 1, "permissions": ["scheduler.schedule.read"]}
-- identité operateur: {"id": "auth_session:operateur", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.run.manage", "essai.rapport.run"]}
-- identité operateursanstache: {"id": "auth_session:operateursanstache", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.run.manage"]}
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
    FOR $n IN ["admin", "redacteur", "sanstache", "lecteur", "operateur", "operateursanstache", "membre"] {
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

-- test: exécution différée par run_at, priorité propre
-- en tant que: redacteur
{
    LET $at = time::now() + 1d;
    LET $r = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "csv" }, run_at: $at, priority: 1 });
    CREATE passe:e SET id_run = $r.data.id;
    RETURN $r.ok AND !$r.data.duplicate AND $r.data.state = "queued" AND $r.data.origin = "enqueue" AND $r.data.scheduled_for = $at AND $r.data.available_at = $at
        AND $r.data.priority = 1 AND $r.data.max_attempts = 3 AND $r.data.queue = scheduler_queue:default AND $r.data.schedule IS NONE AND $r.data.created_by = auth_identity:redacteur
        AND $r.data.unique_key IS NONE;
};

-- test: exécution par délai, et immédiate ; priorité de la tâche par défaut
-- en tant que: redacteur
{
    LET $d = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" }, delay: 3d });
    LET $now = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" } });
    RETURN $d.data.scheduled_for > time::now() + 2d AND $d.data.scheduled_for < time::now() + 4d AND $d.data.priority = 5
        AND $now.data.scheduled_for <= time::now();
};

-- test: paramètres faux refusés : run_at et delay ensemble, run_at passé, arguments hors schéma, tâche inconnue
-- en tant que: redacteur
RETURN fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" }, run_at: time::now() + 1h, delay: 1h }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" }, run_at: time::now() - 1h }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" }, priority: 10 }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "odt" } }).error.code = "SCHEDULER_ARGS_INVALID"
    AND fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.zzz" }).error.code = "SCHEDULER_TASK_NOT_FOUND";

-- test: permission propre de la tâche exigée pour une exécution différée
-- en tant que: sanstache
RETURN fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" } }).error.code = "SCHEDULER_PERMISSION_DENIED"
    AND array::len(CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "pdf" }, queue: scheduler_queue:default, priority: 5, origin: "enqueue", scheduled_for: time::now(), available_at: time::now(), state: "queued", max_attempts: 3, created_by: auth_identity:sanstache }) = 0;

-- test: unicité : même arguments dans la durée d'unicité → l'exécution existante (duplicate)
-- en tant que: sanstache
{
    LET $a = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge" });
    LET $b = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge" });
    LET $c = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge", unique_key: "lot-2" });
    LET $d = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge", unique_key: "lot-2" });
    UPDATE passe:e SET id_purge = $a.data.id;
    RETURN !$a.data.duplicate AND $a.data.unique_key = fn::security_hash_object({}, "sha256").hash
        AND $b.data.duplicate AND $b.data.id = $a.data.id
        AND !$c.data.duplicate AND $c.data.unique_key = "lot-2" AND $d.data.duplicate AND $d.data.id = $c.data.id
        AND $a.data.queue = scheduler_queue:maintenance AND $a.data.priority = 7;
};

-- test: une exécution terminée ne bloque plus l'unicité
-- en tant que: operateur
{
    LET $cancel = fn::scheduler_run_cancel({ run: <string> (SELECT VALUE id_purge FROM ONLY passe:e), reason: "Inutile" });
    RETURN $cancel.data.state = "cancelled" AND $cancel.data.cancel_reason = "Inutile" AND $cancel.data.finished_at IS NOT NONE;
};

-- test: après annulation, une nouvelle exécution de même clé est créée
-- en tant que: sanstache
RETURN !fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge" }).data.duplicate;

-- test: limite d'exécutions en attente par organisation
{
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", max_pending_runs: 2 });
    LET $r = fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.rapport", args: { format: "pdf" } });
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", clear: ["max_pending_runs"] });
    RETURN $r.error.code = "SCHEDULER_LIMIT_REACHED" AND $r.error.details.limit = "max_pending_runs";
};

-- test: lecture et liste par un lecteur ; le jeton du bail n'est pas lisible
-- en tant que: lecteur
{
    LET $id = <string> (SELECT VALUE id_run FROM ONLY passe:e);
    LET $g = fn::scheduler_run_get({ run: $id });
    RETURN $g.data.args = { format: "csv" } AND !object::keys($g.data).any(|$k| $k = "lease")
        AND fn::scheduler_run_list({ tenant: "auth_organization:alpha" }).data.total = 6
        AND fn::scheduler_run_list({ tenant: "auth_organization:alpha", task: "essai.purge" }).data.total = 3
        AND fn::scheduler_run_list({ tenant: "auth_organization:alpha", state: "cancelled" }).data.total = 1
        AND fn::scheduler_run_list({ tenant: "auth_organization:alpha", since: time::now() + 12h, limit: 1 }).data.total = 2
        AND fn::scheduler_run_get({ run: "scheduler_run:inconnue" }).error.code = "SCHEDULER_RUN_NOT_FOUND"
        AND fn::scheduler_run_cancel({ run: $id }).error.code = "SCHEDULER_PERMISSION_DENIED"
        AND fn::scheduler_run_retry({ run: $id }).error.code = "SCHEDULER_PERMISSION_DENIED";
};

-- test: organisations isolées
-- en tant que: autre
{
    LET $id = <string> (SELECT VALUE id_run FROM ONLY passe:e);
    RETURN fn::scheduler_run_get({ run: $id }).error.code = "SCHEDULER_RUN_NOT_FOUND"
        AND fn::scheduler_run_cancel({ run: $id }).error.code = "SCHEDULER_RUN_NOT_FOUND"
        AND fn::scheduler_run_list({ tenant: "auth_organization:alpha" }).error.code = "SCHEDULER_PERMISSION_DENIED"
        AND fn::scheduler_run_list({ tenant: "auth_organization:beta" }).data.total = 0
        AND array::len(UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET cancel_reason = "x") = 0;
};

-- test: champs figés : tâche, arguments, date prévue, origine
-- en tant que: operateur
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET scheduled_for = time::now();

-- test: arguments figés
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET args = { format: "pdf" };

-- test: origine figée
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET origin = "schedule";

-- test: une personne ne réserve pas une exécution
-- en tant que: operateur
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET state = "running", attempt = 1, lease = <string> rand::uuid::v7(), locked_until = time::now() + 1h, started_at = time::now();

-- test: transition interdite : queued → completed
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET state = "completed", finished_at = time::now();

-- test: une réservation sans bail nouveau est refusée, même par le moteur
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET state = "running", attempt = 1, locked_until = time::now() + 1h, started_at = time::now();

-- test: une exécution différée ne naît qu'en file
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "pdf" }, queue: scheduler_queue:default, priority: 5, origin: "enqueue", scheduled_for: time::now(), available_at: time::now(), state: "running", max_attempts: 3 };

-- test: une exécution n'utilise pas une autre file que celle de sa tâche
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "pdf" }, queue: scheduler_queue:maintenance, priority: 5, origin: "enqueue", scheduled_for: time::now(), available_at: time::now(), state: "queued", max_attempts: 3 };

-- test: A7 — annulation directe sans scheduler.run.manage refusée par la garde
-- en tant que: sanstache
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET state = "cancelled", finished_at = time::now(), cancel_reason = "direct";

-- test: annulation d'une exécution en file, puis état terminal figé
-- en tant que: operateur
{
    LET $id = <string> (SELECT VALUE id_run FROM ONLY passe:e);
    LET $c = fn::scheduler_run_cancel({ run: $id });
    RETURN $c.data.state = "cancelled" AND fn::scheduler_run_cancel({ run: $id }).error.code = "SCHEDULER_RUN_STATE_INVALID";
};

-- test: un état terminal ne change plus
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
UPDATE (SELECT VALUE id_run FROM ONLY passe:e) SET state = "queued", finished_at = NONE;

-- test: une exécution non terminée ne se supprime pas
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
DELETE scheduler_run WHERE state = "queued";

-- test: A3 / Y1 — relance sans la permission propre de la tâche refusée, aussi en création directe (filtrée)
-- en tant que: operateursanstache
{
    LET $origin = (SELECT VALUE id_run FROM ONLY passe:e);
    LET $direct = (CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "csv" }, queue: scheduler_queue:default, priority: 1, origin: "retry", retry_of: $origin, scheduled_for: time::now(), available_at: time::now(), state: "queued", max_attempts: 3, created_by: auth_identity:operateursanstache });
    RETURN array::len($direct) = 0 AND fn::scheduler_run_retry({ run: <string> $origin }).error.code = "SCHEDULER_PERMISSION_DENIED";
};

-- test: A1 — création directe d'une relance sans exécution d'origine refusée par la garde
-- en tant que: operateur
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "pdf", note: "injecte" }, queue: scheduler_queue:default, priority: 0, origin: "retry", scheduled_for: time::now(), available_at: time::now(), state: "queued", max_attempts: 3, created_by: auth_identity:operateur };

-- test: A1 — création directe d'une relance avec d'autres arguments que l'exécution d'origine refusée
-- en tant que: operateur
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "pdf", note: "injecte" }, queue: scheduler_queue:default, priority: 0, origin: "retry", retry_of: (SELECT VALUE id_run FROM ONLY passe:e), scheduled_for: time::now(), available_at: time::now(), state: "queued", max_attempts: 3, created_by: auth_identity:operateur };

-- test: A1 — une exécution d'un autre type ne porte pas retry_of
-- en tant que: admin
-- attendu-erreur: SCHEDULER_RUN_STATE_INVALID
CREATE scheduler_run CONTENT { tenant: auth_organization:alpha, task: scheduler_task:⟨essai.rapport⟩, args: { format: "csv" }, queue: scheduler_queue:default, priority: 0, origin: "enqueue", retry_of: (SELECT VALUE id_run FROM ONLY passe:e), scheduled_for: time::now(), available_at: time::now(), state: "queued", max_attempts: 3, created_by: auth_identity:admin };

-- test: relance d'une exécution annulée : nouvelle exécution immédiate, mêmes arguments
-- en tant que: operateur
{
    LET $id = <string> (SELECT VALUE id_run FROM ONLY passe:e);
    LET $r = fn::scheduler_run_retry({ run: $id });
    RETURN $r.ok AND $r.data.origin = "retry" AND $r.data.state = "queued" AND $r.data.args = { format: "csv" } AND $r.data.attempt = 0
        AND <string> $r.data.retry_of = $id AND $r.data.created_by = auth_identity:operateur AND $r.data.priority = 1
        AND fn::scheduler_run_retry({ run: <string> $r.data.id }).error.code = "SCHEDULER_RUN_STATE_INVALID";
};

-- test: relance refusée pour une tâche désactivée
{
    fn::scheduler_task_set_state({ task: "essai.rapport", state: "disabled" });
    LET $r = fn::scheduler_run_retry({ run: (SELECT VALUE id_run FROM ONLY passe:e) });
    fn::scheduler_task_set_state({ task: "essai.rapport", state: "active" });
    RETURN $r.error.code = "SCHEDULER_TASK_DISABLED";
};

-- test: exécutions différées, annulations et relances journalisées, jamais d'arguments
RETURN (SELECT VALUE action FROM scheduler_audit WHERE string::starts_with(action, "run.") ORDER BY created_at) = ["run.enqueue", "run.enqueue", "run.enqueue", "run.enqueue", "run.enqueue", "run.cancel", "run.enqueue", "run.cancel", "run.retry"]
    AND !string::contains(<string> (SELECT details FROM scheduler_audit), "csv");

-- test: forme texte d'un identifiant d'exécution : clé simple et identifiant composé convertis, sans lecture
-- en tant que: membre
{
    LET $simple = fn::scheduler_run_ref({ run: "scheduler_run:abc" });
    LET $composite = fn::scheduler_run_ref({ run: "scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z']" });
    RETURN $simple.ok AND $simple.data = scheduler_run:abc AND type::is_record($simple.data, "scheduler_run")
        AND $composite.ok AND $composite.data = scheduler_run:[scheduler_schedule:x, d"2026-01-01T00:00:00Z"];
};

-- test: forme texte refusée : autre table, chaîne illisible, absente, champ inconnu
RETURN fn::scheduler_run_ref({ run: "scheduler_schedule:abc" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({ run: "scheduler_schedule:abc" }).error.details.fields.run = ["CORE_VALIDATION_NOT_ALLOWED"]
    AND fn::scheduler_run_ref({ run: "pas un identifiant" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({}).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({ run: scheduler_run:abc }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({ run: "scheduler_run:abc", autre: 1 }).error.code = "SCHEDULER_INVALID_PARAMETERS";

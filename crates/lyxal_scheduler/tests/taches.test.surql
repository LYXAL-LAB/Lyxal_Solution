-- lyxal-test: assertions
-- Tâches : déclaration par seed rejouable (session système), forme contrôlée (nom, module, cible
-- du même module, permission, tentatives, file, schéma des arguments), écriture refusée hors
-- session système, seul l'état change, activation et désactivation, lecture. Files : liste,
-- pause et reprise, compteur de places protégé.
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

-- test: tâches d'essai déclarées avec leurs valeurs par défaut
RETURN (SELECT VALUE record::id(id) FROM scheduler_task ORDER BY id) == ["essai.global", "essai.purge", "essai.rapport"]
    AND (SELECT VALUE [queue, priority, timeout, state, scope] FROM ONLY scheduler_task:⟨essai.rapport⟩) == [scheduler_queue:default, 5, 1m, "active", "organization"];

-- test: rejeu du seed d'une tâche sans doublon ni écrasement
{
    IF !record::exists(scheduler_task:⟨essai.purge⟩) THEN (
        CREATE scheduler_task:⟨essai.purge⟩ CONTENT { module: "lyxal_essai", executor: "function", target: "essai_autre" }
    ) END;
    RETURN (SELECT VALUE target FROM ONLY scheduler_task:⟨essai.purge⟩) = "essai_purge" AND count(SELECT * FROM scheduler_task) = 3;
};

-- test: nom de tâche hors format refusé
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨Essai.Rapport⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.rapport" };

-- test: module qui ne correspond pas au nom refusé
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.autre⟩ CONTENT { module: "lyxal_autre", executor: "handler", target: "essai.autre" };

-- test: fonction d'un autre module refusée
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.vol⟩ CONTENT { module: "lyxal_essai", executor: "function", target: "auth_purge" };

-- test: événement d'un autre module refusé
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.relance⟩ CONTENT { module: "lyxal_essai", executor: "event", target: "notification.digest.send" };

-- test: handler d'un autre module refusé
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.h⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "auth.h" };

-- test: handler dont la cible n'est pas le nom de la tâche refusé (le handler est inscrit et retrouvé par ce nom)
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.daily⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.process" };

-- test: permission inexistante refusée
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.p⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.p", permission: "essai.inexistante" };

-- test: politique de tentatives hors bornes refusée (11 tentatives)
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.r⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.r", retry: { max_attempts: 11, strategy: "fixed", initial_delay: 1s, max_delay: 1s } };

-- test: politique de tentatives non normalisée refusée (stratégie en majuscules)
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨essai.r⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.r", retry: { max_attempts: 2, strategy: "FIXED", initial_delay: 1s, max_delay: 1s } };

-- test: file inexistante refusée
-- attendu-erreur: SCHEDULER_QUEUE_NOT_FOUND
CREATE scheduler_task:⟨essai.q⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.q", queue: scheduler_queue:inconnue };

-- test: schéma d'arguments faux refusé par le moteur du Core
-- attendu-erreur: CORE_INVALID_ARGUMENT
CREATE scheduler_task:⟨essai.s⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.s", args_schema: { fields: {} } };

-- test: une personne ne déclare, ne modifie ni ne supprime une tâche (écritures filtrées)
-- en tant que: admin
{
    LET $c = (CREATE scheduler_task:⟨essai.pirate⟩ CONTENT { module: "lyxal_essai", executor: "handler", target: "essai.pirate" });
    LET $u = (UPDATE scheduler_task:⟨essai.rapport⟩ SET state = "disabled");
    LET $d = (DELETE scheduler_task:⟨essai.rapport⟩ RETURN BEFORE);
    RETURN array::len($c) = 0 AND array::len($u) = 0 AND array::len($d) = 0;
};

-- test: le compte du moteur non plus
-- en tant que: worker
{
    LET $u = (UPDATE scheduler_task:⟨essai.rapport⟩ SET state = "disabled");
    RETURN array::len($u) = 0 AND (SELECT VALUE state FROM ONLY scheduler_task:⟨essai.rapport⟩) = "active";
};

-- test: même la session système ne change que l'état
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE scheduler_task:⟨essai.rapport⟩ SET target = "essai.autre";

-- test: lecture des tâches par un lecteur : liste filtrée et fiche
-- en tant que: lecteur
{
    LET $all = fn::scheduler_task_list({});
    LET $one = fn::scheduler_task_list({ module: "lyxal_essai", state: "active", limit: 1, start: 1 });
    LET $get = fn::scheduler_task_get({ task: "essai.purge" });
    RETURN $all.data.total = 3 AND $one.data.total = 3 AND array::len($one.data.items) = 1 AND record::id($one.data.items[0].id) = "essai.purge"
        AND $get.data.executor = "function" AND $get.data.unique_for = 1h
        AND fn::scheduler_task_get({ task: "essai.inconnue" }).error.code = "SCHEDULER_TASK_NOT_FOUND"
        AND fn::scheduler_task_get({ task: "pas un nom" }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: une personne ne change pas l'état d'une tâche
-- en tant que: admin
RETURN fn::scheduler_task_set_state({ task: "essai.rapport", state: "disabled" }).error.code = "SCHEDULER_PERMISSION_DENIED";

-- test: désactivation par la session système ; tâche inconnue ; état inconnu
RETURN fn::scheduler_task_set_state({ task: "essai.purge", state: "disabled" }).data.state = "disabled"
    AND fn::scheduler_task_set_state({ task: "essai.zzz", state: "active" }).error.code = "SCHEDULER_TASK_NOT_FOUND"
    AND fn::scheduler_task_set_state({ task: "essai.purge", state: "supprime" }).error.code = "SCHEDULER_INVALID_PARAMETERS";

-- test: tâche désactivée : ni planification ni exécution différée
-- en tant que: admin
RETURN fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "purge", task: "essai.purge", spec: { every: [1h] } }).error.code = "SCHEDULER_TASK_DISABLED"
    AND fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.purge" }).error.code = "SCHEDULER_TASK_DISABLED"
    AND fn::scheduler_task_list({ state: "disabled" }).data.total = 1;

-- test: réactivation ; changements d'état journalisés
{
    fn::scheduler_task_set_state({ task: "essai.purge", state: "active" });
    RETURN (SELECT VALUE action FROM scheduler_audit WHERE action IN ["task.disable", "task.enable"] ORDER BY created_at) = ["task.disable", "task.enable"]
        AND (SELECT VALUE state FROM ONLY scheduler_task:⟨essai.purge⟩) = "active";
};

-- test: tâche d'installation refusée pour une organisation, et inversement
-- en tant que: admin
RETURN fn::scheduler_run_enqueue({ tenant: "auth_organization:alpha", task: "essai.global" }).error.code = "SCHEDULER_INVALID_PARAMETERS";

-- test: tâche d'organisation refusée pour l'installation
-- en tant que: plateforme
RETURN fn::scheduler_run_enqueue({ task: "essai.purge" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_enqueue({ task: "essai.global" }).ok;

-- test: files vues par un lecteur ; seule l'installation les met en pause
-- en tant que: lecteur
{
    LET $l = fn::scheduler_queue_list({});
    RETURN $l.ok AND $l.data.id = [scheduler_queue:default, scheduler_queue:maintenance] AND $l.data[0].slots = []
        AND fn::scheduler_queue_pause({ queue: "default" }).error.code = "SCHEDULER_PERMISSION_DENIED";
};

-- test: pause et reprise d'une file par la plateforme ; file inconnue
-- en tant que: plateforme
{
    LET $p = fn::scheduler_queue_pause({ queue: "maintenance", reason: "Migration" });
    LET $double = fn::scheduler_queue_list({}).data[1].paused;
    LET $r = fn::scheduler_queue_resume({ queue: "maintenance" });
    RETURN $p.data.paused AND $p.data.paused_reason = "Migration" AND $double AND !$r.data.paused AND $r.data.paused_reason IS NONE
        AND fn::scheduler_queue_pause({ queue: "inconnue" }).error.code = "SCHEDULER_QUEUE_NOT_FOUND"
        AND fn::scheduler_queue_resume({ queue: "inconnue" }).error.code = "SCHEDULER_QUEUE_NOT_FOUND"
        AND fn::scheduler_queue_pause({ queue: "Pas Un Nom" }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: pauses de file journalisées et publiées
RETURN (SELECT VALUE action FROM scheduler_audit WHERE string::starts_with(action, "queue.") ORDER BY created_at) = ["queue.pause", "queue.resume"]
    AND (SELECT VALUE event_type FROM event_outbox WHERE string::starts_with(event_type, "scheduler.queue.") ORDER BY created_at) = ["scheduler.queue.paused", "scheduler.queue.resumed"];

-- test: compteur de places protégé : la plateforme ne l'écrit pas
-- en tant que: plateforme
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE scheduler_queue:default SET running = 1;

-- test: concurrence : session système seulement
-- en tant que: plateforme
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE scheduler_queue:default SET concurrency = 50;

-- test: le compteur ne dépasse jamais la concurrence ni ne devient négatif (assertion du schéma)
RETURN string::contains((INFO FOR TABLE scheduler_queue).fields.running, "$value >= 0 AND $value <= $this.concurrency");

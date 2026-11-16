-- lyxal-test: assertions
-- Planifications : création (règles de dates, arguments contrôlés par le schéma de la tâche,
-- permission propre de la tâche, limite par organisation, unicité du nom), modification qui
-- remet la prochaine échéance à calculer, invalide redevenue active, pause, reprise, lecture,
-- liste, suppression (exécutions en attente annulées, historique gardé), gardes des champs du
-- moteur et des transitions, déclenchement immédiat, demande de rejeu.
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

-- test: création par un rédacteur ; échéance à calculer ; valeurs par défaut
-- en tant que: redacteur
{
    LET $s = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "rapport-quotidien", task: "essai.rapport", args: { format: "pdf" },
        spec: { cron: ["0 6 * * 1-5"], timezone: "Europe/Paris", jitter: 30s }, catchup: "all", remaining: 5 });
    CREATE passe:s SET id_schedule = $s.data.id;
    RETURN $s.ok AND $s.data.next_fire_at IS NONE AND $s.data.state = "active" AND $s.data.overlap = "skip" AND !$s.data.paused
        AND $s.data.spec = { cron: ["0 6 * * 1-5"], every: [], exclude_cron: [], timezone: "Europe/Paris", jitter: 30s }
        AND $s.data.created_by = auth_identity:redacteur AND $s.data.remaining = 5 AND $s.data.recent_runs = [];
};

-- test: règles de dates fausses refusées
-- en tant que: redacteur
RETURN [
    {},
    { cron: [] },
    { cron: [""] },
    { cron: ["* * * * *"], timezone: "" },
    { every: [500ms] },
    { at: "demain" },
    { every: [1h], start_at: d"2027-01-02T00:00:00Z", end_at: d"2027-01-01T00:00:00Z" },
    { every: [1h], jitter: 2h },
    { every: [1h], inconnu: 1 },
    { cron: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"] }
].all(|$spec| fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "faux", task: "essai.rapport", args: { format: "pdf" }, spec: $spec }).error.code = "SCHEDULER_SPEC_INVALID");

-- test: arguments hors schéma refusés (valeur, clé inconnue, absents, trop gros)
-- en tant que: redacteur
RETURN [
    { format: "docx" },
    { format: "pdf", inconnu: 1 },
    {}
].all(|$args| fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "faux", task: "essai.rapport", args: $args, spec: { every: [1h] } }).error.code = "SCHEDULER_ARGS_INVALID")
    AND fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "faux", task: "essai.purge", args: { x: 1 }, spec: { every: [1h] } }).error.code = "SCHEDULER_ARGS_INVALID";

-- test: taille des arguments limitée par les réglages
{
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", max_args_bytes: 256 });
    LET $big = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "gros", task: "essai.rapport", args: { format: "pdf", note: string::repeat("x", 300) }, spec: { every: [1h] } });
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", clear: ["max_args_bytes"] });
    RETURN $big.error.code = "SCHEDULER_ARGS_INVALID" AND $big.error.details.fields.args[0].details.max_bytes = 256;
};

-- test: arguments hors schéma refusés aussi pour une écriture directe
-- attendu-erreur: SCHEDULER_ARGS_INVALID
CREATE scheduler_schedule CONTENT { tenant: auth_organization:alpha, name: "direct", task: scheduler_task:⟨essai.rapport⟩, args: { format: "docx" }, spec: { every: [1h] } };

-- test: permission propre de la tâche exigée ; une tâche sans permission propre reste permise
-- en tant que: sanstache
{
    LET $refus = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "vol", task: "essai.rapport", args: { format: "pdf" }, spec: { every: [1h] } });
    LET $ok = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "purge", task: "essai.purge", spec: { every: [1d] } });
    UPDATE passe:s SET id_purge = $ok.data.id;
    RETURN $refus.error.code = "SCHEDULER_PERMISSION_DENIED" AND $ok.ok;
};

-- test: création directe sans la permission de la tâche filtrée par la table
-- en tant que: sanstache
RETURN array::len(CREATE scheduler_schedule CONTENT { tenant: auth_organization:alpha, name: "direct", task: scheduler_task:⟨essai.rapport⟩, args: { format: "pdf" }, spec: { every: [1h] }, created_by: auth_identity:sanstache }) = 0;

-- test: nom unique dans la portée ; tâche inconnue ; organisation d'un autre
-- en tant que: redacteur
RETURN fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "rapport-quotidien", task: "essai.rapport", args: { format: "csv" }, spec: { every: [1h] } }).error.code = "SCHEDULER_SCHEDULE_EXISTS"
    AND fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "x", task: "essai.inconnue", spec: { every: [1h] } }).error.code = "SCHEDULER_TASK_NOT_FOUND"
    AND fn::scheduler_schedule_create({ tenant: "auth_organization:beta", name: "x", task: "essai.purge", spec: { every: [1h] } }).error.code = "SCHEDULER_PERMISSION_DENIED"
    AND fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "x", task: "essai.purge", spec: { every: [1h] }, overlap: "parfois" }).error.code = "SCHEDULER_INVALID_PARAMETERS";

-- test: limite du nombre de planifications par organisation
{
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", max_schedules: 2 });
    LET $r = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "trop", task: "essai.purge", spec: { every: [1h] } });
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", clear: ["max_schedules"] });
    RETURN $r.error.code = "SCHEDULER_LIMIT_REACHED" AND $r.error.details.max = 2;
};

-- test: limite vérifiée aussi pour une écriture directe
-- attendu-erreur: SCHEDULER_LIMIT_REACHED
{
    UPSERT scheduler_settings:alpha SET tenant = auth_organization:alpha, max_schedules = 2;
    CREATE scheduler_schedule CONTENT { tenant: auth_organization:alpha, name: "trop", task: scheduler_task:⟨essai.purge⟩, spec: { every: [1h] } };
};

-- préparation: retour à la limite par défaut ; le moteur calcule l'échéance
{
    UPDATE scheduler_settings:alpha SET max_schedules = NONE;
    fn::scheduler_schedule_next_set({ node: "n1", generation: 1, schedule: (SELECT VALUE id_schedule FROM ONLY passe:s), next_fire_at: time::now() + 1h });
};

-- test: lecture, liste filtrée par un lecteur
-- en tant que: lecteur
{
    LET $id = <string> (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $get = fn::scheduler_schedule_get({ schedule: $id });
    RETURN $get.data.name = "rapport-quotidien" AND $get.data.next_fire_at IS NOT NONE
        AND fn::scheduler_schedule_list({ tenant: "auth_organization:alpha" }).data.total = 2
        AND fn::scheduler_schedule_list({ tenant: "auth_organization:alpha", task: "essai.purge" }).data.items[0].name = "purge"
        AND fn::scheduler_schedule_list({ tenant: "auth_organization:alpha", state: "completed" }).data.total = 0
        AND fn::scheduler_schedule_list({ tenant: "auth_organization:alpha", paused: false, limit: 1, start: 1 }).data.items[0].name = "rapport-quotidien"
        AND fn::scheduler_schedule_get({ schedule: "scheduler_schedule:inconnue" }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND"
        AND fn::scheduler_schedule_update({ schedule: $id, overlap: "allow_all" }).error.code = "SCHEDULER_PERMISSION_DENIED";
};

-- test: modification des arguments seuls : l'échéance reste ; modification des règles : à recalculer
-- en tant que: redacteur
{
    LET $id = <string> (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $a = fn::scheduler_schedule_update({ schedule: $id, args: { format: "csv" }, overlap: "buffer_one", catchup_window: 2h });
    LET $b = fn::scheduler_schedule_update({ schedule: $id, spec: { every: [2h] }, clear: ["remaining"] });
    RETURN $a.ok AND $a.data.args = { format: "csv" } AND $a.data.overlap = "buffer_one" AND $a.data.next_fire_at IS NOT NONE
        AND $b.ok AND $b.data.next_fire_at IS NONE AND $b.data.spec.every = [2h] AND $b.data.remaining IS NONE AND $b.data.catchup_window = 2h
        AND fn::scheduler_schedule_update({ schedule: $id, args: { format: "docx" } }).error.code = "SCHEDULER_ARGS_INVALID"
        AND fn::scheduler_schedule_update({ schedule: $id, spec: { cron: [] } }).error.code = "SCHEDULER_SPEC_INVALID";
};

-- test: sans la permission propre de la tâche : ni modification ni reprise (Y1), mais pause permise
-- en tant que: sanstache
{
    LET $id = <string> (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $u = fn::scheduler_schedule_update({ schedule: $id, args: { format: "pdf" } });
    LET $p = fn::scheduler_schedule_pause({ schedule: $id, reason: "Congés" });
    LET $r = fn::scheduler_schedule_resume({ schedule: $id });
    RETURN $u.error.code = "SCHEDULER_PERMISSION_DENIED" AND $p.data.paused AND $p.data.paused_reason = "Congés"
        AND $r.error.code = "SCHEDULER_PERMISSION_DENIED";
};

-- test: A3 — reprise directe sans la permission de la tâche refusée par la garde (la reprise fait exécuter la tâche)
-- en tant que: sanstache
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE id_schedule FROM ONLY passe:s) SET paused = false, paused_reason = NONE;

-- test: reprise par une personne qui a la permission de la tâche
-- en tant que: redacteur
{
    LET $r = fn::scheduler_schedule_resume({ schedule: <string> (SELECT VALUE id_schedule FROM ONLY passe:s) });
    RETURN $r.ok AND !$r.data.paused AND $r.data.paused_reason IS NONE;
};

-- test: modification directe sans la permission de la tâche refusée par la garde
-- en tant que: sanstache
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE id_schedule FROM ONLY passe:s) SET overlap = "allow_all";

-- test: pause qui laisse une échéance calculée refusée
-- attendu-erreur: SCHEDULER_SCHEDULE_STATE_INVALID
UPDATE (SELECT VALUE id_schedule FROM ONLY passe:s) SET paused = true, next_fire_at = time::now() + 1h;

-- test: double pause et reprise sans pause refusées
-- en tant que: redacteur
{
    LET $id = <string> (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $r = fn::scheduler_schedule_resume({ schedule: $id });
    fn::scheduler_schedule_pause({ schedule: $id });
    LET $p = fn::scheduler_schedule_pause({ schedule: $id });
    fn::scheduler_schedule_resume({ schedule: $id });
    RETURN $r.error.code = "SCHEDULER_SCHEDULE_STATE_INVALID" AND $p.error.code = "SCHEDULER_SCHEDULE_STATE_INVALID";
};

-- test: une personne n'écrit pas la prochaine échéance
-- en tant que: redacteur
-- attendu-erreur: SCHEDULER_SCHEDULE_STATE_INVALID
UPDATE (SELECT VALUE id_schedule FROM ONLY passe:s) SET next_fire_at = time::now() + 1h;

-- test: une personne n'écrit ni la dernière exécution ni l'état
-- en tant que: redacteur
-- attendu-erreur: SCHEDULER_SCHEDULE_STATE_INVALID
UPDATE (SELECT VALUE id_schedule FROM ONLY passe:s) SET state = "completed";

-- test: auteur figé
-- en tant que: redacteur
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE id_schedule FROM ONLY passe:s) SET created_by = auth_identity:admin;

-- test: planification déclarée invalide par le moteur, puis corrigée : de nouveau active
{
    LET $id = (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $inv = fn::scheduler_schedule_next_set({ node: "n1", generation: 1, schedule: $id, invalid_reason: "Expression cron refusée" });
    LET $fix = fn::scheduler_schedule_update({ schedule: $id, spec: { cron: ["0 7 * * *"] } });
    RETURN $inv.data.state = "invalid" AND $inv.data.invalid_reason = "Expression cron refusée" AND $inv.data.next_fire_at IS NONE
        AND $fix.data.state = "active" AND $fix.data.invalid_reason IS NONE
        AND fn::scheduler_schedule_next_set({ node: "n1", generation: 1, schedule: $id, next_fire_at: time::now() + 1h, invalid_reason: "x" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_next_set({ node: "n1", generation: 1, schedule: $id }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: déclenchement immédiat par le rédacteur
-- en tant que: redacteur
{
    LET $t = fn::scheduler_schedule_trigger({ schedule: <string> (SELECT VALUE id_schedule FROM ONLY passe:s) });
    UPDATE passe:s SET id_trigger = $t.data.id;
    RETURN $t.ok AND $t.data.origin = "trigger" AND $t.data.state = "queued" AND $t.data.args = { format: "csv" } AND $t.data.created_by = auth_identity:redacteur;
};

-- test: déclenchement sans la permission de la tâche refusé
-- en tant que: sanstache
RETURN fn::scheduler_schedule_trigger({ schedule: <string> (SELECT VALUE id_schedule FROM ONLY passe:s) }).error.code = "SCHEDULER_PERMISSION_DENIED";

-- test: demande de rejeu : période passée, un seul rejeu en cours, bornes
-- en tant que: redacteur
{
    LET $id = <string> (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $b = fn::scheduler_schedule_backfill({ schedule: $id, from: time::now() - 3d, to: time::now() - 1d, overlap: "allow_all" });
    UPDATE passe:s SET id_backfill = $b.data.id;
    RETURN $b.ok AND $b.data.state = "pending" AND $b.data.requested_by = auth_identity:redacteur
        AND fn::scheduler_schedule_backfill({ schedule: $id, from: time::now() - 2d, to: time::now() - 1h }).error.code = "SCHEDULER_BACKFILL_RUNNING"
        AND fn::scheduler_schedule_backfill({ schedule: $id, from: time::now() - 1d, to: time::now() - 2d }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_backfill({ schedule: $id, from: time::now() - 400d, to: time::now() - 1d }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND fn::scheduler_schedule_backfill({ schedule: $id, from: time::now() - 1d, to: time::now() + 1d }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: rejeu direct en double refusé
-- attendu-erreur: SCHEDULER_BACKFILL_RUNNING
CREATE scheduler_backfill CONTENT { schedule: (SELECT VALUE id_schedule FROM ONLY passe:s), tenant: auth_organization:alpha, from: time::now() - 2d, to: time::now() - 1d };

-- test: rejeu sans la permission de la tâche refusé
-- en tant que: sanstache
RETURN fn::scheduler_schedule_backfill({ schedule: <string> (SELECT VALUE id_schedule FROM ONLY passe:s), from: time::now() - 2d, to: time::now() - 1d }).error.code = "SCHEDULER_PERMISSION_DENIED";

-- test: suppression : exécution en attente annulée, historique gardé, rejeu supprimé
-- en tant que: sanstache
{
    LET $id = <string> (SELECT VALUE id_schedule FROM ONLY passe:s);
    LET $d = fn::scheduler_schedule_delete({ schedule: $id });
    LET $run = (SELECT state, cancel_reason FROM ONLY (SELECT VALUE id_trigger FROM ONLY passe:s));
    RETURN $d.data.deleted = $id AND $run.state = "cancelled" AND $run.cancel_reason = "schedule_deleted"
        AND count(SELECT * FROM scheduler_backfill) = 0
        AND fn::scheduler_schedule_get({ schedule: $id }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND"
        AND fn::scheduler_schedule_delete({ schedule: $id }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND";
};

-- test: une planification d'installation par la plateforme, invisible d'une organisation
-- en tant que: plateforme
{
    LET $s = fn::scheduler_schedule_create({ name: "tic", task: "essai.global", spec: { every: [1m] } });
    UPDATE passe:s SET id_global = $s.data.id;
    RETURN $s.ok AND $s.data.scope_key = "installation" AND fn::scheduler_schedule_list({}).data.total = 1
        AND fn::scheduler_schedule_create({ name: "x", task: "essai.purge", spec: { every: [1h] } }).error.code = "SCHEDULER_INVALID_PARAMETERS";
};

-- test: organisations isolées
-- en tant que: autre
RETURN fn::scheduler_schedule_get({ schedule: <string> (SELECT VALUE id_purge FROM ONLY passe:s) }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND"
    AND fn::scheduler_schedule_get({ schedule: <string> (SELECT VALUE id_global FROM ONLY passe:s) }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND"
    AND fn::scheduler_schedule_pause({ schedule: <string> (SELECT VALUE id_purge FROM ONLY passe:s) }).error.code = "SCHEDULER_SCHEDULE_NOT_FOUND"
    AND fn::scheduler_schedule_list({ tenant: "auth_organization:beta" }).data.total = 0
    AND array::len(UPDATE (SELECT VALUE id_purge FROM ONLY passe:s) SET overlap = "allow_all") = 0;

-- test: un lecteur ne supprime pas (écriture filtrée)
-- en tant que: lecteur
RETURN fn::scheduler_schedule_delete({ schedule: <string> (SELECT VALUE id_purge FROM ONLY passe:s) }).error.code = "SCHEDULER_PERMISSION_DENIED"
    AND array::len(DELETE (SELECT VALUE id_purge FROM ONLY passe:s) RETURN BEFORE) = 0;

-- test: contrôle des règles de dates sans écriture : mêmes règles de forme que l'écriture
-- en tant que: redacteur
RETURN fn::scheduler_spec_validate({ tenant: auth_organization:alpha, spec: { cron: ["0 9 * * *"] } }).data.spec.timezone = "UTC"
    AND fn::scheduler_spec_validate({ tenant: auth_organization:alpha, spec: { cron: ["0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *", "0 9 * * *"] } }).error.code = "SCHEDULER_SPEC_INVALID"
    AND fn::scheduler_spec_validate({ tenant: auth_organization:alpha, spec: {} }).error.code = "SCHEDULER_SPEC_INVALID";

-- test: contrôle des règles de dates refusé sans droit de lecture
-- en tant que: membre
RETURN fn::scheduler_spec_validate({ tenant: auth_organization:alpha, spec: { cron: ["0 9 * * *"] } }).error.code = "SCHEDULER_PERMISSION_DENIED";

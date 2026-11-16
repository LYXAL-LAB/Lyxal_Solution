-- lyxal-test: assertions
-- Clôture (lot 5) : droits renforcés et garde du moteur. Permission propre de la tâche pour un
-- rejeu de période, aussi en écriture directe (Y1) ; annulation réservée à scheduler.run.manage,
-- sauf les exécutions d'une planification supprimée (A7) ; déclenchement cancel_other ;
-- planification invalide ranimée seulement avec des règles nouvelles et réglages de
-- l'installation lisibles seulement avec une permission scheduler.* (A13) ; limite d'exécutions
-- en attente appliquée aux échéances et aux rejeux (A4) ; garde de génération du bail du
-- planificateur (Y2) ; cible d'une tâche (module installé, nom d'un autre module, Y3) ; forme
-- texte d'une exécution strictement canonique (A8, règle du Core) ; handlers servis par un
-- autre nœud pour la sonde (A11).
--
-- identité admin: {"id": "auth_session:admin", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "scheduler.run.manage", "scheduler.calendar.write", "scheduler.settings.manage", "essai.rapport.run"]}
-- identité sanstache: {"id": "auth_session:sanstache", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write"]}
-- identité redacteur: {"id": "auth_session:redacteur", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "essai.rapport.run"]}
-- identité operateur: {"id": "auth_session:operateur", "pv": 1, "permissions": ["scheduler.run.manage"]}
-- identité membre: {"id": "auth_session:membre", "pv": 1, "permissions": []}
-- identité autre: {"id": "auth_session:autre", "pv": 1, "permissions": ["scheduler.schedule.read", "scheduler.schedule.write", "scheduler.run.manage", "scheduler.settings.manage", "essai.rapport.run"]}
-- identité worker: {"id": "auth_session:worker", "pv": 1, "permissions": ["scheduler.worker"]}

-- préparation: organisations, identités, sessions, modules installés, bail du planificateur, tâche d'essai
{
    -- Fondation de l'hôte : modules connus du runtime (lyxal_essai, lyxal_pipeline et lyxal_pipeline_ingestion installés), bail du planificateur tenu par le nœud n1
    FOR $m IN ["lyxal_essai", "lyxal_pipeline", "lyxal_pipeline_ingestion"] {
        fn::runtime_module_upsert({ module_id: $m, name: $m });
        fn::runtime_release_register({ module_id: $m, version: "0.1.0", manifest_version: 1, status: "Installed" });
    };
    fn::runtime_lease_acquire({ kind: "leader", key: "scheduler", node_id: "n1", ttl_seconds: 86400 });
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["admin", "sanstache", "redacteur", "operateur", "membre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@lyxal.test" } };
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_permission:⟨essai.rapport.run⟩ CONTENT { code: "essai.rapport.run", module: "lyxal_essai", scope: "organization", description: { fr: "x", en: "x" } };
    CREATE scheduler_task:⟨essai.rapport⟩ CONTENT {
        module: "lyxal_essai", executor: "handler", target: "essai.rapport", permission: "essai.rapport.run",
        args_schema: { fields: { format: { pipeline: [{ rule: "enum", options: { allowed: ["pdf", "csv"], case_sensitive: true } }], required: true } }, unknown_keys: "reject" },
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 10s, max_delay: 30s }, timeout: 1m
    };
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: l'admin crée une planification en pause et une seconde planification avec une exécution en file
-- en tant que: admin
{
    LET $s = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "rapport", task: "essai.rapport", spec: { every: [1h] }, args: { format: "pdf" }, paused: true, paused_reason: "auteur" });
    LET $t = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "jetable", task: "essai.rapport", spec: { every: [1h] }, args: { format: "csv" }, overlap: "allow_all" });
    LET $r = fn::scheduler_schedule_trigger({ schedule: <string> $t.data.id });
    CREATE passe:a CONTENT { sched: $s.data.id, jetable: $t.data.id, run: $r.data.id, ok: $s.ok AND $t.ok AND $r.ok AND $r.data.state = "queued" };
};

-- test: préparation réussie
RETURN (SELECT VALUE ok FROM ONLY passe:a);

-- test: A2 — rejeu de période créé directement sans la permission propre de la tâche refusé par la garde
-- en tant que: sanstache
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
CREATE scheduler_backfill CONTENT { schedule: (SELECT VALUE sched FROM ONLY passe:a), tenant: auth_organization:alpha, from: time::now() - 3h, to: time::now() - 1m, requested_by: auth_identity:sanstache };

-- test: A2 — la fonction refuse le même rejeu ; avec la permission de la tâche, il est créé
-- en tant que: redacteur
{
    LET $id = <string> (SELECT VALUE sched FROM ONLY passe:a);
    LET $b = fn::scheduler_schedule_backfill({ schedule: $id, from: time::now() - 3h, to: time::now() - 1m });
    UPSERT passe:b CONTENT { backfill: $b.data.id };
    RETURN $b.ok AND $b.data.state = "pending";
};

-- test: A7 — déclenchement cancel_other sans scheduler.run.manage refusé (il annulerait les autres exécutions)
-- en tant que: redacteur
RETURN fn::scheduler_schedule_trigger({ schedule: <string> (SELECT VALUE jetable FROM ONLY passe:a), overlap: "cancel_other" }).error.code = "SCHEDULER_PERMISSION_DENIED";

-- test: A7 — demande d'annulation directe sans scheduler.run.manage refusée par la garde
-- en tant que: sanstache
-- attendu-erreur: SCHEDULER_PERMISSION_DENIED
UPDATE (SELECT VALUE run FROM ONLY passe:a) SET state = "cancelled", finished_at = time::now(), cancel_reason = "direct";

-- test: A7 — suppression d'une planification sans scheduler.run.manage : ses exécutions en attente sont annulées
-- en tant que: sanstache
{
    LET $d = fn::scheduler_schedule_delete({ schedule: <string> (SELECT VALUE jetable FROM ONLY passe:a) });
    RETURN $d.ok AND (SELECT VALUE [state, cancel_reason] FROM ONLY (SELECT VALUE run FROM ONLY passe:a)) = ["cancelled", "schedule_deleted"];
};

-- préparation: le moteur déclare la planification invalide
UPDATE ONLY (SELECT VALUE sched FROM ONLY passe:a) SET state = "invalid", invalid_reason = "min_interval: cron[0] (essai)", next_fire_at = NONE;

-- test: A13 — ranimer une planification invalide sans corriger ses règles est refusé
-- en tant que: admin
-- attendu-erreur: SCHEDULER_SCHEDULE_STATE_INVALID
UPDATE ONLY (SELECT VALUE sched FROM ONLY passe:a) SET state = "active", invalid_reason = NONE;

-- test: A13 — avec des règles nouvelles, elle redevient active (à recalculer)
-- en tant que: admin
{
    LET $u = fn::scheduler_schedule_update({ schedule: <string> (SELECT VALUE sched FROM ONLY passe:a), spec: { every: [2h] } });
    RETURN $u.ok AND $u.data.state = "active" AND $u.data.invalid_reason IS NONE AND $u.data.next_fire_at IS NONE;
};

-- préparation: réglages de l'installation enregistrés
fn::scheduler_settings_set({ max_args_bytes: 8192 });

-- test: A13 — réglages de l'installation illisibles sans aucune permission scheduler.*
-- en tant que: membre
RETURN array::len(SELECT * FROM scheduler_settings) = 0 AND fn::scheduler_can({ action: "member" }) = false;

-- test: A13 — réglages de l'installation lisibles avec une permission scheduler.* de l'organisation active (ils s'appliquent à elle)
-- en tant que: operateur
RETURN (SELECT VALUE scope_key FROM scheduler_settings) = ["installation"] AND fn::scheduler_settings_effective({ tenant: auth_organization:alpha }).max_args_bytes = 8192;

-- test: Y2 — garde de génération : autre génération, autre nœud ou compte de service refusés (SCHEDULER_LEADER_FENCED)
{
    LET $s = (SELECT VALUE sched FROM ONLY passe:a);
    LET $b = (SELECT VALUE backfill FROM ONLY passe:b);
    RETURN fn::scheduler_leader_held("n1", 1) AND !fn::scheduler_leader_held("n1", 2) AND !fn::scheduler_leader_held("n2", 1)
        AND fn::scheduler_leader_fenced({ node: "n1", generation: 1, language: "fr" }) IS NONE
        AND object::keys(fn::scheduler_leader_fields()) = ["generation", "node"]
        AND fn::scheduler_schedule_fire({ node: "n1", generation: 2, schedule: $s, fire_times: [] }).error.code = "SCHEDULER_LEADER_FENCED"
        AND fn::scheduler_schedule_next_set({ node: "n2", generation: 1, schedule: $s, next_fire_at: time::now() + 1h }).error.code = "SCHEDULER_LEADER_FENCED"
        AND fn::scheduler_backfill_fire({ node: "n2", generation: 1, backfill: $b, fire_times: [] }).error.code = "SCHEDULER_LEADER_FENCED"
        AND fn::scheduler_run_rescue({ node: "n1", generation: 2 }).error.code = "SCHEDULER_LEADER_FENCED"
        AND fn::scheduler_run_prune({ node: "n2", generation: 1 }).error.code = "SCHEDULER_LEADER_FENCED"
        AND fn::scheduler_schedule_fire({ schedule: $s, fire_times: [] }).error.code = "SCHEDULER_INVALID_PARAMETERS"
        AND (SELECT VALUE next_fire_at FROM ONLY $s) IS NONE;
};

-- test: Y2 — un compte de service scheduler.worker ne lit pas le bail : les fonctions du planificateur lui sont refusées
-- en tant que: worker
RETURN fn::scheduler_run_rescue({ node: "n1", generation: 1 }).error.code = "SCHEDULER_LEADER_FENCED"
    AND fn::scheduler_run_prune({ node: "n1", generation: 1 }).error.code = "SCHEDULER_LEADER_FENCED";

-- test: Y2 — bail libéré : le nœud qui le tenait n'écrit plus rien
{
    fn::runtime_lease_release({ kind: "leader", key: "scheduler", node_id: "n1", generation: 1 });
    LET $refused = fn::scheduler_run_rescue({ node: "n1", generation: 1 }).error.code = "SCHEDULER_LEADER_FENCED";
    LET $lease = fn::runtime_lease_acquire({ kind: "leader", key: "scheduler", node_id: "n1", ttl_seconds: 86400 });
    RETURN $refused AND $lease.data.lease.generation = 2 AND fn::scheduler_run_rescue({ node: "n1", generation: 2 }).ok;
};

-- préparation: limite de 5 exécutions en attente pour alpha ; planification cron à la minute, sans chevauchement
-- en tant que: admin
{
    fn::scheduler_settings_set({ tenant: "auth_organization:alpha", max_pending_runs: 5 });
    LET $s = fn::scheduler_schedule_create({ tenant: "auth_organization:alpha", name: "minute", task: "essai.rapport", spec: { cron: ["* * * * *"] }, args: { format: "pdf" }, overlap: "allow_all", catchup: "all", catchup_window: 2h });
    LET $b = fn::scheduler_schedule_backfill({ schedule: <string> $s.data.id, from: time::now() - 2h, to: time::now() - 1m });
    UPSERT passe:p CONTENT { s: $s.data.id, b: $b.data.id };
};

-- test: A4 — rejeu de période : pas plus d'exécutions que la limite d'attente, les autres ignorées et comptées
{
    LET $b = (SELECT VALUE b FROM ONLY passe:p);
    LET $base = time::now() - 50m;
    LET $times = array::map(<array> (0..40), |$i| { at: $base + duration::from_mins($i), available_at: $base + duration::from_mins($i) });
    LET $pending = fn::scheduler_pending_room(auth_organization:alpha);
    LET $r = fn::scheduler_backfill_fire({ node: "n1", generation: 2, backfill: $b, fire_times: $times });
    RETURN $r.ok AND array::len($r.data.runs) = $pending AND $r.data.limited = 40 - $pending
        AND fn::scheduler_pending_room(auth_organization:alpha) = 0
        AND count(SELECT VALUE id FROM scheduler_run WHERE scope_key = "alpha" AND state IN ["waiting", "queued", "retrying"]) = 5;
};

-- test: A4 — échéances : limite atteinte, aucune création, échéances ignorées et comptées
{
    LET $s = (SELECT VALUE s FROM ONLY passe:p);
    LET $base = time::now() - 40m;
    LET $times = array::map(<array> (0..30), |$i| { at: $base + duration::from_mins($i), available_at: $base + duration::from_mins($i) });
    LET $r = fn::scheduler_schedule_fire({ node: "n1", generation: 2, schedule: $s, fire_times: $times, next_fire_at: time::now() + 1m });
    RETURN $r.ok AND $r.data.runs = [] AND $r.data.limited = 30 AND $r.data.ignored = 30
        AND count(SELECT VALUE id FROM scheduler_run WHERE scope_key = "alpha" AND state IN ["waiting", "queued", "retrying"]) = 5;
};

-- test: Y3 — un module dont le nom est le début d'un autre module installé ne vise pas les fonctions de cet autre module
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨pipeline.vol⟩ CONTENT { module: "lyxal_pipeline", executor: "function", target: "pipeline_ingestion_publish", retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s } };

-- test: Y3 — un module qui n'est pas installé ne déclare aucune tâche (ici, viser les fonctions utils_* du Core)
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨utils.vol⟩ CONTENT { module: "lyxal_utils", executor: "function", target: "utils_engine_schema", retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s } };

-- test: Y3 — le module installé vise ses propres fonctions ; l'autre module, les siennes
{
    CREATE scheduler_task:⟨pipeline.relance⟩ CONTENT { module: "lyxal_pipeline", executor: "function", target: "pipeline_relance", retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s } };
    CREATE scheduler_task:⟨pipeline_ingestion.publication⟩ CONTENT { module: "lyxal_pipeline_ingestion", executor: "function", target: "pipeline_ingestion_publish", retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s } };
    RETURN record::exists(scheduler_task:⟨pipeline.relance⟩) AND record::exists(scheduler_task:⟨pipeline_ingestion.publication⟩);
};

-- test: Y3 — un événement d'un autre module installé dont le nom commence par celui du module est refusé
-- attendu-erreur: SCHEDULER_INVALID_PARAMETERS
CREATE scheduler_task:⟨pipeline.annonce⟩ CONTENT { module: "lyxal_pipeline", executor: "event", target: "pipeline_ingestion.lot.publie", retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s } };

-- test: A8 — forme texte d'une exécution : texte après l'identifiant et écriture non canonique refusés (règle surql_record_string du Core)
-- en tant que: membre
RETURN fn::scheduler_run_ref({ run: "scheduler_run:abc xyz" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({ run: "scheduler_run:abc; DELETE x" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({ run: "scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z'] trailing" }).error.code = "SCHEDULER_INVALID_PARAMETERS"
    AND fn::scheduler_run_ref({ run: "scheduler_run:[scheduler_schedule:x,d'2026-01-01T00:00:00Z']" }).error.details.fields.run[0] = "CORE_VALIDATION_FORMAT"
    AND fn::scheduler_run_ref({ run: "scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z']" }).data = scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z'];

-- test: A11 — handlers inscrits par un autre nœud, connus de la sonde
{
    fn::scheduler_run_claim({ queue: "maintenance", node: "n7", limit: 1, handlers: ["essai.rapport"] });
    LET $h = fn::scheduler_health({});
    RETURN $h.data.handler_tasks = ["essai.rapport"] AND $h.data.handlers_served = ["essai.rapport"]
        AND (SELECT VALUE handlers FROM ONLY scheduler_node:["n7", "maintenance"]) = ["essai.rapport"];
};

-- test: A11 — un nœud dont toutes les places sont occupées reste présent : ses battements rafraîchissent sa présence
{
    fn::scheduler_run_enqueue({ tenant: auth_organization:alpha, task: "essai.rapport", args: { format: "pdf" } });
    LET $claimed = fn::scheduler_run_claim({ queue: "default", node: "n8", limit: 1, handlers: ["essai.rapport"] }).data.items[0];
    LET $before = (SELECT VALUE seen_at FROM ONLY scheduler_node:["n8", "default"]);
    sleep(1100ms);
    LET $beat = fn::scheduler_run_heartbeat({ run: $claimed.id, lease: <string> $claimed.lease });
    LET $after = (SELECT VALUE seen_at FROM ONLY scheduler_node:["n8", "default"]);
    RETURN $beat.ok AND $before IS NOT NONE AND $after > $before + 1s;
};

-- test: A11 — un compte sans scheduler.worker ne lit ni n'écrit les exécuteurs
-- en tant que: admin
RETURN array::len(SELECT * FROM scheduler_node) = 0 AND array::len(CREATE scheduler_node:["x", "default"] CONTENT { node: "x", queue: scheduler_queue:default }) = 0;

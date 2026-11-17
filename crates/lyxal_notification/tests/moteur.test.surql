-- lyxal-test: assertions
-- Moteur d'étapes : enchaînement dans l'ordre, condition fausse, étape sautée par surcharge,
-- idempotence de l'avancement ; attente (durée, date des données, décalage, date passée, date
-- absente, trop longue) ; attentes confiées à lyxal_scheduler (exécution différée de la tâche
-- notification.run_resume) ; reprise (normale, rejouée, après annulation) ; tâches du
-- planificateur déclarées ; droits ; fonctions internes du moteur.
--
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }

-- préparation: organisation, sessions, parcours à étapes et gabarits
{
    CREATE notification_integration:relais CONTENT { key: "relais", channel: "email", provider: "smtp", name: "Relais", primary: true, settings: { from_address: "noreply@lyxal.test", host: "127.0.0.1", port: 2525, security: "local_plain" }, credentials_path: "notification/smtp/relais" };
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_identity:envoyeur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "envoyeur@lyxal.test" } };
    CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@lyxal.test" } };
    RELATE auth_identity:envoyeur->auth_member_of->auth_organization:alpha;
    CREATE auth_session:envoyeur CONTENT { identity: auth_identity:envoyeur, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_workflow:suite CONTENT { tenant: auth_organization:alpha, key: "suite", name: "Suite", status: "active", steps: [
        { key: "premier", type: "email" },
        { key: "pause", type: "delay", amount: 2, unit: "hours" },
        { key: "rappel", type: "email", condition: { field: "steps.premier.status", op: "eq", value: "completed" } }
    ] };
    CREATE notification_workflow:cond CONTENT { tenant: auth_organization:alpha, key: "cond", name: "Cond", status: "active", steps: [
        { key: "vip", type: "email", condition: { field: "payload.vip", op: "eq", value: true } },
        { key: "tous", type: "email" }
    ] };
    CREATE notification_workflow:rdv CONTENT { tenant: auth_organization:alpha, key: "rdv", name: "Rendez-vous", status: "active", steps: [
        { key: "veille", type: "delay", until: "payload.rdv", offset: { amount: -1, unit: "days" } },
        { key: "email", type: "email" }
    ] };
    FOR $step IN [["suite", "premier"], ["suite", "rappel"], ["cond", "vip"], ["cond", "tous"], ["rdv", "email"]] {
        CREATE notification_template CONTENT { tenant: auth_organization:alpha, workflow: type::record("notification_workflow", $step[0]), step_key: $step[1], subject: "S", html_body: "<p>H</p>", text_body: "T" };
    };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: déclenchement : seule la première étape est engagée (cursor 1), le déclenchement attend son envoi
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "suite", idempotency_key: "suite-1", to: { subscriber_id: "client-1", email: "client@exemple.fr" } }).data;
    CREATE test_ref:suite CONTENT { run: $r.run_id };
    RETURN $r.status == "created" AND array::len($r.job_ids) == 1
        AND (SELECT VALUE [step_key, type, status] FROM notification_job WHERE run = $r.run_id) == [["premier", "email", "queued"]]
        AND (SELECT VALUE [status, cursor] FROM ONLY $r.run_id) == ["pending", 1];
};

-- test: avancement rejoué : rien de plus n'est créé
{
    LET $run = (SELECT VALUE run FROM ONLY test_ref:suite);
    LET $a = fn::notification_run_advance({ run: $run });
    LET $b = fn::notification_run_advance({ run: $run });
    RETURN $a == { status: "pending" } AND $b == $a AND count(SELECT id FROM notification_job WHERE run = $run) == 1;
};

-- test: fin de l'envoi : l'attente est engagée (fin dans deux heures), le déclenchement attend
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ worker_id: "w1" }).data[0];
    LET $done = fn::notification_job_complete({ job_id: <string> $job.job_id, claim_token: $job.claim_token, integration: "notification_integration:relais", response_code: 250 }).data;
    LET $run = $job.run_id;
    LET $wait = (SELECT * FROM ONLY notification_job WHERE run = $run AND step_key = "pause" LIMIT 1);
    RETURN $job.digest IS NONE AND $done.run_status IS NONE AND $wait.status == "queued" AND $wait.type == "delay"
        AND $wait.wait_until > time::now() + 119m AND $wait.wait_until <= time::now() + 2h
        AND (SELECT VALUE status FROM ONLY $run) == "waiting";
};

-- test: une attente n'est jamais réservée par le worker d'envoi
-- en tant que: worker
RETURN fn::notification_job_claim({ worker_id: "w1" }).data == [];

-- test: attente confiée au planificateur : exécution différée de notification.run_resume à sa fin, étape waiting
{
    LET $run = (SELECT VALUE run FROM ONLY test_ref:suite);
    LET $r = fn::notification_wait_schedule({}).data;
    LET $job = (SELECT * FROM ONLY notification_job WHERE run = $run AND step_key = "pause" LIMIT 1);
    LET $scheduled = (SELECT * FROM ONLY scheduler_run WHERE task = scheduler_task:⟨notification.run_resume⟩ LIMIT 1);
    UPDATE test_ref:suite SET scheduler_run = $scheduled.id;
    RETURN $r == { scheduled: 1, resumed: 0, failed: 0, codes: [], more: false }
        AND $job.status == "waiting" AND $job.scheduler_run == <string> $scheduled.id
        AND $scheduled.args == { run: <string> $run, step_key: "pause" } AND $scheduled.scheduled_for == $job.wait_until
        AND $scheduled.state == "queued" AND $scheduled.tenant IS NONE AND $scheduled.unique_key == string::concat(<string> $run, "/pause");
};

-- test: confiée une seule fois : un second passage ne crée rien
RETURN fn::notification_wait_schedule({ limit: 10 }).data.scheduled == 0
    AND count(SELECT id FROM scheduler_run WHERE task = scheduler_task:⟨notification.run_resume⟩) == 1;

-- test: reprise par le planificateur (forme de l'exécuteur function) : attente terminée, étape suivante engagée (condition vraie)
{
    LET $ref = (SELECT * FROM ONLY test_ref:suite);
    LET $r = fn::notification_run_resume({ args: { run: <string> $ref.run, step_key: "pause" }, run: $ref.scheduler_run, scheduled_for: time::now(), attempt: 1 });
    RETURN $r.ok AND $r.data == { status: "resumed", run_status: "pending" }
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $ref.run ORDER BY created_at) == [["premier", "completed"], ["pause", "completed"], ["rappel", "queued"]];
};

-- test: reprise rejouée : rien ne change
{
    LET $ref = (SELECT * FROM ONLY test_ref:suite);
    LET $r = fn::notification_run_resume({ args: { run: <string> $ref.run, step_key: "pause" }, run: $ref.scheduler_run, scheduled_for: time::now(), attempt: 2 });
    RETURN $r.data == { status: "ignored", run_status: NONE } AND count(SELECT id FROM notification_job WHERE run = $ref.run) == 3;
};

-- test: dernière étape envoyée : déclenchement terminé, secret effacé
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ worker_id: "w1" }).data[0];
    RETURN fn::notification_job_complete({ job_id: <string> $job.job_id, claim_token: $job.claim_token, integration: "notification_integration:relais" }).data.run_status == "completed";
};

-- test: condition fausse : étape sautée (motif condition), la suivante est engagée
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "cond", idempotency_key: "cond-1", to: { subscriber_id: "client-1" }, payload: { vip: false } }).data;
    LET $vip = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "cond", idempotency_key: "cond-2", to: { subscriber_id: "client-1" }, payload: { vip: true } }).data;
    RETURN (SELECT VALUE [step_key, status, skip_reason] FROM notification_job WHERE run = $r.run_id ORDER BY created_at) == [["vip", "skipped", "condition"], ["tous", "queued", NONE]]
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $vip.run_id) == [["vip", "queued"]];
};

-- test: surcharges : étape sautée (motif override), durée d'attente changée
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "suite", idempotency_key: "suite-2", to: { subscriber_id: "client-1" }, overrides: { steps: { premier: { skip: true }, pause: { amount: 5, unit: "minutes" } } } }).data;
    LET $jobs = (SELECT step_key, status, skip_reason, wait_until FROM notification_job WHERE run = $r.run_id ORDER BY created_at);
    CREATE test_ref:suite2 CONTENT { run: $r.run_id };
    RETURN $jobs[0].{ step_key, status, skip_reason } == { step_key: "premier", status: "skipped", skip_reason: "override" }
        AND $jobs[1].status == "queued" AND $jobs[1].wait_until <= time::now() + 5m AND $jobs[1].wait_until > time::now() + 4m;
};

-- test: attente sur une date des données décalée d'un jour (veille du rendez-vous)
-- en tant que: envoyeur
{
    LET $rdv = time::now() + 3d;
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rdv", idempotency_key: "rdv-1", to: { subscriber_id: "client-1" }, payload: { rdv: <string> $rdv } }).data;
    RETURN (SELECT VALUE wait_until FROM ONLY notification_job WHERE run = $r.run_id AND step_key = "veille" LIMIT 1) == $rdv - 1d
        AND (SELECT VALUE status FROM ONLY $r.run_id) == "waiting";
};

-- test: date déjà passée : attente terminée aussitôt, étape suivante engagée
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rdv", idempotency_key: "rdv-2", to: { subscriber_id: "client-1" }, payload: { rdv: "2020-01-02T09:00:00Z" } }).data;
    RETURN (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $r.run_id ORDER BY created_at) == [["veille", "completed"], ["email", "queued"]];
};

-- test: date absente ou illisible : étape en échec (NOTIFICATION_PAYLOAD_INVALID), déclenchement en échec
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rdv", idempotency_key: "rdv-3", to: { subscriber_id: "client-1" }, payload: { rdv: "demain" } }).data;
    LET $job = (SELECT * FROM ONLY notification_job WHERE run = $r.run_id LIMIT 1);
    RETURN $job.status == "failed" AND $job.last_error.code == "NOTIFICATION_PAYLOAD_INVALID"
        AND (SELECT VALUE status FROM ONLY $r.run_id) == "failed" AND count(SELECT id FROM notification_job WHERE run = $r.run_id) == 1;
};

-- test: date au-delà de max_wait_days : étape en échec (NOTIFICATION_WAIT_TOO_LONG), aucun message
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rdv", idempotency_key: "rdv-4", to: { subscriber_id: "client-1" }, payload: { rdv: <string> (time::now() + 60d) } }).data;
    RETURN (SELECT VALUE last_error.code FROM ONLY notification_job WHERE run = $r.run_id LIMIT 1) == "NOTIFICATION_WAIT_TOO_LONG"
        AND (SELECT VALUE status FROM ONLY $r.run_id) == "failed";
};

-- test: attente échue avant d'être confiée au planificateur : reprise aussitôt par le worker d'étapes
{
    LET $run = (SELECT VALUE run FROM ONLY test_ref:suite2);
    UPDATE notification_job SET wait_until = time::now() - 1s WHERE run = $run AND step_key = "pause";
    LET $r = fn::notification_wait_schedule({}).data;
    RETURN $r.resumed == 1 AND $r.scheduled >= 1
        AND (SELECT VALUE [step_key, status, skip_reason] FROM notification_job WHERE run = $run ORDER BY created_at)
            == [["premier", "skipped", "override"], ["pause", "completed", NONE], ["rappel", "skipped", "condition"]]
        AND (SELECT VALUE [status, skip_reason] FROM ONLY $run) == ["skipped", "override"];
};

-- test: reprise après annulation : l'exécution du planificateur se termine sans rien faire
{
    LET $run = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "rdv-1" LIMIT 1);
    LET $canceled = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "rdv-1" }).data;
    LET $r = fn::notification_run_resume({ args: { run: <string> $run, step_key: "veille" } });
    RETURN $canceled.canceled == 1 AND $r.data == { status: "ignored", run_status: NONE }
        AND (SELECT VALUE status FROM ONLY $run) == "canceled"
        AND (SELECT VALUE [status, skip_reason] FROM ONLY notification_job WHERE run = $run LIMIT 1) == ["canceled", "canceled"];
};

-- test: tâches du planificateur déclarées par le seed du module (exécuteur function, permission notification.worker, portée installation)
RETURN (SELECT VALUE [module, executor, target, permission, scope, state, queue, unique_for] FROM ONLY scheduler_task:⟨notification.run_resume⟩)
        == ["lyxal_notification", "function", "notification_run_resume", "notification.worker", "installation", "active", scheduler_queue:default, 1d]
    AND (SELECT VALUE [module, executor, target, permission, scope, state, queue] FROM ONLY scheduler_task:⟨notification.purge⟩)
        == ["lyxal_notification", "function", "notification_purge", "notification.worker", "installation", "active", scheduler_queue:default];

-- test: attentes et reprises réservées au worker et au moteur
-- en tant que: envoyeur
RETURN fn::notification_wait_schedule({}).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_run_resume({ args: { run: "notification_run:x", step_key: "pause" } }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: entrées invalides
RETURN fn::notification_wait_schedule({ limit: 0 }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_run_resume({ args: { run: "autre_table:x", step_key: "pause" } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_run_resume({ args: { run: "notification_run:x" } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_run_resume({ args: { run: "notification_run:x", step_key: "pause" }, inconnu: 1 }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: fonctions internes : contexte des conditions (jamais le secret), fin d'attente, étape engagée une seule fois
{
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "suite-1" LIMIT 1);
    LET $context = fn::notification_step_context({ run: $run });
    LET $workflow = (SELECT * FROM ONLY notification_workflow:suite);
    LET $due = fn::notification_wait_due({ run: $run, step: $workflow.steps[1], override: {}, context: $context });
    LET $dated = fn::notification_wait_due({ run: $run, step: { key: "x", type: "delay", until: "payload.quand" }, context: { payload: { quand: "2030-01-01T00:00:00Z" } } });
    LET $again = fn::notification_job_add({ run: $run.id, step_key: "premier", type: "email", status: "queued" });
    LET $entered = fn::notification_step_enter({ run: $run, workflow: $workflow, step: $workflow.steps[0], index: 0 });
    LET $ended = fn::notification_wait_end({ run: $run.id, step_key: "pause" });
    RETURN $context == { payload: {}, subscriber: { subscriber_id: "client-1", locale: NONE, timezone: NONE, data: {} }, steps: { premier: { status: "completed" }, pause: { status: "completed" }, rappel: { status: "completed" } } }
        AND $due.code IS NONE AND $due.until > time::now() + 119m
        AND $dated.code == "NOTIFICATION_WAIT_TOO_LONG"
        AND $again.job IS NONE AND $entered.job IS NONE AND $ended == { status: "ignored", run_status: NONE }
        AND count(SELECT id FROM notification_job WHERE run = $run.id) == 3;
};

-- test: un parcours modifié pendant une attente ne change pas le déclenchement (étapes copiées au déclenchement)
{
    CREATE notification_workflow:modif CONTENT { tenant: auth_organization:alpha, key: "modif", name: "Modif", status: "active", steps: [
        { key: "pause", type: "delay", amount: 1, unit: "hours" }, { key: "email", type: "email" }
    ] };
    CREATE notification_template CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:modif, step_key: "email", subject: "S", html_body: "<p>H</p>", text_body: "T" };
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "modif", idempotency_key: "modif-1", to: { subscriber_id: "client-9", email: "c9@exemple.fr" } }).data;
    UPDATE notification_workflow:modif SET steps = [{ key: "email", type: "email" }];
    LET $resumed = fn::notification_run_resume({ args: { run: <string> $r.run_id, step_key: "pause" } }).data;
    RETURN $resumed.status == "resumed" AND (SELECT VALUE steps.key FROM ONLY $r.run_id) == ["pause", "email"]
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $r.run_id ORDER BY created_at) == [["pause", "completed"], ["email", "queued"]];
};

-- test: échéance : aucune sans secret (une longue attente ne fait rien expirer), 7 jours par défaut avec un secret
{
    LET $plain = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "modif", idempotency_key: "modif-2", to: { subscriber_id: "client-9" } }).data;
    LET $sealed = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "modif", idempotency_key: "modif-3", to: { subscriber_id: "client-9" }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).data;
    LET $at = (SELECT VALUE expires_at FROM ONLY $sealed.run_id);
    RETURN (SELECT VALUE expires_at FROM ONLY $plain.run_id) IS NONE AND $at > time::now() + 6d AND $at <= time::now() + 7d;
};

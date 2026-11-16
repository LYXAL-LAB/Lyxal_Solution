-- lyxal-test: assertions
-- Annulation (abonné, liste, regroupement porté, envoi déjà parti, rien en cours, événement sans
-- données), envoi groupé (100 au plus, rapport par entrée), envoi de test (attentes,
-- regroupements et limitations ignorés ; suppression et préférences appliquées) ; droits
-- (send, manage, read, sans droit, autre organisation).
--
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["notification.read", "notification.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }

-- préparation: organisations, sessions, parcours et gabarits
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["envoyeur", "gestion", "lecteur", "membre", "autre", "worker"] {
        LET $org = IF $n = "autre" { auth_organization:beta } ELSE IF $n = "worker" { NONE } ELSE { auth_organization:alpha };
        LET $identity = type::record("auth_identity", $n);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
        IF $org IS NOT NONE { RELATE $identity->auth_member_of->$org; };
        CREATE type::record("auth_session", $n) CONTENT { identity: $identity, organization: $org, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE notification_workflow:relance CONTENT { tenant: auth_organization:alpha, key: "relance", name: "Relance", status: "active", steps: [
        { key: "premier", type: "email" }, { key: "pause", type: "delay", amount: 1, unit: "days" }, { key: "rappel", type: "email" }
    ] };
    CREATE notification_workflow:lot CONTENT { tenant: auth_organization:alpha, key: "lot", name: "Lot", status: "active", steps: [
        { key: "lot", type: "digest", window: { amount: 1, unit: "hours" } }, { key: "email", type: "email" }
    ] };
    CREATE notification_workflow:essai CONTENT { tenant: auth_organization:alpha, key: "essai", name: "Essai", status: "draft", steps: [
        { key: "limite", type: "throttle", limit: 1, window: { amount: 1, unit: "hours" } },
        { key: "lot", type: "digest", window: { amount: 1, unit: "hours" } },
        { key: "pause", type: "delay", amount: 1, unit: "days" },
        { key: "email", type: "email" }
    ] };
    FOR $step IN [["relance", "premier"], ["relance", "rappel"], ["lot", "email"], ["essai", "email"]] {
        CREATE notification_template CONTENT { tenant: auth_organization:alpha, workflow: type::record("notification_workflow", $step[0]), step_key: $step[1], subject: "S", html_body: "<p>H</p>", text_body: "T" };
    };
};

-- test: annulation d'un déclenchement en attente : étape d'attente annulée, secret effacé
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "relance-1", to: { subscriber_id: "client-1", email: "client@exemple.fr" }, overrides: { steps: { premier: { skip: true } } }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).data;
    LET $waiting = (SELECT VALUE status FROM ONLY $r.run_id);
    LET $c = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "relance-1" }).data;
    RETURN $waiting == "waiting" AND $c == { canceled: 1, runs: [$r.run_id] }
        AND (SELECT VALUE [status, skip_reason] FROM ONLY $r.run_id) == ["canceled", "canceled"]
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $r.run_id ORDER BY created_at) == [["premier", "skipped"], ["pause", "canceled"]];
};

-- test: secret effacé et événement notification.run.canceled (identifiants seulement)
{
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "relance-1" LIMIT 1);
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "notification.run.canceled" LIMIT 1);
    RETURN $run.secret IS NONE AND $e.payload == { run_id: <string> $run.id, tenant: "auth_organization:alpha", workflow_id: "notification_workflow:relance" };
};

-- test: annulation d'une liste : chaque abonné (<clé>/<subscriber_id>)
-- en tant que: envoyeur
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "liste", to: [{ subscriber_id: "a", email: "a@exemple.fr" }, { subscriber_id: "b", email: "b@exemple.fr" }] });
    LET $c = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "liste" }).data;
    RETURN $c.canceled == 2
        AND (SELECT VALUE status FROM notification_run WHERE idempotency_key IN ["liste/a", "liste/b"]) == ["canceled", "canceled"]
        AND (SELECT VALUE status FROM notification_job WHERE run.idempotency_key IN ["liste/a", "liste/b"]) == ["canceled", "canceled"];
};

-- test: annulation du porteur d'un regroupement : refermé sans envoi ; la reprise ne fait rien
-- en tant que: envoyeur
{
    LET $carrier = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: "lot-1", to: { subscriber_id: "client-1" } }).data.run_id;
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: "lot-2", to: { subscriber_id: "client-1" } });
    LET $digest = (SELECT VALUE digest FROM ONLY $carrier);
    LET $c = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "lot-1" }).data;
    RETURN $c.canceled == 1 AND (SELECT VALUE [status, open_slot, count] FROM ONLY $digest) == ["closed", NONE, 2]
        AND (SELECT VALUE status FROM notification_job WHERE run = $carrier) == ["canceled"];
};

-- test: reprise du porteur annulé : rien, aucun envoi engagé
{
    LET $carrier = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "lot-1" LIMIT 1);
    RETURN fn::notification_run_resume({ args: { run: <string> $carrier, step_key: "lot" } }).data.status == "ignored"
        AND count(SELECT id FROM notification_job WHERE run = $carrier AND type = "email") == 0;
};

-- test: rien en cours pour la clé (inconnue, ou déjà annulée) : NOTIFICATION_RUN_NOT_FOUND
-- en tant que: envoyeur
RETURN fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "inconnue" }).error.code == "NOTIFICATION_RUN_NOT_FOUND"
    AND fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "relance-1" }).error.code == "NOTIFICATION_RUN_NOT_FOUND"
    AND fn::notification_cancel({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_INVALID_INPUT";

-- préparation: un envoi réservé par le worker avant l'annulation
fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "parti-1", to: { subscriber_id: "client-3", email: "c3@exemple.fr" } });

-- test: envoi déjà en cours : il n'est pas rappelé, mais le parcours s'arrête
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ worker_id: "w1" }).data.find(|$j| $j.idempotency_key = "parti-1");
    LET $c = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "parti-1" }).data;
    LET $done = fn::notification_job_complete({ job_id: <string> $job.job_id, claim_token: $job.claim_token }).data;
    RETURN $c.canceled == 1 AND $done.status == "completed" AND $done.run_status == "canceled"
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $job.run_id) == [["premier", "completed"]];
};

-- préparation: deux envois réservés par le worker puis annulés pendant l'envoi
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "encours-1", to: { subscriber_id: "client-4", email: "c4@exemple.fr" } });
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "encours-2", to: { subscriber_id: "client-5", email: "c5@exemple.fr" } });
};

-- test: annulé pendant l'envoi : un échec temporaire ne remet pas l'étape en file, une réservation expirée n'est pas reprise
{
    LET $jobs = fn::notification_job_claim({ worker_id: "w1" }).data;
    LET $a = $jobs.find(|$j| $j.idempotency_key = "encours-1");
    LET $b = $jobs.find(|$j| $j.idempotency_key = "encours-2");
    LET $c1 = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "encours-1" }).data.canceled;
    LET $c2 = fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "encours-2" }).data.canceled;
    LET $failed = fn::notification_job_fail({ job_id: <string> $a.job_id, claim_token: $a.claim_token, class: "transient", code: "SMTP_421" }).data;
    UPDATE notification_job SET locked_until = time::now() - 1s WHERE run.idempotency_key = "encours-2";
    LET $again = fn::notification_job_claim({ worker_id: "w2" }).data;
    RETURN $c1 == 1 AND $c2 == 1 AND $b IS NOT NONE AND $failed.status == "canceled" AND $failed.next_retry_at IS NONE
        AND $again.filter(|$j| $j.idempotency_key IN ["encours-1", "encours-2"]) == []
        AND (SELECT VALUE status FROM notification_job WHERE run.idempotency_key IN ["encours-1", "encours-2"]) == ["canceled", "canceled"];
};

-- test: annulation réservée à notification.send dans l'organisation
-- en tant que: lecteur
RETURN fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "x" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: une autre organisation n'annule rien d'alpha
-- en tant que: autre
RETURN fn::notification_cancel({ tenant: "auth_organization:alpha", idempotency_key: "x" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_cancel({ tenant: "auth_organization:beta", idempotency_key: "liste" }).error.code == "NOTIFICATION_RUN_NOT_FOUND";

-- test: envoi groupé : chaque déclenchement contrôlé et exécuté, rapport par entrée
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger_bulk({ events: [
        { tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "bulk-1", to: { subscriber_id: "client-1" } },
        { tenant: "auth_organization:alpha", workflow_key: "inconnu", idempotency_key: "bulk-2", to: { subscriber_id: "client-1" } },
        { tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "bulk-3", to: { subscriber_id: "inexistant" } },
        { tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "bulk-1", to: { subscriber_id: "client-1" } }
    ] }).data.results;
    RETURN $r.map(|$e| [$e.index, $e.ok]) == [[0, true], [1, false], [2, false], [3, true]]
        AND $r[0].data.status == "created" AND $r[1].error.code == "NOTIFICATION_WORKFLOW_NOT_FOUND"
        AND $r[2].error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND" AND $r[3].data.status == "duplicate";
};

-- test: envoi groupé borné (1 à 100) par lyxal_core ; entrées invalides
-- en tant que: envoyeur
{
    LET $event = { tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "k", to: { subscriber_id: "client-1" } };
    RETURN fn::notification_trigger_bulk({ events: array::map(<array>(0..101), |$i| $event) }).error.details.fields.events == ["CORE_VALIDATION_TOO_LONG"]
        AND fn::notification_trigger_bulk({ events: [] }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_trigger_bulk({ events: [1] }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_trigger_bulk({ events: array::map(<array>(0..100), |$i| object::extend($event, { idempotency_key: string::concat("cent-", <string> $i) })) }).data.results.all(|$e| $e.ok);
};

-- test: envoi groupé sans droit : chaque entrée refusée
-- en tant que: membre
RETURN fn::notification_trigger_bulk({ events: [{ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "m-1", to: { subscriber_id: "client-1" } }] }).data.results[0].error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: envoi de test (brouillon) : limitation, regroupement et attente ignorés, l'e-mail part tout de suite
-- en tant que: gestion
{
    LET $r = fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: { subscriber_id: "testeur", email: "testeur@alpha.test" }, payload: { a: 1 } }).data;
    LET $run = (SELECT * FROM ONLY $r.run_id);
    RETURN $r.status == "created" AND $run.test AND string::starts_with($run.idempotency_key, "test/")
        AND (SELECT VALUE [step_key, status, skip_reason] FROM notification_job WHERE run = $r.run_id ORDER BY created_at)
            == [["limite", "skipped", "test"], ["lot", "skipped", "test"], ["pause", "skipped", "test"], ["email", "queued", NONE]]
        AND count(SELECT id FROM notification_digest WHERE workflow = notification_workflow:essai) == 0;
};

-- préparation: adresse supprimée et préférence de l'abonné
{
    fn::notification_suppression_add({ tenant: "auth_organization:alpha", address: "bloque@alpha.test", reason: "manual" });
    fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "sans_email", email: "sans@alpha.test" });
    fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "sans_email", channels: { email: false } });
};

-- test: envoi de test : liste de suppression et préférences appliquées
-- en tant que: gestion
RETURN fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: { subscriber_id: "bloque", email: "bloque@alpha.test" } }).data.skip_reason == "suppressed:manual"
    AND fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: { subscriber_id: "sans_email" } }).data.skip_reason == "preference:subscriber_global";

-- test: envoi de test : un seul abonné ; parcours inconnu ; variables contrôlées par le schéma
-- en tant que: gestion
RETURN fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: { topic: "x" } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: [{ subscriber_id: "a" }] }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "inconnu", to: { subscriber_id: "testeur" } }).error.code == "NOTIFICATION_WORKFLOW_NOT_FOUND";

-- test: envoi de test réservé à notification.manage
-- en tant que: envoyeur
RETURN fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: { subscriber_id: "testeur" } }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: envoi de test refusé à une autre organisation
-- en tant que: autre
RETURN fn::notification_test_send({ tenant: "auth_organization:alpha", workflow_key: "essai", to: { subscriber_id: "testeur" } }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: fonctions internes du déclenchement : parcours visé, déclenchement d'un abonné, réponse
{
    LET $active = fn::notification_trigger_workflow({ tenant: auth_organization:alpha, workflow_key: "essai", active_only: true });
    LET $any = fn::notification_trigger_workflow({ tenant: auth_organization:alpha, workflow_key: "essai", active_only: false });
    LET $workflow = (SELECT * FROM ONLY notification_workflow:relance);
    LET $one = fn::notification_trigger_one({ tenant: auth_organization:alpha, workflow: $workflow, input: { subscriber_id: "client-1" }, idempotency_key: "interne-1", payload: {}, settings: fn::notification_settings_effective({ tenant: auth_organization:alpha }), exclude_actor: true, actor: "client-1", overrides: {}, test: false });
    LET $single = fn::notification_trigger_single({ result: { status: "no_address" }, workflow: $workflow, language: "fr" });
    RETURN $active.code == "NOTIFICATION_WORKFLOW_INACTIVE" AND $any.workflow.id == notification_workflow:essai
        AND $one.status == "skipped" AND $one.skip_reason == "actor"
        AND $single.error.code == "NOTIFICATION_SUBSCRIBER_NO_ADDRESS" AND $single.error.details == { channels: ["email"] };
};

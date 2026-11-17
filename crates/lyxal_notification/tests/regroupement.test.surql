-- lyxal-test: assertions
-- Regroupement (digest) : ouverture, déclenchement qui rejoint (merged, événement sans données),
-- clé lue dans les données, 100 événements gardés au plus, fermeture et variables du message
-- regroupé, recul (lookback). Limitation (throttle) : sous et au-dessus de la limite, clé, fenêtre
-- suivante, parcours critique jamais limité. Purge des regroupements fermés et des compteurs.
--
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: organisation, sessions, parcours et gabarits
{
    CREATE notification_integration:relais CONTENT { key: "relais", channel: "email", provider: "smtp", name: "Relais", primary: true, settings: { from_address: "noreply@lyxal.test", host: "127.0.0.1", port: 2525, security: "local_plain" }, credentials_path: "notification/smtp/relais" };
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    FOR $n IN ["envoyeur", "worker", "lecteur", "membre"] {
        LET $identity = type::record("auth_identity", $n);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
        IF $n != "worker" { RELATE $identity->auth_member_of->auth_organization:alpha; };
        CREATE type::record("auth_session", $n) CONTENT { identity: $identity, organization: IF $n = "worker" { NONE } ELSE { auth_organization:alpha }, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE notification_workflow:lot CONTENT { tenant: auth_organization:alpha, key: "lot", name: "Lot", status: "active", steps: [
        { key: "lot", type: "digest", window: { amount: 30, unit: "minutes" }, group_by: "payload.projet" },
        { key: "email", type: "email" }
    ] };
    CREATE notification_workflow:recul CONTENT { tenant: auth_organization:alpha, key: "recul", name: "Recul", status: "active", steps: [
        { key: "lot", type: "digest", window: { amount: 10, unit: "minutes" }, lookback: { amount: 1, unit: "hours" } },
        { key: "email", type: "email" }
    ] };
    CREATE notification_workflow:limite CONTENT { tenant: auth_organization:alpha, key: "limite", name: "Limite", status: "active", steps: [
        { key: "limite", type: "throttle", limit: 2, window: { amount: 1, unit: "hours" }, group_by: "payload.projet" },
        { key: "email", type: "email" }
    ] };
    CREATE notification_workflow:limite_courte CONTENT { tenant: auth_organization:alpha, key: "limite_courte", name: "Limite courte", status: "active", steps: [
        { key: "limite", type: "throttle", limit: 1, window: { amount: 4, unit: "seconds" } },
        { key: "email", type: "email" }
    ] };
    CREATE notification_workflow:alerte CONTENT { tenant: auth_organization:alpha, key: "alerte", name: "Alerte", status: "active", critical: true, steps: [
        { key: "limite", type: "throttle", limit: 1, window: { amount: 1, unit: "hours" } },
        { key: "email", type: "email" }
    ] };
    FOR $w IN ["lot", "recul", "limite", "limite_courte", "alerte"] {
        CREATE notification_template CONTENT { tenant: auth_organization:alpha, workflow: type::record("notification_workflow", $w), step_key: "email", subject: "{{ digest.count }} nouveautés", html_body: "<p>H</p>", text_body: "T" };
    };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: premier déclenchement d'une clé : regroupement ouvert, porté par ce déclenchement, qui attend la fin de la fenêtre
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: "lot-1", to: { subscriber_id: "client-1", email: "client@exemple.fr" }, payload: { projet: "A", n: 1 } }).data;
    LET $run = (SELECT * FROM ONLY $r.run_id);
    LET $digest = (SELECT * FROM ONLY $run.digest);
    LET $job = (SELECT * FROM ONLY notification_job WHERE run = $r.run_id LIMIT 1);
    CREATE test_ref:lot CONTENT { carrier: $r.run_id, digest: $digest.id };
    RETURN $run.status == "waiting" AND $digest.{ status, count, group_key, carrier } == { status: "open", count: 1, group_key: "A", carrier: $r.run_id }
        AND $digest.events[0].payload == { projet: "A", n: 1 }
        AND $job.{ type, status } == { type: "digest", status: "queued" } AND $job.wait_until == $digest.ends_at
        AND $digest.ends_at > time::now() + 29m AND $digest.ends_at <= time::now() + 30m;
};

-- test: même clé pendant la fenêtre : le déclenchement rejoint le regroupement (merged), rien d'autre n'est engagé
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: "lot-2", to: { subscriber_id: "client-1" }, payload: { projet: "A", n: 2 } }).data;
    LET $run = (SELECT * FROM ONLY $r.run_id);
    LET $digest = (SELECT * FROM ONLY test_ref:lot.digest);
    RETURN $r.status == "created" AND $run.status == "merged" AND $run.digest == $digest.id AND $run.secret IS NONE
        AND (SELECT VALUE [type, status] FROM notification_job WHERE run = $r.run_id) == [["digest", "merged"]]
        AND $digest.count == 2 AND $digest.events.payload.n == [1, 2];
};

-- test: événement notification.run.merged : identifiants seulement
{
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "notification.run.merged" LIMIT 1);
    RETURN object::keys($e.payload) == ["digest_id", "run_id"] AND $e.payload.digest_id == <string> test_ref:lot.digest;
};

-- test: autre clé (autre projet) : regroupement distinct
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: "lot-b", to: { subscriber_id: "client-1" }, payload: { projet: "B", n: 1 } }).data;
    RETURN (SELECT VALUE status FROM ONLY $r.run_id) == "waiting" AND (SELECT VALUE digest FROM ONLY $r.run_id) != test_ref:lot.digest
        AND count(SELECT id FROM notification_digest WHERE status = "open") == 2;
};

-- préparation: 103 déclenchements de plus pour la clé A
FOR $i IN <array>(3..106) {
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: string::concat("lot-", <string> $i), to: { subscriber_id: "client-1" }, payload: { projet: "A", n: $i } });
};

-- test: 100 événements gardés au plus, tous comptés
{
    LET $digest = (SELECT * FROM ONLY test_ref:lot.digest);
    RETURN $digest.count == 105 AND array::len($digest.events) == 100 AND $digest.events[99].payload.n == 100;
};

-- test: fin de la fenêtre (reprise par le planificateur) : regroupement fermé, étape de canal engagée
{
    LET $carrier = (SELECT VALUE carrier FROM ONLY test_ref:lot);
    LET $r = fn::notification_run_resume({ args: { run: <string> $carrier, step_key: "lot" } }).data;
    LET $digest = (SELECT * FROM ONLY test_ref:lot.digest);
    RETURN $r == { status: "resumed", run_status: "pending" } AND $digest.status == "closed" AND $digest.open_slot IS NONE AND $digest.closed_at IS NOT NONE
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $carrier ORDER BY created_at) == [["lot", "completed"], ["email", "queued"]];
};

-- test: le message regroupé reçoit le nombre et les données des événements
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w1" }).data[0];
    CREATE test_ref:envoi CONTENT { job: $job.job_id, token: $job.claim_token };
    RETURN $job.run_id == test_ref:lot.carrier AND $job.digest.count == 105 AND array::len($job.digest.events) == 100
        AND $job.digest.events[0].payload == { projet: "A", n: 1 } AND $job.digest.events[0].at IS NOT NONE;
};

-- test: regroupement fermé : un nouveau déclenchement de la clé en ouvre un autre
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lot", idempotency_key: "lot-200", to: { subscriber_id: "client-1" }, payload: { projet: "A", n: 200 } }).data;
    LET $digest = (SELECT VALUE digest FROM ONLY $r.run_id);
    RETURN $digest != test_ref:lot.digest AND (SELECT VALUE [status, carrier] FROM ONLY $digest) == ["open", $r.run_id];
};

-- test: recul : rien d'arrivé depuis une heure, le message part tout de suite (regroupement fermé d'un seul événement)
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "recul", idempotency_key: "recul-1", to: { subscriber_id: "client-1" } }).data;
    RETURN (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $r.run_id ORDER BY created_at) == [["lot", "completed"], ["email", "queued"]]
        AND (SELECT VALUE [status, count] FROM ONLY (SELECT VALUE digest FROM ONLY $r.run_id)) == ["closed", 1];
};

-- test: recul : arrivée récente, le suivant ouvre un regroupement ; le troisième le rejoint
-- en tant que: envoyeur
{
    LET $second = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "recul", idempotency_key: "recul-2", to: { subscriber_id: "client-1" } }).data;
    LET $third = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "recul", idempotency_key: "recul-3", to: { subscriber_id: "client-1" } }).data;
    RETURN (SELECT VALUE status FROM ONLY $second.run_id) == "waiting" AND (SELECT VALUE status FROM ONLY $third.run_id) == "merged";
};

-- test: limitation : sous la limite les messages partent, au-delà le déclenchement s'arrête (motif throttled, rien en attente)
-- en tant que: envoyeur
{
    LET $runs = array::map([1, 2, 3], |$i| fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "limite", idempotency_key: string::concat("limite-", <string> $i), to: { subscriber_id: "client-1" }, payload: { projet: "A" } }).data);
    LET $third = (SELECT * FROM ONLY $runs[2].run_id);
    RETURN (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $runs[0].run_id ORDER BY created_at) == [["limite", "completed"], ["email", "queued"]]
        AND (SELECT VALUE status FROM notification_job WHERE run = $runs[1].run_id AND step_key = "email") == ["queued"]
        AND $runs[2].status == "skipped" AND $runs[2].skip_reason == "throttled"
        AND $third.{ status, skip_reason } == { status: "skipped", skip_reason: "throttled" }
        AND (SELECT VALUE [step_key, status, skip_reason] FROM notification_job WHERE run = $third.id) == [["limite", "skipped", "throttled"]];
};

-- test: limitation par clé : un autre projet a son propre compteur
-- en tant que: envoyeur
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "limite", idempotency_key: "limite-b", to: { subscriber_id: "client-1" }, payload: { projet: "B" } }).data.status == "created"
    AND (SELECT VALUE count FROM notification_rate_limit WHERE group_key = "A") == [3];

-- test: fenêtre suivante : le compteur repart
-- en tant que: envoyeur
{
    LET $call = |$key| fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "limite_courte", idempotency_key: $key, to: { subscriber_id: "client-2", email: "client2@exemple.fr" } }).data;
    -- Les fenêtres sont alignées sur l'horloge (time::floor) : on se place juste après le début
    -- d'une fenêtre, pour que les deux premiers appels tombent dans la même, quelle que soit la
    -- vitesse de la machine, puis on attend une fenêtre entière pour le troisième
    sleep(time::ceil(time::now(), 4s) - time::now() + 100ms);
    LET $first = $call("court-1");
    LET $second = $call("court-2");
    sleep(4s);
    LET $third = $call("court-3");
    RETURN $first.status == "created" AND $second.skip_reason == "throttled" AND $third.status == "created";
};

-- test: un parcours critique n'est jamais limité
-- en tant que: envoyeur
{
    LET $runs = array::map([1, 2, 3], |$i| fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "alerte", idempotency_key: string::concat("alerte-", <string> $i), to: { subscriber_id: "client-1" } }).data);
    RETURN $runs.all(|$r| $r.status == "created") AND count(SELECT id FROM notification_rate_limit WHERE workflow = notification_workflow:alerte) == 0;
};

-- test: regroupements et compteurs lisibles avec la lecture de l'organisation, jamais sans droit
-- en tant que: lecteur
RETURN count(SELECT id FROM notification_digest) >= 3 AND count(SELECT id FROM notification_rate_limit) >= 2;

-- test: sans droit : rien de lisible
-- en tant que: membre
RETURN count(SELECT id FROM notification_digest) == 0 AND count(SELECT id FROM notification_rate_limit) == 0;

-- test: purge : regroupements fermés et compteurs expirés supprimés ; les regroupements ouverts restent
{
    UPDATE notification_digest SET purge_after = time::now() - 1s;
    UPDATE notification_rate_limit SET purge_after = time::now() - 1s WHERE group_key = "A";
    LET $open = count(SELECT id FROM notification_digest WHERE status = "open");
    LET $closed = count(SELECT id FROM notification_digest WHERE status = "closed");
    LET $r = fn::notification_purge({ args: { limit: 100 } }).data;
    RETURN $r.digests == $closed AND $r.rate_limits >= 1 AND count(SELECT id FROM notification_digest) == $open
        AND count(SELECT id FROM notification_rate_limit WHERE group_key = "A") == 0;
};

-- test: fonctions internes : clé de regroupement, regroupement rejoint, limitation (rejouables)
{
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "lot-200" LIMIT 1);
    LET $key = fn::notification_group_key({ step: { group_by: "payload.projet" }, context: { payload: { projet: 42 } } });
    LET $none = fn::notification_group_key({ step: {}, context: {} });
    LET $join = fn::notification_digest_join({ run: $run, step: { key: "lot", type: "digest", window: { amount: 30, unit: "minutes" }, group_by: "payload.projet" }, context: { payload: $run.payload }, until: time::now() + 30m });
    LET $merge = fn::notification_digest_merge({ run: $run, step: { key: "lot" }, digest: $run.digest });
    LET $workflow = (SELECT * FROM ONLY notification_workflow:limite);
    LET $other = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "limite-b" LIMIT 1);
    LET $hit = fn::notification_throttle_hit({ run: $other, workflow: $workflow, step: $workflow.steps[0], context: { payload: { projet: "B" } } });
    RETURN $key == "42" AND $none == "" AND $join.job IS NONE AND $merge.job IS NONE AND $hit.job IS NONE
        AND (SELECT VALUE count FROM ONLY $run.digest) == 3;
};

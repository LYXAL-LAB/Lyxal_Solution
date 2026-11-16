-- lyxal-test: assertions
-- Diffusions et listes : déclenchement d'une liste (clé par abonné, statut par abonné, auteur
-- exclu), d'un sujet ou de tous (enregistrement idempotent), traitement par le worker par
-- paquets (curseur, condition d'abonnement, auteur exclu, sans adresse), reprise sans doublon,
-- fin, réservation perdue, permissions.
--
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }

-- préparation: organisations, sessions, parcours, sujet de cinq abonnés (dont un sans adresse et un avec condition)
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["envoyeur", "autre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
    };
    RELATE auth_identity:envoyeur->auth_member_of->auth_organization:alpha;
    CREATE auth_session:envoyeur CONTENT { identity: auth_identity:envoyeur, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_workflow:annonce CONTENT { tenant: auth_organization:alpha, key: "annonce", name: "Annonce", status: "active", steps: [{ key: "email", channel: "email" }] };
    CREATE notification_topic:equipe CONTENT { tenant: auth_organization:alpha, key: "equipe", name: "Équipe" };
    FOR $n IN ["m1", "m2", "m3", "m4"] {
        LET $s = fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: $n, email: string::concat($n, "@exemple.fr"), data: { region: IF $n = "m3" { "sud" } ELSE { "nord" } } }, must_exist: false }).subscriber;
        CREATE type::record("notification_topic_member", $n) CONTENT { topic: notification_topic:equipe, subscriber: $s.id, condition: IF $n = "m3" { { field: "payload.region", op: "eq", value: "sud" } } ELSE { NONE } };
    };
    LET $sans = fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "m5", first_name: "Sans adresse" }, must_exist: false }).subscriber;
    CREATE notification_topic_member:m5 CONTENT { topic: notification_topic:equipe, subscriber: $sans.id };
};

-- test: destinataires de `to` : abonné, liste, sujet, tous ; formes invalides
RETURN fn::notification_trigger_target({ to: { subscriber_id: "a", email: "a@exemple.fr" } }).kind == "subscriber"
    AND fn::notification_trigger_target({ to: ["a", { subscriber_id: "b" }] }).subscribers.subscriber_id == ["a", "b"]
    AND fn::notification_trigger_target({ to: { topic: "equipe" } }).topic == "equipe"
    AND fn::notification_trigger_target({ to: { all: true } }).kind == "all"
    AND !fn::notification_trigger_target({ to: { all: false } }).valid
    AND !fn::notification_trigger_target({ to: { topic: "Pas Snake" } }).valid
    AND fn::notification_trigger_target({ to: [] }).by_field == { to: ["CORE_VALIDATION_TOO_SHORT"] }
    AND fn::notification_trigger_target({ to: (<array> (1..=101)).map(|$i| <string> $i) }).by_field == { to: ["CORE_VALIDATION_TOO_LONG"] }
    -- Invité à l'adresse la plus longue admise (254) : identifiant email:<adresse> accepté
    AND fn::notification_trigger_target({ to: { subscriber_id: string::concat("email:", string::repeat("a", 254)) } }).valid
    AND fn::notification_trigger_target({ to: ["a", { email: "x@exemple.fr" }] }).by_field.to["1"] IS NOT NONE;

-- test: liste : un déclenchement par abonné (clé <clé>/<subscriber_id>), auteur exclu, inconnu refusé sans arrêter la liste
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "liste-1", actor: "m2",
        to: ["m1", "m2", { subscriber_id: "nouveau", email: "nouveau@exemple.fr" }, "inconnu", "m5"] }).data;
    RETURN $r.kind == "list" AND $r.runs.map(|$x| [$x.subscriber_id, $x.status]) == [["m1", "created"], ["m2", "skipped"], ["nouveau", "created"], ["inconnu", "rejected"], ["m5", "no_address"]]
        AND $r.runs[1].skip_reason == "actor" AND $r.runs[3].code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND"
        AND (SELECT VALUE idempotency_key FROM notification_run WHERE scope_key = "alpha" ORDER BY idempotency_key) == ["liste-1/m1", "liste-1/nouveau"];
};

-- test: liste rejouée : aucun déclenchement de plus ; auteur prévenu sur demande ; liste de plus de 100 abonnés et secret refusés
-- en tant que: envoyeur
{
    LET $again = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "liste-1", to: ["m1"] }).data;
    LET $actor = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "liste-2", actor: "m2", exclude_actor: false, to: ["m2"] }).data;
    RETURN $again.runs[0].status == "duplicate" AND $actor.runs[0].status == "created"
        AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "l-3", to: array::map(<array>(0..101), |$i| <string> $i) }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "l-4", to: ["m1"], secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: déclenchement d'un abonné qui est l'auteur : écarté
-- en tant que: envoyeur
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "auteur-1", actor: "m1", to: { subscriber_id: "m1" } }).data.{ status, skip_reason, run_id } == { status: "skipped", skip_reason: "actor", run_id: NONE };

-- test: diffusion à un sujet : enregistrée, rejouée sans doublon ; sujet inconnu refusé ; secret refusé
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "diff-1", actor: "m1", to: { topic: "equipe" }, payload: { region: "nord" } }).data;
    LET $again = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "diff-1", to: { topic: "equipe" } }).data;
    RETURN $r.kind == "broadcast" AND $r.status == "created" AND $again.status == "duplicate" AND $again.broadcast_id == $r.broadcast_id
        AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "diff-2", to: { topic: "absent" } }).error.code == "NOTIFICATION_TOPIC_NOT_FOUND"
        AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "diff-3", to: { topic: "equipe" }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: qui déclenche ne traite pas les diffusions (worker seulement)
-- en tant que: envoyeur
RETURN fn::notification_broadcast_claim({ worker_id: "w" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_broadcast_step({ broadcast_id: "notification_broadcast:x", claim_token: "01a1bca0-0000-7000-8000-000000000001" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_broadcast_complete({ broadcast_id: "notification_broadcast:x", claim_token: "01a1bca0-0000-7000-8000-000000000001" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- préparation: le worker réserve la diffusion
{
    LET $claim = fn::notification_broadcast_claim({ worker_id: "w1", lease_seconds: 60 }).data;
    CREATE essai:claim CONTENT { broadcast_id: <string> $claim.broadcast_id, claim_token: $claim.claim_token };
};

-- test: une diffusion réservée n'est pas réservée deux fois
RETURN fn::notification_broadcast_claim({ worker_id: "w2" }).data IS NONE
    AND (SELECT VALUE [status, worker_id] FROM ONLY notification_broadcast WHERE idempotency_key = "diff-1" LIMIT 1) == ["running", "w1"];

-- test: premier paquet de deux : auteur (m1) exclu ; curseur avancé
{
    LET $c = (SELECT * FROM ONLY essai:claim);
    LET $r = fn::notification_broadcast_step({ broadcast_id: $c.broadcast_id, claim_token: $c.claim_token, size: 2 }).data;
    RETURN $r == { processed: 2, created: 1, skipped: 1, done: false }
        AND (SELECT VALUE processed FROM ONLY notification_broadcast WHERE idempotency_key = "diff-1" LIMIT 1) == 2;
};

-- test: fin prématurée refusée
{
    LET $c = (SELECT * FROM ONLY essai:claim);
    RETURN fn::notification_broadcast_complete({ broadcast_id: $c.broadcast_id, claim_token: $c.claim_token }).error.code == "NOTIFICATION_BROADCAST_INCOMPLETE";
};

-- test: reprise après arrêt (curseur revenu au début) : aucun déclenchement en double
{
    LET $c = (SELECT * FROM ONLY essai:claim);
    UPDATE notification_broadcast SET cursor = NONE WHERE idempotency_key = "diff-1";
    LET $r = fn::notification_broadcast_step({ broadcast_id: $c.broadcast_id, claim_token: $c.claim_token, size: 2 }).data;
    RETURN $r.created == 0 AND count(SELECT id FROM notification_run WHERE string::starts_with(idempotency_key, "diff-1/")) == 1;
};

-- test: paquet suivant : condition non remplie (m3) et abonné sans adresse (m5) écartés ; dernier paquet incomplet : fin
{
    LET $c = (SELECT * FROM ONLY essai:claim);
    LET $r = fn::notification_broadcast_step({ broadcast_id: $c.broadcast_id, claim_token: $c.claim_token, size: 4 }).data;
    RETURN $r == { processed: 3, created: 1, skipped: 2, done: true }
        AND (SELECT VALUE idempotency_key FROM notification_run WHERE string::starts_with(idempotency_key, "diff-1/") ORDER BY idempotency_key) == ["diff-1/m2", "diff-1/m4"]
        AND (SELECT VALUE [broadcast IS NOT NONE, actor] FROM notification_run WHERE string::starts_with(idempotency_key, "diff-1/")) == [[true, "m1"], [true, "m1"]];
};

-- test: diffusion terminée ; paquet de plus sans effet ; réservation inconnue refusée
{
    LET $c = (SELECT * FROM ONLY essai:claim);
    LET $done = fn::notification_broadcast_complete({ broadcast_id: $c.broadcast_id, claim_token: $c.claim_token }).data;
    RETURN $done.status == "completed" AND $done.created == 2
        AND fn::notification_broadcast_step({ broadcast_id: $c.broadcast_id, claim_token: $c.claim_token }).error.code == "NOTIFICATION_JOB_CLAIM_LOST"
        AND fn::notification_broadcast_claim({ worker_id: "w1" }).data IS NONE;
};

-- test: diffusion à tous les abonnés de la portée ; réservation reprise après expiration (worker arrêté)
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "tous-1", to: { all: true } });
    LET $first = fn::notification_broadcast_claim({ worker_id: "w1", lease_seconds: 10 }).data;
    UPDATE notification_broadcast SET locked_until = time::now() - 1s WHERE idempotency_key = "tous-1";
    LET $second = fn::notification_broadcast_claim({ worker_id: "w2" }).data;
    LET $lost = fn::notification_broadcast_step({ broadcast_id: <string> $first.broadcast_id, claim_token: $first.claim_token });
    LET $r = fn::notification_broadcast_step({ broadcast_id: <string> $second.broadcast_id, claim_token: $second.claim_token }).data;
    LET $done = fn::notification_broadcast_complete({ broadcast_id: <string> $second.broadcast_id, claim_token: $second.claim_token }).data;
    RETURN $lost.error.code == "NOTIFICATION_JOB_CLAIM_LOST"
        AND $r == { processed: 6, created: 5, skipped: 1, done: true } AND $done.status == "completed"
        AND count(SELECT id FROM notification_run WHERE string::starts_with(idempotency_key, "tous-1/")) == 5;
};

-- test: une autre organisation ne diffuse pas chez Alpha
-- en tant que: autre
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "annonce", idempotency_key: "x-1", to: { all: true } }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND count(SELECT id FROM notification_broadcast) == 0;

-- test: déclenchement interne d'un abonné : sans adresse pour aucun canal du parcours, rien n'est créé
RETURN fn::notification_run_create({
    tenant: auth_organization:alpha, workflow: (SELECT * FROM ONLY notification_workflow:annonce),
    subscriber: fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "m5" }),
    idempotency_key: "interne-1", payload: {}, settings: fn::notification_settings_effective({ tenant: auth_organization:alpha })
}).status == "no_address" AND count(SELECT id FROM notification_run WHERE idempotency_key = "interne-1") == 0;

-- test: purge : une diffusion terminée au-delà de sa conservation est supprimée
{
    UPDATE notification_broadcast SET purge_after = time::now() - 1s WHERE status = "completed";
    RETURN fn::notification_purge({ limit: 100 }).data.broadcasts == 2 AND count(SELECT id FROM notification_broadcast) == 0;
};

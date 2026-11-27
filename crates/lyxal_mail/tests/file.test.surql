-- lyxal-test: assertions
-- File d'envoi (lot 6, §5, décisions E4 à E7) : réservation dans l'ordre de l'échéancier, bail et
-- jeton ; garde (jeton périmé, bail échu, autre réservation : MAIL_QUEUE_CLAIM_LOST) ; reprise d'un
-- bail expiré sans essai compté ; préparation par le worker (jeton de retour, préfixe, message
-- illisible) ; remises, échecs temporaires et définitifs, échéance suivante bornée, retard une fois,
-- expiration 4.4.7 ; suspension d'une destination puis remise à zéro ; rendu sans essai ; avis dus
-- et notés une fois ; événements mail.submission.* une fois par destinataire, sans adresse ni
-- domaine, aucun pour un avis ; lots bornés ; échéancier égal à la table après chaque opération ;
-- mesures ; maintenance ; aucune fonction de file pour un titulaire ou un administrateur.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "mail.send", "auth.member.read", "auth.organization.settings.manage"] }
-- identité jean: { "id": "auth_session:jean", "pv": 1, "permissions": ["mail.mailbox.access", "mail.send"] }
-- identité marie: { "id": "auth_session:marie", "pv": 1, "permissions": ["mail.send"] }
-- identité paul: { "id": "auth_session:paul", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "mail.send", "auth.member.read", "auth.organization.settings.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["mail.worker", "storage.worker"] }
-- identité relais: { "id": "auth_session:relais", "pv": 1, "permissions": ["mail.relay", "storage.worker"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["mail.installation.manage"] }

-- préparation: organisations alpha et beta, identités et sessions lyxal_auth, domaines vérifiés, table de passage
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $person IN [["admin", "alpha"], ["jean", "alpha"], ["marie", "alpha"], ["paul", "alpha"], ["autre", "beta"]] {
        LET $identity = type::record("auth_identity", $person[0]);
        LET $organization = type::record("auth_organization", $person[1]);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($person[0], "@lyxal.test") } };
        RELATE $identity->auth_member_of->$organization;
        CREATE type::record("auth_session", $person[0]) CONTENT { identity: $identity, organization: $organization, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    FOR $name IN ["worker", "relais", "plateforme"] {
        CREATE type::record("auth_identity", $name) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test") } };
        CREATE type::record("auth_session", $name) CONTENT { identity: type::record("auth_identity", $name), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_organization_domain:alpha CONTENT { organization: auth_organization:alpha, domain: "alpha.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:beta CONTENT { organization: auth_organization:beta, domain: "beta.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: domaines, comptes de jean, marie et paul (alpha) et d'autre (beta), alias equipe (jean écrit en son nom) et direction, expéditeur des modules noreply, buckets chiffrés du courrier
{
    LET $domain = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).data.id;
    LET $domain_beta = fn::mail_domain_create({ auth_domain: "auth_organization_domain:beta" }).data.id;
    LET $jean = fn::mail_account_create({ identity: "auth_identity:jean", domain: <string> $domain, local_part: "jean" }).data.account.id;
    LET $marie = fn::mail_account_create({ identity: "auth_identity:marie", domain: <string> $domain, local_part: "marie" }).data.account.id;
    LET $paul = fn::mail_account_create({ identity: "auth_identity:paul", domain: <string> $domain, local_part: "paul" }).data.account.id;
    LET $autre = fn::mail_account_create({ identity: "auth_identity:autre", domain: <string> $domain_beta, local_part: "autre" }).data.account.id;
    LET $equipe = fn::mail_address_create({ domain: <string> $domain, local_part: "equipe", kind: "alias", targets: [<string> $jean, <string> $marie], senders: [<string> $jean] }).data.id;
    LET $direction = fn::mail_address_create({ domain: <string> $domain, local_part: "direction", kind: "alias", targets: [<string> $marie] }).data.id;
    fn::mail_domain_update({ domain: <string> $domain, module_senders: ["noreply"] });
    fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "lyxal-mail", encrypted: true, emit_events: false });
    fn::storage_bucket_create({ tenant: "auth_organization:beta", name: "lyxal-mail", encrypted: true, emit_events: false });
    CREATE passe:ids CONTENT {
        domain: <string> $domain, domain_beta: <string> $domain_beta, equipe: <string> $equipe, direction: <string> $direction,
        jean: <string> $jean, marie: <string> $marie, paul: <string> $paul, autre: <string> $autre
    };
    DEFINE FUNCTION OVERWRITE fn::essai_id($name: string) -> string { RETURN (SELECT * FROM ONLY passe:ids)[$name]; };
    DEFINE FUNCTION OVERWRITE fn::essai_garder($name: string, $value: any) -> any { UPSERT passe:ids MERGE object::from_entries([[$name, $value]]); RETURN $value; };
};

-- préparation: aides d'essai : fichier écrit à la clé d'un envoi, clôture, envoi d'un module prêt en file, échéancier recalculé, événements d'envoi
{
    -- Fichier chiffré écrit par lyxal_storage à la clé d'un envoi (session de l'essai : système)
    DEFINE FUNCTION OVERWRITE fn::essai_fichier($submission: string) -> string {
        LET $row = (SELECT tenant, content FROM ONLY type::record($submission));
        LET $bucket = (SELECT VALUE id FROM ONLY storage_bucket WHERE tenant = $row.tenant AND name = "lyxal-mail" LIMIT 1);
        LET $object = fn::storage_object_begin({ bucket: <string> $bucket, key: $row.content.key, filename: "message.eml", declared_size: $row.content.size }).data;
        fn::storage_object_commit({ object: <string> $object.id, size: $row.content.size, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key: "enc:v2:essai-files-1:QUJD" });
        RETURN <string> $object.id;
    };
    -- Clôture d'un dépôt par la session système de l'hôte (fichier écrit puis destinataires en file)
    DEFINE FUNCTION OVERWRITE fn::essai_clore($submission: string) -> object {
        RETURN fn::mail_submission_commit({ submission: $submission, object: fn::essai_fichier($submission) });
    };
    -- Envoi d'un module (session système), clos : identifiant
    DEFINE FUNCTION OVERWRITE fn::essai_module($recipients: array) -> string {
        LET $begun = fn::mail_submission_begin({ origin: "module", from: "noreply@alpha.test", header_from: ["noreply@alpha.test"], recipients: $recipients, size: 100, client_reference: "job_42" });
        IF !$begun.ok { THROW $begun.error.code; };
        LET $closed = fn::essai_clore(<string> $begun.data.submission);
        IF !$closed.ok { THROW $closed.error.code; };
        RETURN <string> $begun.data.submission;
    };
    -- Échéancier égal à la table : une fiche par destinataire scheduled (échéance) ou running (fin du bail), aucune autre
    DEFINE FUNCTION OVERWRITE fn::essai_echeancier() -> bool {
        LET $open = (SELECT id, state, next_attempt_at, locked_until FROM mail_queue_recipient WHERE state IN ["scheduled", "running"]);
        LET $expected = array::sort::asc(array::map($open, |$r| <string> fn::mail_queue_due_key(IF $r.state = "scheduled" { $r.next_attempt_at } ELSE { $r.locked_until }, $r.id)));
        RETURN $expected == array::sort::asc((SELECT VALUE <string> id FROM mail_queue_due));
    };
    DEFINE FUNCTION OVERWRITE fn::essai_evenements($kind: string) -> array {
        RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = $kind ORDER BY created_at);
    };
};

-- test: aucune fonction de la file pour un titulaire ou un administrateur
-- en tant que: jean
RETURN [
    fn::mail_queue_claim({ node: "n1" }), fn::mail_queue_renew({ claim: "01a21a8f-2d4f-7ce2-9e67-5063e68bfb08", recipients: ["mail_queue_recipient:x"] }),
    fn::mail_queue_prepare({ claim: "01a21a8f-2d4f-7ce2-9e67-5063e68bfb08", submission: "mail_submission:x" }),
    fn::mail_queue_complete({ claim: "01a21a8f-2d4f-7ce2-9e67-5063e68bfb08", items: [{ recipient: "mail_queue_recipient:x", outcome: "delivered" }] }),
    fn::mail_queue_fail({ claim: "01a21a8f-2d4f-7ce2-9e67-5063e68bfb08", items: [{ recipient: "mail_queue_recipient:x", permanent: true, stage: "rcpt" }] }),
    fn::mail_queue_release({ claim: "01a21a8f-2d4f-7ce2-9e67-5063e68bfb08", recipients: ["mail_queue_recipient:x"] }),
    fn::mail_queue_dsn_done({ submission: "mail_submission:x", action: "failed", recipients: ["mail_queue_recipient:x"] }),
    fn::mail_queue_stats({}), fn::mail_queue_purge({}),
    fn::mail_return_record({ submission: "mail_submission:x", items: [{ recipient: "mail_queue_recipient:x", action: "failed" }] })
].all(|$r| $r.error.code == "MAIL_PERMISSION_DENIED");

-- test: l'administrateur de l'organisation n'a pas la file
-- en tant que: admin
RETURN fn::mail_queue_claim({ node: "n1" }).error.code == "MAIL_PERMISSION_DENIED" AND fn::mail_queue_stats({}).error.code == "MAIL_PERMISSION_DENIED";

-- test: file vide : rien à réserver ; entrées refusées par lyxal_core
-- en tant que: worker
RETURN fn::mail_queue_claim({ node: "n1" }).data == { claim: NONE, items: [] }
    AND [{}, { node: "n1", limit: 0 }, { node: "n1", limit: 501 }, { node: "n1", lease_seconds: 30 }, { node: "n1", autre: 1 }].all(|$p| fn::mail_queue_claim($p).error.code == "MAIL_INVALID_PARAMETERS");

-- préparation: envoi d'un module à deux destinataires de domaines différents, en file
{
    fn::essai_garder("a", fn::essai_module([{ address: "a@un.test" }, { address: "b@deux.test" }]));
};

-- test: réservation dans l'ordre de l'échéancier, sous bail et jeton : un destinataire à la fois
-- en tant que: worker
{
    LET $first = fn::mail_queue_claim({ node: "n1", limit: 1, lease_seconds: 600 });
    LET $second = fn::mail_queue_claim({ node: "n2", limit: 10 });
    LET $third = fn::mail_queue_claim({ node: "n3" });
    fn::essai_garder("claim1", $first.data.claim);
    fn::essai_garder("claim2", $second.data.claim);
    LET $item = $first.data.items[0];
    RETURN $first.ok AND array::len($first.data.items) == 1 AND $item.rank == 0 AND $item.address == "a@un.test" AND $item.domain == "un.test"
        AND $item.origin == "module" AND $item.prepared == false AND $item.sender == "noreply@alpha.test" AND $item.envelope_from IS NONE AND $item.attempts == 0
        AND $item.content.key == (SELECT VALUE content.key FROM ONLY type::record(fn::essai_id("a"))) AND $item.content.object IS NOT NONE
        AND $second.data.items.rank == [1] AND $second.data.claim != $first.data.claim
        AND $third.data == { claim: NONE, items: [] };
};

-- test: réservation : destinataires running sous la fin du bail dans l'échéancier, rien d'échu
RETURN fn::essai_echeancier()
    AND (SELECT VALUE [state, claimed_by] FROM mail_queue_recipient WHERE submission = type::record(fn::essai_id("a")) ORDER BY rank) == [["running", "n1"], ["running", "n2"]]
    AND (SELECT VALUE at FROM mail_queue_due).all(|$at| $at > time::now() + 9m);

-- test: préparation : jeton exigé (expéditeur non vide), garde de la réservation, adresse de retour posée une fois
-- en tant que: worker
{
    LET $submission = fn::essai_id("a");
    LET $missing = fn::mail_queue_prepare({ claim: fn::essai_id("claim1"), submission: $submission });
    LET $stranger = fn::mail_queue_prepare({ claim: "01a21a8f-2d4f-7ce2-9e67-5063e68bfb08", submission: $submission, return_token: "0123456789abcdefghjkmnpqrs" });
    LET $badtoken = fn::mail_queue_prepare({ claim: fn::essai_id("claim1"), submission: $submission, return_token: "0123456789ABCDEFGHJKMNPQRS" });
    LET $prepared = fn::mail_queue_prepare({ claim: fn::essai_id("claim1"), submission: $submission, return_token: "0123456789abcdefghjkmnpqrs", prefix: "DKIM-Signature: v=1; a=ed25519-sha256\r\n" });
    LET $again = fn::mail_queue_prepare({ claim: fn::essai_id("claim1"), submission: $submission, return_token: "1123456789abcdefghjkmnpqrs" });
    LET $row = (SELECT envelope_from, return_token, prefix, prepared_at, return_expires_at, expires_at FROM ONLY type::record($submission));
    RETURN $missing.error.details == { fields: { return_token: ["required"] } } AND $stranger.error.code == "MAIL_QUEUE_CLAIM_LOST"
        AND $badtoken.error.code == "MAIL_INVALID_PARAMETERS"
        AND $prepared.data == { prepared: true, envelope_from: "rp=0123456789abcdefghjkmnpqrs@alpha.test", failed: 0, dsn: [] }
        AND $again.error.code == "MAIL_SUBMISSION_STATE_INVALID"
        AND $row.return_token == "0123456789abcdefghjkmnpqrs" AND $row.prefix == "DKIM-Signature: v=1; a=ed25519-sha256\r\n" AND $row.return_expires_at == $row.expires_at + 14d;
};

-- test: garde : remise écrite avec un jeton étranger refusée sans rien écrire ; lot trop grand refusé
-- en tant que: worker
{
    LET $recipient = <string> fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 0);
    LET $lost = fn::mail_queue_complete({ claim: fn::essai_id("claim2"), items: [{ recipient: $recipient, outcome: "delivered" }] });
    LET $big = fn::mail_queue_complete({ claim: fn::essai_id("claim1"), items: array::map(<array> (0..101), |$i| { recipient: $recipient, outcome: "delivered" }) });
    LET $bad = fn::mail_queue_complete({ claim: fn::essai_id("claim1"), items: [{ recipient: $recipient, outcome: "parti" }] });
    RETURN $lost.error.{ code, details } == { code: "MAIL_QUEUE_CLAIM_LOST", details: { lost: [type::record($recipient)] } }
        AND $big.error.{ code, details } == { code: "MAIL_QUEUE_BATCH_TOO_LARGE", details: { max_items: 100 } }
        AND $bad.error.code == "MAIL_INVALID_PARAMETERS"
        AND (SELECT VALUE state FROM ONLY type::record($recipient)) == "running";
};

-- test: remise réussie : delivered, résultat gardé, aucun avis pour un module ; un élément perdu rendu dans lost
-- en tant que: worker
{
    LET $r0 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 0);
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    LET $done = fn::mail_queue_complete({ claim: fn::essai_id("claim1"), items: [
        { recipient: <string> $r0, outcome: "delivered", host: "mx.un.test", code: 250, enhanced: "2.0.0", tls: { version: "TLSv1.3", verified: false } },
        { recipient: <string> $r1, outcome: "delivered" }
    ] });
    LET $row = (SELECT state, final_at, claim, locked_until, last_result FROM ONLY $r0);
    RETURN $done.data == { dsn: [], lost: [$r1] } AND $row.state == "delivered" AND $row.final_at IS NOT NONE AND $row.locked_until IS NONE
        AND $row.last_result.{ stage, code, enhanced, host, tls } == { stage: "data", code: 250, enhanced: "2.0.0", host: "mx.un.test", tls: { version: "TLSv1.3", verified: false } };
};

-- test: événement mail.submission.delivered : une fois, sans adresse ni domaine, avec la référence du module
{
    LET $events = fn::essai_evenements("mail.submission.delivered");
    RETURN array::len($events) == 1 AND object::keys($events[0]).sort() == ["at", "attempts", "client_reference", "local", "origin", "outcome", "rank", "recipient", "status", "submission", "tenant"]
        AND $events[0].{ rank, origin, client_reference, status, attempts, local, outcome, tenant } == { rank: 0, origin: "module", client_reference: "job_42", status: "2.0.0", attempts: 0, local: false, outcome: "delivered", tenant: "auth_organization:alpha" }
        AND fn::essai_echeancier();
};

-- test: échec temporaire : essai compté, échéance suivante bornée (5 min ± 10 %), destination injoignable suspendue 5 min
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    LET $start = time::now();
    LET $failed = fn::mail_queue_fail({ claim: fn::essai_id("claim2"), items: [{ recipient: <string> $r1, permanent: false, stage: "connect", text: "Connexion refusée" }], destination: { domain: "deux.test", unreachable: true } });
    LET $row = (SELECT state, attempts, next_attempt_at, last_result, claim FROM ONLY $r1);
    LET $destination = (SELECT * FROM ONLY mail_queue_destination:⟨deux.test⟩);
    RETURN $failed.data.items == [{ recipient: $r1, state: "scheduled", next_attempt_at: $row.next_attempt_at }] AND $failed.data.dsn == [] AND $failed.data.lost == []
        AND $row.state == "scheduled" AND $row.attempts == 1 AND $row.last_result.{ stage, text } == { stage: "connect", text: "Connexion refusée" }
        AND $row.next_attempt_at >= $start + 270s AND $row.next_attempt_at <= time::now() + 330s
        AND $destination.consecutive_failures == 1 AND $destination.suspended_until >= $start + 299s AND $destination.suspended_until <= time::now() + 301s
        AND fn::essai_echeancier();
};

-- test: destination suspendue écartée de la réservation, même échue ; reprise à la fin de la suspension
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    UPDATE $r1 SET next_attempt_at = time::now() - 1s;
    LET $hidden = fn::mail_queue_claim({ node: "n1" });
    UPDATE mail_queue_destination:⟨deux.test⟩ SET suspended_until = time::now() - 1s;
    LET $excluded = fn::mail_queue_claim({ node: "n1", exclude_domains: ["DEUX.test"] });
    LET $back = fn::mail_queue_claim({ node: "n1" });
    fn::essai_garder("claim3", $back.data.claim);
    RETURN $hidden.data.items == [] AND $excluded.data.items == [] AND $back.data.items.recipient == [$r1] AND $back.data.items[0].prepared == true
        AND $back.data.items[0].envelope_from == "rp=0123456789abcdefghjkmnpqrs@alpha.test" AND $back.data.items[0].attempts == 1
        AND $back.data.items[0].prefix == "DKIM-Signature: v=1; a=ed25519-sha256\r\n";
};

-- test: second échec de connexion : suspension doublée ; une réponse de serveur remet le compteur à zéro
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    LET $failed = fn::mail_queue_fail({ claim: fn::essai_id("claim3"), items: [{ recipient: <string> $r1, permanent: false, stage: "greeting", code: 421 }], destination: { domain: "deux.test", unreachable: true, stage: "greeting" } });
    LET $suspended = (SELECT VALUE suspended_until FROM ONLY mail_queue_destination:⟨deux.test⟩);
    LET $row = (SELECT next_attempt_at, attempts FROM ONLY $r1);
    UPDATE $r1 SET next_attempt_at = time::now() - 1s;
    UPDATE mail_queue_destination:⟨deux.test⟩ SET suspended_until = time::now() - 1s;
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    LET $answered = fn::mail_queue_fail({ claim: $claimed.data.claim, items: [{ recipient: <string> $r1, permanent: false, stage: "rcpt", code: 451, enhanced: "4.7.1" }], destination: { domain: "deux.test", unreachable: false } });
    fn::essai_garder("claim4", $claimed.data.claim);
    RETURN $failed.ok AND $suspended >= time::now() + 9m AND $row.attempts == 2 AND $row.next_attempt_at >= $suspended
        AND $answered.data.items[0].state == "scheduled"
        AND (SELECT VALUE [consecutive_failures, suspended_until] FROM ONLY mail_queue_destination:⟨deux.test⟩) == [0, NONE]
        AND (SELECT VALUE attempts FROM ONLY $r1) == 3;
};

-- test: reprise après un arrêt brutal : bail expiré sans écriture, nouvelle réservation qui reprend le destinataire sans essai compté ; l'ancien jeton est refusé
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    UPDATE $r1 SET next_attempt_at = time::now() - 1s;
    LET $crashed = fn::mail_queue_claim({ node: "perdu", lease_seconds: 60 });
    -- Le nœud s'arrête : son bail expire, rien n'est écrit
    UPDATE $r1 SET locked_until = time::now() - 1s;
    LET $echeancier = fn::essai_echeancier();
    LET $resumed = fn::mail_queue_claim({ node: "repreneur" });
    LET $stale = fn::mail_queue_complete({ claim: $crashed.data.claim, items: [{ recipient: <string> $r1, outcome: "delivered" }] });
    LET $stale_renew = fn::mail_queue_renew({ claim: $crashed.data.claim, recipients: [<string> $r1] });
    LET $renewed = fn::mail_queue_renew({ claim: $resumed.data.claim, recipients: [<string> $r1], lease_seconds: 1800 });
    fn::essai_garder("claim5", $resumed.data.claim);
    RETURN $crashed.data.items.recipient == [$r1] AND $echeancier AND $resumed.data.items.recipient == [$r1] AND $resumed.data.claim != $crashed.data.claim
        AND $resumed.data.items[0].attempts == 3 AND $stale.error.code == "MAIL_QUEUE_CLAIM_LOST" AND $stale_renew.error.code == "MAIL_QUEUE_CLAIM_LOST"
        AND $renewed.data.renewed == 1 AND $renewed.data.lost == []
        AND (SELECT VALUE [claimed_by, attempts] FROM ONLY $r1) == ["repreneur", 3]
        AND (SELECT VALUE locked_until FROM ONLY $r1) > time::now() + 29m AND fn::essai_echeancier();
};

-- test: un nœud dont la réservation est perdue ne suspend pas la destination : MAIL_QUEUE_CLAIM_LOST, destination inchangée
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    LET $initial = (SELECT VALUE [consecutive_failures, suspended_until] FROM ONLY mail_queue_destination:⟨deux.test⟩);
    LET $stale = fn::mail_queue_fail({ claim: <string> rand::uuid::v7(), items: [{ recipient: <string> $r1, permanent: false, stage: "connect" }], destination: { domain: "deux.test", unreachable: true } });
    RETURN $stale.error.code == "MAIL_QUEUE_CLAIM_LOST"
        AND (SELECT VALUE [consecutive_failures, suspended_until] FROM ONLY mail_queue_destination:⟨deux.test⟩) == $initial
        AND (SELECT VALUE claimed_by FROM ONLY $r1) == "repreneur";
};

-- test: rendu sans essai compté (arrêt propre, cadence) : échéance donnée, jeton effacé ; lot de 501 refusé
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    LET $at = time::now() + 1h;
    LET $big = fn::mail_queue_release({ claim: fn::essai_id("claim5"), recipients: array::map(<array> (0..501), |$i| <string> $r1) });
    LET $released = fn::mail_queue_release({ claim: fn::essai_id("claim5"), recipients: [<string> $r1], not_before: $at });
    LET $row = (SELECT state, attempts, next_attempt_at, locked_until FROM ONLY $r1);
    RETURN $big.error.code == "MAIL_QUEUE_BATCH_TOO_LARGE" AND $released.data == { released: 1, lost: [] }
        AND $row == { state: "scheduled", attempts: 3, next_attempt_at: $at, locked_until: NONE }
        AND fn::mail_queue_claim({ node: "n1" }).data.items == [] AND fn::essai_echeancier();
};

-- test: expiration : un échec temporaire après la fin de vie de l'envoi expire le destinataire (4.4.7), mail.submission.failed
-- en tant que: worker
{
    LET $r1 = fn::mail_queue_recipient_key(type::record(fn::essai_id("a")), 1);
    UPDATE $r1 SET next_attempt_at = time::now() - 1s;
    UPDATE type::record(fn::essai_id("a")) SET expires_at = time::now() - 1s;
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    LET $failed = fn::mail_queue_fail({ claim: $claimed.data.claim, items: [{ recipient: <string> $r1, permanent: false, stage: "rcpt", code: 450 }] });
    LET $row = (SELECT state, attempts, last_result, final_at FROM ONLY $r1);
    LET $submission = (SELECT state, open_count, done_at, return_expires_at FROM ONLY type::record(fn::essai_id("a")));
    RETURN $failed.data.items[0].state == "expired" AND $row.state == "expired" AND $row.attempts == 4 AND $row.last_result.{ stage, enhanced, code } == { stage: "expired", enhanced: "4.4.7", code: 450 }
        AND $submission.state == "done" AND $submission.open_count == 0 AND $submission.return_expires_at > time::now() + 13d
        AND fn::essai_echeancier() AND array::len(SELECT * FROM mail_queue_due) == 0;
};

-- test: expiration : mail.submission.failed (outcome expired, 4.4.7)
{
    LET $events = fn::essai_evenements("mail.submission.failed");
    RETURN array::len($events) == 1 AND $events[0].{ rank, status, attempts, outcome } == { rank: 1, status: "4.4.7", attempts: 4, outcome: "expired" };
};

-- test: dépôt de jean (avis dus) : trois destinataires, défaut, NOTIFY=NEVER, NOTIFY=SUCCESS vers un domaine de l'installation
-- en tant que: jean
{
    LET $begun = fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["jean@alpha.test"], recipients: [
        { address: "x@trois.test" }, { address: "y@trois.test", notify: ["never"] }, { address: "autre@beta.test", notify: ["success", "failure", "delay"] }
    ], size: 100 });
    RETURN fn::essai_garder("j", <string> $begun.data.submission) != NONE;
};

-- préparation: clôture du dépôt de jean par la session système
{
    fn::essai_clore(fn::essai_id("j"));
    -- Mise en file il y a 5 heures : l'avis de retard (4 h) est dû au prochain échec temporaire
    UPDATE type::record(fn::essai_id("j")) SET queued_at = time::now() - 5h;
};

-- test: préparation d'un dépôt authentifié par le worker, à la première réservation
-- en tant que: worker
{
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    fn::essai_garder("claimj", $claimed.data.claim);
    LET $submission = type::record(fn::essai_id("j"));
    RETURN array::len($claimed.data.items) == 3 AND $claimed.data.items.all(|$i| !$i.prepared AND $i.origin == "submission")
        AND fn::mail_queue_prepare({ claim: $claimed.data.claim, submission: <string> $submission, return_token: "2123456789abcdefghjkmnpqrs" }).data.envelope_from == "rp=2123456789abcdefghjkmnpqrs@alpha.test";
};

-- test: retard : premier échec temporaire après le délai → delayed_at posé, avis de retard dû une fois (pas pour NOTIFY=NEVER), mail.submission.delayed
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("j"));
    LET $r = |$rank| fn::mail_queue_recipient_key($s, $rank);
    LET $failed = fn::mail_queue_fail({ claim: fn::essai_id("claimj"), items: [0, 1, 2].map(|$i| { recipient: <string> $r($i), permanent: false, stage: "rcpt", code: 451 }) });
    RETURN $failed.data.dsn == [{ submission: $s, action: "delayed", recipients: [$r(0), $r(2)] }]
        AND (SELECT VALUE delayed_at IS NOT NONE FROM mail_queue_recipient WHERE submission = $s ORDER BY rank) == [true, true, true]
        AND fn::mail_queue_dsn_done({ submission: <string> $s, action: "delayed", recipients: [<string> $r(0), <string> $r(2)] }).data == { marked: 2 }
        AND fn::mail_queue_dsn_done({ submission: <string> $s, action: "delayed", recipients: [<string> $r(0)] }).data == { marked: 0 };
};

-- test: retard : mail.submission.delayed une fois par destinataire, sans référence de module
{
    LET $delayed = fn::essai_evenements("mail.submission.delayed");
    RETURN array::len($delayed) == 3 AND $delayed.all(|$e| $e.origin == "submission" AND $e.client_reference IS NONE);
};

-- test: un second échec temporaire ne redonne ni retard ni avis
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("j"));
    UPDATE mail_queue_recipient SET next_attempt_at = time::now() - 1s WHERE submission = $s;
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    fn::essai_garder("claimj2", $claimed.data.claim);
    LET $failed = fn::mail_queue_fail({ claim: $claimed.data.claim, items: [{ recipient: <string> fn::mail_queue_recipient_key($s, 0), permanent: false, stage: "rcpt" }] });
    RETURN $failed.data.dsn == [];
};

-- test: retard : aucun nouvel événement
RETURN array::len(fn::essai_evenements("mail.submission.delayed")) == 3;

-- test: échec définitif → avis failed dû (défaut, pas NOTIFY=NEVER) ; remise par la route locale avec NOTIFY=SUCCESS → avis delivered
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("j"));
    LET $r = |$rank| fn::mail_queue_recipient_key($s, $rank);
    LET $failed = fn::mail_queue_fail({ claim: fn::essai_id("claimj2"), items: [{ recipient: <string> $r(1), permanent: true, stage: "rcpt", code: 550, enhanced: "5.1.1", text: "User unknown" }] });
    LET $done = fn::mail_queue_complete({ claim: fn::essai_id("claimj2"), items: [{ recipient: <string> $r(2), outcome: "delivered" }] });
    RETURN $failed.data.dsn == [] AND $done.data.dsn == [{ submission: $s, action: "delivered", recipients: [$r(2)] }]
        AND (SELECT VALUE last_result.stage FROM ONLY $r(2)) == "local"
        AND fn::mail_queue_dsn_done({ submission: <string> $s, action: "delivered", recipients: [<string> $r(2)] }).data == { marked: 1 };
};

-- test: échec définitif du premier destinataire : avis failed, une seule fois ; envoi fini
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("j"));
    LET $r0 = fn::mail_queue_recipient_key($s, 0);
    UPDATE $r0 SET next_attempt_at = time::now() - 1s;
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    LET $failed = fn::mail_queue_fail({ claim: $claimed.data.claim, items: [{ recipient: <string> $r0, permanent: true, stage: "data", code: 554, enhanced: "5.7.1" }] });
    LET $marked = fn::mail_queue_dsn_done({ submission: <string> $s, action: "failed", recipients: [<string> $r0] });
    RETURN $failed.data.dsn == [{ submission: $s, action: "failed", recipients: [$r0] }] AND $marked.data == { marked: 1 }
        AND (SELECT VALUE state FROM ONLY $s) == "done"
        AND (SELECT VALUE state FROM mail_queue_recipient WHERE submission = $s ORDER BY rank) == ["failed", "failed", "delivered"];
};

-- test: événements : un par destinataire et par issue, aucun pour un avis ; aucune adresse ni domaine dans les charges
{
    LET $events = (SELECT event_type, payload FROM event_outbox WHERE string::starts_with(event_type, "mail.submission"));
    LET $text = <string> $events.payload;
    RETURN array::len(fn::essai_evenements("mail.submission.failed")) == 3 AND array::len(fn::essai_evenements("mail.submission.delivered")) == 2
        AND !string::contains($text, "@") AND !string::contains($text, "trois.test") AND !string::contains($text, "un.test") AND !string::contains($text, "User unknown");
};

-- test: avis vers l'extérieur (origine dsn) déposé par le compte de service : expéditeur vide exigé, aucun avis ni événement sur un avis
-- en tant que: worker
{
    LET $begun = fn::mail_submission_begin({ origin: "dsn", from: "", header_from: ["mailer-daemon@mx.lyxal.test"], recipients: [{ address: "origine@ailleurs.test" }], size: 300, tenant: "auth_organization:alpha", prefix: "Received: x\r\n" });
    LET $refused = fn::mail_submission_begin({ origin: "dsn", from: "a@alpha.test", header_from: ["mailer-daemon@mx.lyxal.test"], recipients: [{ address: "origine@ailleurs.test" }], size: 300, tenant: "auth_organization:alpha" });
    fn::essai_garder("avis", <string> $begun.data.submission);
    RETURN $begun.ok AND $begun.data.return_address IS NONE AND $refused.error.code == "MAIL_INVALID_PARAMETERS"
        AND (SELECT VALUE [prepared_at IS NOT NONE, prefix, sender] FROM ONLY $begun.data.submission) == [true, "Received: x\r\n", NONE];
};

-- test: avis vers l'extérieur : remis puis échoué sans événement
-- en tant que: worker
{
    LET $object = fn::essai_fichier(fn::essai_id("avis"));
    fn::mail_submission_commit({ submission: fn::essai_id("avis"), object: $object });
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    LET $failed = fn::mail_queue_fail({ claim: $claimed.data.claim, items: [{ recipient: <string> $claimed.data.items[0].recipient, permanent: true, stage: "rcpt" }] });
    RETURN $claimed.data.items[0].prepared AND $failed.data.dsn == [];
};

-- test: avis vers l'extérieur : aucun événement
RETURN array::len(fn::essai_evenements("mail.submission.failed")) == 3 AND array::len(SELECT * FROM event_outbox WHERE payload.origin = "dsn") == 0;

-- test: mesures de la file (session système)
{
    fn::essai_module([{ address: "m1@quatre.test" }, { address: "m2@quatre.test" }]);
    LET $stats = fn::mail_queue_stats({});
    RETURN $stats.ok AND $stats.data.scheduled == 2 AND $stats.data.running == 0 AND $stats.data.due == 2 AND $stats.data.oldest_due_at <= time::now()
        AND $stats.data.suspended_destinations == 0;
};

-- test: réservation bornée : 2 000 destinataires en attente plus tard, deux échus ; seuls les échus sont lus (session système)
{
    -- 20 envois de modules de 100 destinataires (limite d'un envoi de module)
    FOR $n IN <array> (0..20) { fn::essai_module(array::map(<array> (0..100), |$i| { address: string::concat("p", <string> $n, "_", <string> $i, "@cinq.test") })); };
    UPDATE mail_queue_recipient SET next_attempt_at = time::now() + 1d WHERE domain = "cinq.test";
    LET $claimed = fn::mail_queue_claim({ node: "n1", limit: 500 });
    RETURN $claimed.data.items.address == ["m1@quatre.test", "m2@quatre.test"] AND fn::essai_echeancier() AND array::len(SELECT * FROM mail_queue_due) == 2002;
};

-- test: réservation : 1 200 destinataires échus d'une destination suspendue en tête de l'échéancier n'affament pas les autres (fenêtres successives) (session système)
{
    FOR $n IN <array> (0..12) { fn::essai_module(array::map(<array> (0..100), |$i| { address: string::concat("b", <string> $n, "_", <string> $i, "@bouchon.test") })); };
    UPSERT mail_queue_destination:⟨bouchon.test⟩ SET consecutive_failures = 1, suspended_until = time::now() + 5m;
    fn::essai_module([{ address: "apres1@sept.test" }, { address: "apres2@sept.test" }]);
    LET $claimed = fn::mail_queue_claim({ node: "n1", limit: 500 });
    RETURN $claimed.data.items.address == ["apres1@sept.test", "apres2@sept.test"]
        AND count(SELECT VALUE id FROM mail_queue_recipient WHERE domain = "bouchon.test" AND state = "scheduled") == 1200;
};

-- test: message illisible à la préparation : destinataires en attente et tenus en échec définitif 5.6.0, aucun avis pour un module (session système)
{
    LET $s = type::record(fn::essai_module([{ address: "i1@six.test" }, { address: "i2@six.test" }]));
    UPDATE mail_queue_recipient SET next_attempt_at = time::now() + 1d WHERE domain = "cinq.test";
    LET $claimed = fn::mail_queue_claim({ node: "n1", limit: 1 });
    LET $prepared = fn::mail_queue_prepare({ claim: $claimed.data.claim, submission: <string> $s, return_token: "3123456789abcdefghjkmnpqrs", malformed: true });
    RETURN $claimed.data.items[0].submission == $s AND $prepared.data.{ prepared, failed, dsn } == { prepared: true, failed: 2, dsn: [] }
        AND (SELECT VALUE [state, last_result.enhanced, last_result.code] FROM mail_queue_recipient WHERE submission = $s ORDER BY rank) == [["failed", "5.6.0", 554], ["failed", "5.6.0", 554]]
        AND (SELECT VALUE state FROM ONLY $s) == "done" AND fn::essai_echeancier();
};

-- test: maintenance : fichiers des envois finis supprimés, dépôts abandonnés retirés, jetons échus effacés, compteurs échus retirés
{
    -- Dépôt abandonné et compteur d'une fenêtre passée
    LET $abandoned = fn::mail_submission_begin({ origin: "module", from: "noreply@alpha.test", header_from: ["noreply@alpha.test"], recipients: [{ address: "z@ailleurs.test" }], size: 10 });
    fn::mail_submission_abort({ submission: <string> $abandoned.data.submission });
    CREATE mail_send_counter:ancien CONTENT { tenant: auth_organization:alpha, kind: "module_messages", count: 3, expires_at: time::now() - 1d };
    UPDATE type::record(fn::essai_id("j")) SET return_expires_at = time::now() - 1s;
    LET $object = (SELECT VALUE content.object FROM ONLY type::record(fn::essai_id("a")));
    LET $purged = fn::mail_queue_purge({ limit: 100 });
    RETURN $purged.ok AND $purged.data.submissions == 1 AND $purged.data.contents == 5 AND $purged.data.tokens == 1 AND $purged.data.counters == 1
        AND (SELECT VALUE state FROM ONLY $object) == "deleted"
        AND (SELECT VALUE content.removed_at IS NOT NONE FROM ONLY type::record(fn::essai_id("a"))) == true
        AND !record::exists($abandoned.data.submission)
        AND (SELECT VALUE return_token FROM ONLY type::record(fn::essai_id("j"))) IS NONE;
};

-- test: maintenance : envois finis depuis 14 jours retirés avec leurs destinataires
{
    UPDATE type::record(fn::essai_id("a")) SET done_at = time::now() - 15d;
    LET $purged = fn::mail_queue_purge({});
    RETURN $purged.data.submissions == 1 AND !record::exists(type::record(fn::essai_id("a")))
        AND array::len(SELECT * FROM mail_queue_recipient WHERE submission = type::record(fn::essai_id("a"))) == 0;
};

-- test: règles internes de l'envoi : échéances (délai par essai, dernier délai répété, décalage borné), échéancier, clés, garde, avis regroupés
{
    LET $now = time::now();
    LET $settings = fn::mail_settings_effective({});
    LET $first = fn::mail_queue_next_attempt(1, $settings, $now);
    LET $tenth = fn::mail_queue_next_attempt(10, $settings, $now);
    LET $flat = fn::mail_queue_next_attempt(3, object::extend($settings, { retry_jitter_percent: 0 }), $now);
    RETURN $first >= $now + 270s AND $first <= $now + 330s AND $tenth >= $now + 108m AND $tenth <= $now + 132m AND $flat == $now + 20m
        AND fn::mail_queue_due_at({ state: "scheduled", next_attempt_at: $now, locked_until: NONE }) == $now
        AND fn::mail_queue_due_at({ state: "running", next_attempt_at: $now - 1h, locked_until: $now }) == $now
        AND fn::mail_queue_due_at({ state: "failed", next_attempt_at: $now }) IS NONE AND fn::mail_queue_due_at(NONE) IS NONE
        AND fn::mail_queue_recipient_key_text(mail_submission:sabc, 3) == "sabc_1003"
        AND fn::mail_queue_due_key(d"2026-01-01T00:00:00Z", mail_queue_recipient:sabc_1003) == type::record("mail_queue_due", string::concat(<string> (10000000000000000 + time::micros(d"2026-01-01T00:00:00Z")), "_sabc_1003"))
        AND fn::mail_queue_held(mail_queue_recipient:absent, "c", $now) IS NONE
        AND fn::mail_queue_fail_item({ recipient: mail_queue_recipient:absent, permanent: true, stage: "rcpt" }, "c", $now, $settings, NONE) IS NONE
        AND fn::mail_queue_destination_record(NONE, $now) IS NONE
        AND fn::mail_queue_dsn_groups([{ submission: 1, action: "failed", recipient: "a" }, { submission: 1, action: "failed", recipient: "b" }, { submission: 2, action: "delayed", recipient: "c" }])
            == [{ submission: 1, action: "failed", recipients: ["a", "b"] }, { submission: 2, action: "delayed", recipients: ["c"] }]
        AND fn::mail_absent().valid AND fn::mail_absent().value IS NONE
        AND fn::mail_queue_worker_writer()
        AND fn::mail_queue_due_read($now, 3, []).all(|$d| $d.domain != "bouchon.test") AND array::len(fn::mail_queue_due_read($now, 3, ["bouchon.test"])) <= 3;
};

-- test: règles internes : un titulaire n'écrit pas en compte de service
-- en tant que: jean
RETURN !fn::mail_queue_worker_writer();

-- test: règles internes : contrôle des lots du worker par lyxal_core (rapport, borne, perte de la réservation)
{
    LET $item = { recipient: "mail_queue_recipient:x", outcome: "delivered", tls: { version: "TLSv1.2", verified: true } };
    LET $report = fn::mail_queue_batch_report({ items: [$item] }, "complete", 2, { claim: fn::mail_absent() });
    LET $large = fn::mail_queue_batch_report({ items: [$item, $item, $item] }, "complete", 2, { claim: fn::mail_absent() });
    RETURN fn::mail_queue_item_check("complete", $item).valid AND !fn::mail_queue_item_check("complete", object::extend($item, { tls: { verified: "oui" } })).valid
        AND fn::mail_queue_item_check("fail", { recipient: "mail_queue_recipient:x", permanent: false, stage: "dns" }).valid
        AND !fn::mail_queue_item_check("return", { recipient: "mail_queue_recipient:x", action: "failed", autre: 1 }).valid
        AND $report.valid AND $report.value.items[0].recipient == mail_queue_recipient:x
        AND fn::mail_queue_batch_error($large, {}, 2).error.code == "MAIL_QUEUE_BATCH_TOO_LARGE"
        AND fn::mail_queue_batch_error(fn::mail_queue_batch_report({ items: [{}] }, "complete", 2, {}), {}, 2).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_queue_lost([1], "fr", { done: [] }).error.code == "MAIL_QUEUE_CLAIM_LOST"
        AND fn::mail_queue_lost([1], "fr", { done: [2], n: 1 }).data == { n: 1, lost: [1] };
};

-- test: règles internes : droit d'expéditeur, expéditeurs des modules, parties locales réservées, origine d'un dépôt, destinataire, champs d'envoi d'un alias
{
    LET $jean = type::record(fn::essai_id("jean"));
    LET $domain = type::record(fn::essai_id("domain"));
    RETURN fn::mail_sender_allowed(auth_organization:alpha, $jean, ["jean@alpha.test", "", NONE, "JEAN+x@alpha.test", "jean@beta.test", "pas-une-adresse"]) == [true, true, true, true, false, false]
        AND fn::mail_sender_allowed(auth_organization:alpha, NONE, ["jean@alpha.test"]) == [false]
        AND fn::mail_module_sender_tenant("NoReply@alpha.test") == auth_organization:alpha AND fn::mail_module_sender_tenant("jean@alpha.test") IS NONE
        AND fn::mail_local_part_refusal($domain, "rp=x") == "MAIL_ADDRESS_RESERVED" AND fn::mail_local_part_refusal($domain, "noreply") == "MAIL_MODULE_SENDER_CONFLICT"
        AND fn::mail_local_part_refusal($domain, "ventes") IS NONE
        AND fn::mail_submission_origin("dsn", NONE, [], auth_organization:beta) == { tenant: auth_organization:beta, account: NONE, owner: NONE }
        AND fn::mail_submission_origin("forward", "inconnu@alpha.test", [], NONE).error == "MAIL_SENDER_FORBIDDEN"
        AND fn::mail_submission_origin("submission", "jean@alpha.test", [], NONE).error == "MAIL_PERMISSION_DENIED"
        AND fn::mail_submission_recipient_check({ address: "a@b.test", notify: ["failure"] }).valid AND !fn::mail_submission_recipient_check({ address: "a@b.test", notify: [] }).valid
        AND fn::mail_alias_sending_check(auth_organization:alpha, [type::record(fn::essai_id("autre"))], NONE).code == "MAIL_ALIAS_TARGET_INVALID"
        AND fn::mail_alias_sending_check(auth_organization:alpha, [$jean], ["x@ailleurs.test"]) IS NONE
        AND fn::mail_address_send_refusal(NONE, { kind: "account", domain: $domain, local_part: "z", senders: [$jean], forward_to: [] }) == "MAIL_WRITE_FORBIDDEN"
        AND fn::mail_address_send_refusal(NONE, { kind: "alias", tenant: auth_organization:alpha, domain: $domain, local_part: "z", senders: [], forward_to: ["x@beta.test"] }) == "MAIL_ALIAS_TARGET_INVALID";
};

-- test: règles internes : compteurs d'envoi (sortes, fenêtres, prise, limite, rendu), gardes et effets appelés hors table, charge des événements, fichier d'un envoi jamais écrit
{
    LET $at = d"2025-01-15T10:30:00Z";
    LET $row = { origin: "submission", account: type::record(fn::essai_id("jean")), tenant: auth_organization:alpha, recipient_count: 3, created_at: $at };
    LET $counters = fn::mail_send_counters($row, { send_messages_per_day: 5, send_recipients_per_day: 4 });
    LET $taken = fn::mail_send_counter_take($counters);
    LET $over = fn::mail_send_counter_take($counters);
    fn::mail_send_counter_release($counters);
    LET $counts = (SELECT VALUE count FROM $counters.id);
    LET $module = fn::mail_send_counters(object::extend($row, { origin: "module" }), { module_messages_per_hour: 1 });
    RETURN $counters.map(|$c| [$c.kind, $c.amount, $c.limit]) == [["account_messages", 1, 5], ["account_recipients", 3, 4]]
        AND <string> $counters[0].id == string::concat("mail_send_counter:account_messages_", <string> record::id($row.account), "_20250115")
        AND $counters[0].expires_at == d"2025-01-17T00:00:00Z" AND $module[0].kind == "module_messages" AND $module[0].expires_at == d"2025-01-16T11:00:00Z"
        AND <string> $module[0].id == "mail_send_counter:module_messages_alpha_2025011510"
        AND fn::mail_send_counters(object::extend($row, { origin: "dsn" }), {}) == []
        AND $taken IS NONE AND $over == "account_recipients" AND $counts == [0, 0]
        AND fn::mail_submission_refusal(NONE, NONE) IS NONE AND fn::mail_queue_recipient_refusal(NONE, NONE) IS NONE
        AND fn::mail_submission_refusal(NONE, { state: "queued" }) == "MAIL_WRITE_FORBIDDEN"
        AND fn::mail_submission_apply({ tenant: auth_organization:absente }, NONE) IS NONE
        AND fn::mail_queue_recipient_apply(NONE, NONE) IS NONE
        AND array::len(object::keys(fn::mail_submission_event_payload({ id: mail_queue_recipient:x, tenant: auth_organization:alpha, submission: mail_submission:x, rank: 0, origin: "module", attempts: 1, local: false }))) == 10
        AND fn::mail_submission_file_remove({ id: mail_submission:x, tenant: auth_organization:alpha, content: { key: "queue/jamais.eml" } });
};

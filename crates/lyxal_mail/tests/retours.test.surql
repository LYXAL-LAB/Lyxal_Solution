-- lyxal-test: assertions
-- Adresses de retour (lot 6, §11, §10.3) : jeton posé à la préparation, résolu en rp=<jeton> sur le
-- domaine de l'enveloppe ; jeton inconnu, mauvais domaine, échu : adresse inconnue ; préfixe rp=
-- réservé aux adresses et aux comptes ; avis reçu : destinataire remis passé à bounced (événement),
-- les autres comptés ; fin de l'envoi : adresse de retour valable 14 jours ; transfert et avis
-- déposés par le compte de service avec leur jeton.
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
    -- Échéancier tenu : la seconde de chaque destinataire programmé y figure, et sa clé de lecture (due_second) est posée
    DEFINE FUNCTION OVERWRITE fn::essai_echeancier() -> bool {
        LET $scheduled = (SELECT next_attempt_at, due_second FROM mail_queue_recipient WHERE state = "scheduled");
        LET $others = (SELECT VALUE due_second FROM mail_queue_recipient WHERE state != "scheduled");
        RETURN $scheduled.all(|$r| record::exists(fn::mail_queue_due_key($r.next_attempt_at)) AND $r.due_second == time::unix($r.next_attempt_at))
            AND $others.all(|$s| $s IS NONE);
    };
    DEFINE FUNCTION OVERWRITE fn::essai_evenements($kind: string) -> array {
        RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = $kind ORDER BY created_at);
    };
};

-- test: préfixe rp= réservé aux adresses de retour : adresse, alias et compte refusés
-- en tant que: admin
RETURN fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "rp=abc", kind: "alias", targets: [fn::essai_id("jean")] }).error.code == "MAIL_ADDRESS_RESERVED"
    AND fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "RP=x", kind: "account", account: fn::essai_id("jean") }).error.code == "MAIL_ADDRESS_RESERVED"
    AND fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "rpx", kind: "account", account: fn::essai_id("jean") }).ok;

-- test: création directe d'une adresse réservée refusée par la garde
-- attendu-erreur: MAIL_ADDRESS_RESERVED
CREATE mail_address CONTENT { tenant: auth_organization:alpha, domain: type::record(fn::essai_id("domain")), local_part: "rp=forge", address: "rp=forge@alpha.test", kind: "account", account: type::record(fn::essai_id("jean")) };

-- test: dépôt de jean vers deux destinataires
-- en tant que: jean
RETURN fn::essai_garder("j", <string> fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["jean@alpha.test"], recipients: [{ address: "x@ailleurs.test" }, { address: "y@ailleurs.test" }], size: 100 }).data.submission) != NONE;

-- préparation: clôture par la session système
{
    fn::essai_clore(fn::essai_id("j"));
};

-- test: avant la préparation, aucune adresse de retour n'existe pour l'envoi
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "rp=4123456789abcdefghjkmnpqrs@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";

-- test: le worker prépare l'envoi ; l'adresse de retour se résout vers lui
-- en tant que: worker
{
    LET $claimed = fn::mail_queue_claim({ node: "n1" });
    fn::essai_garder("claim", $claimed.data.claim);
    LET $prepared = fn::mail_queue_prepare({ claim: $claimed.data.claim, submission: fn::essai_id("j"), return_token: "4123456789abcdefghjkmnpqrs" });
    LET $resolved = fn::mail_recipient_resolve({ address: "RP=4123456789ABCDEFGHJKMNPQRS@Alpha.test" });
    RETURN $prepared.data.envelope_from == "rp=4123456789abcdefghjkmnpqrs@alpha.test"
        AND $resolved.data == {
            kind: "return", address: "rp=4123456789abcdefghjkmnpqrs@alpha.test", domain: "alpha.test", tenant: auth_organization:alpha,
            max_message_bytes: 52428800, accounts: [], submission: type::record(fn::essai_id("j")), origin: "submission",
            account: type::record(fn::essai_id("jean")), forward_to: [], backscatter_protection: true
        };
};

-- test: jeton inconnu, jeton d'un autre domaine, forme invalide : adresse inconnue ; domaine étranger : aucun relais
-- en tant que: worker
RETURN ["rp=5123456789abcdefghjkmnpqrs@alpha.test", "rp=4123456789abcdefghjkmnpqrs@beta.test", "rp=@alpha.test", "rp=4123456789abcdefghjkmnpqrs+x@alpha.test"].all(|$a|
        fn::mail_recipient_resolve({ address: $a }).error.code == "MAIL_RECIPIENT_UNKNOWN")
    AND fn::mail_recipient_resolve({ address: "rp=4123456789abcdefghjkmnpqrs@ailleurs.test" }).error.code == "MAIL_RELAY_DENIED";

-- test: avis reçu : un échec qui désigne (adresse finale, casse ignorée) un destinataire remis le passe à bounced ; un retard, une adresse inconnue de l'envoi sont comptés ; lot trop grand, élément sans adresse refusés
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("j"));
    LET $r0 = fn::mail_queue_recipient_key($s, 0);
    LET $r1 = fn::mail_queue_recipient_key($s, 1);
    fn::mail_queue_complete({ claim: fn::essai_id("claim"), items: [{ recipient: <string> $r0, outcome: "delivered" }, { recipient: <string> $r1, outcome: "relayed" }] });
    LET $recorded = fn::mail_return_record({ submission: <string> $s, items: [
        { final_recipient: "X@Ailleurs.test", action: "Failed", status: "5.1.1", diagnostic: "smtp; 550 5.1.1 User unknown" },
        { final_recipient: "y@ailleurs.test", action: "delayed", status: "4.4.1" },
        { final_recipient: "inconnu@ailleurs.test", action: "failed", status: "5.1.1" }
    ] });
    LET $again = fn::mail_return_record({ submission: <string> $s, items: [{ final_recipient: "x@ailleurs.test", action: "failed", status: "5.1.1" }] });
    LET $big = fn::mail_return_record({ submission: <string> $s, items: array::map(<array> (0..101), |$i| { final_recipient: "x@ailleurs.test", action: "failed" }) });
    LET $missing = fn::mail_return_record({ submission: <string> $s, items: [{ action: "failed" }] });
    LET $row = (SELECT state, last_result FROM ONLY $r0);
    RETURN $recorded.data == { bounced: 1, ignored: 2 } AND $again.data == { bounced: 0, ignored: 1 } AND $big.error.code == "MAIL_QUEUE_BATCH_TOO_LARGE"
        AND $missing.error.code == "MAIL_INVALID_PARAMETERS"
        AND $row.state == "bounced" AND $row.last_result.{ stage, enhanced, text } == { stage: "bounce", enhanced: "5.1.1", text: "smtp; 550 5.1.1 User unknown" }
        AND (SELECT VALUE state FROM ONLY $r1) == "relayed"
        AND fn::mail_return_record({ submission: "mail_submission:absent", items: [{ final_recipient: "x@ailleurs.test", action: "failed" }] }).error.code == "MAIL_SUBMISSION_NOT_FOUND";
};

-- test: avis reçu : l'adresse d'origine désigne aussi le destinataire (adresse finale réécrite par le serveur distant)
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("j"));
    LET $r1 = fn::mail_queue_recipient_key($s, 1);
    LET $recorded = fn::mail_return_record({ submission: <string> $s, items: [{ final_recipient: "boite-reelle@interne.ailleurs.test", original_recipient: "y@ailleurs.test", action: "failed", status: "5.2.2" }] });
    RETURN $recorded.data == { bounced: 1, ignored: 0 } AND (SELECT VALUE state FROM ONLY $r1) == "bounced";
};

-- test: événement mail.submission.bounced une fois par destinataire, sans adresse ni texte distant ; fin de l'envoi : adresse de retour valable 14 jours
{
    LET $events = fn::essai_evenements("mail.submission.bounced");
    LET $s = (SELECT state, done_at, return_expires_at FROM ONLY type::record(fn::essai_id("j")));
    RETURN array::len($events) == 2 AND $events[0].{ rank, status, origin } == { rank: 0, status: "5.1.1", origin: "submission" }
        AND $events[1].{ rank, status } == { rank: 1, status: "5.2.2" }
        AND !string::contains(<string> $events, "@") AND !string::contains(<string> $events, "User unknown")
        AND $s.state == "done" AND $s.return_expires_at == $s.done_at + 14d;
};

-- test: le titulaire lit l'issue de son envoi (bounced, relayed)
-- en tant que: jean
RETURN fn::mail_submission_get({ submission: fn::essai_id("j") }).data.recipients.map(|$r| [$r.state, $r.last_result.stage]) == [["bounced", "bounce"], ["bounced", "bounce"]];

-- test: adresse de retour échue : inconnue
{
    UPDATE type::record(fn::essai_id("j")) SET return_expires_at = time::now() - 1s;
    RETURN fn::mail_recipient_resolve({ address: "rp=4123456789abcdefghjkmnpqrs@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";
};

-- test: transfert déposé par le compte de service : depuis l'alias, jeton fourni, adresse de retour rendue, compteur des transferts de l'organisation
-- en tant que: worker
{
    LET $begun = fn::mail_submission_begin({ origin: "forward", from: "equipe@alpha.test", header_from: ["origine@ailleurs.test"], recipients: [{ address: "externe@ailleurs.test" }],
        size: 200, return_token: "6123456789abcdefghjkmnpqrs", forward: { envelope_from: "origine@ailleurs.test", spf: "pass", envelope_dkim: false } });
    LET $missing = fn::mail_submission_begin({ origin: "forward", from: "equipe@alpha.test", header_from: ["origine@ailleurs.test"], recipients: [{ address: "externe@ailleurs.test" }],
        size: 200, forward: { spf: "pass", envelope_dkim: false } });
    LET $unknown = fn::mail_submission_begin({ origin: "forward", from: "inconnu@alpha.test", header_from: ["origine@ailleurs.test"], recipients: [{ address: "externe@ailleurs.test" }],
        size: 200, return_token: "7123456789abcdefghjkmnpqrs", forward: { spf: "pass", envelope_dkim: false } });
    LET $eleven = fn::mail_submission_begin({ origin: "forward", from: "equipe@alpha.test", header_from: ["origine@ailleurs.test"], recipients: array::map(<array> (0..11), |$i| { address: string::concat("e", <string> $i, "@ailleurs.test") }),
        size: 200, return_token: "8123456789abcdefghjkmnpqrs", forward: { spf: "pass", envelope_dkim: false } });
    fn::essai_garder("transfert", <string> $begun.data.submission);
    RETURN $begun.data.return_address == "rp=6123456789abcdefghjkmnpqrs@alpha.test" AND $missing.error.code == "MAIL_INVALID_PARAMETERS"
        AND $unknown.error.code == "MAIL_SENDER_FORBIDDEN" AND $eleven.error.details == { max_recipients: 10 }
        AND fn::mail_recipient_resolve({ address: "rp=6123456789abcdefghjkmnpqrs@alpha.test" }).data.origin == "forward";
};

-- test: transfert : compteur des transferts pris, réception d'origine gardée
{
    LET $day = time::format(time::now(), "%Y%m%d");
    RETURN (SELECT VALUE count FROM ONLY type::record("mail_send_counter", string::concat("forward_messages_alpha_", $day))) == 1
        AND (SELECT VALUE forward FROM ONLY type::record(fn::essai_id("transfert"))) == { envelope_from: "origine@ailleurs.test", spf: "pass", envelope_dkim: false };
};

-- test: transfert : avis à l'expéditeur d'origine seulement s'il est authentifié (SPF pass, ou DKIM de son domaine)
{
    LET $authenticated = { origin: "forward", sender: "equipe@alpha.test", forward: { envelope_from: "o@ailleurs.test", spf: "pass", envelope_dkim: false } };
    LET $dkim = { origin: "forward", sender: "equipe@alpha.test", forward: { envelope_from: "o@ailleurs.test", spf: "fail", envelope_dkim: true } };
    LET $forged = { origin: "forward", sender: "equipe@alpha.test", forward: { envelope_from: "o@ailleurs.test", spf: "softfail", envelope_dkim: false } };
    LET $empty = { origin: "forward", sender: "equipe@alpha.test", forward: { envelope_from: NONE, spf: "pass", envelope_dkim: true } };
    LET $recipient = { notify: NONE, dsn_sent: false, delay_sent: false, local: false };
    RETURN fn::mail_queue_dsn_wanted($authenticated, $recipient, "failed") AND fn::mail_queue_dsn_wanted($dkim, $recipient, "failed")
        AND !fn::mail_queue_dsn_wanted($forged, $recipient, "failed") AND !fn::mail_queue_dsn_wanted($empty, $recipient, "failed")
        AND !fn::mail_queue_dsn_wanted({ origin: "module", sender: "noreply@alpha.test" }, $recipient, "failed")
        AND !fn::mail_queue_dsn_wanted({ origin: "submission", sender: NONE }, $recipient, "failed")
        AND fn::mail_queue_dsn_wanted({ origin: "submission", sender: "jean@alpha.test" }, object::extend($recipient, { notify: ["success"] }), "relayed")
        AND !fn::mail_queue_dsn_wanted({ origin: "submission", sender: "jean@alpha.test" }, object::extend($recipient, { notify: ["success"] }), "delivered");
};

-- test: transfert d'un titulaire refusé
-- en tant que: jean
RETURN fn::mail_submission_begin({ origin: "forward", from: "equipe@alpha.test", header_from: ["origine@ailleurs.test"], recipients: [{ address: "externe@ailleurs.test" }],
    size: 200, return_token: "9123456789abcdefghjkmnpqrs", forward: { spf: "pass", envelope_dkim: false } }).error.code == "MAIL_PERMISSION_DENIED";

-- préparation: clôture du transfert par la session système
{
    fn::essai_clore(fn::essai_id("transfert"));
};

-- test: transfert en échec définitif, expéditeur d'origine authentifié : avis dû, repris par fn::mail_queue_dsn_pending (transferts compris) jusqu'à sa production
-- en tant que: worker
{
    LET $s = type::record(fn::essai_id("transfert"));
    LET $r0 = fn::mail_queue_recipient_key($s, 0);
    LET $claimed = fn::mail_queue_claim({ node: "n2" });
    LET $failed = fn::mail_queue_fail({ claim: $claimed.data.claim, items: [{ recipient: <string> $r0, permanent: true, stage: "rcpt", code: 550, enhanced: "5.1.1" }] });
    LET $pending = fn::mail_queue_dsn_pending({ grace_seconds: 0 });
    LET $read = fn::mail_submission_get({ submission: <string> $s });
    fn::mail_queue_dsn_done({ submission: <string> $s, action: "failed", recipients: [<string> $r0] });
    RETURN $claimed.data.items.map(|$i| $i.recipient) == [$r0]
        AND $failed.data.dsn == [{ submission: $s, action: "failed", recipients: [$r0] }]
        AND array::any($pending.data.dsn, |$g| $g.submission == $s AND $g.recipients == [$r0] AND $g.object IS NOT NONE)
        AND $read.data.forward == { envelope_from: "origine@ailleurs.test", spf: "pass", envelope_dkim: false }
        AND !array::any(fn::mail_queue_dsn_pending({ grace_seconds: 0 }).data.dsn, |$g| $g.submission == $s);
};

-- test: un envoi qui n'est pas un transfert ne rend aucune réception d'origine
-- en tant que: worker
RETURN fn::mail_submission_get({ submission: fn::essai_id("j") }).data.forward IS NONE;

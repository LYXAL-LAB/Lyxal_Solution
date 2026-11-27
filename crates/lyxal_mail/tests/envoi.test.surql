-- lyxal-test: assertions
-- Envoi (lot 6, §8.3, §8.4, §12, §13) : droit d'expéditeur (adresse du compte, sous-adresse, alias
-- avec et sans senders, autre compte, autre organisation, domaine extérieur) ; dépôt authentifié
-- (envoi pending, compteurs pris par l'événement, usurpations refusées par rang, jeton et préfixe
-- refusés d'un titulaire, limites par message et par jour, abandon qui rend les compteurs) ;
-- clôture (fichier contrôlé, un destinataire par adresse, route locale, échéancier, aucun
-- événement) ; lecture par le titulaire seulement (ni autre membre, ni administrateur, ni autre
-- organisation, ni relais) ; écritures directes refusées ; annulation ; contrat des modules (relais
-- et session système, expéditeurs des modules, référence, conflits avec les adresses) ; champs
-- d'envoi des alias (senders, forward_to).
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

-- test: droit d'expéditeur : adresse du compte, casse ignorée, sous-adresse, alias qui le nomme, expéditeur vide ; refus : autre compte, alias sans senders, autre organisation, domaine extérieur
-- en tant que: jean
{
    LET $checked = fn::mail_sender_check({ addresses: ["jean@alpha.test", "Jean+devis@ALPHA.test", "equipe@alpha.test", "", "marie@alpha.test", "direction@alpha.test", "autre@beta.test", "x@ailleurs.test"] });
    RETURN $checked.ok AND $checked.data == { allowed: false, refused: [4, 5, 6, 7] }
        AND fn::mail_sender_check({ addresses: ["jean@alpha.test", "equipe@alpha.test"] }).data == { allowed: true, refused: [] };
};

-- test: droit d'expéditeur : sans mail.send, ou sans compte de courrier, refusé
-- en tant que: paul
RETURN fn::mail_sender_check({ addresses: ["paul@alpha.test"] }).error.code == "MAIL_PERMISSION_DENIED";

-- test: droit d'expéditeur : un administrateur sans compte n'envoie pas ; entrées refusées par lyxal_core
-- en tant que: admin
RETURN fn::mail_sender_check({ addresses: ["jean@alpha.test"] }).error.code == "MAIL_PERMISSION_DENIED"
    AND [{}, { addresses: [] }, { addresses: ["pas une adresse"] }, { addresses: array::repeat("jean@alpha.test", 11) }, { addresses: ["jean@alpha.test"], autre: 1 }].all(|$p|
        fn::mail_sender_check($p).error.code == "MAIL_INVALID_PARAMETERS");

-- test: alias : faire partie de l'alias ne donne pas le droit d'écrire en son nom
-- en tant que: marie
RETURN fn::mail_sender_check({ addresses: ["direction@alpha.test", "equipe@alpha.test"] }).data == { allowed: false, refused: [0, 1] };

-- test: l'administrateur nomme marie dans senders de direction ; un compte d'une autre organisation est refusé ; senders sur une adresse de compte refusé
-- en tant que: admin
RETURN fn::mail_address_update({ address: fn::essai_id("direction"), senders: [fn::essai_id("marie")] }).data.senders == [type::record(fn::essai_id("marie"))]
    AND fn::mail_address_update({ address: fn::essai_id("direction"), senders: [fn::essai_id("autre")] }).error.code == "MAIL_ALIAS_TARGET_INVALID"
    AND fn::mail_address_update({ address: (SELECT VALUE <string> id FROM ONLY mail_address WHERE address = "jean@alpha.test" LIMIT 1), senders: [fn::essai_id("marie")] }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: marie écrit désormais sous direction
-- en tant que: marie
RETURN fn::mail_sender_check({ addresses: ["direction@alpha.test"] }).data == { allowed: true, refused: [] };

-- test: dépôt authentifié : envoi pending, clé du fichier, aucune adresse de retour (posée par le worker), compteurs du compte pris
-- en tant que: jean
{
    LET $begun = fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["Jean@alpha.test"], recipients: [{ address: "Paul@Ailleurs.TEST" }, { address: "marie@alpha.test", notify: ["SUCCESS", "failure"] }], size: 100, dsn: { ret: "full", envid: "QQ314159" } });
    fn::essai_garder("depot", <string> $begun.data.submission);
    RETURN $begun.ok AND $begun.data.tenant == auth_organization:alpha AND $begun.data.bucket_name == "lyxal-mail"
        AND $begun.data.key == string::concat("queue/", <string> record::id($begun.data.submission), ".eml")
        AND $begun.data.return_address IS NONE AND $begun.data.max_size == 52428800;
};

-- test: compteurs du compte pris par l'événement de création ; destinataires annoncés, domaine en minuscules
{
    LET $key = <string> record::id(type::record(fn::essai_id("jean")));
    LET $day = time::format(time::now(), "%Y%m%d");
    LET $row = (SELECT * FROM ONLY type::record(fn::essai_id("depot")));
    RETURN (SELECT VALUE count FROM ONLY type::record("mail_send_counter", string::concat("account_messages_", $key, "_", $day))) == 1
        AND (SELECT VALUE count FROM ONLY type::record("mail_send_counter", string::concat("account_recipients_", $key, "_", $day))) == 2
        AND $row.state == "pending" AND $row.origin == "submission" AND $row.owner == auth_identity:jean AND $row.sender == "jean@alpha.test"
        AND $row.header_from == ["jean@alpha.test"] AND $row.pending_recipients.address == ["Paul@ailleurs.test", "marie@alpha.test"]
        AND $row.pending_recipients[1].notify == ["success", "failure"] AND $row.dsn == { ret: "full", envid: "QQ314159" }
        AND $row.prepared_at IS NONE AND $row.prefix IS NONE AND $row.return_token IS NONE;
};

-- test: usurpation : From d'un autre compte, MAIL FROM d'un autre compte, alias sans senders, autre organisation (rangs refusés, sans adresse)
-- en tant que: jean
RETURN fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["jean@alpha.test", "marie@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 }).error.{ code, details } == { code: "MAIL_SENDER_FORBIDDEN", details: { refused: [2] } }
    AND fn::mail_submission_begin({ from: "marie@alpha.test", header_from: ["jean@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 }).error.details == { refused: [0] }
    AND fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["direction@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 }).error.code == "MAIL_SENDER_FORBIDDEN"
    AND fn::mail_submission_begin({ from: "autre@beta.test", header_from: ["autre@beta.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 }).error.code == "MAIL_SENDER_FORBIDDEN";

-- test: jeton, préfixe, transfert et référence de module refusés d'un titulaire ; entrées refusées par lyxal_core
-- en tant que: jean
{
    LET $base = { from: "jean@alpha.test", header_from: ["jean@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 };
    RETURN fn::mail_submission_begin(object::extend($base, { return_token: "0123456789abcdefghjkmnpqrs" })).error.details == { fields: { return_token: ["forward_or_dsn_only"] } }
        AND fn::mail_submission_begin(object::extend($base, { prefix: "DKIM-Signature: a\r\n" })).error.details == { fields: { prefix: ["forward_or_dsn_only"] } }
        AND fn::mail_submission_begin(object::extend($base, { client_reference: "job-1" })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_submission_begin(object::extend($base, { forward: { spf: "pass", envelope_dkim: true } })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_submission_begin(object::extend($base, { origin: "forward", forward: { spf: "pass", envelope_dkim: true }, return_token: "0123456789abcdefghjkmnpqrs" })).error.code == "MAIL_PERMISSION_DENIED"
        AND [
            object::remove($base, "from"), object::extend($base, { recipients: [] }), object::extend($base, { recipients: [{ address: "pas une adresse" }] }),
            object::extend($base, { recipients: [{ address: "x@ailleurs.test", notify: ["jamais"] }] }), object::extend($base, { recipients: [{ address: "x@ailleurs.test", autre: 1 }] }),
            object::extend($base, { recipients: [{ address: "x@ailleurs.test", notify: ["never", "success"] }] }), object::extend($base, { size: 0 }),
            object::extend($base, { dsn: { ret: "tout" } }), object::extend($base, { origin: "inconnue" }), object::extend($base, { autre: 1 }),
            object::extend($base, { recipients: array::map(<array> (0..1001), |$i| { address: string::concat("d", <string> $i, "@ailleurs.test") }) })
        ].all(|$p| fn::mail_submission_begin($p).error.code == "MAIL_INVALID_PARAMETERS");
};

-- test: limites : destinataires par message de l'organisation, taille de l'organisation
-- en tant que: jean
RETURN fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["jean@alpha.test"], recipients: array::map(<array> (0..101), |$i| { address: string::concat("d", <string> $i, "@ailleurs.test") }), size: 10 }).error.{ code, details } == { code: "MAIL_SUBMISSION_TOO_MANY_RECIPIENTS", details: { max_recipients: 100 } }
    AND fn::mail_submission_begin({ from: "jean@alpha.test", header_from: ["jean@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 52428801 }).error.code == "MAIL_MESSAGE_TOO_LARGE";

-- test: sans mail.send, ou sans compte, aucun dépôt authentifié
-- en tant que: paul
RETURN fn::mail_submission_begin({ from: "paul@alpha.test", header_from: ["paul@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 }).error.code == "MAIL_PERMISSION_DENIED";

-- test: l'administrateur limite les messages par jour de l'organisation (plafonnés par l'installation)
-- en tant que: admin
RETURN fn::mail_settings_set({ tenant: "auth_organization:alpha", send_messages_per_day: 2 }).ok
    AND fn::mail_settings_get({ tenant: "auth_organization:alpha" }).data.effective.send_messages_per_day == 2
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", retry_jitter_percent: 5 }).error.details == { fields: { retry_jitter_percent: ["installation_only"] } };

-- test: limite des messages du compte par jour : le deuxième passe, le troisième est refusé ; un abandon rend le compteur
-- en tant que: jean
{
    LET $message = { from: "jean@alpha.test", header_from: ["jean@alpha.test"], recipients: [{ address: "x@ailleurs.test" }], size: 10 };
    LET $second = fn::mail_submission_begin($message);
    LET $third = fn::mail_submission_begin($message);
    LET $aborted = fn::mail_submission_abort({ submission: <string> $second.data.submission });
    LET $again = fn::mail_submission_abort({ submission: <string> $second.data.submission });
    LET $fourth = fn::mail_submission_begin($message);
    fn::essai_garder("abandon", <string> $second.data.submission);
    fn::essai_garder("quatrieme", <string> $fourth.data.submission);
    RETURN $second.ok AND $third.error.{ code, details } == { code: "MAIL_SEND_LIMIT_EXCEEDED", details: { kind: "account_messages", limit: 2 } }
        AND $aborted.data == { released: true } AND $again.error.code == "MAIL_SUBMISSION_STATE_INVALID" AND $fourth.ok;
};

-- test: l'administrateur relève la limite
-- en tant que: admin
RETURN fn::mail_settings_set({ tenant: "auth_organization:alpha", clear: ["send_messages_per_day"] }).ok;

-- test: clôture : refusée au titulaire (fichiers et file : session système de l'hôte)
-- en tant que: jean
RETURN fn::mail_submission_commit({ submission: fn::essai_id("depot"), object: "storage_object:absent" }).error.code == "MAIL_PERMISSION_DENIED";

-- test: clôture : fichier absent, fichier d'une autre clé refusés ; puis un destinataire en file par adresse, route locale posée, échéancier tenu, aucun événement
{
    LET $missing = fn::mail_submission_commit({ submission: fn::essai_id("depot"), object: "storage_object:absent" });
    LET $wrong = fn::mail_submission_commit({ submission: fn::essai_id("depot"), object: fn::essai_fichier(fn::essai_id("quatrieme")) });
    LET $closed = fn::essai_clore(fn::essai_id("depot"));
    LET $submission = type::record(fn::essai_id("depot"));
    LET $rows = (SELECT * FROM mail_queue_recipient WHERE submission = $submission ORDER BY rank);
    RETURN $missing.error.code == "MAIL_CONTENT_UNAVAILABLE" AND $wrong.error.code == "MAIL_CONTENT_STATE_INVALID"
        AND $closed.ok AND $closed.data.recipients == 2
        AND (SELECT VALUE [state, open_count, recipient_count, array::len(pending_recipients)] FROM ONLY $submission) == ["queued", 2, 2, 0]
        AND $rows.map(|$r| [$r.rank, $r.address, $r.domain, $r.local, $r.state, $r.attempts, $r.owner, $r.origin]) == [
            [0, "Paul@ailleurs.test", "ailleurs.test", false, "scheduled", 0, auth_identity:jean, "submission"],
            [1, "marie@alpha.test", "alpha.test", true, "scheduled", 0, auth_identity:jean, "submission"]
        ]
        AND $rows[0].id == fn::mail_queue_recipient_key($submission, 0)
        AND fn::essai_echeancier() AND array::len(SELECT * FROM mail_queue_due) == 2
        AND array::len(SELECT * FROM event_outbox WHERE string::starts_with(event_type, "mail.submission")) == 0;
};

-- test: clôture une seule fois ; abandon d'un envoi clos refusé
{
    RETURN fn::mail_submission_commit({ submission: fn::essai_id("depot"), object: "storage_object:absent" }).error.code == "MAIL_SUBMISSION_STATE_INVALID"
        AND fn::mail_submission_abort({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_STATE_INVALID";
};

-- test: lecture par le titulaire : envoi sans préfixe, jeton ni contenu, destinataires par rang
-- en tant que: jean
{
    LET $read = fn::mail_submission_get({ submission: fn::essai_id("depot") });
    RETURN $read.ok AND $read.data.state == "queued" AND $read.data.size == 100 AND $read.data.recipients.map(|$r| [$r.rank, $r.state]) == [[0, "scheduled"], [1, "scheduled"]]
        AND !object::keys($read.data).any(|$k| $k IN ["prefix", "return_token", "content", "pending_recipients"]);
};

-- test: marie ne lit ni n'annule l'envoi de jean
-- en tant que: marie
RETURN fn::mail_submission_get({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_NOT_FOUND"
    AND fn::mail_submission_cancel({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_NOT_FOUND"
    AND array::len(SELECT * FROM mail_queue_recipient) == 0;

-- test: l'administrateur de l'organisation ne lit aucun envoi de ses membres (M11)
-- en tant que: admin
RETURN fn::mail_submission_get({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_NOT_FOUND"
    AND array::len(SELECT * FROM mail_submission) == 0 AND array::len(SELECT * FROM mail_queue_recipient) == 0;

-- test: une autre organisation ne lit aucun envoi
-- en tant que: autre
RETURN fn::mail_submission_get({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_NOT_FOUND" AND array::len(SELECT * FROM mail_submission) == 0;

-- test: le relais des modules ne lit pas un dépôt authentifié
-- en tant que: relais
RETURN fn::mail_submission_get({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_NOT_FOUND";

-- test: écritures directes du titulaire refusées par la garde : destinataire passé à delivered
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE fn::mail_queue_recipient_key(type::record(fn::essai_id("depot")), 0) SET state = "delivered";

-- test: création directe d'un destinataire par le titulaire filtrée par les permissions ; champs réservés non écrits
-- en tant que: jean
{
    LET $created = (CREATE mail_queue_recipient CONTENT { tenant: auth_organization:alpha, submission: type::record(fn::essai_id("depot")), owner: auth_identity:jean, origin: "submission", rank: 5, address: "x@y.test", domain: "y.test", local: false, next_attempt_at: time::now() });
    LET $touched = (UPDATE ONLY type::record(fn::essai_id("depot")) SET open_count = 0, prefix = "X: y\r\n");
    RETURN $created == [] AND (SELECT VALUE [open_count, state] FROM ONLY type::record(fn::essai_id("depot"))) == [2, "queued"];
};

-- test: annulation par le titulaire : destinataires en attente annulés, envoi fini, aucun événement ; seconde annulation refusée
-- en tant que: jean
{
    LET $canceled = fn::mail_submission_cancel({ submission: fn::essai_id("depot") });
    LET $read = fn::mail_submission_get({ submission: fn::essai_id("depot") }).data;
    RETURN $canceled.data == { canceled: 2 } AND $read.state == "done" AND $read.open_count == 0 AND $read.recipients.state == ["canceled", "canceled"]
        AND fn::mail_submission_cancel({ submission: fn::essai_id("depot") }).error.code == "MAIL_SUBMISSION_STATE_INVALID";
};

-- test: annulation : échéancier vidé, aucun événement
RETURN fn::essai_echeancier() AND array::len(SELECT * FROM event_outbox WHERE string::starts_with(event_type, "mail.submission")) == 0;

-- test: module : dépôt par le relais sous un expéditeur des modules, référence rendue ; adresse d'une personne ou d'un autre domaine refusée ; 100 destinataires au plus
-- en tant que: relais
{
    LET $message = { origin: "module", from: "noreply@alpha.test", header_from: ["noreply@alpha.test"], recipients: [{ address: "client@ailleurs.test" }], size: 50, client_reference: "notification_step_7" };
    LET $begun = fn::mail_submission_begin($message);
    fn::essai_garder("module", <string> $begun.data.submission);
    RETURN $begun.ok AND $begun.data.tenant == auth_organization:alpha AND $begun.data.return_address IS NONE
        AND fn::mail_submission_begin(object::extend($message, { from: "jean@alpha.test" })).error.{ code, details } == { code: "MAIL_SENDER_FORBIDDEN", details: { refused: [0] } }
        AND fn::mail_submission_begin(object::extend($message, { header_from: ["jean@alpha.test"] })).error.details == { refused: [1] }
        AND fn::mail_submission_begin(object::extend($message, { from: "noreply@beta.test", header_from: ["noreply@beta.test"] })).error.code == "MAIL_SENDER_FORBIDDEN"
        AND fn::mail_submission_begin(object::extend($message, { recipients: array::map(<array> (0..101), |$i| { address: string::concat("d", <string> $i, "@ailleurs.test") }) })).error.details == { max_recipients: 100 }
        AND fn::mail_submission_begin(object::extend($message, { origin: "submission", client_reference: NONE })).error.code == "MAIL_PERMISSION_DENIED"
        AND fn::mail_submission_begin(object::extend($message, { client_reference: "a b" })).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: module : compteur de l'organisation par heure ; clôture par le relais (qui a aussi storage.worker)
{
    LET $hour = time::format(time::now(), "%Y%m%d%H");
    RETURN (SELECT VALUE count FROM ONLY type::record("mail_send_counter", string::concat("module_messages_alpha_", $hour))) == 1;
};

-- test: module : clôture et lecture par le relais, sans texte du serveur distant
-- en tant que: relais
{
    LET $object = fn::essai_fichier(fn::essai_id("module"));
    LET $closed = fn::mail_submission_commit({ submission: fn::essai_id("module"), object: $object });
    LET $read = fn::mail_submission_get({ submission: fn::essai_id("module") });
    RETURN $closed.data.recipients == 1 AND $read.data.client_reference == "notification_step_7" AND $read.data.recipients[0].state == "scheduled";
};

-- test: module : un titulaire ne lit pas un envoi de module ; la session système dépose aussi sous un expéditeur des modules
-- en tant que: jean
RETURN fn::mail_submission_get({ submission: fn::essai_id("module") }).error.code == "MAIL_SUBMISSION_NOT_FOUND";

-- test: module : session système
RETURN fn::essai_module([{ address: "a@ailleurs.test" }, { address: "b@beta.test" }]) != NONE
    AND (SELECT VALUE local FROM mail_queue_recipient WHERE origin = "module" AND address = "b@beta.test") == [true];

-- test: expéditeurs des modules : jamais une adresse inscrite, jamais le préfixe réservé ; une adresse ne prend pas un expéditeur des modules
-- en tant que: admin
RETURN fn::mail_domain_update({ domain: fn::essai_id("domain"), module_senders: ["noreply", "jean"] }).error.code == "MAIL_MODULE_SENDER_CONFLICT"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), module_senders: ["rp=x"] }).error.code == "MAIL_ADDRESS_RESERVED"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), module_senders: ["a b"] }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "NoReply", kind: "alias", targets: [fn::essai_id("jean")] }).error.code == "MAIL_MODULE_SENDER_CONFLICT"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), module_senders: ["noreply", "notifications"], backscatter_protection: false }).data.{ module_senders, backscatter_protection } == { module_senders: ["noreply", "notifications"], backscatter_protection: false };

-- test: transfert d'un alias : adresses extérieures seulement, 10 au plus
-- en tant que: admin
RETURN fn::mail_address_update({ address: fn::essai_id("equipe"), forward_to: ["Externe@Ailleurs.test"] }).data.forward_to == ["externe@ailleurs.test"]
    AND fn::mail_address_update({ address: fn::essai_id("equipe"), forward_to: ["x@alpha.test"] }).error.{ code, details } == { code: "MAIL_ALIAS_TARGET_INVALID", details: { field: "forward_to" } }
    AND fn::mail_address_update({ address: fn::essai_id("equipe"), forward_to: array::map(<array> (0..11), |$i| string::concat("d", <string> $i, "@ailleurs.test")) }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "ventes", kind: "account", account: fn::essai_id("jean"), forward_to: ["x@ailleurs.test"] }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: transfert vers le domaine d'une autre organisation de l'installation : refusé par la garde (domaine invisible de l'administrateur)
-- en tant que: admin
-- attendu-erreur: MAIL_ALIAS_TARGET_INVALID
RETURN fn::mail_address_update({ address: fn::essai_id("equipe"), forward_to: ["x@beta.test"] });

-- test: transfert : résolution d'un alias à cibles extérieures (réglage du domaine rendu)
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "equipe@alpha.test" }).data.{ kind, forward_to, backscatter_protection } == { kind: "mailbox", forward_to: ["externe@ailleurs.test"], backscatter_protection: false };

-- test: compte supprimé : retiré des senders des alias
-- en tant que: admin
{
    fn::mail_address_update({ address: fn::essai_id("equipe"), senders: [fn::essai_id("jean"), fn::essai_id("marie")] });
    fn::mail_account_delete({ account: fn::essai_id("marie") });
    RETURN (SELECT VALUE senders FROM ONLY type::record(fn::essai_id("equipe"))) == [type::record(fn::essai_id("jean"))];
};

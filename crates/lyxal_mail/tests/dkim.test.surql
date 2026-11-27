-- lyxal-test: assertions
-- Clés DKIM (lot 6, §9) : création des fiches publiques par le compte de service, sélecteur pris,
-- chemin du secret imposé, taille RSA ; travail de la tâche de provisionnement (domaines sans clé,
-- clés en attente) ; activation ; signataires actifs seulement ; enregistrements à publier lus par
-- l'administrateur de l'organisation, rien pour un membre ni pour une autre organisation ; chemin
-- du secret jamais lisible hors du compte de service.
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

-- test: tâche de provisionnement : chaque domaine actif sans clé, par nom puis algorithme ; aucune clé en attente
-- en tant que: worker
{
    LET $work = fn::mail_dkim_pending({});
    RETURN $work.ok AND $work.data.pending == []
        AND $work.data.missing.map(|$m| [$m.name, $m.algorithm]) == [["alpha.test", "rsa-sha256"], ["alpha.test", "ed25519-sha256"], ["beta.test", "rsa-sha256"], ["beta.test", "ed25519-sha256"]]
        AND $work.data.missing[0].tenant == auth_organization:alpha;
};

-- test: fiches publiques créées par le compte de service : RSA 2 048 bits et Ed25519, état pending, chemin du secret non rendu
-- en tant que: worker
{
    LET $rsa = fn::mail_dkim_key_create({ domain: fn::essai_id("domain"), selector: "lyx202611r", algorithm: "rsa-sha256", bits: 2048, public_key: "TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE=", secret_path: "mail/dkim/alpha.test/lyx202611r" });
    LET $ed = fn::mail_dkim_key_create({ domain: fn::essai_id("domain"), selector: "lyx202611e", algorithm: "ed25519-sha256", public_key: "MCowBQYDK2VwAyEA11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=", secret_path: "mail/dkim/alpha.test/lyx202611e" });
    fn::essai_garder("rsa", <string> $rsa.data.id);
    fn::essai_garder("ed", <string> $ed.data.id);
    RETURN $rsa.ok AND $rsa.data.state == "pending" AND $rsa.data.bits == 2048 AND $rsa.data.tenant == auth_organization:alpha AND !object::keys($rsa.data).any(|$k| $k == "secret_path")
        AND $ed.ok AND $ed.data.bits IS NONE AND $ed.data.algorithm == "ed25519-sha256";
};

-- test: refus : sélecteur pris, chemin du secret autre que mail/dkim/<domaine>/<sélecteur>, taille RSA absente ou donnée à Ed25519, domaine inconnu, entrées invalides
-- en tant que: worker
{
    LET $key = { domain: fn::essai_id("domain"), selector: "lyx202611r", algorithm: "rsa-sha256", bits: 2048, public_key: "QUJD", secret_path: "mail/dkim/alpha.test/lyx202611r" };
    RETURN fn::mail_dkim_key_create($key).error.code == "MAIL_DKIM_KEY_EXISTS"
        AND fn::mail_dkim_key_create(object::extend($key, { selector: "lyx202612r", secret_path: "mail/dkim/beta.test/lyx202612r" })).error.details == { fields: { secret_path: ["mail/dkim/<domain>/<selector>"] } }
        AND fn::mail_dkim_key_create(object::extend($key, { selector: "lyx202612r", secret_path: "mail/dkim/alpha.test/lyx202612r", bits: NONE })).error.details == { fields: { bits: ["required"] } }
        AND fn::mail_dkim_key_create(object::extend($key, { selector: "lyx202612e", secret_path: "mail/dkim/alpha.test/lyx202612e", algorithm: "ed25519-sha256" })).error.details == { fields: { bits: ["not_allowed"] } }
        AND fn::mail_dkim_key_create(object::extend($key, { domain: "mail_domain:absent" })).error.code == "MAIL_DOMAIN_NOT_FOUND"
        AND [object::extend($key, { selector: "Pas Un Slug" }), object::extend($key, { algorithm: "rsa-sha1" }), object::extend($key, { bits: 1024 }), object::extend($key, { public_key: "pas du base64 !" }), object::extend($key, { autre: 1 })]
            .all(|$p| fn::mail_dkim_key_create($p).error.code == "MAIL_INVALID_PARAMETERS");
};

-- test: les clés en attente passent à la tâche ; alpha n'a plus de clé manquante
-- en tant que: worker
{
    LET $work = fn::mail_dkim_pending({}).data;
    RETURN $work.pending.map(|$k| [$k.name, $k.selector, $k.algorithm]) == [["alpha.test", "lyx202611r", "rsa-sha256"], ["alpha.test", "lyx202611e", "ed25519-sha256"]]
        AND $work.missing.map(|$m| $m.name) == ["beta.test", "beta.test"]
        AND array::len(fn::mail_dkim_pending({ limit: 1 }).data.pending) == 1 AND array::len(fn::mail_dkim_pending({ limit: 1 }).data.missing) == 1;
};

-- test: signataires : aucune clé tant qu'elles sont en attente
-- en tant que: worker
RETURN fn::mail_dkim_signers({ domains: ["alpha.test"] }).data == { items: [] };

-- test: activation quand l'enregistrement DNS est publié ; une clé active le reste ; clé inconnue
-- en tant que: worker
{
    LET $activated = fn::mail_dkim_key_activate({ key: fn::essai_id("rsa") });
    LET $again = fn::mail_dkim_key_activate({ key: fn::essai_id("rsa") });
    RETURN $activated.data.state == "active" AND $activated.data.activated_at IS NOT NONE AND $again.data.activated_at == $activated.data.activated_at
        AND fn::mail_dkim_key_activate({ key: "mail_dkim_key:absente" }).error.code == "MAIL_DKIM_KEY_NOT_FOUND";
};

-- test: signataires : clés actives seulement, domaine du From en forme ASCII, casse ignorée ; domaine extérieur sans clé ; au plus deux domaines
-- en tant que: worker
RETURN fn::mail_dkim_signers({ domains: ["ALPHA.test", "ailleurs.test"] }).data.items == [{ domain: "alpha.test", selector: "lyx202611r", algorithm: "rsa-sha256", secret_path: "mail/dkim/alpha.test/lyx202611r" }]
    AND fn::mail_dkim_signers({ domains: ["a.test", "b.test", "c.test"] }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: enregistrements à publier lus par l'administrateur de l'organisation, sans chemin du secret
-- en tant que: admin
{
    LET $list = fn::mail_dkim_key_list({ domain: fn::essai_id("domain") });
    RETURN $list.ok AND $list.data.items.map(|$k| [$k.selector, $k.state, $k.dns_name, $k.dns_value]) == [
            ["lyx202611e", "pending", "lyx202611e._domainkey.alpha.test", "v=DKIM1; k=ed25519; p=MCowBQYDK2VwAyEA11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo="],
            ["lyx202611r", "active", "lyx202611r._domainkey.alpha.test", "v=DKIM1; k=rsa; p=TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE="]
        ]
        AND (SELECT VALUE secret_path FROM mail_dkim_key) == [NONE, NONE]
        AND fn::mail_dkim_key_create({ domain: fn::essai_id("domain"), selector: "x", algorithm: "ed25519-sha256", public_key: "QUJD", secret_path: "mail/dkim/alpha.test/x" }).error.code == "MAIL_PERMISSION_DENIED"
        AND fn::mail_dkim_signers({ domains: ["alpha.test"] }).error.code == "MAIL_PERMISSION_DENIED"
        AND fn::mail_dkim_pending({}).error.code == "MAIL_PERMISSION_DENIED"
        AND fn::mail_dkim_key_activate({ key: fn::essai_id("ed") }).error.code == "MAIL_PERMISSION_DENIED";
};

-- test: écriture directe d'une fiche par l'administrateur filtrée par les permissions
-- en tant que: admin
{
    LET $touched = (UPDATE type::record(fn::essai_id("ed")) SET state = "active");
    RETURN $touched == [] AND (SELECT VALUE state FROM ONLY type::record(fn::essai_id("ed"))) == "pending";
};

-- test: un membre ne lit aucune clé
-- en tant que: jean
RETURN fn::mail_dkim_key_list({ domain: fn::essai_id("domain") }).error.code IN ["MAIL_PERMISSION_DENIED", "MAIL_DOMAIN_NOT_FOUND"]
    AND array::len(SELECT * FROM mail_dkim_key) == 0;

-- test: l'administrateur d'une autre organisation ne lit pas les clés d'alpha
-- en tant que: autre
RETURN fn::mail_dkim_key_list({ domain: fn::essai_id("domain") }).error.code IN ["MAIL_PERMISSION_DENIED", "MAIL_DOMAIN_NOT_FOUND"]
    AND array::len(SELECT * FROM mail_dkim_key) == 0
    AND fn::mail_dkim_key_list({ domain: fn::essai_id("domain_beta") }).data == { items: [] };

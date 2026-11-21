-- lyxal-test: assertions
-- Droits : permissions et rôles déclarés par le seed (rejouable), fn::mail_can par action et
-- par identité (session système, administrateur, titulaire, autre membre, membre sans droit,
-- autre organisation, compte de service, administrateur de la plateforme), fonctions internes,
-- écritures filtrées par les permissions des tables (MAIL_WRITE_FORBIDDEN).
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "auth.member.read", "auth.organization.settings.manage"] }
-- identité jean: { "id": "auth_session:jean", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité marie: { "id": "auth_session:marie", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "auth.member.read", "auth.organization.settings.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["mail.worker"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["mail.installation.manage"] }

-- préparation: organisations alpha et beta, identités et sessions lyxal_auth, domaines vérifiés, table de passage
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $person IN [["admin", "alpha"], ["jean", "alpha"], ["marie", "alpha"], ["membre", "alpha"], ["autre", "beta"]] {
        LET $identity = type::record("auth_identity", $person[0]);
        LET $organization = type::record("auth_organization", $person[1]);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($person[0], "@lyxal.test") } };
        RELATE $identity->auth_member_of->$organization;
        CREATE type::record("auth_session", $person[0]) CONTENT { identity: $identity, organization: $organization, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    FOR $name IN ["worker", "plateforme"] {
        CREATE type::record("auth_identity", $name) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test") } };
        CREATE type::record("auth_session", $name) CONTENT { identity: type::record("auth_identity", $name), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_organization_domain:alpha CONTENT { organization: auth_organization:alpha, domain: "alpha.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:alpha2 CONTENT { organization: auth_organization:alpha, domain: "alpha2.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:attente CONTENT { organization: auth_organization:alpha, domain: "attente.test", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:beta CONTENT { organization: auth_organization:beta, domain: "beta.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: aides d'essai (session système) : contenu déposé dans le bucket chiffré, message inscrit, compteurs recalculés
{
    DEFINE FUNCTION OVERWRITE fn::essai_contenu($account: string, $size: int) -> string {
        LET $tenant = (SELECT VALUE tenant FROM ONLY type::record($account));
        LET $existing = (SELECT VALUE id FROM ONLY storage_bucket WHERE tenant = $tenant AND name = "lyxal-mail" LIMIT 1);
        LET $bucket = $existing ?? fn::storage_bucket_create({ tenant: <string> $tenant, name: "lyxal-mail", encrypted: true }).data.id;
        LET $reserved = fn::mail_content_begin({ account: $account, size: $size }).data;
        LET $object = fn::storage_object_begin({ bucket: <string> $bucket, key: $reserved.key, filename: "message.eml", declared_size: $size }).data;
        fn::storage_object_commit({ object: <string> $object.id, size: $size, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key: "enc:v2:essai-files-1:QUJD" });
        fn::mail_content_attach({ content: <string> $reserved.content, object: <string> $object.id });
        RETURN <string> $reserved.content;
    };
    DEFINE FUNCTION OVERWRITE fn::essai_message($account: string, $mailbox: string, $extra: object) -> object {
        LET $content = fn::essai_contenu($account, $extra.size ?? 100);
        RETURN fn::mail_message_create(object::extend({
            content: $content, mailbox: $mailbox, received_at: time::now(),
            envelope: { subject: "Essai", from: [{ name: "Expéditeur", address: "exp@ailleurs.test" }] }, structure: { type: "text/plain", size: 100 }
        }, object::remove($extra, "size")));
    };
    DEFINE FUNCTION OVERWRITE fn::essai_coherent($account: string) -> bool {
        LET $id = type::record($account);
        LET $boxes = (SELECT id, total, unseen, size FROM mail_mailbox WHERE account = $id);
        LET $messages = (SELECT mailbox, seen, size FROM mail_message WHERE account = $id);
        LET $owner = (SELECT message_count, used_bytes, mailbox_count FROM ONLY $id);
        RETURN $boxes.all(|$b| {
            LET $mine = $messages.filter(|$m| $m.mailbox = $b.id);
            RETURN $b.total == array::len($mine) AND $b.unseen == array::len($mine.filter(|$m| !$m.seen)) AND $b.size == math::sum($mine.map(|$m| $m.size));
        }) AND $owner.message_count == array::len($messages) AND $owner.used_bytes == math::sum($messages.map(|$m| $m.size)) AND $owner.mailbox_count == array::len($boxes);
    };
};

-- préparation: domaines alpha.test et beta.test, comptes de jean et marie (alpha) et d'autre (beta)
{
    LET $domain = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).data.id;
    LET $domain_beta = fn::mail_domain_create({ auth_domain: "auth_organization_domain:beta" }).data.id;
    LET $jean = fn::mail_account_create({ identity: "auth_identity:jean", domain: <string> $domain, local_part: "jean" }).data.account.id;
    LET $marie = fn::mail_account_create({ identity: "auth_identity:marie", domain: <string> $domain, local_part: "marie" }).data.account.id;
    LET $autre = fn::mail_account_create({ identity: "auth_identity:autre", domain: <string> $domain_beta, local_part: "autre" }).data.account.id;
    LET $box = |$account, $role| <string> (SELECT VALUE id FROM ONLY mail_mailbox WHERE account = $account AND role = $role LIMIT 1);
    CREATE passe:ids CONTENT {
        domain: <string> $domain, domain_beta: <string> $domain_beta,
        jean: <string> $jean, marie: <string> $marie, autre: <string> $autre,
        jean_inbox: $box($jean, "inbox"), jean_trash: $box($jean, "trash"), jean_archive: $box($jean, "archive"), jean_sent: $box($jean, "sent"),
        marie_inbox: $box($marie, "inbox"), autre_inbox: $box($autre, "inbox")
    };
    DEFINE FUNCTION OVERWRITE fn::essai_id($name: string) -> string { RETURN (SELECT * FROM ONLY passe:ids)[$name]; };
};


-- préparation: un message dans la boîte de jean
UPDATE passe:ids SET m1 = <string> fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), {}).data.id;

-- test: permissions et rôles créés par le seed ; mail.worker n'est attribuée à aucun rôle
RETURN (SELECT VALUE code FROM auth_permission WHERE module = "lyxal_mail" ORDER BY code) == ["mail.domain.manage", "mail.installation.manage", "mail.mailbox.access", "mail.worker"]
    AND (SELECT VALUE [scope, app_password ?? false] FROM auth_permission WHERE module = "lyxal_mail" ORDER BY code) == [["organization", false], ["installation", false], ["organization", true], ["installation", false]]
    AND array::sort((SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_admin).filter(|$c| string::starts_with($c, "mail."))) == ["mail.domain.manage", "mail.mailbox.access"]
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_member).filter(|$c| string::starts_with($c, "mail.")) == ["mail.mailbox.access"]
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin).filter(|$c| string::starts_with($c, "mail.")) == ["mail.installation.manage"]
    AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨mail.worker⟩) == 0;

-- test: rejeu des seeds sans doublon ni erreur
{
    IF !record::exists(auth_permission:⟨mail.worker⟩) THEN (
        CREATE auth_permission:⟨mail.worker⟩ CONTENT { code: "mail.worker", module: "lyxal_mail", scope: "installation", description: { fr: "x", en: "x" } }
    ) END;
    IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_member AND out = auth_permission:⟨mail.mailbox.access⟩) = 0 THEN (
        RELATE auth_role:organization_member->auth_role_grants->auth_permission:⟨mail.mailbox.access⟩
    ) END;
    IF !record::exists(error_definition:MAIL_QUOTA_EXCEEDED) THEN (
        CREATE error_definition:MAIL_QUOTA_EXCEEDED CONTENT { code: "MAIL_QUOTA_EXCEEDED", module: "mail", message: "x" }
    ) END;
    RETURN array::len(SELECT * FROM auth_permission WHERE module = "lyxal_mail") == 4
        AND array::len(SELECT * FROM auth_role_grants WHERE out = auth_permission:⟨mail.mailbox.access⟩) == 2
        AND (SELECT VALUE message FROM ONLY error_definition:MAIL_QUOTA_EXCEEDED) == "Mail quota exceeded";
};

-- test: 39 codes d'erreur MAIL_*, traduits en français et en anglais
RETURN array::len(SELECT * FROM error_definition WHERE module = "mail") == 39
    AND (SELECT * FROM error_definition WHERE module = "mail").all(|$e| string::starts_with($e.code, "MAIL_") AND $e.translations.fr.label != NONE AND $e.translations.en.label != NONE)
    AND (SELECT VALUE code FROM error_definition WHERE module = "mail" AND retryable = true) == ["MAIL_CONTENT_UNAVAILABLE"];

-- test: la session système peut tout
RETURN ["worker", "manage", "settings", "mailbox"].all(|$a| fn::mail_can({ action: $a, tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")) }) AND fn::mail_can({ action: $a }));

-- test: administrateur : gestion de son organisation, sa propre boîte, jamais celle d'un membre ; rien ailleurs
-- en tant que: admin
RETURN fn::mail_can({ action: "manage", tenant: auth_organization:alpha })
    AND fn::mail_can({ action: "settings", tenant: auth_organization:alpha })
    AND fn::mail_can({ action: "settings" })
    AND !fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")) })
    AND fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, identity: auth_identity:admin })
    AND !fn::mail_can({ action: "manage", tenant: auth_organization:beta })
    AND !fn::mail_can({ action: "manage" })
    AND !fn::mail_can({ action: "worker" })
    AND !fn::mail_can({ action: "inconnue", tenant: auth_organization:alpha });

-- test: titulaire : sa boîte et la lecture des limites seulement
-- en tant que: jean
RETURN fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")) })
    AND !fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, account: type::record(fn::essai_id("marie")) })
    AND !fn::mail_can({ action: "mailbox", tenant: auth_organization:beta, account: type::record(fn::essai_id("jean")) })
    AND !fn::mail_can({ action: "mailbox", account: type::record(fn::essai_id("jean")) })
    AND fn::mail_can({ action: "settings", tenant: auth_organization:alpha })
    AND !fn::mail_can({ action: "manage", tenant: auth_organization:alpha })
    AND !fn::mail_can({ action: "worker" });

-- test: membre sans droit de courrier : ni boîte ni limites de l'organisation
-- en tant que: membre
RETURN !fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, identity: auth_identity:membre })
    AND !fn::mail_can({ action: "settings", tenant: auth_organization:alpha })
    AND fn::mail_can({ action: "settings" });

-- test: compte de service : toute boîte, toutes les limites, pas la gestion
-- en tant que: worker
RETURN fn::mail_can({ action: "worker" })
    AND fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")) })
    AND fn::mail_can({ action: "mailbox", tenant: auth_organization:beta, account: type::record(fn::essai_id("autre")) })
    AND fn::mail_can({ action: "settings", tenant: auth_organization:beta })
    AND !fn::mail_can({ action: "manage", tenant: auth_organization:alpha })
    AND !fn::mail_can({ action: "manage" });

-- test: administrateur de la plateforme : réglages de l'installation seulement
-- en tant que: plateforme
RETURN fn::mail_can({ action: "manage" })
    AND !fn::mail_can({ action: "manage", tenant: auth_organization:alpha })
    AND !fn::mail_can({ action: "mailbox", tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")) })
    AND array::len(SELECT * FROM mail_account) == 0;

-- test: compte de la session ; partie locale normalisée ; prochain numéro de modification
-- en tant que: jean
RETURN fn::mail_session_account(NONE) == type::record(fn::essai_id("jean"))
    AND fn::mail_session_account(type::record(fn::essai_id("marie"))) == type::record(fn::essai_id("marie"))
    AND fn::mail_address_normalize(" Jean.X ", "alpha.test") == { valid: true, local_part: "jean.x", address: "jean.x@alpha.test" }
    AND fn::mail_address_normalize("a b", "alpha.test").valid == false
    AND fn::mail_modseq_next(type::record(fn::essai_id("jean"))) == fn::mail_account_get({}).data.modseq + 1;

-- test: règles d'entrée et lecture de lots ; drapeaux appliqués
-- en tant que: jean
{
    LET $keywords = fn::validation_object_execute({ k: ["$Seen", "x]"] }, { fields: { k: fn::mail_keywords_rule() }, unknown_keys: "reject" }, 20);
    LET $messages = fn::validation_object_execute({ m: [] }, { fields: { m: fn::mail_messages_rule() }, unknown_keys: "reject" }, 20);
    LET $loaded = fn::mail_messages_load([type::record(fn::essai_id("m1"))]);
    LET $missing = fn::mail_messages_load([type::record(fn::essai_id("m1")), mail_message:absent]);
    RETURN $keywords.by_field.keys() == ["k[1]"] AND !$messages.valid
        AND $loaded.code IS NONE AND $loaded.account.id == type::record(fn::essai_id("jean")) AND array::len($loaded.rows) == 1
        AND $missing == { code: "MAIL_MESSAGE_NOT_FOUND", details: { messages: ["mail_message:absent"] } }
        AND fn::mail_flags_apply({ seen: false, answered: false, flagged: false, deleted: false, draft: false, keywords: ["b"] }, ["$SEEN", "A"], ["b"], NONE)
            == { seen: true, answered: false, flagged: false, deleted: false, draft: false, keywords: ["a"] };
};

-- test: fil d'un message selon ses ancêtres
RETURN fn::mail_thread_assign({ account: type::record(fn::essai_id("jean")), message_id: "nouveau@x", in_reply_to: ["absent@x"], base_subject: "s", is_report: false }).orphan == true
    AND fn::mail_thread_assign({ account: type::record(fn::essai_id("jean")), message_id: "nouveau@x", base_subject: "s", is_report: false }).orphan == false;

-- test: gardes et compteurs appelés directement (session système)
RETURN fn::mail_write_refusal("mail_content", { state: "released", object: mail_content:x }, { state: "stored", object: mail_content:x }) == "MAIL_CONTENT_STATE_INVALID"
    AND fn::mail_write_refusal("table_inconnue", NONE, {}) IS NONE
    AND fn::mail_counters_apply("table_inconnue", NONE, {}) IS NONE
    AND fn::mail_content_release(mail_content:absent) IS NONE;

-- test: retrait d'un contenu sans fichier : sans erreur
{
    LET $reserved = fn::mail_content_begin({ account: fn::essai_id("marie"), size: 10 }).data;
    LET $row = (SELECT id, tenant, key, object FROM ONLY $reserved.content);
    RETURN fn::mail_content_remove($row) AND !record::exists($reserved.content);
};

-- préparation: tables du courrier fermées à l'écriture (lecture inchangée), pour vérifier le contrôle de l'écriture principale
{
    DEFINE TABLE OVERWRITE mail_settings TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE tenant IS NONE OR fn::mail_can({ action: "settings", tenant: tenant }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE mail_domain TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "worker" }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE mail_account TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR fn::mail_can({ action: "mailbox", tenant: tenant, identity: identity }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE mail_address TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "manage", tenant: tenant }) OR (account IS NOT NONE AND fn::mail_can({ action: "mailbox", tenant: tenant, account: account })) OR fn::mail_can({ action: "worker" }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE mail_mailbox TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE mail_content TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE mail_message TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account }) FOR create, update, delete NONE;
};

-- test: gestion : écritures filtrées, erreur explicite, rien d'écrit
-- en tant que: admin
{
    LET $results = [
        fn::mail_settings_set({ tenant: "auth_organization:alpha", max_keywords_per_message: 3 }),
        fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha2" }),
        fn::mail_domain_update({ domain: fn::essai_id("domain"), state: "disabled" }),
        fn::mail_account_create({ identity: "auth_identity:membre", domain: fn::essai_id("domain"), local_part: "membre" }),
        fn::mail_account_update({ account: fn::essai_id("jean"), quota_bytes: 1 }),
        fn::mail_account_delete({ account: fn::essai_id("jean") }),
        fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "alias", kind: "alias", targets: [fn::essai_id("jean")] }),
        fn::mail_address_update({ address: <string> (SELECT VALUE primary_address FROM ONLY type::record(fn::essai_id("marie"))), state: "disabled" })
    ];
    RETURN $results.all(|$r| $r.error.code == "MAIL_WRITE_FORBIDDEN")
        AND fn::mail_domain_get({ domain: fn::essai_id("domain") }).data.state == "active"
        AND fn::mail_account_get({ account: fn::essai_id("jean") }).data.state == "active";
};

-- préparation: adresse supplémentaire de marie et domaine vide, écrits par la session système
{
    UPDATE passe:ids SET extra = <string> fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "m2", kind: "account", account: fn::essai_id("marie") }).data.id;
    UPDATE passe:ids SET empty = <string> fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha2" }).data.id;
};

-- test: suppressions filtrées : erreur explicite, rien de supprimé
-- en tant que: admin
RETURN fn::mail_address_delete({ address: fn::essai_id("extra") }).error.code == "MAIL_WRITE_FORBIDDEN"
    AND fn::mail_domain_delete({ domain: fn::essai_id("empty") }).error.code == "MAIL_WRITE_FORBIDDEN"
    AND record::exists(type::record(fn::essai_id("extra"))) AND record::exists(type::record(fn::essai_id("empty")));

-- test: boîte : écritures filtrées, erreur explicite, rien d'écrit
-- en tant que: jean
{
    LET $m1 = fn::essai_id("m1");
    LET $results = [
        fn::mail_mailbox_create({ name: "Projets" }),
        fn::mail_mailbox_update({ mailbox: fn::essai_id("jean_trash"), name: "Corbeille" }),
        fn::mail_content_begin({ account: fn::essai_id("jean"), size: 10 }),
        fn::mail_message_flags_set({ messages: [$m1], add: ["$seen"] }),
        fn::mail_message_move({ messages: [$m1], mailbox: fn::essai_id("jean_archive") }),
        fn::mail_message_copy({ messages: [$m1], mailbox: fn::essai_id("jean_archive") }),
        fn::mail_message_expunge({ mailbox: fn::essai_id("jean_inbox"), messages: [$m1] }),
        fn::mail_mailbox_delete({ mailbox: fn::essai_id("jean_sent") })
    ];
    RETURN $results.all(|$r| $r.error.code == "MAIL_WRITE_FORBIDDEN")
        AND fn::mail_mailbox_list({}).data.path == ["Archive", "Drafts", "INBOX", "Junk", "Sent", "Trash"]
        AND fn::mail_message_get({ message: $m1 }).data.{ seen, uid } == { seen: false, uid: 1 };
};

-- préparation: contenu stocké pour jean, écrit par la session système
UPDATE passe:ids SET c2 = fn::essai_contenu(fn::essai_id("jean"), 10);

-- test: inscription filtrée : erreur explicite
-- en tant que: jean
RETURN fn::mail_message_create({ content: fn::essai_id("c2"), mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).error.code == "MAIL_WRITE_FORBIDDEN";

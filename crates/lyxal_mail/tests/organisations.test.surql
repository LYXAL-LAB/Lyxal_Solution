-- lyxal-test: assertions
-- Organisations : isolement complet entre alpha et beta (aucune fiche visible, aucune écriture,
-- « introuvable » plutôt que « interdit »), puis suppression d'une organisation : toutes ses
-- données de courrier partent avec elle (cascade), ses fichiers avec son bucket, sans événement
-- de retrait, et sans toucher l'autre organisation.
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


-- préparation: messages, dossier, alias et réglages dans les deux organisations
{
    fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), { message_id: "a@x" });
    fn::essai_message(fn::essai_id("autre"), fn::essai_id("autre_inbox"), { message_id: "b@x" });
    fn::essai_message(fn::essai_id("autre"), fn::essai_id("autre_inbox"), { message_id: "c@x" });
    fn::mail_message_expunge({ mailbox: fn::essai_id("autre_inbox"), messages: (SELECT VALUE id FROM mail_message WHERE message_id = "c@x").map(|$i| <string> $i) });
    fn::mail_mailbox_create({ account: fn::essai_id("autre"), name: "Bois" });
    fn::mail_address_create({ domain: fn::essai_id("domain_beta"), local_part: "equipe", kind: "alias", targets: [fn::essai_id("autre")] });
    fn::mail_settings_set({ tenant: "auth_organization:beta", default_quota_bytes: 100000 });
    fn::mail_settings_set({ tenant: "auth_organization:alpha", default_quota_bytes: 200000 });
};

-- préparation: message remis par SMTP dans beta (fiche d'idempotence), attrape-tout et postmaster de beta
{
    LET $account = fn::essai_id("autre");
    LET $key = string::repeat("a", 64);
    LET $reserved = fn::mail_delivery_begin({ account: $account, size: 100, delivery_key: $key }).data;
    LET $bucket = (SELECT VALUE id FROM ONLY storage_bucket WHERE tenant = auth_organization:beta AND name = "lyxal-mail" LIMIT 1);
    LET $object = fn::storage_object_begin({ bucket: <string> $bucket, key: $reserved.storage_key, filename: "message.eml", declared_size: 100 }).data;
    fn::storage_object_commit({ object: <string> $object.id, size: 100, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key: "enc:v2:essai-files-1:QUJD" });
    fn::mail_delivery_commit({ account: $account, items: [{
        content: <string> $reserved.content, object: <string> $object.id, received_at: time::now(), delivery_key: $key, message_id: "d@x",
        envelope: { subject: "Remis" }, structure: { type: "text/plain", size: 100 },
        reception: { spf: "pass", dkim: "pass", dmarc: "pass", iprev: "pass", antivirus: "not_scanned", spam: "none", tls: true }
    }] });
    fn::mail_domain_update({ domain: fn::essai_id("domain_beta"), catch_all: $account, postmaster: $account });
};

-- test: remise de beta en place : message d'origine delivery, fiche d'idempotence, attrape-tout
RETURN (SELECT VALUE origin FROM mail_message WHERE message_id = "d@x") == ["delivery"]
    AND (SELECT VALUE tenant FROM mail_delivery) == [auth_organization:beta]
    AND fn::mail_domain_get({ domain: fn::essai_id("domain_beta") }).data.catch_all == type::record(fn::essai_id("autre"))
    AND fn::mail_recipient_resolve({ address: "nimporte@beta.test" }).data.tenant == auth_organization:beta;

-- test: l'administrateur de beta ne voit rien d'alpha
-- en tant que: autre
RETURN [mail_domain, mail_account, mail_address, mail_mailbox, mail_content, mail_message, mail_tombstone].all(|$t| (SELECT VALUE tenant FROM $t).all(|$x| $x == auth_organization:beta))
    AND (SELECT VALUE tenant FROM mail_settings WHERE tenant IS NOT NONE) == [auth_organization:beta]
    AND array::len(SELECT * FROM mail_message) == 2
    AND array::len(SELECT * FROM mail_delivery) == 0 AND array::len(SELECT * FROM mail_network_block) == 0;

-- test: l'administrateur d'alpha ne voit rien de beta, ni les boîtes de ses membres
-- en tant que: admin
RETURN [mail_domain, mail_account, mail_address].all(|$t| (SELECT VALUE tenant FROM $t).all(|$x| $x == auth_organization:alpha))
    AND [mail_mailbox, mail_content, mail_message, mail_tombstone, mail_delivery, mail_network_block].all(|$t| array::len(SELECT * FROM $t) == 0);

-- test: un identifiant d'une autre organisation est introuvable, pas interdit
-- en tant que: autre
RETURN fn::mail_domain_get({ domain: fn::essai_id("domain") }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_account_get({ account: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_message_list({ mailbox: fn::essai_id("jean_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_quota_get({ account: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_content_begin({ account: fn::essai_id("jean"), size: 1 }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_account_create({ identity: "auth_identity:autre", domain: fn::essai_id("domain"), local_part: "intrus" }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_address_create({ domain: fn::essai_id("domain_beta"), local_part: "fuite", kind: "account", account: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), catch_all: fn::essai_id("autre") }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain_beta"), catch_all: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain_beta"), postmaster: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_recipient_resolve({ address: "jean@alpha.test" }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_delivery_begin({ account: fn::essai_id("jean"), size: 1, delivery_key: string::repeat("b", 64) }).error.code == "MAIL_PERMISSION_DENIED";

-- test: écriture directe dans une autre organisation : sans effet
-- en tant que: autre
{
    UPDATE mail_account SET quota_bytes = 1 WHERE tenant = auth_organization:alpha;
    DELETE mail_address WHERE tenant = auth_organization:alpha;
    RETURN true;
};

-- test: rien n'a changé dans alpha
RETURN (SELECT VALUE quota_bytes FROM mail_account WHERE tenant = auth_organization:alpha) == [NONE, NONE]
    AND array::len(SELECT * FROM mail_address WHERE tenant = auth_organization:alpha) == 2;

-- test: suppression de l'organisation beta : toutes ses données de courrier et ses fichiers partent, sans événement de retrait
{
    LET $events = array::len(SELECT * FROM event_outbox WHERE string::starts_with(event_type, "mail.") AND (string::ends_with(event_type, ".deleted")));
    DELETE auth_organization:beta;
    RETURN [mail_settings, mail_domain, mail_account, mail_address, mail_mailbox, mail_content, mail_message, mail_tombstone, mail_delivery].all(|$t| array::len(SELECT * FROM $t WHERE tenant = auth_organization:beta) == 0)
        AND array::len(SELECT * FROM storage_object WHERE tenant = auth_organization:beta) == 0
        AND array::len(SELECT * FROM storage_bucket WHERE tenant = auth_organization:beta) == 0
        AND !record::exists(auth_organization_domain:beta)
        AND array::len(SELECT * FROM event_outbox WHERE string::starts_with(event_type, "mail.") AND string::ends_with(event_type, ".deleted")) == $events;
};

-- test: alpha intacte, compteurs exacts
RETURN fn::essai_coherent(fn::essai_id("jean")) AND fn::essai_coherent(fn::essai_id("marie"))
    AND array::len(SELECT * FROM mail_account WHERE tenant = auth_organization:alpha) == 2
    AND array::len(SELECT * FROM mail_message WHERE tenant = auth_organization:alpha) == 1
    AND fn::mail_settings_effective({ tenant: auth_organization:alpha }).default_quota_bytes == 200000
    AND array::len(SELECT * FROM storage_object WHERE tenant = auth_organization:alpha) == 1;

-- test: le domaine de lyxal_auth d'alpha reste protégé
-- attendu-erreur: MAIL_DOMAIN_EXISTS
DELETE auth_organization_domain:alpha;

-- test: suppression de l'organisation alpha : plus rien, ni compte ni fichier
{
    DELETE auth_organization:alpha;
    RETURN [mail_settings, mail_domain, mail_account, mail_address, mail_mailbox, mail_content, mail_message, mail_tombstone, mail_delivery].all(|$t| array::len(SELECT * FROM $t WHERE tenant IS NOT NONE) == 0)
        AND array::len(SELECT * FROM storage_object) == 0;
};

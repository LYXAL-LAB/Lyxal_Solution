-- lyxal-test: assertions
-- Réglages : valeurs par défaut (décisions M17, M18), installation puis organisation, effacement
-- (clear), bornes, lecture des limites par un membre qui a une boîte, droits par portée.
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


-- test: valeurs par défaut du module
RETURN fn::mail_settings_effective({}) == {
        max_message_bytes: 52428800, default_quota_bytes: NONE, tombstone_retention_days: 30,
        max_mailboxes_per_account: 1000, max_addresses_per_account: 100, max_keywords_per_message: 50
    }
    AND fn::mail_settings_get({}).data == { own: NONE, effective: fn::mail_settings_effective({}) };

-- test: l'administrateur de la plateforme règle l'installation
-- en tant que: plateforme
{
    LET $saved = fn::mail_settings_set({ max_message_bytes: 1048576, tombstone_retention_days: 10 });
    RETURN $saved.ok AND $saved.data.scope_key == "installation" AND $saved.data.tenant IS NONE
        AND fn::mail_settings_get({}).data.effective.max_message_bytes == 1048576
        AND fn::mail_settings_set({ tenant: "auth_organization:alpha", max_message_bytes: 2048 }).error.code == "MAIL_PERMISSION_DENIED";
};

-- test: l'administrateur d'une organisation ne règle pas l'installation
-- en tant que: admin
RETURN fn::mail_settings_set({ max_message_bytes: 4096 }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_settings_get({}).data.effective.max_message_bytes == 1048576;

-- test: réglages de l'organisation, repli sur l'installation champ par champ
-- en tant que: admin
{
    LET $saved = fn::mail_settings_set({ tenant: "auth_organization:alpha", default_quota_bytes: 1000, max_keywords_per_message: 5 });
    LET $read = fn::mail_settings_get({ tenant: "auth_organization:alpha" }).data;
    RETURN $saved.ok AND $read.own.default_quota_bytes == 1000 AND $read.own.max_message_bytes IS NONE
        AND $read.effective == {
            max_message_bytes: 1048576, default_quota_bytes: 1000, tombstone_retention_days: 10,
            max_mailboxes_per_account: 1000, max_addresses_per_account: 100, max_keywords_per_message: 5
        };
};

-- test: un champ fourni remplace, clear efface, les autres restent
-- en tant que: admin
{
    LET $saved = fn::mail_settings_set({ tenant: "auth_organization:alpha", max_addresses_per_account: 3, clear: ["default_quota_bytes"] }).data;
    RETURN $saved.default_quota_bytes IS NONE AND $saved.max_keywords_per_message == 5 AND $saved.max_addresses_per_account == 3
        AND fn::mail_settings_effective({ tenant: auth_organization:alpha }).default_quota_bytes IS NONE;
};

-- test: bornes et paramètres refusés par le moteur de lyxal_core
-- en tant que: admin
RETURN fn::mail_settings_set({ tenant: "auth_organization:alpha", tombstone_retention_days: 3 }).error.{ code, fields: details.fields.keys() } == { code: "MAIL_INVALID_PARAMETERS", fields: ["tombstone_retention_days"] }
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", max_message_bytes: 10 }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", max_mailboxes_per_account: 5 }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", clear: ["inconnu"] }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", couleur: "bleu" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_settings_get({ tenant: "pas-une-organisation:x" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_settings_get({ tenant: "auth_organization:alpha", language: "en" }).ok;

-- test: le message d'erreur suit la langue demandée
-- en tant que: admin
RETURN fn::mail_settings_set({ tenant: "auth_organization:alpha", tombstone_retention_days: 3, language: "en" }).error.label == "Invalid parameters"
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", tombstone_retention_days: 3 }).error.label == "Paramètres invalides";

-- test: un membre qui a une boîte lit les limites de son organisation, ne les change pas
-- en tant que: jean
RETURN fn::mail_settings_get({ tenant: "auth_organization:alpha" }).data.effective.max_addresses_per_account == 3
    AND fn::mail_settings_effective({ tenant: auth_organization:alpha }).max_keywords_per_message == 5
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", max_keywords_per_message: 50 }).error.code == "MAIL_PERMISSION_DENIED";

-- test: un membre sans droit de courrier lit l'installation seulement
-- en tant que: membre
RETURN fn::mail_settings_get({}).ok
    AND fn::mail_settings_get({ tenant: "auth_organization:alpha" }).error.code == "MAIL_PERMISSION_DENIED"
    AND array::len(SELECT * FROM mail_settings WHERE tenant = auth_organization:alpha) == 0;

-- test: une autre organisation ne lit ni ne règle alpha
-- en tant que: autre
RETURN fn::mail_settings_get({ tenant: "auth_organization:alpha" }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", max_keywords_per_message: 50 }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_settings_get({ tenant: "auth_organization:beta" }).data.own IS NONE;

-- test: le compte de service lit les réglages de toute organisation, ne les change pas
-- en tant que: worker
RETURN fn::mail_settings_get({ tenant: "auth_organization:alpha" }).data.own.max_addresses_per_account == 3
    AND fn::mail_settings_set({ tenant: "auth_organization:alpha", max_keywords_per_message: 50 }).error.code == "MAIL_PERMISSION_DENIED";

-- test: une ligne par portée ; la suppression n'est permise à personne hors session système
-- en tant que: admin
RETURN array::len(DELETE mail_settings RETURN BEFORE) == 0
    AND array::len(SELECT * FROM mail_settings) == 2;

-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : contenus (chemin de dépôt) et maintenance
-- MODULE    : lyxal_mail
-- ============================================================================
-- Chemin de dépôt (plan du lot 4, §3) : fn::mail_content_begin (session de l'appelant : droits,
-- taille, quota) → écriture chiffrée par lyxal_storage sous la session système de l'hôte →
-- fn::mail_content_attach (session système) → fn::mail_message_create (session de l'appelant).
-- Aucun utilisateur n'a de droit storage.* sur le bucket du courrier : les fonctions qui touchent
-- aux fichiers (attache, maintenance) s'exécutent sous la session système de l'hôte, ou sous un
-- compte de service qui a aussi le droit storage.worker. Les fichiers sont lus et supprimés par
-- les fonctions publiques de lyxal_storage seulement.

-- ----------------------------------------------------------------------------
-- fn::mail_content_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_content_begin($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }], required: true },
            size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5368709120 } }], required: true },
            protection: { pipeline: [{ rule: "enum", options: { allowed: ["platform"], case_sensitive: true } }], default: "platform" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $account = (SELECT id, tenant, state, used_bytes, quota_bytes, quota_exceeded_at FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    IF !fn::mail_can({ action: "mailbox", tenant: $account.tenant, account: $account.id }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $account.state != "active" { RETURN fn::error_result(IF $account.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    LET $settings = fn::mail_settings_effective({ tenant: $account.tenant });
    IF $p.size > $settings.max_message_bytes { RETURN fn::error_result("MAIL_MESSAGE_TOO_LARGE", $p.language, { size: $p.size, max_message_bytes: $settings.max_message_bytes }); };
    LET $quota = $account.quota_bytes ?? $settings.default_quota_bytes;
    IF $quota IS NOT NONE AND $account.used_bytes + $p.size > $quota {
        -- Premier refus depuis le dernier passage sous le quota : publie mail.quota.exceeded
        IF $account.quota_exceeded_at IS NONE { UPDATE $account.id SET quota_exceeded_at = time::now(); };
        RETURN fn::error_result("MAIL_QUOTA_EXCEEDED", $p.language, { quota_bytes: $quota, used_bytes: $account.used_bytes });
    };
    LET $created = (CREATE ONLY mail_content CONTENT {
        tenant: $account.tenant, account: $account.id, key: string::concat(<string> record::id($account.id), "/", <string> rand::uuid::v7(), ".eml"),
        state: "pending", size: $p.size, protection: $p.protection, expires_at: time::now() + 1h
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_content" }); };
    RETURN fn::result_ok({ content: $created.id, key: $created.key, bucket_name: "lyxal-mail", max_size: $settings.max_message_bytes, tenant: $account.tenant, expires_at: $created.expires_at });
} COMMENT "Réserve le contenu d'un message à déposer ({ account, size (octets en clair), protection (platform seul au lot 4) }) : compte actif, taille (MAIL_MESSAGE_TOO_LARGE) et quota (MAIL_QUOTA_EXCEEDED, mail.quota.exceeded au premier refus) contrôlés ; contenu pending, abandonné après 1 h ; { content, key (clé du fichier : <compte>/<UUID v7>.eml), bucket_name (lyxal-mail, bucket chiffré de l'organisation), max_size, tenant, expires_at }. Droit : titulaire du compte, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_content_attach
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_content_attach($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            content: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true },
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $content = (SELECT id, tenant, key, size, state, expires_at FROM ONLY $p.content);
    IF $content == NONE { RETURN fn::error_result("MAIL_CONTENT_NOT_FOUND", $p.language, { content: <string> $p.content }); };
    IF $content.state != "pending" OR $content.expires_at <= time::now() { RETURN fn::error_result("MAIL_CONTENT_STATE_INVALID", $p.language, { state: $content.state, expected: "pending" }); };
    -- Le fichier, lu par les fonctions publiques de lyxal_storage : disponible, dans le bucket
    -- chiffré lyxal-mail de l'organisation, à la clé du contenu, de même taille en clair
    LET $object = fn::storage_object_get({ object: <string> $p.object });
    IF !$object.ok { RETURN fn::error_result("MAIL_CONTENT_UNAVAILABLE", $p.language, { storage: $object.error.code }); };
    LET $bucket = fn::storage_bucket_get({ bucket: <string> $object.data.bucket });
    IF !$bucket.ok { RETURN fn::error_result("MAIL_CONTENT_UNAVAILABLE", $p.language, { storage: $bucket.error.code }); };
    IF $object.data.state != "available" OR $object.data.key != $content.key OR $object.data.size != $content.size
        OR $bucket.data.name != "lyxal-mail" OR $bucket.data.tenant != $content.tenant OR !$bucket.data.encrypted {
        RETURN fn::error_result("MAIL_CONTENT_STATE_INVALID", $p.language, { object: <string> $p.object });
    };
    LET $updated = (UPDATE ONLY $content.id SET state = "stored", object = $object.data.id);
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_content" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Lie un contenu pending à son fichier écrit par lyxal_storage ({ content, object }) : le fichier doit être available, dans le bucket chiffré lyxal-mail de l'organisation (chiffrement obligatoire, décision M1), à la clé du contenu et de même taille en clair (sinon MAIL_CONTENT_STATE_INVALID ; fichier illisible : MAIL_CONTENT_UNAVAILABLE) ; contenu stored, à inscrire avant son délai d'abandon. Droit : session système, ou compte de service qui lit les fichiers";

-- ----------------------------------------------------------------------------
-- fn::mail_content_open
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_content_open($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            message: { pipeline: [{ rule: "record", options: { expected_table: "mail_message" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $message = (SELECT id, tenant, account, content FROM ONLY $p.message);
    -- Contrôle complet une fois par appel (la permission de la fiche est un contrôle allégé)
    IF $message == NONE OR !fn::mail_can({ action: "mailbox", tenant: $message.tenant, account: $message.account }) { RETURN fn::error_result("MAIL_MESSAGE_NOT_FOUND", $p.language, { message: <string> $p.message }); };
    LET $content = (SELECT object, size, state, protection, key_fingerprint FROM ONLY $message.content);
    IF $content == NONE OR $content.state != "stored" OR $content.object IS NONE { RETURN fn::error_result("MAIL_CONTENT_UNAVAILABLE", $p.language, {}); };
    RETURN fn::result_ok({ object: $content.object, size: $content.size, protection: $content.protection, key_fingerprint: $content.key_fingerprint });
} COMMENT "Fichier à lire pour un message ({ message }) : { object (fiche de lyxal_storage, lue et déchiffrée par le service sous la session système), size, protection, key_fingerprint } ; MAIL_CONTENT_UNAVAILABLE si le contenu n'est pas stocké. Droit : titulaire du compte, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_content_remove (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_content_remove($content: object) -> bool {
    -- Fichier du contenu : sa fiche (contenu stocké), sinon celle écrite à sa clé (dépôt interrompu)
    LET $object = IF $content.object IS NOT NONE {
        fn::storage_object_get({ object: <string> $content.object })
    } ELSE {
        LET $buckets = fn::storage_bucket_list({ tenant: <string> $content.tenant, limit: 1000 });
        IF !$buckets.ok { THROW "MAIL_CONTENT_UNAVAILABLE"; };
        LET $bucket = array::first(array::filter($buckets.data.items, |$b| $b.name = "lyxal-mail"));
        IF $bucket IS NONE { NONE } ELSE { fn::storage_object_get({ bucket: <string> $bucket.id, key: $content.key }) }
    };
    IF $object IS NOT NONE AND !$object.ok AND $object.error.code != "STORAGE_OBJECT_NOT_FOUND" { THROW "MAIL_CONTENT_UNAVAILABLE"; };
    -- Le contenu d'abord : le fichier n'est plus référencé, puis il est supprimé dans la même transaction
    DELETE $content.id;
    IF $object IS NOT NONE AND $object.ok AND $object.data.state != "deleted" {
        LET $removed = fn::storage_object_delete({ object: <string> $object.data.id });
        IF !$removed.ok { THROW $removed.error.code; };
    };
    RETURN true;
} COMMENT "Interne : retire un contenu ($content : id, tenant, key, object) et son fichier dans la même transaction (fn::storage_object_delete), jamais l'un sans l'autre : un refus de lyxal_storage annule tout (THROW) ; un fichier jamais écrit est ignoré";

-- ----------------------------------------------------------------------------
-- fn::mail_content_expire
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_content_expire($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    -- Abandonnés : pending, ou stored jamais inscrits, hors délai ; libérés : plus aucun lecteur
    LET $now = time::now();
    LET $abandoned = array::concat(
        (SELECT id, tenant, key, object FROM mail_content WHERE state = "pending" AND expires_at < $now ORDER BY expires_at LIMIT $p.limit),
        (SELECT id, tenant, key, object FROM mail_content WHERE state = "stored" AND expires_at < $now AND refs = 0 ORDER BY expires_at LIMIT $p.limit)
    );
    LET $released = (SELECT id, tenant, key, object FROM mail_content WHERE state = "released" ORDER BY expires_at LIMIT $p.limit);
    LET $expired = array::slice($abandoned, 0, $p.limit);
    LET $freed = array::slice($released, 0, $p.limit - array::len($expired));
    FOR $content IN array::concat($expired, $freed) { fn::mail_content_remove($content); };
    RETURN fn::result_ok({ expired: array::len($expired), released: array::len($freed) });
} COMMENT "Maintenance ({ limit : 100 }) : contenus abandonnés (pending, ou stored jamais inscrits, après leur délai d'une heure) et contenus libérés (released : plus aucun message ne les lit) retirés avec leur fichier dans la même transaction (aucun fichier orphelin) ; { expired, released }. Droit : session système, ou compte de service qui gère aussi les fichiers (storage.worker)";

-- ----------------------------------------------------------------------------
-- fn::mail_tombstone_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_tombstone_purge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 1000 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    -- Par organisation : conservation de ses réglages (7 à 365 jours)
    LET $tenants = array::distinct(SELECT VALUE tenant FROM mail_account);
    LET $rows = array::slice(array::flatten(array::map($tenants, |$tenant| {
        LET $cutoff = time::now() - duration::from_days(fn::mail_settings_effective({ tenant: $tenant }).tombstone_retention_days);
        RETURN (SELECT id, account, modseq, created_at FROM mail_tombstone WHERE tenant = $tenant AND created_at < $cutoff ORDER BY created_at LIMIT $p.limit);
    })), 0, $p.limit);
    IF array::len($rows) = 0 { RETURN fn::result_ok({ purged: 0 }); };
    DELETE $rows.id;
    -- Plancher du compte : plus haut numéro de modification purgé
    FOR $account IN array::distinct($rows.account) {
        LET $floor = math::max(array::map(array::filter($rows, |$row| $row.account = $account), |$row| $row.modseq));
        UPDATE $account SET changes_floor = math::max([changes_floor, $floor]);
    };
    RETURN fn::result_ok({ purged: array::len($rows) });
} COMMENT "Maintenance ({ limit : 1 000 }) : pierres tombales plus anciennes que la conservation de leur organisation (tombstone_retention_days, 30 jours par défaut) retirées ; le plancher des comptes (changes_floor) avance au plus haut numéro purgé : une synchronisation plus ancienne rend MAIL_CHANGES_TOO_OLD ; { purged }. Droit : session système, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_account_purge_step
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_account_purge_step($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5000 } }], default: 500 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $account = (SELECT id, tenant FROM ONLY mail_account WHERE state = "deleting" ORDER BY id LIMIT 1);
    IF $account == NONE { RETURN fn::result_ok({ accounts: 0, messages: 0, done: true }); };
    -- Messages par lots (ni pierre tombale ni numéro de modification pour un compte en purge),
    -- puis contenus et fichiers, puis le compte (dossiers et pierres tombales en cascade)
    LET $messages = (SELECT VALUE id FROM mail_message WHERE account = $account.id LIMIT $p.limit);
    IF array::len($messages) > 0 {
        DELETE $messages;
        RETURN fn::result_ok({ accounts: 0, messages: array::len($messages), done: false });
    };
    LET $contents = (SELECT id, tenant, key, object FROM mail_content WHERE account = $account.id LIMIT $p.limit);
    IF array::len($contents) > 0 {
        FOR $content IN $contents { fn::mail_content_remove($content); };
        RETURN fn::result_ok({ accounts: 0, messages: 0, done: false });
    };
    LET $deleted = (DELETE ONLY $account.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_account" }); };
    RETURN fn::result_ok({ accounts: 1, messages: 0, done: array::len(SELECT VALUE id FROM mail_account WHERE state = "deleting" LIMIT 1) = 0 });
} COMMENT "Maintenance ({ limit : 500 }) : purge par étapes d'un compte en suppression (deleting) : ses messages par lots, puis ses contenus avec leurs fichiers (même transaction), puis le compte, ses dossiers et ses pierres tombales ; publie mail.account.deleted ; { accounts (comptes purgés), messages (messages retirés), done (plus aucun compte à purger) }, à rappeler jusqu'à done. Droit : session système, ou compte de service qui gère aussi les fichiers (storage.worker)";

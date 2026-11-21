-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : dossiers
-- MODULE    : lyxal_mail
-- ============================================================================
-- Lus et écrits par le titulaire du compte (et le compte de service), jamais par
-- l'administrateur de l'organisation (décision M11). Un dossier invisible est introuvable.

-- ----------------------------------------------------------------------------
-- fn::mail_mailbox_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_mailbox_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            parent: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }] },
            role: { pipeline: [{ rule: "enum", options: { allowed: ["drafts", "sent", "junk", "trash", "archive"], case_sensitive: true } }] },
            subscribed: { pipeline: [{ rule: "boolean" }], default: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { name: { pipeline: [{ rule: "normalize_unicode", options: { collapse_whitespace: false } }, { rule: "remove_control_chars", options: { preserve_layout: false } }, { rule: "trim" }] } }, unknown_keys: "keep" }, 20);
    -- Nom : un segment de chemin, sans « / » ni caractère joker IMAP (« * », « % »)
    IF !fn::validation_regex($p.name, "^[^/*%]+$").valid OR !fn::validation_max_length($p.name, 255).valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { name: ["format"] } });
    };
    LET $above = IF $p.parent IS NONE { NONE } ELSE { (SELECT id, account, path FROM ONLY $p.parent) };
    IF $p.parent IS NOT NONE AND $above == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.parent }); };
    IF $above IS NOT NONE AND $p.account IS NOT NONE AND $p.account != $above.account {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { parent: ["other_account"] } });
    };
    LET $target = fn::mail_session_account($p.account ?? $above.account);
    LET $account = IF $target IS NONE { NONE } ELSE { (SELECT id, tenant, state, mailbox_count FROM ONLY $target) };
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, {}); };
    IF !fn::mail_can({ action: "mailbox", tenant: $account.tenant, account: $account.id }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $account.state != "active" { RETURN fn::error_result(IF $account.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    LET $max = fn::mail_settings_effective({ tenant: $account.tenant }).max_mailboxes_per_account;
    IF $account.mailbox_count >= $max { RETURN fn::error_result("MAIL_MAILBOX_LIMIT", $p.language, { max_mailboxes_per_account: $max }); };
    LET $path = IF $above IS NONE { $p.name } ELSE { string::concat($above.path, "/", $p.name) };
    IF string::len($path) > 1024 { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { name: ["path_too_long"] } }); };
    -- INBOX est réservé à la boîte de réception, quelle que soit la casse (RFC 9051)
    IF ($above IS NONE AND string::lowercase($p.name) = "inbox")
        OR array::len(SELECT VALUE id FROM mail_mailbox WHERE account = $account.id AND path = $path LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_MAILBOX_EXISTS", $p.language, {});
    };
    IF $p.role IS NOT NONE AND array::len(SELECT VALUE id FROM mail_mailbox WHERE account = $account.id AND role = $p.role LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_MAILBOX_ROLE_TAKEN", $p.language, { role: $p.role });
    };
    LET $modseq = fn::mail_modseq_next($account.id);
    LET $created = (CREATE ONLY mail_mailbox CONTENT {
        tenant: $account.tenant, account: $account.id, parent: $above.id, name: $p.name, path: $path, role: $p.role,
        subscribed: $p.subscribed, uid_validity: (SELECT VALUE uid_validity_next FROM ONLY $account.id), modseq: $modseq, highest_modseq: $modseq
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_mailbox" }); };
    RETURN fn::result_ok($created);
} COMMENT "Crée un dossier ({ name, parent, role (drafts, sent, junk, trash, archive), subscribed, account (absent : celui du parent, sinon celui de la session) }) : chemin parent/nom, UIDVALIDITY tirée du compteur du compte (un dossier recréé sous un ancien nom en reçoit une plus grande) ; INBOX réservé (MAIL_MAILBOX_EXISTS), MAIL_MAILBOX_ROLE_TAKEN, MAIL_MAILBOX_LIMIT. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_mailbox_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_mailbox_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $mailbox = (SELECT * FROM ONLY $p.mailbox);
    IF $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    RETURN fn::result_ok($mailbox);
} COMMENT "Dossier ({ mailbox }) et ses compteurs tenus (total, unseen, size, uid_next, uid_validity, highest_modseq). Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_mailbox_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_mailbox_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $target = fn::mail_session_account($p.account);
    LET $account = IF $target IS NONE { NONE } ELSE { (SELECT id, tenant FROM ONLY $target) };
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, {}); };
    IF !fn::mail_can({ action: "mailbox", tenant: $account.tenant, account: $account.id }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok(SELECT * FROM mail_mailbox WHERE account = $account.id ORDER BY path, id);
} COMMENT "Dossiers d'un compte ({ account }, absent : celui de la session), triés par chemin, compteurs compris (lus tels quels, aucun calcul). Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_mailbox_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_mailbox_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }] },
            parent: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }] },
            role: { pipeline: [{ rule: "enum", options: { allowed: ["drafts", "sent", "junk", "trash", "archive"], case_sensitive: true } }] },
            subscribed: { pipeline: [{ rule: "boolean" }] },
            sort_order: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 2147483647 } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["parent", "role"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { name: { pipeline: [{ rule: "normalize_unicode", options: { collapse_whitespace: false } }, { rule: "remove_control_chars", options: { preserve_layout: false } }, { rule: "trim" }] } }, unknown_keys: "keep" }, 20);
    IF $p.name IS NOT NONE AND (!fn::validation_regex($p.name, "^[^/*%]+$").valid OR !fn::validation_max_length($p.name, 255).valid) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { name: ["format"] } });
    };
    LET $mailbox = (SELECT * FROM ONLY $p.mailbox);
    IF $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $state = (SELECT VALUE state FROM ONLY $mailbox.account);
    IF $state != "active" { RETURN fn::error_result(IF $state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    LET $name = $p.name ?? $mailbox.name;
    LET $parent_id = IF "parent" IN $p.clear { NONE } ELSE { $p.parent ?? $mailbox.parent };
    LET $role = IF "role" IN $p.clear { NONE } ELSE { $p.role ?? $mailbox.role };
    -- La boîte de réception ne se renomme ni ne se déplace au lot 4, et garde son rôle
    IF $mailbox.role = "inbox" AND ($name != $mailbox.name OR $parent_id != $mailbox.parent OR $role != "inbox") {
        RETURN fn::error_result("MAIL_MAILBOX_PROTECTED", $p.language, {});
    };
    LET $above = IF $parent_id IS NONE { NONE } ELSE { (SELECT id, account, path FROM ONLY $parent_id) };
    IF $parent_id IS NOT NONE AND ($above == NONE OR $above.account != $mailbox.account) { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $parent_id }); };
    IF $above IS NOT NONE AND ($above.id = $mailbox.id OR string::starts_with($above.path, string::concat($mailbox.path, "/"))) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { parent: ["cycle"] } });
    };
    LET $path = IF $above IS NONE { $name } ELSE { string::concat($above.path, "/", $name) };
    IF string::len($path) > 1024 { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { name: ["path_too_long"] } }); };
    IF $path != $mailbox.path AND (($above IS NONE AND string::lowercase($name) = "inbox")
        OR array::len(SELECT VALUE id FROM mail_mailbox WHERE account = $mailbox.account AND path = $path LIMIT 1) > 0) {
        RETURN fn::error_result("MAIL_MAILBOX_EXISTS", $p.language, {});
    };
    IF $role IS NOT NONE AND $role != $mailbox.role AND array::len(SELECT VALUE id FROM mail_mailbox WHERE account = $mailbox.account AND role = $role LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_MAILBOX_ROLE_TAKEN", $p.language, { role: $role });
    };
    LET $subscribed = $p.subscribed ?? $mailbox.subscribed;
    LET $sort_order = $p.sort_order ?? $mailbox.sort_order;
    IF $path = $mailbox.path AND $parent_id = $mailbox.parent AND $role = $mailbox.role AND $subscribed = $mailbox.subscribed AND $sort_order = $mailbox.sort_order {
        RETURN fn::result_ok($mailbox);
    };
    LET $modseq = fn::mail_modseq_next($mailbox.account);
    LET $updated = (UPDATE ONLY $mailbox.id SET name = $name, parent = $parent_id, path = $path, role = $role,
        subscribed = $subscribed, sort_order = $sort_order, modseq = $modseq);
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_mailbox" }); };
    -- Renommage ou déplacement : chemins des sous-dossiers réécrits, parents d'abord
    IF $path != $mailbox.path {
        FOR $child IN (SELECT id, path FROM mail_mailbox WHERE account = $mailbox.account AND string::starts_with(path, string::concat($mailbox.path, "/")) ORDER BY path) {
            UPDATE $child.id SET path = string::concat($path, string::slice($child.path, string::len($mailbox.path))), modseq = $modseq;
        };
    };
    RETURN fn::result_ok((SELECT * FROM ONLY $mailbox.id));
} COMMENT "Modifie un dossier ({ mailbox, name, parent, role, subscribed, sort_order, clear (parent : premier niveau ; role) }) : un renommage ou un déplacement réécrit les chemins des sous-dossiers dans la même transaction et garde l'UIDVALIDITY ; la boîte de réception ne se renomme pas au lot 4 (MAIL_MAILBOX_PROTECTED) ; MAIL_MAILBOX_EXISTS, MAIL_MAILBOX_ROLE_TAKEN, boucle refusée. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_mailbox_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_mailbox_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            remove_messages: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $mailbox = (SELECT id, account, role, total FROM ONLY $p.mailbox);
    IF $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $state = (SELECT VALUE state FROM ONLY $mailbox.account);
    IF $state != "active" { RETURN fn::error_result(IF $state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    IF $mailbox.role = "inbox" { RETURN fn::error_result("MAIL_MAILBOX_PROTECTED", $p.language, {}); };
    IF array::len(SELECT VALUE id FROM mail_mailbox WHERE account = $mailbox.account AND parent = $mailbox.id LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_MAILBOX_HAS_CHILDREN", $p.language, {});
    };
    IF $mailbox.total > 0 AND !$p.remove_messages { RETURN fn::error_result("MAIL_MAILBOX_NOT_EMPTY", $p.language, { total: $mailbox.total }); };
    -- Au-delà de 5 000 messages : vidage par lots d'abord (fn::mail_message_expunge)
    IF $mailbox.total > 5000 { RETURN fn::error_result("MAIL_MAILBOX_TOO_LARGE", $p.language, { total: $mailbox.total, max: 5000 }); };
    LET $expunged = IF $mailbox.total > 0 { array::len(DELETE mail_message WHERE mailbox = $mailbox.id RETURN BEFORE) } ELSE { 0 };
    LET $deleted = (DELETE ONLY $mailbox.id RETURN BEFORE);
    IF $deleted == NONE OR $expunged != $mailbox.total { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_mailbox" }); };
    RETURN fn::result_ok({ deleted: true, expunged: $expunged });
} COMMENT "Supprime un dossier ({ mailbox, remove_messages (faux par défaut) }) : refus pour la boîte de réception (MAIL_MAILBOX_PROTECTED), un dossier parent (MAIL_MAILBOX_HAS_CHILDREN), un dossier non vide sans remove_messages (MAIL_MAILBOX_NOT_EMPTY) ou de plus de 5 000 messages (MAIL_MAILBOX_TOO_LARGE : vider par lots d'abord) ; pierres tombales des messages et du dossier ; { deleted, expunged }. Droit : titulaire du compte";

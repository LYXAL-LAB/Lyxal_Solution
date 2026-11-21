-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : messages, synchronisation, fils
-- MODULE    : lyxal_mail
-- ============================================================================
-- Une fonction est une seule instruction, donc une seule transaction ; elle prend le prochain
-- numéro de modification du compte (fn::mail_modseq_next) et le pose sur ce qu'elle change ; les
-- événements tiennent compteurs, pierres tombales et lecteurs des contenus. Deux écritures
-- concurrentes dans un même compte se heurtent sur la fiche du compte : l'une est refusée pour
-- conflit de transaction et rejouée par le service Rust (lot 4d). Pages par curseur, jamais par
-- décalage. Drapeaux système écrits $seen, $answered, $flagged, $deleted, $draft (mots-clés JMAP).

-- ----------------------------------------------------------------------------
-- fn::mail_message_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_create($params: object) {
    LET $text = |$max| { pipeline: [{ rule: "optional_string", options: { max_length: $max } }] };
    LET $ids = |$max| { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: $max } }] };
    LET $list = { pipeline: [{ rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
        fields: { name: $text(2048), address: $text(2048), group: $text(2048) }, unknown_keys: "reject"
    } } }] } }] };
    LET $report = fn::validation_object_execute($params, {
        fields: {
            content: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true },
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            received_at: { pipeline: [{ rule: "datetime" }], required: true },
            sent_at: { pipeline: [{ rule: "datetime" }] },
            seen: { pipeline: [{ rule: "boolean" }], default: false },
            answered: { pipeline: [{ rule: "boolean" }], default: false },
            flagged: { pipeline: [{ rule: "boolean" }], default: false },
            deleted: { pipeline: [{ rule: "boolean" }], default: false },
            draft: { pipeline: [{ rule: "boolean" }], default: false },
            keywords: fn::mail_keywords_rule(),
            message_id: $text(2048),
            in_reply_to: $ids(100),
            references: $ids(1000),
            base_subject: $text(16384),
            is_report: { pipeline: [{ rule: "boolean" }], default: false },
            envelope: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    date: { pipeline: [{ rule: "datetime" }] }, subject: $text(16384), message_id: $text(2048),
                    in_reply_to: $ids(100), references: $ids(1000),
                    from: $list, sender: $list, reply_to: $list, to: $list, cc: $list, bcc: $list
                },
                unknown_keys: "reject"
            } } }] },
            structure: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 1048576 } }] },
            has_attachment: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $mailbox = (SELECT id, account, uid_next FROM ONLY $p.mailbox);
    IF $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $account = (SELECT id, tenant, state, used_bytes, quota_bytes, quota_exceeded_at FROM ONLY $mailbox.account);
    IF $account.state != "active" { RETURN fn::error_result(IF $account.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    LET $content = (SELECT id, account, state, size, refs, protection FROM ONLY $p.content);
    IF $content == NONE OR $content.account != $account.id { RETURN fn::error_result("MAIL_CONTENT_NOT_FOUND", $p.language, { content: <string> $p.content }); };
    -- Un contenu stocké s'inscrit une fois ; ses copies passent par fn::mail_message_copy
    IF $content.state != "stored" OR $content.refs > 0 { RETURN fn::error_result("MAIL_CONTENT_STATE_INVALID", $p.language, { state: $content.state }); };
    -- Contenu lu par le serveur (niveau A) : enveloppe et structure exigées (décision M8)
    IF $content.protection = "platform" AND ($p.envelope IS NONE OR $p.structure IS NONE) {
        RETURN fn::error_result("MAIL_MESSAGE_MALFORMED", $p.language, { fields: { envelope: IF $p.envelope IS NONE { ["required"] } ELSE { [] }, structure: IF $p.structure IS NONE { ["required"] } ELSE { [] } } });
    };
    LET $settings = fn::mail_settings_effective({ tenant: $account.tenant });
    IF $content.size > $settings.max_message_bytes { RETURN fn::error_result("MAIL_MESSAGE_TOO_LARGE", $p.language, { size: $content.size, max_message_bytes: $settings.max_message_bytes }); };
    LET $flags = fn::mail_flags_apply({ seen: $p.seen, answered: $p.answered, flagged: $p.flagged, deleted: $p.deleted, draft: $p.draft, keywords: [] }, $p.keywords ?? [], [], NONE);
    IF array::len($flags.keywords) > $settings.max_keywords_per_message { RETURN fn::error_result("MAIL_KEYWORD_LIMIT", $p.language, { max_keywords_per_message: $settings.max_keywords_per_message }); };
    LET $quota = $account.quota_bytes ?? $settings.default_quota_bytes;
    IF $quota IS NOT NONE AND $account.used_bytes + $content.size > $quota {
        -- Premier refus depuis le dernier passage sous le quota : publie mail.quota.exceeded
        IF $account.quota_exceeded_at IS NONE { UPDATE $account.id SET quota_exceeded_at = time::now(); };
        RETURN fn::error_result("MAIL_QUOTA_EXCEEDED", $p.language, { quota_bytes: $quota, used_bytes: $account.used_bytes });
    };
    IF $mailbox.uid_next > 4294967295 { RETURN fn::error_result("MAIL_MAILBOX_UID_EXHAUSTED", $p.language, {}); };
    LET $thread = fn::mail_thread_assign({ account: $account.id, message_id: $p.message_id, in_reply_to: $p.in_reply_to, references: $p.references, base_subject: $p.base_subject, is_report: $p.is_report });
    LET $modseq = fn::mail_modseq_next($account.id);
    LET $created = (CREATE ONLY mail_message CONTENT {
        tenant: $account.tenant, account: $account.id, mailbox: $mailbox.id, content: $content.id,
        uid: $mailbox.uid_next, modseq: $modseq, create_modseq: $modseq, thread: $thread.thread, thread_orphan: $thread.orphan,
        received_at: $p.received_at, sent_at: $p.sent_at, size: $content.size,
        seen: $flags.seen, answered: $flags.answered, flagged: $flags.flagged, deleted: $flags.deleted, draft: $flags.draft, keywords: $flags.keywords,
        message_id: $p.message_id, base_subject: $p.base_subject, has_attachment: $p.has_attachment, envelope: $p.envelope, structure: $p.structure
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_message" }); };
    RETURN fn::result_ok(object::extend($created, { protection: $content.protection }));
} COMMENT "Inscrit un message ({ content (stocké, jamais inscrit), mailbox, received_at, sent_at, seen, answered, flagged, deleted, draft, keywords, message_id, in_reply_to, references, base_subject, is_report (avis de non-remise), envelope, structure, has_attachment }) : UID suivant du dossier, numéro de modification suivant du compte, fil (décision M7), compteurs et lecteurs du contenu ; enveloppe et structure exigées pour un contenu platform (MAIL_MESSAGE_MALFORMED) ; MAIL_MESSAGE_TOO_LARGE, MAIL_KEYWORD_LIMIT, MAIL_MAILBOX_UID_EXHAUSTED ; quota contrôlé : MAIL_QUOTA_EXCEEDED, et mail.quota.exceeded au premier refus. Droit : titulaire du compte, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_message_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_get($params: object) {
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
    LET $message = (SELECT *, content.protection AS protection, content.key_fingerprint AS key_fingerprint FROM ONLY $p.message);
    IF $message == NONE { RETURN fn::error_result("MAIL_MESSAGE_NOT_FOUND", $p.language, { message: <string> $p.message }); };
    RETURN fn::result_ok($message);
} COMMENT "Message ({ message }) : métadonnées, drapeaux, fil, enveloppe, structure, et protection du contenu (protection, key_fingerprint, décision M15). Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_message_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            before: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    received_at: { pipeline: [{ rule: "datetime" }], required: true },
                    id: { pipeline: [{ rule: "record", options: { expected_table: "mail_message" } }], required: true }
                },
                unknown_keys: "reject"
            } } }] },
            uid_min: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 4294967295 } }] },
            uid_max: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 4294967295 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 50 },
            fields: { pipeline: [{ rule: "enum", options: { allowed: ["summary", "full"], case_sensitive: true } }], default: "summary" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.before IS NOT NONE AND ($report.value.uid_min IS NOT NONE OR $report.value.uid_max IS NOT NONE)) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { { before: ["before_or_uid_range"] } } ELSE { $report.by_field } });
    };
    LET $p = $report.value;
    LET $mailbox = (SELECT id FROM ONLY $p.mailbox);
    IF $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $by_uid = $p.uid_min IS NOT NONE OR $p.uid_max IS NOT NONE;
    LET $rows = IF $by_uid {
        (SELECT *, content.protection AS protection FROM mail_message
            WHERE mailbox = $mailbox.id AND uid >= ($p.uid_min ?? 1) AND uid <= ($p.uid_max ?? 4294967295)
            ORDER BY uid LIMIT $p.limit + 1)
    } ELSE {
        -- Date décroissante, identifiant pour départager deux messages de même date
        (SELECT *, content.protection AS protection FROM mail_message
            WHERE mailbox = $mailbox.id AND ($p.before IS NONE OR received_at < $p.before.received_at OR (received_at = $p.before.received_at AND id < $p.before.id))
            ORDER BY received_at DESC, id DESC LIMIT $p.limit + 1)
    };
    LET $page = array::slice($rows, 0, $p.limit);
    LET $items = IF $p.fields = "full" { $page } ELSE { array::map($page, |$m| object::remove($m, ["envelope", "structure"])) };
    LET $last = array::last($page);
    LET $next = IF array::len($rows) <= $p.limit { NONE } ELSE IF $by_uid { { uid_min: $last.uid + 1 } } ELSE { { before: { received_at: $last.received_at, id: <string> $last.id } } };
    RETURN fn::result_ok({ items: $items, next: $next });
} COMMENT "Messages d'un dossier ({ mailbox, before ({ received_at, id } : curseur), ou uid_min / uid_max (plage d'UID), limit (50, 1 000 au plus), fields (summary : sans enveloppe ni structure ; full) }) : par date de réception décroissante (identifiant pour départager), ou par UID croissant ; jamais par décalage ; { items, next (curseur suivant, NONE à la fin) }, protection du contenu comprise. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_message_changes
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_changes($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }] },
            since: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5000 } }], default: 1000 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.account IS NONE) = ($report.value.mailbox IS NONE) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { { account: ["account_or_mailbox"] } } ELSE { $report.by_field } });
    };
    LET $p = $report.value;
    LET $mailbox = IF $p.mailbox IS NONE { NONE } ELSE { (SELECT id, account, highest_modseq FROM ONLY $p.mailbox) };
    IF $p.mailbox IS NOT NONE AND $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $account = (SELECT id, tenant, modseq, changes_floor FROM ONLY ($p.account ?? $mailbox.account));
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, {}); };
    IF !fn::mail_can({ action: "mailbox", tenant: $account.tenant, account: $account.id }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    -- Effacements plus anciens purgés : resynchronisation complète (IMAP) ou cannotCalculateChanges (JMAP)
    IF $p.since < $account.changes_floor { RETURN fn::error_result("MAIL_CHANGES_TOO_OLD", $p.language, { since: $p.since, floor: $account.changes_floor }); };
    LET $box_key = IF $mailbox IS NONE { NONE } ELSE { <string> $mailbox.id };
    LET $changed_rows = IF $mailbox IS NONE {
        (SELECT id, mailbox, uid, modseq, seen, answered, flagged, deleted, draft, keywords FROM mail_message WHERE account = $account.id AND modseq > $p.since ORDER BY modseq, id LIMIT $p.limit + 1)
    } ELSE {
        (SELECT id, mailbox, uid, modseq, seen, answered, flagged, deleted, draft, keywords FROM mail_message WHERE mailbox = $mailbox.id AND modseq > $p.since ORDER BY modseq, id LIMIT $p.limit + 1)
    };
    LET $removed_rows = IF $mailbox IS NONE {
        (SELECT id, kind, mailbox, uid, object, modseq FROM mail_tombstone WHERE account = $account.id AND modseq > $p.since ORDER BY modseq, id LIMIT $p.limit + 1)
    } ELSE {
        (SELECT id, kind, mailbox, uid, object, modseq FROM mail_tombstone WHERE mailbox = $box_key AND modseq > $p.since ORDER BY modseq, id LIMIT $p.limit + 1)
    };
    -- Numéros de modification des deux listes (déjà triées), triés ensemble pour placer la coupure
    LET $modseqs = array::sort::asc(array::concat($changed_rows.modseq, $removed_rows.modseq));
    -- Coupure entre deux numéros de modification : un numéro n'est jamais rendu à moitié ; un
    -- numéro plus grand que limit (lot d'une seule écriture) est rendu en entier
    LET $cut = IF array::len($modseqs) <= $p.limit { NONE } ELSE { $modseqs[$p.limit] };
    LET $whole = IF $cut IS NONE OR $modseqs[0] < $cut { NONE } ELSE {
        IF $mailbox IS NONE {
            { changed: (SELECT id, mailbox, uid, modseq, seen, answered, flagged, deleted, draft, keywords FROM mail_message WHERE account = $account.id AND modseq = $cut ORDER BY id),
              removed: (SELECT id, kind, mailbox, uid, object, modseq FROM mail_tombstone WHERE account = $account.id AND modseq = $cut ORDER BY id) }
        } ELSE {
            { changed: (SELECT id, mailbox, uid, modseq, seen, answered, flagged, deleted, draft, keywords FROM mail_message WHERE mailbox = $mailbox.id AND modseq = $cut ORDER BY id),
              removed: (SELECT id, kind, mailbox, uid, object, modseq FROM mail_tombstone WHERE mailbox = $box_key AND modseq = $cut ORDER BY id) }
        }
    };
    LET $changed = IF $whole IS NOT NONE { $whole.changed } ELSE IF $cut IS NONE { $changed_rows } ELSE { array::filter($changed_rows, |$row| $row.modseq < $cut) };
    LET $removed = IF $whole IS NOT NONE { $whole.removed } ELSE IF $cut IS NONE { $removed_rows } ELSE { array::filter($removed_rows, |$row| $row.modseq < $cut) };
    LET $highest = IF $whole IS NOT NONE { $cut } ELSE IF $cut IS NOT NONE { $cut - 1 } ELSE IF $mailbox IS NONE { $account.modseq } ELSE { $mailbox.highest_modseq };
    -- Numéro rendu en entier : d'autres changements le suivent-ils ?
    LET $beyond = IF $whole IS NONE { $cut IS NOT NONE } ELSE IF $mailbox IS NONE {
        array::len(SELECT VALUE id FROM mail_message WHERE account = $account.id AND modseq > $cut LIMIT 1) > 0
            OR array::len(SELECT VALUE id FROM mail_tombstone WHERE account = $account.id AND modseq > $cut LIMIT 1) > 0
    } ELSE {
        array::len(SELECT VALUE id FROM mail_message WHERE mailbox = $mailbox.id AND modseq > $cut LIMIT 1) > 0
            OR array::len(SELECT VALUE id FROM mail_tombstone WHERE mailbox = $box_key AND modseq > $cut LIMIT 1) > 0
    };
    RETURN fn::result_ok({
        changed: $changed,
        removed: array::map($removed, |$row| object::remove($row, "id")),
        highest_modseq: math::max([$highest, $p.since]),
        more: $beyond
    });
} COMMENT "Changements d'un compte ({ account }) ou d'un dossier ({ mailbox }) depuis un numéro de modification ({ since }, limit : 1 000, 5 000 au plus) : { changed : messages créés ou modifiés (id, mailbox, uid, modseq, drapeaux, keywords), removed : effacements (kind, mailbox, uid, object, modseq), highest_modseq : numéro jusqu'auquel la réponse est complète (since de l'appel suivant), more } ; un numéro n'est jamais coupé entre deux pages ; MAIL_CHANGES_TOO_OLD sous le plancher du compte (effacements purgés). Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_message_flags_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_flags_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            messages: fn::mail_messages_rule(),
            add: fn::mail_keywords_rule(),
            remove: fn::mail_keywords_rule(),
            replace: fn::mail_keywords_rule(),
            unchanged_since: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.replace IS NOT NONE AND ($report.value.add IS NOT NONE OR $report.value.remove IS NOT NONE))
        OR ($report.value.replace IS NONE AND $report.value.add IS NONE AND $report.value.remove IS NONE) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { { replace: ["replace_or_add_remove"] } } ELSE { $report.by_field } });
    };
    LET $p = $report.value;
    LET $loaded = fn::mail_messages_load($p.messages);
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, $loaded.details); };
    LET $settings = fn::mail_settings_effective({ tenant: $loaded.account.tenant });
    -- CONDSTORE (RFC 7162) : un message modifié depuis unchanged_since n'est pas touché
    LET $conflicts = array::filter($loaded.rows, |$m| $p.unchanged_since IS NOT NONE AND $m.modseq > $p.unchanged_since);
    LET $planned = array::map(array::filter($loaded.rows, |$m| $p.unchanged_since IS NONE OR $m.modseq <= $p.unchanged_since), |$m| {
        LET $flags = fn::mail_flags_apply($m, $p.add ?? [], $p.remove ?? [], $p.replace);
        RETURN object::extend($flags, { id: $m.id, uid: $m.uid, changed: $flags.seen != $m.seen OR $flags.answered != $m.answered OR $flags.flagged != $m.flagged OR $flags.deleted != $m.deleted OR $flags.draft != $m.draft OR $flags.keywords != $m.keywords });
    });
    IF array::any($planned, |$m| array::len($m.keywords) > $settings.max_keywords_per_message) {
        RETURN fn::error_result("MAIL_KEYWORD_LIMIT", $p.language, { max_keywords_per_message: $settings.max_keywords_per_message });
    };
    LET $changes = array::filter($planned, |$m| $m.changed);
    LET $modseq = fn::mail_modseq_next($loaded.account.id);
    LET $written = array::map($changes, |$m| (UPDATE ONLY $m.id SET seen = $m.seen, answered = $m.answered, flagged = $m.flagged, deleted = $m.deleted, draft = $m.draft, keywords = $m.keywords, modseq = $modseq RETURN VALUE id));
    IF array::any($written, |$w| $w IS NONE) { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_message" }); };
    RETURN fn::result_ok({
        updated: array::map($changes, |$m| { id: $m.id, uid: $m.uid, modseq: $modseq }),
        conflicts: array::map($conflicts, |$m| $m.id)
    });
} COMMENT "Change les drapeaux et mots-clés de messages d'un même compte ({ messages (500 au plus), add, remove, ou replace : $seen, $answered, $flagged, $deleted, $draft et mots-clés IMAP, mis en minuscules ; unchanged_since (CONDSTORE) }) : un numéro de modification pour l'appel, compteurs des dossiers ; un message inchangé n'est pas réécrit ; { updated : [{ id, uid, modseq }], conflicts : messages modifiés depuis unchanged_since } ; MAIL_KEYWORD_LIMIT. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_message_move
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_move($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            messages: fn::mail_messages_rule(),
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $loaded = fn::mail_messages_load($p.messages);
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, $loaded.details); };
    LET $target = (SELECT id, account, uid_next FROM ONLY $p.mailbox);
    IF $target == NONE OR $target.account != $loaded.account.id { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    -- Un message déjà dans le dossier cible reste inchangé (ni nouvel UID, ni numéro de modification)
    LET $rows = array::filter($loaded.rows, |$m| $m.mailbox != $target.id);
    LET $count = array::len($rows);
    IF $count = 0 { RETURN fn::result_ok({ moved: [] }); };
    IF $target.uid_next + $count - 1 > 4294967295 { RETURN fn::error_result("MAIL_MAILBOX_UID_EXHAUSTED", $p.language, {}); };
    LET $modseq = fn::mail_modseq_next($loaded.account.id);
    -- Même fiche (même identifiant), nouvel UID dans le dossier cible, dans l'ordre des UID sources
    LET $moved = array::map(<array> (0..$count), |$i| {
        LET $done = (UPDATE ONLY $rows[$i].id SET mailbox = $target.id, uid = $target.uid_next + $i, modseq = $modseq RETURN VALUE id);
        RETURN IF $done IS NONE { NONE } ELSE { { id: $rows[$i].id, from_uid: $rows[$i].uid, uid: $target.uid_next + $i, modseq: $modseq } };
    });
    IF array::any($moved, |$m| $m IS NONE) { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_message" }); };
    RETURN fn::result_ok({ moved: $moved });
} COMMENT "Déplace des messages d'un même compte ({ messages (500 au plus), mailbox }) : même fiche (même identifiant JMAP), nouvel UID dans le dossier cible, pierre tombale dans le dossier source, un numéro de modification pour l'appel ; un message déjà dans le dossier cible reste inchangé et n'est pas rendu ; { moved : [{ id, from_uid, uid, modseq }] } ; MAIL_MAILBOX_UID_EXHAUSTED. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_message_copy
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_copy($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            messages: fn::mail_messages_rule(),
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $loaded = fn::mail_messages_load($p.messages);
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, $loaded.details); };
    LET $target = (SELECT id, account, uid_next FROM ONLY $p.mailbox);
    IF $target == NONE OR $target.account != $loaded.account.id { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $count = array::len($loaded.rows);
    IF $target.uid_next + $count - 1 > 4294967295 { RETURN fn::error_result("MAIL_MAILBOX_UID_EXHAUSTED", $p.language, {}); };
    -- Une copie compte à nouveau dans le quota (contenu partagé, aucun octet recopié)
    LET $account = $loaded.account;
    LET $quota = $account.quota_bytes ?? fn::mail_settings_effective({ tenant: $account.tenant }).default_quota_bytes;
    LET $added = math::sum(array::map($loaded.rows, |$m| $m.size));
    IF $quota IS NOT NONE AND $account.used_bytes + $added > $quota {
        IF $account.quota_exceeded_at IS NONE { UPDATE $account.id SET quota_exceeded_at = time::now(); };
        RETURN fn::error_result("MAIL_QUOTA_EXCEEDED", $p.language, { quota_bytes: $quota, used_bytes: $account.used_bytes });
    };
    LET $modseq = fn::mail_modseq_next($account.id);
    LET $rows = $loaded.rows;
    LET $copied = array::map(<array> (0..$count), |$i| {
        LET $source = $rows[$i];
        LET $created = (CREATE ONLY mail_message CONTENT {
            tenant: $source.tenant, account: $source.account, mailbox: $target.id, content: $source.content,
            uid: $target.uid_next + $i, modseq: $modseq, create_modseq: $modseq, thread: $source.thread, thread_orphan: $source.thread_orphan,
            received_at: $source.received_at, sent_at: $source.sent_at, size: $source.size,
            seen: $source.seen, answered: $source.answered, flagged: $source.flagged, deleted: $source.deleted, draft: $source.draft, keywords: $source.keywords,
            message_id: $source.message_id, base_subject: $source.base_subject, has_attachment: $source.has_attachment, envelope: $source.envelope, structure: $source.structure
        });
        RETURN IF $created == NONE { NONE } ELSE { { source: $source.id, id: $created.id, uid: $created.uid } };
    });
    IF array::any($copied, |$c| $c IS NONE) { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_message" }); };
    RETURN fn::result_ok({ copied: $copied });
} COMMENT "Copie des messages d'un même compte ({ messages (500 au plus), mailbox }) : nouvelles fiches sur le même contenu (aucun octet recopié, lecteurs du contenu comptés), même fil, drapeaux et mots-clés gardés, nouveaux UID, un numéro de modification pour l'appel ; quota compté à nouveau (MAIL_QUOTA_EXCEEDED) ; { copied : [{ source, id, uid }] }. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_message_expunge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_message_expunge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
            messages: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 500 } }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "mail_message" } }] } }, { rule: "array_unique" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $mailbox = (SELECT id, account FROM ONLY $p.mailbox);
    IF $mailbox == NONE { RETURN fn::error_result("MAIL_MAILBOX_NOT_FOUND", $p.language, { mailbox: <string> $p.mailbox }); };
    LET $account = (SELECT id, state, modseq FROM ONLY $mailbox.account);
    IF $account.state != "active" { RETURN fn::error_result(IF $account.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    -- Messages nommés (effacés, \Deleted ou non), sinon les \Deleted du dossier, 500 par appel
    LET $candidates = IF $p.messages IS NONE {
        (SELECT id, uid FROM mail_message WHERE mailbox = $mailbox.id AND deleted = true ORDER BY uid LIMIT 501)
    } ELSE {
        (SELECT id, uid FROM $p.messages WHERE mailbox = $mailbox.id ORDER BY uid)
    };
    IF $p.messages IS NOT NONE AND array::len($candidates) != array::len($p.messages) {
        RETURN fn::error_result("MAIL_MESSAGE_NOT_FOUND", $p.language, { messages: array::map(array::complement($p.messages, $candidates.id), |$m| <string> $m) });
    };
    LET $targets = array::slice($candidates, 0, 500);
    LET $ids = $targets.id;
    LET $deleted = IF array::len($ids) = 0 { [] } ELSE { (DELETE $ids RETURN BEFORE) };
    IF array::len($deleted) != array::len($ids) { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_message" }); };
    -- Numéros de modification des effacements, posés par les pierres tombales
    LET $keys = array::map($ids, |$id| <string> $id);
    LET $tombs = (SELECT object, uid, modseq FROM mail_tombstone WHERE account = $account.id AND modseq > $account.modseq AND kind = "message" AND object IN $keys ORDER BY modseq);
    RETURN fn::result_ok({
        expunged: array::map($tombs, |$t| { id: type::record($t.object), uid: $t.uid, modseq: $t.modseq }),
        more: array::len($candidates) > 500
    });
} COMMENT "Efface définitivement des messages d'un dossier ({ mailbox, messages : ceux-là ; sinon les messages \\Deleted, 500 par appel }) : pierre tombale et numéro de modification par message, compteurs, lecteurs des contenus (un contenu sans lecteur est libéré, puis retiré avec son fichier par la maintenance) ; { expunged : [{ id, uid, modseq }], more }. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_thread_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_thread_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            thread: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
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
    LET $messages = (SELECT VALUE id FROM mail_message WHERE account = $account.id AND thread = <string> $p.thread ORDER BY received_at, id);
    IF array::len($messages) = 0 { RETURN fn::error_result("MAIL_MESSAGE_NOT_FOUND", $p.language, {}); };
    RETURN fn::result_ok({ messages: $messages });
} COMMENT "Messages d'un fil ({ thread, account (absent : celui de la session) }), par date de réception puis identifiant ; { messages } ; MAIL_MESSAGE_NOT_FOUND si le fil n'a aucun message visible. Droit : titulaire du compte";

-- ----------------------------------------------------------------------------
-- Règles d'entrée et lecture de lots (internes)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_keywords_rule() -> object {
    RETURN { pipeline: [
        { rule: "array_length", options: { max_length: 1000 } },
        { rule: "each", options: { pipeline: [
            { rule: "required_string", options: { min_length: 1, max_length: 128 } },
            -- atome IMAP (RFC 9051) : ASCII visible sans ( ) { % * " \ ]
            { rule: "regex", options: { pattern: "^[\\x21\\x23\\x24\\x26\\x27\\x2B-\\x5B\\x5E-\\x7A\\x7C-\\x7E]+$" } }
        ] } }
    ] };
} COMMENT "Interne : règle d'entrée d'une liste de drapeaux et mots-clés (1 000 au plus, atomes IMAP de 128 caractères au plus) pour fn::validation_object_execute ; la casse est ramenée aux minuscules par fn::mail_flags_apply";

DEFINE FUNCTION OVERWRITE fn::mail_messages_rule() -> object {
    RETURN { pipeline: [
        { rule: "array_length", options: { min_length: 1, max_length: 500 } },
        { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "mail_message" } }] } },
        { rule: "array_unique" }
    ], required: true };
} COMMENT "Interne : règle d'entrée d'un lot de messages (1 à 500 identifiants distincts) pour fn::validation_object_execute";

DEFINE FUNCTION OVERWRITE fn::mail_flags_apply($message: object, $add: array<string>, $remove: array<string>, $replace: option<array<string>>) -> object {
    LET $system = ["$seen", "$answered", "$flagged", "$deleted", "$draft"];
    LET $low = |$list| array::distinct(array::map($list, |$k| fn::sanitize_lowercase($k)));
    LET $plus = $low($add);
    LET $minus = $low($remove);
    LET $exact = IF $replace IS NONE { NONE } ELSE { $low($replace) };
    LET $flag = |$name, $current| IF $exact IS NOT NONE { $name IN $exact } ELSE IF $name IN $minus { false } ELSE IF $name IN $plus { true } ELSE { $current };
    LET $base = IF $exact IS NOT NONE { array::complement($exact, $system) } ELSE { array::complement(array::union($message.keywords ?? [], array::complement($plus, $system)), $minus) };
    RETURN {
        seen: $flag("$seen", $message.seen), answered: $flag("$answered", $message.answered), flagged: $flag("$flagged", $message.flagged),
        deleted: $flag("$deleted", $message.deleted), draft: $flag("$draft", $message.draft),
        keywords: array::sort::asc(array::distinct($base))
    };
} COMMENT "Interne : drapeaux système et mots-clés d'un message ($message : seen, answered, flagged, deleted, draft, keywords) après ajout ($add), retrait ($remove) ou remplacement ($replace, NONE : aucun) : noms en minuscules, $seen, $answered, $flagged, $deleted, $draft vers les booléens, autres mots-clés triés sans doublon (modèle de Mox)";

DEFINE FUNCTION OVERWRITE fn::mail_messages_load($ids: array) -> object {
    -- Ordre des UID (dans chaque dossier) : un déplacement ou une copie garde l'ordre des sources
    LET $rows = (SELECT * FROM $ids ORDER BY mailbox, uid);
    IF array::len($rows) != array::len($ids) {
        RETURN { code: "MAIL_MESSAGE_NOT_FOUND", details: { messages: array::map(array::complement($ids, $rows.id), |$m| <string> $m) } };
    };
    LET $accounts = array::distinct($rows.account);
    IF array::len($accounts) != 1 { RETURN { code: "MAIL_INVALID_PARAMETERS", details: { fields: { messages: ["one_account"] } } }; };
    LET $account = (SELECT id, tenant, state, used_bytes, quota_bytes, quota_exceeded_at FROM ONLY $accounts[0]);
    IF $account.state != "active" { RETURN { code: IF $account.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, details: {} }; };
    RETURN { code: NONE, rows: $rows, account: $account };
} COMMENT "Interne : messages d'un lot ($ids) lus sous les droits de l'appelant : { code: NONE, rows, account }, ou { code, details } : MAIL_MESSAGE_NOT_FOUND (identifiants absents ou invisibles), MAIL_INVALID_PARAMETERS (plusieurs comptes), MAIL_ACCOUNT_DISABLED, MAIL_ACCOUNT_DELETING";

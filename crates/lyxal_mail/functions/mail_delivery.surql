-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : réception (résolution des destinataires, remise groupée et idempotente)
-- MODULE    : lyxal_mail
-- ============================================================================
-- Chemin d'une remise SMTP (plan du lot 5, §3, §9, §10.3), sous la session système de l'hôte ou
-- un compte de service (mail.worker) : fn::mail_recipient_resolve à chaque RCPT TO ; puis, par
-- compte destinataire, fn::mail_delivery_begin (compte, taille, quota, idempotence : un appel),
-- écriture chiffrée du fichier par lyxal_storage, et fn::mail_delivery_commit (lien du fichier,
-- inscription, fiche d'idempotence et compteurs de 1 à 32 messages du compte : une transaction).
-- Le service de remise ordonne les remises d'un même compte dans le nœud (décision S11) : le
-- compteur de modifications reste par compte (décision M6), sans conflit entre remises d'un nœud.
-- Contrôle des paramètres (décision S12) : le moteur de lyxal_core valide les champs scalaires,
-- la forme des listes et la taille sérialisée de l'enveloppe et de la structure ; leur forme
-- détaillée est garantie par le schéma de mail_message. fn::mail_message_create, appelable par un
-- titulaire, garde la validation complète.

-- ----------------------------------------------------------------------------
-- fn::mail_recipient_accounts (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_recipient_accounts($targets: array<record<mail_account>>, $default_quota: option<int>) -> array {
    RETURN (SELECT id AS account, state,
        (quota_bytes ?? $default_quota) IS NOT NONE AND used_bytes >= (quota_bytes ?? $default_quota) AS quota_full
        FROM $targets ORDER BY account);
} COMMENT "Interne : comptes d'une adresse résolue ($targets : le compte d'une adresse, ou les comptes d'un alias ; $default_quota : quota par défaut de l'organisation), triés par identifiant : [{ account, state, quota_full (quota du compte, sinon de l'organisation, atteint) }] ; un compte absent n'est pas rendu";

-- ----------------------------------------------------------------------------
-- fn::mail_recipient_resolve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_recipient_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            address: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 254 } }, { rule: "ascii", options: { trim_value: true, allow_blank: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { address: { pipeline: [{ rule: "trim" }, { rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    -- <postmaster> sans domaine (RFC 5321 §4.5.1) : adresse inscrite du réglage de l'installation
    LET $bare = $p.address = "postmaster";
    LET $address = IF $bare { (SELECT VALUE postmaster FROM ONLY mail_settings WHERE scope_key = "installation" LIMIT 1) } ELSE { $p.address };
    LET $parts = string::split($address ?? "", "@");
    IF array::len($parts) < 2 { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    LET $local = array::join(array::slice($parts, 0, array::len($parts) - 1), "@");
    -- Aucun relais : seul un domaine de courrier actif de l'installation reçoit (adresse littérale comprise)
    LET $domain = (SELECT id, tenant, name, state, subaddress_separator, catch_all, postmaster FROM ONLY mail_domain WHERE name = array::last($parts) LIMIT 1);
    IF $domain == NONE OR $domain.state != "active" { RETURN fn::error_result(IF $bare { "MAIL_RECIPIENT_UNKNOWN" } ELSE { "MAIL_RELAY_DENIED" }, $p.language, {}); };
    IF !fn::validation_email($address, 254).valid { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    -- Adresse exacte, sinon sans sa sous-adresse (jean+factures → jean)
    LET $exact = (SELECT address, kind, account, targets, state FROM ONLY mail_address WHERE address = $address LIMIT 1);
    LET $plain = IF $domain.subaddress_separator IS NOT NONE AND string::contains($local, $domain.subaddress_separator) { string::split($local, $domain.subaddress_separator)[0] } ELSE { $local };
    LET $row = $exact ?? (IF $plain = $local { NONE } ELSE { (SELECT address, kind, account, targets, state FROM ONLY mail_address WHERE address = string::concat($plain, "@", $domain.name) LIMIT 1) });
    -- Une adresse inscrite mais désactivée n'est jamais rattrapée par l'attrape-tout
    IF $row IS NOT NONE AND $row.state != "active" { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    -- Sans adresse inscrite : compte postmaster du domaine, sinon attrape-tout (aucun par défaut)
    LET $fallback = IF $row IS NOT NONE { NONE } ELSE IF $plain = "postmaster" AND $domain.postmaster IS NOT NONE { $domain.postmaster } ELSE { $domain.catch_all };
    IF $row IS NONE AND $fallback IS NONE { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    LET $wanted = IF $row IS NONE { [$fallback] } ELSE IF $row.kind = "account" { [$row.account] } ELSE { $row.targets };
    LET $settings = fn::mail_settings_effective({ tenant: $domain.tenant });
    -- Comptes actifs seulement (alias développé) ; aucun : désactivés ou en suppression
    LET $found = fn::mail_recipient_accounts($wanted, $settings.default_quota_bytes);
    LET $accounts = array::filter($found, |$a| $a.state = "active");
    IF array::len($accounts) = 0 { RETURN fn::error_result(IF array::len($found) = 0 { "MAIL_RECIPIENT_UNKNOWN" } ELSE { "MAIL_RECIPIENT_DISABLED" }, $p.language, {}); };
    RETURN fn::result_ok({
        address: IF $row IS NONE { $address } ELSE { $row.address },
        domain: $domain.name, tenant: $domain.tenant, max_message_bytes: $settings.max_message_bytes,
        accounts: array::map($accounts, |$a| { account: $a.account, quota_full: $a.quota_full })
    });
} COMMENT "Résout un destinataire ({ address : ASCII, domaine en forme ASCII }) : casse ignorée ; domaine de courrier actif de l'installation, sinon MAIL_RELAY_DENIED (aucun relais) ; adresse exacte, sinon sans sa sous-adresse (jean+factures → jean) si le domaine en a ; sans adresse inscrite : compte postmaster du domaine pour postmaster@<domaine>, sinon compte attrape-tout du domaine (aucun par défaut) ; postmaster sans domaine : adresse du réglage de l'installation ; alias développé, comptes actifs seulement ; { address (adresse inscrite qui a servi, ou adresse demandée pour un attrape-tout), domain, tenant, max_message_bytes (taille maximale de l'organisation), accounts : [{ account, quota_full }] } ; MAIL_RECIPIENT_UNKNOWN (adresse absente ou désactivée), MAIL_RECIPIENT_DISABLED (comptes désactivés ou en suppression), sans écho de l'adresse. Droit : session système, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_delivery_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_delivery_begin($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }], required: true },
            size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5368709120 } }], required: true },
            delivery_key: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $account = (SELECT id, tenant, state, used_bytes, quota_bytes, quota_exceeded_at FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    -- Idempotence (décision S8) : message déjà remis à ce compte, rien à réserver
    LET $known = (SELECT message, expires_at FROM ONLY fn::mail_delivery_key($account.id, $p.delivery_key));
    IF $known IS NOT NONE AND $known.expires_at > time::now() { RETURN fn::result_ok({ duplicate: true, message: $known.message }); };
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
        state: "pending", size: $p.size, protection: "platform", expires_at: time::now() + 1h
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_content" }); };
    RETURN fn::result_ok({ duplicate: false, content: $created.id, storage_key: $created.key });
} COMMENT "Ouvre la remise d'un message à un compte ({ account, size (octets en clair), delivery_key (empreinte BLAKE3 en hexadécimal, 64 caractères : adresse inscrite du destinataire, expéditeur de l'enveloppe, octets reçus) }) : message déjà remis à ce compte dans les 7 jours : { duplicate: true, message } (rien n'est réservé) ; sinon compte actif, taille (MAIL_MESSAGE_TOO_LARGE) et quota (MAIL_QUOTA_EXCEEDED, mail.quota.exceeded au premier refus) contrôlés, contenu pending de protection platform réservé pour 1 h : { duplicate: false, content, storage_key (clé du fichier à écrire dans le bucket chiffré lyxal-mail de l'organisation) }. Droit : session système, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_delivery_commit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_delivery_commit($params: object) {
    LET $text = |$max| { pipeline: [{ rule: "optional_string", options: { max_length: $max } }] };
    LET $ids = |$max| { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: $max } }], default: [] };
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }], required: true },
            items: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 32 } }, { rule: "each", options: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    content: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true },
                    object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
                    role: { pipeline: [{ rule: "enum", options: { allowed: ["inbox", "junk"], case_sensitive: true } }], default: "inbox" },
                    received_at: { pipeline: [{ rule: "datetime", options: { min_value: d"1970-01-01T00:00:00Z" } }], required: true },
                    delivery_key: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
                    message_id: $text(2048),
                    in_reply_to: $ids(100),
                    references: $ids(1000),
                    base_subject: $text(16384),
                    is_report: { pipeline: [{ rule: "boolean" }], default: false },
                    envelope: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 262144 } }], required: true },
                    structure: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 1048576 } }], required: true },
                    has_attachment: { pipeline: [{ rule: "boolean" }], default: false },
                    reception: fn::mail_reception_rule()
                },
                unknown_keys: "reject"
            } } }] } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        LET $language = IF type::is_string($params.language) { $params.language } ELSE { NONE };
        RETURN IF ($report.by_field.items ?? []) CONTAINS "CORE_VALIDATION_TOO_LONG" {
            fn::error_result("MAIL_DELIVERY_BATCH_TOO_LARGE", $language, { max_items: 32 })
        } ELSE {
            fn::error_result("MAIL_INVALID_PARAMETERS", $language, { fields: $report.by_field })
        };
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $account = (SELECT id, tenant, state FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    IF $account.state != "active" { RETURN fn::error_result(IF $account.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, {}); };
    LET $settings = fn::mail_settings_effective({ tenant: $account.tenant });
    -- Dans l'ordre du lot, chaque élément lit le compte et le dossier tels que le précédent les a laissés
    RETURN fn::result_ok({ items: array::map($p.items, |$item| fn::mail_delivery_item($account.id, $item, $settings, $p.language)) });
} COMMENT "Inscrit un lot de messages remis à un compte ({ account, items : 1 à 32 × { content (réservé par fn::mail_delivery_begin), object (fichier écrit par lyxal_storage), role (inbox par défaut, ou junk ; dossier absent : boîte de réception), received_at, delivery_key, message_id, in_reply_to, references, base_subject, is_report, envelope, structure, has_attachment, reception ({ spf, dkim, dmarc, iprev, antivirus, spam, tls }) } }) en une transaction : pour chaque élément, lien du contenu à son fichier (bucket chiffré lyxal-mail de l'organisation, clé et taille du contenu), inscription d'origine delivery (UID suivant du dossier, numéro de modification suivant du compte, fil, compteurs), fiche d'idempotence de 7 jours ; publie mail.message.received par message inscrit ; { items : dans l'ordre du lot, { message, uid, mailbox, duplicate } (duplicate : message déjà remis, rien n'est inscrit), ou { error } (erreur de l'élément, qui n'annule pas les autres : MAIL_CONTENT_NOT_FOUND, MAIL_CONTENT_STATE_INVALID, MAIL_CONTENT_UNAVAILABLE, MAIL_MESSAGE_TOO_LARGE, MAIL_QUOTA_EXCEEDED, MAIL_MAILBOX_NOT_FOUND, MAIL_MAILBOX_UID_EXHAUSTED, MAIL_WRITE_FORBIDDEN) } ; plus de 32 éléments : MAIL_DELIVERY_BATCH_TOO_LARGE ; champs scalaires et tailles contrôlés par lyxal_core, forme de l'enveloppe et de la structure par le schéma de mail_message (une valeur hors schéma annule le lot). Droit : session système, ou compte de service qui lit les fichiers";

-- ----------------------------------------------------------------------------
-- fn::mail_delivery_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_delivery_purge($params: object) {
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
    LET $due = (SELECT VALUE id FROM mail_delivery WHERE expires_at < time::now() ORDER BY expires_at LIMIT $p.limit);
    IF array::len($due) = 0 { RETURN fn::result_ok({ removed: 0 }); };
    LET $removed = (DELETE $due RETURN BEFORE);
    IF array::len($removed) = 0 { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_delivery" }); };
    RETURN fn::result_ok({ removed: array::len($removed) });
} COMMENT "Maintenance ({ limit : 1 000 }) : fiches d'idempotence des remises échues (7 jours) retirées ; { removed }. Droit : session système, compte de service";

-- ----------------------------------------------------------------------------
-- Remise d'un élément, clé d'idempotence, règle d'entrée (internes)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_delivery_key($account: record<mail_account>, $delivery_key: string) -> record<mail_delivery> {
    RETURN type::record("mail_delivery", string::concat(<string> record::id($account), "_", $delivery_key));
} COMMENT "Interne : identifiant de la fiche d'idempotence d'une remise (mail_delivery:⟨<clé du compte>_<empreinte>⟩)";

DEFINE FUNCTION OVERWRITE fn::mail_reception_rule() -> object {
    LET $word = |$allowed| { pipeline: [{ rule: "enum", options: { allowed: $allowed, case_sensitive: true } }], required: true };
    RETURN { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
        fields: {
            spf: $word(["none", "neutral", "pass", "fail", "softfail", "temperror", "permerror"]),
            dkim: $word(["none", "pass", "fail", "neutral", "policy", "temperror", "permerror"]),
            dmarc: $word(["none", "pass", "fail", "temperror", "permerror"]),
            iprev: $word(["pass", "fail", "temperror", "permerror"]),
            antivirus: $word(["clean", "not_scanned"]),
            spam: $word(["none"]),
            tls: { pipeline: [{ rule: "boolean" }], required: true }
        },
        unknown_keys: "reject"
    } } }], required: true };
} COMMENT "Interne : règle d'entrée des résultats de la réception d'un message ({ spf, dkim, dmarc, iprev : mots de résultat de la RFC 8601 ; antivirus : clean ou not_scanned ; spam : none (lot 11) ; tls }), tous exigés, pour fn::validation_object_execute";

DEFINE FUNCTION OVERWRITE fn::mail_delivery_item($account: record<mail_account>, $item: object, $settings: object, $language: string) -> object {
    LET $fail = |$code, $details| { error: fn::error_result($code, $language, $details).error };
    -- Idempotence : déjà remis (nouvel essai de l'expéditeur, ou même message deux fois dans le lot)
    LET $delivery = fn::mail_delivery_key($account, $item.delivery_key);
    LET $known = (SELECT message, expires_at FROM ONLY $delivery);
    IF $known IS NOT NONE AND $known.expires_at > time::now() {
        LET $kept = (SELECT uid, mailbox FROM ONLY $known.message);
        RETURN { message: $known.message, uid: $kept.uid, mailbox: $kept.mailbox, duplicate: true };
    };
    IF $known IS NOT NONE { DELETE $delivery; };
    -- Contenu réservé et fichier écrit : disponible, dans le bucket chiffré lyxal-mail de
    -- l'organisation, à la clé du contenu, de même taille en clair (comme fn::mail_content_attach)
    LET $content = (SELECT id, tenant, account, key, size, state, protection, expires_at FROM ONLY $item.content);
    IF $content == NONE OR $content.account != $account { RETURN $fail("MAIL_CONTENT_NOT_FOUND", { content: <string> $item.content }); };
    IF $content.state != "pending" OR $content.expires_at <= time::now() { RETURN $fail("MAIL_CONTENT_STATE_INVALID", { state: $content.state, expected: "pending" }); };
    LET $object = fn::storage_object_get({ object: <string> $item.object });
    IF !$object.ok { RETURN $fail("MAIL_CONTENT_UNAVAILABLE", { storage: $object.error.code }); };
    LET $bucket = fn::storage_bucket_get({ bucket: <string> $object.data.bucket });
    IF !$bucket.ok { RETURN $fail("MAIL_CONTENT_UNAVAILABLE", { storage: $bucket.error.code }); };
    IF $object.data.state != "available" OR $object.data.key != $content.key OR $object.data.size != $content.size
        OR $bucket.data.name != "lyxal-mail" OR $bucket.data.tenant != $content.tenant OR !$bucket.data.encrypted {
        RETURN $fail("MAIL_CONTENT_STATE_INVALID", { object: <string> $item.object });
    };
    -- Compte et dossier relus : l'élément précédent du lot les a fait avancer
    LET $owner = (SELECT tenant, identity, used_bytes, quota_bytes, quota_exceeded_at, modseq FROM ONLY $account);
    LET $wanted = (SELECT id, uid_next FROM ONLY mail_mailbox WHERE account = $account AND role = $item.role LIMIT 1);
    -- Dossier « Junk » supprimé par son titulaire : boîte de réception (jamais supprimée)
    LET $mailbox = $wanted ?? (SELECT id, uid_next FROM ONLY mail_mailbox WHERE account = $account AND role = "inbox" LIMIT 1);
    IF $mailbox == NONE { RETURN $fail("MAIL_MAILBOX_NOT_FOUND", {}); };
    IF $content.size > $settings.max_message_bytes { RETURN $fail("MAIL_MESSAGE_TOO_LARGE", { size: $content.size, max_message_bytes: $settings.max_message_bytes }); };
    LET $quota = $owner.quota_bytes ?? $settings.default_quota_bytes;
    IF $quota IS NOT NONE AND $owner.used_bytes + $content.size > $quota {
        IF $owner.quota_exceeded_at IS NONE { UPDATE $account SET quota_exceeded_at = time::now(); };
        RETURN $fail("MAIL_QUOTA_EXCEEDED", { quota_bytes: $quota, used_bytes: $owner.used_bytes });
    };
    IF $mailbox.uid_next > 4294967295 { RETURN $fail("MAIL_MAILBOX_UID_EXHAUSTED", {}); };
    LET $stored = (UPDATE ONLY $content.id SET state = "stored", object = $object.data.id);
    IF $stored == NONE { RETURN $fail("MAIL_WRITE_FORBIDDEN", { table: "mail_content" }); };
    LET $thread = fn::mail_thread_assign({ account: $account, message_id: $item.message_id, in_reply_to: $item.in_reply_to, references: $item.references, base_subject: $item.base_subject, is_report: $item.is_report });
    LET $modseq = $owner.modseq + 1;
    LET $created = (CREATE ONLY fn::mail_message_key($mailbox.id, $mailbox.uid_next) CONTENT {
        tenant: $owner.tenant, account: $account, owner: $owner.identity, mailbox: $mailbox.id, content: $content.id, protection: $content.protection,
        origin: "delivery", reception: $item.reception, email_id: <string> rand::uuid::v7(),
        uid: $mailbox.uid_next, modseq: $modseq, create_modseq: $modseq, thread: $thread.thread, thread_orphan: $thread.orphan,
        received_at: $item.received_at, sent_at: $item.envelope.date, size: $content.size,
        message_id: $item.message_id, base_subject: $item.base_subject, has_attachment: $item.has_attachment, envelope: $item.envelope, structure: $item.structure
    });
    -- Inscription filtrée : le contenu lié reste sans lecteur, retiré avec son fichier par la maintenance
    IF $created == NONE { RETURN $fail("MAIL_WRITE_FORBIDDEN", { table: "mail_message" }); };
    -- Sans fiche d'idempotence, un nouvel essai ferait un doublon : tout le lot est annulé
    LET $recorded = (CREATE ONLY $delivery CONTENT { tenant: $owner.tenant, account: $account, message: $created.id, expires_at: time::now() + 7d });
    IF $recorded == NONE { THROW "MAIL_WRITE_FORBIDDEN"; };
    RETURN { message: $created.id, uid: $created.uid, mailbox: $mailbox.id, duplicate: false };
} COMMENT "Interne : un élément de fn::mail_delivery_commit ($account : compte actif ; $item : élément validé ; $settings : réglages effectifs de l'organisation). Tous les contrôles précèdent les écritures : une erreur d'élément est rendue ({ error }) sans rien écrire ni annuler les autres ; sinon contenu lié à son fichier, message inscrit (origine delivery, non lu, date d'envoi de l'enveloppe) et fiche d'idempotence : { message, uid, mailbox, duplicate: false } ; message déjà remis : { message, uid, mailbox (NONE si le message n'existe plus), duplicate: true }";

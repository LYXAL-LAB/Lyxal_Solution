-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : réglages et domaines de courrier
-- MODULE    : lyxal_mail
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::mail_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_settings_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "settings", tenant: $p.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok({
        own: (SELECT * FROM ONLY mail_settings WHERE scope_key = $scope LIMIT 1),
        effective: fn::mail_settings_effective({ tenant: $p.tenant })
    });
} COMMENT "Réglages d'une portée ({ tenant }, absent : installation) : { own, effective } (organisation, sinon installation, sinon valeurs par défaut). Droit : gestion, ou lecture des limites par un membre qui a une boîte";

-- ----------------------------------------------------------------------------
-- fn::mail_settings_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_settings_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            max_message_bytes: { pipeline: [{ rule: "integer", options: { min_value: 1024, max_value: 5368709120 } }] },
            default_quota_bytes: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
            tombstone_retention_days: { pipeline: [{ rule: "integer", options: { min_value: 7, max_value: 365 } }] },
            max_mailboxes_per_account: { pipeline: [{ rule: "integer", options: { min_value: 6, max_value: 10000 } }] },
            max_addresses_per_account: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }] },
            max_keywords_per_message: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }] },
            postmaster: { pipeline: [{ rule: "email", options: { max_length: 254 } }, { rule: "ascii", options: { trim_value: true, allow_blank: false } }] },
            send_recipients_per_message: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }] },
            send_messages_per_day: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000000 } }] },
            send_recipients_per_day: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000000 } }] },
            module_messages_per_hour: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000000 } }] },
            forward_messages_per_day: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 10000000 } }] },
            retry_intervals: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 16 } }, { rule: "each", options: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1440 } }] } }] },
            retry_jitter_percent: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 50 } }] },
            delay_notice_hours: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 72 } }] },
            expire_hours: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 720 } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["max_message_bytes", "default_quota_bytes", "tombstone_retention_days", "max_mailboxes_per_account", "max_addresses_per_account", "max_keywords_per_message", "postmaster", "send_recipients_per_message", "send_messages_per_day", "send_recipients_per_day", "module_messages_per_hour", "forward_messages_per_day", "retry_intervals", "retry_jitter_percent", "delay_notice_hours", "expire_hours"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    -- Le destinataire postmaster sans domaine et les réglages de la file sont de l'installation seulement
    LET $installation_only = ["postmaster", "retry_intervals", "retry_jitter_percent", "delay_notice_hours", "expire_hours"];
    LET $misplaced = IF $report.valid AND $report.value.tenant IS NOT NONE { array::filter($installation_only, |$f| $report.value[$f] IS NOT NONE) } ELSE { [] };
    IF !$report.valid OR array::len($misplaced) > 0 {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { object::from_entries(array::map($misplaced, |$f| [$f, ["installation_only"]])) } ELSE { $report.by_field } });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { postmaster: { pipeline: [{ rule: "trim" }, { rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::mail_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $fields = ["max_message_bytes", "default_quota_bytes", "tombstone_retention_days", "max_mailboxes_per_account", "max_addresses_per_account", "max_keywords_per_message", "postmaster",
        "send_recipients_per_message", "send_messages_per_day", "send_recipients_per_day", "module_messages_per_hour", "forward_messages_per_day",
        "retry_intervals", "retry_jitter_percent", "delay_notice_hours", "expire_hours"];
    -- Champ fourni : remplacé ; champ dans clear : effacé ; sinon conservé
    LET $changes = object::from_entries(array::filter(
        array::map($fields, |$f| [$f, IF $f IN $p.clear { NONE } ELSE { $p[$f] }]),
        |$e| $e[1] IS NOT NONE OR $e[0] IN $p.clear
    ));
    LET $existing = (SELECT VALUE id FROM ONLY mail_settings WHERE scope_key = $scope LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("mail_settings", $scope) CONTENT object::extend($changes, { tenant: $p.tenant }))
    } ELSE {
        (UPDATE ONLY $existing MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_settings" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Enregistre les réglages d'une portée ({ tenant, max_message_bytes, default_quota_bytes, tombstone_retention_days, max_mailboxes_per_account, max_addresses_per_account, max_keywords_per_message, postmaster (installation seulement : adresse inscrite qui reçoit le destinataire postmaster écrit sans domaine, rangée en minuscules), limites d'envoi (send_recipients_per_message, send_messages_per_day, send_recipients_per_day, module_messages_per_hour, forward_messages_per_day : celles d'une organisation sont plafonnées par celles de l'installation), file d'envoi (installation seulement : retry_intervals, retry_jitter_percent, delay_notice_hours, expire_hours), clear }) : un champ fourni est remplacé, un champ nommé dans clear est effacé, les autres sont conservés. Droit : gestion (mail.domain.manage ; mail.installation.manage sans tenant)";

-- ----------------------------------------------------------------------------
-- fn::mail_domain_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_domain_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            auth_domain: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization_domain" } }], required: true },
            subaddress_separator: { pipeline: [{ rule: "enum", options: { allowed: ["+", "none"], case_sensitive: true } }], default: "+" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Domaine de lyxal_auth lu par son contrat public, sous les droits de l'appelant : lisible par
    -- l'administrateur de son organisation, sinon introuvable
    LET $found = fn::auth_organization_domain_get({ domain: <string> $p.auth_domain, language: $p.language });
    IF !$found.ok { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { auth_domain: <string> $p.auth_domain }); };
    LET $source = $found.data;
    IF !fn::mail_can({ action: "manage", tenant: $source.organization }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $source.state != "verified" { RETURN fn::error_result("MAIL_DOMAIN_NOT_VERIFIED", $p.language, { auth_domain: <string> $source.id }); };
    -- Décision M10 : forme ASCII seulement (aucune conversion IDNA dans lyxal_core)
    IF !fn::validation_ascii($source.domain, false, false).valid OR !fn::validation_domain($source.domain, true).valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { auth_domain: ["ascii_domain_required"] } });
    };
    IF array::len(SELECT VALUE id FROM mail_domain WHERE name = $source.domain LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_DOMAIN_EXISTS", $p.language, { auth_domain: <string> $source.id });
    };
    LET $created = (CREATE ONLY mail_domain CONTENT {
        tenant: $source.organization, auth_domain: $source.id, name: $source.domain,
        subaddress_separator: IF $p.subaddress_separator = "none" { NONE } ELSE { $p.subaddress_separator }
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_domain" }); };
    RETURN fn::result_ok($created);
} COMMENT "Déclare un domaine de courrier ({ auth_domain, subaddress_separator (+ par défaut, ou none) }) sur un domaine vérifié de l'organisation dans lyxal_auth (décision M9), sous le même nom, en forme ASCII (décision M10) ; MAIL_DOMAIN_NOT_VERIFIED, MAIL_DOMAIN_EXISTS ; publie mail.domain.created. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_domain_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_domain_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "mail_domain" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT * FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok(object::extend($domain, { addresses: $domain.address_count }));
} COMMENT "Domaine de courrier ({ domain }) et son nombre d'adresses (addresses, compteur tenu). Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_domain_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_domain_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            after: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 253 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $context = fn::auth_context({});
    LET $tenant = $p.tenant ?? (IF $context.ok { $context.data.organization } ELSE { NONE });
    IF $tenant IS NONE OR !fn::mail_can({ action: "manage", tenant: $tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM mail_domain WHERE tenant = $tenant AND ($p.after IS NONE OR name > $p.after) ORDER BY name LIMIT $p.limit + 1);
    LET $items = array::slice($rows, 0, $p.limit);
    RETURN fn::result_ok({ items: $items, next: IF array::len($rows) > $p.limit { array::last($items).name } ELSE { NONE } });
} COMMENT "Domaines de courrier d'une organisation ({ tenant (absent : organisation de la session), after (curseur : nom), limit (50, 200 au plus) }), triés par nom (unique) ; { items, next } (next : curseur de la page suivante, NONE à la fin). Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_domain_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_domain_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "mail_domain" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }] },
            subaddress_separator: { pipeline: [{ rule: "enum", options: { allowed: ["+", "none"], case_sensitive: true } }] },
            catch_all: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            postmaster: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            module_senders: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }] } }] },
            backscatter_protection: { pipeline: [{ rule: "boolean" }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["catch_all", "postmaster"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT id, tenant, name, subaddress_separator FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    -- Expéditeurs des modules (lot 6, §12.3) : parties locales ASCII en minuscules, distinctes,
    -- hors du préfixe réservé rp= et d'aucune adresse inscrite du domaine
    LET $senders = IF $p.module_senders IS NONE { NONE } ELSE { array::map($p.module_senders, |$l| fn::mail_address_normalize($l, $domain.name)) };
    IF $senders IS NOT NONE AND (!array::all($senders, |$s| $s.valid) OR array::len(array::distinct($senders.local_part)) != array::len($senders)) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { module_senders: ["format"] } });
    };
    IF $senders IS NOT NONE AND array::any($senders, |$s| string::starts_with($s.local_part, "rp=")) { RETURN fn::error_result("MAIL_ADDRESS_RESERVED", $p.language, {}); };
    IF $senders IS NOT NONE AND array::len($senders) > 0 AND array::len(SELECT VALUE id FROM mail_address WHERE domain = $domain.id AND local_part IN $senders.local_part LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_MODULE_SENDER_CONFLICT", $p.language, {});
    };
    -- Attrape-tout et postmaster : comptes actifs de l'organisation du domaine
    LET $receivers = array::filter([$p.catch_all, $p.postmaster], |$a| $a IS NOT NONE);
    LET $known = (SELECT id, state FROM $receivers WHERE tenant = $domain.tenant);
    LET $missing = array::complement($receivers, $known.id);
    IF array::len($missing) > 0 { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $missing[0] }); };
    LET $inactive = array::find($known, |$a| $a.state != "active");
    IF $inactive IS NOT NONE { RETURN fn::error_result(IF $inactive.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, $p.language, { account: <string> $inactive.id }); };
    LET $updated = (UPDATE ONLY $domain.id SET
        state = $p.state ?? state,
        subaddress_separator = IF $p.subaddress_separator IS NONE { subaddress_separator } ELSE IF $p.subaddress_separator = "none" { NONE } ELSE { $p.subaddress_separator },
        catch_all = IF "catch_all" IN $p.clear { NONE } ELSE { $p.catch_all ?? catch_all },
        postmaster = IF "postmaster" IN $p.clear { NONE } ELSE { $p.postmaster ?? postmaster },
        module_senders = IF $senders IS NONE { module_senders } ELSE { $senders.local_part },
        backscatter_protection = $p.backscatter_protection ?? backscatter_protection);
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_domain" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un domaine de courrier ({ domain, state (active, disabled : aucune adresse du domaine n'est résolue), subaddress_separator (+ ou none), catch_all (compte attrape-tout : reçoit les adresses inconnues du domaine), postmaster (compte qui reçoit postmaster@<domaine> sans adresse inscrite), module_senders (0 à 20 parties locales sous lesquelles les modules envoient : jamais une adresse inscrite, MAIL_MODULE_SENDER_CONFLICT ; préfixe rp= réservé, MAIL_ADDRESS_RESERVED), backscatter_protection (refus des avis à expéditeur vide adressés à une adresse ordinaire, vrai par défaut), clear (champs à effacer : catch_all, postmaster) }) ; un champ absent est conservé ; attrape-tout et postmaster : comptes actifs de l'organisation du domaine (MAIL_ACCOUNT_NOT_FOUND, MAIL_ACCOUNT_DISABLED, MAIL_ACCOUNT_DELETING). Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_domain_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_domain_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "mail_domain" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT id, tenant, address_count FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $domain.address_count > 0 { RETURN fn::error_result("MAIL_DOMAIN_NOT_EMPTY", $p.language, { addresses: $domain.address_count }); };
    LET $deleted = (DELETE ONLY $domain.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_domain" }); };
    RETURN fn::result_ok({ deleted: true });
} COMMENT "Supprime un domaine de courrier ({ domain }) qui ne porte plus aucune adresse ni alias (MAIL_DOMAIN_NOT_EMPTY) ; publie mail.domain.deleted ; le domaine reste vérifié dans lyxal_auth. Droit : gestion";

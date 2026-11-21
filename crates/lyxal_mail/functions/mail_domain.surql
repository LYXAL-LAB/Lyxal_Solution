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
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["max_message_bytes", "default_quota_bytes", "tombstone_retention_days", "max_mailboxes_per_account", "max_addresses_per_account", "max_keywords_per_message"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $fields = ["max_message_bytes", "default_quota_bytes", "tombstone_retention_days", "max_mailboxes_per_account", "max_addresses_per_account", "max_keywords_per_message"];
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
} COMMENT "Enregistre les réglages d'une portée ({ tenant, max_message_bytes, default_quota_bytes, tombstone_retention_days, max_mailboxes_per_account, max_addresses_per_account, max_keywords_per_message, clear }) : un champ fourni est remplacé, un champ nommé dans clear est effacé, les autres sont conservés. Droit : gestion (mail.domain.manage ; mail.installation.manage sans tenant)";

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
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT id, tenant, subaddress_separator FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $updated = (UPDATE ONLY $domain.id SET
        state = $p.state ?? state,
        subaddress_separator = IF $p.subaddress_separator IS NONE { subaddress_separator } ELSE IF $p.subaddress_separator = "none" { NONE } ELSE { $p.subaddress_separator });
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_domain" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un domaine de courrier ({ domain, state (active, disabled : aucune adresse du domaine n'est résolue), subaddress_separator (+ ou none) }) ; un champ absent est conservé. Droit : gestion";

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

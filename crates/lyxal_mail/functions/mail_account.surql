-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : comptes, quotas, adresses et alias
-- MODULE    : lyxal_mail
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::mail_account_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_account_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            domain: { pipeline: [{ rule: "record", options: { expected_table: "mail_domain" } }], required: true },
            local_part: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            quota_bytes: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT id, tenant, name, state FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $domain.state != "active" { RETURN fn::error_result("MAIL_DOMAIN_DISABLED", $p.language, { domain: <string> $domain.id }); };
    LET $normalized = fn::mail_address_normalize($p.local_part, $domain.name);
    IF !$normalized.valid { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { local_part: ["format"] } }); };
    -- L'identité est membre actif de l'organisation (adhésion lisible par son administrateur)
    IF array::len(SELECT VALUE id FROM auth_member_of WHERE in = $p.identity AND out = $domain.tenant AND state = "active" LIMIT 1) = 0 {
        RETURN fn::error_result("MAIL_ACCOUNT_NOT_MEMBER", $p.language, { identity: <string> $p.identity });
    };
    IF array::len(SELECT VALUE id FROM mail_account WHERE tenant = $domain.tenant AND identity = $p.identity LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_ACCOUNT_EXISTS", $p.language, { identity: <string> $p.identity });
    };
    IF array::len(SELECT VALUE id FROM mail_address WHERE address = $normalized.address LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_ADDRESS_EXISTS", $p.language, {});
    };
    -- Compte (ses six dossiers sont créés par l'événement de création), adresse principale, lien
    LET $account = (CREATE ONLY mail_account CONTENT { tenant: $domain.tenant, identity: $p.identity, quota_bytes: $p.quota_bytes });
    IF $account == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_account" }); };
    LET $address = (CREATE ONLY mail_address CONTENT {
        tenant: $domain.tenant, domain: $domain.id, local_part: $normalized.local_part, address: $normalized.address,
        kind: "account", account: $account.id
    });
    -- Même droit que le compte : un refus ici annule tout plutôt que de laisser un compte sans adresse
    IF $address == NONE { THROW "MAIL_WRITE_FORBIDDEN"; };
    LET $linked = (UPDATE ONLY $account.id SET primary_address = $address.id);
    IF $linked == NONE { THROW "MAIL_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({ account: $linked, address: $address });
} COMMENT "Crée le compte de courrier d'un membre ({ identity, domain, local_part, quota_bytes }) : compte, adresse principale (partie locale ASCII en minuscules, décision M10) et six dossiers (INBOX, Drafts, Sent, Junk, Trash, Archive, rôles SPECIAL-USE, décision M18) créés ensemble ; MAIL_ACCOUNT_NOT_MEMBER, MAIL_ACCOUNT_EXISTS, MAIL_ADDRESS_EXISTS, MAIL_DOMAIN_DISABLED ; publie mail.account.created et mail.address.created ; { account, address }. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_account_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_account_get($params: object) {
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
    -- Compte invisible (autre organisation, autre membre) : introuvable
    LET $account = IF $target IS NONE { NONE } ELSE { (SELECT * FROM ONLY $target) };
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, {}); };
    LET $quota = $account.quota_bytes ?? fn::mail_settings_effective({ tenant: $account.tenant }).default_quota_bytes;
    RETURN fn::result_ok(object::extend($account, { effective_quota_bytes: $quota }));
} COMMENT "Compte ({ account }, absent : celui de la session dans son organisation) et son quota effectif (effective_quota_bytes : celui du compte, sinon celui des réglages, NONE : sans quota). Droit : gestion, ou titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_account_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_account_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled", "deleting"], case_sensitive: true } }] },
            after: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
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
    LET $rows = (SELECT * FROM mail_account
        WHERE tenant = $tenant AND ($p.state IS NONE OR state = $p.state) AND ($p.after IS NONE OR id > $p.after)
        ORDER BY id LIMIT $p.limit + 1);
    LET $items = array::slice($rows, 0, $p.limit);
    RETURN fn::result_ok({ items: $items, next: IF array::len($rows) > $p.limit { <string> array::last($items).id } ELSE { NONE } });
} COMMENT "Comptes d'une organisation ({ tenant (absent : organisation de la session), state, after (curseur : identifiant), limit (50, 200 au plus) }), triés par identifiant ; { items, next }. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_account_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_account_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }] },
            quota_bytes: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["quota_bytes"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $account = (SELECT id, tenant, state FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    IF !fn::mail_can({ action: "manage", tenant: $account.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $account.state = "deleting" { RETURN fn::error_result("MAIL_ACCOUNT_DELETING", $p.language, {}); };
    LET $quota_changed = "quota_bytes" IN $p.clear OR $p.quota_bytes IS NOT NONE;
    -- Quota changé : la date du dépassement s'efface (un nouveau refus publiera mail.quota.exceeded)
    LET $updated = (UPDATE ONLY $account.id SET
        state = $p.state ?? state,
        quota_bytes = IF "quota_bytes" IN $p.clear { NONE } ELSE { $p.quota_bytes ?? quota_bytes },
        quota_exceeded_at = IF $quota_changed { NONE } ELSE { quota_exceeded_at });
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_account" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un compte ({ account, state (active, disabled : aucune écriture ni remise), quota_bytes, clear (quota_bytes : quota des réglages) }) ; un quota changé efface la date du dernier dépassement ; un compte en suppression ne change plus (MAIL_ACCOUNT_DELETING). Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_account_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_account_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $account = (SELECT id, tenant, state FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    IF !fn::mail_can({ action: "manage", tenant: $account.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $account.state = "deleting" { RETURN fn::error_result("MAIL_ACCOUNT_DELETING", $p.language, {}); };
    LET $updated = (UPDATE ONLY $account.id SET state = "deleting");
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_account" }); };
    RETURN fn::result_ok((SELECT * FROM ONLY $account.id));
} COMMENT "Supprime un compte ({ account }) : état deleting, adresses retirées tout de suite, alias qui ne le visent plus (un alias sans compte est retiré) ; messages, contenus, fichiers et compte purgés ensuite par la maintenance (fn::mail_account_purge_step, qui publie mail.account.deleted). Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_quota_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_quota_get($params: object) {
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
    LET $account = IF $target IS NONE { NONE } ELSE { (SELECT tenant, used_bytes, message_count, quota_bytes FROM ONLY $target) };
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, {}); };
    LET $quota = $account.quota_bytes ?? fn::mail_settings_effective({ tenant: $account.tenant }).default_quota_bytes;
    RETURN fn::result_ok({
        used_bytes: $account.used_bytes,
        message_count: $account.message_count,
        quota_bytes: $quota,
        resources: [
            { name: "STORAGE", usage: $account.used_bytes, limit: $quota },
            { name: "MESSAGE", usage: $account.message_count, limit: NONE }
        ]
    });
} COMMENT "Quota d'un compte ({ account }, absent : celui de la session) : { used_bytes, message_count, quota_bytes (NONE : sans quota), resources (STORAGE, MESSAGE de la RFC 9208) }, lus dans les compteurs tenus. Droit : gestion, ou titulaire du compte";

-- ----------------------------------------------------------------------------
-- fn::mail_address_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "mail_domain" } }], required: true },
            local_part: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            kind: { pipeline: [{ rule: "enum", options: { allowed: ["account", "alias"], case_sensitive: true } }], required: true },
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            targets: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 50 } }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] } }, { rule: "array_unique" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Sorte account : un compte, pas de cibles ; alias : des cibles, pas de compte
    IF ($p.kind = "account") != ($p.account IS NOT NONE) OR ($p.kind = "alias") != ($p.targets IS NOT NONE) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { kind: ["account_or_targets"] } });
    };
    LET $domain = (SELECT id, tenant, name, state FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $domain.state != "active" { RETURN fn::error_result("MAIL_DOMAIN_DISABLED", $p.language, { domain: <string> $domain.id }); };
    LET $normalized = fn::mail_address_normalize($p.local_part, $domain.name);
    IF !$normalized.valid { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { local_part: ["format"] } }); };
    IF array::len(SELECT VALUE id FROM mail_address WHERE address = $normalized.address LIMIT 1) > 0 {
        RETURN fn::error_result("MAIL_ADDRESS_EXISTS", $p.language, {});
    };
    IF $p.kind = "account" {
        LET $account = (SELECT id, tenant, state, address_count FROM ONLY $p.account);
        IF $account == NONE OR $account.tenant != $domain.tenant { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
        IF $account.state = "deleting" { RETURN fn::error_result("MAIL_ACCOUNT_DELETING", $p.language, {}); };
        LET $max = fn::mail_settings_effective({ tenant: $domain.tenant }).max_addresses_per_account;
        IF $account.address_count >= $max { RETURN fn::error_result("MAIL_ADDRESS_LIMIT", $p.language, { max_addresses_per_account: $max }); };
    } ELSE {
        LET $valid = (SELECT VALUE id FROM $p.targets WHERE tenant = $domain.tenant AND state != "deleting");
        IF array::len($valid) != array::len($p.targets) { RETURN fn::error_result("MAIL_ALIAS_TARGET_INVALID", $p.language, {}); };
    };
    LET $created = (CREATE ONLY mail_address CONTENT {
        tenant: $domain.tenant, domain: $domain.id, local_part: $normalized.local_part, address: $normalized.address,
        kind: $p.kind, account: $p.account, targets: $p.targets ?? []
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_address" }); };
    RETURN fn::result_ok($created);
} COMMENT "Crée une adresse ({ domain, local_part, kind : account (avec account) ou alias (avec targets : 1 à 50 comptes de l'organisation) }) : partie locale ASCII en minuscules (décision M10) ; MAIL_ADDRESS_EXISTS, MAIL_ADDRESS_LIMIT (adresses par compte), MAIL_ALIAS_TARGET_INVALID, MAIL_DOMAIN_DISABLED ; publie mail.address.created. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_address_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            address: { pipeline: [{ rule: "record", options: { expected_table: "mail_address" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }] },
            targets: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 50 } }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] } }, { rule: "array_unique" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $address = (SELECT id, tenant, kind FROM ONLY $p.address);
    IF $address == NONE { RETURN fn::error_result("MAIL_ADDRESS_NOT_FOUND", $p.language, { address: <string> $p.address }); };
    IF !fn::mail_can({ action: "manage", tenant: $address.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $p.targets IS NOT NONE {
        IF $address.kind != "alias" { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { targets: ["alias_only"] } }); };
        LET $valid = (SELECT VALUE id FROM $p.targets WHERE tenant = $address.tenant AND state != "deleting");
        IF array::len($valid) != array::len($p.targets) { RETURN fn::error_result("MAIL_ALIAS_TARGET_INVALID", $p.language, {}); };
    };
    LET $updated = (UPDATE ONLY $address.id SET state = $p.state ?? state, targets = $p.targets ?? targets);
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_address" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie une adresse ({ address, state (active, disabled : non résolue), targets (alias seulement : 1 à 50 comptes de l'organisation) }) ; un champ absent est conservé. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_address_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            address: { pipeline: [{ rule: "record", options: { expected_table: "mail_address" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $address = (SELECT id, tenant, account FROM ONLY $p.address);
    IF $address == NONE { RETURN fn::error_result("MAIL_ADDRESS_NOT_FOUND", $p.language, { address: <string> $p.address }); };
    IF !fn::mail_can({ action: "manage", tenant: $address.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF $address.account IS NOT NONE AND (SELECT VALUE primary_address FROM ONLY $address.account) = $address.id {
        RETURN fn::error_result("MAIL_ADDRESS_IS_PRIMARY", $p.language, {});
    };
    LET $deleted = (DELETE ONLY $address.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_address" }); };
    RETURN fn::result_ok({ deleted: true });
} COMMENT "Retire une adresse ou un alias ({ address }) ; l'adresse principale d'un compte ne se retire pas (MAIL_ADDRESS_IS_PRIMARY) ; publie mail.address.deleted. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::mail_address_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "mail_domain" } }] },
            account: { pipeline: [{ rule: "record", options: { expected_table: "mail_account" } }] },
            after: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 254 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.domain IS NONE) = ($report.value.account IS NONE) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { { domain: ["domain_or_account"] } } ELSE { $report.by_field } });
    };
    LET $p = $report.value;
    IF $p.domain IS NOT NONE {
        LET $domain = (SELECT id, tenant FROM ONLY $p.domain);
        IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
        IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
        LET $rows = (SELECT * FROM mail_address WHERE domain = $domain.id AND ($p.after IS NONE OR address > $p.after) ORDER BY address LIMIT $p.limit + 1);
        LET $items = array::slice($rows, 0, $p.limit);
        RETURN fn::result_ok({ items: $items, next: IF array::len($rows) > $p.limit { array::last($items).address } ELSE { NONE } });
    };
    -- Adresses d'un compte : son administrateur ou son titulaire (compte invisible : introuvable)
    LET $account = (SELECT id, tenant FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("MAIL_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    LET $rows = (SELECT * FROM mail_address WHERE account = $account.id AND ($p.after IS NONE OR address > $p.after) ORDER BY address LIMIT $p.limit + 1);
    LET $items = array::slice($rows, 0, $p.limit);
    RETURN fn::result_ok({ items: $items, next: IF array::len($rows) > $p.limit { array::last($items).address } ELSE { NONE } });
} COMMENT "Adresses d'un domaine ({ domain }, droit : gestion) ou d'un compte ({ account }, droit : gestion, ou titulaire du compte), triées par adresse (unique) ; after : curseur (adresse), limit (50, 200 au plus) ; { items, next }";

-- ----------------------------------------------------------------------------
-- fn::mail_address_resolve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_resolve($params: object) {
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
    IF !fn::validation_email($p.address, 254).valid { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    LET $parts = string::split($p.address, "@");
    LET $local = array::join(array::slice($parts, 0, array::len($parts) - 1), "@");
    LET $domain = (SELECT id, state, subaddress_separator FROM ONLY mail_domain WHERE name = array::last($parts) LIMIT 1);
    IF $domain == NONE OR $domain.state != "active" { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    -- Adresse exacte, sinon sans sa sous-adresse (jean+factures → jean)
    LET $exact = (SELECT address, kind, account, targets, state FROM ONLY mail_address WHERE address = $p.address LIMIT 1);
    LET $base = IF $exact IS NONE AND $domain.subaddress_separator IS NOT NONE AND string::contains($local, $domain.subaddress_separator) {
        string::concat(string::split($local, $domain.subaddress_separator)[0], "@", array::last($parts))
    } ELSE { NONE };
    LET $row = $exact ?? (IF $base IS NONE { NONE } ELSE { (SELECT address, kind, account, targets, state FROM ONLY mail_address WHERE address = $base LIMIT 1) });
    IF $row == NONE OR $row.state != "active" { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    -- Comptes actifs seulement (alias développé)
    LET $wanted = IF $row.kind = "account" { [$row.account] } ELSE { $row.targets };
    LET $accounts = (SELECT VALUE id FROM $wanted WHERE state = "active" ORDER BY id);
    IF array::len($accounts) = 0 { RETURN fn::error_result("MAIL_RECIPIENT_UNKNOWN", $p.language, {}); };
    RETURN fn::result_ok({ accounts: $accounts, address: $row.address });
} COMMENT "Résout une adresse de destinataire ({ address }) : casse ignorée, sous-adresse retirée (jean+factures → jean) si le domaine en a, alias développé, comptes actifs seulement ; { accounts, address (adresse inscrite qui a servi) } ; MAIL_RECIPIENT_UNKNOWN sinon (domaine ou adresse absents ou désactivés, aucun compte actif), sans écho de l'adresse. Droit : compte de service, session système";

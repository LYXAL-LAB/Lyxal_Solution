-- ============================================================================
-- FONCTIONS : domaines e-mail vérifiés d'une organisation
-- MODULE    : lyxal_auth
-- ============================================================================
-- Le jeton de défi est généré en Rust (OsRng) et publié par le client en DNS TXT
-- `_lyxal-challenge.<domaine>` ; Rust lit les enregistrements et transmet leurs empreintes
-- BLAKE3. La base ne connaît que des empreintes.

DEFINE FUNCTION OVERWRITE fn::auth_organization_domain_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            domain: { pipeline: [{ rule: "domain", options: { allow_subdomains: true } }], required: true },
            challenge_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { domain: { pipeline: [{ rule: "domain" }] }, challenge_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.settings.manage" });
    };
    IF !record::exists($p.organization) { RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {}); };
    -- Un domaine d'une autre organisation est invisible : INSERT IGNORE n'insère rien quand l'index
    -- unique sur le domaine le contient déjà, sans rien révéler de son propriétaire
    LET $created = (INSERT IGNORE INTO auth_organization_domain {
        id: type::record("auth_organization_domain", string::replace(<string> rand::uuid::v7(), "-", "")),
        organization: $p.organization,
        domain: $p.domain,
        challenge_hash: $p.challenge_hash
    })[0];
    IF $created == NONE { RETURN fn::error_result("AUTH_DOMAIN_TAKEN", $p.language, { domain: $p.domain }); };
    RETURN fn::result_ok(object::extend(object::remove($created, "challenge_hash"), { txt_record: string::concat("_lyxal-challenge.", $p.domain) }));
} COMMENT "Déclare un domaine à vérifier ({ organization, domain, challenge_hash }) ; renvoie le nom de l'enregistrement TXT à publier. Permission auth.organization.settings.manage ou auth.organization.manage";

DEFINE FUNCTION OVERWRITE fn::auth_organization_domain_verify($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization_domain" } }], required: true },
            observed_hashes: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT * FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("AUTH_DOMAIN_NOT_VERIFIED", $p.language, { reason: "not_found" }); };
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: $domain.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.settings.manage" });
    };
    IF $domain.state = "verified" { RETURN fn::result_ok(object::remove($domain, "challenge_hash")); };
    IF $domain.challenge_hash NOTINSIDE array::map($p.observed_hashes, |$h| string::lowercase($h)) {
        RETURN fn::error_result("AUTH_DOMAIN_NOT_VERIFIED", $p.language, { txt_record: string::concat("_lyxal-challenge.", $domain.domain) });
    };
    LET $verified = (UPDATE ONLY $domain.id SET state = "verified", verified_at = time::now());
    IF $verified == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization_domain" }); };
    RETURN fn::result_ok(object::remove($verified, "challenge_hash"));
} COMMENT "Vérifie un domaine ({ domain, observed_hashes : empreintes BLAKE3 des enregistrements TXT lus en Rust }). Permission auth.organization.settings.manage ou auth.organization.manage";

DEFINE FUNCTION OVERWRITE fn::auth_organization_domain_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization_domain" } }], required: true },
            auto_join: { pipeline: [{ rule: "boolean" }] },
            default_roles: { pipeline: [{ rule: "array" }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }] } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT * FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("AUTH_DOMAIN_NOT_VERIFIED", $p.language, { reason: "not_found" }); };
    LET $platform = fn::auth_has_permission({ permission: "auth.organization.manage" });
    IF !$platform AND !fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: $domain.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.settings.manage" });
    };
    IF ($p.auto_join ?? false) AND $domain.state != "verified" { RETURN fn::error_result("AUTH_DOMAIN_NOT_VERIFIED", $p.language, {}); };
    LET $roles = $p.default_roles ?? $domain.default_roles;
    LET $found = (SELECT id, scope, tenant, is_default FROM auth_role WHERE id IN $roles);
    IF array::len($found) != array::len(array::distinct($roles)) { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF array::any($found, |$r| $r.scope != "organization" OR ($r.tenant IS NOT NONE AND $r.tenant != $domain.organization)) {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    IF array::any($found, |$r| !$r.is_default) AND !$platform AND !fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: $domain.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.role.manage" });
    };
    LET $updated = (UPDATE ONLY $domain.id SET auto_join = $p.auto_join ?? $domain.auto_join, default_roles = $roles);
    IF $updated == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization_domain" }); };
    RETURN fn::result_ok(object::remove($updated, "challenge_hash"));
} COMMENT "Règle le rattachement automatique d'un domaine vérifié ({ domain, auto_join, default_roles }). Permission auth.organization.settings.manage (+ auth.organization.role.manage pour des rôles non par défaut)";

DEFINE FUNCTION OVERWRITE fn::auth_organization_domain_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            domain: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization_domain" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT id, organization FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("AUTH_DOMAIN_NOT_VERIFIED", $p.language, { reason: "not_found" }); };
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: $domain.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.settings.manage" });
    };
    LET $deleted = (DELETE ONLY $domain.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization_domain" }); };
    RETURN fn::result_ok({ removed: true, domain: $domain.id });
} COMMENT "Retire un domaine d'une organisation ({ domain }). Permission auth.organization.settings.manage ou auth.organization.manage";

DEFINE FUNCTION OVERWRITE fn::auth_organization_domain_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.organization.settings.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.settings.manage" });
    };
    RETURN fn::result_ok(
        SELECT id, domain, state, verified_at, auto_join, default_roles, created_at FROM auth_organization_domain
        WHERE organization = $p.organization ORDER BY domain
    );
} COMMENT "Liste les domaines d'une organisation ({ organization }) sans empreintes de défi. Permission auth.organization.settings.manage ou auth.organization.manage";

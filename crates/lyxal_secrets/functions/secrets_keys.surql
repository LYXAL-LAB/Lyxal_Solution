-- ============================================================================
-- FONCTIONS : clés des organisations
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Réservées à la session système ou au worker (service Rust de l'hôte), sauf
-- fn::secrets_tenant_key_rotate_allowed, qui contrôle le droit d'une personne de demander une
-- rotation. La clé elle-même n'est jamais visible en clair ici : seulement scellée. Chaque clé a
-- un usage (purpose) : secrets (versions des secrets) ou files (clés des fichiers chiffrés d'un
-- module de l'hôte, FileKeys) ; une clé active par portée et par usage.

-- ----------------------------------------------------------------------------
-- fn::secrets_keys_trusted (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_keys_trusted() -> bool {
    RETURN fn::auth_session_valid({}).system OR fn::secrets_can({ action: "worker" });
} COMMENT "Interne : vrai pour la session système ou le compte de service du coffre-fort";

-- ----------------------------------------------------------------------------
-- fn::secrets_key_is_active (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_key_is_active($scope_key: string, $key_id: string) -> bool {
    RETURN (SELECT VALUE state FROM ONLY secrets_tenant_key WHERE key_id = $key_id AND scope_key = $scope_key LIMIT 1) = "active";
} COMMENT "Interne : vrai si key_id est la clé active de la portée (une valeur ne se scelle que par elle)";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_ring
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_ring($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        tenant: { checks: [|$v: any| fn::validation_record($v, "auth_organization")] },
        purpose: { checks: [|$v: any| fn::validation_enum($v, ["secrets", "files"], true)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok({
        items: (SELECT key_id, wrapped, state FROM secrets_tenant_key
            WHERE scope_key = $scope AND purpose = $p.purpose AND state IN ["active", "decrypt_only"] ORDER BY created_at ASC)
    });
} COMMENT "Trousseau scellé d'une portée pour un usage ({ tenant, purpose : secrets ou files }) : clés active et decrypt_only, scellées par la clé maîtresse : { items: [{ key_id, wrapped, state }] }. Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            purpose: { pipeline: [{ rule: "enum", options: { allowed: ["secrets", "files"], case_sensitive: true } }], required: true },
            wrapped: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 4096 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            replaces: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }] },
            requested_by: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $active = (SELECT id, key_id FROM ONLY secrets_tenant_key WHERE scope_key = $scope AND purpose = $p.purpose AND state = "active" LIMIT 1);
    -- Écriture conditionnelle : première clé (replaces absent) ou remplacement de la clé active attendue
    IF ($p.replaces IS NONE AND $active IS NOT NONE) OR ($p.replaces IS NOT NONE AND $active.key_id != $p.replaces) {
        RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { active: $active.key_id, replaces: $p.replaces });
    };
    IF $active IS NOT NONE {
        UPDATE $active.id SET state = "decrypt_only", retired_at = time::now();
    };
    LET $created = (INSERT IGNORE INTO secrets_tenant_key {
        tenant: $p.tenant,
        purpose: $p.purpose,
        key_id: $p.key_id,
        wrapped: $p.wrapped,
        requested_by: IF $p.requested_by IS NONE { NONE } ELSE { <string> $p.requested_by }
    });
    -- Index : une autre création concurrente a gagné
    IF array::len($created) = 0 { THROW "SECRETS_TENANT_KEY_CONFLICT"; };
    RETURN fn::result_ok({ key_id: $created[0].key_id, state: $created[0].state, retired: $active.key_id });
} COMMENT "Range une clé d'organisation scellée ({ tenant, purpose : secrets ou files, key_id, wrapped, replaces, requested_by }) : première clé de l'usage (replaces absent, aucune clé active) ou rotation (replaces = clé active attendue de l'usage, qui passe en decrypt_only). Création concurrente : SECRETS_TENANT_KEY_CONFLICT, le service relit le trousseau. Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_rotate_allowed
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_rotate_allowed($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "settings", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $caller = fn::secrets_caller();
    RETURN fn::result_ok({ allowed: true, requested_by: $caller.identity });
} COMMENT "Droit de demander la rotation de la clé d'une organisation ({ tenant }) : { allowed, requested_by } ; la nouvelle clé est ensuite créée par la session système (fn::secrets_tenant_key_create). Droit : réglages";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_rewrap
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_rewrap($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            expected_master_key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            wrapped: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 4096 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $key = (SELECT id, state, master_key_id FROM ONLY secrets_tenant_key WHERE key_id = $p.key_id LIMIT 1);
    IF $key == NONE OR $key.state = "destroyed" { RETURN fn::error_result("SECRETS_TENANT_KEY_UNAVAILABLE", $p.language, { key_id: $p.key_id }); };
    IF $key.master_key_id != $p.expected_master_key_id {
        RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { master_key_id: $key.master_key_id });
    };
    LET $updated = (UPDATE ONLY $key.id SET wrapped = $p.wrapped, rewrapped_at = time::now() WHERE master_key_id = $p.expected_master_key_id);
    IF $updated == NONE { RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { key_id: $p.key_id }); };
    RETURN fn::result_ok({ key_id: $p.key_id, master_key_id: $updated.master_key_id });
} COMMENT "Rescelle une clé d'organisation par la nouvelle clé maîtresse ({ key_id, expected_master_key_id, wrapped }) ; refusé si une autre clé maîtresse a déjà été posée (SECRETS_TENANT_KEY_CONFLICT). Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_destroy
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_destroy($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            in_use: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $key = (SELECT id, scope_key, purpose, state FROM ONLY secrets_tenant_key WHERE key_id = $p.key_id LIMIT 1);
    IF $key == NONE OR $key.state != "decrypt_only" { RETURN fn::error_result("SECRETS_TENANT_KEY_UNAVAILABLE", $p.language, { key_id: $p.key_id, state: $key.state }); };
    -- Clé « secrets » : le coffre-fort sait si une version l'utilise encore. Clé « fichiers » : seul
    -- le module qui range les fichiers le sait ; l'hôte le dit (in_use), le coffre-fort ne lit
    -- aucune table de ce module
    IF $key.purpose = "secrets" AND $p.in_use IS NOT NONE {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", $p.language, { fields: { in_use: ["not_allowed"] } });
    };
    LET $used = IF $key.purpose = "files" {
        $p.in_use ?? true
    } ELSE {
        array::len(SELECT VALUE id FROM secrets_version WHERE scope_key = $key.scope_key AND key_id = $p.key_id LIMIT 1) > 0
    };
    IF $used { RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { key_id: $p.key_id, in_use: true }); };
    LET $destroyed = (UPDATE ONLY $key.id SET state = "destroyed", wrapped = NONE, destroyed_at = time::now());
    IF $destroyed == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_tenant_key" }); };
    RETURN fn::result_ok({ key_id: $p.key_id, destroyed: true });
} COMMENT "Détruit une ancienne clé d'organisation ({ key_id, in_use }) : seulement en decrypt_only et quand plus rien ne l'utilise ; matière effacée. Clé « secrets » : plus aucune version (in_use refusé) ; clé « fichiers » : in_use = false fourni par l'hôte d'après le module qui range les fichiers (absent : refus). Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_retired
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_retired($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            purpose: { pipeline: [{ rule: "enum", options: { allowed: ["secrets", "files"], case_sensitive: true } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok({
        items: (SELECT key_id, tenant, retired_at FROM secrets_tenant_key
            WHERE purpose = $p.purpose AND state = "decrypt_only" ORDER BY retired_at, key_id LIMIT $p.limit START $p.start)
    });
} COMMENT "Clés retirées d'un usage ({ purpose : secrets ou files, limit, start : clés en échec à passer }), de la plus anciennement retirée à la plus récente : { items: [{ key_id, tenant, retired_at }] } ; pour l'usage files, l'hôte rescelle les clés de fichiers qu'elles scellent puis les détruit (fn::secrets_tenant_key_destroy avec in_use). Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_rewrap_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rewrap_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            master_key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            skip_versions: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            skip_keys: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $retired = (SELECT key_id, scope_key, tenant FROM secrets_tenant_key WHERE purpose = "secrets" AND state = "decrypt_only");
    LET $retired_ids = $retired.key_id;
    -- Versions encore scellées par une clé retirée
    LET $versions = (SELECT secret, tenant, number, key_id, envelope FROM secrets_version
        WHERE state != "destroyed" AND key_id IN $retired_ids ORDER BY id LIMIT $p.limit START $p.skip_versions);
    -- Clés d'organisation (tous usages) scellées par une autre clé maîtresse que l'active
    LET $keys = (SELECT key_id, tenant, purpose, wrapped, master_key_id FROM secrets_tenant_key
        WHERE state IN ["active", "decrypt_only"] AND master_key_id != $p.master_key_id ORDER BY id LIMIT $p.limit START $p.skip_keys);
    -- Clés « secrets » retirées que plus aucune version n'utilise (les clés « fichiers » sont
    -- détruites par l'hôte : fn::secrets_tenant_key_retired)
    LET $unused = array::filter($retired, |$k| array::len(SELECT VALUE id FROM secrets_version WHERE scope_key = $k.scope_key AND key_id = $k.key_id LIMIT 1) = 0);
    RETURN fn::result_ok({ versions: $versions, keys: $keys, unused: $unused.key_id });
} COMMENT "Travail de rescellement ({ master_key_id : clé maîtresse active, limit, skip_versions, skip_keys : éléments en échec à passer, pour qu'ils n'empêchent pas le reste }) : versions scellées par une clé « secrets » retirée (avec leur enveloppe), clés d'organisation de tous usages scellées par une autre clé maîtresse (avec leur usage), clés « secrets » retirées inutilisées (à détruire). Session système ou worker";

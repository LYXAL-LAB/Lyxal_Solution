-- ============================================================================
-- FONCTIONS : clés des organisations
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Réservées à la session système ou au worker (service Rust de l'hôte), sauf
-- fn::secrets_tenant_key_rotate_allowed, qui contrôle le droit d'une personne de demander une
-- rotation. La clé elle-même n'est jamais visible en clair ici : seulement scellée.

-- ----------------------------------------------------------------------------
-- fn::secrets_keys_trusted (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_keys_trusted() -> bool {
    RETURN fn::auth_session_valid({}).system OR fn::secrets_can({ action: "worker" });
} COMMENT "Interne : vrai pour la session système ou le compte de service du coffre-fort";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_ring
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_ring($params: object) {
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
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok({
        items: (SELECT key_id, wrapped, state FROM secrets_tenant_key
            WHERE scope_key = $scope AND state IN ["active", "decrypt_only"] ORDER BY created_at ASC)
    });
} COMMENT "Trousseau scellé d'une portée ({ tenant }) : clés active et decrypt_only, scellées par la clé maîtresse : { items: [{ key_id, wrapped, state }] }. Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_key_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_key_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
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
    LET $active = (SELECT id, key_id FROM ONLY secrets_tenant_key WHERE scope_key = $scope AND state = "active" LIMIT 1);
    -- Écriture conditionnelle : première clé (replaces absent) ou remplacement de la clé active attendue
    IF ($p.replaces IS NONE AND $active IS NOT NONE) OR ($p.replaces IS NOT NONE AND $active.key_id != $p.replaces) {
        RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { active: $active.key_id, replaces: $p.replaces });
    };
    IF $active IS NOT NONE {
        UPDATE $active.id SET state = "decrypt_only", retired_at = time::now();
    };
    LET $created = (INSERT IGNORE INTO secrets_tenant_key {
        tenant: $p.tenant,
        key_id: $p.key_id,
        wrapped: $p.wrapped,
        requested_by: IF $p.requested_by IS NONE { NONE } ELSE { <string> $p.requested_by }
    });
    -- Index : une autre création concurrente a gagné
    IF array::len($created) = 0 { THROW "SECRETS_TENANT_KEY_CONFLICT"; };
    RETURN fn::result_ok({ key_id: $created[0].key_id, state: $created[0].state, retired: $active.key_id });
} COMMENT "Range une clé d'organisation scellée ({ tenant, key_id, wrapped, replaces, requested_by }) : première clé (replaces absent, aucune clé active) ou rotation (replaces = clé active attendue, qui passe en decrypt_only). Création concurrente : SECRETS_TENANT_KEY_CONFLICT, le service relit le trousseau. Session système ou worker";

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
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $key = (SELECT id, scope_key, state FROM ONLY secrets_tenant_key WHERE key_id = $p.key_id LIMIT 1);
    IF $key == NONE OR $key.state != "decrypt_only" { RETURN fn::error_result("SECRETS_TENANT_KEY_UNAVAILABLE", $p.language, { key_id: $p.key_id, state: $key.state }); };
    LET $used = (SELECT VALUE id FROM secrets_version WHERE scope_key = $key.scope_key AND key_id = $p.key_id LIMIT 1);
    IF array::len($used) > 0 { RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { key_id: $p.key_id, in_use: true }); };
    UPDATE $key.id SET state = "destroyed", wrapped = NONE, destroyed_at = time::now();
    RETURN fn::result_ok({ key_id: $p.key_id, destroyed: true });
} COMMENT "Détruit une ancienne clé d'organisation ({ key_id }) : seulement en decrypt_only et quand plus aucune version ne l'utilise ; matière effacée. Session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_rewrap_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rewrap_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            master_key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_keys_trusted() { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $retired = (SELECT key_id, scope_key, tenant FROM secrets_tenant_key WHERE state = "decrypt_only");
    LET $retired_ids = $retired.key_id;
    -- Versions encore scellées par une clé retirée
    LET $versions = (SELECT secret, tenant, number, key_id, envelope FROM secrets_version
        WHERE state != "destroyed" AND key_id IN $retired_ids LIMIT $p.limit);
    -- Clés d'organisation scellées par une autre clé maîtresse que l'active
    LET $keys = (SELECT key_id, tenant, wrapped, master_key_id FROM secrets_tenant_key
        WHERE state IN ["active", "decrypt_only"] AND master_key_id != $p.master_key_id LIMIT $p.limit);
    -- Clés retirées que plus aucune version n'utilise
    LET $unused = array::filter($retired, |$k| array::len(SELECT VALUE id FROM secrets_version WHERE scope_key = $k.scope_key AND key_id = $k.key_id LIMIT 1) = 0);
    RETURN fn::result_ok({ versions: $versions, keys: $keys, unused: $unused.key_id });
} COMMENT "Travail de rescellement ({ master_key_id : clé maîtresse active, limit }) : versions scellées par une clé retirée (avec leur enveloppe), clés d'organisation scellées par une autre clé maîtresse, clés retirées inutilisées (à détruire). Session système ou worker";

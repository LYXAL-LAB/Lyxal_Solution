-- ============================================================================
-- FONCTION : fn::catalogue_item_personnaliser
-- MODULE   : lyxal_catalogue
-- RÔLE     : Personnalisation d'un article maître par le locataire de la session (libellé,
--            code interne, disponibilité), sans modifier l'article maître partagé
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_personnaliser($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            item_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            libelle_personnalise: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }] },
            code_interne_client: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            libelle_personnalise: { pipeline: [{ rule: "trim" }] },
            code_interne_client: { pipeline: [{ rule: "trim" }] }
        },
        unknown_keys: "keep"
    }, 20);
    LET $language = $p.language;
    IF $p.libelle_personnalise == NONE AND $p.code_interne_client == NONE AND $p.enabled == NONE {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $language, { fields: {
            libelle_personnalise: ["CORE_VALIDATION_COMBINATION"],
            code_interne_client: ["CORE_VALIDATION_COMBINATION"],
            enabled: ["CORE_VALIDATION_COMBINATION"]
        } });
    };

    -- Locataire de la session
    LET $caller_role = IF $token != NONE AND $token.role != NONE { string::trim($token.role) } ELSE IF $auth != NONE AND $auth.role != NONE { string::trim($auth.role) } ELSE { NONE };
    LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { string::trim($token.tenant_id) } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { string::trim($auth.tenant_id) } ELSE { NONE };
    IF $caller_role != "tenant_user" OR $caller_tenant == NONE OR string::len($caller_tenant) == 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
            field: "role",
            notice: "La personnalisation d'un article exige une identité cliente (tenant_user) rattachée à un locataire."
        });
    };

    -- Article maître seulement : un article privé se modifie directement par son locataire
    LET $item = (SELECT id, is_custom FROM ONLY $p.item_id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $p.item_id });
    };
    IF $item.is_custom != false {
        RETURN fn::error_result("CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER", $language, { id: <string> $p.item_id });
    };

    LET $changes = object::from_entries(object::entries({
        libelle_personnalise: $p.libelle_personnalise,
        code_interne_client: $p.code_interne_client,
        enabled: $p.enabled
    }).filter(|$e| $e[1] != NONE));
    LET $existing = (SELECT VALUE id FROM ONLY catalogue_item_personnalisation WHERE item = $item.id AND tenant_id = $caller_tenant LIMIT 1);
    LET $saved = IF $existing != NONE {
        UPDATE ONLY $existing MERGE object::extend($changes, { updated_at: time::now() })
    } ELSE {
        CREATE ONLY catalogue_item_personnalisation CONTENT object::extend($changes, { item: $item.id })
    };
    IF $saved == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item_personnalisation" });
    };
    RETURN fn::result_ok($saved);
} COMMENT "Crée ou met à jour la personnalisation d'un article maître (libellé, code interne, disponibilité) pour le seul locataire de la session ; l'article maître partagé n'est jamais modifié ; un article privé se modifie directement (CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER)";

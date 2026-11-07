-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/mapping/error_mapping_disable.surql
-- Fonction : fn::error_mapping_disable
--
-- Désactive une correspondance externe sans la supprimer.
--
-- Paramètres
--   mapping_id (requis), language
--
-- Valeur renvoyée : fn::result_ok({ id, disabled })
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_MAPPING_NOT_FOUND : correspondance inconnue
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_mapping_disable(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        mapping_id: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["error_external_mapping"] } }], required: true },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF (SELECT VALUE id FROM $p.mapping_id)[0] IS NONE { RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $p.language, { mapping_id: $p.mapping_id }); };
    LET $updated = UPDATE ONLY $p.mapping_id SET enabled = false;
    IF $updated IS NONE { RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_external_mapping" }); };
    RETURN fn::result_ok({ id: $p.mapping_id, disabled: true });
}
COMMENT "Désactive une correspondance externe sans la supprimer."
PERMISSIONS FULL;

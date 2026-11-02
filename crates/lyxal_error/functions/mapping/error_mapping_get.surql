-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/mapping/error_mapping_get.surql
-- Fonction : fn::error_mapping_get
--
-- Renvoie une correspondance externe par son identifiant.
--
-- Paramètres
--   mapping_id (requis, enregistrement error_external_mapping), language
--
-- Valeur renvoyée : fn::result_ok(correspondance)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_MAPPING_NOT_FOUND : correspondance inconnue
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_mapping_get(
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
    LET $mapping = (SELECT * FROM $p.mapping_id)[0];
    IF $mapping IS NONE { RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $p.language, { mapping_id: $p.mapping_id }); };
    RETURN fn::result_ok($mapping);
}
COMMENT "Renvoie une correspondance externe par son identifiant."
PERMISSIONS FULL;

-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/occurrence/error_occurrence_get.surql
-- Fonction : fn::error_occurrence_get
--
-- Renvoie une occurrence d'erreur par son identifiant.
--
-- Paramètres
--   occurrence_id (requis, enregistrement error_occurrence), language
--
-- Valeur renvoyée : fn::result_ok(occurrence)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_OCCURRENCE_NOT_FOUND : occurrence inconnue
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_occurrence_get(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        occurrence_id: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["error_occurrence"] } }], required: true },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $occurrence = (SELECT * FROM $p.occurrence_id)[0];
    IF $occurrence IS NONE { RETURN fn::error_result("ERROR_OCCURRENCE_NOT_FOUND", $p.language, { occurrence_id: $p.occurrence_id }); };
    RETURN fn::result_ok($occurrence);
}
COMMENT "Renvoie une occurrence d'erreur par son identifiant."
PERMISSIONS FULL;

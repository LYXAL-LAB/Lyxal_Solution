-- ============================================================================
-- FONCTION : fn::ingestion_resolve_manufacturer
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution d'un fabricant ou d'une marque par ses alias
-- APPEL    : interne (worker, ligne à ligne), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_manufacturer($params: object) {
    LET $check = fn::validation_required_string($params.raw_name, 1, 255);
    IF !$check.valid {
        RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", NONE, { field: "raw_name", reason: $check.code });
    };
    LET $raw_name = fn::sanitize_uppercase(fn::sanitize_trim($check.value));

    LET $hit = (SELECT canonical_name, holding_or_group, is_verified FROM ONLY ingestion_manufacturer_alias WHERE raw_alias = $raw_name LIMIT 1);
    IF $hit != NONE {
        RETURN fn::result_ok({ canonical_name: $hit.canonical_name, holding_or_group: $hit.holding_or_group, is_verified: $hit.is_verified, resolved: true });
    };

    -- Non résolu : le nom normalisé reste exploitable par la qualification
    RETURN fn::result_ok({ canonical_name: $raw_name, holding_or_group: NONE, is_verified: false, resolved: false });
} COMMENT "Résout un fabricant ou une marque via ingestion_manufacturer_alias ; un nom inconnu est renvoyé normalisé avec resolved = false";

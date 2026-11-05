-- ============================================================================
-- FONCTION : fn::ingestion_resolve_unit
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution d'une unité fournisseur vers le référentiel base_unite
-- APPEL    : interne (worker, ligne à ligne), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_unit($params: object) {
    LET $check = fn::validation_required_string($params.raw_unit, 1, 64);
    IF !$check.valid {
        RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", NONE, { raw_unit: $params.raw_unit, reason: $check.code });
    };
    LET $raw_unit = fn::sanitize_uppercase(fn::sanitize_trim($check.value));

    -- 1. Alias configurés, puis 2. référentiel officiel base_unite
    LET $alias = (SELECT VALUE canonical_unit FROM ONLY ingestion_unit_alias WHERE raw_alias = $raw_unit LIMIT 1);
    IF $alias != NONE {
        RETURN fn::result_ok({ canonical_code: $alias, resolved: true });
    };
    LET $base = (SELECT VALUE code FROM ONLY base_unite WHERE code = $raw_unit LIMIT 1);
    IF $base != NONE {
        RETURN fn::result_ok({ canonical_code: $base, resolved: true });
    };

    RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", NONE, { raw_unit: $raw_unit });
} COMMENT "Résout une unité brute via ingestion_unit_alias puis base_unite ; INGESTION_UNIT_UNRESOLVED si inconnue";

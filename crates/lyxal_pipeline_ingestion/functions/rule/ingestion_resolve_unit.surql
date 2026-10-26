-- ============================================================================
-- FONCTION : fn::ingestion_resolve_unit
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution d'une unité brute vers le référentiel universel base_unite
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_unit($params: object) {
    LET $raw_unit = IF $params.raw_unit != NONE { string::uppercase(string::trim($params.raw_unit)) } ELSE { "" };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF string::len($raw_unit) == 0 {
        RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", $language, { raw_unit: $raw_unit });
    };

    -- 1. Recherche dans les alias dynamiques configurés
    LET $alias_res = (SELECT canonical_unit FROM ingestion_unit_alias WHERE raw_alias = $raw_unit);
    IF array::len($alias_res) > 0 {
        RETURN fn::result_ok({
            canonical_code: $alias_res[0].canonical_unit,
            resolved: true
        });
    };

    -- 2. Recherche directe dans le référentiel officiel base_unite
    LET $base_res = (SELECT code FROM base_unite WHERE code = $raw_unit);
    IF array::len($base_res) > 0 {
        RETURN fn::result_ok({
            canonical_code: $base_res[0].code,
            resolved: true
        });
    };

    -- 3. Échec de résolution
    RETURN fn::error_result("INGESTION_UNIT_UNRESOLVED", $language, { raw_unit: $raw_unit });
} COMMENT "Résout une unité brute via ingestion_unit_alias et base_unite";

-- ============================================================================
-- FONCTION : fn::ingestion_resolve_manufacturer
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution d'un nom de fabricant via les alias dynamiques configurés
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_resolve_manufacturer($params: object) {
    LET $raw_name = IF $params.raw_name != NONE { string::uppercase(string::trim($params.raw_name)) } ELSE { "" };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF string::len($raw_name) == 0 {
        RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", $language, { champ: "raw_name" });
    };

    LET $alias_res = (SELECT canonical_name, holding_or_group, is_verified FROM ingestion_manufacturer_alias WHERE raw_alias = $raw_name);
    IF array::len($alias_res) > 0 {
        LET $hit = $alias_res[0];
        RETURN fn::result_ok({
            canonical_name: $hit.canonical_name,
            holding_or_group: $hit.holding_or_group,
            is_verified: $hit.is_verified,
            resolved: true
        });
    };

    -- Retour non résolu mais exploitable pour la qualification
    RETURN fn::result_ok({
        canonical_name: $raw_name,
        holding_or_group: NONE,
        is_verified: false,
        resolved: false
    });
} COMMENT "Résout un fabricant ou marque industrielle via ingestion_manufacturer_alias";

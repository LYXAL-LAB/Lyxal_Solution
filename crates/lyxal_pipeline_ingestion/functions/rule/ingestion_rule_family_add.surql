-- ============================================================================
-- FONCTION : fn::ingestion_rule_family_add
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Déclaration ou mise à jour dynamique d'une famille de produits BTP
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rule_family_add($params: object) {
    LET $code = string::uppercase(string::trim($params.code));
    LET $label = string::trim($params.label);
    LET $keywords = IF $params.keywords != NONE { $params.keywords } ELSE { [] };
    LET $standard_unit = IF $params.standard_unit != NONE { string::uppercase(string::trim($params.standard_unit)) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF string::len($code) < 2 {
        RETURN fn::error_result("INGESTION_RULE_FAMILY_INVALID", $language, { code: $code });
    };

    LET $rec_id = <record> string::concat('ingestion_family_rule:⟨', $code, '⟩');

    UPSERT $rec_id CONTENT {
        code: $code,
        label: $label,
        keywords: $keywords,
        standard_unit: $standard_unit,
        updated_at: time::now()
    };

    RETURN fn::result_ok($code);
} COMMENT "Ajoute ou configure une famille de produits sans recompilation du moteur Rust";

-- ============================================================================
-- FONCTION : fn::ingestion_rule_spec_add
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Déclaration ou mise à jour d'une spécification technique patronne
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rule_spec_add($params: object) {
    LET $key = string::uppercase(string::trim($params.technical_identity_key));
    LET $family = string::uppercase(string::trim($params.family_code));
    LET $title = string::trim($params.generic_title);
    LET $dims = IF $params.nominal_dimensions != NONE { $params.nominal_dimensions } ELSE { NONE };
    LET $tols = IF $params.tolerances != NONE { $params.tolerances } ELSE { { length_tol_mm: 5.0, width_tol_mm: 5.0, height_tol_mm: 1.0, weight_tol_pct: 5.0 } };
    LET $weight = IF $params.nominal_weight != NONE { <float> $params.nominal_weight } ELSE { NONE };
    LET $norm = IF $params.standard_norm != NONE { string::trim($params.standard_norm) } ELSE { NONE };
    LET $fire = IF $params.fire_rating != NONE { string::trim($params.fire_rating) } ELSE { NONE };
    LET $features = IF $params.required_features != NONE { $params.required_features } ELSE { {} };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF string::len($key) < 3 {
        RETURN fn::error_result("INGESTION_SPEC_INVALID", $language, { technical_identity_key: $key });
    };

    LET $rec_id = <record> string::concat('ingestion_specification:⟨', $key, '⟩');

    UPSERT $rec_id CONTENT {
        technical_identity_key: $key,
        family_code: $family,
        generic_title: $title,
        nominal_dimensions: $dims,
        tolerances: $tols,
        nominal_weight: $weight,
        standard_norm: $norm,
        fire_rating: $fire,
        required_features: $features,
        updated_at: time::now()
    };

    RETURN fn::result_ok($key);
} COMMENT "Ajoute ou met à jour une spécification technique patronne avec tolérances et critères de rapprochement";

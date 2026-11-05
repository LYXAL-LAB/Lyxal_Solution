-- ============================================================================
-- FONCTION : fn::ingestion_rules_load
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Chargement des référentiels de regroupement technique
-- APPEL    : interne (moteur de regroupement technique), sans paramètre
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rules_load($params: object) {
    RETURN fn::result_ok({
        families: (SELECT code, label, keywords, standard_unit FROM ingestion_family_rule ORDER BY code),
        specifications: (SELECT technical_identity_key, family_code, generic_title, nominal_dimensions, tolerances,
                IF nominal_weight != NONE { { net_weight_kg: nominal_weight } } ELSE { NONE } AS nominal_weight, standard_norm, fire_rating, required_features
            FROM ingestion_specification ORDER BY technical_identity_key),
        substitutions: (SELECT rule_id, source_mfg AS source_manufacturer, source_ref, target_mfg AS target_manufacturer, target_ref,
                system_scope, certification_body, certification_ref AS certification_reference, <string> valid_until AS valid_until, is_revoked, revocation_reason
            FROM ingestion_substitution_rule ORDER BY rule_id)
    });
} COMMENT "Retourne les familles de produits, les spécifications patronnes et les règles de substitution configurées";

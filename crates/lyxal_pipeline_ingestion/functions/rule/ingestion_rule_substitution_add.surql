-- ============================================================================
-- FONCTION : fn::ingestion_rule_substitution_add
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Déclaration ou mise à jour d'une règle de substitution contextualisée
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_rule_substitution_add($params: object) {
    LET $rule_id = string::uppercase(string::trim($params.rule_id));
    LET $source_mfg = string::uppercase(string::trim($params.source_mfg));
    LET $source_ref = string::trim($params.source_ref);
    LET $target_mfg = string::uppercase(string::trim($params.target_mfg));
    LET $target_ref = string::trim($params.target_ref);
    LET $system_scope = string::uppercase(string::trim($params.system_scope));
    LET $certification_body = string::uppercase(string::trim($params.certification_body));
    LET $certification_ref = string::trim($params.certification_ref);
    LET $valid_until = <datetime> $params.valid_until;
    LET $is_revoked = IF $params.is_revoked != NONE { <bool> $params.is_revoked } ELSE { false };
    LET $revocation_reason = IF $params.revocation_reason != NONE { <string> $params.revocation_reason } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF string::len($rule_id) < 3 {
        RETURN fn::error_result("INGESTION_SUBSTITUTION_RULE_INVALID", $language, { rule_id: $rule_id });
    };

    LET $rec_id = <record> string::concat('ingestion_substitution_rule:⟨', $rule_id, '⟩');

    UPSERT $rec_id CONTENT {
        rule_id: $rule_id,
        source_mfg: $source_mfg,
        source_ref: $source_ref,
        target_mfg: $target_mfg,
        target_ref: $target_ref,
        system_scope: $system_scope,
        certification_body: $certification_body,
        certification_ref: $certification_ref,
        valid_until: $valid_until,
        is_revoked: $is_revoked,
        revocation_reason: $revocation_reason,
        updated_at: time::now()
    };

    RETURN fn::result_ok($rule_id);
} COMMENT "Ajoute ou met à jour une règle de substitution contextualisée et révocable";

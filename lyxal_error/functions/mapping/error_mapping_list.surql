-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_list                                                 │
-- │  Liste les règles de correspondance filtrées par fournisseur            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_mapping_list(
    $provider: option<string>
) {
    LET $clean_provider = IF $provider != NONE AND string::len(string::trim($provider)) > 0 {
        string::lowercase(string::trim($provider))
    } ELSE {
        NONE
    };

    LET $list = IF $clean_provider != NONE {
        SELECT * FROM error_external_mapping WHERE provider = $clean_provider ORDER BY priority ASC
    } ELSE {
        SELECT * FROM error_external_mapping ORDER BY provider ASC, priority ASC
    };

    RETURN fn::result_ok($list);
} COMMENT "Liste et filtre les règles de correspondance externes au format universel";

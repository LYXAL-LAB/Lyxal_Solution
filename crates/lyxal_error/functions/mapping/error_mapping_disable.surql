-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_disable                                              │
-- │  Désactive logiquement une règle de correspondance d'erreur externe     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_mapping_disable(
    $params: any
) {
    LET $language = IF type::is::object($params) AND $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = IF type::is::record($params) {
        $params
    } ELSE IF type::is::string($params) {
        $params
    } ELSE IF type::is::object($params) {
        $params.mapping_id ?? $params.id
    } ELSE {
        NONE
    };

    LET $mapping_id = IF type::is::record($raw_id) {
        $raw_id
    } ELSE IF type::is::string($raw_id) {
        IF string::starts_with($raw_id, "error_external_mapping:") {
            type::thing("error_external_mapping", string::slice($raw_id, 23))
        } ELSE {
            type::thing("error_external_mapping", $raw_id)
        }
    } ELSE {
        NONE
    };

    IF $mapping_id == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "mapping_id" });
    };

    LET $existing = SELECT VALUE id FROM $mapping_id;
    IF array::len($existing) == 0 {
        RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $language, { mapping_id: $mapping_id });
    };

    UPDATE $mapping_id SET enabled = false, updated_at = time::now();
    RETURN fn::result_ok({ disabled: true, id: $mapping_id });
} COMMENT "Désactive logiquement une règle de correspondance d'erreur externe";

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_get                                                  │
-- │  Lecture d'une règle de correspondance d'erreur externe par son ID      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_mapping_get(
    $params: any
) {
    LET $language = IF type::is::object($params) AND $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = IF type::is::object($params) {
        $params.mapping_id ?? $params.id
    } ELSE {
        $params
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

    LET $res = SELECT * FROM $mapping_id;
    IF array::len($res) == 0 {
        RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $language, { mapping_id: $mapping_id });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'un mapping d'erreur externe au format universel";

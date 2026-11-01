-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::error_mapping_get                                                  â”‚
-- â”‚  Lecture d'une rÃ¨gle de correspondance d'erreur externe par son ID      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::error_mapping_get(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = $params.mapping_id ?? $params.id;
    LET $raw_str = IF $raw_id != NONE { string::trim(<string>$raw_id) } ELSE { "" };
    LET $id_part = string::replace($raw_str, "error_external_mapping:", "");

    LET $mapping_id = IF type::is_record($raw_id) {
        $raw_id
    } ELSE IF string::len($id_part) > 0 {
        type::record("error_external_mapping", $id_part)
    } ELSE {
        NONE
    };

    IF $mapping_id == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "mapping_id" });
    };

    LET $res = SELECT * FROM error_external_mapping WHERE id = $mapping_id;
    IF array::len($res) == 0 {
        RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $language, { mapping_id: <string>$mapping_id });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "RÃ©cupÃ¨re les dÃ©tails d'un mapping d'erreur externe au format universel";

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_type_get                                                 │
-- │  Récupération d'un type d'unité de mesure par id ou par code            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_type_get($params: object) {
    LET $id = $params.id;
    LET $raw_code = $params.code;
    LET $language = IF $params.language != NONE AND string::len(string::trim($params.language)) > 0 {
        string::lowercase(string::trim($params.language))
    } ELSE {
        "fr"
    };

    LET $record = IF $id != NONE {
        SELECT * FROM ONLY $id
    } ELSE IF $raw_code != NONE AND string::len(string::trim($raw_code)) > 0 {
        LET $code = string::uppercase(string::trim($raw_code));
        SELECT * FROM base_unite_type WHERE code = $code LIMIT 1
    } ELSE {
        NONE
    };

    LET $found = IF type::is_array($record) {
        IF array::len($record) > 0 { $record[0] } ELSE { NONE }
    } ELSE {
        $record
    };

    IF $found == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: $id, code: $raw_code });
    };

    RETURN fn::result_ok($found);
} COMMENT "Récupère un type d'unité de mesure par son identifiant ou son code technique";

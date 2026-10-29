-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_get                                                           │
-- │  Récupère la définition canonique brute d'une erreur par son code        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_get(
    $params: any
) {
    LET $code = IF type::is_string($params) {
        $params
    } ELSE IF type::is_object($params) {
        $params.code ?? $params.code_or_id ?? $params.id
    } ELSE {
        NONE
    };

    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        RETURN NONE;
    };

    LET $clean_code = string::uppercase(string::trim($code));

    LET $res = SELECT * FROM error_definition 
                WHERE (code = $clean_code OR id = type::record("error_definition", $clean_code))
                  AND enabled = true 
                LIMIT 1;

    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "Récupère la définition brute d'un code d'erreur canonique actif";

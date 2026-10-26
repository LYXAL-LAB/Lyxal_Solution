-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_get                                                           │
-- │  Récupère la définition canonique brute d'une erreur par son code      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_get(
    $code: option<string>
) {
    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        RETURN NONE;
    };

    LET $clean_code = string::uppercase(string::trim($code));

    LET $res = SELECT * FROM error_definition 
                WHERE code = $clean_code 
                  AND enabled = true 
                LIMIT 1;

    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "Récupère la définition brute d'un code d'erreur canonique actif";

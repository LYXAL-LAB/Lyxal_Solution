-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_setting                                                â”‚
-- â”‚  RÃ©cupÃ¨re la valeur d'une clÃ© de configuration systÃ¨me dans booking_setting â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_setting(
    $key_name: option<string>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DU PARAMÃˆTRE OBLIGATOIRE
    -- ------------------------------------------------------------------------
    IF $key_name == NONE OR string::len(string::trim($key_name)) == 0 {
        THROW "Parameter 'key_name' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. RECHERCHE DE LA CLÃ‰ NORMALISÃ‰E EN MINUSCULES
    -- ------------------------------------------------------------------------
    LET $clean_key = string::lowercase(string::trim($key_name));
    LET $res = SELECT VALUE value FROM booking_setting WHERE setting_key = $clean_key LIMIT 1;

    -- ------------------------------------------------------------------------
    -- 3. RETOUR DE LA VALEUR OU NONE
    -- ------------------------------------------------------------------------
    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re la valeur d'une clÃ© de configuration globale du systÃ¨me";

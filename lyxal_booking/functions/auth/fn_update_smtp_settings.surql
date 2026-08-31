-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_smtp_settings                                       â”‚
-- â”‚  Mise Ã  jour de la configuration SMTP globale dans booking_setting     â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_smtp_settings(
    $host: option<string>,
    $port: option<int>,
    $username: option<string>,
    $password_enc: option<string>,
    $from_email: option<string>,
    $from_name: option<string>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $host == NONE OR string::len(string::trim($host)) == 0 {
        THROW "Parameter 'host' is required";
    };
    IF $port == NONE OR $port <= 0 {
        THROW "Parameter 'port' is required and must be > 0";
    };

    -- ------------------------------------------------------------------------
    -- 2. Ã‰VALUATION PRÃ‰ALABLE DES VARIABLES DANS DES INSTRUCTIONS LET
    -- ------------------------------------------------------------------------
    LET $clean_host = string::trim($host);
    LET $clean_user = IF $username != NONE { string::trim($username) } ELSE { NONE };
    LET $clean_pass = IF $password_enc != NONE { string::trim($password_enc) } ELSE { NONE };
    LET $clean_email = IF $from_email != NONE { string::trim($from_email) } ELSE { NONE };
    LET $clean_name = IF $from_name != NONE { string::trim($from_name) } ELSE { NONE };

    LET $config_obj = {
        host: $clean_host,
        port: $port,
        username: $clean_user,
        password_enc: $clean_pass,
        from_email: $clean_email,
        from_name: $clean_name,
        updated_at: time::now()
    };

    -- ------------------------------------------------------------------------
    -- 3. PERSISTANCE DANS BOOKING_SETTING (setting_key = 'smtp_config')
    -- ------------------------------------------------------------------------
    LET $existing = SELECT VALUE id FROM booking_setting WHERE setting_key = 'smtp_config' LIMIT 1;
    IF array::len($existing) > 0 {
        UPDATE $existing[0] SET value = $config_obj, updated_at = time::now();
    } ELSE {
        CREATE booking_setting CONTENT {
            setting_key: 'smtp_config',
            value: $config_obj,
            updated_at: time::now()
        };
    };

    RETURN true;
} COMMENT "Met Ã  jour la configuration SMTP d'envoi d'e-mails dans les paramÃ¨tres gÃ©nÃ©raux";

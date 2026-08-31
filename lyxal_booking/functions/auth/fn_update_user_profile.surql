-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_user_profile                                        â”‚
-- â”‚  Met Ã  jour le profil et les prÃ©fÃ©rences d'un compte hÃ´te              â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_user_profile(
    $account_id: option<record<booking_account>>,
    $name: option<string>,
    $timezone: option<string>,
    $language: option<string>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $current = SELECT * FROM $account_id;
    IF array::len($current) == 0 {
        THROW "Account not found";
    };

    LET $acc = $current[0];
    LET $clean_name = IF $name != NONE AND string::len(string::trim($name)) > 0 { string::trim($name) } ELSE { $acc.name };
    LET $clean_tz = IF $timezone != NONE AND string::len(string::trim($timezone)) > 0 { string::trim($timezone) } ELSE { $acc.timezone };
    LET $clean_lang = IF $language != NONE { string::lowercase(string::trim($language)) } ELSE { $acc.language };

    UPDATE $account_id MERGE {
        name: $clean_name,
        timezone: $clean_tz,
        language: $clean_lang,
        updated_at: time::now()
    };

    RETURN SELECT * FROM $account_id;
} COMMENT "Met Ã  jour le nom d'affichage, le fuseau horaire et la langue d'un compte hÃ´te";

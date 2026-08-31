-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_user_timezone                                      â”‚
-- â”‚  Met Ã  jour le fuseau horaire prÃ©fÃ©rÃ© d'un compte utilisateur          â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_user_timezone(
    $account_id: option<record<booking_account>>,
    $timezone: option<string>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };
    IF $timezone == NONE OR string::len(string::trim($timezone)) == 0 {
        THROW "Parameter 'timezone' is required";
    };

    LET $clean_tz = string::trim($timezone);
    UPDATE $account_id SET timezone = $clean_tz, updated_at = time::now();

    RETURN true;
} COMMENT "Met Ã  jour le fuseau horaire configurÃ© pour un compte hÃ´te";

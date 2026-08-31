-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_user_username                                      â”‚
-- â”‚  Met Ã  jour le pseudo/username d'un compte hÃ´te avec contrÃ´le d'unicitÃ©â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_user_username(
    $account_id: option<record<booking_account>>,
    $username: option<string>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };
    IF $username == NONE OR string::len(string::trim($username)) == 0 {
        THROW "Parameter 'username' is required";
    };

    LET $clean_uname = string::lowercase(string::trim($username));

    -- ContrÃ´le d'unicitÃ© du nom d'utilisateur hors du compte courant
    LET $existing = SELECT VALUE id FROM booking_account 
                     WHERE username = $clean_uname 
                       AND id != $account_id 
                     LIMIT 1;

    IF array::len($existing) > 0 {
        THROW "Username is already taken by another account";
    };

    UPDATE $account_id SET username = $clean_uname, updated_at = time::now();
    RETURN true;
} COMMENT "Met Ã  jour le nom d'utilisateur d'un compte avec vÃ©rification de l'unicitÃ©";

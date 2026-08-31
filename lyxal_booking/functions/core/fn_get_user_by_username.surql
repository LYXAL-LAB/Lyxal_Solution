-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_user_by_username                                      â”‚
-- â”‚  RÃ©cupÃ¨re le profil public d'un compte hÃ´te par son nom d'utilisateur  â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_user_by_username(
    $username: option<string>
) {
    IF $username == NONE OR string::len(string::trim($username)) == 0 {
        THROW "Parameter 'username' is required";
    };

    LET $clean_uname = string::lowercase(string::trim($username));
    LET $res = SELECT id, name, username, email, avatar_url, timezone, role 
                 FROM booking_account 
                WHERE username = $clean_uname 
                  AND enabled = true 
                LIMIT 1;

    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re les informations d'un compte hÃ´te par son pseudo public";

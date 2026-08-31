-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_user_avatar_path                                   â”‚
-- â”‚  Met Ã  jour l'URL de l'image de profil/avatar d'un compte utilisateur  â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_user_avatar_path(
    $account_id: option<record<booking_account>>,
    $avatar_path: option<string>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $clean_avatar = IF $avatar_path != NONE { string::trim($avatar_path) } ELSE { NONE };
    UPDATE $account_id SET avatar_url = $clean_avatar, updated_at = time::now();

    RETURN true;
} COMMENT "Met Ã  jour l'URL de l'image d'avatar d'un compte hÃ´te";

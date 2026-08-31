-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_account_name_by_user                               â”‚
-- â”‚  Met Ã  jour le nom complet d'un compte utilisateur                     â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_account_name_by_user(
    $account_id: option<record<booking_account>>,
    $name: option<string>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        THROW "Parameter 'name' is required";
    };

    LET $clean_name = string::trim($name);
    UPDATE $account_id SET name = $clean_name, updated_at = time::now();

    RETURN true;
} COMMENT "Met Ã  jour le nom d'affichage d'un compte utilisateur";

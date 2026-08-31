-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_user_timezone                                         â”‚
-- â”‚  RÃ©cupÃ¨re le fuseau horaire prÃ©fÃ©rÃ© d'un compte utilisateur            â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_user_timezone(
    $account_id: option<record<booking_account>>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $res = SELECT VALUE timezone FROM $account_id;
    RETURN IF array::len($res) > 0 AND $res[0] != NONE { $res[0] } ELSE { 'UTC' };
} COMMENT "RÃ©cupÃ¨re le fuseau horaire configurÃ© d'un utilisateur";

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ fn::booking_cli_set_user_password                                        │
-- │ Mise à jour du hash mot de passe et réinitialisation des sessions        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cli_set_user_password($params: object) {
    LET $email = string::lowercase(string::trim($params.email));
    LET $password_hash = $params.password_hash;

    LET $target = (SELECT * FROM booking_account WHERE email = $email LIMIT 1);
    IF array::len($target) == 0 {
        RETURN fn::result_error("BOOKING_USER_NOT_FOUND", "fr", { email: $email });
    };
    LET $acc = $target[0];

    LET $updated = (UPDATE ONLY $acc.id SET password_hash = $password_hash, updated_at = time::now());

    DELETE booking_session WHERE account = $acc.id;

    RETURN fn::result_ok({
        account_id: $updated.id,
        email: $updated.email
    });
};

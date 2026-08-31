-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ fn::booking_cli_list_users                                               │
-- │ Listing typé des comptes utilisateurs pour la CLI                        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cli_list_users($params: object) {
    LET $accounts = (SELECT id, email, name, role, enabled, auth_provider, created_at FROM booking_account ORDER BY created_at ASC);
    RETURN fn::result_ok($accounts);
};

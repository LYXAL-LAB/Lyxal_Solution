-- ============================================================================
-- INDEX UNIQUES SYSTEMATIQUES DE LA TABLE BOOKING_ACCOUNT
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE INDEX OVERWRITE booking_account_email_unique
ON TABLE booking_account
FIELDS email
UNIQUE;

DEFINE INDEX OVERWRITE booking_account_username_unique
ON TABLE booking_account
FIELDS username
UNIQUE;

DEFINE INDEX OVERWRITE booking_account_oidc_issuer_sub_unique
ON TABLE booking_account
FIELDS oidc_issuer, oidc_sub
UNIQUE;

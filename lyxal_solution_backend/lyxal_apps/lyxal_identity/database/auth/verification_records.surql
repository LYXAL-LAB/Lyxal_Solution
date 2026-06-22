-- Table verification_records
DEFINE TABLE verification_records SCHEMAFULL;
DEFINE FIELD identifier ON TABLE verification_records TYPE string; -- email or phone
DEFINE FIELD code ON TABLE verification_records TYPE string;
DEFINE FIELD kind ON TABLE verification_records TYPE string ASSERT $value IN ['EmailVerification', 'PhoneVerification', 'ForgotPassword', 'BindEmail', 'BindPhone', 'SignIn', 'Register'];
DEFINE FIELD expires_at ON TABLE verification_records TYPE datetime;
DEFINE FIELD created_at ON TABLE verification_records TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_verif_id_kind ON TABLE verification_records COLUMNS identifier, kind;

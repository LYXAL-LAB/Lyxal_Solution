-- Table verification_statuses
DEFINE TABLE verification_statuses SCHEMAFULL;
DEFINE FIELD user ON TABLE verification_statuses TYPE record<users>;
DEFINE FIELD kind ON TABLE verification_statuses TYPE string;
DEFINE FIELD is_verified ON TABLE verification_statuses TYPE bool DEFAULT false;
DEFINE FIELD verified_at ON TABLE verification_statuses TYPE option<datetime>;
DEFINE FIELD created_at ON TABLE verification_statuses TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE verification_statuses TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_verif_status ON TABLE verification_statuses COLUMNS user, kind UNIQUE;

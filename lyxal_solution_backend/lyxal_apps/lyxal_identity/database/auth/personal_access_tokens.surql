-- Table personal_access_tokens
DEFINE TABLE personal_access_tokens SCHEMAFULL;
DEFINE FIELD user ON TABLE personal_access_tokens TYPE record<users>;
DEFINE FIELD name ON TABLE personal_access_tokens TYPE string;
DEFINE FIELD token_hash ON TABLE personal_access_tokens TYPE string;
DEFINE FIELD expires_at ON TABLE personal_access_tokens TYPE option<datetime>;
DEFINE FIELD last_used_at ON TABLE personal_access_tokens TYPE option<datetime>;
DEFINE FIELD created_at ON TABLE personal_access_tokens TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_pat_user ON TABLE personal_access_tokens COLUMNS user;
DEFINE INDEX idx_pat_token ON TABLE personal_access_tokens COLUMNS token_hash UNIQUE;

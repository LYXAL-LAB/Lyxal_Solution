-- Table subject_tokens
DEFINE TABLE subject_tokens SCHEMAFULL;
DEFINE FIELD user ON TABLE subject_tokens TYPE record<users>;
DEFINE FIELD application ON TABLE subject_tokens TYPE record<applications>;
DEFINE FIELD token_hash ON TABLE subject_tokens TYPE string;
DEFINE FIELD expires_at ON TABLE subject_tokens TYPE datetime;
DEFINE FIELD created_at ON TABLE subject_tokens TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_subject_token ON TABLE subject_tokens COLUMNS token_hash UNIQUE;

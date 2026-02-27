-- Table one_time_tokens
DEFINE TABLE one_time_tokens SCHEMAFULL;
DEFINE FIELD token_hash ON TABLE one_time_tokens TYPE string;
DEFINE FIELD data ON TABLE one_time_tokens TYPE object;
DEFINE FIELD expires_at ON TABLE one_time_tokens TYPE datetime;
DEFINE FIELD created_at ON TABLE one_time_tokens TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ott_token ON TABLE one_time_tokens COLUMNS token_hash UNIQUE;

DEFINE TABLE nonce SCHEMAFULL;
DEFINE FIELD value ON TABLE nonce TYPE string;
DEFINE FIELD expires_at ON TABLE nonce TYPE datetime;
DEFINE INDEX nonce_value ON TABLE nonce COLUMNS value UNIQUE;

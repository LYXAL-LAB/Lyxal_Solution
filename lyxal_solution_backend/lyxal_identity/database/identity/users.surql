-- Table users (Identity central)
DEFINE TABLE users SCHEMAFULL;
DEFINE FIELD username ON TABLE users TYPE option<string>;
DEFINE FIELD primary_email ON TABLE users TYPE option<string>;
DEFINE FIELD is_email_verified ON TABLE users TYPE bool DEFAULT false;
DEFINE FIELD primary_phone ON TABLE users TYPE option<string>;
DEFINE FIELD is_phone_verified ON TABLE users TYPE bool DEFAULT false;
DEFINE FIELD name ON TABLE users TYPE option<string>;
DEFINE FIELD avatar ON TABLE users TYPE option<string>;
DEFINE FIELD password_hash ON TABLE users TYPE option<string>;
DEFINE FIELD last_sign_in_at ON TABLE users TYPE option<datetime>;
DEFINE FIELD created_at ON TABLE users TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE users TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_user_username ON TABLE users COLUMNS username UNIQUE;
DEFINE INDEX idx_user_email ON TABLE users COLUMNS primary_email UNIQUE;

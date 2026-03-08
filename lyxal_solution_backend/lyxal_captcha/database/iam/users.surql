DEFINE TABLE user SCHEMAFULL;
DEFINE FIELD name ON TABLE user TYPE string;
DEFINE FIELD email ON TABLE user TYPE string ASSERT is::email($value);
DEFINE FIELD email_verified ON TABLE user TYPE bool DEFAULT false;
DEFINE FIELD secret ON TABLE user TYPE string;
DEFINE FIELD password ON TABLE user TYPE string;
DEFINE INDEX user_name ON TABLE user COLUMNS name UNIQUE;
DEFINE INDEX user_email ON TABLE user COLUMNS email UNIQUE;
DEFINE INDEX user_secret ON TABLE user COLUMNS secret UNIQUE;

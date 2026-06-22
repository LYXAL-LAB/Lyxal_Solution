DEFINE TABLE user SCHEMAFULL;
DEFINE FIELD email ON user TYPE string ASSERT is::email($value);
DEFINE FIELD provider ON user TYPE option<string>;
DEFINE FIELD username ON user TYPE option<string>;
DEFINE FIELD createdAt ON user TYPE datetime DEFAULT time::now();
DEFINE INDEX userEmailIndex ON user FIELDS email UNIQUE;

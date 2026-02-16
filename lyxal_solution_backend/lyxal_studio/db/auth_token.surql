DEFINE TABLE auth_token SCHEMAFULL;
DEFINE FIELD token ON auth_token TYPE string DEFAULT rand::uuid();
DEFINE FIELD project ON auth_token TYPE record<project>;
DEFINE FIELD name ON auth_token TYPE string DEFAULT "";
DEFINE FIELD relation ON auth_token TYPE string ASSERT $value INSIDE ['viewers', 'editors', 'builders', 'administrators'] DEFAULT 'viewers';
DEFINE FIELD canClone ON auth_token TYPE bool DEFAULT true;
DEFINE FIELD canCopy ON auth_token TYPE bool DEFAULT true;
DEFINE FIELD createdAt ON auth_token TYPE datetime DEFAULT time::now();
DEFINE INDEX authTokenIndex ON auth_token FIELDS token UNIQUE;

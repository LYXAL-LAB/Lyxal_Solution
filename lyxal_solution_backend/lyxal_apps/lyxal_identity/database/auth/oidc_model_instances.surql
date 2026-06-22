-- Table oidc_model_instances (Sessions, Codes, Tokens)
DEFINE TABLE oidc_model_instances SCHEMAFULL;
DEFINE FIELD kind ON TABLE oidc_model_instances TYPE string ASSERT $value IN ['AuthorizationCode', 'RefreshToken', 'AccessToken', 'DeviceCode', 'BackchannelAuthenticationRequest'];
DEFINE FIELD jti ON TABLE oidc_model_instances TYPE string;
DEFINE FIELD data ON TABLE oidc_model_instances TYPE object; -- Stores the JSON payload of the OIDC model
DEFINE FIELD expires_at ON TABLE oidc_model_instances TYPE datetime;
DEFINE FIELD consumed_at ON TABLE oidc_model_instances TYPE option<datetime>;
DEFINE FIELD created_at ON TABLE oidc_model_instances TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_oidc_jti ON TABLE oidc_model_instances COLUMNS jti UNIQUE;
DEFINE INDEX idx_oidc_kind_jti ON TABLE oidc_model_instances COLUMNS kind, jti;

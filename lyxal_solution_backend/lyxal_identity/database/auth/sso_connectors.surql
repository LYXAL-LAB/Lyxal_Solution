-- Table sso_connectors
DEFINE TABLE sso_connectors SCHEMAFULL;
DEFINE FIELD connector_id ON TABLE sso_connectors TYPE string;
DEFINE FIELD connector_blueprint_id ON TABLE sso_connectors TYPE string;
DEFINE FIELD data ON TABLE sso_connectors TYPE object;
DEFINE FIELD is_enabled ON TABLE sso_connectors TYPE bool DEFAULT true;
DEFINE FIELD created_at ON TABLE sso_connectors TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_sso_connector_id ON TABLE sso_connectors COLUMNS connector_id UNIQUE;

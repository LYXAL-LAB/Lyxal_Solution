-- Table connectors (Social & Enterprise Connectors)
DEFINE TABLE connectors SCHEMAFULL;
DEFINE FIELD connector_id ON TABLE connectors TYPE string;
DEFINE FIELD connector_blueprint_id ON TABLE connectors TYPE string;
DEFINE FIELD data ON TABLE connectors TYPE object;
DEFINE FIELD created_at ON TABLE connectors TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_connector_id ON TABLE connectors COLUMNS connector_id UNIQUE;

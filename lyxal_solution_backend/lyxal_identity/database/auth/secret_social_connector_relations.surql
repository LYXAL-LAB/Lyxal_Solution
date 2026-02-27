-- Table secret_social_connector_relations
DEFINE TABLE secret_social_connector_relations SCHEMAFULL;
DEFINE FIELD secret ON TABLE secret_social_connector_relations TYPE record<secrets>;
DEFINE FIELD connector ON TABLE secret_social_connector_relations TYPE record<connectors>;
DEFINE FIELD created_at ON TABLE secret_social_connector_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ssoc_rel ON TABLE secret_social_connector_relations COLUMNS secret, connector UNIQUE;

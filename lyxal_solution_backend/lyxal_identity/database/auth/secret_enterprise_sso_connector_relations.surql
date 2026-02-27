-- Table secret_enterprise_sso_connector_relations
DEFINE TABLE secret_enterprise_sso_connector_relations SCHEMAFULL;
DEFINE FIELD secret ON TABLE secret_enterprise_sso_connector_relations TYPE record<secrets>;
DEFINE FIELD connector ON TABLE secret_enterprise_sso_connector_relations TYPE record<sso_connectors>;
DEFINE FIELD created_at ON TABLE secret_enterprise_sso_connector_relations TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_sessoc_rel ON TABLE secret_enterprise_sso_connector_relations COLUMNS secret, connector UNIQUE;

-- Table logto_configs
DEFINE TABLE logto_configs SCHEMAFULL;
DEFINE FIELD key ON TABLE logto_configs TYPE string;
DEFINE FIELD value ON TABLE logto_configs TYPE string;
DEFINE FIELD created_at ON TABLE logto_configs TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE logto_configs TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_config_key ON TABLE logto_configs COLUMNS key UNIQUE;

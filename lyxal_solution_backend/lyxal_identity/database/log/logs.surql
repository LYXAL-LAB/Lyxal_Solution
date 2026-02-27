-- Table logs (Audit Trail)
DEFINE TABLE logs SCHEMAFULL;
DEFINE FIELD key ON TABLE logs TYPE string;
DEFINE FIELD payload ON TABLE logs TYPE object;
DEFINE FIELD created_at ON TABLE logs TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_log_key ON TABLE logs COLUMNS key;
DEFINE INDEX idx_log_created_at ON TABLE logs COLUMNS created_at;

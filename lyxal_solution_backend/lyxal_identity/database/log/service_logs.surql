-- Table service_logs
DEFINE TABLE service_logs SCHEMAFULL;
DEFINE FIELD service_name ON TABLE service_logs TYPE string;
DEFINE FIELD level ON TABLE service_logs TYPE string ASSERT $value IN ['trace', 'debug', 'info', 'warn', 'error'];
DEFINE FIELD message ON TABLE service_logs TYPE string;
DEFINE FIELD data ON TABLE service_logs TYPE object;
DEFINE FIELD created_at ON TABLE service_logs TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_service_log_created ON TABLE service_logs COLUMNS created_at;


-- 4. Table: bridge_user_credentials
-- Actual encrypted credentials stored for a user/workspace
DEFINE TABLE bridge_user_credentials SCHEMAFULL;
DEFINE FIELD provider ON TABLE bridge_user_credentials TYPE record(bridge_providers);
DEFINE FIELD encrypted_data ON TABLE bridge_user_credentials TYPE string; -- Encrypted JSON of keys
DEFINE FIELD label ON TABLE bridge_user_credentials TYPE string;         -- e.g., 'My Airtable Pro Account'
DEFINE FIELD created_at ON TABLE bridge_user_credentials TYPE datetime DEFAULT time::now();

-- 5. Table: bridge_logs
-- Execution history of the bridge engine
DEFINE TABLE bridge_logs SCHEMALESS;
DEFINE FIELD provider ON TABLE bridge_logs TYPE record(bridge_providers);
DEFINE FIELD status ON TABLE bridge_logs TYPE string;              -- 'success', 'error'
DEFINE FIELD response_code ON TABLE bridge_logs TYPE int;
DEFINE FIELD executed_at ON TABLE bridge_logs TYPE datetime DEFAULT time::now();
DEFINE TABLE daily_token_usage SCHEMAFULL;

DEFINE FIELD tenant ON TABLE daily_token_usage TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD usage ON TABLE daily_token_usage TYPE int DEFAULT 0;
DEFINE FIELD user_token_usage ON TABLE daily_token_usage TYPE int DEFAULT 0;
DEFINE FIELD m2m_token_usage ON TABLE daily_token_usage TYPE int DEFAULT 0;
DEFINE FIELD date ON TABLE daily_token_usage TYPE datetime ASSERT $value != NONE;

DEFINE INDEX tenant_date ON TABLE daily_token_usage COLUMNS tenant, date UNIQUE;

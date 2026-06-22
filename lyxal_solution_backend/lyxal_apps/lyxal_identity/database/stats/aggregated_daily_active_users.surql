DEFINE TABLE aggregated_daily_active_users SCHEMAFULL;

DEFINE FIELD tenant ON TABLE aggregated_daily_active_users TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD activity_date ON TABLE aggregated_daily_active_users TYPE datetime ASSERT $value != NONE;
DEFINE FIELD user ON TABLE aggregated_daily_active_users TYPE record<users> ASSERT $value != NONE;
DEFINE FIELD activity_count ON TABLE aggregated_daily_active_users TYPE int ASSERT $value != NONE;

DEFINE INDEX tenant_date ON TABLE aggregated_daily_active_users COLUMNS tenant, activity_date;
DEFINE INDEX tenant_user_date ON TABLE aggregated_daily_active_users COLUMNS tenant, user, activity_date;

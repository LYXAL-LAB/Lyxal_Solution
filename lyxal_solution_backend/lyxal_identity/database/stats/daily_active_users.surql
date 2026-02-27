DEFINE TABLE daily_active_users SCHEMAFULL;

DEFINE FIELD tenant ON TABLE daily_active_users TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD user ON TABLE daily_active_users TYPE record<users> ASSERT $value != NONE;
DEFINE FIELD date ON TABLE daily_active_users TYPE datetime DEFAULT time::now();

DEFINE INDEX user_date ON TABLE daily_active_users COLUMNS user, date UNIQUE;
DEFINE INDEX tenant_date_user ON TABLE daily_active_users COLUMNS tenant, date, user;

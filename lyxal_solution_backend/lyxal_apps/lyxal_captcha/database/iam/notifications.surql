DEFINE TABLE notification SCHEMAFULL;
DEFINE FIELD sender ON TABLE notification TYPE record(user);
DEFINE FIELD receiver ON TABLE notification TYPE record(user);
DEFINE FIELD heading ON TABLE notification TYPE string;
DEFINE FIELD message ON TABLE notification TYPE string;
DEFINE FIELD read ON TABLE notification TYPE bool DEFAULT false;
DEFINE FIELD created_at ON TABLE notification TYPE datetime DEFAULT time::now();

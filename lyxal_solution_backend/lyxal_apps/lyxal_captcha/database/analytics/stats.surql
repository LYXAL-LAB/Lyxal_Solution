DEFINE TABLE pow_stat SCHEMAFULL;
DEFINE FIELD parent_config ON TABLE pow_stat TYPE record(config);
DEFINE FIELD type ON TABLE pow_stat TYPE string ASSERT $value IN ['fetched', 'solved', 'confirmed'];
DEFINE FIELD timestamp ON TABLE pow_stat TYPE datetime DEFAULT time::now();

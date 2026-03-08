DEFINE TABLE level SCHEMAFULL;
DEFINE FIELD parent_config ON TABLE level TYPE record(config);
DEFINE FIELD difficulty_factor ON TABLE level TYPE int;
DEFINE FIELD visitor_threshold ON TABLE level TYPE int;

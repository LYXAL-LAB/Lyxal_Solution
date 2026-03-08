DEFINE TABLE traffic_estimate SCHEMAFULL;
DEFINE FIELD parent_config ON TABLE traffic_estimate TYPE record(config);
DEFINE FIELD avg_traffic ON TABLE traffic_estimate TYPE int;
DEFINE FIELD peak_traffic ON TABLE traffic_estimate TYPE int;

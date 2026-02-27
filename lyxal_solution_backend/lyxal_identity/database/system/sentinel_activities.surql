-- Table sentinel_activities
DEFINE TABLE sentinel_activities SCHEMAFULL;
DEFINE FIELD kind ON TABLE sentinel_activities TYPE string;
DEFINE FIELD user ON TABLE sentinel_activities TYPE option<record<users>>;
DEFINE FIELD organization ON TABLE sentinel_activities TYPE option<record<organizations>>;
DEFINE FIELD data ON TABLE sentinel_activities TYPE object;
DEFINE FIELD created_at ON TABLE sentinel_activities TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_sentinel_kind ON TABLE sentinel_activities COLUMNS kind;
DEFINE INDEX idx_sentinel_created ON TABLE sentinel_activities COLUMNS created_at;

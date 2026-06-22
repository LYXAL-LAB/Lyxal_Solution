-- Table hooks (Webhooks)
DEFINE TABLE hooks SCHEMAFULL;
DEFINE FIELD name ON TABLE hooks TYPE string;
DEFINE FIELD event ON TABLE hooks TYPE string; -- e.g. User.Created
DEFINE FIELD url ON TABLE hooks TYPE string;
DEFINE FIELD config ON TABLE hooks TYPE object; -- headers, auth, etc.
DEFINE FIELD created_at ON TABLE hooks TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_hook_event ON TABLE hooks COLUMNS event;

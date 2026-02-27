-- Table resources (API Resources)
DEFINE TABLE resources SCHEMAFULL;
DEFINE FIELD name ON TABLE resources TYPE string;
DEFINE FIELD indicator ON TABLE resources TYPE string;
DEFINE FIELD description ON TABLE resources TYPE option<string>;
DEFINE FIELD created_at ON TABLE resources TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE resources TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_resource_indicator ON TABLE resources COLUMNS indicator UNIQUE;

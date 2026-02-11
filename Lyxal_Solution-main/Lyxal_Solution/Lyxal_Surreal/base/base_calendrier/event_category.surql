-- Catégorie d'événement 
DEFINE TABLE event_category SCHEMAFULL;
DEFINE FIELD code ON event_category TYPE string UNIQUE ASSERT $value != NONE;
DEFINE FIELD name ON event_category TYPE string ASSERT $value != NONE;
DEFINE FIELD color ON event_category TYPE string DEFAULT '#3498db';
DEFINE FIELD description ON event_category TYPE string;
DEFINE FIELD is_active ON event_category TYPE bool DEFAULT true;
DEFINE FIELD created_at ON event_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON event_category TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON event_category TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_event_category_code ON event_category FIELDS code;
DEFINE INDEX idx_event_category_active ON event_category FIELDS is_active;
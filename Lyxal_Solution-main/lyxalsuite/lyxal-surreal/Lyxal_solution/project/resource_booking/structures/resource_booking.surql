-- ======================================================================
-- TABLE : RESOURCE_BOOKING
-- ======================================================================
DEFINE TABLE resource_booking SCHEMAFULL
    COMMENT "Réservation de ressource";

-- Champs principaux
DEFINE FIELD id ON resource_booking TYPE record<resource_booking>;
DEFINE FIELD created_on ON resource_booking TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON resource_booking TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON resource_booking TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON resource_booking TYPE string;
DEFINE FIELD notes ON resource_booking TYPE string;

-- Relations
DEFINE FIELD resource_id ON resource_booking TYPE option<record<resource>>;
DEFINE FIELD project_id ON resource_booking TYPE option<record<project>>;
DEFINE FIELD project_task_id ON resource_booking TYPE option<record<project_task>>;
DEFINE FIELD user_id ON resource_booking TYPE option<record<user>>;

-- Dates
DEFINE FIELD from_date ON resource_booking TYPE datetime;
DEFINE FIELD to_date ON resource_booking TYPE datetime;

-- Configuration
DEFINE FIELD update_task_from_period ON resource_booking TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_resource_booking_resource ON resource_booking COLUMNS resource_id;
DEFINE INDEX idx_resource_booking_project ON resource_booking COLUMNS project_id;
DEFINE INDEX idx_resource_booking_task ON resource_booking COLUMNS project_task_id;
DEFINE INDEX idx_resource_booking_user ON resource_booking COLUMNS user_id;
DEFINE INDEX idx_resource_booking_dates ON resource_booking COLUMNS from_date, to_date;
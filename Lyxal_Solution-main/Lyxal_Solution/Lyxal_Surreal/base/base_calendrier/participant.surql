-- Participant
DEFINE TABLE participant SCHEMAFULL;
DEFINE FIELD name ON participant TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON participant TYPE string;
DEFINE FIELD phone ON participant TYPE string;
DEFINE FIELD user ON participant TYPE record<user>;
DEFINE FIELD partner ON participant TYPE record<partner>;
DEFINE FIELD is_active ON participant TYPE bool DEFAULT true;
DEFINE FIELD created_at ON participant TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON participant TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON participant TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_participant_email ON participant FIELDS email;
DEFINE INDEX idx_participant_user ON participant FIELDS user;
DEFINE INDEX idx_participant_partner ON participant FIELDS partner;
DEFINE INDEX idx_participant_active ON participant FIELDS is_active;
-- Anonymiseur de relation
DEFINE TABLE relationship_anonymizer SCHEMAFULL;
DEFINE FIELD name ON relationship_anonymizer TYPE string ASSERT $value != NONE;
DEFINE FIELD source_model ON relationship_anonymizer TYPE string ASSERT $value != NONE;
DEFINE FIELD target_model ON relationship_anonymizer TYPE string ASSERT $value != NONE;
DEFINE FIELD relationship_field ON relationship_anonymizer TYPE string ASSERT $value != NONE;
DEFINE FIELD anonymization_strategy_select ON relationship_anonymizer TYPE int DEFAULT 1; -- 1:Nullify, 2:Replace, 3:Cascade Delete, 4:Preserve
DEFINE FIELD replacement_strategy ON relationship_anonymizer TYPE string;
DEFINE FIELD cascade_depth ON relationship_anonymizer TYPE int DEFAULT 1;
DEFINE FIELD preserve_referential_integrity ON relationship_anonymizer TYPE bool DEFAULT true;
DEFINE FIELD conditions ON relationship_anonymizer TYPE string;
DEFINE FIELD is_bidirectional ON relationship_anonymizer TYPE bool DEFAULT false;
DEFINE FIELD priority ON relationship_anonymizer TYPE int DEFAULT 100;
DEFINE FIELD is_active ON relationship_anonymizer TYPE bool DEFAULT true;
DEFINE FIELD notes ON relationship_anonymizer TYPE string;
DEFINE FIELD created_at ON relationship_anonymizer TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON relationship_anonymizer TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON relationship_anonymizer TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_relationship_anonymizer_source ON relationship_anonymizer FIELDS source_model;
DEFINE INDEX idx_relationship_anonymizer_target ON relationship_anonymizer FIELDS target_model;
DEFINE INDEX idx_relationship_anonymizer_strategy ON relationship_anonymizer FIELDS anonymization_strategy_select;
DEFINE INDEX idx_relationship_anonymizer_active ON relationship_anonymizer FIELDS is_active;
DEFINE INDEX idx_relationship_anonymizer_priority ON relationship_anonymizer FIELDS priority;
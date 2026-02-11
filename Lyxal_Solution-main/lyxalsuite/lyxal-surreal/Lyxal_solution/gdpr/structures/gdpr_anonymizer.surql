-- Anonymiseur GDPR 
DEFINE TABLE gdpr_anonymizer SCHEMAFULL;
DEFINE FIELD name ON gdpr_anonymizer TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON gdpr_anonymizer TYPE string UNIQUE;
DEFINE FIELD anonymization_type_select ON gdpr_anonymizer TYPE int DEFAULT 1; -- 1:Masking, 2:Hashing, 3:Encryption, 4:Deletion, 5:Pseudonymization
DEFINE FIELD field_type ON gdpr_anonymizer TYPE string; -- Type de champ concerné
DEFINE FIELD anonymization_pattern ON gdpr_anonymizer TYPE string;
DEFINE FIELD replacement_value ON gdpr_anonymizer TYPE string;
DEFINE FIELD preserve_format ON gdpr_anonymizer TYPE bool DEFAULT true;
DEFINE FIELD preserve_length ON gdpr_anonymizer TYPE bool DEFAULT true;
DEFINE FIELD salt_value ON gdpr_anonymizer TYPE string;
DEFINE FIELD encryption_key ON gdpr_anonymizer TYPE string;
DEFINE FIELD is_reversible ON gdpr_anonymizer TYPE bool DEFAULT false;
DEFINE FIELD strength_level ON gdpr_anonymizer TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High
DEFINE FIELD description ON gdpr_anonymizer TYPE string;
DEFINE FIELD usage_examples ON gdpr_anonymizer TYPE string;
DEFINE FIELD is_active ON gdpr_anonymizer TYPE bool DEFAULT true;
DEFINE FIELD created_at ON gdpr_anonymizer TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_anonymizer TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_anonymizer TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_anonymizer_code ON gdpr_anonymizer FIELDS code;
DEFINE INDEX idx_gdpr_anonymizer_type ON gdpr_anonymizer FIELDS anonymization_type_select;
DEFINE INDEX idx_gdpr_anonymizer_field_type ON gdpr_anonymizer FIELDS field_type;
DEFINE INDEX idx_gdpr_anonymizer_active ON gdpr_anonymizer FIELDS is_active;
DEFINE INDEX idx_gdpr_anonymizer_reversible ON gdpr_anonymizer FIELDS is_reversible;

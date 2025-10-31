-- =============================================================================
-- MODULE: BASE SOUS MODULE : COMMUNICATION
-- TABLE: base_template (Template)
-- Templates de messages
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_template TYPE NORMAL SCHEMAFULL
COMMENT "Templates de messages"
PERMISSIONS FULL;

DEFINE FIELD name ON base_template TYPE string
COMMENT "Nom du template";
DEFINE FIELD subject ON base_template TYPE string
COMMENT "Sujet du template";
DEFINE FIELD media_type_select ON base_template TYPE int DEFAULT 1
COMMENT "Type de média"; -- 1:Email, 2:SMS, 3:Mail, 4:Fax, 5:Push
DEFINE FIELD model_name ON base_template TYPE string
COMMENT "Nom du modèle cible";
DEFINE FIELD language ON base_template TYPE record<base_language>
COMMENT "Langue du template";
DEFINE FIELD is_default ON base_template TYPE bool DEFAULT false
COMMENT "Est le template par défaut";
DEFINE FIELD is_active ON base_template TYPE bool DEFAULT true
COMMENT "Est actif";
DEFINE FIELD company ON base_template TYPE record<base_company>
COMMENT "Entreprise";
DEFINE FIELD created_at ON base_template TYPE datetime DEFAULT time::now()
COMMENT "Date de création";
DEFINE FIELD updated_at ON base_template TYPE datetime DEFAULT time::now()
COMMENT "Date de mise à jour";
DEFINE FIELD version ON base_template TYPE int DEFAULT 0
COMMENT "Version";

-- Index pour base_template
DEFINE INDEX idx_template_name ON base_template FIELDS name;
DEFINE INDEX idx_template_model ON base_template FIELDS model_name;
DEFINE INDEX idx_template_media_type ON base_template FIELDS media_type_select;
DEFINE INDEX idx_template_active ON base_template FIELDS is_active;
DEFINE INDEX idx_template_company ON base_template FIELDS company;
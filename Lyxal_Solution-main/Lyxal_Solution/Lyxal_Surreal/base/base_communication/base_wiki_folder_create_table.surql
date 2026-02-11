-- ======================================================================
-- MODULE : BASE  SOUS MODULE : COMMUNICATION
-- TABLE : BASE_WIKI_FOLDER
-- ======================================================================
DEFINE TABLE IF NOT EXISTS base_wiki_folder TYPE NORMAL SCHEMAFULL
    COMMENT "Dossier de wiki pour organisation"
    PERMISSIONS FULL;

-- Identification
DEFINE FIELD name ON base_wiki_folder TYPE string;
DEFINE FIELD description ON base_wiki_folder TYPE string;

-- Configuration
DEFINE FIELD sequence ON base_wiki_folder TYPE int DEFAULT 0;

-- Relations hiérarchiques
DEFINE FIELD parent_folder_id ON base_wiki_folder TYPE option<record<base_wiki_folder>>;
DEFINE FIELD wiki_folder_list ON base_wiki_folder TYPE array<record<base_wiki_folder>>;

-- Relations avec wikis
DEFINE FIELD wiki_list ON base_wiki_folder TYPE array<record<base_wiki>>;

-- Champs principaux

DEFINE FIELD created_on ON base_wiki_folder TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON base_wiki_folder TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_base_wiki_folder_name ON base_wiki_folder FIELDS name;
DEFINE INDEX idx_base_wiki_folder_parent ON base_wiki_folder FIELDS parent_folder_id;
DEFINE INDEX idx_base_wiki_folder_sequence ON base_wiki_folder FIELDS sequence;
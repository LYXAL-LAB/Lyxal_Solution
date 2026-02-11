-- ======================================================================
-- MODULE : BASE  SOUS MODULE : COMMUNICATION
-- TABLE : base_wiki 
-- Extension de la table wiki : project/wiki/structures/wiki.surql
-- ======================================================================
DEFINE TABLE IF NOT EXISTS base_wiki TYPE NORMAL SCHEMAFULL
    COMMENT "Wiki de projet pour documentation collaborative"
    PERMISSIONS FULL;

-- Identification
DEFINE FIELD title ON base_wiki TYPE string;
DEFINE FIELD content ON base_wiki TYPE string;
DEFINE FIELD sequence ON base_wiki TYPE int DEFAULT 0;

-- Relations

DEFINE FIELD folder_id ON base_wiki TYPE option<record<base_wiki_folder>>;
-- Champs principaux

DEFINE FIELD created_on ON base_wiki TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON base_wiki TYPE datetime DEFAULT time::now();



-- Index

DEFINE INDEX idx_base_wiki_title ON base_wiki FIELDS title;
DEFINE INDEX idx_base_wiki_folder ON base_wiki FIELDS folder_id;
DEFINE INDEX idx_base_wiki_sequence ON base_wiki FIELDS sequence;
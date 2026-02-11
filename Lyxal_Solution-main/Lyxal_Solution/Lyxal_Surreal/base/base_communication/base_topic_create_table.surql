-- ======================================================================
-- MODULE : BASE SOUS MODULE : COMMUNICATION
-- TABLE : TOPIC
-- Extension de la table topic : project/topic_projet/structures/topic.surql
-- ======================================================================
DEFINE TABLE IF NOT EXISTS base_topic TYPE NORMAL SCHEMAFULL
    COMMENT "Sujet/Topic de discussion"
    PERMISSIONS FULL ;

-- Identification
DEFINE FIELD name ON base_topic TYPE string;
DEFINE FIELD description ON base_topic TYPE string;

-- Configuration
DEFINE FIELD sequence ON base_topic TYPE int DEFAULT 0;
-- Champs principaux
DEFINE FIELD created_on ON base_topic TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON base_topic TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_base_topic_name ON base_topic FIELDS name;
DEFINE INDEX idx_base_topic_sequence ON base_topic FIELDS sequence;
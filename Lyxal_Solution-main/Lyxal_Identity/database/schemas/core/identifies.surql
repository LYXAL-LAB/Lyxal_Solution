-- ============================================================
-- RELATION: identifies (email_hash -> identity)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE identifies TYPE RELATION 
    IN email_hash
    OUT identity
SCHEMAFULL
COMMENT "Relation : Un hash d'email identifie une identité"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS ADDITIONNELS (sur la relation)

DEFINE FIELD IF NOT EXISTS verified ON TABLE identifies 
    TYPE bool 
    DEFAULT false
    COMMENT "Si l'email a été vérifié";

DEFINE FIELD IF NOT EXISTS verified_at ON TABLE identifies 
    TYPE option<datetime>
    COMMENT "Date de vérification de l'email";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE identifies 
    TYPE datetime 
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création de la liaison";

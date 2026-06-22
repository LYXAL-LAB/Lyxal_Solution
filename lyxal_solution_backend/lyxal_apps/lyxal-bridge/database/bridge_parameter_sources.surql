-- Définition de la table des sources de paramètres
DEFINE TABLE IF NOT EXISTS bridge_parameter_sources 
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Sources de données pour les paramètres (Statique, Utilisateur, Auth, etc.)";

-- Définition des champs de la table
DEFINE FIELD IF NOT EXISTS identity ON TABLE bridge_parameter_sources 
    TYPE object 
    DEFAULT {}
    COMMENT "Identité de la source";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE bridge_parameter_sources 
        TYPE string
        ASSERT $value != "" AND $value != NONE
        COMMENT "Nom de la source (ex: 'static', 'user', 'auth')";

DEFINE FIELD IF NOT EXISTS affichage ON TABLE bridge_parameter_sources 
    TYPE object 
    DEFAULT {}
    COMMENT "Affichage de la source";
        
    DEFINE FIELD IF NOT EXISTS affichage.display_name ON TABLE bridge_parameter_sources 
        TYPE string
        ASSERT $value != "" AND $value != NONE
        COMMENT "Nom d'affichage de la source (ex: 'Valeur Fixe', 'Saisie Utilisateur')";

DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_parameter_sources 
    TYPE object 
    DEFAULT {}
    COMMENT "Statut de la source";
        
    DEFINE FIELD IF NOT EXISTS status.status ON TABLE bridge_parameter_sources 
        TYPE record<bridge_status> 
        DEFAULT bridge_status:active
        COMMENT "Statut de la source";

-- Définition des index de la table
DEFINE INDEX IF NOT EXISTS src_name_idx ON TABLE bridge_parameter_sources 
    FIELDS identity.name 
    UNIQUE
    COMMENT "Index unique sur le nom de la source";
-- Catalogue des actions disponibles par provider (ex: "Create Record", "List Emails")
DEFINE TABLE IF NOT EXISTS bridge_operations 
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Catalogue des opérations/actions par provider";

---- Fields de la table ---- 

    -- Relations (Liaisons)
    DEFINE FIELD IF NOT EXISTS relations ON TABLE bridge_operations 
        TYPE object
        DEFAULT {}
        COMMENT "Liaisons avec les autres tables";

        DEFINE FIELD IF NOT EXISTS relations.provider_id ON TABLE bridge_operations 
            TYPE record<bridge_providers>
            ASSERT $value != NONE
            COMMENT "Lien vers le provider propriétaire";

    -- Identité technique
    DEFINE FIELD IF NOT EXISTS identity ON TABLE bridge_operations 
        TYPE object
        DEFAULT {}
        COMMENT "Identité technique de l'opération";

        DEFINE FIELD IF NOT EXISTS identity.name ON TABLE bridge_operations 
            TYPE string
            ASSERT $value != NONE 
                   AND string::is::alphanumeric(string::replace($value, "_", ""))  
                   AND $value ~ "^[a-z][a-z0-9_]*$" 
            COMMENT "Nom interne en snake_case (ex: list_records)";

        DEFINE FIELD IF NOT EXISTS identity.operation_id ON TABLE bridge_operations 
            TYPE uuid
            DEFAULT uuid::rand()
            READONLY
            COMMENT "ID unique d'opération pour le tracking";

    -- Affichage UI
    DEFINE FIELD IF NOT EXISTS affichage ON TABLE bridge_operations 
        TYPE object
        DEFAULT {}
        COMMENT "Informations d'affichage pour l'utilisateur";

        DEFINE FIELD IF NOT EXISTS affichage.display_name ON TABLE bridge_operations 
            TYPE string
            ASSERT $value != NONE AND string::len($value) >= 2 
            COMMENT "Nom lisible (ex: 'Créer un enregistrement')";

        DEFINE FIELD IF NOT EXISTS affichage.description ON TABLE bridge_operations 
            TYPE string
            DEFAULT ""
            COMMENT "Description de ce que fait l'action";

    -- Configuration d'Exécution
    DEFINE FIELD IF NOT EXISTS configuration ON TABLE bridge_operations 
        TYPE object
        DEFAULT {}
        COMMENT "Configuration technique de l'appel API";
        
        DEFINE FIELD IF NOT EXISTS configuration.method ON TABLE bridge_operations 
            TYPE record<bridge_operations_methods>
            COMMENT "Méthode HTTP à utiliser";

        DEFINE FIELD IF NOT EXISTS configuration.path ON TABLE bridge_operations 
            TYPE string
            COMMENT "Chemin de l'URL (ex: /v0/{baseId}/{table})";

        DEFINE FIELD IF NOT EXISTS configuration.parameters ON TABLE bridge_operations 
            TYPE array<object>
            DEFAULT []
            COMMENT "Tableau des paramètres. Exemple: [
                    { name: 'baseId', in: 'path', required: true },
                    { name: 'limit', in: 'query', default: 100 },
                    { name: 'X-API-Version', in: 'header', value: 'v1', is_static: true }]";

            -- Définition des objets à l'intérieur du tableau 
            DEFINE FIELD IF NOT EXISTS configuration.parameters.* ON TABLE bridge_operations 
                TYPE object
                DEFAULT {}
                COMMENT "Structure d'un paramètre individuel";

            -- Nom technique (ex: 'limit', 'Authorization')
            DEFINE FIELD IF NOT EXISTS configuration.parameters.*.name ON TABLE bridge_operations 
                TYPE string
                ASSERT $value != NONE
                COMMENT "Nom technique du paramètre";

            -- Emplacement (Où injecter la donnée dans reqwest)
            DEFINE FIELD IF NOT EXISTS configuration.parameters.*.in ON TABLE bridge_operations 
                TYPE string 
                ASSERT $value INSIDE ['query', 'header', 'path', 'cookie', 'body']
                COMMENT "Emplacement (Où injecter la donnée dans reqwest)";

            -- Type de source (D'où vient la valeur)
            DEFINE FIELD IF NOT EXISTS configuration.parameters.*.value_type ON TABLE bridge_operations 
                TYPE string 
                ASSERT $value INSIDE ['static', 'user', 'auth', 'expression']
                COMMENT "Type de source (D'où vient la valeur)";    

            -- Valeur par défaut ou valeur fixe (Optionnelle)
            DEFINE FIELD IF NOT EXISTS configuration.parameters.*.value ON TABLE bridge_operations 
                TYPE option<string>
                COMMENT "Valeur par défaut ou valeur fixe (Optionnelle)";

            -- Validation : Est-ce que le moteur Rust doit exiger cette donnée ?
            DEFINE FIELD IF NOT EXISTS configuration.parameters.*.required ON TABLE bridge_operations 
                TYPE boolean DEFAULT true
                COMMENT "Validation : Est-ce que le moteur Rust doit exiger cette donnée ?";

    -- Template JSON du corps de la requête
    DEFINE FIELD IF NOT EXISTS configuration.body_template ON TABLE bridge_operations 
        TYPE object
            DEFAULT {}
            COMMENT "Template JSON du corps de la requête";

    -- Hooks Rust à exécuter (pré/post requête)
    DEFINE FIELD IF NOT EXISTS configuration.hooks ON TABLE bridge_operations 
        TYPE array<string>
            DEFAULT []
            COMMENT "Liste des hooks Rust à appliquer (ex: ['hmac_sign', 'auto_paginate_cursor'])";

    -- Statut de l'opération
    DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_operations 
        TYPE object
        DEFAULT {}
        COMMENT "Status de l'opération";

        DEFINE FIELD IF NOT EXISTS status.status ON TABLE bridge_operations 
            TYPE record<bridge_status>
            DEFAULT bridge_status:active
            COMMENT "Status du provider";

        DEFINE FIELD IF NOT EXISTS status.etag ON TABLE bridge_operations 
            TYPE uuid
            READONLY
            DEFAULT ALWAYS uuid::rand()
            COMMENT "Etag du provider";

        DEFINE FIELD IF NOT EXISTS status.version ON TABLE bridge_operations 
            TYPE string
            DEFAULT "1.0.0"
            COMMENT "Version du provider";

    -- Horodatage
    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE bridge_operations 
        TYPE object
        DEFAULT {}
        COMMENT "Timestamp de l'opération";

        DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE bridge_operations 
            TYPE datetime
            READONLY
            DEFAULT time::now();

        DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE bridge_operations 
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now();

    -- Indexation pour performance
    DEFINE INDEX IF NOT EXISTS provider_op_idx ON TABLE bridge_operations 
        FIELDS relations.provider_id, identity.name UNIQUE;
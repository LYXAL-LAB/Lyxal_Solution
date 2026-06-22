-- Table: bridge_errors (Version Exhaustive)
DEFINE TABLE IF NOT EXISTS bridge_errors 
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Moteur de décision d'erreurs pour le Lyxal Bridge";

    -- 1. Relations (Le Qui)
    DEFINE FIELD IF NOT EXISTS relations ON TABLE bridge_errors 
        TYPE object DEFAULT {}
        COMMENT "Cible de la règle d'erreur";

        DEFINE FIELD IF NOT EXISTS relations.operation_id ON TABLE bridge_errors 
            TYPE option<record<bridge_operations>>
            COMMENT "ID de l'opération";

    -- 2. Déclencheurs (Le Quand)
    DEFINE FIELD IF NOT EXISTS triggers ON TABLE bridge_errors 
        TYPE object DEFAULT {}
        COMMENT "Conditions de déclenchement de la règle";

        DEFINE FIELD IF NOT EXISTS triggers.http_code ON TABLE bridge_errors 
            TYPE option<int>
            COMMENT "Le code HTTP (ex: 429, 500)";

        DEFINE FIELD IF NOT EXISTS triggers.body_pattern ON TABLE bridge_operations 
            TYPE option<string>
            COMMENT "Regex ou mot-clé à chercher dans le JSON de réponse (ex: 'rate_limit') ";

    -- 3. Réaction technique (Le Comment)
    DEFINE FIELD IF NOT EXISTS configuration ON TABLE bridge_errors 
        TYPE object DEFAULT {}
        COMMENT "Action technique à exécuter par le moteur Rust";

        DEFINE FIELD IF NOT EXISTS configuration.action ON TABLE bridge_errors 
            TYPE string
            ASSERT $value INSIDE ["retry", "stop", "ignore", "map", "circuit_break"]
            COMMENT "Action: retry, stop (crash), ignore (continus), map (remplace message), circuit_break (bloque le provider)";

        DEFINE FIELD IF NOT EXISTS configuration.mapped_message ON TABLE bridge_errors 
            TYPE option<string>
            COMMENT "Message d'erreur traduit pour l'utilisateur final";

    -- 4. Stratégie de Résilience (La Survie)
    DEFINE FIELD IF NOT EXISTS resilience ON TABLE bridge_errors 
        TYPE object DEFAULT {}
        COMMENT "Paramètres de survie (Retry/Backoff)";

        DEFINE FIELD IF NOT EXISTS resilience.max_attempts ON TABLE bridge_errors 
            TYPE int 
            DEFAULT 3
            COMMENT"Nombre max de tentative";

        DEFINE FIELD IF NOT EXISTS resilience.backoff_ms ON TABLE bridge_errors 
            TYPE int 
            DEFAULT 1000
            COMMENT"Délai d'attente entre les tentatives";

        DEFINE FIELD IF NOT EXISTS resilience.exponential ON TABLE bridge_errors 
            TYPE boolean 
            DEFAULT true
            COMMENT"Augmentation exponentielle du délai d'attente";

    -- 5. Status & Version (Le Quoi)
    DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_errors 
        TYPE object 
        DEFAULT {}
        COMMENT "Etat de la règle";

        DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE bridge_errors 
            TYPE boolean 
            DEFAULT true
            COMMENT"Statut de la règle";

        DEFINE FIELD IF NOT EXISTS status.severity ON TABLE bridge_errors 
            TYPE string 
            DEFAULT "error"
            ASSERT $value INSIDE ["info", "warning", "error", "critical"]
            COMMENT"Niveau de sévérité de la règle";

    -- 6. Horodatage
    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE bridge_errors 
        TYPE object 
        DEFAULT {}
        COMMENT "Horodatage de la règle";

        DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE bridge_errors 
            TYPE datetime 
            READONLY 
            DEFAULT time::now()
            COMMENT"Date de création de la règle";

        DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE bridge_errors 
            TYPE datetime 
            READONLY 
            DEFAULT ALWAYS time::now()
            COMMENT"Date de modification de la règle";

            
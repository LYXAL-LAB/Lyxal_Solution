DEFINE TABLE IF NOT EXISTS webhooks TYPE NORMAL SCHEMAFULL
    COMMENT "Configuration des abonnements aux webhooks tiers"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS target_url ON TABLE webhooks 
    TYPE string
    COMMENT "URL cible du webhook";

DEFINE FIELD IF NOT EXISTS secret ON TABLE webhooks 
    TYPE string
    COMMENT "Secret partagé pour la signature des payloads (HMAC)";

DEFINE FIELD IF NOT EXISTS active ON TABLE webhooks 
    TYPE bool 
    DEFAULT true
    COMMENT "État d'activation du webhook";

DEFINE FIELD IF NOT EXISTS events ON TABLE webhooks 
    TYPE array<string> 
    DEFAULT []
    COMMENT "Liste des types d'événements auxquels ce webhook est abonné";

DEFINE FIELD IF NOT EXISTS headers ON TABLE webhooks 
    TYPE object
    COMMENT "En-têtes HTTP personnalisés à inclure dans les requêtes";

DEFINE FIELD IF NOT EXISTS description ON TABLE webhooks 
    TYPE string
    COMMENT "Description ou note interne";

DEFINE FIELD IF NOT EXISTS created_by ON TABLE webhooks 
    TYPE string
    COMMENT "Créateur du webhook";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE webhooks 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE webhooks 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de dernière modification";

DEFINE FIELD IF NOT EXISTS last_delivered_at ON TABLE webhooks 
    TYPE datetime
    COMMENT "Date de la dernière livraison réussie";

DEFINE FIELD IF NOT EXISTS failure_count ON TABLE webhooks 
    TYPE int 
    DEFAULT 0
    COMMENT "Compteur d'échecs consécutifs";

DEFINE FIELD IF NOT EXISTS title ON TABLE webhooks 
    TYPE string 
    DEFAULT ''
    COMMENT "Titre ou nom lisible du webhook";

DEFINE INDEX IF NOT EXISTS idx_webhooks_active ON TABLE webhooks 
    COLUMNS active
    COMMENT "Index pour filtrer les webhooks actifs";

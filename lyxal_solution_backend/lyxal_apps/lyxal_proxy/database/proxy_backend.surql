---- Table proxy_backend : Les Cibles, Les serveurs réels vers lesquels le proxy envoie le trafic. ----

DEFINE TABLE IF NOT EXISTS proxy_backend
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Serveur cible réel appartenant à un cluster pour recevoir le trafic proxyfié";

---- Fields ----

-- Application --

DEFINE FIELD IF NOT EXISTS application ON TABLE proxy_backend 
    TYPE object
    DEFAULT {}
    COMMENT "Application propriétaire";

    DEFINE FIELD IF NOT EXISTS application.lyxal_proxy ON TABLE proxy_backend 
        TYPE record<lyxal_proxy>
        REFERENCE ON DELETE CASCADE
        COMMENT "Application lyxal_proxy propriétaire du backend";

-- Configuration --

DEFINE FIELD IF NOT EXISTS configuration ON TABLE proxy_backend
    TYPE object
    DEFAULT {}
    COMMENT "Configuration réseau du backend cible";

    DEFINE FIELD IF NOT EXISTS configuration.cluster_id ON TABLE proxy_backend
        TYPE record<proxy_cluster>
        REFERENCE ON DELETE CASCADE
        COMMENT "Le cluster auquel ce backend spécifque appartient";

    DEFINE FIELD IF NOT EXISTS configuration.host ON TABLE proxy_backend
        TYPE string
        ASSERT string::is_domain($value) OR string::is_ip($value)
        COMMENT "Host ou IP du serveur cible (ex: 127.0.0.1 ou server.local)";

    DEFINE FIELD IF NOT EXISTS configuration.port ON TABLE proxy_backend
        TYPE number
        ASSERT $value > 0 AND $value < 65535
        COMMENT "Port du serveur cible cible (ex: 8080)";

    DEFINE FIELD IF NOT EXISTS configuration.weight ON TABLE proxy_backend
        TYPE number
        ASSERT $value > 0 AND $value <= 1000
        DEFAULT 100
        COMMENT "Poids de ce backend pour la répartition de charge";

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE proxy_backend
    TYPE object
    DEFAULT {}
    COMMENT "État de fonctionnement et d'activation du backend";

    DEFINE FIELD IF NOT EXISTS status.enabled ON TABLE proxy_backend
        TYPE boolean
        DEFAULT true
        COMMENT "Si false, ce backend ne recevra plus de trafic même s'il est en bonne santé";

    DEFINE FIELD IF NOT EXISTS status.is_healthy ON TABLE proxy_backend
        TYPE boolean
        DEFAULT true
        COMMENT "Mis à jour automatiquement par le mécanisme de health check du proxy (Lyxal_proxy)";

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE proxy_backend 
    TYPE object
    DEFAULT {}
    COMMENT "Metadonnées horodatées";

    DEFINE FIELD timestamp.created_at ON TABLE proxy_backend 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date d'ajout du backend";

    DEFINE FIELD timestamp.updated_at ON TABLE proxy_backend
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Dernière modification de la configuration ou du status du backend";

---- Indexes ----

-- Contrainte : Un serveur/processus de backend spécifique ne peut appartenir qu'une seule fois au même cluster --
DEFINE INDEX idx_unique_cluster_address ON TABLE proxy_backend 
    FIELDS configuration.cluster_id, configuration.host, configuration.port
    UNIQUE
    COMMENT "Unicité de l'adresse IP/Port au sein d'un même groupe de cluster";

-- Index de performance pour trouver tous les backends d'un cluster très rapidement pour le moteur de routage --
DEFINE INDEX idx_backend_cluster ON TABLE proxy_backend 
    FIELDS configuration.cluster_id
    COMMENT "Index de jointure inversée pour récupérer tous les backends d'un cluster";

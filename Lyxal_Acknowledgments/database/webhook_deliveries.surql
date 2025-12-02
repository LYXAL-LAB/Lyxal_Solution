DEFINE TABLE IF NOT EXISTS webhook_deliveries TYPE NORMAL SCHEMAFULL
    COMMENT "Journal d'exécution et file d'attente des envois de webhooks"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS webhook_id ON TABLE webhook_deliveries 
    TYPE record<webhooks>
    COMMENT "Référence vers la configuration du webhook";

DEFINE FIELD IF NOT EXISTS event_type ON TABLE webhook_deliveries 
    TYPE string
    COMMENT "Type d'événement déclencheur";

DEFINE FIELD IF NOT EXISTS event_id ON TABLE webhook_deliveries 
    TYPE string
    COMMENT "ID unique de l'événement (UUID)";

DEFINE FIELD IF NOT EXISTS payload ON TABLE webhook_deliveries 
    TYPE object 
    DEFAULT {}
    COMMENT "Données JSON envoyées";

DEFINE FIELD IF NOT EXISTS status ON TABLE webhook_deliveries 
    TYPE string 
    DEFAULT 'pending' 
    ASSERT $value INSIDE ['pending', 'processing', 'delivered', 'failed', 'cancelled']
    COMMENT "État de la livraison";

DEFINE FIELD IF NOT EXISTS retry_count ON TABLE webhook_deliveries 
    TYPE int 
    DEFAULT 0
    COMMENT "Nombre de tentatives effectuées";

DEFINE FIELD IF NOT EXISTS max_retries ON TABLE webhook_deliveries 
    TYPE int 
    DEFAULT 6
    COMMENT "Nombre maximum de tentatives avant abandon";

DEFINE FIELD IF NOT EXISTS priority ON TABLE webhook_deliveries 
    TYPE int 
    DEFAULT 0
    COMMENT "Priorité de traitement";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE webhook_deliveries 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de création de l'événement";

DEFINE FIELD IF NOT EXISTS scheduled_for ON TABLE webhook_deliveries 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date prévue pour l'envoi";

DEFINE FIELD IF NOT EXISTS processed_at ON TABLE webhook_deliveries 
    TYPE datetime
    COMMENT "Date de traitement final";

DEFINE FIELD IF NOT EXISTS next_retry_at ON TABLE webhook_deliveries 
    TYPE datetime
    COMMENT "Date de la prochaine tentative";

DEFINE FIELD IF NOT EXISTS request_headers ON TABLE webhook_deliveries 
    TYPE object
    COMMENT "En-têtes envoyés lors de la requête";

DEFINE FIELD IF NOT EXISTS response_status ON TABLE webhook_deliveries 
    TYPE int
    COMMENT "Code HTTP renvoyé par le serveur distant";

DEFINE FIELD IF NOT EXISTS response_headers ON TABLE webhook_deliveries 
    TYPE object
    COMMENT "En-têtes renvoyés par le serveur distant";

DEFINE FIELD IF NOT EXISTS response_body ON TABLE webhook_deliveries 
    TYPE string
    COMMENT "Corps de la réponse (tronqué si nécessaire)";

DEFINE FIELD IF NOT EXISTS last_error ON TABLE webhook_deliveries 
    TYPE string
    COMMENT "Dernier message d'erreur technique";

DEFINE INDEX IF NOT EXISTS idx_webhook_deliveries_status_scheduled ON TABLE webhook_deliveries 
    COLUMNS status, scheduled_for
    COMMENT "Index pour le traitement de la file d'attente";

DEFINE INDEX IF NOT EXISTS idx_webhook_deliveries_priority_scheduled ON TABLE webhook_deliveries 
    COLUMNS priority, scheduled_for
    COMMENT "Index de priorité";

DEFINE INDEX IF NOT EXISTS idx_webhook_deliveries_retry ON TABLE webhook_deliveries 
    COLUMNS next_retry_at
    COMMENT "Index pour les réessais";

DEFINE INDEX IF NOT EXISTS idx_webhook_deliveries_webhook_id ON TABLE webhook_deliveries 
    COLUMNS webhook_id
    COMMENT "Index par webhook";

DEFINE INDEX IF NOT EXISTS idx_webhook_deliveries_event_type ON TABLE webhook_deliveries 
    COLUMNS event_type
    COMMENT "Index par type d'événement";

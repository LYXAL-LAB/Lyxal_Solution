DEFINE TABLE IF NOT EXISTS email_queue TYPE NORMAL SCHEMAFULL
    COMMENT "File d'attente asynchrone pour l'envoi d'emails avec gestion des réessais"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS to_addresses ON TABLE email_queue 
    TYPE array<string>
    COMMENT "Liste des destinataires principaux";

DEFINE FIELD IF NOT EXISTS cc_addresses ON TABLE email_queue 
    TYPE array<string>
    COMMENT "Liste des destinataires en copie";

DEFINE FIELD IF NOT EXISTS bcc_addresses ON TABLE email_queue 
    TYPE array<string>
    COMMENT "Liste des destinataires en copie cachée";

DEFINE FIELD IF NOT EXISTS subject ON TABLE email_queue 
    TYPE string
    COMMENT "Sujet de l'email";

DEFINE FIELD IF NOT EXISTS template ON TABLE email_queue 
    TYPE string
    COMMENT "Identifiant du template à utiliser";

DEFINE FIELD IF NOT EXISTS locale ON TABLE email_queue 
    TYPE string 
    DEFAULT 'fr'
    COMMENT "Langue de l'email";

DEFINE FIELD IF NOT EXISTS data ON TABLE email_queue 
    TYPE object 
    DEFAULT {}
    COMMENT "Données dynamiques pour le template";

DEFINE FIELD IF NOT EXISTS headers ON TABLE email_queue 
    TYPE object
    COMMENT "En-têtes SMTP personnalisés";

DEFINE FIELD IF NOT EXISTS status ON TABLE email_queue 
    TYPE string 
    DEFAULT 'pending' 
    ASSERT $value INSIDE ['pending', 'processing', 'sent', 'failed', 'cancelled']
    COMMENT "État actuel dans la file d'attente";

DEFINE FIELD IF NOT EXISTS priority ON TABLE email_queue 
    TYPE int 
    DEFAULT 0
    COMMENT "Priorité de traitement (plus élevé = traité en premier)";

DEFINE FIELD IF NOT EXISTS retry_count ON TABLE email_queue 
    TYPE int 
    DEFAULT 0
    COMMENT "Nombre de tentatives déjà effectuées";

DEFINE FIELD IF NOT EXISTS max_retries ON TABLE email_queue 
    TYPE int 
    DEFAULT 3
    COMMENT "Nombre maximum de tentatives autorisées";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE email_queue 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de création de la tâche";

DEFINE FIELD IF NOT EXISTS scheduled_for ON TABLE email_queue 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date planifiée pour le traitement (pour les envois différés)";

DEFINE FIELD IF NOT EXISTS processed_at ON TABLE email_queue 
    TYPE datetime
    COMMENT "Date de fin de traitement (succès ou échec final)";

DEFINE FIELD IF NOT EXISTS next_retry_at ON TABLE email_queue 
    TYPE datetime
    COMMENT "Date de la prochaine tentative en cas d'échec";

DEFINE FIELD IF NOT EXISTS last_error ON TABLE email_queue 
    TYPE string
    COMMENT "Dernier message d'erreur rencontré";

DEFINE FIELD IF NOT EXISTS error_details ON TABLE email_queue 
    TYPE object
    COMMENT "Détails techniques de l'erreur";

DEFINE FIELD IF NOT EXISTS reference_type ON TABLE email_queue 
    TYPE string
    COMMENT "Type d'objet lié (ex: 'reminder', 'notification')";

DEFINE FIELD IF NOT EXISTS reference_id ON TABLE email_queue 
    TYPE string
    COMMENT "ID de l'objet lié";

DEFINE FIELD IF NOT EXISTS created_by ON TABLE email_queue 
    TYPE string
    COMMENT "Utilisateur ayant généré cet email";

DEFINE INDEX IF NOT EXISTS idx_email_queue_status_scheduled ON TABLE email_queue 
    COLUMNS status, scheduled_for
    COMMENT "Index pour récupérer les tâches à traiter";

DEFINE INDEX IF NOT EXISTS idx_email_queue_priority_scheduled ON TABLE email_queue 
    COLUMNS priority, scheduled_for
    COMMENT "Index pour gérer les priorités";

DEFINE INDEX IF NOT EXISTS idx_email_queue_retry ON TABLE email_queue 
    COLUMNS next_retry_at
    COMMENT "Index pour les réessais";

DEFINE INDEX IF NOT EXISTS idx_email_queue_reference ON TABLE email_queue 
    COLUMNS reference_type, reference_id
    COMMENT "Index pour retrouver les emails liés à un objet";

DEFINE INDEX IF NOT EXISTS idx_email_queue_created_at ON TABLE email_queue 
    COLUMNS created_at
    COMMENT "Index chronologique";

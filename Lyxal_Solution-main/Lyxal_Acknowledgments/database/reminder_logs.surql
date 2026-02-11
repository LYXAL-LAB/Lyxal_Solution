DEFINE TABLE IF NOT EXISTS reminder_logs TYPE NORMAL SCHEMAFULL
    COMMENT "Historique des emails de relance envoyés aux signataires attendus"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS doc_id ON TABLE reminder_logs 
    TYPE string
    COMMENT "Identifiant du document concerné";

DEFINE FIELD IF NOT EXISTS recipient_email ON TABLE reminder_logs 
    TYPE string
    COMMENT "Email du destinataire de la relance";

DEFINE FIELD IF NOT EXISTS sent_at ON TABLE reminder_logs 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date d'envoi de la relance";

DEFINE FIELD IF NOT EXISTS sent_by ON TABLE reminder_logs 
    TYPE string
    COMMENT "Utilisateur ou système ayant déclenché la relance";

DEFINE FIELD IF NOT EXISTS template_used ON TABLE reminder_logs 
    TYPE string
    COMMENT "Nom du template d'email utilisé";

DEFINE FIELD IF NOT EXISTS status ON TABLE reminder_logs 
    TYPE string 
    ASSERT $value INSIDE ['sent', 'failed', 'bounced', 'queued']
    COMMENT "Statut de l'envoi (envoyé, échoué, rejeté, en file d'attente)";

DEFINE FIELD IF NOT EXISTS error_message ON TABLE reminder_logs 
    TYPE string
    COMMENT "Message d'erreur en cas d'échec";

DEFINE INDEX IF NOT EXISTS idx_reminder_logs_doc_id ON TABLE reminder_logs 
    COLUMNS doc_id
    COMMENT "Index par document";

DEFINE INDEX IF NOT EXISTS idx_reminder_logs_recipient ON TABLE reminder_logs 
    COLUMNS recipient_email
    COMMENT "Index par destinataire";

DEFINE INDEX IF NOT EXISTS idx_reminder_logs_sent_at ON TABLE reminder_logs 
    COLUMNS sent_at
    COMMENT "Index chronologique";

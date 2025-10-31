-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::utils::format_notification`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_utils_format_notification_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_utils_format_notification_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::utils::format_notification`.');

    DEFINE FUNCTION fn::scheduler::utils::format_notification(
        $notification_id: record<scheduler_notification>
    ) {
        // Cette fonction reproduit la logique de formatage de `NotificationThread.cpp`.
        // Elle prépare le sujet et le corps d'un email de notification.

        // 1. Récupérer toutes les données nécessaires en une seule fois.
        LET $data = (SELECT
            *,
            jobid.* AS job,
            userid.* AS user,
            joblogid.* AS history
        FROM ONLY $notification_id)[0];

        IF !$data {
            RETURN { subject: "Erreur", body: "Notification introuvable." };
        }

        // 2. Déterminer les clés des phrases à utiliser.
        LET $lang = $data.user.language OR 'en';
        LET $type_key = SWITCH $data.type {
            WHEN 'onFailure' THEN 'failure'
            WHEN 'onSuccess' THEN 'success'
            WHEN 'onDisable' THEN 'disable'
            ELSE 'unknown'
        };
        LET $subject_key = 'notify.' + $type_key + '.mail.subject';
        LET $body_key = 'notify.' + $type_key + '.mail.text';

        // 3. Récupérer les templates de phrases.
        LET $phrases = (SELECT
            value AS subject_template
            FROM scheduler_phrases
            WHERE language = $lang AND key = $subject_key
        )[0] UNION (SELECT
            value AS body_template
            FROM scheduler_phrases
            WHERE language = $lang AND key = $body_key
        )[0];

        LET $subject_template = $phrases.subject_template OR "Sujet non défini";
        LET $body_template = $phrases.body_template OR "Corps non défini";

        // 4. Formater et remplacer les placeholders en JavaScript.
        RETURN function($data, $subject, $body) {
            
            const placeholders = {
                '$firstname': $data.user.firstname,
                '$lastname': $data.user.lastname,
                '$title': $data.job.title || $data.job.function_name || $data.job.url,
                '$url': $data.job.url || $data.job.function_name,
                '$executed': new Date($data.history.date).toLocaleString(),
                '$scheduled': new Date($data.history.date_planned).toLocaleString(),
                '$attempts': $data.job.fail_counter,
                '$status': `${$data.history.status_text} (${$data.history.http_status})`
            };

            let finalSubject = $subject;
            let finalBody = $body;

            for (const key in placeholders) {
                const value = placeholders[key] || '';
                finalSubject = finalSubject.replace(key, value);
                finalBody = finalBody.replace(key, value);
            }

            return {
                subject: finalSubject,
                body: finalBody
            };

        }($data, $subject_template, $body_template);
    };
    
    fn::system_log_create_record_system(['scheduler_utils_format_notification_initialise', 'success'], 'Fonction `fn::scheduler::utils::format_notification` initialisée avec succès.');

    RETURN true;
};

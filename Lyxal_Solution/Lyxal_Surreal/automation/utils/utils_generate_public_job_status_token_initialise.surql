-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::utils::generate_public_job_status_token`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_utils_generate_public_job_status_token_initialise() {
    -- Définition du secret pour les tokens de badge
    DEFINE PARAM IF NOT EXISTS $scheduler_status_badge_token_secret VALUE rand::string(64);

    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_utils_generate_public_job_status_token_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::utils::generate_public_job_status_token`.');

    DEFINE FUNCTION fn::scheduler::utils::generate_public_job_status_token(
        $job_id: record<scheduler_job>,
        $user_id: record<scheduler_user>,
        $options: int
    ) {
        // Génère un token de sécurité pour l'accès public aux badges de statut.
        // Réplique la logique hash_hmac de PHP.
        
        LET $job_id_str = type::string($job_id);
        LET $user_id_str = type::string($user_id);
        
        LET $string_to_sign = 'statusBadge:' + $user_id_str + ':' + $job_id_str + ':' + type::string($options);
        
        LET $token = crypto::hmac::sha256($string_to_sign, $scheduler_status_badge_token_secret);
        
        // La logique PHP prend un `substr`. On peut le faire aussi.
        // Ici, on suppose une longueur de 16 caractères pour l'exemple.
        RETURN string::slice($token, 0, 16);
    };
    
    fn::system_log_create_record_system(['scheduler_utils_generate_public_job_status_token_initialise', 'success'], 'Fonction `fn::scheduler::utils::generate_public_job_status_token` initialisée avec succès.');

    RETURN true;
};

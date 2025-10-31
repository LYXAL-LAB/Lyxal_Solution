-- =================================================================================================
-- DEBUT DE L'INITIALISATION DES PARAMETRES SYSTEME DU SCHEDULER
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_system_params_initialise() {
    -- Log de début
    fn::system_log_create_record_system(['scheduler_system_params_initialise', 'start'], 
    'Initialisation des paramètres système du scheduler.');

    -- Définition du nom d'utilisateur du worker du scheduler
    -- Ce paramètre sera utilisé pour authentifier le service qui déclenche le pipeline.
    DEFINE PARAM IF NOT EXISTS scheduler_name ON ROOT 
    VALUE 'scheduler_worker_name'
    COMMENT 'Nom d\'utilisateur système pour le worker du scheduler.'
    PERMISSIONS FULL;

    -- Définition du mot de passe du worker du scheduler
    -- IMPORTANT: La valeur par défaut est pour le développement. En production, elle doit être 
    -- surchargée.
    DEFINE PARAM IF NOT EXISTS scheduler_pass ON ROOT 
    VALUE 'scheduler_worker_pass' 
    COMMENT 'Mot de passe pour l\'utilisateur système du worker du scheduler.'
    PERMISSIONS FULL;

    -- Log de fin
    fn::system_log_create_record_system(['scheduler_system_params_initialise', 'success'], 
    'Paramètres système du scheduler initialisés avec succès.');

    RETURN true;
};

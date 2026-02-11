-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_mfadevice`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_mfadevice_create_table_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_scheduler'];
    LET $run_id = rand::uuid();

    -- Création de la table scheduler_mfadevice
    fn::system_log_create_record_system(['scheduler_mfadevice_create_table_initialise', 'start'],
     'Initialisation de la table `scheduler_mfadevice`.',
     { log_extra_tags: ['module_scheduler'], run_id: $run_id, parent_run_id: $parent_run_id });

    DEFINE TABLE IF NOT EXISTS scheduler_mfadevice TYPE SCHEMAFULL
        COMMENT 'Stocke les appareils pour l\'authentification multi-facteurs (MFA).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS environment ON scheduler_mfadevice TYPE record<system_environment>
        COMMENT 'Lien vers l\'utilisateur.';

    DEFINE FIELD IF NOT EXISTS enabled ON scheduler_mfadevice TYPE bool DEFAULT false
        COMMENT 'Appareil activé.';

    DEFINE FIELD IF NOT EXISTS title ON scheduler_mfadevice TYPE string DEFAULT ''
        COMMENT 'Titre de l\'appareil.';

    DEFINE FIELD IF NOT EXISTS secret ON scheduler_mfadevice TYPE string DEFAULT ''
        COMMENT 'Secret de l\'appareil.';

    DEFINE FIELD IF NOT EXISTS type ON scheduler_mfadevice TYPE number DEFAULT 0
        COMMENT 'Type de l\'appareil.';

    DEFINE FIELD IF NOT EXISTS created ON scheduler_mfadevice TYPE datetime
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS last_timeslot ON scheduler_mfadevice TYPE datetime
        COMMENT 'Dernier slot utilisé.';


    -- Migration de l'index sur environment
    DEFINE INDEX IF NOT EXISTS mfadevice_environment_idx ON scheduler_mfadevice 
    FIELDS environment 
        COMMENT 'Index sur l\'environnement.';
    
    fn::system_log_create_record_system(['scheduler_mfadevice_create_table_initialise', 'success'],
     'Table `scheduler_mfadevice` initialisée avec succès.',
     { log_extra_tags: ['module_scheduler'], run_id: $run_id, parent_run_id: $parent_run_id });

    RETURN 
    { 
        success: true, 
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
};

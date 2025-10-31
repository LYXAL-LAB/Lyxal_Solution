-- =================================================================================================
-- |
-- | Fichier : automation_service_create_table_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_service` pour stocker les services (ex: Google Sheets).
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_service_create_table_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'automation_service',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    --
    -- Initialise la table `automation_service`.
    -- Cette table stocke les services spécifiques d'une organisation (ex: Google Sheets, Facebook Graph API).
    --
    DEFINE TABLE IF NOT EXISTS automation_service SCHEMAFULL TYPE NORMAL
        COMMENT 'Stocke les services spécifiques (ex: Google Sheets) qui nécessitent 
                 des credentials.';

    -- == Champs principaux
    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_service TYPE string
        COMMENT 'Nom du service (ex: "Google Sheets").'
        ASSERT string::len($value) > 0 AND string::len($value) <= 128;
    
    DEFINE FIELD IF NOT EXISTS organisation ON TABLE automation_service 
        TYPE record<automation_organisation>
        ASSERT $value != NONE
        VALUE type::thing('automation_organisation', string::lowercase($value))
        COMMENT 'Lien vers l\'organisation parente.';

    DEFINE FIELD IF NOT EXISTS documentation_url ON TABLE automation_service 
        TYPE option<string>
        COMMENT 'URL vers la documentation de l\'API du service.';

    DEFINE FIELD IF NOT EXISTS auth_handler ON TABLE automation_service 
        TYPE record<builder_catalogue>
        ASSERT $value != NONE
        VALUE type::thing('builder_catalogue', string::lowercase($value))
        COMMENT 'Nom de la fonction `fn::` qui gère la logique d\'authentification pour ce service.';

    -- == Timestamps
    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_service 
        TYPE datetime
        VALUE $value OR time::now()
        DEFAULT time::now()
        COMMENT 'Date et heure de création de l\'enregistrement.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_service 
        TYPE datetime
        VALUE $value 
        DEFAULT time::now()
        COMMENT 'Date et heure de la dernière mise à jour de l\'enregistrement.';

    -- == Index
    -- Assure qu'un service est unique au sein d'une organisation.
    DEFINE INDEX IF NOT EXISTS service_name_org_unique ON TABLE automation_service 
    FIELDS name, organisation UNIQUE
    COMMENT 'Index unique pour le service et l\'organisation.';

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'Table `automation_service` initialisée avec succès.',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        message: 'Table `automation_service` initialisée avec succès.',
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise la table `automation_service` pour les services d'automatisation."
PERMISSIONS FULL;

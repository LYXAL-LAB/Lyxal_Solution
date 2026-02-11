-- =================================================================================================
-- |
-- | Fichier : automation_tag_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_tag` qui stocke les tags système.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'automation_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `automation_tag`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS automation_tag SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Tags des noeuds d automation'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_tag 
    TYPE string
    COMMENT 'Nom du tag';

    DEFINE FIELD IF NOT EXISTS is_visible ON TABLE automation_tag 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si le tag est visible';

    DEFINE FIELD IF NOT EXISTS is_editable ON TABLE automation_tag 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si le tag est editable';

    DEFINE FIELD IF NOT EXISTS color ON TABLE automation_tag 
    TYPE option<string>
    COMMENT 'Couleur du tag';

    DEFINE FIELD IF NOT EXISTS etag ON TABLE automation_tag 
    TYPE number
    DEFAULT 1
    COMMENT 'Version du tag pour la concurrence optimiste';

    DEFINE FIELD IF NOT EXISTS created_by ON TABLE automation_tag 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
    COMMENT 'Utilisateur qui a créé le tag';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_tag 
    TYPE datetime
    COMMENT 'Date de création du tag';
    
    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_tag 
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de mise à jour du tag';
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'automation_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `automation_tag`'
PERMISSIONS FULL;

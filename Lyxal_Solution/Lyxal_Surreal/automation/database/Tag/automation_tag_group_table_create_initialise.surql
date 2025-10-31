-- =================================================================================================
-- |
-- | Fichier : automation_tag_group_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table de liaison `automation_tag_group`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_tag_group_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'automation_tag_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `automation_tag_group`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS automation_tag_group SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Groupes de tags'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS tag ON TABLE automation_tag_group 
    TYPE record<automation_tag>
    REFERENCE ON DELETE REJECT
    VALUE type::thing('automation_tag', $value)
    COMMENT 'Tag';

    DEFINE FIELD IF NOT EXISTS group_user ON TABLE automation_tag_group 
    TYPE record<base_user_group>
    REFERENCE ON DELETE REJECT
    VALUE type::thing('user_group', $value)
    COMMENT 'Groupe d\'utilisateurs';

    -- == Index
    DEFINE INDEX unique_tag_group ON TABLE automation_tag_group 
    FIELDS tag, group_user UNIQUE
    COMMENT 'Index unique pour la relation tag/group';
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'automation_tag_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table de liaison `automation_tag_group`'
PERMISSIONS FULL;

-- =================================================================================================
-- |
-- | Fichier : automation_node_tag_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table de liaison `automation_node_tag`.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `automation_node_tag`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS automation_node_tag SCHEMAFULL
    TYPE RELATION
    COMMENT 'Relation entre un noeud et un tag'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS in ON TABLE automation_node_tag 
    TYPE record<automation_node>
    VALUE type::thing('automation_node', $value)
    COMMENT 'Noeud';

    DEFINE FIELD IF NOT EXISTS out ON TABLE automation_node_tag 
    TYPE record<automation_tag>
    VALUE type::thing('automation_tag', $value)
    COMMENT 'Tag';
    
    -- == Index
    DEFINE INDEX unique_node_tag ON TABLE automation_node_tag 
    FIELDS in, out UNIQUE
    COMMENT 'Index unique pour la relation in/out';
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table de liaison `automation_node_tag`'
PERMISSIONS FULL;

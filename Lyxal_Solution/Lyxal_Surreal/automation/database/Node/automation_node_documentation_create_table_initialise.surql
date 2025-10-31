-- =================================================================================================
-- |
-- | Fichier : automation_node_documentation_create_table_initialise.surql
-- | Module : automation
-- | Description : Initialise la table de relation `automation_node_documentation`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_node_documentation_create_table_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Création du log de début
    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    --
    -- Initialise la table `automation_node_documentation`.
    -- Cette table est une relation entre les nodes et leurs documentations.
    --
    DEFINE TABLE IF NOT EXISTS automation_node_documentation SCHEMAFULL TYPE RELATION
        COMMENT 'Lie un node à un enregistrement de documentation système.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS in ON TABLE automation_node_documentation 
        TYPE record<automation_node>
        VALUE type::thing('automation_node', $value)
        COMMENT 'Le node concerné.';
    
    DEFINE FIELD IF NOT EXISTS out ON TABLE automation_node_documentation
        TYPE record<system_documentation>
        VALUE type::thing('system_documentation', $value)
        COMMENT 'La documentation système associée.';

    -- Index pour garantir l'unicité de la relation node <-> documentation
    DEFINE INDEX IF NOT EXISTS idx_unique_relation ON TABLE automation_node_documentation 
    FIELDS in, out UNIQUE
    COMMENT 'Index sur la relation node <-> documentation';

    -- Création du log de succès
    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table de relation `automation_node_documentation`.'
PERMISSIONS FULL;

-- =============================================================================================
-- |
-- | Fichier : automation_node_search_provider_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_search_provider` (providers de liste).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_search_provider_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_search_provider',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_search_provider SCHEMAFULL TYPE NORMAL
        COMMENT 'Fournisseurs de listes (listSearch) référencés par des params resourceLocator.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS node ON TABLE automation_node_search_provider
        TYPE record<automation_node>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node', $value)
        COMMENT 'Référence au node.';

    DEFINE FIELD IF NOT EXISTS provider_name ON TABLE automation_node_search_provider
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Nom du provider (ex: getRepositories).';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node_search_provider
        TYPE option<string>;

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_search_provider 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_search_provider 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_node_provider ON TABLE automation_node_search_provider
        FIELDS node, provider_name UNIQUE
        COMMENT 'Unicité par node + provider.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_search_provider',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `automation_node_search_provider`.'
PERMISSIONS FULL;



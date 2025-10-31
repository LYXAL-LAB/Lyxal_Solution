-- =============================================================================================
-- |
-- | Fichier : automation_node_group_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table référentielle `automation_node_group`.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_group_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_group SCHEMAFULL TYPE NORMAL
        COMMENT 'Groupes de classification des nodes (équivalent n8n: group)'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS key ON TABLE automation_node_group
        TYPE string
        ASSERT string::len($value) > 0 AND string::len($value) <= 64
        COMMENT 'Clé technique du groupe (ex: input, transform).';

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_node_group
        TYPE string
        ASSERT string::len($value) > 0 AND string::len($value) <= 128
        COMMENT 'Nom affiché du groupe.';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node_group
        TYPE option<string>;

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_group
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_group
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS node_group_key_unique ON TABLE automation_node_group
        FIELDS key UNIQUE
        COMMENT 'Unicité de la clé du groupe.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table référentielle des groupes de nodes.'
PERMISSIONS FULL;



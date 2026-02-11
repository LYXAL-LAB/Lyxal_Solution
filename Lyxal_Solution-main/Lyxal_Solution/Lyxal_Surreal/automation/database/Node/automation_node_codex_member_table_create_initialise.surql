-- =============================================================================================
-- |
-- | Fichier : automation_node_codex_member_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la relation `automation_node_codex_member` (node -> subcategory).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_codex_member_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_codex_member',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_codex_member SCHEMAFULL TYPE RELATION
        COMMENT 'Relation d\'appartenance node -> sous-catégorie Codex.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS in ON TABLE automation_node_codex_member
        TYPE record<automation_node>
        VALUE type::thing('automation_node', $value)
        COMMENT 'Node membre.';

    DEFINE FIELD IF NOT EXISTS out ON TABLE automation_node_codex_member
        TYPE record<automation_node_codex_subcategory>
        VALUE type::thing('automation_node_codex_subcategory', $value)
        COMMENT 'Sous-catégorie Codex.';

    DEFINE INDEX IF NOT EXISTS idx_unique_node_codex_member ON TABLE automation_node_codex_member
        FIELDS in, out UNIQUE
        COMMENT 'Un node ne peut appartenir qu\'une fois à la même sous-catégorie.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_codex_member',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la relation node -> sous-catégorie Codex.'
PERMISSIONS FULL;



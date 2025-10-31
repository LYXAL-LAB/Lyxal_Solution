-- =============================================================================================
-- |
-- | Fichier : automation_node_group_member_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la relation `automation_node_group_member` (node -> group).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_group_member_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_group_member',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_group_member SCHEMAFULL TYPE RELATION
        COMMENT 'Relation entre un node et un groupe.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS in ON TABLE automation_node_group_member
        TYPE record<automation_node>
        VALUE type::thing('automation_node', $value)
        COMMENT 'Node membre.';

    DEFINE FIELD IF NOT EXISTS out ON TABLE automation_node_group_member
        TYPE record<automation_node_group>
        VALUE type::thing('automation_node_group', $value)
        COMMENT 'Groupe cible.';

    DEFINE INDEX IF NOT EXISTS idx_unique_node_group_member ON TABLE automation_node_group_member
        FIELDS in, out UNIQUE
        COMMENT 'Un node ne peut appartenir qu\'une fois au même groupe.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_group_member',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la relation node -> group.'
PERMISSIONS FULL;



-- =============================================================================================
-- |
-- | Fichier : automation_node_param_mode_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_param_mode` (modes resourceLocator).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_param_mode_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_param_mode',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_param_mode SCHEMAFULL TYPE NORMAL
        COMMENT 'Modes pour un paramètre resourceLocator (list/url/name/...).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS param ON TABLE automation_node_param_mode
        TYPE record<automation_node_param>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node_param', $value)
        COMMENT 'Référence au paramètre.';

    DEFINE FIELD IF NOT EXISTS mode_name ON TABLE automation_node_param_mode
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Nom du mode (list, url, name, ...).';

    DEFINE FIELD IF NOT EXISTS mode_type ON TABLE automation_node_param_mode
        TYPE string
        COMMENT 'Type du mode (list/string/...).';

    DEFINE FIELD IF NOT EXISTS type_options_json ON TABLE automation_node_param_mode
        TYPE option<object>
        COMMENT 'typeOptions propres au mode (searchListMethod, extractValue, validation, ...).';

    DEFINE FIELD IF NOT EXISTS sort_order ON TABLE automation_node_param_mode
        TYPE option<int>;

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_param_mode 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_param_mode 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_param_mode ON TABLE automation_node_param_mode
        FIELDS param, mode_name UNIQUE
        COMMENT 'Unicité par paramètre + mode.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_param_mode',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `automation_node_param_mode`.'
PERMISSIONS FULL;



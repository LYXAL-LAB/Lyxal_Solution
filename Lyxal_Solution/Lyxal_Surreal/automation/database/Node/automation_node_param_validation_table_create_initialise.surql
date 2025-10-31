-- =============================================================================================
-- |
-- | Fichier : automation_node_param_validation_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_param_validation` (validations par regex, etc.).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_param_validation_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_param_validation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_param_validation SCHEMAFULL TYPE NORMAL
        COMMENT 'Règles de validation pour un paramètre (regex, messages, etc.).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS param ON TABLE automation_node_param_validation
        TYPE record<automation_node_param>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node_param', $value)
        COMMENT 'Référence au paramètre.';

    DEFINE FIELD IF NOT EXISTS kind ON TABLE automation_node_param_validation
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Type de validation (regex, schema, ...).';

    DEFINE FIELD IF NOT EXISTS properties ON TABLE automation_node_param_validation
        TYPE object
        COMMENT 'Propriétés de validation (ex: { regex, errorMessage }).';

    DEFINE FIELD IF NOT EXISTS sort_order ON TABLE automation_node_param_validation
        TYPE option<int>;

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_param_validation 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_param_validation 
        TYPE datetime
        VALUE $value OR time::now();

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_param_validation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `automation_node_param_validation`.'
PERMISSIONS FULL;



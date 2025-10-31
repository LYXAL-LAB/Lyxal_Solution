-- =============================================================================================
-- |
-- | Fichier : automation_node_param_option_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_param_option` (valeurs des options).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_param_option_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_param_option',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_param_option SCHEMAFULL TYPE NORMAL
        COMMENT 'Options pour un paramètre (type=options).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS param ON TABLE automation_node_param_option
        TYPE record<automation_node_param>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node_param', $value)
        COMMENT 'Référence au paramètre.';

    DEFINE FIELD IF NOT EXISTS value ON TABLE automation_node_param_option
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Valeur interne de l\'option.';

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_node_param_option
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Libellé affiché de l\'option.';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node_param_option
        TYPE option<string>
        COMMENT 'Description de l\'option.';

    DEFINE FIELD IF NOT EXISTS action ON TABLE automation_node_param_option
        TYPE option<string>
        COMMENT 'Texte d\'action (si présent dans n8n).';

    DEFINE FIELD IF NOT EXISTS sort_order ON TABLE automation_node_param_option
        TYPE option<int>;

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_param_option 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_param_option 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_param_option ON TABLE automation_node_param_option
        FIELDS param, value UNIQUE
        COMMENT 'Unicité par paramètre + valeur.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_param_option',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `automation_node_param_option`.'
PERMISSIONS FULL;



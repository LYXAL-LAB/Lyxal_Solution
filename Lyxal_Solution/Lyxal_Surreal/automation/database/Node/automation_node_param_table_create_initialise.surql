-- =============================================================================================
-- |
-- | Fichier : automation_node_param_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_param` (définition des paramètres).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_param_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_param',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_param SCHEMAFULL TYPE NORMAL
        COMMENT 'Paramètres d\'un node (équivalent n8n: properties[]).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS node ON TABLE automation_node_param
        TYPE record<automation_node>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node', $value)
        COMMENT 'Référence au node.';

    DEFINE FIELD IF NOT EXISTS path ON TABLE automation_node_param
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Chemin unique du paramètre (ex: additionalFields.body).';

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_node_param
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Nom technique du paramètre (name).';

    DEFINE FIELD IF NOT EXISTS display_name ON TABLE automation_node_param
        TYPE option<string>
        COMMENT 'Nom affiché (displayName).';

    DEFINE FIELD IF NOT EXISTS type ON TABLE automation_node_param
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Type (string, number, boolean, options, json, resourceLocator, collection, 
        fixedCollection, notice, dateTime, ...).';

    DEFINE FIELD IF NOT EXISTS required ON TABLE automation_node_param
        TYPE bool
        VALUE $value OR false
        COMMENT 'Paramètre requis.';

    DEFINE FIELD IF NOT EXISTS default_json ON TABLE automation_node_param
        TYPE option<string>
        COMMENT 'Valeur par défaut sérialisée (JSON ou scalaire sous forme de chaîne).';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node_param
        TYPE option<string>
        COMMENT 'Description du paramètre.';

    DEFINE FIELD IF NOT EXISTS placeholder ON TABLE automation_node_param
        TYPE option<string>
        COMMENT 'Placeholder (si applicable).';

    DEFINE FIELD IF NOT EXISTS hint ON TABLE automation_node_param
        TYPE option<string>
        COMMENT 'Hint (si applicable).';

    DEFINE FIELD IF NOT EXISTS display_conditions_json ON TABLE automation_node_param
        TYPE option<object>
        COMMENT 'displayOptions.show/hide et autres conditions (@version, etc.).';

    DEFINE FIELD IF NOT EXISTS type_options_json ON TABLE automation_node_param
        TYPE option<object>
        COMMENT 'typeOptions (validation, rows, searchListMethod, min/max, etc.).';

    DEFINE FIELD IF NOT EXISTS sort_order ON TABLE automation_node_param
        TYPE option<int>
        COMMENT 'Ordre d\'affichage relatif.';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_param 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_param 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_node_param ON TABLE automation_node_param
        FIELDS node, path UNIQUE
        COMMENT 'Unicité par node + chemin de paramètre.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_param',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `automation_node_param`.'
PERMISSIONS FULL;



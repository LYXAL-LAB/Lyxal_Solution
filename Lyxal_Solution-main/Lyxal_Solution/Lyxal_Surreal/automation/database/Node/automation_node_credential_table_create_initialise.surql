-- =============================================================================================
-- |
-- | Fichier : automation_node_credential_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_credential`.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_credential_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_credential',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_credential SCHEMAFULL TYPE NORMAL
        COMMENT 'Déclare les credentials requis par un node et leurs conditions d\'affichage.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS node ON TABLE automation_node_credential
        TYPE record<automation_node>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node', $value)
        COMMENT 'Référence au node.';

    DEFINE FIELD IF NOT EXISTS credential_name ON TABLE automation_node_credential
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Nom du credential (ex: githubApi).';

    DEFINE FIELD IF NOT EXISTS required ON TABLE automation_node_credential
        TYPE bool
        DEFAULT true
        COMMENT 'Credential requis ou non.';

    DEFINE FIELD IF NOT EXISTS display_conditions_json ON TABLE automation_node_credential
        TYPE option<object>
        COMMENT 'displayOptions.show/hide pour ce credential.';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_credential 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_credential 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_node_credential ON TABLE automation_node_credential
        FIELDS node, credential_name UNIQUE
        COMMENT 'Unicité par node + credential';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_credential',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `automation_node_credential`.'
PERMISSIONS FULL;



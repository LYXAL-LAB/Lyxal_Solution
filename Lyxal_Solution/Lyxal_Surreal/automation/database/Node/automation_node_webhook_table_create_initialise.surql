-- =============================================================================================
-- |
-- | Fichier : automation_node_webhook_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table `automation_node_webhook`.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_webhook_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_webhook',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Table
    DEFINE TABLE IF NOT EXISTS automation_node_webhook SCHEMAFULL TYPE NORMAL
        COMMENT 'Définitions de webhooks pour un node n8n équivalent.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS node ON TABLE automation_node_webhook
        TYPE record<automation_node>
        REFERENCE ON DELETE REJECT
        VALUE type::thing('automation_node', $value)
        COMMENT 'Référence au node.';

    DEFINE FIELD IF NOT EXISTS path_template ON TABLE automation_node_webhook
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Chemin du webhook (template).';

    DEFINE FIELD IF NOT EXISTS http_method ON TABLE automation_node_webhook
        TYPE string
        COMMENT 'Méthode HTTP (GET, POST, ...).';

    DEFINE FIELD IF NOT EXISTS response_mode ON TABLE automation_node_webhook
        TYPE option<string>
        COMMENT 'Mode de réponse (p.ex. onReceived).';

    DEFINE FIELD IF NOT EXISTS restart_webhook ON TABLE automation_node_webhook
        TYPE option<bool>
        COMMENT 'Redémarrer le webhook (si applicable).';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_webhook 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_webhook 
        TYPE datetime
        VALUE $value OR time::now();

    DEFINE INDEX IF NOT EXISTS idx_unique_node_webhook ON TABLE automation_node_webhook
        FIELDS node, path_template, http_method UNIQUE
        COMMENT 'Unicité par node + chemin + méthode.';

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_webhook',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `automation_node_webhook`.'
PERMISSIONS FULL;



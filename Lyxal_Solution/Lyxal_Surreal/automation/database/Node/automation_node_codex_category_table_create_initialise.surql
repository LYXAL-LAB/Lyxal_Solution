-- =============================================================================================
-- |
-- | Fichier : automation_node_codex_category_table_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la table référentielle `automation_node_codex_category`.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_codex_category_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'automation_node_codex_category',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS automation_node_codex_category SCHEMAFULL TYPE NORMAL
        COMMENT 'Catégories Codex (référentiel).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS key ON TABLE automation_node_codex_category
        TYPE string
        ASSERT string::len($value) > 0 AND string::len($value) <= 64
        COMMENT 'Clé technique normalisée (ex: productivity, communication).';

    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_node_codex_category
        TYPE string
        ASSERT string::len($value) > 0 AND string::len($value) <= 128
        COMMENT 'Nom affiché de la catégorie.';

    DEFINE FIELD IF NOT EXISTS description ON TABLE automation_node_codex_category
        TYPE option<string>
        COMMENT 'Description de la catégorie.';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_node_codex_category
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_node_codex_category
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de mise à jour.';

    DEFINE INDEX IF NOT EXISTS codex_category_key_unique ON TABLE automation_node_codex_category
        FIELDS key UNIQUE
        COMMENT 'Unicité de la clé catégorie.';

    fn::system_log_helper_initialise(
        'table', 'done', 'automation_node_codex_category',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table référentielle des catégories Codex.'
PERMISSIONS FULL;



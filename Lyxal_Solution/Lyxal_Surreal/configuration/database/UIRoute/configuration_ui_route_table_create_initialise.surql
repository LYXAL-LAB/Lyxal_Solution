-- =============================================================================================
-- |
-- | Fichier : configuration_ui_route_table_create_initialise.surql
-- | Module : configuration / UIRoute
-- | Description : Initialise la table `configuration_ui_route` (catalogue des routes UI).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_ui_route_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'configuration_ui_route',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS configuration_ui_route SCHEMAFULL TYPE NORMAL
        COMMENT 'Catalogue des routes UI (clé + path).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS key ON TABLE configuration_ui_route
        TYPE string
        ASSERT string::len(string::trim($value)) > 0
        COMMENT 'Clé unique de route (ex: integrations).';

    DEFINE FIELD IF NOT EXISTS path ON TABLE configuration_ui_route
        TYPE string
        ASSERT string::starts_with($value, '/')
        COMMENT 'Chemin interne SPA (ex: /integrations).';

    DEFINE FIELD IF NOT EXISTS description ON TABLE configuration_ui_route
        TYPE option<string>
        COMMENT 'Description fonctionnelle (facultatif).';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE configuration_ui_route
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE configuration_ui_route
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de mise à jour.';

    DEFINE INDEX IF NOT EXISTS configuration_ui_route_key_unique 
        ON TABLE configuration_ui_route
        FIELDS key UNIQUE
        COMMENT 'Unicité de la clé de route.';

    DEFINE INDEX IF NOT EXISTS configuration_ui_route_path_unique 
        ON TABLE configuration_ui_route
        FIELDS path UNIQUE
        COMMENT 'Unicité du path.';

    fn::system_log_helper_initialise(
        'table', 'done', 'configuration_ui_route',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `configuration_ui_route`.'
PERMISSIONS FULL;



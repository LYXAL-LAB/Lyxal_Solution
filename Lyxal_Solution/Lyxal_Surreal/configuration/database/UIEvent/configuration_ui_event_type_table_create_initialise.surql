-- =============================================================================================
-- |
-- | Fichier : configuration_ui_event_type_table_create_initialise.surql
-- | Module : configuration / UIEvent
-- | Description : Initialise la table `configuration_ui_event_type` (types d'événements UI).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_ui_event_type_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'configuration_ui_event_type',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS configuration_ui_event_type SCHEMAFULL TYPE NORMAL
        COMMENT 'Types d\'événements UI (navigate, open_modal, ...).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS key ON TABLE configuration_ui_event_type
        TYPE string
        ASSERT string::len(string::trim($value)) > 0
        COMMENT 'Clé unique du type (ex: navigate).';

    DEFINE FIELD IF NOT EXISTS description ON TABLE configuration_ui_event_type
        TYPE option<string>
        COMMENT 'Description fonctionnelle (facultatif).';

    DEFINE FIELD IF NOT EXISTS payload_schema_json ON TABLE configuration_ui_event_type
        TYPE option<object>
        COMMENT 'Schéma JSON attendu pour le payload (facultatif).';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE configuration_ui_event_type
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE configuration_ui_event_type
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de mise à jour.';

    DEFINE INDEX IF NOT EXISTS configuration_ui_event_type_key_unique ON TABLE configuration_ui_event_type
        FIELDS key UNIQUE
        COMMENT 'Unicité de la clé de type.';

    fn::system_log_helper_initialise(
        'table', 'done', 'configuration_ui_event_type',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `configuration_ui_event_type`.'
PERMISSIONS FULL;



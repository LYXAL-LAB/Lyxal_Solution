-- =============================================================================================
-- |
-- | Fichier : configuration_ui_event_table_create_initialise.surql
-- | Module : configuration / UIEvent
-- | Description : Initialise la table `configuration_ui_event` (catalogue des événements UI).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_ui_event_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'configuration_ui_event',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS configuration_ui_event SCHEMAFULL TYPE NORMAL
        COMMENT 'Catalogue des événements UI réutilisables (clé, type, payload par défaut).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS key ON TABLE configuration_ui_event
        TYPE string
        ASSERT string::len(string::trim($value)) > 0
        COMMENT 'Clé unique de l\'événement (ex: navigate).';

    DEFINE FIELD IF NOT EXISTS type ON TABLE configuration_ui_event
        TYPE record<configuration_ui_event_type>
        VALUE if $value = NONE then NONE else type::thing('configuration_ui_event_type', $value) end
        REFERENCE ON DELETE REJECT
        COMMENT 'Type d\'événement (référence).';

    DEFINE FIELD IF NOT EXISTS default_payload_json ON TABLE configuration_ui_event
        TYPE option<object>
        COMMENT 'Payload par défaut (JSON) fusionné avec les overrides.';

    DEFINE FIELD IF NOT EXISTS description ON TABLE configuration_ui_event
        TYPE option<string>
        COMMENT 'Description fonctionnelle (facultatif).';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE configuration_ui_event
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE configuration_ui_event
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de mise à jour.';

    DEFINE INDEX IF NOT EXISTS configuration_ui_event_key_unique ON TABLE configuration_ui_event
        FIELDS key UNIQUE
        COMMENT 'Unicité de la clé d\'événement.';

    fn::system_log_helper_initialise(
        'table', 'done', 'configuration_ui_event',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `configuration_ui_event`.'
PERMISSIONS FULL;



-- =============================================================================================
-- |
-- | Fichier : configuration_ui_item_event_table_create_initialise.surql
-- | Module : configuration / UIItemEvent
-- | Description : Initialise la table RELATION `configuration_ui_item_event` (item -> event).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_ui_item_event_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'configuration_ui_item_event',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS configuration_ui_item_event SCHEMAFULL TYPE RELATION
        COMMENT 'Association d\'un item de menu à un événement UI (avec ordre et overrides).'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS in ON TABLE configuration_ui_item_event
        TYPE record<ui_menu_item>;

    DEFINE FIELD IF NOT EXISTS out ON TABLE configuration_ui_item_event
        TYPE record<configuration_ui_event>;

    DEFINE FIELD IF NOT EXISTS order ON TABLE configuration_ui_item_event
        TYPE int
        VALUE $value OR 0
        COMMENT 'Ordre d\'exécution (par item).';

    DEFINE FIELD IF NOT EXISTS enabled ON TABLE configuration_ui_item_event
        TYPE bool
        VALUE $value OR true
        COMMENT 'Activation de l\'étape.';

    DEFINE FIELD IF NOT EXISTS payload_overrides_json ON TABLE configuration_ui_item_event
        TYPE option<object>
        COMMENT 'Overrides JSON fusionnés avec le payload par défaut de l\'événement.';

    DEFINE FIELD IF NOT EXISTS route ON TABLE configuration_ui_item_event
        TYPE option<record<configuration_ui_route>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Route typée pour les événements navigate (facultatif).';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE configuration_ui_item_event
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de mise à jour.';

    DEFINE INDEX IF NOT EXISTS configuration_ui_item_event_unique_pair ON TABLE configuration_ui_item_event
        FIELDS in, out UNIQUE
        COMMENT 'Un couple item->event unique.';

    DEFINE INDEX IF NOT EXISTS configuration_ui_item_event_in_order_unique ON TABLE configuration_ui_item_event
        FIELDS in, order UNIQUE
        COMMENT 'Permet l\'exécution séquentielle sans doublon de position.';

    fn::system_log_helper_initialise(
        'table', 'done', 'configuration_ui_item_event',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `configuration_ui_item_event`.'
PERMISSIONS FULL;



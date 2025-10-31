-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_table_create_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Initialise la table `ui_menu_item`.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_table_create_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_initialise(
        'table', 'start', 'ui_menu_item',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE TABLE IF NOT EXISTS ui_menu_item SCHEMAFULL TYPE NORMAL
        COMMENT 'Items du menu principal pilotés par la base.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS key ON TABLE ui_menu_item
        TYPE string
        ASSERT string::len($value) > 0
        COMMENT 'Clé technique unique.';

    DEFINE FIELD IF NOT EXISTS name_i18n ON TABLE ui_menu_item
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        VALUE if $value = NONE then NONE else type::thing('i18n_key', $value) end
        COMMENT 'Clé i18n du libellé (référence vers i18n_key).';

    DEFINE FIELD IF NOT EXISTS tooltip_i18n ON TABLE ui_menu_item
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        VALUE if $value = NONE then NONE else type::thing('i18n_key', $value) end
        COMMENT 'Clé i18n du tooltip (référence vers i18n_key).';

    DEFINE FIELD IF NOT EXISTS icon_key ON TABLE ui_menu_item
        TYPE option<string>
        COMMENT 'Clé d\'icône mappée côté UI.';

    DEFINE FIELD IF NOT EXISTS order ON TABLE ui_menu_item
        TYPE int
        VALUE $value OR 0
        COMMENT 'Ordre dans le parent.';

    DEFINE FIELD IF NOT EXISTS parent ON TABLE ui_menu_item
        TYPE option<record<ui_menu_item>>
        VALUE if $value = NONE then NONE else type::thing('ui_menu_item', $value) end
        COMMENT 'Parent hiérarchique (facultatif).';

    DEFINE FIELD IF NOT EXISTS module_key ON TABLE ui_menu_item
        TYPE option<string>
        COMMENT 'Clé de module (filtrage avec config.ui.modules).';

    DEFINE FIELD IF NOT EXISTS roles ON TABLE ui_menu_item
        TYPE option<array<string>>
        COMMENT 'Rôles autorisés (facultatif).';

    DEFINE FIELD IF NOT EXISTS enabled ON TABLE ui_menu_item
        TYPE bool
        VALUE $value OR true
        COMMENT 'Activation de l\'item.';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE ui_menu_item
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de création.';

    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE ui_menu_item
        TYPE datetime
        VALUE $value OR time::now()
        COMMENT 'Date de mise à jour.';

    DEFINE INDEX IF NOT EXISTS ui_menu_key_unique ON TABLE ui_menu_item
        FIELDS key UNIQUE
        COMMENT 'Unicité de la clé d\'item.';

    fn::system_log_helper_initialise(
        'table', 'done', 'ui_menu_item',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `ui_menu_item`.'
PERMISSIONS FULL;



-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_resources_create_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Crée un item de menu UI.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_create(
    $key: string,
    $name_i18n: option<string>,
    $tooltip_i18n: option<string>,
    $icon_key: option<string>,
    $order: option<int>,
    $parent: option<string>,
    $module_key: option<string>,
    $roles: option<array<string>>,
    $enabled: option<bool>
) {
    IF $key = NONE OR string::len(string::trim($key)) = 0 {
        THROW 'La clé technique est requise.';
    };

    LET $now = time::now();
    LET $parent_record = if $parent = NONE then NONE else type::thing('ui_menu_item', $parent) end;
    
    LET $data = CREATE type::thing('ui_menu_item', $key) SET
        key = $key,
        name_i18n = if $name_i18n = NONE then NONE else type::thing('i18n_key', $name_i18n) end,
        tooltip_i18n = if $tooltip_i18n = NONE then NONE else type::thing('i18n_key', $tooltip_i18n) end,
        icon_key = $icon_key,
        order = $order OR 0,
        parent = $parent_record,
        module_key = $module_key,
        roles = $roles,
        enabled = $enabled OR true,
        created_at = $now,
        updated_at = $now;

    RETURN { success: true, data: $data[0] };
}
COMMENT 'Crée un item de menu UI.'
PERMISSIONS FULL;



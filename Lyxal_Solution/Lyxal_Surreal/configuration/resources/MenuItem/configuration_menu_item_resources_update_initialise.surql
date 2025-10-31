-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_resources_update_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Met à jour un item de menu UI par key.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_update(
    $key: string,
    $fields: option<object>
) {
    IF $key = NONE OR string::len(string::trim($key)) = 0 {
        THROW 'La clé technique est requise.';
    };
    LET $item = SELECT * FROM ui_menu_item WHERE key = $key LIMIT 1;
    IF array::len($item) = 0 { THROW 'Item introuvable.'; };
    LET $id = $item[0].id;

    LET $updated = UPDATE $id SET
        name_i18n = if $fields.name_i18n = NONE then name_i18n else type::thing('i18n_key', $fields.name_i18n) end,
        tooltip_i18n = if $fields.tooltip_i18n = NONE then tooltip_i18n else type::thing('i18n_key', $fields.tooltip_i18n) end,
        icon_key = $fields.icon_key OR icon_key,
        order = $fields.order OR order,
        parent = if $fields.parent = NONE then parent else type::thing('ui_menu_item', $fields.parent) end,
        module_key = $fields.module_key OR module_key,
        roles = $fields.roles OR roles,
        enabled = $fields.enabled OR enabled,
        updated_at = time::now();

    RETURN { success: true, data: $updated };
}
COMMENT 'Met à jour un item de menu UI par key.'
PERMISSIONS FULL;



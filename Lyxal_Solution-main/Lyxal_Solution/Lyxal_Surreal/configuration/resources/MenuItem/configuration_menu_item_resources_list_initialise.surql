-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_resources_list_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Liste les items de menu UI, avec filtres.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_list(
    $only_enabled: option<bool>,
    $module_key: option<string>
) {
    LET $q = if $module_key != NONE {
        SELECT * FROM ui_menu_item WHERE (enabled = true OR $only_enabled = false) AND module_key = $module_key ORDER BY parent, order;
    } else {
        SELECT * FROM ui_menu_item WHERE (enabled = true OR $only_enabled = false) ORDER BY parent, order;
    };
    RETURN { success: true, data: $q };
}
COMMENT 'Liste les items, filtrés par activation/module.'
PERMISSIONS FULL;



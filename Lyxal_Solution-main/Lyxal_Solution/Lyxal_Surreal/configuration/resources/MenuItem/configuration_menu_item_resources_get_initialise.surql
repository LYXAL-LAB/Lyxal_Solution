-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_resources_get_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Récupère un item de menu UI par key.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_get(
    $key: string
) {
    LET $res = SELECT * FROM ui_menu_item WHERE key = $key LIMIT 1;
    IF array::len($res) > 0 {
        RETURN { success: true, data: $res[0] };
    } else {
        RETURN { success: true, data: NONE };
    };
}
COMMENT 'Récupère un item par key.'
PERMISSIONS FULL;



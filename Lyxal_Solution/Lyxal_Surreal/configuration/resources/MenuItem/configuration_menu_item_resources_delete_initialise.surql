-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_resources_delete_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Supprime un item de menu UI par key.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_delete(
    $key: string
) {
    IF $key = NONE OR string::len(string::trim($key)) = 0 {
        THROW 'La clé technique est requise.';
    };
    LET $item = SELECT * FROM ui_menu_item WHERE key = $key LIMIT 1;
    IF array::len($item) = 0 { RETURN { success: true, deleted: 0 }; };
    LET $id = $item[0].id;
    LET $res = DELETE $id;
    RETURN { success: true, deleted: array::len($res) };
}
COMMENT 'Supprime un item de menu UI par key.'
PERMISSIONS FULL;



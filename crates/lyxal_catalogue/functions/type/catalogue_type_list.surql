-- ============================================================================
-- FONCTION : fn::catalogue_type_list
-- MODULE   : lyxal_catalogue
-- RÔLE     : Liste des types fondamentaux du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_type_list($params: object) {
    LET $enabled = $params.enabled;
    LET $records = IF $enabled != NONE {
        SELECT * FROM catalogue_type WHERE enabled = $enabled ORDER BY code ASC
    } ELSE {
        SELECT * FROM catalogue_type ORDER BY code ASC
    };
    RETURN fn::result_ok($records);
} COMMENT "Liste les types fondamentaux d'éléments du catalogue universel";

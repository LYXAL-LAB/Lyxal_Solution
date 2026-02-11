-- =============================================================================
-- FONCTION: fn::get_account_children
-- =============================================================================
-- DESCRIPTION: Récupère tous les comptes enfants directs d'un compte parent
-- PARAMETRES:
--   $account_id: ID du compte parent (obligatoire)
--   $is_active: Filtrer par statut actif (optionnel, défaut: true)
--   $recursive: Récupérer tous les descendants (optionnel, défaut: false)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Enfants directs actifs:
--   RETURN fn::get_account_children(account_chart:pcg_fr_4);
--   -- Tous les descendants (récursif):
--   RETURN fn::get_account_children(account_chart:pcg_fr_4, true, true);
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_account_children(
    $account_id: record,
    $is_active: option<bool>,
    $recursive: option<bool>
) {
    -- Vérifier que le compte parent existe
    LET $parent_exists = (SELECT * FROM ONLY $account_id);
    IF $parent_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "Le compte parent spécifié n'existe pas"
        };
    };
    
    -- Valeurs par défaut
    LET $active_filter = IF $is_active IS NONE { true } ELSE { $is_active };
    LET $recursive_search = IF $recursive IS NONE { false } ELSE { $recursive };
    
    -- Récupérer les comptes enfants directs
    LET $direct_children = IF $active_filter = true {
        (SELECT * FROM account_chart 
         WHERE parent_account = $account_id 
         AND is_active = true 
         ORDER BY account_number)
    } ELSE {
        (SELECT * FROM account_chart 
         WHERE parent_account = $account_id 
         ORDER BY account_number)
    };
    
    -- Si récursif, récupérer aussi les petits-enfants
    LET $all_children = IF $recursive_search = true {
        -- Fonction récursive pour obtenir tous les descendants
        LET $descendants = [];
        FOR $child IN $direct_children {
            LET $child_descendants = fn::get_account_children($child.id, $is_active, true);
            IF $child_descendants.success {
                LET $descendants = array::append($descendants, $child);
                FOR $desc IN $child_descendants.data {
                    LET $descendants = array::append($descendants, $desc);
                };
            } ELSE {
                LET $descendants = array::append($descendants, $child);
            };
        };
        $descendants
    } ELSE {
        $direct_children
    };
    
    -- Enrichir avec les données des normes et parents
    LET $enriched_children = (SELECT *,
        accounting_standard.* AS standard_data,
        parent_account.* AS parent_data
    FROM $all_children
    FETCH accounting_standard, parent_account);
    
    LET $result_message = IF $recursive_search = true {
        "Tous les descendants du compte récupérés avec succès"
    } ELSE {
        "Comptes enfants directs récupérés avec succès"
    };
    
    RETURN {
        success: true,
        data: $enriched_children,
        message: $result_message
    };
} COMMENT "Récupère les comptes enfants directs ou tous les descendants d'un compte parent."; 
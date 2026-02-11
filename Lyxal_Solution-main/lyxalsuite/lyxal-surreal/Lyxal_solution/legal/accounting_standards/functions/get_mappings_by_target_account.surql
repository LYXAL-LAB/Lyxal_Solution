-- =============================================================================
-- FONCTION: fn::get_mappings_by_target_account
-- =============================================================================
-- DESCRIPTION: Récupère tous les mappings pour un compte cible donné
-- PARAMETRES:
--   $target_account: Compte cible (obligatoire)
--   $source_standard: Filtrer par norme source (optionnel)
--   $mapping_type: Filtrer par type de mapping (optionnel)
--   $is_active: Filtrer par statut actif (optionnel)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Tous les mappings vers un compte:
--   RETURN fn::get_mappings_by_target_account(account_chart:411000_ifrs);
--   -- Mappings actifs depuis PCG:
--   RETURN fn::get_mappings_by_target_account(
--     account_chart:411000_ifrs,
--     accounting_standard:pcg2014,
--     NONE,
--     true
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_mappings_by_target_account(
    $target_account: record,
    $source_standard: option<record>,
    $mapping_type: option<string>,
    $is_active: option<bool>
) {
    -- Vérifier que le compte cible existe
    LET $target_acc_exists = (SELECT * FROM ONLY $target_account);
    IF $target_acc_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "Le compte cible spécifié n'existe pas"
        };
    };
    
    -- Construire la requête avec filtres
    LET $mappings = (SELECT * FROM accounting_mapping WHERE target_account = $target_account);
    
    LET $filtered_mappings = IF $source_standard IS NOT NONE {
        (SELECT * FROM $mappings WHERE source_standard = $source_standard)
    } ELSE {
        $mappings
    };
    
    LET $filtered_mappings = IF $mapping_type IS NOT NONE {
        (SELECT * FROM $filtered_mappings WHERE mapping_type = $mapping_type)
    } ELSE {
        $filtered_mappings
    };
    
    LET $filtered_mappings = IF $is_active IS NOT NONE {
        (SELECT * FROM $filtered_mappings WHERE is_active = $is_active)
    } ELSE {
        $filtered_mappings
    };
    
    -- Enrichir avec les données des normes et comptes
    LET $enriched_mappings = (SELECT *,
        source_standard.* AS source_standard_data,
        target_standard.* AS target_standard_data,
        source_account.* AS source_account_data,
        target_account.* AS target_account_data
    FROM $filtered_mappings
    FETCH source_standard, target_standard, source_account, target_account);
    
    -- Trier les résultats
    LET $sorted_mappings = (SELECT * FROM $enriched_mappings ORDER BY source_standard.name, mapping_type);
    
    RETURN {
        success: true,
        data: $sorted_mappings,
        message: "Mappings du compte cible récupérés avec succès"
    };
} COMMENT "Récupère tous les mappings pour un compte cible donné avec filtres."; 
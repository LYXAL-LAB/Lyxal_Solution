-- =============================================================================
-- FONCTION: fn::get_mappings_between_standards
-- =============================================================================
-- DESCRIPTION: Récupère tous les mappings entre deux normes comptables
-- PARAMETRES:
--   $source_standard: Norme source (obligatoire)
--   $target_standard: Norme cible (obligatoire)
--   $mapping_type: Filtrer par type de mapping (optionnel)
--   $is_active: Filtrer par statut actif (optionnel)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Tous les mappings PCG vers IFRS:
--   RETURN fn::get_mappings_between_standards(
--     accounting_standard:pcg2014,
--     accounting_standard:ifrs
--   );
--   -- Mappings directs actifs:
--   RETURN fn::get_mappings_between_standards(
--     accounting_standard:pcg2014,
--     accounting_standard:ifrs,
--     "direct",
--     true
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_mappings_between_standards(
    $source_standard: record,
    $target_standard: record,
    $mapping_type: option<string>,
    $is_active: option<bool>
) {
    -- Vérifier que les normes existent
    LET $source_std_exists = (SELECT * FROM ONLY $source_standard);
    IF $source_std_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "La norme comptable source spécifiée n'existe pas"
        };
    };
    
    LET $target_std_exists = (SELECT * FROM ONLY $target_standard);
    IF $target_std_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "La norme comptable cible spécifiée n'existe pas"
        };
    };
    
    -- Construire la requête avec filtres
    LET $mappings = (SELECT * FROM accounting_mapping 
        WHERE source_standard = $source_standard AND target_standard = $target_standard);
    
    LET $filtered_mappings = IF $mapping_type IS NOT NONE {
        (SELECT * FROM $mappings WHERE mapping_type = $mapping_type)
    } ELSE {
        $mappings
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
    LET $sorted_mappings = (SELECT * FROM $enriched_mappings ORDER BY source_account.account_number, mapping_type);
    
    RETURN {
        success: true,
        data: $sorted_mappings,
        message: "Mappings entre normes récupérés avec succès"
    };
} COMMENT "Récupère tous les mappings entre deux normes comptables spécifiques."; 
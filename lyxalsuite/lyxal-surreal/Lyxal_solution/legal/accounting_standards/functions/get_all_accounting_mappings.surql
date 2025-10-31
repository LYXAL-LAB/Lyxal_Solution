-- =============================================================================
-- FONCTION: fn::get_all_accounting_mappings
-- =============================================================================
-- DESCRIPTION: Récupère tous les mappings comptables avec filtres optionnels
-- PARAMETRES:
--   $source_standard: Filtrer par norme source (optionnel)
--   $target_standard: Filtrer par norme cible (optionnel)
--   $mapping_type: Filtrer par type de mapping (optionnel)
--   $is_active: Filtrer par statut actif (optionnel)
--   $limit: Nombre maximum de résultats (optionnel)
--   $offset: Décalage pour pagination (optionnel)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Tous les mappings:
--   RETURN fn::get_all_accounting_mappings();
--   -- Mappings actifs d'une norme vers une autre:
--   RETURN fn::get_all_accounting_mappings(
--     accounting_standard:pcg2014,
--     accounting_standard:ifrs,
--     NONE,
--     true
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::get_all_accounting_mappings(
    $source_standard: option<record>,
    $target_standard: option<record>,
    $mapping_type: option<string>,
    $is_active: option<bool>,
    $limit: option<int>,
    $offset: option<int>
) {
    -- Construire la requête de base
    LET $base_query = (SELECT * FROM accounting_mapping);
    
    -- Appliquer les filtres
    LET $filtered_mappings = IF $source_standard IS NOT NONE {
        (SELECT * FROM $base_query WHERE source_standard = $source_standard)
    } ELSE {
        $base_query
    };
    
    LET $filtered_mappings = IF $target_standard IS NOT NONE {
        (SELECT * FROM $filtered_mappings WHERE target_standard = $target_standard)
    } ELSE {
        $filtered_mappings
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
    
    -- Appliquer la pagination
    LET $final_offset = IF $offset IS NOT NONE { $offset } ELSE { 0 };
    LET $paginated_mappings = IF $limit IS NOT NONE {
        (SELECT * FROM $filtered_mappings ORDER BY created_on DESC LIMIT $limit START $final_offset)
    } ELSE {
        (SELECT * FROM $filtered_mappings ORDER BY created_on DESC)
    };
    
    -- Enrichir avec les données des normes et comptes
    LET $enriched_mappings = (SELECT *,
        source_standard.* AS source_standard_data,
        target_standard.* AS target_standard_data,
        source_account.* AS source_account_data,
        target_account.* AS target_account_data
    FROM $paginated_mappings
    FETCH source_standard, target_standard, source_account, target_account);
    
    RETURN {
        success: true,
        data: $enriched_mappings,
        message: "Mappings comptables récupérés avec succès"
    };
} COMMENT "Récupère tous les mappings comptables avec filtres et pagination."; 
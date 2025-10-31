-- =============================================================================
-- FONCTION: fn::map_account_to_standard
-- =============================================================================
-- DESCRIPTION: Trouve les comptes cibles correspondant à un compte source dans une norme donnée
-- PARAMETRES:
--   $source_account: ID du compte source (obligatoire)
--   $target_standard: ID de la norme cible (obligatoire)
--   $mapping_type: Type de mapping à rechercher (optionnel)
--   $is_active: Filtrer par mappings actifs (optionnel, défaut: true)
-- RETOUR: {success: bool, data: array, message: string}
-- USAGE:
--   -- Tous les mappings actifs vers IFRS:
--   RETURN fn::map_account_to_standard(account_chart:pcg_fr_411, accounting_standard:ifrs);
--   -- Mappings directs seulement:
--   RETURN fn::map_account_to_standard(account_chart:pcg_fr_411, accounting_standard:ifrs, "direct");
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::map_account_to_standard(
    $source_account: record,
    $target_standard: record,
    $mapping_type: option<string>,
    $is_active: option<bool>
) {
    -- Vérifier que le compte source existe
    LET $source_exists = (SELECT * FROM ONLY $source_account);
    IF $source_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "Le compte source spécifié n'existe pas"
        };
    };
    
    -- Vérifier que la norme cible existe
    LET $target_std_exists = (SELECT * FROM ONLY $target_standard);
    IF $target_std_exists IS NONE {
        RETURN {
            success: false,
            data: [],
            message: "La norme comptable cible spécifiée n'existe pas"
        };
    };
    
    -- Valeur par défaut pour is_active
    LET $active_filter = IF $is_active IS NONE { true } ELSE { $is_active };
    
    -- Construire la requête de base
    LET $base_mappings = (SELECT * FROM accounting_mapping 
        WHERE source_account = $source_account 
        AND target_standard = $target_standard);
    
    -- Appliquer le filtre de type de mapping
    LET $filtered_mappings = IF $mapping_type IS NOT NONE {
        (SELECT * FROM $base_mappings WHERE mapping_type = $mapping_type)
    } ELSE {
        $base_mappings
    };
    
    -- Appliquer le filtre d'activation
    LET $active_mappings = IF $active_filter = true {
        (SELECT * FROM $filtered_mappings WHERE is_active = true)
    } ELSE {
        $filtered_mappings
    };
    
    -- Enrichir avec les données des comptes et normes
    LET $enriched_mappings = (SELECT *,
        source_account.* AS source_account_data,
        target_account.* AS target_account_data,
        source_standard.* AS source_standard_data,
        target_standard.* AS target_standard_data
    FROM $active_mappings
    FETCH source_account, target_account, source_standard, target_standard);
    
    -- Extraire seulement les comptes cibles pour simplifier le retour
    LET $target_accounts = [];
    FOR $mapping IN $enriched_mappings {
        LET $target_accounts = array::append($target_accounts, {
            id: $mapping.target_account.id,
            account_number: $mapping.target_account.account_number,
            account_name: $mapping.target_account.account_name,
            mapping_type: $mapping.mapping_type,
            mapping_ratio: $mapping.mapping_ratio,
            conditions: $mapping.conditions,
            notes: $mapping.notes
        });
    };
    
    RETURN {
        success: true,
        data: $target_accounts,
        message: "Mappings vers " + $target_std_exists.name + " trouvés avec succès"
    };
} COMMENT "Trouve les comptes cibles correspondant à un compte source dans une norme donnée."; 
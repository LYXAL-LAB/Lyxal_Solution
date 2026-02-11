-- =============================================================================
-- FONCTION: fn::add_accounting_mapping
-- =============================================================================
-- DESCRIPTION: Ajoute un nouveau mapping entre comptes de différentes normes
-- PARAMETRES:
--   $source_standard: ID de la norme comptable source (obligatoire)
--   $target_standard: ID de la norme comptable cible (obligatoire)
--   $source_account: ID du compte source (obligatoire)
--   $target_account: ID du compte cible (obligatoire)
--   $mapping_type: Type de mapping (direct/split/consolidate/conditional) (obligatoire)
--   $mapping_ratio: Ratio de mapping (défaut: 1.0)
--   $conditions: Conditions de mapping (optionnel)
--   $notes: Notes explicatives (optionnel)
--   $is_active: Statut actif (défaut: true)
--   $created_by: Créé par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Mapping direct simple:
--   RETURN fn::add_accounting_mapping(
--     accounting_standard:pcg2014,
--     accounting_standard:ifrs,
--     account_chart:411000_pcg,
--     account_chart:411000_ifrs,
--     "direct",
--     1.0,
--     {},
--     "Mapping direct client standard",
--     true,
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::add_accounting_mapping(
    $source_standard: record,
    $target_standard: record,
    $source_account: record,
    $target_account: record,
    $mapping_type: string,
    $mapping_ratio: option<float>,
    $conditions: option<object>,
    $notes: option<string>,
    $is_active: option<bool>,
    $created_by: option<string>
) {
    -- Vérifier que les normes comptables existent
    LET $source_std_exists = (SELECT * FROM ONLY $source_standard);
    IF $source_std_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La norme comptable source spécifiée n'existe pas"
        };
    };
    
    LET $target_std_exists = (SELECT * FROM ONLY $target_standard);
    IF $target_std_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La norme comptable cible spécifiée n'existe pas"
        };
    };
    
    -- Vérifier que les comptes existent
    LET $source_acc_exists = (SELECT * FROM ONLY $source_account);
    IF $source_acc_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Le compte source spécifié n'existe pas"
        };
    };
    
    LET $target_acc_exists = (SELECT * FROM ONLY $target_account);
    IF $target_acc_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Le compte cible spécifié n'existe pas"
        };
    };
    
    -- Vérifier que le compte source appartient à la norme source
    IF $source_acc_exists.accounting_standard != $source_standard {
        RETURN {
            success: false,
            data: NONE,
            message: "Le compte source n'appartient pas à la norme comptable source"
        };
    };
    
    -- Vérifier que le compte cible appartient à la norme cible
    IF $target_acc_exists.accounting_standard != $target_standard {
        RETURN {
            success: false,
            data: NONE,
            message: "Le compte cible n'appartient pas à la norme comptable cible"
        };
    };
    
    -- Vérifier l'unicité du mapping (source_standard + source_account + target_standard)
    LET $existing_mapping = (SELECT * FROM accounting_mapping WHERE source_standard = $source_standard AND source_account = $source_account AND target_standard = $target_standard);
    IF count($existing_mapping) > 0 {
        RETURN {
            success: false,
            data: NONE,
            message: "Un mapping existe déjà entre ce compte source et cette norme cible"
        };
    };
    
    -- Valeurs par défaut
    LET $final_mapping_ratio = IF $mapping_ratio IS NONE { 1.0 } ELSE { $mapping_ratio };
    LET $final_conditions = IF $conditions IS NONE { {} } ELSE { $conditions };
    LET $final_is_active = IF $is_active IS NONE { true } ELSE { $is_active };
    
    -- Créer le mapping
    LET $new_mapping = (CREATE accounting_mapping CONTENT {
        source_standard: $source_standard,
        target_standard: $target_standard,
        source_account: $source_account,
        target_account: $target_account,
        mapping_type: $mapping_type,
        mapping_ratio: $final_mapping_ratio,
        conditions: $final_conditions,
        notes: $notes,
        is_active: $final_is_active,
        created_on: time::now(),
        updated_on: time::now(),
        created_by: $created_by,
        updated_by: $created_by
    });
    
    RETURN {
        success: true,
        data: $new_mapping[0],
        message: "Mapping comptable créé avec succès"
    };
} COMMENT "Ajoute un nouveau mapping entre comptes de différentes normes comptables avec validation complète."; 
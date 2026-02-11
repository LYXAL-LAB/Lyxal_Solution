-- =============================================================================
-- FONCTION: fn::update_legal_form
-- =============================================================================
-- DESCRIPTION: Met à jour une forme juridique existante
-- PARAMETRES:
--   $id: ID de la forme juridique à modifier (obligatoire)
--   $name: Nouveau nom (optionnel)
--   $code: Nouveau code (optionnel)
--   $country: Nouveau pays (optionnel)
--   $category: Nouvelle catégorie (optionnel)
--   $description: Nouvelle description (optionnel)
--   $isCommercial: Forme commerciale (optionnel)
--   $isLimitedLiability: Responsabilité limitée (optionnel)
--   $requiresMinimumCapital: Exige capital minimum (optionnel)
--   $minimumCapital: Capital minimum requis (optionnel)
--   $minimumShareholders: Nombre minimum d'actionnaires (optionnel)
--   $maximumShareholders: Nombre maximum d'actionnaires (optionnel)
--   $requirements: Exigences spécifiques (optionnel)
--   $defaultTaxRegime: Régime fiscal par défaut (optionnel)
--   $allowsVATExemption: Permet exonération TVA (optionnel)
--   $typicalUse: Utilisation typique (optionnel)
--   $advantages: Avantages (optionnel)
--   $disadvantages: Inconvénients (optionnel)
--   $updated_by: Mis à jour par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Exemple de mise à jour partielle:
--   RETURN fn::update_legal_form(
--     legal_form:abc123,
--     "Société à Responsabilité Limitée Unipersonnelle",
--     "SARLU"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::update_legal_form(
    $id: record,
    $name: option<string>,
    $code: option<string>,
    $country: option<record>,
    $category: option<record>,
    $description: option<string>,
    $isCommercial: option<bool>,
    $isLimitedLiability: option<bool>,
    $requiresMinimumCapital: option<bool>,
    $minimumCapital: option<decimal>,
    $minimumShareholders: option<int>,
    $maximumShareholders: option<int>,
    $requirements: option<object>,
    $defaultTaxRegime: option<record>,
    $allowsVATExemption: option<bool>,
    $typicalUse: option<string>,
    $advantages: option<array>,
    $disadvantages: option<array>,
    $updated_by: option<string>
) {
    -- Vérifier que la forme juridique existe
    LET $existing_form = (SELECT * FROM ONLY $id);
    IF $existing_form IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Forme juridique non trouvée"
        };
    };
    
    -- Vérifier l'unicité du code si modifié
    IF $code IS NOT NONE {
        LET $final_country = IF $country IS NOT NONE { $country } ELSE { $existing_form.country };
        LET $duplicate_check = (SELECT * FROM legal_form WHERE code = $code AND country = $final_country AND id != $id);
        IF count($duplicate_check) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: "Une forme juridique avec ce code existe déjà dans ce pays"
            };
        };
    };
    
    -- Vérifier l'existence des références si fournies
    IF $country IS NOT NONE {
        LET $country_exists = (SELECT * FROM ONLY $country);
        IF $country_exists IS NONE {
            RETURN {
                success: false,
                data: NONE,
                message: "Le pays spécifié n'existe pas"
            };
        };
    };
    
    IF $category IS NOT NONE {
        LET $category_exists = (SELECT * FROM ONLY $category);
        IF $category_exists IS NONE {
            RETURN {
                success: false,
                data: NONE,
                message: "La catégorie juridique spécifiée n'existe pas"
            };
        };
    };
    
    -- Effectuer la mise à jour avec des SET individuels
    LET $updated_form = (UPDATE $id SET updated_on = time::now());
    
    IF $name IS NOT NONE {
        LET $updated_form = (UPDATE $id SET name = $name);
    };
    
    IF $code IS NOT NONE {
        LET $updated_form = (UPDATE $id SET code = $code);
    };
    
    IF $country IS NOT NONE {
        LET $updated_form = (UPDATE $id SET country = $country);
    };
    
    IF $category IS NOT NONE {
        LET $updated_form = (UPDATE $id SET category = $category);
    };
    
    IF $description IS NOT NONE {
        LET $updated_form = (UPDATE $id SET description = $description);
    };
    
    IF $isCommercial IS NOT NONE {
        LET $updated_form = (UPDATE $id SET isCommercial = $isCommercial);
    };
    
    IF $isLimitedLiability IS NOT NONE {
        LET $updated_form = (UPDATE $id SET isLimitedLiability = $isLimitedLiability);
    };
    
    IF $requiresMinimumCapital IS NOT NONE {
        LET $updated_form = (UPDATE $id SET requiresMinimumCapital = $requiresMinimumCapital);
    };
    
    IF $minimumCapital IS NOT NONE {
        LET $updated_form = (UPDATE $id SET minimumCapital = $minimumCapital);
    };
    
    IF $minimumShareholders IS NOT NONE {
        LET $updated_form = (UPDATE $id SET minimumShareholders = $minimumShareholders);
    };
    
    IF $maximumShareholders IS NOT NONE {
        LET $updated_form = (UPDATE $id SET maximumShareholders = $maximumShareholders);
    };
    
    IF $requirements IS NOT NONE {
        LET $updated_form = (UPDATE $id SET requirements = $requirements);
    };
    
    IF $defaultTaxRegime IS NOT NONE {
        LET $updated_form = (UPDATE $id SET defaultTaxRegime = $defaultTaxRegime);
    };
    
    IF $allowsVATExemption IS NOT NONE {
        LET $updated_form = (UPDATE $id SET allowsVATExemption = $allowsVATExemption);
    };
    
    IF $typicalUse IS NOT NONE {
        LET $updated_form = (UPDATE $id SET typicalUse = $typicalUse);
    };
    
    IF $advantages IS NOT NONE {
        LET $updated_form = (UPDATE $id SET advantages = $advantages);
    };
    
    IF $disadvantages IS NOT NONE {
        LET $updated_form = (UPDATE $id SET disadvantages = $disadvantages);
    };
    
    IF $updated_by IS NOT NONE {
        LET $updated_form = (UPDATE $id SET updated_by = $updated_by);
    };
    
    -- Récupérer le résultat final
    LET $updated_form = (SELECT * FROM ONLY $id);
    
    RETURN {
        success: true,
        data: $updated_form,
        message: "Forme juridique mise à jour avec succès"
    };
} COMMENT "Met à jour une forme juridique existante avec validation des contraintes d'unicité et d'existence des références. Mise à jour partielle supportée."; 
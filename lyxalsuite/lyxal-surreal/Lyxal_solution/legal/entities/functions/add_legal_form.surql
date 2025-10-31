-- =============================================================================
-- FONCTION: fn::add_legal_form
-- =============================================================================
-- DESCRIPTION: Ajoute une nouvelle forme juridique avec toutes ses caractéristiques
-- PARAMETRES:
--   $name: Nom de la forme juridique (obligatoire)
--   $code: Code court (obligatoire)
--   $country: ID du pays (obligatoire)
--   $category: ID de la catégorie juridique (obligatoire)
--   $description: Description détaillée (optionnel)
--   $isCommercial: Forme commerciale (défaut: true)
--   $isLimitedLiability: Responsabilité limitée (défaut: false)
--   $requiresMinimumCapital: Exige capital minimum (défaut: false)
--   $minimumCapital: Capital minimum requis (optionnel)
--   $minimumShareholders: Nombre minimum d'actionnaires (défaut: 1)
--   $maximumShareholders: Nombre maximum d'actionnaires (optionnel)
--   $requirements: Exigences spécifiques (optionnel)
--   $defaultTaxRegime: Régime fiscal par défaut (optionnel)
--   $allowsVATExemption: Permet exonération TVA (défaut: false)
--   $typicalUse: Utilisation typique (optionnel)
--   $advantages: Avantages (optionnel)
--   $disadvantages: Inconvénients (optionnel)
--   $created_by: Créé par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Exemple minimal:
--   RETURN fn::add_legal_form(
--     "SARL", 
--     "SARL", 
--     country:france, 
--     legal_category:societes_capitaux
--   );
--   
--   -- Exemple complet:
--   RETURN fn::add_legal_form(
--     "Société à Responsabilité Limitée",
--     "SARL",
--     country:france,
--     legal_category:societes_capitaux,
--     "Société commerciale avec responsabilité limitée",
--     true,
--     true,
--     true,
--     1000.00,
--     1,
--     100,
--     {
--       auditRequired: false,
--       boardRequired: false,
--       publicationRequired: true,
--       specificReporting: false,
--       registrationAuthority: "Greffe du tribunal de commerce",
--       additionalCompliance: ["Dépôt des comptes annuels"]
--     },
--     tax_regime:is,
--     false,
--     "PME, entreprises familiales",
--     ["Responsabilité limitée", "Souplesse de gestion"],
--     ["Capital minimum requis", "Formalités administratives"],
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::add_legal_form(
    $name: string,
    $code: string,
    $country: record,
    $category: record,
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
    $created_by: option<string>
) {
    -- Vérifier l'unicité du code dans le pays
    LET $existing_form = (SELECT * FROM legal_form WHERE code = $code AND country = $country);
    IF count($existing_form) > 0 {
        RETURN {
            success: false,
            data: NONE,
            message: "Une forme juridique avec ce code existe déjà dans ce pays"
        };
    };
    
    -- Vérifier que le pays existe
    LET $country_exists = (SELECT * FROM ONLY $country);
    IF $country_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Le pays spécifié n'existe pas"
        };
    };
    
    -- Vérifier que la catégorie existe
    LET $category_exists = (SELECT * FROM ONLY $category);
    IF $category_exists IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "La catégorie juridique spécifiée n'existe pas"
        };
    };
    
    -- Valeurs par défaut
    LET $final_isCommercial = IF $isCommercial IS NONE { true } ELSE { $isCommercial };
    LET $final_isLimitedLiability = IF $isLimitedLiability IS NONE { false } ELSE { $isLimitedLiability };
    LET $final_requiresMinimumCapital = IF $requiresMinimumCapital IS NONE { false } ELSE { $requiresMinimumCapital };
    LET $final_minimumShareholders = IF $minimumShareholders IS NONE { 1 } ELSE { $minimumShareholders };
    LET $final_allowsVATExemption = IF $allowsVATExemption IS NONE { false } ELSE { $allowsVATExemption };
    LET $final_requirements = IF $requirements IS NONE {
        {
            auditRequired: false,
            boardRequired: false,
            publicationRequired: false,
            specificReporting: false,
            registrationAuthority: null,
            additionalCompliance: []
        }
    } ELSE { $requirements };
    LET $final_advantages = IF $advantages IS NONE { [] } ELSE { $advantages };
    LET $final_disadvantages = IF $disadvantages IS NONE { [] } ELSE { $disadvantages };
    
    -- Créer la forme juridique
    LET $new_form = (CREATE legal_form CONTENT {
        name: $name,
        code: $code,
        description: $description,
        country: $country,
        category: $category,
        isCommercial: $final_isCommercial,
        isLimitedLiability: $final_isLimitedLiability,
        requiresMinimumCapital: $final_requiresMinimumCapital,
        minimumCapital: $minimumCapital,
        minimumShareholders: $final_minimumShareholders,
        maximumShareholders: $maximumShareholders,
        requirements: $final_requirements,
        defaultTaxRegime: $defaultTaxRegime,
        allowsVATExemption: $final_allowsVATExemption,
        typicalUse: $typicalUse,
        advantages: $final_advantages,
        disadvantages: $final_disadvantages,
        active: true,
        created_on: time::now(),
        updated_on: time::now(),
        created_by: $created_by,
        updated_by: $created_by
    });
    
    RETURN {
        success: true,
        data: $new_form[0],
        message: "Forme juridique créée avec succès"
    };
} COMMENT "Ajoute une nouvelle forme juridique avec toutes ses caractéristiques. Vérifie l'unicité du code par pays et l'existence des références. Retourne un objet avec success, data et message."; 
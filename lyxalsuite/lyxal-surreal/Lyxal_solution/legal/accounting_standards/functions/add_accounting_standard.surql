-- =============================================================================
-- FONCTION: fn::add_accounting_standard
-- =============================================================================
-- DESCRIPTION: Ajoute une nouvelle norme comptable avec toutes ses caractéristiques
-- PARAMETRES:
--   $name: Nom de la norme comptable (obligatoire)
--   $code: Code unique de la norme (obligatoire)
--   $description: Description détaillée (optionnel)
--   $version: Version de la norme (optionnel)
--   $country: ID du pays (optionnel)
--   $scope: Portée (national/international/regional) (défaut: national)
--   $category: Catégorie (pcg/ifrs/gaap/simplified/other) (défaut: other)
--   $effective_date: Date d'entrée en vigueur (optionnel)
--   $last_update: Date de dernière mise à jour (optionnel)
--   $status: Statut (active/inactive/deprecated) (défaut: active)
--   $is_mandatory: Obligatoire ou non (défaut: false)
--   $applies_to: Liste des entités concernées (optionnel)
--   $eligibility_criteria: Critères d'éligibilité (optionnel)
--   $application_rules: Règles d'application (optionnel)
--   $compliance_requirements: Exigences de conformité (optionnel)
--   $parent_standard: Norme parent (optionnel)
--   $related_standards: Normes liées (optionnel)
--   $created_by: Créé par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Exemple minimal:
--   RETURN fn::add_accounting_standard(
--     "Plan Comptable Général", 
--     "PCG2025"
--   );
--   
--   -- Exemple complet:
--   RETURN fn::add_accounting_standard(
--     "Plan Comptable Général 2025",
--     "PCG2025",
--     "Nouvelle version du PCG français",
--     "2025.1",
--     country:france,
--     "national",
--     "pcg",
--     d'2025-01-01T00:00:00Z',
--     d'2024-12-01T00:00:00Z',
--     "active",
--     true,
--     ["SARL", "SAS", "SA"],
--     { legal_forms: ["SARL", "SAS"], sectors: ["all"] },
--     { mandatory_for: ["all_french_companies"] },
--     { reporting_frequency: "annual" },
--     accounting_standard:pcg2014,
--     [accounting_standard:ifrs],
--     "admin"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::add_accounting_standard(
    $name: string,
    $code: string,
    $description: option<string>,
    $version: option<string>,
    $country: option<record>,
    $scope: option<string>,
    $category: option<string>,
    $effective_date: option<datetime>,
    $last_update: option<datetime>,
    $status: option<string>,
    $is_mandatory: option<bool>,
    $applies_to: option<array>,
    $eligibility_criteria: option<object>,
    $application_rules: option<object>,
    $compliance_requirements: option<object>,
    $parent_standard: option<record>,
    $related_standards: option<array>,
    $created_by: option<string>
) {
    -- Vérifier l'unicité du code
    LET $existing_standard = (SELECT * FROM accounting_standard WHERE code = $code);
    IF count($existing_standard) > 0 {
        RETURN {
            success: false,
            data: NONE,
            message: "Une norme comptable avec ce code existe déjà"
        };
    };
    
    -- Vérifier que le pays existe si fourni
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
    
    -- Vérifier que la norme parent existe si fournie
    IF $parent_standard IS NOT NONE {
        LET $parent_exists = (SELECT * FROM ONLY $parent_standard);
        IF $parent_exists IS NONE {
            RETURN {
                success: false,
                data: NONE,
                message: "La norme parent spécifiée n'existe pas"
            };
        };
    };
    
    -- Valeurs par défaut
    LET $final_scope = IF $scope IS NONE { "national" } ELSE { $scope };
    LET $final_category = IF $category IS NONE { "other" } ELSE { $category };
    LET $final_status = IF $status IS NONE { "active" } ELSE { $status };
    LET $final_is_mandatory = IF $is_mandatory IS NONE { false } ELSE { $is_mandatory };
    LET $final_applies_to = IF $applies_to IS NONE { [] } ELSE { $applies_to };
    LET $final_eligibility_criteria = IF $eligibility_criteria IS NONE { {} } ELSE { $eligibility_criteria };
    LET $final_application_rules = IF $application_rules IS NONE { {} } ELSE { $application_rules };
    LET $final_compliance_requirements = IF $compliance_requirements IS NONE { {} } ELSE { $compliance_requirements };
    LET $final_related_standards = IF $related_standards IS NONE { [] } ELSE { $related_standards };
    LET $final_effective_date = IF $effective_date IS NONE { time::now() } ELSE { $effective_date };
    LET $final_last_update = IF $last_update IS NONE { time::now() } ELSE { $last_update };
    
    -- Créer la norme comptable
    LET $new_standard = (CREATE accounting_standard CONTENT {
        name: $name,
        code: $code,
        description: $description,
        version: $version,
        country: $country,
        scope: $final_scope,
        category: $final_category,
        effective_date: $final_effective_date,
        last_update: $final_last_update,
        status: $final_status,
        is_mandatory: $final_is_mandatory,
        applies_to: $final_applies_to,
        eligibility_criteria: $final_eligibility_criteria,
        application_rules: $final_application_rules,
        compliance_requirements: $final_compliance_requirements,
        parent_standard: $parent_standard,
        related_standards: $final_related_standards,
        created_on: time::now(),
        updated_on: time::now(),
        created_by: $created_by,
        updated_by: $created_by
    });
    
    RETURN {
        success: true,
        data: $new_standard[0],
        message: "Norme comptable créée avec succès"
    };
} COMMENT "Ajoute une nouvelle norme comptable avec toutes ses caractéristiques. Vérifie l'unicité du code et l'existence des références. Retourne un objet avec success, data et message."; 
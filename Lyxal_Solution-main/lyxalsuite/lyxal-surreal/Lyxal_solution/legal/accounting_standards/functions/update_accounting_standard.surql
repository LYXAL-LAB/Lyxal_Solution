-- =============================================================================
-- FONCTION: fn::update_accounting_standard
-- =============================================================================
-- DESCRIPTION: Met à jour une norme comptable existante
-- PARAMETRES:
--   $id: ID de la norme comptable à modifier (obligatoire)
--   $name: Nouveau nom (optionnel)
--   $code: Nouveau code (optionnel)
--   $description: Nouvelle description (optionnel)
--   $version: Nouvelle version (optionnel)
--   $country: Nouveau pays (optionnel)
--   $scope: Nouvelle portée (optionnel)
--   $category: Nouvelle catégorie (optionnel)
--   $effective_date: Nouvelle date d'entrée en vigueur (optionnel)
--   $last_update: Nouvelle date de mise à jour (optionnel)
--   $status: Nouveau statut (optionnel)
--   $is_mandatory: Nouveau statut obligatoire (optionnel)
--   $applies_to: Nouvelle liste d'entités concernées (optionnel)
--   $eligibility_criteria: Nouveaux critères d'éligibilité (optionnel)
--   $application_rules: Nouvelles règles d'application (optionnel)
--   $compliance_requirements: Nouvelles exigences de conformité (optionnel)
--   $parent_standard: Nouvelle norme parent (optionnel)
--   $related_standards: Nouvelles normes liées (optionnel)
--   $updated_by: Mis à jour par (optionnel)
-- RETOUR: {success: bool, data: record, message: string}
-- USAGE:
--   -- Exemple de mise à jour partielle:
--   RETURN fn::update_accounting_standard(
--     accounting_standard:pcg2014,
--     "Plan Comptable Général 2014 - Version révisée",
--     "PCG2014-R1"
--   );
-- =============================================================================

DEFINE FUNCTION OVERWRITE fn::update_accounting_standard(
    $id: record,
    $name: option<string>,
    $code: option<string>,
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
    $updated_by: option<string>
) {
    -- Vérifier que la norme comptable existe
    LET $existing_standard = (SELECT * FROM ONLY $id);
    IF $existing_standard IS NONE {
        RETURN {
            success: false,
            data: NONE,
            message: "Norme comptable non trouvée"
        };
    };
    
    -- Vérifier l'unicité du code si modifié
    IF $code IS NOT NONE {
        LET $duplicate_check = (SELECT * FROM accounting_standard WHERE code = $code AND id != $id);
        IF count($duplicate_check) > 0 {
            RETURN {
                success: false,
                data: NONE,
                message: "Une norme comptable avec ce code existe déjà"
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
    
    -- Effectuer la mise à jour avec des SET individuels
    LET $updated_standard = (UPDATE $id SET updated_on = time::now());
    
    IF $name IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET name = $name);
    };
    
    IF $code IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET code = $code);
    };
    
    IF $description IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET description = $description);
    };
    
    IF $version IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET version = $version);
    };
    
    IF $country IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET country = $country);
    };
    
    IF $scope IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET scope = $scope);
    };
    
    IF $category IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET category = $category);
    };
    
    IF $effective_date IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET effective_date = $effective_date);
    };
    
    IF $last_update IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET last_update = $last_update);
    };
    
    IF $status IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET status = $status);
    };
    
    IF $is_mandatory IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET is_mandatory = $is_mandatory);
    };
    
    IF $applies_to IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET applies_to = $applies_to);
    };
    
    IF $eligibility_criteria IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET eligibility_criteria = $eligibility_criteria);
    };
    
    IF $application_rules IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET application_rules = $application_rules);
    };
    
    IF $compliance_requirements IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET compliance_requirements = $compliance_requirements);
    };
    
    IF $parent_standard IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET parent_standard = $parent_standard);
    };
    
    IF $related_standards IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET related_standards = $related_standards);
    };
    
    IF $updated_by IS NOT NONE {
        LET $updated_standard = (UPDATE $id SET updated_by = $updated_by);
    };
    
    -- Récupérer le résultat final
    LET $updated_standard = (SELECT * FROM ONLY $id);
    
    RETURN {
        success: true,
        data: $updated_standard,
        message: "Norme comptable mise à jour avec succès"
    };
} COMMENT "Met à jour une norme comptable existante avec validation des contraintes d'unicité et d'existence des références. Mise à jour partielle supportée."; 
-- =====================================================
-- FONCTIONS DE DÉSACTIVATION: sale_order_line_type
-- Description: Désactivation (soft delete) des types de ligne
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: deactivate_sale_order_line_type
-- Description: Désactivation d'un type par ID
-- =====================================================

DEFINE FUNCTION fn::deactivate_sale_order_line_type($id: record<sale_order_line_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $existing = SELECT * FROM $id;
    IF !$existing {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Vérification si déjà inactif
    IF !$existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de ligne déjà inactif",
            data: $existing[0]
        };
    };
    
    -- Protection des types système
    IF $existing[0].is_system {
        RETURN {
            success: false,
            error: "Les types système ne peuvent pas être désactivés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Vérification des permissions de suppression
    IF !$existing[0].allows_deletion {
        RETURN {
            success: false,
            error: "Ce type de ligne ne peut pas être désactivé",
            message: "Erreur de permission : désactivation interdite"
        };
    };
    
    -- Vérification de l'utilisation actuelle
    LET $usage_count = SELECT VALUE count() FROM sale_order_line WHERE type_id = $id LIMIT 1;
    IF $usage_count[0] > 0 {
        RETURN {
            success: false,
            error: "Ce type de ligne est actuellement utilisé dans " + <string>$usage_count[0] + " ligne(s)",
            message: "Erreur de contrainte : type en cours d'utilisation",
            usage_count: $usage_count[0]
        };
    };
    
    -- Désactivation du type
    LET $deactivated_type = UPDATE $id SET 
        is_active = false,
        updated_on = time::now();
    
    -- Vérification de la désactivation
    IF !$deactivated_type {
        RETURN {
            success: false,
            error: "Erreur lors de la désactivation du type de ligne",
            message: "Erreur système : désactivation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne désactivé avec succès",
        data: $deactivated_type[0]
    };
};

-- =====================================================
-- FONCTION: deactivate_sale_order_line_type_by_code
-- Description: Désactivation d'un type par code
-- =====================================================

DEFINE FUNCTION fn::deactivate_sale_order_line_type_by_code($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de ligne est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Recherche du type par code
    LET $type = SELECT VALUE id FROM sale_order_line_type WHERE code = $code LIMIT 1;
    IF !$type {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec ce code"
        };
    };
    
    -- Délégation à la fonction principale
    RETURN fn::deactivate_sale_order_line_type($type[0]);
};

-- =====================================================
-- FONCTION: deactivate_sale_order_line_type_force
-- Description: Désactivation forcée avec migration des données
-- =====================================================

DEFINE FUNCTION fn::deactivate_sale_order_line_type_force(
    $id: record<sale_order_line_type>,
    $replacement_id: record<sale_order_line_type>
) {
    -- Validation des paramètres
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    IF !$replacement_id {
        RETURN {
            success: false,
            error: "L'ID du type de remplacement est obligatoire",
            message: "Erreur de validation : ID de remplacement manquant"
        };
    };
    
    -- Vérification de l'existence du type à désactiver
    LET $existing = SELECT * FROM $id;
    IF !$existing {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Vérification de l'existence du type de remplacement
    LET $replacement = SELECT * FROM $replacement_id;
    IF !$replacement {
        RETURN {
            success: false,
            error: "Type de ligne de remplacement non trouvé",
            message: "Aucun type de ligne trouvé avec l'ID de remplacement"
        };
    };
    
    -- Vérification que le type de remplacement est actif
    IF !$replacement[0].is_active {
        RETURN {
            success: false,
            error: "Le type de remplacement doit être actif",
            message: "Erreur de validation : type de remplacement inactif"
        };
    };
    
    -- Protection des types système
    IF $existing[0].is_system {
        RETURN {
            success: false,
            error: "Les types système ne peuvent pas être désactivés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Comptage des lignes à migrer
    LET $lines_to_migrate = SELECT VALUE count() FROM sale_order_line WHERE type_id = $id;
    
    -- Migration des lignes existantes
    IF $lines_to_migrate[0] > 0 {
        UPDATE sale_order_line SET 
            type_id = $replacement_id,
            updated_on = time::now()
        WHERE type_id = $id;
    };
    
    -- Désactivation du type
    LET $deactivated_type = UPDATE $id SET 
        is_active = false,
        updated_on = time::now();
    
    -- Vérification de la désactivation
    IF !$deactivated_type {
        RETURN {
            success: false,
            error: "Erreur lors de la désactivation du type de ligne",
            message: "Erreur système : désactivation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne désactivé avec succès et données migrées",
        data: $deactivated_type[0],
        migrated_lines: $lines_to_migrate[0],
        replacement_type: $replacement[0]
    };
};

-- =====================================================
-- FONCTION: batch_deactivate_sale_order_line_types
-- Description: Désactivation en lot
-- =====================================================

DEFINE FUNCTION fn::batch_deactivate_sale_order_line_types($ids: array<record<sale_order_line_type>>) {
    -- Validation du paramètre
    IF !$ids OR array::len($ids) == 0 {
        RETURN {
            success: false,
            error: "La liste des IDs est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : IDs manquants"
        };
    };
    
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $id IN $ids {
        LET $result = fn::deactivate_sale_order_line_type($id);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                id: $id,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Désactivation en lot terminée",
        total_requested: array::len($ids),
        success_count: $success_count,
        error_count: array::len($errors),
        deactivated_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: check_sale_order_line_type_can_be_deactivated
-- Description: Vérification si un type peut être désactivé
-- =====================================================

DEFINE FUNCTION fn::check_sale_order_line_type_can_be_deactivated($id: record<sale_order_line_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $existing = SELECT * FROM $id;
    IF !$existing {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec cet ID"
        };
    };
    
    -- Vérifications des contraintes
    LET $constraints = {
        is_active: $existing[0].is_active,
        is_system: $existing[0].is_system,
        allows_deletion: $existing[0].allows_deletion,
        usage_count: (SELECT VALUE count() FROM sale_order_line WHERE type_id = $id LIMIT 1)[0] OR 0
    };
    
    -- Évaluation des contraintes
    LET $can_deactivate = $constraints.is_active 
        AND !$constraints.is_system 
        AND $constraints.allows_deletion 
        AND $constraints.usage_count == 0;
    
    -- Raisons d'impossibilité
    LET $blocking_reasons = [];
    IF !$constraints.is_active {
        $blocking_reasons = array::push($blocking_reasons, "Type déjà inactif");
    };
    IF $constraints.is_system {
        $blocking_reasons = array::push($blocking_reasons, "Type système protégé");
    };
    IF !$constraints.allows_deletion {
        $blocking_reasons = array::push($blocking_reasons, "Désactivation interdite");
    };
    IF $constraints.usage_count > 0 {
        $blocking_reasons = array::push($blocking_reasons, "Type en cours d'utilisation (" + <string>$constraints.usage_count + " ligne(s))");
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Vérification effectuée",
        can_deactivate: $can_deactivate,
        constraints: $constraints,
        blocking_reasons: $blocking_reasons
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Désactivation par ID:
   SELECT fn::deactivate_sale_order_line_type(sale_order_line_type:CUSTOM);

2. Désactivation par code:
   SELECT fn::deactivate_sale_order_line_type_by_code("CUSTOM");

3. Désactivation forcée avec migration:
   SELECT fn::deactivate_sale_order_line_type_force(
       sale_order_line_type:CUSTOM,
       sale_order_line_type:NORMAL
   );

4. Désactivation en lot:
   SELECT fn::batch_deactivate_sale_order_line_types([
       sale_order_line_type:CUSTOM1,
       sale_order_line_type:CUSTOM2
   ]);

5. Vérification de possibilité:
   SELECT fn::check_sale_order_line_type_can_be_deactivated(
       sale_order_line_type:CUSTOM
   );

PROTECTIONS ET VALIDATIONS:
- Types système : ne peuvent pas être désactivés
- Types en cours d'utilisation : désactivation bloquée
- Permissions : respect du champ allows_deletion
- Types déjà inactifs : pas d'erreur, confirmation

DÉSACTIVATION FORCÉE:
- Migre automatiquement les lignes existantes
- Nécessite un type de remplacement actif
- Maintient l'intégrité des données
- Fournit un rapport de migration

CONTRAINTES VÉRIFIÉES:
- is_active: Type actuellement actif
- is_system: Type système protégé
- allows_deletion: Permission de suppression
- usage_count: Nombre d'utilisations actuelles

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    error: string (si erreur),
    usage_count: int (si applicable),
    migrated_lines: int (si migration)
}
*/ 
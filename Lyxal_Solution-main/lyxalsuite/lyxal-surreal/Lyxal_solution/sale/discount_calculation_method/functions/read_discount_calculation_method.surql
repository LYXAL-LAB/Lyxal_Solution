-- =====================================================
-- FONCTIONS DE LECTURE: discount_calculation_method
-- Description: Fonctions de lecture et consultation des méthodes de calcul
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: read_discount_calculation_method
-- Description: Lecture d'une méthode par ID
-- =====================================================

DEFINE FUNCTION fn::read_discount_calculation_method($id: record<discount_calculation_method>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID de la méthode de calcul est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $method = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$method {
        RETURN {
            success: false,
            error: "Méthode de calcul non trouvée",
            message: "Aucune méthode de calcul trouvée avec cet ID"
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthode de calcul trouvée",
        data: $method[0]
    };
};

-- =====================================================
-- FONCTION: read_discount_calculation_method_by_code
-- Description: Lecture d'une méthode par code
-- =====================================================

DEFINE FUNCTION fn::read_discount_calculation_method_by_code($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code de la méthode de calcul est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $method = SELECT * FROM discount_calculation_method WHERE code = $code LIMIT 1;
    
    -- Vérification de l'existence
    IF !$method {
        RETURN {
            success: false,
            error: "Méthode de calcul non trouvée",
            message: "Aucune méthode de calcul trouvée avec ce code"
        };
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthode de calcul trouvée",
        data: $method[0]
    };
};

-- =====================================================
-- FONCTION: read_discount_calculation_method_with_usage
-- Description: Lecture avec statistiques d'utilisation
-- =====================================================

DEFINE FUNCTION fn::read_discount_calculation_method_with_usage($id: record<discount_calculation_method>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID de la méthode de calcul est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $method = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$method {
        RETURN {
            success: false,
            error: "Méthode de calcul non trouvée",
            message: "Aucune méthode de calcul trouvée avec cet ID"
        };
    };
    
    -- Calcul des statistiques d'utilisation
    LET $usage_stats = {
        -- Utilisation dans les types de remise
        discount_type_usage: (SELECT VALUE count() FROM discount_type WHERE calculation_method_id = $id)[0] OR 0,
        active_discount_type_usage: (SELECT VALUE count() FROM discount_type WHERE calculation_method_id = $id AND is_active = true)[0] OR 0,
        
        -- Utilisation indirecte dans les commandes
        order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0] OR 0,
        order_line_usage: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0] OR 0,
        
        -- Montants calculés
        total_discount_amount: (SELECT VALUE sum(discount_amount) FROM sale_order WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0] OR 0,
        avg_discount_amount: (SELECT VALUE avg(discount_amount) FROM sale_order WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0] OR 0,
        
        -- Statistiques temporelles
        first_used: (SELECT VALUE min(creation_date) FROM sale_order WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0],
        last_used: (SELECT VALUE max(creation_date) FROM sale_order WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0],
        
        -- Clients uniques
        unique_clients: (SELECT VALUE count(DISTINCT client_partner_id) FROM sale_order WHERE discount_type_id IN (SELECT id FROM discount_type WHERE calculation_method_id = $id))[0] OR 0
    };
    
    -- Calcul du total d'utilisation
    LET $total_usage = $usage_stats.discount_type_usage + $usage_stats.order_usage + $usage_stats.order_line_usage;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthode de calcul trouvée avec statistiques",
        data: $method[0],
        usage_stats: $usage_stats,
        total_usage: $total_usage
    };
};

-- =====================================================
-- FONCTION: read_multiple_discount_calculation_methods
-- Description: Lecture de plusieurs méthodes par IDs
-- =====================================================

DEFINE FUNCTION fn::read_multiple_discount_calculation_methods($ids: array<record<discount_calculation_method>>) {
    -- Validation du paramètre
    IF !$ids OR array::len($ids) == 0 {
        RETURN {
            success: false,
            error: "La liste des IDs est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : IDs manquants"
        };
    };
    
    -- Lecture des enregistrements
    LET $methods = SELECT * FROM discount_calculation_method WHERE id IN $ids ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul trouvées",
        requested_count: array::len($ids),
        found_count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: read_discount_calculation_methods_by_codes
-- Description: Lecture de plusieurs méthodes par codes
-- =====================================================

DEFINE FUNCTION fn::read_discount_calculation_methods_by_codes($codes: array<string>) {
    -- Validation du paramètre
    IF !$codes OR array::len($codes) == 0 {
        RETURN {
            success: false,
            error: "La liste des codes est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : codes manquants"
        };
    };
    
    -- Lecture des enregistrements
    LET $methods = SELECT * FROM discount_calculation_method WHERE code IN $codes ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul trouvées",
        requested_count: array::len($codes),
        found_count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: check_discount_calculation_method_exists
-- Description: Vérification d'existence d'une méthode
-- =====================================================

DEFINE FUNCTION fn::check_discount_calculation_method_exists($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code de la méthode de calcul est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $exists = SELECT VALUE count() FROM discount_calculation_method WHERE code = $code LIMIT 1;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Vérification d'existence effectuée",
        exists: $exists[0] > 0,
        code: $code
    };
};

-- =====================================================
-- FONCTION: get_discount_calculation_method_details
-- Description: Détails complets avec métadonnées
-- =====================================================

DEFINE FUNCTION fn::get_discount_calculation_method_details($id: record<discount_calculation_method>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID de la méthode de calcul est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Lecture de l'enregistrement
    LET $method = SELECT * FROM $id;
    
    -- Vérification de l'existence
    IF !$method {
        RETURN {
            success: false,
            error: "Méthode de calcul non trouvée",
            message: "Aucune méthode de calcul trouvée avec cet ID"
        };
    };
    
    -- Calcul des métadonnées
    LET $metadata = {
        can_be_deleted: !$method[0].is_system,
        can_be_modified: !$method[0].is_system,
        is_in_use: (SELECT VALUE count() FROM discount_type WHERE calculation_method_id = $id LIMIT 1)[0] > 0,
        age_days: math::floor(time::unix(time::now()) - time::unix($method[0].created_on)) / 86400,
        last_modified_days: math::floor(time::unix(time::now()) - time::unix($method[0].updated_on)) / 86400,
        
        -- Capacités
        capabilities: {
            supports_fixed_amount: $method[0].supports_fixed_amount,
            supports_percentage: $method[0].supports_percentage,
            supports_formula: $method[0].supports_formula,
            supports_currency: $method[0].supports_currency,
            can_be_cumulated: $method[0].can_be_cumulated,
            requires_approval: $method[0].requires_approval,
            restricted_usage: $method[0].restricted_usage
        },
        
        -- Configuration
        configuration: {
            calculation_type: $method[0].calculation_type,
            calculation_subtype: $method[0].calculation_subtype,
            display_category: $method[0].display_category,
            decimal_precision: $method[0].decimal_precision,
            cache_enabled: $method[0].cache_enabled,
            cache_duration: $method[0].cache_duration
        }
    };
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Détails complets de la méthode de calcul",
        data: $method[0],
        metadata: $metadata
    };
};

-- =====================================================
-- FONCTION: get_discount_calculation_methods_by_type
-- Description: Méthodes par type de calcul
-- =====================================================

DEFINE FUNCTION fn::get_discount_calculation_methods_by_type($calculation_type: string) {
    -- Validation du paramètre
    IF !$calculation_type OR !($calculation_type IN ["FIXED", "PERCENT", "FORMULA", "TIERED", "CONDITIONAL"]) {
        RETURN {
            success: false,
            error: "Le type de calcul doit être FIXED, PERCENT, FORMULA, TIERED ou CONDITIONAL",
            message: "Erreur de validation : type invalide"
        };
    };
    
    -- Recherche des méthodes par type
    LET $methods = SELECT * FROM discount_calculation_method 
        WHERE is_active = true 
        AND calculation_type = $calculation_type
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul trouvées par type",
        calculation_type: $calculation_type,
        count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: get_discount_calculation_methods_by_support
-- Description: Méthodes par type de support
-- =====================================================

DEFINE FUNCTION fn::get_discount_calculation_methods_by_support(
    $supports_fixed_amount: bool,
    $supports_percentage: bool,
    $supports_formula: bool,
    $supports_currency: bool
) {
    -- Recherche des méthodes par support
    LET $methods = SELECT * FROM discount_calculation_method 
        WHERE is_active = true
        AND ($supports_fixed_amount IS NONE OR supports_fixed_amount = $supports_fixed_amount)
        AND ($supports_percentage IS NONE OR supports_percentage = $supports_percentage)
        AND ($supports_formula IS NONE OR supports_formula = $supports_formula)
        AND ($supports_currency IS NONE OR supports_currency = $supports_currency)
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul trouvées par support",
        filters: {
            supports_fixed_amount: $supports_fixed_amount,
            supports_percentage: $supports_percentage,
            supports_formula: $supports_formula,
            supports_currency: $supports_currency
        },
        count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: get_discount_calculation_methods_by_category
-- Description: Méthodes par catégorie d'affichage
-- =====================================================

DEFINE FUNCTION fn::get_discount_calculation_methods_by_category($display_category: string) {
    -- Validation du paramètre
    IF !$display_category OR $display_category == "" {
        RETURN {
            success: false,
            error: "La catégorie d'affichage est obligatoire",
            message: "Erreur de validation : catégorie manquante"
        };
    };
    
    -- Recherche des méthodes par catégorie
    LET $methods = SELECT * FROM discount_calculation_method 
        WHERE is_active = true 
        AND display_category = $display_category
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul trouvées par catégorie",
        display_category: $display_category,
        count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: get_available_discount_calculation_methods
-- Description: Méthodes disponibles pour un utilisateur
-- =====================================================

DEFINE FUNCTION fn::get_available_discount_calculation_methods($user_roles: array<string>) {
    -- Paramètres par défaut
    LET $roles = $user_roles OR [];
    
    -- Recherche des méthodes disponibles
    LET $methods = SELECT * FROM discount_calculation_method 
        WHERE is_active = true
        AND (
            restricted_usage = false OR 
            array::len(array::intersect($roles, allowed_roles)) > 0
        )
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul disponibles récupérées",
        user_roles: $roles,
        count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: get_discount_calculation_methods_for_approval
-- Description: Méthodes nécessitant une approbation
-- =====================================================

DEFINE FUNCTION fn::get_discount_calculation_methods_for_approval($approval_level: string) {
    -- Recherche des méthodes nécessitant approbation
    LET $methods = SELECT * FROM discount_calculation_method 
        WHERE is_active = true 
        AND requires_approval = true
        AND ($approval_level IS NONE OR approval_level = $approval_level)
        ORDER BY sequence;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Méthodes de calcul nécessitant approbation récupérées",
        approval_level: $approval_level,
        count: array::len($methods),
        data: $methods
    };
};

-- =====================================================
-- FONCTION: search_discount_calculation_methods
-- Description: Recherche textuelle dans les méthodes
-- =====================================================

DEFINE FUNCTION fn::search_discount_calculation_methods($search_term: string, $limit: int) {
    -- Validation du paramètre
    IF !$search_term OR $search_term == "" {
        RETURN {
            success: false,
            error: "Le terme de recherche est obligatoire",
            message: "Erreur de validation : terme de recherche manquant"
        };
    };
    
    -- Paramètres
    LET $search_limit = $limit OR 10;
    LET $search_lower = string::lowercase($search_term);
    
    -- Recherche
    LET $results = SELECT * FROM discount_calculation_method 
        WHERE string::lowercase(code) CONTAINS $search_lower
        OR string::lowercase(name) CONTAINS $search_lower
        OR string::lowercase(description) CONTAINS $search_lower
        OR string::lowercase(calculation_type) CONTAINS $search_lower
        ORDER BY sequence ASC
        LIMIT $search_limit;
    
    -- Retour avec succès
    RETURN {
        success: true,
        message: "Recherche dans les méthodes de calcul effectuée",
        search_term: $search_term,
        limit: $search_limit,
        count: array::len($results),
        data: $results
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Lecture par ID:
   SELECT fn::read_discount_calculation_method(discount_calculation_method:FIXED_AMOUNT);

2. Lecture par code:
   SELECT fn::read_discount_calculation_method_by_code("FIXED_AMOUNT");

3. Lecture avec statistiques:
   SELECT fn::read_discount_calculation_method_with_usage(discount_calculation_method:PERCENTAGE);

4. Lecture multiple par IDs:
   SELECT fn::read_multiple_discount_calculation_methods([
       discount_calculation_method:FIXED_AMOUNT,
       discount_calculation_method:PERCENTAGE
   ]);

5. Lecture multiple par codes:
   SELECT fn::read_discount_calculation_methods_by_codes(["FIXED_AMOUNT", "PERCENTAGE"]);

6. Vérification d'existence:
   SELECT fn::check_discount_calculation_method_exists("FORMULA");

7. Détails complets:
   SELECT fn::get_discount_calculation_method_details(discount_calculation_method:FIXED_AMOUNT);

8. Méthodes par type:
   SELECT fn::get_discount_calculation_methods_by_type("PERCENT");

9. Méthodes par support:
   SELECT fn::get_discount_calculation_methods_by_support(true, false, false, true);

10. Méthodes par catégorie:
    SELECT fn::get_discount_calculation_methods_by_category("AMOUNT");

11. Méthodes disponibles:
    SELECT fn::get_available_discount_calculation_methods(["MANAGER", "SALES"]);

12. Méthodes nécessitant approbation:
    SELECT fn::get_discount_calculation_methods_for_approval("MANAGER");

13. Recherche textuelle:
    SELECT fn::search_discount_calculation_methods("montant", 5);

STATISTIQUES DISPONIBLES:
- discount_type_usage: Utilisation dans les types de remise
- active_discount_type_usage: Utilisation dans les types actifs
- order_usage: Utilisation indirecte dans les commandes
- order_line_usage: Utilisation dans les lignes de commande
- total_discount_amount: Montant total des remises
- avg_discount_amount: Montant moyen des remises
- first_used/last_used: Dates d'utilisation
- unique_clients: Nombre de clients uniques

MÉTADONNÉES DISPONIBLES:
- can_be_deleted: Peut être supprimé
- can_be_modified: Peut être modifié
- is_in_use: Actuellement utilisé
- age_days: Âge en jours
- last_modified_days: Dernière modification en jours
- capabilities: Capacités de la méthode
- configuration: Configuration technique

FILTRES DISPONIBLES:
- Par type de calcul: FIXED, PERCENT, FORMULA, TIERED, CONDITIONAL
- Par support: montant fixe, pourcentage, formule, devise
- Par catégorie: AMOUNT, PERCENT, FORMULA, ADVANCED, STANDARD
- Par approbation: nécessite approbation, niveau d'approbation
- Par restriction: usage restreint, rôles autorisés

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object/array (si succès),
    error: string (si erreur)
}
*/ 
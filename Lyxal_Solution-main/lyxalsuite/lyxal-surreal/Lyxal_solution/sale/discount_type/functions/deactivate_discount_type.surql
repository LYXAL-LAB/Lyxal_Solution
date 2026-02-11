-- =====================================================
-- FONCTIONS DE DÉSACTIVATION: discount_type
-- Description: Fonctions pour désactiver les types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: deactivate_discount_type
-- Description: Désactivation d'un type de remise
-- =====================================================

DEFINE FUNCTION fn::deactivate_discount_type($id: record<discount_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de remise est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $existing = SELECT * FROM $id;
    IF !$existing {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec cet ID"
        };
    };
    
    -- Vérification si déjà désactivé
    IF !$existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de remise déjà désactivé",
            data: $existing[0]
        };
    };
    
    -- Vérification de l'utilisation actuelle
    LET $usage_check = {
        order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id AND status IN ["DRAFT", "CONFIRMED"])[0] OR 0,
        order_line_usage: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id = $id)[0] OR 0,
        pack_line_usage: (SELECT VALUE count() FROM pack_line WHERE discount_type_id = $id)[0] OR 0
    };
    
    LET $total_active_usage = $usage_check.order_usage + $usage_check.order_line_usage + $usage_check.pack_line_usage;
    
    -- Avertissement si utilisation active
    LET $warning_message = IF $total_active_usage > 0 THEN
        "ATTENTION: Ce type de remise est actuellement utilisé dans " + string::concat($total_active_usage) + " enregistrement(s)"
    ELSE NONE END;
    
    -- Désactivation
    LET $deactivated = UPDATE $id SET 
        is_active = false,
        updated_on = time::now();
    
    -- Vérification de la désactivation
    IF !$deactivated {
        RETURN {
            success: false,
            error: "Erreur lors de la désactivation du type de remise",
            message: "Erreur système : désactivation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise désactivé avec succès",
        data: $deactivated[0],
        usage_warning: $warning_message,
        usage_details: $usage_check
    };
};

-- =====================================================
-- FONCTION: deactivate_discount_type_by_code
-- Description: Désactivation par code
-- =====================================================

DEFINE FUNCTION fn::deactivate_discount_type_by_code($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de remise est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Recherche du type par code
    LET $discount_type = SELECT VALUE id FROM discount_type WHERE code = $code LIMIT 1;
    
    -- Vérification de l'existence
    IF !$discount_type {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec ce code"
        };
    };
    
    -- Désactivation via la fonction principale
    RETURN fn::deactivate_discount_type($discount_type[0]);
};

-- =====================================================
-- FONCTION: deactivate_discount_type_safe
-- Description: Désactivation sécurisée avec vérifications
-- =====================================================

DEFINE FUNCTION fn::deactivate_discount_type_safe($id: record<discount_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de remise est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Vérification de l'existence
    LET $existing = SELECT * FROM $id;
    IF !$existing {
        RETURN {
            success: false,
            error: "Type de remise non trouvé",
            message: "Aucun type de remise trouvé avec cet ID"
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
    
    -- Vérification si déjà désactivé
    IF !$existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de remise déjà désactivé",
            data: $existing[0]
        };
    };
    
    -- Vérification stricte de l'utilisation
    LET $usage_check = {
        draft_orders: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id AND status = "DRAFT")[0] OR 0,
        confirmed_orders: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id AND status = "CONFIRMED")[0] OR 0,
        order_lines: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id = $id)[0] OR 0,
        pack_lines: (SELECT VALUE count() FROM pack_line WHERE discount_type_id = $id)[0] OR 0
    };
    
    -- Interdiction si utilisation active
    IF $usage_check.draft_orders > 0 OR $usage_check.confirmed_orders > 0 {
        RETURN {
            success: false,
            error: "Impossible de désactiver : type utilisé dans des commandes actives",
            message: "Erreur de contrainte : utilisation active détectée",
            usage_details: $usage_check
        };
    };
    
    -- Désactivation
    LET $deactivated = UPDATE $id SET 
        is_active = false,
        updated_on = time::now();
    
    -- Vérification de la désactivation
    IF !$deactivated {
        RETURN {
            success: false,
            error: "Erreur lors de la désactivation du type de remise",
            message: "Erreur système : désactivation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise désactivé avec succès (mode sécurisé)",
        data: $deactivated[0],
        usage_details: $usage_check
    };
};

-- =====================================================
-- FONCTION: batch_deactivate_discount_types
-- Description: Désactivation en lot
-- =====================================================

DEFINE FUNCTION fn::batch_deactivate_discount_types($ids: array<record<discount_type>>) {
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
        LET $result = fn::deactivate_discount_type($id);
        
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
        deactivated_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: batch_deactivate_discount_types_by_codes
-- Description: Désactivation en lot par codes
-- =====================================================

DEFINE FUNCTION fn::batch_deactivate_discount_types_by_codes($codes: array<string>) {
    -- Validation du paramètre
    IF !$codes OR array::len($codes) == 0 {
        RETURN {
            success: false,
            error: "La liste des codes est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : codes manquants"
        };
    };
    
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $code IN $codes {
        LET $result = fn::deactivate_discount_type_by_code($code);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                code: $code,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Désactivation en lot par codes terminée",
        total_requested: array::len($codes),
        success_count: $success_count,
        error_count: array::len($errors),
        deactivated_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: deactivate_expired_discount_types
-- Description: Désactivation des types expirés
-- =====================================================

DEFINE FUNCTION fn::deactivate_expired_discount_types() {
    -- Recherche des types expirés
    LET $expired_types = SELECT * FROM discount_type 
        WHERE is_active = true 
        AND valid_to IS NOT NONE 
        AND valid_to < time::now();
    
    -- Si aucun type expiré
    IF array::len($expired_types) == 0 {
        RETURN {
            success: true,
            message: "Aucun type de remise expiré trouvé",
            deactivated_count: 0,
            data: []
        };
    };
    
    -- Désactivation des types expirés
    LET $deactivated = UPDATE discount_type 
        SET is_active = false, updated_on = time::now()
        WHERE is_active = true 
        AND valid_to IS NOT NONE 
        AND valid_to < time::now();
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Types de remise expirés désactivés avec succès",
        deactivated_count: array::len($deactivated),
        data: $deactivated
    };
};

-- =====================================================
-- FONCTION: deactivate_unused_discount_types
-- Description: Désactivation des types non utilisés
-- =====================================================

DEFINE FUNCTION fn::deactivate_unused_discount_types($days_unused: int) {
    -- Validation du paramètre
    LET $check_days = $days_unused OR 90; -- 90 jours par défaut
    LET $cutoff_date = time::now() - duration::from_days($check_days);
    
    -- Recherche des types non utilisés
    LET $unused_types = SELECT * FROM discount_type 
        WHERE is_active = true 
        AND is_system = false
        AND updated_on < $cutoff_date
        AND id NOT IN (
            SELECT DISTINCT discount_type_id FROM sale_order 
            WHERE discount_type_id IS NOT NONE 
            AND creation_date >= $cutoff_date
        );
    
    -- Si aucun type non utilisé
    IF array::len($unused_types) == 0 {
        RETURN {
            success: true,
            message: "Aucun type de remise non utilisé trouvé",
            deactivated_count: 0,
            data: []
        };
    };
    
    -- Désactivation des types non utilisés
    LET $deactivated = UPDATE discount_type 
        SET is_active = false, updated_on = time::now()
        WHERE is_active = true 
        AND is_system = false
        AND updated_on < $cutoff_date
        AND id NOT IN (
            SELECT DISTINCT discount_type_id FROM sale_order 
            WHERE discount_type_id IS NOT NONE 
            AND creation_date >= $cutoff_date
        );
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Types de remise non utilisés désactivés avec succès",
        check_period_days: $check_days,
        deactivated_count: array::len($deactivated),
        data: $deactivated
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Désactivation simple:
   SELECT fn::deactivate_discount_type(discount_type:VOLUME);

2. Désactivation par code:
   SELECT fn::deactivate_discount_type_by_code("VOLUME");

3. Désactivation sécurisée:
   SELECT fn::deactivate_discount_type_safe(discount_type:VOLUME);

4. Désactivation en lot par IDs:
   SELECT fn::batch_deactivate_discount_types([
       discount_type:VOLUME,
       discount_type:PROMO
   ]);

5. Désactivation en lot par codes:
   SELECT fn::batch_deactivate_discount_types_by_codes([
       "VOLUME", "PROMO"
   ]);

6. Désactivation des types expirés:
   SELECT fn::deactivate_expired_discount_types();

7. Désactivation des types non utilisés:
   SELECT fn::deactivate_unused_discount_types(90); -- 90 jours

DIFFÉRENCES ENTRE LES MODES:

1. Mode Standard (deactivate_discount_type):
   - Désactive même si utilisé
   - Retourne des avertissements
   - Rapide et direct

2. Mode Sécurisé (deactivate_discount_type_safe):
   - Refuse si utilisé dans des commandes actives
   - Protège les types système
   - Contrôles stricts

3. Mode Automatique:
   - deactivate_expired_discount_types: Types expirés
   - deactivate_unused_discount_types: Types non utilisés

VÉRIFICATIONS D'UTILISATION:
- draft_orders: Commandes en brouillon
- confirmed_orders: Commandes confirmées
- order_lines: Lignes de commande
- pack_lines: Lignes de pack

PROTECTIONS:
- Types système : non désactivables
- Utilisation active : avertissements ou blocage
- Validation des paramètres
- Gestion des erreurs

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    usage_warning: string (si applicable),
    usage_details: object (détails d'utilisation),
    error: string (si erreur)
}
*/ 
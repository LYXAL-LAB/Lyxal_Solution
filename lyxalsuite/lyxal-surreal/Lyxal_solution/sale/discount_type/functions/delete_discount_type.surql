-- =====================================================
-- FONCTIONS DE SUPPRESSION: discount_type
-- Description: Fonctions pour supprimer les types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: delete_discount_type
-- Description: Suppression d'un type de remise
-- =====================================================

DEFINE FUNCTION fn::delete_discount_type($id: record<discount_type>) {
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
            error: "Les types système ne peuvent pas être supprimés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Vérification de l'utilisation dans les commandes
    LET $usage_check = {
        order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id)[0] OR 0,
        order_line_usage: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id = $id)[0] OR 0,
        pack_line_usage: (SELECT VALUE count() FROM pack_line WHERE discount_type_id = $id)[0] OR 0
    };
    
    LET $total_usage = $usage_check.order_usage + $usage_check.order_line_usage + $usage_check.pack_line_usage;
    
    -- Interdiction si utilisation détectée
    IF $total_usage > 0 {
        RETURN {
            success: false,
            error: "Impossible de supprimer : type utilisé dans " + string::concat($total_usage) + " enregistrement(s)",
            message: "Erreur de contrainte : utilisation détectée",
            usage_details: $usage_check
        };
    };
    
    -- Suppression
    DELETE $id;
    
    -- Vérification de la suppression
    LET $still_exists = SELECT * FROM $id;
    IF $still_exists {
        RETURN {
            success: false,
            error: "Erreur lors de la suppression du type de remise",
            message: "Erreur système : suppression échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise supprimé avec succès",
        deleted_discount_type: $existing[0]
    };
};

-- =====================================================
-- FONCTION: delete_discount_type_by_code
-- Description: Suppression par code
-- =====================================================

DEFINE FUNCTION fn::delete_discount_type_by_code($code: string) {
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
    
    -- Suppression via la fonction principale
    RETURN fn::delete_discount_type($discount_type[0]);
};

-- =====================================================
-- FONCTION: delete_discount_type_safe
-- Description: Suppression sécurisée avec vérifications étendues
-- =====================================================

DEFINE FUNCTION fn::delete_discount_type_safe($id: record<discount_type>) {
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
            error: "Les types système ne peuvent pas être supprimés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Vérification étendue de l'utilisation
    LET $usage_check = {
        -- Utilisation directe
        order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id)[0] OR 0,
        order_line_usage: (SELECT VALUE count() FROM sale_order_line WHERE discount_type_id = $id)[0] OR 0,
        pack_line_usage: (SELECT VALUE count() FROM pack_line WHERE discount_type_id = $id)[0] OR 0,
        
        -- Utilisation dans les brouillons
        draft_order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id AND status = "DRAFT")[0] OR 0,
        
        -- Utilisation dans les commandes confirmées
        confirmed_order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id AND status = "CONFIRMED")[0] OR 0,
        
        -- Utilisation dans les commandes finalisées
        finalized_order_usage: (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id AND status IN ["INVOICED", "DELIVERED"])[0] OR 0
    };
    
    LET $total_usage = $usage_check.order_usage + $usage_check.order_line_usage + $usage_check.pack_line_usage;
    
    -- Interdiction stricte si utilisation
    IF $total_usage > 0 {
        RETURN {
            success: false,
            error: "Impossible de supprimer : type utilisé dans " + string::concat($total_usage) + " enregistrement(s)",
            message: "Erreur de contrainte : utilisation détectée (mode sécurisé)",
            usage_details: $usage_check,
            recommendation: "Désactivez ce type au lieu de le supprimer"
        };
    };
    
    -- Vérification de l'inactivité
    IF $existing[0].is_active {
        RETURN {
            success: false,
            error: "Impossible de supprimer : type encore actif",
            message: "Erreur de contrainte : type actif (mode sécurisé)",
            recommendation: "Désactivez d'abord ce type avant de le supprimer"
        };
    };
    
    -- Suppression
    DELETE $id;
    
    -- Vérification de la suppression
    LET $still_exists = SELECT * FROM $id;
    IF $still_exists {
        RETURN {
            success: false,
            error: "Erreur lors de la suppression du type de remise",
            message: "Erreur système : suppression échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise supprimé avec succès (mode sécurisé)",
        deleted_discount_type: $existing[0]
    };
};

-- =====================================================
-- FONCTION: batch_delete_discount_types
-- Description: Suppression en lot
-- =====================================================

DEFINE FUNCTION fn::batch_delete_discount_types($ids: array<record<discount_type>>) {
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
        LET $result = fn::delete_discount_type($id);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.deleted_discount_type);
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
        message: "Suppression en lot terminée",
        total_requested: array::len($ids),
        success_count: $success_count,
        error_count: array::len($errors),
        deleted_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: batch_delete_discount_types_by_codes
-- Description: Suppression en lot par codes
-- =====================================================

DEFINE FUNCTION fn::batch_delete_discount_types_by_codes($codes: array<string>) {
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
        LET $result = fn::delete_discount_type_by_code($code);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.deleted_discount_type);
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
        message: "Suppression en lot par codes terminée",
        total_requested: array::len($codes),
        success_count: $success_count,
        error_count: array::len($errors),
        deleted_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: delete_unused_discount_types
-- Description: Suppression des types non utilisés
-- =====================================================

DEFINE FUNCTION fn::delete_unused_discount_types($days_unused: int, $force: bool) {
    -- Validation et paramètres par défaut
    LET $check_days = $days_unused OR 180; -- 180 jours par défaut
    LET $force_delete = $force OR false;
    LET $cutoff_date = time::now() - duration::from_days($check_days);
    
    -- Recherche des types non utilisés
    LET $unused_types = SELECT * FROM discount_type 
        WHERE is_system = false
        AND is_active = false
        AND updated_on < $cutoff_date
        AND id NOT IN (
            SELECT DISTINCT discount_type_id FROM sale_order 
            WHERE discount_type_id IS NOT NONE
        )
        AND id NOT IN (
            SELECT DISTINCT discount_type_id FROM sale_order_line 
            WHERE discount_type_id IS NOT NONE
        )
        AND id NOT IN (
            SELECT DISTINCT discount_type_id FROM pack_line 
            WHERE discount_type_id IS NOT NONE
        );
    
    -- Si aucun type non utilisé
    IF array::len($unused_types) == 0 {
        RETURN {
            success: true,
            message: "Aucun type de remise non utilisé trouvé",
            check_period_days: $check_days,
            deleted_count: 0,
            data: []
        };
    };
    
    -- Suppression si force activée
    IF $force_delete {
        LET $deleted_ids = [];
        FOR $type IN $unused_types {
            $deleted_ids = array::push($deleted_ids, $type.id);
        };
        
        DELETE discount_type WHERE id IN $deleted_ids;
        
        RETURN {
            success: true,
            message: "Types de remise non utilisés supprimés avec succès",
            check_period_days: $check_days,
            deleted_count: array::len($unused_types),
            data: $unused_types
        };
    } ELSE {
        -- Mode preview : retour des types qui seraient supprimés
        RETURN {
            success: true,
            message: "Types de remise non utilisés identifiés (mode preview)",
            check_period_days: $check_days,
            would_delete_count: array::len($unused_types),
            data: $unused_types,
            note: "Utilisez force=true pour effectuer la suppression"
        };
    };
};

-- =====================================================
-- FONCTION: cleanup_discount_types
-- Description: Nettoyage complet des types obsolètes
-- =====================================================

DEFINE FUNCTION fn::cleanup_discount_types($options: object) {
    -- Options par défaut
    LET $delete_expired = $options.delete_expired OR false;
    LET $delete_unused = $options.delete_unused OR false;
    LET $unused_days = $options.unused_days OR 180;
    LET $force = $options.force OR false;
    
    LET $results = {
        expired_deleted: [],
        unused_deleted: [],
        total_deleted: 0,
        errors: []
    };
    
    -- Suppression des types expirés
    IF $delete_expired {
        LET $expired_types = SELECT * FROM discount_type 
            WHERE is_system = false
            AND valid_to IS NOT NONE 
            AND valid_to < time::now()
            AND id NOT IN (
                SELECT DISTINCT discount_type_id FROM sale_order 
                WHERE discount_type_id IS NOT NONE
            );
        
        IF array::len($expired_types) > 0 AND $force {
            LET $expired_ids = [];
            FOR $type IN $expired_types {
                $expired_ids = array::push($expired_ids, $type.id);
            };
            
            DELETE discount_type WHERE id IN $expired_ids;
            $results.expired_deleted = $expired_types;
        } ELSE {
            $results.expired_deleted = $expired_types;
        };
    };
    
    -- Suppression des types non utilisés
    IF $delete_unused {
        LET $unused_result = fn::delete_unused_discount_types($unused_days, $force);
        $results.unused_deleted = $unused_result.data;
    };
    
    -- Calcul du total
    $results.total_deleted = array::len($results.expired_deleted) + array::len($results.unused_deleted);
    
    -- Retour
    RETURN {
        success: true,
        message: "Nettoyage des types de remise terminé",
        options: $options,
        results: $results,
        note: IF !$force THEN "Mode preview - utilisez force=true pour effectuer les suppressions" ELSE NONE END
    };
};

-- =====================================================
-- FONCTION: soft_delete_discount_type
-- Description: Suppression logique (désactivation)
-- =====================================================

DEFINE FUNCTION fn::soft_delete_discount_type($id: record<discount_type>) {
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
            error: "Les types système ne peuvent pas être supprimés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Désactivation (suppression logique)
    LET $soft_deleted = UPDATE $id SET 
        is_active = false,
        updated_on = time::now();
    
    -- Vérification de la désactivation
    IF !$soft_deleted {
        RETURN {
            success: false,
            error: "Erreur lors de la suppression logique du type de remise",
            message: "Erreur système : désactivation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise supprimé logiquement (désactivé) avec succès",
        data: $soft_deleted[0],
        note: "Le type reste dans la base mais est inactif"
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Suppression standard:
   SELECT fn::delete_discount_type(discount_type:VOLUME);

2. Suppression par code:
   SELECT fn::delete_discount_type_by_code("VOLUME");

3. Suppression sécurisée:
   SELECT fn::delete_discount_type_safe(discount_type:VOLUME);

4. Suppression en lot par IDs:
   SELECT fn::batch_delete_discount_types([
       discount_type:VOLUME,
       discount_type:PROMO
   ]);

5. Suppression en lot par codes:
   SELECT fn::batch_delete_discount_types_by_codes([
       "VOLUME", "PROMO"
   ]);

6. Suppression des types non utilisés:
   SELECT fn::delete_unused_discount_types(180, false); -- Preview
   SELECT fn::delete_unused_discount_types(180, true);  -- Exécution

7. Nettoyage complet:
   SELECT fn::cleanup_discount_types({
       delete_expired: true,
       delete_unused: true,
       unused_days: 180,
       force: false
   });

8. Suppression logique:
   SELECT fn::soft_delete_discount_type(discount_type:VOLUME);

MODES DE SUPPRESSION:

1. Standard (delete_discount_type):
   - Vérifie l'utilisation
   - Bloque si utilisé
   - Protège les types système

2. Sécurisé (delete_discount_type_safe):
   - Vérifications étendues
   - Bloque si actif
   - Contrôles stricts

3. Logique (soft_delete_discount_type):
   - Désactive au lieu de supprimer
   - Préserve les données
   - Maintient l'intégrité référentielle

4. Automatique:
   - delete_unused_discount_types: Types non utilisés
   - cleanup_discount_types: Nettoyage complet

PROTECTIONS:
- Types système : Non supprimables
- Utilisation active : Blocage de la suppression
- Intégrité référentielle : Vérification des relations
- Mode preview : Visualisation avant suppression

VÉRIFICATIONS D'UTILISATION:
- order_usage: Utilisation dans sale_order
- order_line_usage: Utilisation dans sale_order_line
- pack_line_usage: Utilisation dans pack_line
- Statuts des commandes : DRAFT, CONFIRMED, INVOICED, DELIVERED

RECOMMANDATIONS:
- Utilisez la suppression logique pour les types utilisés
- Préférez la désactivation à la suppression physique
- Utilisez le mode preview pour les suppressions automatiques
- Vérifiez l'utilisation avant la suppression

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    deleted_discount_type: object (si succès),
    usage_details: object (détails d'utilisation),
    recommendation: string (si applicable),
    error: string (si erreur)
}
*/ 
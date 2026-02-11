-- =====================================================
-- FONCTIONS DE SUPPRESSION: sale_order_line_type
-- Description: Suppression définitive des types de ligne
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: delete_sale_order_line_type
-- Description: Suppression définitive avec protection
-- =====================================================

DEFINE FUNCTION fn::delete_sale_order_line_type(
    $id: record<sale_order_line_type>,
    $force: bool
) {
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
    
    -- Protection des types système
    IF $existing[0].is_system {
        RETURN {
            success: false,
            error: "Les types système ne peuvent pas être supprimés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Vérification des permissions de suppression
    IF !$existing[0].allows_deletion {
        RETURN {
            success: false,
            error: "Ce type de ligne ne peut pas être supprimé",
            message: "Erreur de permission : suppression interdite"
        };
    };
    
    -- Vérification de l'utilisation actuelle
    LET $usage_count = SELECT VALUE count() FROM sale_order_line WHERE type_id = $id;
    IF $usage_count[0] > 0 AND !$force {
        RETURN {
            success: false,
            error: "Ce type de ligne est utilisé dans " + <string>$usage_count[0] + " ligne(s). Utilisez force=true pour forcer la suppression",
            message: "Erreur de contrainte : type en cours d'utilisation",
            usage_count: $usage_count[0],
            force_required: true
        };
    };
    
    -- Si suppression forcée avec utilisation, migration vers type par défaut
    IF $usage_count[0] > 0 AND $force {
        -- Recherche du type par défaut (NORMAL ou premier actif)
        LET $default_type = SELECT VALUE id FROM sale_order_line_type 
            WHERE is_active = true AND (code = "NORMAL" OR code = "DEFAULT")
            ORDER BY code = "NORMAL" DESC, sequence ASC 
            LIMIT 1;
        
        IF !$default_type {
            -- Si pas de type par défaut, prendre le premier actif
            $default_type = SELECT VALUE id FROM sale_order_line_type 
                WHERE is_active = true AND id != $id
                ORDER BY sequence ASC 
                LIMIT 1;
        };
        
        IF !$default_type {
            RETURN {
                success: false,
                error: "Impossible de supprimer : aucun type de remplacement disponible",
                message: "Erreur de contrainte : pas de type de remplacement"
            };
        };
        
        -- Migration des lignes existantes
        UPDATE sale_order_line SET 
            type_id = $default_type[0],
            updated_on = time::now()
        WHERE type_id = $id;
    };
    
    -- Suppression définitive
    DELETE $id;
    
    -- Vérification de la suppression
    LET $check_deleted = SELECT * FROM $id;
    IF $check_deleted {
        RETURN {
            success: false,
            error: "Erreur lors de la suppression du type de ligne",
            message: "Erreur système : suppression échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne supprimé définitivement",
        deleted_type: $existing[0],
        migrated_lines: IF $usage_count[0] > 0 THEN $usage_count[0] ELSE 0 END,
        replacement_type: IF $usage_count[0] > 0 THEN $default_type[0] ELSE NONE END
    };
};

-- =====================================================
-- FONCTION: delete_sale_order_line_type_by_code
-- Description: Suppression par code
-- =====================================================

DEFINE FUNCTION fn::delete_sale_order_line_type_by_code(
    $code: string,
    $force: bool
) {
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
    RETURN fn::delete_sale_order_line_type($type[0], $force);
};

-- =====================================================
-- FONCTION: cleanup_unused_sale_order_line_type
-- Description: Nettoyage des types inutilisés
-- =====================================================

DEFINE FUNCTION fn::cleanup_unused_sale_order_line_type() {
    -- Recherche des types inactifs et inutilisés
    LET $unused_types = SELECT * FROM sale_order_line_type 
        WHERE is_active = false 
        AND is_system = false 
        AND allows_deletion = true
        AND id NOT IN (SELECT DISTINCT type_id FROM sale_order_line WHERE type_id IS NOT NONE);
    
    -- Comptage avant nettoyage
    LET $cleanup_count = array::len($unused_types);
    
    -- Suppression des types inutilisés
    IF $cleanup_count > 0 {
        FOR $type IN $unused_types {
            DELETE $type.id;
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Nettoyage des types inutilisés terminé",
        cleaned_count: $cleanup_count,
        cleaned_types: $unused_types
    };
};

-- =====================================================
-- FONCTION: batch_delete_sale_order_line_types
-- Description: Suppression en lot
-- =====================================================

DEFINE FUNCTION fn::batch_delete_sale_order_line_types(
    $ids: array<record<sale_order_line_type>>,
    $force: bool
) {
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
    LET $total_migrated = 0;
    
    FOR $id IN $ids {
        LET $result = fn::delete_sale_order_line_type($id, $force);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $total_migrated = $total_migrated + ($result.migrated_lines OR 0);
            $results = array::push($results, $result.deleted_type);
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
        total_migrated_lines: $total_migrated,
        deleted_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: check_sale_order_line_type_can_be_deleted
-- Description: Vérification si un type peut être supprimé
-- =====================================================

DEFINE FUNCTION fn::check_sale_order_line_type_can_be_deleted($id: record<sale_order_line_type>) {
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
        is_system: $existing[0].is_system,
        allows_deletion: $existing[0].allows_deletion,
        usage_count: (SELECT VALUE count() FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        has_replacement: (SELECT VALUE count() FROM sale_order_line_type 
            WHERE is_active = true AND id != $id)[0] > 0
    };
    
    -- Évaluation des contraintes
    LET $can_delete = !$constraints.is_system 
        AND $constraints.allows_deletion;
    
    LET $can_delete_safely = $can_delete AND $constraints.usage_count == 0;
    LET $can_delete_with_force = $can_delete 
        AND $constraints.usage_count > 0 
        AND $constraints.has_replacement;
    
    -- Raisons d'impossibilité
    LET $blocking_reasons = [];
    IF $constraints.is_system {
        $blocking_reasons = array::push($blocking_reasons, "Type système protégé");
    };
    IF !$constraints.allows_deletion {
        $blocking_reasons = array::push($blocking_reasons, "Suppression interdite");
    };
    IF $constraints.usage_count > 0 AND !$constraints.has_replacement {
        $blocking_reasons = array::push($blocking_reasons, "Aucun type de remplacement disponible");
    };
    
    -- Avertissements
    LET $warnings = [];
    IF $constraints.usage_count > 0 {
        $warnings = array::push($warnings, "Type utilisé dans " + <string>$constraints.usage_count + " ligne(s)");
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Vérification effectuée",
        can_delete: $can_delete,
        can_delete_safely: $can_delete_safely,
        can_delete_with_force: $can_delete_with_force,
        constraints: $constraints,
        blocking_reasons: $blocking_reasons,
        warnings: $warnings
    };
};

-- =====================================================
-- FONCTION: get_sale_order_line_type_dependencies
-- Description: Analyse des dépendances avant suppression
-- =====================================================

DEFINE FUNCTION fn::get_sale_order_line_type_dependencies($id: record<sale_order_line_type>) {
    -- Validation du paramètre
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    -- Analyse des dépendances
    LET $dependencies = {
        sale_order_lines: (SELECT 
            sale_order_id,
            count() as line_count,
            sum(qty) as total_quantity,
            sum(in_tax_total) as total_amount
        FROM sale_order_line 
        WHERE type_id = $id 
        GROUP BY sale_order_id),
        
        recent_usage: (SELECT * FROM sale_order_line 
            WHERE type_id = $id 
            ORDER BY creation_date DESC 
            LIMIT 10),
        
        order_statuses: (SELECT DISTINCT so.status_select, count() as count
            FROM sale_order_line sol
            JOIN sale_order so ON sol.sale_order_id = so.id
            WHERE sol.type_id = $id
            GROUP BY so.status_select),
        
        date_range: {
            first_use: (SELECT VALUE min(creation_date) FROM sale_order_line WHERE type_id = $id)[0],
            last_use: (SELECT VALUE max(creation_date) FROM sale_order_line WHERE type_id = $id)[0]
        }
    };
    
    -- Statistiques de dépendance
    LET $stats = {
        total_lines: array::len($dependencies.sale_order_lines),
        total_orders: (SELECT VALUE count(DISTINCT sale_order_id) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        total_quantity: (SELECT VALUE sum(qty) FROM sale_order_line WHERE type_id = $id)[0] OR 0,
        total_amount: (SELECT VALUE sum(in_tax_total) FROM sale_order_line WHERE type_id = $id)[0] OR 0
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Analyse des dépendances effectuée",
        dependencies: $dependencies,
        stats: $stats
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Suppression simple:
   SELECT fn::delete_sale_order_line_type(sale_order_line_type:CUSTOM, false);

2. Suppression forcée:
   SELECT fn::delete_sale_order_line_type(sale_order_line_type:CUSTOM, true);

3. Suppression par code:
   SELECT fn::delete_sale_order_line_type_by_code("CUSTOM", false);

4. Nettoyage des types inutilisés:
   SELECT fn::cleanup_unused_sale_order_line_type();

5. Suppression en lot:
   SELECT fn::batch_delete_sale_order_line_types([
       sale_order_line_type:CUSTOM1,
       sale_order_line_type:CUSTOM2
   ], false);

6. Vérification de possibilité:
   SELECT fn::check_sale_order_line_type_can_be_deleted(
       sale_order_line_type:CUSTOM
   );

7. Analyse des dépendances:
   SELECT fn::get_sale_order_line_type_dependencies(
       sale_order_line_type:CUSTOM
   );

PROTECTIONS ET VALIDATIONS:
- Types système : suppression interdite
- Types en cours d'utilisation : force requise
- Permissions : respect du champ allows_deletion
- Migration automatique : vers type par défaut

SUPPRESSION FORCÉE:
- Migre automatiquement vers type par défaut
- Recherche NORMAL > DEFAULT > premier actif
- Maintient l'intégrité référentielle
- Fournit un rapport de migration

NETTOYAGE AUTOMATIQUE:
- Supprime les types inactifs inutilisés
- Respecte les protections système
- Vérifie les permissions de suppression
- Rapport détaillé des suppressions

ANALYSE DES DÉPENDANCES:
- Lignes de commande utilisant le type
- Commandes concernées par statut
- Utilisation récente et historique
- Statistiques financières

CONTRAINTES VÉRIFIÉES:
- is_system: Type système protégé
- allows_deletion: Permission de suppression
- usage_count: Nombre d'utilisations
- has_replacement: Disponibilité de remplacement

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    deleted_type: object (si succès),
    migrated_lines: int (si migration),
    replacement_type: record (si migration),
    error: string (si erreur)
}
*/ 
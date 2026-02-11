-- =====================================================
-- FONCTIONS D'ACTIVATION: discount_type
-- Description: Fonctions pour activer les types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: activate_discount_type
-- Description: Activation d'un type de remise
-- =====================================================

DEFINE FUNCTION fn::activate_discount_type($id: record<discount_type>) {
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
    
    -- Vérification si déjà activé
    IF $existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de remise déjà activé",
            data: $existing[0]
        };
    };
    
    -- Vérification de la validité temporelle
    LET $now = time::now();
    LET $validity_check = {
        is_valid_from: IF $existing[0].valid_from THEN $now >= $existing[0].valid_from ELSE true END,
        is_valid_to: IF $existing[0].valid_to THEN $now <= $existing[0].valid_to ELSE true END,
        is_currently_valid: true
    };
    
    $validity_check.is_currently_valid = $validity_check.is_valid_from AND $validity_check.is_valid_to;
    
    -- Avertissement si pas dans la période de validité
    LET $validity_warning = IF !$validity_check.is_currently_valid THEN
        "ATTENTION: Ce type de remise n'est pas dans sa période de validité"
    ELSE NONE END;
    
    -- Vérification de l'unicité de la séquence
    LET $sequence_conflict = SELECT VALUE id FROM discount_type 
        WHERE sequence = $existing[0].sequence 
        AND is_active = true 
        AND id != $id 
        LIMIT 1;
    
    IF $sequence_conflict {
        RETURN {
            success: false,
            error: "Impossible d'activer : un autre type actif utilise déjà cette séquence",
            message: "Erreur de contrainte : séquence en conflit",
            conflicting_id: $sequence_conflict[0]
        };
    };
    
    -- Activation
    LET $activated = UPDATE $id SET 
        is_active = true,
        updated_on = time::now();
    
    -- Vérification de l'activation
    IF !$activated {
        RETURN {
            success: false,
            error: "Erreur lors de l'activation du type de remise",
            message: "Erreur système : activation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise activé avec succès",
        data: $activated[0],
        validity_warning: $validity_warning,
        validity_check: $validity_check
    };
};

-- =====================================================
-- FONCTION: activate_discount_type_by_code
-- Description: Activation par code
-- =====================================================

DEFINE FUNCTION fn::activate_discount_type_by_code($code: string) {
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
    
    -- Activation via la fonction principale
    RETURN fn::activate_discount_type($discount_type[0]);
};

-- =====================================================
-- FONCTION: activate_discount_type_with_sequence
-- Description: Activation avec nouvelle séquence
-- =====================================================

DEFINE FUNCTION fn::activate_discount_type_with_sequence(
    $id: record<discount_type>,
    $new_sequence: int
) {
    -- Validation des paramètres
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de remise est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    IF !$new_sequence OR $new_sequence <= 0 {
        RETURN {
            success: false,
            error: "La nouvelle séquence doit être un nombre positif",
            message: "Erreur de validation : séquence invalide"
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
    
    -- Vérification de l'unicité de la nouvelle séquence
    LET $sequence_conflict = SELECT VALUE id FROM discount_type 
        WHERE sequence = $new_sequence 
        AND is_active = true 
        AND id != $id 
        LIMIT 1;
    
    IF $sequence_conflict {
        RETURN {
            success: false,
            error: "La nouvelle séquence est déjà utilisée par un autre type actif",
            message: "Erreur de contrainte : séquence en conflit",
            conflicting_id: $sequence_conflict[0]
        };
    };
    
    -- Mise à jour de la séquence et activation
    LET $activated = UPDATE $id SET 
        sequence = $new_sequence,
        is_active = true,
        updated_on = time::now();
    
    -- Vérification de l'activation
    IF !$activated {
        RETURN {
            success: false,
            error: "Erreur lors de l'activation du type de remise",
            message: "Erreur système : activation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise activé avec nouvelle séquence",
        data: $activated[0],
        old_sequence: $existing[0].sequence,
        new_sequence: $new_sequence
    };
};

-- =====================================================
-- FONCTION: batch_activate_discount_types
-- Description: Activation en lot
-- =====================================================

DEFINE FUNCTION fn::batch_activate_discount_types($ids: array<record<discount_type>>) {
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
        LET $result = fn::activate_discount_type($id);
        
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
        message: "Activation en lot terminée",
        total_requested: array::len($ids),
        success_count: $success_count,
        error_count: array::len($errors),
        activated_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: batch_activate_discount_types_by_codes
-- Description: Activation en lot par codes
-- =====================================================

DEFINE FUNCTION fn::batch_activate_discount_types_by_codes($codes: array<string>) {
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
        LET $result = fn::activate_discount_type_by_code($code);
        
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
        message: "Activation en lot par codes terminée",
        total_requested: array::len($codes),
        success_count: $success_count,
        error_count: array::len($errors),
        activated_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: activate_valid_discount_types
-- Description: Activation des types dans leur période de validité
-- =====================================================

DEFINE FUNCTION fn::activate_valid_discount_types() {
    -- Recherche des types valides mais inactifs
    LET $now = time::now();
    LET $valid_inactive_types = SELECT * FROM discount_type 
        WHERE is_active = false 
        AND (valid_from IS NONE OR valid_from <= $now)
        AND (valid_to IS NONE OR valid_to >= $now);
    
    -- Si aucun type valide inactif
    IF array::len($valid_inactive_types) == 0 {
        RETURN {
            success: true,
            message: "Aucun type de remise valide inactif trouvé",
            activated_count: 0,
            data: []
        };
    };
    
    -- Vérification des conflits de séquence
    LET $sequence_conflicts = [];
    FOR $type IN $valid_inactive_types {
        LET $conflict = SELECT VALUE id FROM discount_type 
            WHERE sequence = $type.sequence 
            AND is_active = true 
            AND id != $type.id 
            LIMIT 1;
        
        IF $conflict {
            $sequence_conflicts = array::push($sequence_conflicts, {
                type_id: $type.id,
                type_code: $type.code,
                sequence: $type.sequence,
                conflicting_id: $conflict[0]
            });
        };
    };
    
    -- Activation des types sans conflit
    LET $activated = UPDATE discount_type 
        SET is_active = true, updated_on = time::now()
        WHERE is_active = false 
        AND (valid_from IS NONE OR valid_from <= $now)
        AND (valid_to IS NONE OR valid_to >= $now)
        AND id NOT IN (SELECT VALUE type_id FROM $sequence_conflicts);
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Types de remise valides activés avec succès",
        activated_count: array::len($activated),
        sequence_conflicts_count: array::len($sequence_conflicts),
        data: $activated,
        sequence_conflicts: $sequence_conflicts
    };
};

-- =====================================================
-- FONCTION: toggle_discount_type_status
-- Description: Basculer le statut actif/inactif
-- =====================================================

DEFINE FUNCTION fn::toggle_discount_type_status($id: record<discount_type>) {
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
    
    -- Basculement selon le statut actuel
    IF $existing[0].is_active {
        RETURN fn::deactivate_discount_type($id);
    } ELSE {
        RETURN fn::activate_discount_type($id);
    };
};

-- =====================================================
-- FONCTION: reactivate_discount_type
-- Description: Réactivation avec vérifications complètes
-- =====================================================

DEFINE FUNCTION fn::reactivate_discount_type($id: record<discount_type>) {
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
    
    -- Vérification si déjà activé
    IF $existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de remise déjà activé",
            data: $existing[0]
        };
    };
    
    -- Vérifications complètes pour la réactivation
    LET $checks = {
        -- Validité temporelle
        is_valid_now: IF $existing[0].valid_from AND $existing[0].valid_to THEN
            (time::now() >= $existing[0].valid_from AND time::now() <= $existing[0].valid_to)
        ELSE IF $existing[0].valid_from THEN
            time::now() >= $existing[0].valid_from
        ELSE IF $existing[0].valid_to THEN
            time::now() <= $existing[0].valid_to
        ELSE true END,
        
        -- Conflit de séquence
        sequence_conflict: (SELECT VALUE id FROM discount_type 
            WHERE sequence = $existing[0].sequence 
            AND is_active = true 
            AND id != $id 
            LIMIT 1)[0],
        
        -- Limites d'utilisation
        usage_limit_reached: IF $existing[0].max_usage_count THEN
            (SELECT VALUE count() FROM sale_order WHERE discount_type_id = $id)[0] >= $existing[0].max_usage_count
        ELSE false END
    };
    
    -- Blocage si pas valide temporellement
    IF !$checks.is_valid_now {
        RETURN {
            success: false,
            error: "Impossible de réactiver : type hors de sa période de validité",
            message: "Erreur de contrainte : validité temporelle",
            validity_period: {
                valid_from: $existing[0].valid_from,
                valid_to: $existing[0].valid_to,
                current_time: time::now()
            }
        };
    };
    
    -- Blocage si conflit de séquence
    IF $checks.sequence_conflict {
        RETURN {
            success: false,
            error: "Impossible de réactiver : séquence utilisée par un autre type actif",
            message: "Erreur de contrainte : séquence en conflit",
            conflicting_id: $checks.sequence_conflict
        };
    };
    
    -- Avertissement si limite d'utilisation atteinte
    LET $usage_warning = IF $checks.usage_limit_reached THEN
        "ATTENTION: La limite d'utilisation de ce type a été atteinte"
    ELSE NONE END;
    
    -- Réactivation
    LET $reactivated = UPDATE $id SET 
        is_active = true,
        updated_on = time::now();
    
    -- Vérification de la réactivation
    IF !$reactivated {
        RETURN {
            success: false,
            error: "Erreur lors de la réactivation du type de remise",
            message: "Erreur système : réactivation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise réactivé avec succès",
        data: $reactivated[0],
        usage_warning: $usage_warning,
        checks: $checks
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Activation simple:
   SELECT fn::activate_discount_type(discount_type:VOLUME);

2. Activation par code:
   SELECT fn::activate_discount_type_by_code("VOLUME");

3. Activation avec nouvelle séquence:
   SELECT fn::activate_discount_type_with_sequence(
       discount_type:VOLUME, 25
   );

4. Activation en lot par IDs:
   SELECT fn::batch_activate_discount_types([
       discount_type:VOLUME,
       discount_type:PROMO
   ]);

5. Activation en lot par codes:
   SELECT fn::batch_activate_discount_types_by_codes([
       "VOLUME", "PROMO"
   ]);

6. Activation des types valides:
   SELECT fn::activate_valid_discount_types();

7. Basculement de statut:
   SELECT fn::toggle_discount_type_status(discount_type:VOLUME);

8. Réactivation complète:
   SELECT fn::reactivate_discount_type(discount_type:VOLUME);

VÉRIFICATIONS EFFECTUÉES:

1. Activation Standard:
   - Existence de l'enregistrement
   - Statut actuel
   - Conflits de séquence
   - Avertissements de validité

2. Activation avec Séquence:
   - Toutes les vérifications standard
   - Validation de la nouvelle séquence
   - Unicité de la séquence

3. Réactivation Complète:
   - Validité temporelle (bloquante)
   - Conflits de séquence (bloquants)
   - Limites d'utilisation (avertissement)
   - Contrôles complets

GESTION DES CONFLITS:
- Séquence : Vérification d'unicité parmi les types actifs
- Validité : Contrôle des dates valid_from/valid_to
- Utilisation : Surveillance des limites max_usage_count

MODES D'ACTIVATION:
- activate_discount_type: Standard avec avertissements
- activate_valid_discount_types: Automatique pour types valides
- reactivate_discount_type: Complet avec blocages stricts
- toggle_discount_type_status: Basculement intelligent

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    validity_warning: string (si applicable),
    validity_check: object (détails de validité),
    error: string (si erreur)
}
*/ 
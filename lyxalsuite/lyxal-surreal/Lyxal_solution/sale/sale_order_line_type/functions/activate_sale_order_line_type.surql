-- =====================================================
-- FONCTIONS D'ACTIVATION: sale_order_line_type
-- Description: Réactivation des types de ligne désactivés
-- Version: 1.0
-- =====================================================

-- =====================================================
-- FONCTION: activate_sale_order_line_type
-- Description: Activation d'un type par ID
-- =====================================================

DEFINE FUNCTION fn::activate_sale_order_line_type($id: record<sale_order_line_type>) {
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
    
    -- Vérification si déjà actif
    IF $existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de ligne déjà actif",
            data: $existing[0]
        };
    };
    
    -- Vérification des conflits potentiels avec le code
    LET $code_conflict = SELECT VALUE id FROM sale_order_line_type 
        WHERE code = $existing[0].code AND is_active = true LIMIT 1;
    IF $code_conflict {
        RETURN {
            success: false,
            error: "Un type de ligne actif avec ce code existe déjà",
            message: "Erreur de conflit : code déjà utilisé par un type actif",
            conflicting_id: $code_conflict[0]
        };
    };
    
    -- Vérification des conflits potentiels avec la séquence
    LET $sequence_conflict = SELECT VALUE id FROM sale_order_line_type 
        WHERE sequence = $existing[0].sequence AND is_active = true LIMIT 1;
    IF $sequence_conflict {
        RETURN {
            success: false,
            error: "Un type de ligne actif avec cette séquence existe déjà",
            message: "Erreur de conflit : séquence déjà utilisée par un type actif",
            conflicting_id: $sequence_conflict[0]
        };
    };
    
    -- Activation du type
    LET $activated_type = UPDATE $id SET 
        is_active = true,
        updated_on = time::now();
    
    -- Vérification de l'activation
    IF !$activated_type {
        RETURN {
            success: false,
            error: "Erreur lors de l'activation du type de ligne",
            message: "Erreur système : activation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne activé avec succès",
        data: $activated_type[0]
    };
};

-- =====================================================
-- FONCTION: activate_sale_order_line_type_by_code
-- Description: Activation d'un type par code
-- =====================================================

DEFINE FUNCTION fn::activate_sale_order_line_type_by_code($code: string) {
    -- Validation du paramètre
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code du type de ligne est obligatoire",
            message: "Erreur de validation : code manquant"
        };
    };
    
    -- Recherche du type par code (même inactif)
    LET $type = SELECT VALUE id FROM sale_order_line_type WHERE code = $code LIMIT 1;
    IF !$type {
        RETURN {
            success: false,
            error: "Type de ligne non trouvé",
            message: "Aucun type de ligne trouvé avec ce code"
        };
    };
    
    -- Délégation à la fonction principale
    RETURN fn::activate_sale_order_line_type($type[0]);
};

-- =====================================================
-- FONCTION: activate_sale_order_line_type_with_new_sequence
-- Description: Activation avec nouvelle séquence si conflit
-- =====================================================

DEFINE FUNCTION fn::activate_sale_order_line_type_with_new_sequence(
    $id: record<sale_order_line_type>,
    $new_sequence: int
) {
    -- Validation des paramètres
    IF !$id {
        RETURN {
            success: false,
            error: "L'ID du type de ligne est obligatoire",
            message: "Erreur de validation : ID manquant"
        };
    };
    
    IF !$new_sequence OR $new_sequence <= 0 {
        RETURN {
            success: false,
            error: "La nouvelle séquence est obligatoire et doit être positive",
            message: "Erreur de validation : séquence invalide"
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
    
    -- Vérification si déjà actif
    IF $existing[0].is_active {
        RETURN {
            success: true,
            message: "Type de ligne déjà actif",
            data: $existing[0]
        };
    };
    
    -- Vérification des conflits avec le code
    LET $code_conflict = SELECT VALUE id FROM sale_order_line_type 
        WHERE code = $existing[0].code AND is_active = true LIMIT 1;
    IF $code_conflict {
        RETURN {
            success: false,
            error: "Un type de ligne actif avec ce code existe déjà",
            message: "Erreur de conflit : code déjà utilisé par un type actif",
            conflicting_id: $code_conflict[0]
        };
    };
    
    -- Vérification des conflits avec la nouvelle séquence
    LET $sequence_conflict = SELECT VALUE id FROM sale_order_line_type 
        WHERE sequence = $new_sequence AND is_active = true LIMIT 1;
    IF $sequence_conflict {
        RETURN {
            success: false,
            error: "Un type de ligne actif avec cette séquence existe déjà",
            message: "Erreur de conflit : séquence déjà utilisée par un type actif",
            conflicting_id: $sequence_conflict[0]
        };
    };
    
    -- Activation du type avec nouvelle séquence
    LET $activated_type = UPDATE $id SET 
        is_active = true,
        sequence = $new_sequence,
        updated_on = time::now();
    
    -- Vérification de l'activation
    IF !$activated_type {
        RETURN {
            success: false,
            error: "Erreur lors de l'activation du type de ligne",
            message: "Erreur système : activation échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de ligne activé avec succès avec nouvelle séquence",
        data: $activated_type[0],
        old_sequence: $existing[0].sequence,
        new_sequence: $new_sequence
    };
};

-- =====================================================
-- FONCTION: batch_activate_sale_order_line_types
-- Description: Activation en lot
-- =====================================================

DEFINE FUNCTION fn::batch_activate_sale_order_line_types($ids: array<record<sale_order_line_type>>) {
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
        LET $result = fn::activate_sale_order_line_type($id);
        
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
        activated_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- FONCTION: check_sale_order_line_type_can_be_activated
-- Description: Vérification si un type peut être activé
-- =====================================================

DEFINE FUNCTION fn::check_sale_order_line_type_can_be_activated($id: record<sale_order_line_type>) {
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
        code_conflict: (SELECT VALUE count() FROM sale_order_line_type 
            WHERE code = $existing[0].code AND is_active = true LIMIT 1)[0] > 0,
        sequence_conflict: (SELECT VALUE count() FROM sale_order_line_type 
            WHERE sequence = $existing[0].sequence AND is_active = true LIMIT 1)[0] > 0
    };
    
    -- Évaluation des contraintes
    LET $can_activate = !$constraints.is_active 
        AND !$constraints.code_conflict 
        AND !$constraints.sequence_conflict;
    
    -- Raisons d'impossibilité
    LET $blocking_reasons = [];
    IF $constraints.is_active {
        $blocking_reasons = array::push($blocking_reasons, "Type déjà actif");
    };
    IF $constraints.code_conflict {
        $blocking_reasons = array::push($blocking_reasons, "Code déjà utilisé par un type actif");
    };
    IF $constraints.sequence_conflict {
        $blocking_reasons = array::push($blocking_reasons, "Séquence déjà utilisée par un type actif");
    };
    
    -- Suggestions de résolution
    LET $suggestions = [];
    IF $constraints.code_conflict {
        $suggestions = array::push($suggestions, "Modifier le code avant activation");
    };
    IF $constraints.sequence_conflict {
        LET $max_sequence = (SELECT VALUE max(sequence) FROM sale_order_line_type WHERE is_active = true)[0] OR 0;
        $suggestions = array::push($suggestions, "Utiliser la séquence " + <string>($max_sequence + 1));
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Vérification effectuée",
        can_activate: $can_activate,
        constraints: $constraints,
        blocking_reasons: $blocking_reasons,
        suggestions: $suggestions
    };
};

-- =====================================================
-- FONCTION: get_next_available_sequence
-- Description: Obtenir la prochaine séquence disponible
-- =====================================================

DEFINE FUNCTION fn::get_next_available_sequence() {
    -- Recherche de la séquence maximale actuelle
    LET $max_sequence = SELECT VALUE max(sequence) FROM sale_order_line_type WHERE is_active = true;
    
    -- Calcul de la prochaine séquence
    LET $next_sequence = ($max_sequence[0] OR 0) + 1;
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Prochaine séquence disponible calculée",
        next_sequence: $next_sequence,
        current_max: $max_sequence[0] OR 0
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Activation par ID:
   SELECT fn::activate_sale_order_line_type(sale_order_line_type:CUSTOM);

2. Activation par code:
   SELECT fn::activate_sale_order_line_type_by_code("CUSTOM");

3. Activation avec nouvelle séquence:
   SELECT fn::activate_sale_order_line_type_with_new_sequence(
       sale_order_line_type:CUSTOM, 15
   );

4. Activation en lot:
   SELECT fn::batch_activate_sale_order_line_types([
       sale_order_line_type:CUSTOM1,
       sale_order_line_type:CUSTOM2
   ]);

5. Vérification de possibilité:
   SELECT fn::check_sale_order_line_type_can_be_activated(
       sale_order_line_type:CUSTOM
   );

6. Prochaine séquence disponible:
   SELECT fn::get_next_available_sequence();

GESTION DES CONFLITS:
- Code unique : vérification avant activation
- Séquence unique : détection des conflits
- Résolution automatique : nouvelle séquence si conflit
- Suggestions : aide à la résolution manuelle

VALIDATIONS EFFECTUÉES:
- Existence de l'enregistrement
- Statut actuel (éviter double activation)
- Conflits de code avec types actifs
- Conflits de séquence avec types actifs
- Intégrité des données

STRATÉGIES DE RÉSOLUTION:
- Modification du code avant activation
- Attribution d'une nouvelle séquence
- Activation avec séquence spécifique
- Activation en lot avec gestion d'erreurs

CONTRAINTES VÉRIFIÉES:
- is_active: Type actuellement inactif
- code_conflict: Conflit de code avec type actif
- sequence_conflict: Conflit de séquence avec type actif

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    error: string (si erreur),
    conflicting_id: record (si conflit),
    suggestions: array (si applicable)
}
*/ 
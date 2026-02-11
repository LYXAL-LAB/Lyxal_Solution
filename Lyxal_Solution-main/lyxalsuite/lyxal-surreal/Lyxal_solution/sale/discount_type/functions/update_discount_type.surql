-- =====================================================
-- FONCTION: update_discount_type
-- Description: Mise à jour d'un type de remise
-- Version: 1.0
-- =====================================================

-- Fonction principale de mise à jour
DEFINE FUNCTION fn::update_discount_type(
    $id: record<discount_type>,
    $code: string,
    $name: string,
    $sequence: int,
    $calculation_method: string,
    $description: string,
    $symbol: string,
    $formula: string,
    $min_value: decimal,
    $max_value: decimal,
    $min_order_amount: decimal,
    $max_order_amount: decimal,
    $is_cumulative: bool,
    $is_automatic: bool,
    $requires_approval: bool,
    $applies_to_subtotal: bool,
    $applies_to_taxes: bool,
    $color: string,
    $icon: string,
    $valid_from: date,
    $valid_to: date,
    $max_usage_count: int,
    $max_usage_per_client: int
) {
    -- Validation du paramètre ID
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
    IF $existing[0].is_system AND ($code OR $name OR $calculation_method) {
        RETURN {
            success: false,
            error: "Les types système ne peuvent pas avoir leur code, nom ou méthode de calcul modifiés",
            message: "Erreur de permission : type système protégé"
        };
    };
    
    -- Validation du code (si fourni)
    IF $code {
        IF $code == "" {
            RETURN {
                success: false,
                error: "Le code ne peut pas être vide",
                message: "Erreur de validation : code vide"
            };
        };
        
        -- Vérification de l'unicité du code (si différent)
        IF $code != $existing[0].code {
            LET $existing_code = SELECT VALUE id FROM discount_type WHERE code = $code LIMIT 1;
            IF $existing_code {
                RETURN {
                    success: false,
                    error: "Un type de remise avec ce code existe déjà",
                    message: "Erreur de validation : code déjà utilisé",
                    existing_id: $existing_code[0]
                };
            };
        };
    };
    
    -- Validation du nom (si fourni)
    IF $name AND $name == "" {
        RETURN {
            success: false,
            error: "Le nom ne peut pas être vide",
            message: "Erreur de validation : nom vide"
        };
    };
    
    -- Validation de la séquence (si fournie)
    IF $sequence {
        IF $sequence <= 0 {
            RETURN {
                success: false,
                error: "La séquence doit être positive",
                message: "Erreur de validation : séquence invalide"
            };
        };
        
        -- Vérification de l'unicité de la séquence (si différente)
        IF $sequence != $existing[0].sequence {
            LET $existing_sequence = SELECT VALUE id FROM discount_type WHERE sequence = $sequence LIMIT 1;
            IF $existing_sequence {
                RETURN {
                    success: false,
                    error: "Un type de remise avec cette séquence existe déjà",
                    message: "Erreur de validation : séquence déjà utilisée",
                    existing_id: $existing_sequence[0]
                };
            };
        };
    };
    
    -- Validation de la méthode de calcul (si fournie)
    IF $calculation_method AND !($calculation_method IN ["FIXED", "PERCENT", "FORMULA"]) {
        RETURN {
            success: false,
            error: "La méthode de calcul doit être FIXED, PERCENT ou FORMULA",
            message: "Erreur de validation : méthode de calcul invalide"
        };
    };
    
    -- Validation de la couleur (si fournie)
    IF $color AND !string::starts_with($color, "#") {
        RETURN {
            success: false,
            error: "La couleur doit être un code hexadécimal valide (ex: #FF0000)",
            message: "Erreur de validation : format de couleur invalide"
        };
    };
    
    -- Validation des valeurs
    LET $final_min_value = $min_value OR $existing[0].min_value;
    LET $final_max_value = $max_value OR $existing[0].max_value;
    
    IF $final_min_value AND $final_max_value AND $final_max_value < $final_min_value {
        RETURN {
            success: false,
            error: "La valeur maximale doit être supérieure ou égale à la valeur minimale",
            message: "Erreur de validation : valeurs incohérentes"
        };
    };
    
    -- Validation des montants de commande
    LET $final_min_order = $min_order_amount OR $existing[0].min_order_amount;
    LET $final_max_order = $max_order_amount OR $existing[0].max_order_amount;
    
    IF $final_min_order AND $final_max_order AND $final_max_order < $final_min_order {
        RETURN {
            success: false,
            error: "Le montant maximum de commande doit être supérieur ou égal au montant minimum",
            message: "Erreur de validation : montants incohérents"
        };
    };
    
    -- Validation des dates de validité
    LET $final_valid_from = $valid_from OR $existing[0].valid_from;
    LET $final_valid_to = $valid_to OR $existing[0].valid_to;
    
    IF $final_valid_from AND $final_valid_to AND $final_valid_to < $final_valid_from {
        RETURN {
            success: false,
            error: "La date de fin de validité doit être postérieure à la date de début",
            message: "Erreur de validation : dates incohérentes"
        };
    };
    
    -- Validation des compteurs d'utilisation
    IF $max_usage_count AND $max_usage_count <= 0 {
        RETURN {
            success: false,
            error: "Le nombre maximum d'utilisations doit être positif",
            message: "Erreur de validation : compteur invalide"
        };
    };
    
    IF $max_usage_per_client AND $max_usage_per_client <= 0 {
        RETURN {
            success: false,
            error: "Le nombre maximum d'utilisations par client doit être positif",
            message: "Erreur de validation : compteur par client invalide"
        };
    };
    
    -- Préparation de l'objet de mise à jour
    LET $update_data = {};
    
    -- Ajout conditionnel des champs à mettre à jour
    IF $code { $update_data.code = $code; };
    IF $name { $update_data.name = $name; };
    IF $sequence { $update_data.sequence = $sequence; };
    IF $calculation_method { $update_data.calculation_method = $calculation_method; };
    IF $description != NONE { $update_data.description = $description; };
    IF $symbol { $update_data.symbol = $symbol; };
    IF $formula != NONE { $update_data.formula = $formula; };
    IF $min_value != NONE { $update_data.min_value = $min_value; };
    IF $max_value != NONE { $update_data.max_value = $max_value; };
    IF $min_order_amount != NONE { $update_data.min_order_amount = $min_order_amount; };
    IF $max_order_amount != NONE { $update_data.max_order_amount = $max_order_amount; };
    IF $is_cumulative != NONE { $update_data.is_cumulative = $is_cumulative; };
    IF $is_automatic != NONE { $update_data.is_automatic = $is_automatic; };
    IF $requires_approval != NONE { $update_data.requires_approval = $requires_approval; };
    IF $applies_to_subtotal != NONE { $update_data.applies_to_subtotal = $applies_to_subtotal; };
    IF $applies_to_taxes != NONE { $update_data.applies_to_taxes = $applies_to_taxes; };
    IF $color { $update_data.color = $color; };
    IF $icon { $update_data.icon = $icon; };
    IF $valid_from != NONE { $update_data.valid_from = $valid_from; };
    IF $valid_to != NONE { $update_data.valid_to = $valid_to; };
    IF $max_usage_count != NONE { $update_data.max_usage_count = $max_usage_count; };
    IF $max_usage_per_client != NONE { $update_data.max_usage_per_client = $max_usage_per_client; };
    
    -- Mise à jour du timestamp
    $update_data.updated_on = time::now();
    
    -- Vérification qu'il y a quelque chose à mettre à jour
    IF object::len($update_data) == 1 { -- Seulement updated_on
        RETURN {
            success: true,
            message: "Aucune modification à effectuer",
            data: $existing[0]
        };
    };
    
    -- Mise à jour de l'enregistrement
    LET $updated_discount_type = UPDATE $id MERGE $update_data;
    
    -- Vérification de la mise à jour
    IF !$updated_discount_type {
        RETURN {
            success: false,
            error: "Erreur lors de la mise à jour du type de remise",
            message: "Erreur système : mise à jour échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise mis à jour avec succès",
        data: $updated_discount_type[0],
        updated_fields: object::keys($update_data)
    };
};

-- =====================================================
-- FONCTION: update_discount_type_partial
-- Description: Mise à jour partielle avec objet
-- =====================================================

DEFINE FUNCTION fn::update_discount_type_partial(
    $id: record<discount_type>,
    $updates: object
) {
    RETURN fn::update_discount_type(
        $id,
        $updates.code,
        $updates.name,
        $updates.sequence,
        $updates.calculation_method,
        $updates.description,
        $updates.symbol,
        $updates.formula,
        $updates.min_value,
        $updates.max_value,
        $updates.min_order_amount,
        $updates.max_order_amount,
        $updates.is_cumulative,
        $updates.is_automatic,
        $updates.requires_approval,
        $updates.applies_to_subtotal,
        $updates.applies_to_taxes,
        $updates.color,
        $updates.icon,
        $updates.valid_from,
        $updates.valid_to,
        $updates.max_usage_count,
        $updates.max_usage_per_client
    );
};

-- =====================================================
-- FONCTION: update_discount_type_sequence
-- Description: Mise à jour de la séquence uniquement
-- =====================================================

DEFINE FUNCTION fn::update_discount_type_sequence(
    $id: record<discount_type>,
    $new_sequence: int
) {
    RETURN fn::update_discount_type(
        $id,
        NONE, NONE, $new_sequence, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_discount_type_display
-- Description: Mise à jour des éléments d'affichage
-- =====================================================

DEFINE FUNCTION fn::update_discount_type_display(
    $id: record<discount_type>,
    $color: string,
    $icon: string
) {
    RETURN fn::update_discount_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, $color, $icon, NONE, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_discount_type_validity
-- Description: Mise à jour des dates de validité
-- =====================================================

DEFINE FUNCTION fn::update_discount_type_validity(
    $id: record<discount_type>,
    $valid_from: date,
    $valid_to: date
) {
    RETURN fn::update_discount_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, $valid_from, $valid_to, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_discount_type_limits
-- Description: Mise à jour des limites de valeur
-- =====================================================

DEFINE FUNCTION fn::update_discount_type_limits(
    $id: record<discount_type>,
    $min_value: decimal,
    $max_value: decimal,
    $min_order_amount: decimal,
    $max_order_amount: decimal
) {
    RETURN fn::update_discount_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, $min_value, $max_value, $min_order_amount, $max_order_amount, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: update_discount_type_behavior
-- Description: Mise à jour du comportement
-- =====================================================

DEFINE FUNCTION fn::update_discount_type_behavior(
    $id: record<discount_type>,
    $is_cumulative: bool,
    $is_automatic: bool,
    $requires_approval: bool,
    $applies_to_subtotal: bool,
    $applies_to_taxes: bool
) {
    RETURN fn::update_discount_type(
        $id,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, $is_cumulative, $is_automatic, $requires_approval, $applies_to_subtotal, $applies_to_taxes, NONE, NONE, NONE, NONE, NONE, NONE
    );
};

-- =====================================================
-- FONCTION: batch_update_discount_types
-- Description: Mise à jour en lot
-- =====================================================

DEFINE FUNCTION fn::batch_update_discount_types($updates: array<object>) {
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $update IN $updates {
        IF !$update.id {
            $errors = array::push($errors, {
                error: "ID manquant",
                update: $update
            });
            CONTINUE;
        };
        
        LET $result = fn::update_discount_type_partial($update.id, $update);
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                id: $update.id,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Mise à jour en lot terminée",
        total_requested: array::len($updates),
        success_count: $success_count,
        error_count: array::len($errors),
        updated_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Mise à jour complète:
   SELECT fn::update_discount_type(
       discount_type:VOLUME,
       "VOLUME_NEW", "Nouvelle remise volume", 15, "PERCENT",
       "Description mise à jour", "%", "", 10, 50, 500, 5000,
       true, false, true, true, false, "#28a745", "TrendingDown",
       "2024-01-01", "2024-12-31", 100, 5
   );

2. Mise à jour partielle:
   SELECT fn::update_discount_type_partial(
       discount_type:VOLUME,
       {
           name: "Nouveau nom",
           color: "#007bff",
           description: "Nouvelle description"
       }
   );

3. Mise à jour séquence:
   SELECT fn::update_discount_type_sequence(discount_type:VOLUME, 20);

4. Mise à jour affichage:
   SELECT fn::update_discount_type_display(
       discount_type:VOLUME, "#28a745", "Tag"
   );

5. Mise à jour validité:
   SELECT fn::update_discount_type_validity(
       discount_type:VOLUME, "2024-01-01", "2024-12-31"
   );

6. Mise à jour limites:
   SELECT fn::update_discount_type_limits(
       discount_type:VOLUME, 5, 50, 100, 10000
   );

7. Mise à jour comportement:
   SELECT fn::update_discount_type_behavior(
       discount_type:VOLUME, true, false, true, true, false
   );

8. Mise à jour en lot:
   SELECT fn::batch_update_discount_types([
       {id: discount_type:VOLUME, name: "Nouveau nom 1"},
       {id: discount_type:PROMO, color: "#007bff"}
   ]);

VALIDATIONS EFFECTUÉES:
- Existence de l'enregistrement
- Protection des types système
- Unicité du code et de la séquence
- Méthode de calcul valide
- Format de couleur hexadécimal
- Cohérence des valeurs min/max
- Cohérence des montants de commande
- Cohérence des dates de validité
- Compteurs d'utilisation positifs

PROTECTIONS:
- Types système : code, nom et méthode non modifiables
- Unicité : vérification des doublons
- Cohérence : validation des données liées
- Intégrité : maintien des contraintes métier

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    updated_fields: array (champs modifiés),
    error: string (si erreur)
}
*/ 
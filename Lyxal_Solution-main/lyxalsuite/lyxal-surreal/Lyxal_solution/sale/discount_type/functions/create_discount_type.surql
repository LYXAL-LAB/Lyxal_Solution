-- =====================================================
-- FONCTION: create_discount_type
-- Description: Création d'un nouveau type de remise
-- Version: 1.0
-- =====================================================

-- Fonction principale de création
DEFINE FUNCTION fn::create_discount_type(
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
    -- Validation des paramètres obligatoires
    IF !$code OR $code == "" {
        RETURN {
            success: false,
            error: "Le code est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : code manquant"
        };
    };
    
    IF !$name OR $name == "" {
        RETURN {
            success: false,
            error: "Le nom est obligatoire et ne peut pas être vide",
            message: "Erreur de validation : nom manquant"
        };
    };
    
    IF !$sequence OR $sequence <= 0 {
        RETURN {
            success: false,
            error: "La séquence est obligatoire et doit être positive",
            message: "Erreur de validation : séquence invalide"
        };
    };
    
    IF !$calculation_method OR !($calculation_method IN ["FIXED", "PERCENT", "FORMULA"]) {
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
    
    -- Validation des valeurs min/max
    IF $min_value AND $max_value AND $max_value < $min_value {
        RETURN {
            success: false,
            error: "La valeur maximale doit être supérieure ou égale à la valeur minimale",
            message: "Erreur de validation : valeurs incohérentes"
        };
    };
    
    -- Validation des montants de commande
    IF $min_order_amount AND $max_order_amount AND $max_order_amount < $min_order_amount {
        RETURN {
            success: false,
            error: "Le montant maximum de commande doit être supérieur ou égal au montant minimum",
            message: "Erreur de validation : montants de commande incohérents"
        };
    };
    
    -- Validation des dates de validité
    IF $valid_from AND $valid_to AND $valid_to < $valid_from {
        RETURN {
            success: false,
            error: "La date de fin de validité doit être postérieure à la date de début",
            message: "Erreur de validation : dates de validité incohérentes"
        };
    };
    
    -- Validation des compteurs d'utilisation
    IF $max_usage_count AND $max_usage_count <= 0 {
        RETURN {
            success: false,
            error: "Le nombre maximum d'utilisations doit être positif",
            message: "Erreur de validation : compteur d'utilisation invalide"
        };
    };
    
    IF $max_usage_per_client AND $max_usage_per_client <= 0 {
        RETURN {
            success: false,
            error: "Le nombre maximum d'utilisations par client doit être positif",
            message: "Erreur de validation : compteur par client invalide"
        };
    };
    
    -- Vérification de l'unicité du code
    LET $existing_code = SELECT VALUE id FROM discount_type WHERE code = $code LIMIT 1;
    IF $existing_code {
        RETURN {
            success: false,
            error: "Un type de remise avec ce code existe déjà",
            message: "Erreur de validation : code déjà utilisé",
            existing_id: $existing_code[0]
        };
    };
    
    -- Vérification de l'unicité de la séquence
    LET $existing_sequence = SELECT VALUE id FROM discount_type WHERE sequence = $sequence LIMIT 1;
    IF $existing_sequence {
        RETURN {
            success: false,
            error: "Un type de remise avec cette séquence existe déjà",
            message: "Erreur de validation : séquence déjà utilisée",
            existing_id: $existing_sequence[0]
        };
    };
    
    -- Préparation des valeurs avec défauts
    LET $final_description = $description OR "";
    LET $final_symbol = $symbol OR (IF $calculation_method = "PERCENT" THEN "%" ELSE "€" END);
    LET $final_formula = $formula OR "";
    LET $final_is_cumulative = IF $is_cumulative != NONE THEN $is_cumulative ELSE false END;
    LET $final_is_automatic = IF $is_automatic != NONE THEN $is_automatic ELSE false END;
    LET $final_requires_approval = IF $requires_approval != NONE THEN $requires_approval ELSE false END;
    LET $final_applies_to_subtotal = IF $applies_to_subtotal != NONE THEN $applies_to_subtotal ELSE true END;
    LET $final_applies_to_taxes = IF $applies_to_taxes != NONE THEN $applies_to_taxes ELSE false END;
    LET $final_color = $color OR "#007bff";
    LET $final_icon = $icon OR "Percent";
    
    -- Création de l'enregistrement
    LET $new_discount_type = CREATE discount_type CONTENT {
        code: $code,
        name: $name,
        description: $final_description,
        sequence: $sequence,
        calculation_method: $calculation_method,
        symbol: $final_symbol,
        formula: $final_formula,
        min_value: $min_value,
        max_value: $max_value,
        min_order_amount: $min_order_amount,
        max_order_amount: $max_order_amount,
        is_cumulative: $final_is_cumulative,
        is_automatic: $final_is_automatic,
        requires_approval: $final_requires_approval,
        applies_to_subtotal: $final_applies_to_subtotal,
        applies_to_taxes: $final_applies_to_taxes,
        color: $final_color,
        icon: $final_icon,
        valid_from: $valid_from,
        valid_to: $valid_to,
        max_usage_count: $max_usage_count,
        max_usage_per_client: $max_usage_per_client,
        is_active: true,
        is_system: false,
        created_on: time::now(),
        updated_on: time::now()
    };
    
    -- Vérification de la création
    IF !$new_discount_type {
        RETURN {
            success: false,
            error: "Erreur lors de la création du type de remise",
            message: "Erreur système : création échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Type de remise créé avec succès",
        data: $new_discount_type[0]
    };
};

-- =====================================================
-- FONCTION: create_discount_type_simple
-- Description: Création simplifiée avec paramètres minimaux
-- =====================================================

DEFINE FUNCTION fn::create_discount_type_simple(
    $code: string,
    $name: string,
    $sequence: int,
    $calculation_method: string
) {
    RETURN fn::create_discount_type(
        $code,
        $name,
        $sequence,
        $calculation_method,
        NONE,  -- description
        NONE,  -- symbol (auto)
        NONE,  -- formula
        NONE,  -- min_value
        NONE,  -- max_value
        NONE,  -- min_order_amount
        NONE,  -- max_order_amount
        NONE,  -- is_cumulative (défaut: false)
        NONE,  -- is_automatic (défaut: false)
        NONE,  -- requires_approval (défaut: false)
        NONE,  -- applies_to_subtotal (défaut: true)
        NONE,  -- applies_to_taxes (défaut: false)
        NONE,  -- color (défaut: #007bff)
        NONE,  -- icon (défaut: Percent)
        NONE,  -- valid_from
        NONE,  -- valid_to
        NONE,  -- max_usage_count
        NONE   -- max_usage_per_client
    );
};

-- =====================================================
-- FONCTION: create_discount_type_with_config
-- Description: Création avec configuration comportementale
-- =====================================================

DEFINE FUNCTION fn::create_discount_type_with_config(
    $code: string,
    $name: string,
    $sequence: int,
    $calculation_method: string,
    $config: object
) {
    RETURN fn::create_discount_type(
        $code,
        $name,
        $sequence,
        $calculation_method,
        $config.description,
        $config.symbol,
        $config.formula,
        $config.min_value,
        $config.max_value,
        $config.min_order_amount,
        $config.max_order_amount,
        $config.is_cumulative,
        $config.is_automatic,
        $config.requires_approval,
        $config.applies_to_subtotal,
        $config.applies_to_taxes,
        $config.color,
        $config.icon,
        $config.valid_from,
        $config.valid_to,
        $config.max_usage_count,
        $config.max_usage_per_client
    );
};

-- =====================================================
-- FONCTION: batch_create_discount_types
-- Description: Création en lot de plusieurs types
-- =====================================================

DEFINE FUNCTION fn::batch_create_discount_types($discount_types: array<object>) {
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $discount_type IN $discount_types {
        LET $result = fn::create_discount_type_with_config(
            $discount_type.code,
            $discount_type.name,
            $discount_type.sequence,
            $discount_type.calculation_method,
            $discount_type
        );
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                code: $discount_type.code,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Création en lot terminée",
        total_requested: array::len($discount_types),
        success_count: $success_count,
        error_count: array::len($errors),
        created_discount_types: $results,
        errors: $errors
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Création complète:
   SELECT fn::create_discount_type(
       "VOLUME_DISCOUNT", "Remise volume", 10, "PERCENT", 
       "Remise pour commandes importantes", "%", "",
       5, 25, 1000, NONE, false, false, true, true, false,
       "#28a745", "TrendingDown", NONE, NONE, NONE, NONE
   );

2. Création simple:
   SELECT fn::create_discount_type_simple("BASIC", "Remise basique", 5, "FIXED");

3. Création avec configuration:
   SELECT fn::create_discount_type_with_config("PROMO", "Promotion", 15, "PERCENT", {
       description: "Remise promotionnelle temporaire",
       symbol: "%",
       min_value: 5,
       max_value: 50,
       color: "#dc3545",
       icon: "Tag",
       valid_from: "2024-01-01",
       valid_to: "2024-12-31"
   });

4. Création en lot:
   SELECT fn::batch_create_discount_types([
       {code: "DISCOUNT1", name: "Remise 1", sequence: 1, calculation_method: "FIXED"},
       {code: "DISCOUNT2", name: "Remise 2", sequence: 2, calculation_method: "PERCENT"}
   ]);

VALIDATIONS EFFECTUÉES:
- Code obligatoire et unique
- Nom obligatoire
- Séquence positive et unique
- Méthode de calcul valide (FIXED, PERCENT, FORMULA)
- Format de couleur hexadécimal
- Cohérence des valeurs min/max
- Cohérence des montants de commande
- Cohérence des dates de validité
- Compteurs d'utilisation positifs

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    error: string (si erreur)
}
*/ 
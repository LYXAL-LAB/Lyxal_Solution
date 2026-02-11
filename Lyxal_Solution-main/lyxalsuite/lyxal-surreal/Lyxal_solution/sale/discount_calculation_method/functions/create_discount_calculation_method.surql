-- =====================================================
-- FONCTION: create_discount_calculation_method
-- Description: Création d'une nouvelle méthode de calcul de remise
-- Version: 1.0
-- =====================================================

-- Fonction principale de création
DEFINE FUNCTION fn::create_discount_calculation_method(
    $code: string,
    $name: string,
    $sequence: int,
    $calculation_type: string,
    $description: string,
    $calculation_subtype: string,
    $calculation_formula: string,
    $supports_fixed_amount: bool,
    $supports_percentage: bool,
    $supports_formula: bool,
    $supports_currency: bool,
    $default_symbol: string,
    $uses_currency_symbol: bool,
    $display_format: string,
    $min_value: decimal,
    $max_value: decimal,
    $decimal_precision: int,
    $validation_rules: string,
    $applies_to_subtotal: bool,
    $applies_to_taxes: bool,
    $applies_to_fees: bool,
    $can_be_cumulated: bool,
    $color: string,
    $icon: string,
    $display_category: string,
    $requires_approval: bool,
    $approval_level: string,
    $restricted_usage: bool,
    $allowed_roles: array<string>,
    $calculation_class: string,
    $configuration_params: object,
    $cache_enabled: bool,
    $cache_duration: int,
    $version: string
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
    
    IF !$calculation_type OR !($calculation_type IN ["FIXED", "PERCENT", "FORMULA", "TIERED", "CONDITIONAL"]) {
        RETURN {
            success: false,
            error: "Le type de calcul doit être FIXED, PERCENT, FORMULA, TIERED ou CONDITIONAL",
            message: "Erreur de validation : type de calcul invalide"
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
    
    -- Validation de la précision décimale
    IF $decimal_precision AND ($decimal_precision < 0 OR $decimal_precision > 10) {
        RETURN {
            success: false,
            error: "La précision décimale doit être entre 0 et 10",
            message: "Erreur de validation : précision invalide"
        };
    };
    
    -- Validation de la durée de cache
    IF $cache_duration AND $cache_duration <= 0 {
        RETURN {
            success: false,
            error: "La durée de cache doit être positive",
            message: "Erreur de validation : durée de cache invalide"
        };
    };
    
    -- Validation qu'au moins un type de support est activé
    IF !$supports_fixed_amount AND !$supports_percentage AND !$supports_formula {
        RETURN {
            success: false,
            error: "Au moins un type de support doit être activé (montant fixe, pourcentage ou formule)",
            message: "Erreur de validation : aucun support activé"
        };
    };
    
    -- Vérification de l'unicité du code
    LET $existing_code = SELECT VALUE id FROM discount_calculation_method WHERE code = $code LIMIT 1;
    IF $existing_code {
        RETURN {
            success: false,
            error: "Une méthode de calcul avec ce code existe déjà",
            message: "Erreur de validation : code déjà utilisé",
            existing_id: $existing_code[0]
        };
    };
    
    -- Vérification de l'unicité de la séquence
    LET $existing_sequence = SELECT VALUE id FROM discount_calculation_method WHERE sequence = $sequence LIMIT 1;
    IF $existing_sequence {
        RETURN {
            success: false,
            error: "Une méthode de calcul avec cette séquence existe déjà",
            message: "Erreur de validation : séquence déjà utilisée",
            existing_id: $existing_sequence[0]
        };
    };
    
    -- Préparation des valeurs avec défauts
    LET $final_description = $description OR "";
    LET $final_calculation_subtype = $calculation_subtype OR "SIMPLE";
    LET $final_calculation_formula = $calculation_formula OR "";
    LET $final_supports_fixed_amount = IF $supports_fixed_amount != NONE THEN $supports_fixed_amount ELSE false END;
    LET $final_supports_percentage = IF $supports_percentage != NONE THEN $supports_percentage ELSE false END;
    LET $final_supports_formula = IF $supports_formula != NONE THEN $supports_formula ELSE false END;
    LET $final_supports_currency = IF $supports_currency != NONE THEN $supports_currency ELSE false END;
    LET $final_default_symbol = $default_symbol OR (IF $final_supports_percentage THEN "%" ELSE "€" END);
    LET $final_uses_currency_symbol = IF $uses_currency_symbol != NONE THEN $uses_currency_symbol ELSE $final_supports_currency END;
    LET $final_display_format = $display_format OR "{value} {symbol}";
    LET $final_decimal_precision = $decimal_precision OR 2;
    LET $final_validation_rules = $validation_rules OR "";
    LET $final_applies_to_subtotal = IF $applies_to_subtotal != NONE THEN $applies_to_subtotal ELSE true END;
    LET $final_applies_to_taxes = IF $applies_to_taxes != NONE THEN $applies_to_taxes ELSE false END;
    LET $final_applies_to_fees = IF $applies_to_fees != NONE THEN $applies_to_fees ELSE false END;
    LET $final_can_be_cumulated = IF $can_be_cumulated != NONE THEN $can_be_cumulated ELSE false END;
    LET $final_color = $color OR "#007bff";
    LET $final_icon = $icon OR "Calculator";
    LET $final_display_category = $display_category OR "STANDARD";
    LET $final_requires_approval = IF $requires_approval != NONE THEN $requires_approval ELSE false END;
    LET $final_approval_level = $approval_level OR "NONE";
    LET $final_restricted_usage = IF $restricted_usage != NONE THEN $restricted_usage ELSE false END;
    LET $final_allowed_roles = $allowed_roles OR [];
    LET $final_calculation_class = $calculation_class OR "";
    LET $final_configuration_params = $configuration_params OR {};
    LET $final_cache_enabled = IF $cache_enabled != NONE THEN $cache_enabled ELSE true END;
    LET $final_cache_duration = $cache_duration OR 300;
    LET $final_version = $version OR "1.0";
    
    -- Création de l'enregistrement
    LET $new_method = CREATE discount_calculation_method CONTENT {
        code: $code,
        name: $name,
        description: $final_description,
        sequence: $sequence,
        calculation_type: $calculation_type,
        calculation_subtype: $final_calculation_subtype,
        calculation_formula: $final_calculation_formula,
        supports_fixed_amount: $final_supports_fixed_amount,
        supports_percentage: $final_supports_percentage,
        supports_formula: $final_supports_formula,
        supports_currency: $final_supports_currency,
        default_symbol: $final_default_symbol,
        uses_currency_symbol: $final_uses_currency_symbol,
        display_format: $final_display_format,
        min_value: $min_value,
        max_value: $max_value,
        decimal_precision: $final_decimal_precision,
        validation_rules: $final_validation_rules,
        applies_to_subtotal: $final_applies_to_subtotal,
        applies_to_taxes: $final_applies_to_taxes,
        applies_to_fees: $final_applies_to_fees,
        can_be_cumulated: $final_can_be_cumulated,
        color: $final_color,
        icon: $final_icon,
        display_category: $final_display_category,
        requires_approval: $final_requires_approval,
        approval_level: $final_approval_level,
        restricted_usage: $final_restricted_usage,
        allowed_roles: $final_allowed_roles,
        calculation_class: $final_calculation_class,
        configuration_params: $final_configuration_params,
        cache_enabled: $final_cache_enabled,
        cache_duration: $final_cache_duration,
        version: $final_version,
        is_active: true,
        is_system: false,
        created_on: time::now(),
        updated_on: time::now()
    };
    
    -- Vérification de la création
    IF !$new_method {
        RETURN {
            success: false,
            error: "Erreur lors de la création de la méthode de calcul",
            message: "Erreur système : création échouée"
        };
    };
    
    -- Retour de succès
    RETURN {
        success: true,
        message: "Méthode de calcul créée avec succès",
        data: $new_method[0]
    };
};

-- =====================================================
-- FONCTION: create_discount_calculation_method_simple
-- Description: Création simplifiée avec paramètres minimaux
-- =====================================================

DEFINE FUNCTION fn::create_discount_calculation_method_simple(
    $code: string,
    $name: string,
    $sequence: int,
    $calculation_type: string,
    $supports_fixed_amount: bool,
    $supports_percentage: bool,
    $supports_formula: bool
) {
    RETURN fn::create_discount_calculation_method(
        $code,
        $name,
        $sequence,
        $calculation_type,
        NONE,  -- description
        NONE,  -- calculation_subtype
        NONE,  -- calculation_formula
        $supports_fixed_amount,
        $supports_percentage,
        $supports_formula,
        $supports_fixed_amount,  -- supports_currency = supports_fixed_amount
        NONE,  -- default_symbol (auto)
        NONE,  -- uses_currency_symbol (auto)
        NONE,  -- display_format (défaut)
        NONE,  -- min_value
        NONE,  -- max_value
        NONE,  -- decimal_precision (défaut: 2)
        NONE,  -- validation_rules
        NONE,  -- applies_to_subtotal (défaut: true)
        NONE,  -- applies_to_taxes (défaut: false)
        NONE,  -- applies_to_fees (défaut: false)
        NONE,  -- can_be_cumulated (défaut: false)
        NONE,  -- color (défaut: #007bff)
        NONE,  -- icon (défaut: Calculator)
        NONE,  -- display_category (défaut: STANDARD)
        NONE,  -- requires_approval (défaut: false)
        NONE,  -- approval_level (défaut: NONE)
        NONE,  -- restricted_usage (défaut: false)
        NONE,  -- allowed_roles (défaut: [])
        NONE,  -- calculation_class
        NONE,  -- configuration_params (défaut: {})
        NONE,  -- cache_enabled (défaut: true)
        NONE,  -- cache_duration (défaut: 300)
        NONE   -- version (défaut: 1.0)
    );
};

-- =====================================================
-- FONCTION: create_discount_calculation_method_preset
-- Description: Création avec presets prédéfinis
-- =====================================================

DEFINE FUNCTION fn::create_discount_calculation_method_preset(
    $preset_type: string,
    $code: string,
    $name: string,
    $sequence: int
) {
    -- Validation du preset
    IF !$preset_type OR !($preset_type IN ["FIXED_AMOUNT", "PERCENTAGE", "FORMULA", "TIERED", "CONDITIONAL"]) {
        RETURN {
            success: false,
            error: "Le type de preset doit être FIXED_AMOUNT, PERCENTAGE, FORMULA, TIERED ou CONDITIONAL",
            message: "Erreur de validation : preset invalide"
        };
    };
    
    -- Configuration selon le preset
    LET $config = IF $preset_type = "FIXED_AMOUNT" THEN {
        calculation_type: "FIXED",
        supports_fixed_amount: true,
        supports_percentage: false,
        supports_formula: false,
        supports_currency: true,
        default_symbol: "€",
        uses_currency_symbol: true,
        icon: "Euro",
        display_category: "AMOUNT"
    } ELSE IF $preset_type = "PERCENTAGE" THEN {
        calculation_type: "PERCENT",
        supports_fixed_amount: false,
        supports_percentage: true,
        supports_formula: false,
        supports_currency: false,
        default_symbol: "%",
        uses_currency_symbol: false,
        icon: "Percent",
        display_category: "PERCENT"
    } ELSE IF $preset_type = "FORMULA" THEN {
        calculation_type: "FORMULA",
        supports_fixed_amount: false,
        supports_percentage: false,
        supports_formula: true,
        supports_currency: false,
        default_symbol: "f(x)",
        uses_currency_symbol: false,
        icon: "Calculator",
        display_category: "FORMULA",
        requires_approval: true
    } ELSE IF $preset_type = "TIERED" THEN {
        calculation_type: "TIERED",
        supports_fixed_amount: true,
        supports_percentage: true,
        supports_formula: false,
        supports_currency: true,
        default_symbol: "⚡",
        uses_currency_symbol: false,
        icon: "BarChart3",
        display_category: "ADVANCED"
    } ELSE IF $preset_type = "CONDITIONAL" THEN {
        calculation_type: "CONDITIONAL",
        supports_fixed_amount: true,
        supports_percentage: true,
        supports_formula: true,
        supports_currency: true,
        default_symbol: "?",
        uses_currency_symbol: false,
        icon: "GitBranch",
        display_category: "ADVANCED",
        requires_approval: true
    } ELSE {} END;
    
    -- Création avec la configuration du preset
    RETURN fn::create_discount_calculation_method(
        $code,
        $name,
        $sequence,
        $config.calculation_type,
        "Méthode créée avec le preset " + $preset_type,  -- description
        "PRESET",  -- calculation_subtype
        NONE,  -- calculation_formula
        $config.supports_fixed_amount,
        $config.supports_percentage,
        $config.supports_formula,
        $config.supports_currency,
        $config.default_symbol,
        $config.uses_currency_symbol,
        NONE,  -- display_format (défaut)
        NONE,  -- min_value
        NONE,  -- max_value
        NONE,  -- decimal_precision (défaut: 2)
        NONE,  -- validation_rules
        NONE,  -- applies_to_subtotal (défaut: true)
        NONE,  -- applies_to_taxes (défaut: false)
        NONE,  -- applies_to_fees (défaut: false)
        NONE,  -- can_be_cumulated (défaut: false)
        NONE,  -- color (défaut: #007bff)
        $config.icon,
        $config.display_category,
        $config.requires_approval,
        NONE,  -- approval_level (défaut: NONE)
        NONE,  -- restricted_usage (défaut: false)
        NONE,  -- allowed_roles (défaut: [])
        NONE,  -- calculation_class
        NONE,  -- configuration_params (défaut: {})
        NONE,  -- cache_enabled (défaut: true)
        NONE,  -- cache_duration (défaut: 300)
        NONE   -- version (défaut: 1.0)
    );
};

-- =====================================================
-- FONCTION: batch_create_discount_calculation_methods
-- Description: Création en lot de plusieurs méthodes
-- =====================================================

DEFINE FUNCTION fn::batch_create_discount_calculation_methods($methods: array<object>) {
    LET $results = [];
    LET $errors = [];
    LET $success_count = 0;
    
    FOR $method IN $methods {
        LET $result = fn::create_discount_calculation_method(
            $method.code,
            $method.name,
            $method.sequence,
            $method.calculation_type,
            $method.description,
            $method.calculation_subtype,
            $method.calculation_formula,
            $method.supports_fixed_amount,
            $method.supports_percentage,
            $method.supports_formula,
            $method.supports_currency,
            $method.default_symbol,
            $method.uses_currency_symbol,
            $method.display_format,
            $method.min_value,
            $method.max_value,
            $method.decimal_precision,
            $method.validation_rules,
            $method.applies_to_subtotal,
            $method.applies_to_taxes,
            $method.applies_to_fees,
            $method.can_be_cumulated,
            $method.color,
            $method.icon,
            $method.display_category,
            $method.requires_approval,
            $method.approval_level,
            $method.restricted_usage,
            $method.allowed_roles,
            $method.calculation_class,
            $method.configuration_params,
            $method.cache_enabled,
            $method.cache_duration,
            $method.version
        );
        
        IF $result.success {
            $success_count = $success_count + 1;
            $results = array::push($results, $result.data);
        } ELSE {
            $errors = array::push($errors, {
                code: $method.code,
                error: $result.error,
                message: $result.message
            });
        };
    };
    
    RETURN {
        success: $success_count > 0,
        message: "Création en lot terminée",
        total_requested: array::len($methods),
        success_count: $success_count,
        error_count: array::len($errors),
        created_methods: $results,
        errors: $errors
    };
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
UTILISATION DES FONCTIONS:

1. Création complète:
   SELECT fn::create_discount_calculation_method(
       "FIXED_EURO", "Montant fixe en euros", 10, "FIXED", 
       "Remise en montant fixe exprimée en euros", "SIMPLE", "",
       true, false, false, true, "€", true, "{value} {symbol}",
       0.01, NONE, 2, "", true, false, false, false,
       "#28a745", "Euro", "AMOUNT", false, "NONE", false, [],
       "", {}, true, 300, "1.0"
   );

2. Création simple:
   SELECT fn::create_discount_calculation_method_simple(
       "PERCENT_BASIC", "Pourcentage basique", 20, "PERCENT", 
       false, true, false
   );

3. Création avec preset:
   SELECT fn::create_discount_calculation_method_preset(
       "FIXED_AMOUNT", "FIXED_USD", "Montant fixe USD", 15
   );

4. Création en lot:
   SELECT fn::batch_create_discount_calculation_methods([
       {code: "METHOD1", name: "Méthode 1", sequence: 10, calculation_type: "FIXED"},
       {code: "METHOD2", name: "Méthode 2", sequence: 20, calculation_type: "PERCENT"}
   ]);

PRESETS DISPONIBLES:
- FIXED_AMOUNT: Montant fixe avec devise
- PERCENTAGE: Pourcentage simple
- FORMULA: Formule personnalisée (approbation requise)
- TIERED: Calcul par paliers
- CONDITIONAL: Calcul conditionnel (approbation requise)

VALIDATIONS EFFECTUÉES:
- Code obligatoire et unique
- Nom obligatoire
- Séquence positive et unique
- Type de calcul valide
- Au moins un type de support activé
- Format de couleur hexadécimal
- Cohérence des valeurs min/max
- Précision décimale valide
- Durée de cache positive

RETOUR STANDARDISÉ:
{
    success: bool,
    message: string,
    data: object (si succès),
    error: string (si erreur)
}
*/ 
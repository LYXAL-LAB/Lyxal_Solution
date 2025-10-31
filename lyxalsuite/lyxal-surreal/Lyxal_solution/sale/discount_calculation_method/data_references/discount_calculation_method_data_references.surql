-- =====================================================
-- DONNÉES DE RÉFÉRENCE: discount_calculation_method
-- Description: Méthodes de calcul prédéfinies pour les remises
-- Version: 1.0
-- =====================================================

-- =====================================================
-- MÉTHODES DE CALCUL SYSTÈME
-- =====================================================

-- Méthode: Montant fixe
CREATE discount_calculation_method:FIXED_AMOUNT CONTENT {
    code: "FIXED_AMOUNT",
    name: "Montant fixe",
    description: "Remise en montant fixe exprimée dans une devise (ex: -10€, -50$)",
    sequence: 10,
    calculation_type: "FIXED",
    calculation_subtype: "SIMPLE",
    calculation_formula: "fixed_value",
    supports_fixed_amount: true,
    supports_percentage: false,
    supports_formula: false,
    supports_currency: true,
    default_symbol: "€",
    uses_currency_symbol: true,
    display_format: "{value} {symbol}",
    min_value: 0.01,
    max_value: NONE,
    decimal_precision: 2,
    validation_rules: "min_value > 0",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#28a745",
    icon: "Euro",
    display_category: "AMOUNT",
    requires_approval: false,
    approval_level: "NONE",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "FixedAmountCalculator",
    configuration_params: {
        currency_required: true,
        precision: 2,
        rounding_mode: "HALF_UP"
    },
    cache_enabled: true,
    cache_duration: 300,
    version: "1.0",
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- Méthode: Pourcentage
CREATE discount_calculation_method:PERCENTAGE CONTENT {
    code: "PERCENTAGE",
    name: "Pourcentage",
    description: "Remise en pourcentage du montant de base (ex: -15%, -25%)",
    sequence: 20,
    calculation_type: "PERCENT",
    calculation_subtype: "SIMPLE",
    calculation_formula: "(base_amount * percentage) / 100",
    supports_fixed_amount: false,
    supports_percentage: true,
    supports_formula: false,
    supports_currency: false,
    default_symbol: "%",
    uses_currency_symbol: false,
    display_format: "{value}{symbol}",
    min_value: 0.01,
    max_value: 100,
    decimal_precision: 2,
    validation_rules: "min_value > 0 AND max_value <= 100",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#007bff",
    icon: "Percent",
    display_category: "PERCENT",
    requires_approval: false,
    approval_level: "NONE",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "PercentageCalculator",
    configuration_params: {
        max_percentage: 100,
        precision: 2,
        rounding_mode: "HALF_UP"
    },
    cache_enabled: true,
    cache_duration: 300,
    version: "1.0",
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- MÉTHODES DE CALCUL AVANCÉES
-- =====================================================

-- Méthode: Formule personnalisée
CREATE discount_calculation_method:FORMULA CONTENT {
    code: "FORMULA",
    name: "Formule personnalisée",
    description: "Remise calculée selon une formule personnalisée complexe",
    sequence: 30,
    calculation_type: "FORMULA",
    calculation_subtype: "COMPLEX",
    calculation_formula: "custom_formula",
    supports_fixed_amount: false,
    supports_percentage: false,
    supports_formula: true,
    supports_currency: false,
    default_symbol: "f(x)",
    uses_currency_symbol: false,
    display_format: "{symbol}",
    min_value: NONE,
    max_value: NONE,
    decimal_precision: 4,
    validation_rules: "formula_syntax_valid",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#6c757d",
    icon: "Calculator",
    display_category: "FORMULA",
    requires_approval: true,
    approval_level: "MANAGER",
    restricted_usage: true,
    allowed_roles: ["MANAGER", "ADMIN", "FINANCE"],
    calculation_class: "FormulaCalculator",
    configuration_params: {
        formula_engine: "javascript",
        security_level: "high",
        max_execution_time: 1000
    },
    cache_enabled: false,
    cache_duration: 60,
    version: "1.0",
    is_active: false,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Méthode: Calcul par paliers
CREATE discount_calculation_method:TIERED CONTENT {
    code: "TIERED",
    name: "Calcul par paliers",
    description: "Remise progressive selon des paliers de montant ou quantité",
    sequence: 40,
    calculation_type: "TIERED",
    calculation_subtype: "PROGRESSIVE",
    calculation_formula: "tiered_calculation",
    supports_fixed_amount: true,
    supports_percentage: true,
    supports_formula: false,
    supports_currency: true,
    default_symbol: "⚡",
    uses_currency_symbol: false,
    display_format: "{value} {symbol}",
    min_value: 0,
    max_value: NONE,
    decimal_precision: 2,
    validation_rules: "tiers_configured",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#fd7e14",
    icon: "BarChart3",
    display_category: "ADVANCED",
    requires_approval: true,
    approval_level: "MANAGER",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "TieredCalculator",
    configuration_params: {
        max_tiers: 10,
        tier_type: "amount",
        calculation_mode: "progressive"
    },
    cache_enabled: true,
    cache_duration: 600,
    version: "1.0",
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Méthode: Calcul conditionnel
CREATE discount_calculation_method:CONDITIONAL CONTENT {
    code: "CONDITIONAL",
    name: "Calcul conditionnel",
    description: "Remise appliquée selon des conditions spécifiques (client, produit, date)",
    sequence: 50,
    calculation_type: "CONDITIONAL",
    calculation_subtype: "RULE_BASED",
    calculation_formula: "conditional_rules",
    supports_fixed_amount: true,
    supports_percentage: true,
    supports_formula: true,
    supports_currency: true,
    default_symbol: "?",
    uses_currency_symbol: false,
    display_format: "{value} {symbol}",
    min_value: NONE,
    max_value: NONE,
    decimal_precision: 2,
    validation_rules: "conditions_valid",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: true,
    color: "#6f42c1",
    icon: "GitBranch",
    display_category: "ADVANCED",
    requires_approval: true,
    approval_level: "DIRECTOR",
    restricted_usage: true,
    allowed_roles: ["DIRECTOR", "ADMIN"],
    calculation_class: "ConditionalCalculator",
    configuration_params: {
        max_conditions: 20,
        condition_types: ["client", "product", "date", "amount", "quantity"],
        evaluation_mode: "all_match"
    },
    cache_enabled: false,
    cache_duration: 120,
    version: "1.0",
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- MÉTHODES SPÉCIALISÉES PAR DEVISE
-- =====================================================

-- Méthode: Montant fixe USD
CREATE discount_calculation_method:FIXED_AMOUNT_USD CONTENT {
    code: "FIXED_AMOUNT_USD",
    name: "Montant fixe USD",
    description: "Remise en montant fixe exprimée en dollars américains",
    sequence: 60,
    calculation_type: "FIXED",
    calculation_subtype: "CURRENCY_SPECIFIC",
    calculation_formula: "fixed_value_usd",
    supports_fixed_amount: true,
    supports_percentage: false,
    supports_formula: false,
    supports_currency: true,
    default_symbol: "$",
    uses_currency_symbol: true,
    display_format: "{symbol}{value}",
    min_value: 0.01,
    max_value: NONE,
    decimal_precision: 2,
    validation_rules: "currency = USD",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#198754",
    icon: "DollarSign",
    display_category: "AMOUNT",
    requires_approval: false,
    approval_level: "NONE",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "FixedAmountUSDCalculator",
    configuration_params: {
        currency: "USD",
        precision: 2,
        rounding_mode: "HALF_UP"
    },
    cache_enabled: true,
    cache_duration: 300,
    version: "1.0",
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- MÉTHODES SPÉCIALISÉES PAR CONTEXTE
-- =====================================================

-- Méthode: Pourcentage avec plafond
CREATE discount_calculation_method:PERCENTAGE_CAPPED CONTENT {
    code: "PERCENTAGE_CAPPED",
    name: "Pourcentage avec plafond",
    description: "Remise en pourcentage avec montant maximum plafonné",
    sequence: 70,
    calculation_type: "PERCENT",
    calculation_subtype: "CAPPED",
    calculation_formula: "min((base_amount * percentage) / 100, max_amount)",
    supports_fixed_amount: false,
    supports_percentage: true,
    supports_formula: false,
    supports_currency: true,
    default_symbol: "%",
    uses_currency_symbol: false,
    display_format: "{value}{symbol} (max {max_amount})",
    min_value: 0.01,
    max_value: 100,
    decimal_precision: 2,
    validation_rules: "max_amount_configured",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#17a2b8",
    icon: "Shield",
    display_category: "PERCENT",
    requires_approval: false,
    approval_level: "NONE",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "CappedPercentageCalculator",
    configuration_params: {
        cap_required: true,
        default_cap: 1000,
        precision: 2
    },
    cache_enabled: true,
    cache_duration: 300,
    version: "1.0",
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Méthode: Remise volume progressive
CREATE discount_calculation_method:VOLUME_PROGRESSIVE CONTENT {
    code: "VOLUME_PROGRESSIVE",
    name: "Volume progressif",
    description: "Remise progressive selon le volume de commande (plus le volume est important, plus la remise augmente)",
    sequence: 80,
    calculation_type: "TIERED",
    calculation_subtype: "VOLUME_BASED",
    calculation_formula: "volume_tiers",
    supports_fixed_amount: false,
    supports_percentage: true,
    supports_formula: false,
    supports_currency: false,
    default_symbol: "%",
    uses_currency_symbol: false,
    display_format: "{value}{symbol}",
    min_value: 1,
    max_value: 50,
    decimal_precision: 2,
    validation_rules: "volume_tiers_configured",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#20c997",
    icon: "TrendingUp",
    display_category: "ADVANCED",
    requires_approval: true,
    approval_level: "MANAGER",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "VolumeProgressiveCalculator",
    configuration_params: {
        tier_type: "volume",
        calculation_mode: "progressive",
        max_discount: 50
    },
    cache_enabled: true,
    cache_duration: 600,
    version: "1.0",
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Méthode: Remise fidélité automatique
CREATE discount_calculation_method:LOYALTY_AUTO CONTENT {
    code: "LOYALTY_AUTO",
    name: "Fidélité automatique",
    description: "Remise automatique basée sur le niveau de fidélité du client",
    sequence: 90,
    calculation_type: "CONDITIONAL",
    calculation_subtype: "LOYALTY_BASED",
    calculation_formula: "loyalty_level_discount",
    supports_fixed_amount: false,
    supports_percentage: true,
    supports_formula: false,
    supports_currency: false,
    default_symbol: "%",
    uses_currency_symbol: false,
    display_format: "{value}{symbol}",
    min_value: 1,
    max_value: 15,
    decimal_precision: 1,
    validation_rules: "loyalty_level_exists",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: true,
    color: "#e83e8c",
    icon: "Heart",
    display_category: "LOYALTY",
    requires_approval: false,
    approval_level: "NONE",
    restricted_usage: false,
    allowed_roles: [],
    calculation_class: "LoyaltyAutoCalculator",
    configuration_params: {
        loyalty_levels: ["BRONZE", "SILVER", "GOLD", "PLATINUM"],
        auto_apply: true,
        max_discount: 15
    },
    cache_enabled: true,
    cache_duration: 1800,
    version: "1.0",
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- MÉTHODES EXPÉRIMENTALES (INACTIVES)
-- =====================================================

-- Méthode: Intelligence artificielle
CREATE discount_calculation_method:AI_DYNAMIC CONTENT {
    code: "AI_DYNAMIC",
    name: "IA Dynamique",
    description: "Remise calculée par intelligence artificielle selon le comportement client",
    sequence: 100,
    calculation_type: "FORMULA",
    calculation_subtype: "AI_BASED",
    calculation_formula: "ai_model_prediction",
    supports_fixed_amount: true,
    supports_percentage: true,
    supports_formula: true,
    supports_currency: true,
    default_symbol: "🤖",
    uses_currency_symbol: false,
    display_format: "{symbol} {value}",
    min_value: 0,
    max_value: 30,
    decimal_precision: 3,
    validation_rules: "ai_model_available",
    applies_to_subtotal: true,
    applies_to_taxes: false,
    applies_to_fees: false,
    can_be_cumulated: false,
    color: "#9c27b0",
    icon: "Brain",
    display_category: "EXPERIMENTAL",
    requires_approval: true,
    approval_level: "ADMIN",
    restricted_usage: true,
    allowed_roles: ["ADMIN", "DATA_SCIENTIST"],
    calculation_class: "AIDynamicCalculator",
    configuration_params: {
        model_name: "discount_optimizer_v1",
        confidence_threshold: 0.8,
        max_execution_time: 2000
    },
    cache_enabled: false,
    cache_duration: 30,
    version: "0.1",
    is_active: false,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
MÉTHODES DE CALCUL CRÉÉES:

1. MÉTHODES SYSTÈME (is_system = true):
   - FIXED_AMOUNT: Montant fixe avec devise
   - PERCENTAGE: Pourcentage simple

2. MÉTHODES AVANCÉES:
   - FORMULA: Formule personnalisée (approbation requise)
   - TIERED: Calcul par paliers progressifs
   - CONDITIONAL: Calcul conditionnel complexe

3. MÉTHODES SPÉCIALISÉES:
   - FIXED_AMOUNT_USD: Montant fixe en dollars
   - PERCENTAGE_CAPPED: Pourcentage avec plafond
   - VOLUME_PROGRESSIVE: Remise volume progressive
   - LOYALTY_AUTO: Fidélité automatique

4. MÉTHODES EXPÉRIMENTALES:
   - AI_DYNAMIC: Intelligence artificielle (inactive)

CARACTÉRISTIQUES:

Types de calcul:
- FIXED: 2 méthodes (montant fixe)
- PERCENT: 3 méthodes (pourcentage)
- FORMULA: 2 méthodes (formule)
- TIERED: 2 méthodes (paliers)
- CONDITIONAL: 2 méthodes (conditionnel)

Supports:
- Montant fixe: 5 méthodes
- Pourcentage: 6 méthodes
- Formule: 3 méthodes
- Devise: 5 méthodes

Restrictions:
- Approbation requise: 5 méthodes
- Usage restreint: 3 méthodes
- Rôles spécifiques: 4 méthodes

Catégories d'affichage:
- AMOUNT: Montants fixes
- PERCENT: Pourcentages
- FORMULA: Formules
- ADVANCED: Méthodes avancées
- LOYALTY: Fidélité
- EXPERIMENTAL: Expérimental

UTILISATION:

Ces méthodes fournissent:
1. Couverture complète des besoins de calcul
2. Flexibilité pour cas d'usage spécifiques
3. Extensibilité pour nouvelles méthodes
4. Sécurité avec niveaux d'approbation

Pour ajouter une nouvelle méthode:
1. Définir le type de calcul
2. Configurer les supports
3. Définir les règles de validation
4. Paramétrer les restrictions
5. Implémenter la classe de calcul

MAINTENANCE:

- Méthodes système: Ne pas modifier/supprimer
- Méthodes standard: Modifiables selon besoins
- Méthodes expérimentales: Activation après validation
- Cache: Optimisé selon la complexité de calcul
*/ 
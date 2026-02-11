-- =====================================================
-- DONNÉES DE RÉFÉRENCE: discount_type
-- Description: Données de référence pour les types de remise
-- Version: 1.0
-- =====================================================

-- =====================================================
-- TYPES DE REMISE SYSTÈME
-- =====================================================

-- Type: Montant fixe
CREATE discount_type:AMOUNT CONTENT {
    code: "AMOUNT",
    name: "Montant fixe",
    description: "Remise en montant fixe exprimée en devise (ex: -10€, -50$)",
    sequence: 10,
    calculation_method: "FIXED",
    symbol: "€",
    formula: "",
    min_value: 0.01,
    max_value: NONE,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#28a745",
    icon: "Euro",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Pourcentage
CREATE discount_type:PERCENTAGE CONTENT {
    code: "PERCENTAGE",
    name: "Pourcentage",
    description: "Remise en pourcentage du montant de base (ex: -15%, -25%)",
    sequence: 20,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 0.01,
    max_value: 100,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#007bff",
    icon: "Percent",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: true,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- TYPES DE REMISE MÉTIER
-- =====================================================

-- Type: Remise volume
CREATE discount_type:VOLUME CONTENT {
    code: "VOLUME",
    name: "Remise volume",
    description: "Remise accordée pour les commandes de volume important (minimum 1000€)",
    sequence: 30,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 2,
    max_value: 25,
    min_order_amount: 1000,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: true,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#17a2b8",
    icon: "TrendingUp",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise anticipée
CREATE discount_type:EARLY_BIRD CONTENT {
    code: "EARLY_BIRD",
    name: "Remise anticipée",
    description: "Remise pour les commandes passées en avance (paiement anticipé)",
    sequence: 40,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 1,
    max_value: 15,
    min_order_amount: 500,
    max_order_amount: NONE,
    is_cumulative: true,
    is_automatic: false,
    requires_approval: true,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#ffc107",
    icon: "Clock",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: 2,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise fidélité
CREATE discount_type:LOYALTY CONTENT {
    code: "LOYALTY",
    name: "Remise fidélité",
    description: "Remise automatique pour les clients fidèles (cumul possible)",
    sequence: 50,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 1,
    max_value: 10,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: true,
    is_automatic: true,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#e83e8c",
    icon: "Heart",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise saisonnière
CREATE discount_type:SEASONAL CONTENT {
    code: "SEASONAL",
    name: "Remise saisonnière",
    description: "Remise temporaire pour les périodes spéciales (soldes, promotions)",
    sequence: 60,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 5,
    max_value: 50,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#fd7e14",
    icon: "Calendar",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise commerciale
CREATE discount_type:COMMERCIAL CONTENT {
    code: "COMMERCIAL",
    name: "Remise commerciale",
    description: "Remise négociée par l'équipe commerciale (approbation requise)",
    sequence: 70,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 1,
    max_value: 30,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: true,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#6f42c1",
    icon: "Handshake",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise promotionnelle
CREATE discount_type:PROMO CONTENT {
    code: "PROMO",
    name: "Remise promotionnelle",
    description: "Remise pour les campagnes promotionnelles et marketing",
    sequence: 80,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 5,
    max_value: 40,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#dc3545",
    icon: "Tag",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise quantité
CREATE discount_type:QUANTITY CONTENT {
    code: "QUANTITY",
    name: "Remise quantité",
    description: "Remise basée sur la quantité commandée (dégressif)",
    sequence: 90,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 1,
    max_value: 20,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: true,
    is_automatic: true,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#20c997",
    icon: "Package",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise partenaire
CREATE discount_type:PARTNER CONTENT {
    code: "PARTNER",
    name: "Remise partenaire",
    description: "Remise spéciale pour les partenaires commerciaux et revendeurs",
    sequence: 100,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 5,
    max_value: 35,
    min_order_amount: 200,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: true,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#6c757d",
    icon: "Users",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- TYPES DE REMISE SPÉCIALISÉS
-- =====================================================

-- Type: Remise formule personnalisée
CREATE discount_type:FORMULA CONTENT {
    code: "FORMULA",
    name: "Remise formule",
    description: "Remise calculée selon une formule personnalisée complexe",
    sequence: 110,
    calculation_method: "FORMULA",
    symbol: "f(x)",
    formula: "base_amount * 0.1 + (quantity > 10 ? 50 : 0)",
    min_value: NONE,
    max_value: NONE,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: true,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#495057",
    icon: "Calculator",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: false,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise montant fixe élevé
CREATE discount_type:FIXED_HIGH CONTENT {
    code: "FIXED_HIGH",
    name: "Remise fixe élevée",
    description: "Remise en montant fixe pour les grosses commandes (>5000€)",
    sequence: 120,
    calculation_method: "FIXED",
    symbol: "€",
    formula: "",
    min_value: 100,
    max_value: 2000,
    min_order_amount: 5000,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: true,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#198754",
    icon: "DollarSign",
    valid_from: NONE,
    valid_to: NONE,
    max_usage_count: NONE,
    max_usage_per_client: NONE,
    is_active: true,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- TYPES DE REMISE TEMPORAIRES (EXEMPLES)
-- =====================================================

-- Type: Remise Black Friday (temporaire)
CREATE discount_type:BLACK_FRIDAY CONTENT {
    code: "BLACK_FRIDAY",
    name: "Black Friday",
    description: "Remise spéciale Black Friday - durée limitée",
    sequence: 130,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 10,
    max_value: 60,
    min_order_amount: NONE,
    max_order_amount: NONE,
    is_cumulative: false,
    is_automatic: false,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#000000",
    icon: "ShoppingCart",
    valid_from: "2024-11-29",
    valid_to: "2024-11-30",
    max_usage_count: 1000,
    max_usage_per_client: 1,
    is_active: false,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- Type: Remise Nouvel An (temporaire)
CREATE discount_type:NEW_YEAR CONTENT {
    code: "NEW_YEAR",
    name: "Nouvel An",
    description: "Remise spéciale début d'année - premiers clients",
    sequence: 140,
    calculation_method: "PERCENT",
    symbol: "%",
    formula: "",
    min_value: 5,
    max_value: 25,
    min_order_amount: 100,
    max_order_amount: NONE,
    is_cumulative: true,
    is_automatic: false,
    requires_approval: false,
    applies_to_subtotal: true,
    applies_to_taxes: false,
    color: "#ffd700",
    icon: "Sparkles",
    valid_from: "2024-01-01",
    valid_to: "2024-01-31",
    max_usage_count: 500,
    max_usage_per_client: 1,
    is_active: false,
    is_system: false,
    created_on: time::now(),
    updated_on: time::now()
};

-- =====================================================
-- COMMENTAIRES ET DOCUMENTATION
-- =====================================================

/*
TYPES DE REMISE CRÉÉS:

1. TYPES SYSTÈME (is_system = true):
   - AMOUNT: Montant fixe en devise
   - PERCENTAGE: Pourcentage du montant

2. TYPES MÉTIER STANDARDS:
   - VOLUME: Remise pour gros volumes (>1000€)
   - EARLY_BIRD: Remise anticipée (max 2/client)
   - LOYALTY: Remise fidélité (automatique, cumulable)
   - SEASONAL: Remise saisonnière (soldes)
   - COMMERCIAL: Remise négociée (approbation requise)
   - PROMO: Remise promotionnelle
   - QUANTITY: Remise quantité (automatique, cumulable)
   - PARTNER: Remise partenaire (>200€, approbation)

3. TYPES SPÉCIALISÉS:
   - FORMULA: Remise par formule (inactif par défaut)
   - FIXED_HIGH: Remise fixe élevée (>5000€)

4. TYPES TEMPORAIRES (EXEMPLES):
   - BLACK_FRIDAY: Remise Black Friday (dates limitées)
   - NEW_YEAR: Remise Nouvel An (dates limitées)

CARACTÉRISTIQUES:

Méthodes de calcul:
- FIXED: 3 types (AMOUNT, FIXED_HIGH, FORMULA)
- PERCENT: 9 types (majorité)
- FORMULA: 1 type (FORMULA)

Comportements:
- Cumulables: EARLY_BIRD, LOYALTY, QUANTITY, NEW_YEAR
- Automatiques: LOYALTY, QUANTITY
- Approbation requise: VOLUME, EARLY_BIRD, COMMERCIAL, PARTNER, FORMULA, FIXED_HIGH

Limites:
- Montant minimum: VOLUME (1000€), EARLY_BIRD (500€), PARTNER (200€), FIXED_HIGH (5000€), NEW_YEAR (100€)
- Utilisation par client: EARLY_BIRD (2), BLACK_FRIDAY (1), NEW_YEAR (1)
- Utilisation totale: BLACK_FRIDAY (1000), NEW_YEAR (500)

Validité temporelle:
- BLACK_FRIDAY: 29-30 novembre 2024
- NEW_YEAR: janvier 2024
- Autres: illimitée

Couleurs et icônes:
- Chaque type a une couleur distinctive
- Icônes Lucide React appropriées
- Interface utilisateur cohérente

UTILISATION:

Ces données de référence fournissent:
1. Types de base pour tous les cas d'usage
2. Exemples de configuration avancée
3. Modèles pour créer de nouveaux types
4. Couverture complète des fonctionnalités

Pour ajouter un nouveau type:
1. Copier un type similaire
2. Modifier code, nom, description
3. Ajuster les paramètres selon les besoins
4. Définir la séquence d'affichage
5. Choisir couleur et icône appropriées

MAINTENANCE:

- Types système: Ne pas modifier/supprimer
- Types métier: Modifiables selon besoins
- Types temporaires: Désactiver après expiration
- Séquences: Multiples de 10 pour faciliter l'insertion
*/ 
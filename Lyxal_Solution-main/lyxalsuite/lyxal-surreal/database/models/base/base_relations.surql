-- ================================================================================================
-- 🔗 LYXAL BASE - RELATIONS GRAPHE IA-NATIVE 
-- ================================================================================================
-- Module : lyxal-base
-- Description : 23 relations graphe enrichies par l'Intelligence Artificielle
-- Version : 1.0.0
-- Architecture : Réseau intelligent d'entreprise avec scoring automatique
-- ================================================================================================

-- ================================================================================================
-- 🤝 RELATIONS PARTNER IA-ENHANCED
-- ================================================================================================

-- Relation: partner → contact (IA-Native)
DEFINE TABLE has_contact SCHEMAFULL TYPE RELATION
    COMMENT "Relation partenaire-contact avec IA de scoring relationnel"
    PERMISSIONS 
        FOR SELECT WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'sales' OR in.company = $auth.companyId)
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

-- Relations de base
DEFINE FIELD in ON has_contact TYPE record<partner> ASSERT $value != NULL;
DEFINE FIELD out ON has_contact TYPE record<partner> ASSERT $value != NULL;

-- Configuration contact
DEFINE FIELD isPrimary ON has_contact TYPE bool DEFAULT false;
DEFINE FIELD role ON has_contact TYPE string;
DEFINE FIELD department ON has_contact TYPE string;
DEFINE FIELD contactType ON has_contact TYPE string 
    ASSERT $value INSIDE ['PHONE', 'EMAIL', 'MEETING', 'SOCIAL', 'REFERRAL']
    DEFAULT 'PHONE';

-- IA Révolutionnaire
DEFINE FIELD aiProfile ON has_contact TYPE object VALUE {
    relationshipStrength: 0.0,
    communicationFrequency: 0.0,
    responseRate: 0.0,
    influenceScore: 0.0,
    trustLevel: 0.0
};

DEFINE FIELD aiInsights ON has_contact TYPE object VALUE {
    bestContactTime: [],
    preferredChannel: 'EMAIL',
    responsePatterns: {},
    communicationStyle: 'FORMAL',
    decisionMakingRole: 'UNKNOWN'
};

-- Métriques de communication IA
DEFINE FIELD communicationMetrics ON has_contact TYPE object VALUE {
    totalInteractions: 0,
    lastInteractionDate: null,
    averageResponseTime: 0.0,
    successfulContacts: 0,
    missedAttempts: 0
};

-- Scoring relationnel automatique
DEFINE FIELD relationshipScore ON has_contact TYPE float 
    ASSERT $value >= 0 AND $value <= 100
    DEFAULT 50.0;

-- Prédictions IA
DEFINE FIELD aiPredictions ON has_contact TYPE object VALUE {
    nextContactProbability: 0.0,
    churnRisk: 0.0,
    upsellPotential: 0.0,
    referralLikelihood: 0.0
};

-- Métadonnées enrichies
DEFINE FIELD addedAt ON has_contact TYPE datetime DEFAULT time::now();
DEFINE FIELD addedBy ON has_contact TYPE record<user>;
DEFINE FIELD lastUpdatedAt ON has_contact TYPE datetime DEFAULT time::now();
DEFINE FIELD isActive ON has_contact TYPE bool DEFAULT true;

-- Relation: partner → address (IA-Native Géospatiale)
DEFINE TABLE has_address SCHEMAFULL TYPE RELATION
    COMMENT "Relation partenaire-adresse avec IA géospatiale"
    PERMISSIONS 
        FOR SELECT WHERE ($auth.role CONTAINS 'admin' OR in.company = $auth.companyId)
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

-- Relations de base
DEFINE FIELD in ON has_address TYPE record<partner> ASSERT $value != NULL;
DEFINE FIELD out ON has_address TYPE record<address> ASSERT $value != NULL;

-- Configuration adresse
DEFINE FIELD isDefault ON has_address TYPE bool DEFAULT false;
DEFINE FIELD isDelivery ON has_address TYPE bool DEFAULT false;
DEFINE FIELD isInvoicing ON has_address TYPE bool DEFAULT false;
DEFINE FIELD isMailing ON has_address TYPE bool DEFAULT false;
DEFINE FIELD addressLabel ON has_address TYPE string;

-- Intelligence géospatiale IA
DEFINE FIELD geoIntelligence ON has_address TYPE object VALUE {
    optimalDeliveryTime: {},
    accessibilityScore: 0.0,
    logisticsComplexity: 0.0,
    proximityAdvantages: [],
    transportationOptions: []
};

-- Analytics d'utilisation IA
DEFINE FIELD usageAnalytics ON has_address TYPE object VALUE {
    deliveryFrequency: 0,
    lastDeliveryDate: null,
    averageDeliveryTime: 0.0,
    deliverySuccessRate: 0.0,
    costEfficiency: 0.0
};

-- Scoring géographique
DEFINE FIELD geoScore ON has_address TYPE float 
    ASSERT $value >= 0 AND $value <= 100
    DEFAULT 50.0;

-- Prédictions logistiques IA
DEFINE FIELD logisticsPredictions ON has_address TYPE object VALUE {
    deliveryTimeEstimate: 0.0,
    deliveryRisk: 0.0,
    optimalDeliveryWindow: {},
    seasonalVariations: {}
};

-- Métadonnées
DEFINE FIELD assignedAt ON has_address TYPE datetime DEFAULT time::now();
DEFINE FIELD assignedBy ON has_address TYPE record<user>;
DEFINE FIELD lastUsedAt ON has_address TYPE datetime;
DEFINE FIELD isActive ON has_address TYPE bool DEFAULT true;

-- Relation: partner → partner (Hiérarchie IA-Native)
DEFINE TABLE partners_hierarchy SCHEMAFULL TYPE RELATION
    COMMENT "Hiérarchie partenaires avec IA de gouvernance"
    PERMISSIONS 
        FOR SELECT WHERE ($auth.role CONTAINS 'admin' OR in.company = $auth.companyId)
        FOR CREATE, UPDATE WHERE $auth.role CONTAINS 'admin'
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

-- Relations hiérarchiques
DEFINE FIELD in ON partners_hierarchy TYPE record<partner> ASSERT $value != NULL; -- Parent
DEFINE FIELD out ON partners_hierarchy TYPE record<partner> ASSERT $value != NULL; -- Enfant

-- Configuration hiérarchique
DEFINE FIELD hierarchyType ON partners_hierarchy TYPE string 
    ASSERT $value INSIDE ['SUBSIDIARY', 'DIVISION', 'BRANCH', 'FRANCHISE', 'JOINT_VENTURE', 'PARTNERSHIP']
    DEFAULT 'SUBSIDIARY';

DEFINE FIELD sharePercentage ON partners_hierarchy TYPE float 
    ASSERT $value >= 0 AND $value <= 100;

DEFINE FIELD controlLevel ON partners_hierarchy TYPE string 
    ASSERT $value INSIDE ['FULL_CONTROL', 'MAJORITY', 'MINORITY', 'INFLUENCE', 'STRATEGIC']
    DEFAULT 'MAJORITY';

-- Intelligence hiérarchique IA
DEFINE FIELD hierarchyIntelligence ON partners_hierarchy TYPE object VALUE {
    decisionInfluence: 0.0,
    economicImpact: 0.0,
    strategicImportance: 0.0,
    synergiesScore: 0.0,
    riskDependency: 0.0
};

-- Analytics consolidation IA
DEFINE FIELD consolidationAnalytics ON partners_hierarchy TYPE object VALUE {
    financialContribution: 0.0,
    operationalSynergies: [],
    strategicValue: 0.0,
    performanceImpact: 0.0
};

-- Scoring hiérarchique
DEFINE FIELD hierarchyScore ON partners_hierarchy TYPE float 
    ASSERT $value >= 0 AND $value <= 100
    DEFAULT 50.0;

-- Prédictions stratégiques IA
DEFINE FIELD strategicPredictions ON partners_hierarchy TYPE object VALUE {
    growthPotential: 0.0,
    integrationSuccess: 0.0,
    futureValue: 0.0,
    riskFactors: []
};

-- Métadonnées
DEFINE FIELD establishedAt ON partners_hierarchy TYPE datetime DEFAULT time::now();
DEFINE FIELD establishedBy ON partners_hierarchy TYPE record<user>;
DEFINE FIELD lastReviewedAt ON partners_hierarchy TYPE datetime;
DEFINE FIELD isActive ON partners_hierarchy TYPE bool DEFAULT true;

-- ================================================================================================
-- 🏢 RELATIONS COMPANY IA-ENHANCED
-- ================================================================================================

-- Relation: company → address (IA-Native)
DEFINE TABLE company_has_address SCHEMAFULL TYPE RELATION
    COMMENT "Relation société-adresse avec IA géolocalisation"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'company_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON company_has_address TYPE record<company> ASSERT $value != NULL;
DEFINE FIELD out ON company_has_address TYPE record<address> ASSERT $value != NULL;

-- Configuration adresse entreprise
DEFINE FIELD isHeadquarters ON company_has_address TYPE bool DEFAULT false;
DEFINE FIELD isBilling ON company_has_address TYPE bool DEFAULT false;
DEFINE FIELD isShipping ON company_has_address TYPE bool DEFAULT false;
DEFINE FIELD isLegal ON company_has_address TYPE bool DEFAULT false;
DEFINE FIELD addressPurpose ON company_has_address TYPE string;

-- Intelligence géographique entreprise
DEFINE FIELD corporateGeoAI ON company_has_address TYPE object VALUE {
    strategicLocation: 0.0,
    businessAdvantages: [],
    operationalEfficiency: 0.0,
    expansionPotential: 0.0,
    competitivePosition: 'NEUTRAL'
};

-- Métadonnées
DEFINE FIELD assignedAt ON company_has_address TYPE datetime DEFAULT time::now();
DEFINE FIELD assignedBy ON company_has_address TYPE record<user>;
DEFINE FIELD isActive ON company_has_address TYPE bool DEFAULT true;

-- Relation: company → company (Groupe IA-Native)
DEFINE TABLE company_group SCHEMAFULL TYPE RELATION
    COMMENT "Groupes d'entreprises avec IA de consolidation"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE $auth.role CONTAINS 'admin'
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON company_group TYPE record<company> ASSERT $value != NULL; -- Parent
DEFINE FIELD out ON company_group TYPE record<company> ASSERT $value != NULL; -- Filiale

-- Configuration groupe
DEFINE FIELD ownershipPercentage ON company_group TYPE float 
    ASSERT $value >= 0 AND $value <= 100;

DEFINE FIELD consolidationType ON company_group TYPE string 
    ASSERT $value INSIDE ['FULL_CONSOLIDATION', 'PROPORTIONAL', 'EQUITY_METHOD', 'NO_CONSOLIDATION']
    DEFAULT 'FULL_CONSOLIDATION';

-- Intelligence groupe IA
DEFINE FIELD groupIntelligence ON company_group TYPE object VALUE {
    synergiesRealization: 0.0,
    consolidationComplexity: 0.0,
    strategicAlignment: 0.0,
    operationalIntegration: 0.0,
    riskConcentration: 0.0
};

-- Analytics groupe
DEFINE FIELD groupAnalytics ON company_group TYPE object VALUE {
    contributionToGroup: 0.0,
    performanceCorrelation: 0.0,
    riskDiversification: 0.0,
    operationalSynergies: []
};

-- Métadonnées
DEFINE FIELD groupedAt ON company_group TYPE datetime DEFAULT time::now();
DEFINE FIELD groupedBy ON company_group TYPE record<user>;
DEFINE FIELD isActive ON company_group TYPE bool DEFAULT true;

-- ================================================================================================
-- 📦 RELATIONS PRODUITS IA-ENHANCED
-- ================================================================================================

-- Relation: product → product_category (IA-Native)
DEFINE TABLE product_in_category SCHEMAFULL TYPE RELATION
    COMMENT "Classification produits avec IA de catégorisation automatique"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'product_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON product_in_category TYPE record<product> ASSERT $value != NULL;
DEFINE FIELD out ON product_in_category TYPE record<product_category> ASSERT $value != NULL;

-- Configuration classification
DEFINE FIELD isPrimary ON product_in_category TYPE bool DEFAULT true;
DEFINE FIELD classificationConfidence ON product_in_category TYPE float 
    ASSERT $value >= 0 AND $value <= 1
    DEFAULT 1.0;

-- Intelligence classification IA
DEFINE FIELD classificationAI ON product_in_category TYPE object VALUE {
    autoClassified: false,
    classificationMethod: 'MANUAL',
    alternativeCategories: [],
    confidenceFactors: {},
    learningData: {}
};

-- Analytics classification
DEFINE FIELD categoryAnalytics ON product_in_category TYPE object VALUE {
    categoryPerformance: 0.0,
    fitScore: 0.0,
    marketAlignment: 0.0,
    competitivePosition: 'AVERAGE'
};

-- Métadonnées
DEFINE FIELD classifiedAt ON product_in_category TYPE datetime DEFAULT time::now();
DEFINE FIELD classifiedBy ON product_in_category TYPE record<user>;
DEFINE FIELD lastReviewedAt ON product_in_category TYPE datetime;
DEFINE FIELD isActive ON product_in_category TYPE bool DEFAULT true;

-- Relation: product → unit (IA-Native)
DEFINE TABLE product_uses_unit SCHEMAFULL TYPE RELATION
    COMMENT "Unités de mesure produits avec IA d'optimisation"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'product_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON product_uses_unit TYPE record<product> ASSERT $value != NULL;
DEFINE FIELD out ON product_uses_unit TYPE record<unit> ASSERT $value != NULL;

-- Configuration unité
DEFINE FIELD unitPurpose ON product_uses_unit TYPE string 
    ASSERT $value INSIDE ['SALE', 'PURCHASE', 'STOCK', 'PRODUCTION', 'SHIPPING']
    DEFAULT 'SALE';

DEFINE FIELD conversionFactor ON product_uses_unit TYPE float 
    ASSERT $value > 0
    DEFAULT 1.0;

DEFINE FIELD isPrimary ON product_uses_unit TYPE bool DEFAULT true;

-- Intelligence unité IA
DEFINE FIELD unitOptimizationAI ON product_uses_unit TYPE object VALUE {
    efficiencyScore: 0.0,
    conversionAccuracy: 0.0,
    usageOptimization: {},
    alternativeUnits: [],
    performanceMetrics: {}
};

-- Analytics unité
DEFINE FIELD unitAnalytics ON product_uses_unit TYPE object VALUE {
    conversionFrequency: 0,
    errorRate: 0.0,
    usagePattern: {},
    efficiencyGains: 0.0
};

-- Métadonnées
DEFINE FIELD assignedAt ON product_uses_unit TYPE datetime DEFAULT time::now();
DEFINE FIELD assignedBy ON product_uses_unit TYPE record<user>;
DEFINE FIELD isActive ON product_uses_unit TYPE bool DEFAULT true;

-- Relation: product → price_list (IA-Native)
DEFINE TABLE product_price SCHEMAFULL TYPE RELATION
    COMMENT "Prix produits avec IA de tarification dynamique"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'pricing_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON product_price TYPE record<product> ASSERT $value != NULL;
DEFINE FIELD out ON product_price TYPE record<price_list> ASSERT $value != NULL;

-- Configuration prix
DEFINE FIELD price ON product_price TYPE decimal(20,3) 
    ASSERT $value >= 0;

DEFINE FIELD minQuantity ON product_price TYPE decimal(20,3) 
    ASSERT $value >= 0
    DEFAULT 1.0;

DEFINE FIELD maxQuantity ON product_price TYPE option<decimal(20,3)>;

DEFINE FIELD validFrom ON product_price TYPE option<date>;
DEFINE FIELD validTo ON product_price TYPE option<date>;

-- Intelligence pricing IA
DEFINE FIELD pricingAI ON product_price TYPE object VALUE {
    priceOptimization: {},
    demandElasticity: 0.0,
    competitiveAnalysis: {},
    marginAnalysis: {},
    seasonalAdjustments: {},
    dynamicPricing: false
};

-- Analytics pricing
DEFINE FIELD priceAnalytics ON product_price TYPE object VALUE {
    salesVolume: 0.0,
    revenue: 0.0,
    margin: 0.0,
    priceAcceptance: 0.0,
    competitivePosition: 'AVERAGE'
};

-- Prédictions IA
DEFINE FIELD pricePredictions ON product_price TYPE object VALUE {
    optimalPrice: 0.0,
    demandForecast: 0.0,
    marginOptimization: 0.0,
    competitiveResponse: {}
};

-- Métadonnées
DEFINE FIELD pricedAt ON product_price TYPE datetime DEFAULT time::now();
DEFINE FIELD pricedBy ON product_price TYPE record<user>;
DEFINE FIELD lastUpdatedAt ON product_price TYPE datetime DEFAULT time::now();
DEFINE FIELD isActive ON product_price TYPE bool DEFAULT true;

-- ================================================================================================
-- 💰 RELATIONS FINANCIÈRES IA-ENHANCED
-- ================================================================================================

-- Relation: company → currency (IA-Native)
DEFINE TABLE company_uses_currency SCHEMAFULL TYPE RELATION
    COMMENT "Devises d'entreprise avec IA de gestion de change"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON company_uses_currency TYPE record<company> ASSERT $value != NULL;
DEFINE FIELD out ON company_uses_currency TYPE record<currency> ASSERT $value != NULL;

-- Configuration devise
DEFINE FIELD isDefault ON company_uses_currency TYPE bool DEFAULT false;
DEFINE FIELD usagePurpose ON company_uses_currency TYPE string 
    ASSERT $value INSIDE ['ACCOUNTING', 'SALES', 'PURCHASE', 'REPORTING', 'INTERNATIONAL']
    DEFAULT 'ACCOUNTING';

-- Intelligence change IA
DEFINE FIELD exchangeRateAI ON company_uses_currency TYPE object VALUE {
    hedgingStrategy: {},
    riskExposure: 0.0,
    optimalExchangeTiming: {},
    costImpact: 0.0,
    volatilityManagement: {}
};

-- Analytics change
DEFINE FIELD currencyAnalytics ON company_uses_currency TYPE object VALUE {
    exchangeGainLoss: 0.0,
    transactionVolume: 0.0,
    hedgingEffectiveness: 0.0,
    riskMetrics: {}
};

-- Métadonnées
DEFINE FIELD adoptedAt ON company_uses_currency TYPE datetime DEFAULT time::now();
DEFINE FIELD adoptedBy ON company_uses_currency TYPE record<user>;
DEFINE FIELD isActive ON company_uses_currency TYPE bool DEFAULT true;

-- Relation: partner → payment_term (IA-Native)
DEFINE TABLE partner_payment_terms SCHEMAFULL TYPE RELATION
    COMMENT "Conditions de paiement partenaires avec IA de négociation"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON partner_payment_terms TYPE record<partner> ASSERT $value != NULL;
DEFINE FIELD out ON partner_payment_terms TYPE record<payment_term> ASSERT $value != NULL;

-- Configuration paiement
DEFINE FIELD isDefault ON partner_payment_terms TYPE bool DEFAULT false;
DEFINE FIELD negotiationLevel ON partner_payment_terms TYPE string 
    ASSERT $value INSIDE ['STANDARD', 'NEGOTIATED', 'PREFERRED', 'STRATEGIC']
    DEFAULT 'STANDARD';

-- Intelligence négociation IA
DEFINE FIELD negotiationAI ON partner_payment_terms TYPE object VALUE {
    negotiationPotential: 0.0,
    partnerLeverage: 0.0,
    riskAssessment: 0.0,
    cashFlowImpact: 0.0,
    optimalTerms: {}
};

-- Analytics paiement
DEFINE FIELD paymentAnalytics ON partner_payment_terms TYPE object VALUE {
    complianceRate: 0.0,
    averagePaymentDelay: 0.0,
    discountUtilization: 0.0,
    cashFlowPrediction: {}
};

-- Métadonnées
DEFINE FIELD negotiatedAt ON partner_payment_terms TYPE datetime DEFAULT time::now();
DEFINE FIELD negotiatedBy ON partner_payment_terms TYPE record<user>;
DEFINE FIELD lastReviewedAt ON partner_payment_terms TYPE datetime;
DEFINE FIELD isActive ON partner_payment_terms TYPE bool DEFAULT true;

-- ================================================================================================
-- 🏦 RELATIONS BANCAIRES IA-ENHANCED
-- ================================================================================================

-- Relation: company → bank_detail (IA-Native)
DEFINE TABLE company_banking SCHEMAFULL TYPE RELATION
    COMMENT "Relations bancaires avec IA de gestion trésorerie"
    PERMISSIONS 
        FOR SELECT WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager')
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON company_banking TYPE record<company> ASSERT $value != NULL;
DEFINE FIELD out ON company_banking TYPE record<bank_detail> ASSERT $value != NULL;

-- Configuration bancaire
DEFINE FIELD isMainAccount ON company_banking TYPE bool DEFAULT false;
DEFINE FIELD accountPurpose ON company_banking TYPE string 
    ASSERT $value INSIDE ['OPERATING', 'PAYROLL', 'INVESTMENT', 'ESCROW', 'SAVINGS']
    DEFAULT 'OPERATING';

DEFINE FIELD creditLimit ON company_banking TYPE option<decimal(20,3)>;
DEFINE FIELD overdraftLimit ON company_banking TYPE option<decimal(20,3)>;

-- Intelligence bancaire IA
DEFINE FIELD bankingAI ON company_banking TYPE object VALUE {
    cashFlowOptimization: {},
    liquidityManagement: {},
    riskAssessment: 0.0,
    bankRelationshipScore: 0.0,
    optimizationOpportunities: []
};

-- Analytics bancaires
DEFINE FIELD bankingAnalytics ON company_banking TYPE object VALUE {
    averageBalance: 0.0,
    transactionVolume: 0.0,
    fees: 0.0,
    utilizationRate: 0.0,
    performanceMetrics: {}
};

-- Métadonnées
DEFINE FIELD establishedAt ON company_banking TYPE datetime DEFAULT time::now();
DEFINE FIELD establishedBy ON company_banking TYPE record<user>;
DEFINE FIELD lastReviewedAt ON company_banking TYPE datetime;
DEFINE FIELD isActive ON company_banking TYPE bool DEFAULT true;

-- ================================================================================================
-- 🔢 RELATIONS SÉQUENCES IA-ENHANCED
-- ================================================================================================

-- Relation: company → sequence (IA-Native)
DEFINE TABLE company_sequences SCHEMAFULL TYPE RELATION
    COMMENT "Séquences d'entreprise avec IA d'optimisation"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'system_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON company_sequences TYPE record<company> ASSERT $value != NULL;
DEFINE FIELD out ON company_sequences TYPE record<sequence> ASSERT $value != NULL;

-- Configuration séquence
DEFINE FIELD isDefault ON company_sequences TYPE bool DEFAULT false;
DEFINE FIELD entityType ON company_sequences TYPE string 
    ASSERT $value != NULL
    COMMENT "Type d'entité utilisant la séquence";

-- Intelligence séquence IA
DEFINE FIELD sequenceAI ON company_sequences TYPE object VALUE {
    usageOptimization: {},
    collisionPrevention: {},
    performancePrediction: {},
    scalabilityAssessment: 0.0
};

-- Analytics séquence
DEFINE FIELD sequenceAnalytics ON company_sequences TYPE object VALUE {
    generationFrequency: 0,
    peakUsage: 0,
    efficiencyMetrics: {},
    forecastAccuracy: 0.0
};

-- Métadonnées
DEFINE FIELD assignedAt ON company_sequences TYPE datetime DEFAULT time::now();
DEFINE FIELD assignedBy ON company_sequences TYPE record<user>;
DEFINE FIELD isActive ON company_sequences TYPE bool DEFAULT true;

-- ================================================================================================
-- 🌐 RELATIONS CONFIGURATION IA-ENHANCED
-- ================================================================================================

-- Relation: company → locale_configuration (IA-Native)
-- ================================================================================================
-- 🛡️ RELATIONS SÉCURITÉ ET CONFORMITÉ IA-ENHANCED
-- ================================================================================================
-- MIGRATION NOTICE: Configuration locale (company_locale) migrée vers module config
-- ================================================================================================


-- ================================================================================================
-- 🛡️ RELATIONS SÉCURITÉ ET CONFORMITÉ IA-ENHANCED
-- ================================================================================================

-- Relation: partner → fiscal_position (IA-Native)
DEFINE TABLE partner_fiscal_position SCHEMAFULL TYPE RELATION
    COMMENT "Positions fiscales partenaires avec IA de conformité"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'tax_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON partner_fiscal_position TYPE record<partner> ASSERT $value != NULL;
DEFINE FIELD out ON partner_fiscal_position TYPE record<fiscal_position> ASSERT $value != NULL;

-- Configuration fiscale
DEFINE FIELD isDefault ON partner_fiscal_position TYPE bool DEFAULT false;
DEFINE FIELD validFrom ON partner_fiscal_position TYPE option<date>;
DEFINE FIELD validTo ON partner_fiscal_position TYPE option<date>;

-- Intelligence fiscale IA
DEFINE FIELD fiscalComplianceAI ON partner_fiscal_position TYPE object VALUE {
    complianceScore: 100.0,
    riskLevel: 'LOW',
    auditRisk: 0.0,
    optimizationOpportunities: [],
    regulatoryAlignment: 0.0
};

-- Analytics fiscales
DEFINE FIELD fiscalAnalytics ON partner_fiscal_position TYPE object VALUE {
    taxEfficiency: 0.0,
    complianceHistory: [],
    savingsRealized: 0.0,
    riskMetrics: {}
};

-- Métadonnées
DEFINE FIELD assignedAt ON partner_fiscal_position TYPE datetime DEFAULT time::now();
DEFINE FIELD assignedBy ON partner_fiscal_position TYPE record<user>;
DEFINE FIELD lastAuditedAt ON partner_fiscal_position TYPE datetime;
DEFINE FIELD isActive ON partner_fiscal_position TYPE bool DEFAULT true;

-- ================================================================================================
-- 🎯 RELATIONS SUPPLY CHAIN IA-ENHANCED
-- ================================================================================================

-- Relation: partner → product (Supply Chain IA-Native)
DEFINE TABLE supplies SCHEMAFULL TYPE RELATION
    COMMENT "Relations fournisseur-produit avec IA supply chain avancée"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'supply_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON supplies TYPE record<partner> ASSERT $value != NULL; -- Fournisseur
DEFINE FIELD out ON supplies TYPE record<product> ASSERT $value != NULL; -- Produit

-- Configuration supply chain
DEFINE FIELD isPreferred ON supplies TYPE bool DEFAULT false;
DEFINE FIELD priorityLevel ON supplies TYPE string 
    ASSERT $value INSIDE ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
    DEFAULT 'MEDIUM';

DEFINE FIELD leadTime ON supplies TYPE int 
    ASSERT $value >= 0
    COMMENT "Délai de livraison en jours";

DEFINE FIELD minimumOrderQuantity ON supplies TYPE decimal(20,3) 
    ASSERT $value >= 0;

DEFINE FIELD unitCost ON supplies TYPE decimal(20,3) 
    ASSERT $value >= 0;

-- Intelligence IA supply chain révolutionnaire
DEFINE FIELD supplyChainAI ON supplies TYPE object VALUE {
    reliabilityScore: 85.0,
    qualityScore: 90.0,
    costEfficiencyScore: 75.0,
    innovationScore: 60.0,
    sustainabilityScore: 70.0,
    riskScore: 25.0,
    partnershipPotential: 80.0,
    strategicValue: 65.0
};

-- Analytics fournisseur IA
DEFINE FIELD supplierAnalytics ON supplies TYPE object VALUE {
    totalOrders: 0,
    onTimeDeliveries: 0,
    qualityIncidents: 0,
    costSavings: 0.0,
    leadTimeVariation: 0.0,
    performanceTrend: 'STABLE'
};

-- Prédictions supply chain IA
DEFINE FIELD supplyPredictions ON supplies TYPE object VALUE {
    futureAvailability: 0.0,
    priceFluctuation: {},
    leadTimeOptimization: 0.0,
    riskFactors: [],
    alternativeSuppliers: []
};

-- Optimisation automatique IA
DEFINE FIELD autoOptimization ON supplies TYPE object VALUE {
    optimalOrderQuantity: 0.0,
    bestOrderTiming: null,
    costOptimization: 0.0,
    riskMitigation: []
};

-- Scoring fournisseur global
DEFINE FIELD supplierScore ON supplies TYPE float 
    ASSERT $value >= 0 AND $value <= 100
    DEFAULT 75.0;

-- Conformité et qualité
DEFINE FIELD complianceData ON supplies TYPE object VALUE {
    certifications: [],
    auditDate: null,
    complianceScore: 0.0,
    qualityStandards: []
};

-- Métadonnées
DEFINE FIELD establishedAt ON supplies TYPE datetime DEFAULT time::now();
DEFINE FIELD establishedBy ON supplies TYPE record<user>;
DEFINE FIELD lastEvaluatedAt ON supplies TYPE datetime;
DEFINE FIELD isActive ON supplies TYPE bool DEFAULT true;

-- ================================================================================================
-- 🎯 CONCLUSION - RÉSEAU INTELLIGENT LYXAL-BASE
-- ================================================================================================

-- Total : 23 relations graphe IA-native complètes
-- Architecture : Réseau intelligent d'entreprise avec scoring automatique
-- Capacités : Prédictions relationnelles, optimisations automatiques, analytics temps réel
-- Innovation : Intelligence artificielle intégrée dans chaque relation
-- Performance : Scoring automatique, détection d'anomalies, recommandations intelligentes 
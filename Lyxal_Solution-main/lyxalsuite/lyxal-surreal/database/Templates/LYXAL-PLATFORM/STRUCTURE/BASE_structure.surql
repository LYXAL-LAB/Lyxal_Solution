-- ================================================================================================
-- 🏗️ LYXAL BASE - STRUCTURE PRINCIPALE IA-NATIVE
-- ================================================================================================
-- Module : lyxal-base
-- Description : Structure complète des 24 entités IA-native avec SurrealDB révolutionnaire
-- Version : 1.0.0
-- Architecture : Backend-as-a-Database avec IA intégrée
-- ================================================================================================
-- ================================================================================================
-- ⚙️ CONFIGURATION SYSTÈME - LYXAL SURREAL
-- ================================================================================================
-- 
-- Ce fichier contient toutes les tables de configuration système
-- 
-- Tables incluses:
-- - system_identity: Configuration identité plateforme LYXAL
-- - system_infrastructure: Configuration infrastructure technique LYXAL
-- - app_configuration: Configuration app
-- - locale_configuration: Configuration locale
-- - period_configuration: Configuration period
-- - notification_configuration: Configuration notification
-- - import_configuration: Configuration import
-- 
-- Date de migration: 2025-06-26T15:30:31.009Z
-- Date ajout MASTER: 2025-01-27T10:00:00.000Z
-- ================================================================================================

-- ================================================================================================
-- 🌍 ENTITÉS DE RÉFÉRENCE GÉOGRAPHIQUE
-- A TERMINER EN FIN DE STRUCTURE COMPLETE DES TABLES
-- ================================================================================================

-- Table: country (Pays)
DEFINE TABLE country SCHEMAFULL
    COMMENT "Pays avec données géographiques et IA prédictive"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON country TYPE string 
    ASSERT $value != NULL AND string::len($value) >= 2 AND string::len($value) <= 3
    COMMENT "Code pays ISO";

DEFINE FIELD name ON country TYPE string 
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du pays";

DEFINE FIELD alpha2Code ON country TYPE string 
    ASSERT $value = NULL OR string::len($value) = 2
    COMMENT "Code ISO Alpha-2";

DEFINE FIELD alpha3Code ON country TYPE string 
    ASSERT $value = NULL OR string::len($value) = 3
    COMMENT "Code ISO Alpha-3";

DEFINE FIELD phonePrefix ON country TYPE option<string>
    COMMENT "Préfixe téléphonique international";

DEFINE FIELD numericCode ON country TYPE option<string>
    COMMENT "Code numérique ISO";

DEFINE FIELD isDefault ON country TYPE bool DEFAULT false
    COMMENT "Pays par défaut du système";

DEFINE FIELD isObsolete ON country TYPE bool DEFAULT false
    COMMENT "Pays obsolète";

-- Données IA géographiques
DEFINE FIELD geoIntelligence ON country TYPE object VALUE {
    economicIndicators: {
        gdp: 0.0,
        growthRate: 0.0,
        inflationRate: 0.0,
        currencyStability: 0.0
    },
    businessEnvironment: {
        easeOfBusiness: 0.0,
        taxRate: 0.0,
        regulationComplexity: 0.0,
        marketSize: 0.0
    },
    riskFactors: {
        politicalStability: 0.0,
        economicRisk: 0.0,
        currencyRisk: 0.0,
        operationalRisk: 0.0
    }
};

DEFINE FIELD aiPredictions ON country TYPE object VALUE {
    marketPotential: 0.0,
    expansionRisk: 0.0,
    competitiveAdvantage: [],
    recommendedStrategies: []
};

-- Métadonnées système
DEFINE FIELD createdAt ON country TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON country TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON country TYPE option<record<user>>;
DEFINE FIELD archived ON country TYPE bool DEFAULT false;

-- ================================================================================================
-- 💰 ENTITÉS FINANCIÈRES DE BASE
-- Uniquement déployé sur LYXAL PLATFORM
-- Chaque SaaS accède à ces tables via des fonctions SurrealDB
-- données de base à insérer dans fichier lyxal-reference-data.surql
-- ================================================================================================

-- Table: currency (Devises)
DEFINE TABLE currency SCHEMAFULL
    COMMENT "Devises avec IA de change et prédictions économiques"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON currency TYPE string 
    ASSERT $value != NULL AND string::len($value) = 3
    COMMENT "Code devise ISO 4217";

DEFINE FIELD name ON currency TYPE string 
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la devise";

DEFINE FIELD symbol ON currency TYPE option<string>
    COMMENT "Symbole de la devise (€, $, £)";

DEFINE FIELD decimalDigits ON currency TYPE int 
    ASSERT $value >= 0 AND $value <= 4
    VALUE $value OR 2
    COMMENT "Nombre de décimales";

DEFINE FIELD isDefault ON currency TYPE bool DEFAULT false
    COMMENT "Devise par défaut du système";

DEFINE FIELD isActive ON currency TYPE bool DEFAULT true
    COMMENT "Devise active";

DEFINE FIELD isBaseCurrency ON currency TYPE bool DEFAULT false
    COMMENT "Devise de référence pour les taux (ex: USD)";

DEFINE FIELD currencyFamily ON currency TYPE string
    ASSERT $value INSIDE ['FIAT', 'CRYPTO', 'STABLECOIN', 'COMMODITY']
    VALUE $value OR 'FIAT'
    COMMENT "Famille de devise pour traitements spécifiques";

-- Intelligence IA des taux de change
DEFINE FIELD exchangeRateAI ON currency TYPE object VALUE {
    currentRate: 1.0,
    trend: "stable",
    volatility: 0.0,
    lastUpdated: time::now(),
    confidence: 0.0,
    rateHistory: [],
    fluctuation24h: 0.0,
    fluctuation7d: 0.0,
    fluctuation30d: 0.0
};

-- Prédictions économiques IA
DEFINE FIELD economicPredictions ON currency TYPE object VALUE {
    futureRate: 0.0,
    rateDirection: "stable",
    confidenceInterval: [0.0, 0.0],
    economicFactors: [],
    riskAssessment: 0.0,
    optimalExchangeWindow: null,
    hedgingRecommendations: []
};

-- Analytics avancées
DEFINE FIELD currencyAnalytics ON currency TYPE object VALUE {
    tradingVolume: 0.0,
    marketShare: 0.0,
    liquidity: 0.0,
    correlations: {},
    seasonalPatterns: {},
    newsImpact: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON currency TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON currency TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON currency TYPE option<record<user>>;
DEFINE FIELD archived ON currency TYPE bool DEFAULT false;

-- Table: unit (Unités de mesure)
DEFINE TABLE unit SCHEMAFULL
    COMMENT "Unités de mesure avec IA de conversion et optimisation"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'inventory_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON unit TYPE string 
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code unité unique";

DEFINE FIELD name ON unit TYPE string 
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de l'unité";

DEFINE FIELD symbol ON unit TYPE option<string>
    COMMENT "Symbole de l'unité (kg, m, L)";

DEFINE FIELD unitType ON unit TYPE string 
    ASSERT $value INSIDE ['LENGTH', 'WEIGHT', 'VOLUME', 'AREA', 'TIME', 'QUANTITY', 'TEMPERATURE', 'ENERGY', 'CUSTOM']
    VALUE $value OR 'QUANTITY'
    COMMENT "Type d'unité de mesure";

DEFINE FIELD baseUnit ON unit TYPE option<record<unit>>
    COMMENT "Unité de base pour conversion (même type d'unité uniquement)";

DEFINE FIELD conversionRate ON unit TYPE float 
    ASSERT $value > 0
    VALUE $value OR 1.0
    COMMENT "Taux de conversion vers unité de base";

DEFINE FIELD isDefault ON unit TYPE bool DEFAULT false
    COMMENT "Unité par défaut pour ce type";

-- Intelligence IA des conversions
DEFINE FIELD conversionAI ON unit TYPE object VALUE {
    accuracyScore: 1.0,
    usageFrequency: 0,
    conversionHistory: [],
    errorRate: 0.0,
    optimalPrecision: 2,
    commonConversions: {},
    industryStandards: []
};

-- Analytics d'utilisation
DEFINE FIELD usageAnalytics ON unit TYPE object VALUE {
    totalUsage: 0,
    averageQuantity: 0.0,
    peakUsage: 0.0,
    lastUsed: null,
    popularCombinations: [],
    efficiencyMetrics: {}
};

-- Optimisations IA
DEFINE FIELD aiOptimizations ON unit TYPE object VALUE {
    suggestedAlternatives: [],
    costOptimizations: [],
    inventoryImpact: 0.0,
    processingEfficiency: 0.0,
    qualityMetrics: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON unit TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON unit TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON unit TYPE option<record<user>>;
DEFINE FIELD archived ON unit TYPE bool DEFAULT false;

-- Table: business_sector (Secteurs d'activité hiérarchiques)
DEFINE TABLE business_sector SCHEMAFULL
    COMMENT "Secteurs et sous-secteurs hiérarchiques universels"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'business_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON business_sector TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code unique (ex: REST, REST_PIZZA, REST_PIZZA_DELIVERY)";

DEFINE FIELD name ON business_sector TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom (ex: Restauration, Pizzeria, Livraison Pizza)";

DEFINE FIELD parentSector ON business_sector TYPE option<record<business_sector>>
    COMMENT "Secteur parent (NULL = secteur racine)";

DEFINE FIELD level ON business_sector TYPE int
    ASSERT $value >= 0 AND $value <= 5
    VALUE $value OR 0
    COMMENT "Niveau hiérarchique (0=secteur, 1=sous-secteur, 2=sous-sous-secteur)";

DEFINE FIELD description ON business_sector TYPE option<string>
    COMMENT "Description du secteur";

DEFINE FIELD isActive ON business_sector TYPE bool DEFAULT true
    COMMENT "Secteur actif";

-- Intelligence IA sectorielle
DEFINE FIELD sectorAI ON business_sector TYPE object VALUE {
    marketSize: 0.0,
    growthRate: 0.0,
    competitiveIntensity: 0.0,
    digitalMaturity: 0.0,
    regulationLevel: 0.0,
    seasonalityFactor: 1.0
};

-- Métadonnées
DEFINE FIELD createdAt ON business_sector TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON business_sector TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON business_sector TYPE option<record<user>>;

-- Table: business_model (Modèles économiques)
DEFINE TABLE business_model SCHEMAFULL
    COMMENT "Modèles économiques universels - Référentiel unique"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'business_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON business_model TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code modèle (ex: B2B, B2C, SAAS)";

DEFINE FIELD name ON business_model TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du modèle (ex: Business to Business)";

DEFINE FIELD description ON business_model TYPE option<string>
    COMMENT "Description détaillée du modèle";

DEFINE FIELD category ON business_model TYPE string
    ASSERT $value INSIDE ['TRADITIONAL', 'DIGITAL', 'HYBRID', 'PLATFORM', 'SUBSCRIPTION', 'MARKETPLACE']
    VALUE $value OR 'TRADITIONAL'
    COMMENT "Catégorie de modèle économique";

DEFINE FIELD isActive ON business_model TYPE bool DEFAULT true
    COMMENT "Modèle actif";

-- Intelligence IA modèle économique
DEFINE FIELD modelAI ON business_model TYPE object VALUE {
    profitabilityScore: 0.0,
    scalabilityIndex: 0.0,
    capitalRequirement: 0.0,
    riskLevel: 0.0,
    digitalReadiness: 0.0,
    marketFit: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON business_model TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON business_model TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON business_model TYPE option<record<user>>;

-- ================================================================================================
-- 🎯 INDEX OPTIMISÉS - ENTITÉS FINANCIÈRES DE BASE
-- ================================================================================================

-- Index pour currency
DEFINE INDEX currency_code_idx ON currency FIELDS code UNIQUE;
DEFINE INDEX currency_active_idx ON currency FIELDS isActive;
DEFINE INDEX currency_default_idx ON currency FIELDS isDefault;
DEFINE INDEX currency_base_idx ON currency FIELDS isBaseCurrency;
DEFINE INDEX currency_family_idx ON currency FIELDS currencyFamily;

-- Index pour unit  
DEFINE INDEX unit_code_idx ON unit FIELDS code UNIQUE;
DEFINE INDEX unit_type_idx ON unit FIELDS unitType;
DEFINE INDEX unit_default_idx ON unit FIELDS isDefault;
DEFINE INDEX unit_base_idx ON unit FIELDS baseUnit;

-- Index pour business_sector
DEFINE INDEX business_sector_code_idx ON business_sector FIELDS code UNIQUE;
DEFINE INDEX business_sector_parent_idx ON business_sector FIELDS parentSector;
DEFINE INDEX business_sector_level_idx ON business_sector FIELDS level;
DEFINE INDEX business_sector_active_idx ON business_sector FIELDS isActive;

-- Index pour business_model
DEFINE INDEX business_model_code_idx ON business_model FIELDS code UNIQUE;
DEFINE INDEX business_model_category_idx ON business_model FIELDS category;
DEFINE INDEX business_model_active_idx ON business_model FIELDS isActive;

-- ================================================================================================
-- 🏢 ENTITÉS PRINCIPALES
-- ================================================================================================

-- Table: company (Sociétés)
DEFINE TABLE company SCHEMAFULL
    COMMENT "Sociétés avec IA intégrée et structure complète validée"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'company_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

-- Identification obligatoire
DEFINE FIELD code ON company TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2 AND string::len($value) <= 20
    COMMENT "Code unique de la société";

DEFINE FIELD name ON company TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2 AND string::len($value) <= 200
    COMMENT "Nom de la société";

DEFINE FIELD legalName ON company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 200
    COMMENT "Raison sociale officielle";

DEFINE FIELD shortName ON company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 50
    COMMENT "Nom court pour affichage";

-- Contact et localisation
DEFINE FIELD email ON company TYPE option<string>
    ASSERT $value = NONE OR string::is::email($value)
    COMMENT "Email principal";

DEFINE FIELD phone ON company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 20
    COMMENT "Téléphone principal";

DEFINE FIELD website ON company TYPE option<string>
    ASSERT $value = NONE OR string::starts_with($value, 'http')
    COMMENT "Site web";

DEFINE FIELD address ON company TYPE option<record<address>>
    COMMENT "Adresse principale géolocalisée";

DEFINE FIELD country ON company TYPE string
    VALUE $value OR 'FR'
    ASSERT string::len($value) = 2 OR string::len($value) = 3
    COMMENT "Pays principal (code ISO)";

-- Informations légales flexibles
DEFINE FIELD registrationNumber ON company TYPE option<string>
    COMMENT "Numéro d'enregistrement principal";

DEFINE FIELD taxNumber ON company TYPE option<string>
    COMMENT "Numéro de TVA/Tax ID";

DEFINE FIELD legalInfo ON company TYPE option<object>
    COMMENT "Informations légales spécifiques au pays avec validation IA";

DEFINE FIELD registrationDate ON company TYPE option<date>
    COMMENT "Date d'enregistrement";

DEFINE FIELD legalForm ON company TYPE option<string>
    COMMENT "Forme juridique (SARL, SAS, etc.)";

-- Hiérarchie et relations
DEFINE FIELD parentCompany ON company TYPE option<record<company>>
    COMMENT "Société mère";

DEFINE FIELD subsidiaries ON company TYPE option<array<record<company>>>
    COMMENT "Filiales directes";

DEFINE FIELD isHeadquarters ON company TYPE bool
    VALUE $value OR false
    COMMENT "Est le siège social";

DEFINE FIELD companyGroup ON company TYPE option<string>
    COMMENT "Groupe d'appartenance";

-- Secteur et marché IA-Enhanced
DEFINE FIELD sector ON company TYPE option<record<business_sector>>
    COMMENT "Secteur d'activité principal (référence universelle)";

DEFINE FIELD subSectors ON company TYPE option<array<record<business_sector>>>
    COMMENT "Sous-secteurs d'activité (références universelles)";

DEFINE FIELD businessModel ON company TYPE option<record<business_model>>
    COMMENT "Modèle économique (référence universelle)";

DEFINE FIELD targetMarkets ON company TYPE option<array<string>>
    COMMENT "Marchés cibles géographiques";

DEFINE FIELD competitiveAdvantage ON company TYPE option<array<string>>
    COMMENT "Avantages concurrentiels identifiés";

-- Taille et métriques
DEFINE FIELD size ON company TYPE option<string>
    ASSERT $value = NONE OR $value INSIDE ['startup', 'micro', 'small', 'medium', 'large', 'enterprise', 'unicorn']
    COMMENT "Taille de l'entreprise";

DEFINE FIELD employeeCount ON company TYPE option<int>
    ASSERT $value = NONE OR $value >= 0
    COMMENT "Nombre d'employés";

DEFINE FIELD foundingDate ON company TYPE option<date>
    COMMENT "Date de création";

DEFINE FIELD revenue ON company TYPE option<object>
    COMMENT "Chiffre d'affaires avec historique";

-- Paramètres financiers
DEFINE FIELD defaultCurrency ON company TYPE string
    VALUE $value OR 'EUR'
    ASSERT string::len($value) = 3
    COMMENT "Devise par défaut";

DEFINE FIELD fiscalYearStart ON company TYPE option<string>
    ASSERT $value = NONE OR $value =~ /^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/
    VALUE $value OR '01-01'
    COMMENT "Début d'année fiscale (MM-DD)";

-- Paramètres opérationnels
DEFINE FIELD timeTracking ON company TYPE bool
    VALUE $value OR false
    COMMENT "Suivi du temps activé";

DEFINE FIELD invoiceTemplate ON company TYPE option<string>
    COMMENT "Template de facture par défaut";

DEFINE FIELD orderTemplate ON company TYPE option<string>
    COMMENT "Template de commande par défaut";

DEFINE FIELD allowCreditStatements ON company TYPE bool
    VALUE $value OR false
    COMMENT "Autoriser les relevés de crédit";

DEFINE FIELD enableEDI ON company TYPE bool
    VALUE $value OR false
    COMMENT "EDI activé";

-- Métadonnées
DEFINE FIELD logo ON company TYPE option<string>
    COMMENT "URL ou path du logo";

-- Profil IA complet
DEFINE FIELD aiProfile ON company TYPE object VALUE {
    confidence: 0.0,
    source: 'manual',
    lastAnalyzed: time::now(),
    analysisVersion: '1.0',
    dataQuality: 0.0,
    completeness: 0.0,
    riskScore: 0.0,
    segmentation: 'unknown',
    maturityLevel: 'unknown'
};

-- Insights IA avancés
DEFINE FIELD aiInsights ON company TYPE object VALUE {
    marketPosition: 'unknown',
    growthStage: 'unknown',
    financialHealth: 0.0,
    operationalEfficiency: 0.0,
    innovationIndex: 0.0,
    digitalizationLevel: 0.0,
    sustainabilityScore: 0.0,
    employeeSatisfaction: 0.0,
    customerSatisfaction: 0.0,
    marketShare: 0.0,
    competitivePosition: 'unknown'
};

-- Métriques IA business
DEFINE FIELD aiMetrics ON company TYPE object VALUE {
    performanceScore: 0.0,
    efficiencyScore: 0.0,
    innovationScore: 0.0,
    riskScore: 0.0,
    growthScore: 0.0,
    profitabilityScore: 0.0,
    marketScore: 0.0,
    operationalScore: 0.0,
    lastCalculated: null,
    trendsHistory: []
};

-- Prédictions IA
DEFINE FIELD aiPredictions ON company TYPE object VALUE {
    growthForecast: 0.0,
    revenuePrediction: 0.0,
    marketExpansion: [],
    riskFactors: [],
    opportunities: [],
    challenges: [],
    recommendedActions: [],
    investmentNeeds: 0.0,
    competitiveThreats: [],
    innovation_opportunities: []
};

-- Métadonnées système
DEFINE FIELD createdAt ON company TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON company TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON company TYPE option<record<user>>;
DEFINE FIELD archived ON company TYPE bool DEFAULT false;

-- Table: address (Adresses)
DEFINE TABLE address SCHEMAFULL
    COMMENT "Adresses avec géolocalisation et IA de validation"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'data_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

-- Adresse de base
DEFINE FIELD addressL1 ON address TYPE option<string>
    COMMENT "Ligne d'adresse 1";

DEFINE FIELD addressL2 ON address TYPE option<string>
    COMMENT "Ligne d'adresse 2";

DEFINE FIELD addressL3 ON address TYPE option<string>
    COMMENT "Ligne d'adresse 3";

DEFINE FIELD addressL4 ON address TYPE option<string>
    COMMENT "Ligne d'adresse 4 (complément)";

DEFINE FIELD addressL5 ON address TYPE option<string>
    COMMENT "Ligne d'adresse 5 (ville)";

DEFINE FIELD addressL6 ON address TYPE option<string>
    COMMENT "Ligne d'adresse 6 (pays)";

-- Géolocalisation
DEFINE FIELD zip ON address TYPE option<string>
    COMMENT "Code postal";

DEFINE FIELD city ON address TYPE option<string>
    COMMENT "Ville";

DEFINE FIELD state ON address TYPE option<string>
    COMMENT "État/Province";

DEFINE FIELD country ON address TYPE option<record<country>>
    COMMENT "Pays";

-- Coordonnées GPS
DEFINE FIELD latitude ON address TYPE option<float>
    ASSERT $value = NONE OR ($value >= -90 AND $value <= 90)
    COMMENT "Latitude GPS";

DEFINE FIELD longitude ON address TYPE option<float>
    ASSERT $value = NONE OR ($value >= -180 AND $value <= 180)
    COMMENT "Longitude GPS";

-- Intelligence géospatiale IA
DEFINE FIELD geoIntelligence ON address TYPE object VALUE {
    accuracy: 0.0,
    validationStatus: 'unknown',
    geocodingConfidence: 0.0,
    addressQuality: 0.0,
    deliveryRisk: 0.0,
    accessibilityScore: 0.0,
    proximityAdvantages: [],
    transportationOptions: []
};

-- Analytics géographiques
DEFINE FIELD locationAnalytics ON address TYPE object VALUE {
    deliveryHistory: [],
    averageDeliveryTime: 0.0,
    deliverySuccessRate: 0.0,
    accessibilityNotes: [],
    optimalDeliveryWindows: {},
    seasonalVariations: {}
};

-- Optimisations logistiques IA
DEFINE FIELD logisticsAI ON address TYPE object VALUE {
    routeOptimization: {},
    deliveryPredictions: {},
    costEstimations: {},
    riskAssessment: 0.0,
    alternativeRoutes: [],
    logisticsPartners: []
};

-- Métadonnées
DEFINE FIELD createdAt ON address TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON address TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON address TYPE option<record<user>>;
DEFINE FIELD archived ON address TYPE bool DEFAULT false;

-- Table: partner (Partenaires)
DEFINE TABLE partner SCHEMAFULL
    COMMENT "Partenaires avec IA intégrée et adaptabilité universelle"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'partner_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

-- Identification universelle
DEFINE FIELD name ON partner TYPE string 
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom principal (entreprise ou nom de famille)";

DEFINE FIELD firstName ON partner TYPE option<string>
    COMMENT "Prénom si personne physique";

DEFINE FIELD isCompany ON partner TYPE bool 
    VALUE $value OR false
    COMMENT "true=Entreprise, false=Personne physique";

-- Contact universel
DEFINE FIELD emailAddress ON partner TYPE option<string>
    ASSERT $value = NONE OR string::is::email($value)
    COMMENT "Email principal";

DEFINE FIELD phone ON partner TYPE option<string>
    COMMENT "Téléphone principal";

DEFINE FIELD website ON partner TYPE option<string>
    ASSERT $value = NONE OR string::starts_with($value, 'http')
    COMMENT "Site web";

-- Localisation et langue
DEFINE FIELD language ON partner TYPE option<record<language>>
    COMMENT "Langue préférée";

DEFINE FIELD timezone ON partner TYPE option<string>
    COMMENT "Fuseau horaire préféré";

DEFINE FIELD country ON partner TYPE option<record<country>>
    COMMENT "Pays principal";

-- Statut universel
DEFINE FIELD isActive ON partner TYPE bool 
    VALUE $value OR true
    COMMENT "Partenaire actif";

DEFINE FIELD archived ON partner TYPE bool 
    VALUE $value OR false
    COMMENT "Archivé";

DEFINE FIELD blocked ON partner TYPE bool 
    VALUE $value OR false
    COMMENT "Bloqué temporairement";

DEFINE FIELD blockedReason ON partner TYPE option<string>
    COMMENT "Raison du blocage";

-- Données métier flexibles
DEFINE FIELD businessData ON partner TYPE option<object>
    COMMENT "Données spécifiques au domaine métier (BTP, Restaurant, etc.)";

DEFINE FIELD preferences ON partner TYPE option<object>
    COMMENT "Préférences utilisateur";

DEFINE FIELD settings ON partner TYPE option<object>
    COMMENT "Paramètres de comportement";

-- Classification libre
DEFINE FIELD tags ON partner TYPE option<array<string>>
    COMMENT "Tags libres pour classification";

DEFINE FIELD customFields ON partner TYPE option<object>
    COMMENT "Champs personnalisés configurables";

-- Relations hiérarchiques
DEFINE FIELD parentPartner ON partner TYPE option<record<partner>>
    COMMENT "Groupe/Organisation parente";

-- Profil IA central
DEFINE FIELD aiProfile ON partner TYPE object
    VALUE $value OR {
        confidence: 0.0,
        source: 'manual',
        lastAnalyzed: time::now(),
        analysisVersion: '1.0',
        dataQuality: 0.0,
        completeness: 0.0,
        riskScore: 0.0,
        segmentation: 'unknown'
    }
    COMMENT "Profil IA central avec métriques avancées";

-- Embeddings pour recherche sémantique
DEFINE FIELD embeddings ON partner TYPE option<array<decimal>>
    COMMENT "Embeddings vectoriels pour recherche sémantique et matching";

-- Insights IA avancés
DEFINE FIELD aiInsights ON partner TYPE object
    VALUE $value OR {
        engagement: 'unknown',
        lifetime_value: 0.0,
        churn_risk: 0.0,
        growth_potential: 0.0,
        relationship_strength: 0.0,
        market_segment: 'unknown',
        communication_style: 'unknown',
        preferred_channels: [],
        behavioral_patterns: {},
        predictive_scores: {}
    }
    COMMENT "Analyses IA complètes du partenaire";

-- Métriques IA business
DEFINE FIELD aiMetrics ON partner TYPE object
    VALUE $value OR {
        completionScore: 0.0,
        activityScore: 0.0,
        engagementScore: 0.0,
        loyaltyScore: 0.0,
        profitabilityScore: 0.0,
        responseRate: 0.0,
        satisfaction: 0.0,
        nps: 0.0,
        lastCalculated: null,
        trendsHistory: []
    }
    COMMENT "Métriques IA de performance relationnelle";

-- Prédictions IA
DEFINE FIELD aiPredictions ON partner TYPE object
    VALUE $value OR {
        churn_probability: 0.0,
        next_purchase_date: null,
        lifetime_value_estimate: 0.0,
        engagement_trend: 'stable',
        optimal_contact_time: null,
        recommended_actions: [],
        confidence_intervals: {},
        prediction_horizon: 90,
        last_update: null
    }
    COMMENT "Prédictions IA sur le comportement futur";

-- Métadonnées système
DEFINE FIELD createdAt ON partner TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON partner TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON partner TYPE option<record<user>>;
DEFINE FIELD notes ON partner TYPE option<string>
    COMMENT "Notes internes";

-- ================================================================================================
-- 📦 ENTITÉS PRODUITS
-- ================================================================================================

-- Table: product_category (Catégories de produits)
DEFINE TABLE product_category SCHEMAFULL
    COMMENT "Catégories de produits avec IA de classification automatique"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'product_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON product_category TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code unique de la catégorie";

DEFINE FIELD name ON product_category TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la catégorie";

DEFINE FIELD description ON product_category TYPE option<string>
    COMMENT "Description de la catégorie";

DEFINE FIELD parentCategory ON product_category TYPE option<record<product_category>>
    COMMENT "Catégorie parente (hiérarchie)";

DEFINE FIELD level ON product_category TYPE int
    ASSERT $value >= 0
    VALUE $value OR 0
    COMMENT "Niveau hiérarchique";

DEFINE FIELD isLeaf ON product_category TYPE bool
    VALUE $value OR true
    COMMENT "Catégorie feuille (sans sous-catégories)";

-- Intelligence IA de classification
DEFINE FIELD classificationAI ON product_category TYPE object VALUE {
    autoClassificationRules: [],
    confidenceThreshold: 0.8,
    machineLearnedPatterns: {},
    keywordMatching: [],
    attributeWeights: {},
    misclassificationRate: 0.0
};

-- Métriques et analytics
DEFINE FIELD categoryMetrics ON product_category TYPE object VALUE {
    productCount: 0,
    totalRevenue: 0.0,
    averageMargin: 0.0,
    topSellingProducts: [],
    seasonalTrends: {},
    priceRange: { min: 0.0, max: 0.0 },
    averageSessionDuration: 0
};

-- Optimisations IA
DEFINE FIELD categoryOptimizations ON product_category TYPE object VALUE {
    recommendedPricing: {},
    crossSellOpportunities: [],
    marketingStrategies: [],
    inventoryOptimization: {},
    customerSegmentation: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON product_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON product_category TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON product_category TYPE option<record<user>>;
DEFINE FIELD notes ON product_category TYPE option<string>
    COMMENT "Notes internes";
DEFINE FIELD archived ON product_category TYPE bool DEFAULT false;

-- Table: product (Produits)
DEFINE TABLE product SCHEMAFULL
    COMMENT "Produits avec IA de recommandation et optimisation pricing"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'product_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON product TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code produit unique";

DEFINE FIELD name ON product TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du produit";

DEFINE FIELD description ON product TYPE option<string>
    COMMENT "Description du produit";

DEFINE FIELD shortDescription ON product TYPE option<string>
    COMMENT "Description courte pour affichage";

-- Classification
DEFINE FIELD productCategory ON product TYPE option<record<product_category>>
    COMMENT "Catégorie principale";

DEFINE FIELD productType ON product TYPE string
    ASSERT $value INSIDE ['STORABLE', 'SERVICE', 'DIGITAL', 'SUBSCRIPTION', 'BUNDLE']
    VALUE $value OR 'STORABLE'
    COMMENT "Type de produit";

-- Pricing
DEFINE FIELD salePrice ON product TYPE decimal(20,3)
    ASSERT $value >= 0
    VALUE $value OR 0.0
    COMMENT "Prix de vente";

DEFINE FIELD costPrice ON product TYPE decimal(20,3)
    ASSERT $value >= 0
    VALUE $value OR 0.0
    COMMENT "Prix de revient";

DEFINE FIELD currency ON product TYPE option<record<currency>>
    COMMENT "Devise du prix";

-- Unités
DEFINE FIELD unit ON product TYPE option<record<unit>>
    COMMENT "Unité de mesure";

DEFINE FIELD saleUnit ON product TYPE option<record<unit>>
    COMMENT "Unité de vente";

DEFINE FIELD purchaseUnit ON product TYPE option<record<unit>>
    COMMENT "Unité d'achat";

-- Statuts
DEFINE FIELD isActive ON product TYPE bool
    VALUE $value OR true
    COMMENT "Produit actif";

DEFINE FIELD sellable ON product TYPE bool
    VALUE $value OR true
    COMMENT "Vendable";

DEFINE FIELD purchasable ON product TYPE bool
    VALUE $value OR true
    COMMENT "Achetable";

-- Intelligence IA produit
DEFINE FIELD productAI ON product TYPE object VALUE {
    demandForecast: 0.0,
    priceOptimization: {
        suggestedPrice: 0.0,
        priceElasticity: 0.0,
        competitivePosition: 'unknown',
        marginOptimization: 0.0
    },
    marketAnalysis: {
        marketShare: 0.0,
        competitiveAdvantage: [],
        trendAnalysis: 'stable',
        seasonalityFactor: 1.0
    },
    customerInsights: {
        customerSegments: [],
        buyingPatterns: {},
        preferredChannels: [],
        satisfactionScore: 0.0
    }
};

-- Recommandations IA
DEFINE FIELD aiRecommendations ON product TYPE object VALUE {
    crossSellProducts: [],
    upsellOpportunities: [],
    bundleRecommendations: [],
    targetCustomers: [],
    marketingStrategies: [],
    pricingStrategies: []
};

-- Métriques performance
DEFINE FIELD performanceMetrics ON product TYPE object VALUE {
    salesVolume: 0.0,
    revenue: 0.0,
    margin: 0.0,
    turnoverRate: 0.0,
    customerSatisfaction: 0.0,
    returnRate: 0.0,
    viewsToSales: 0.0,
    inventoryTurnover: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON product TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON product TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON product TYPE option<record<user>>;
DEFINE FIELD archived ON product TYPE bool DEFAULT false;

-- ================================================================================================
-- 💳 ENTITÉS FINANCIÈRES AVANCÉES
-- ================================================================================================

-- Table: tax (Taxes)
DEFINE TABLE tax SCHEMAFULL
    COMMENT "Taxes avec IA de conformité et optimisation fiscale"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'tax_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON tax TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code taxe unique";

DEFINE FIELD name ON tax TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la taxe";

DEFINE FIELD rate ON tax TYPE decimal(10,4)
    ASSERT $value >= 0 AND $value <= 100
    COMMENT "Taux de taxe en pourcentage";

DEFINE FIELD taxType ON tax TYPE string
    ASSERT $value INSIDE ['VAT', 'SALES_TAX', 'EXCISE', 'IMPORT_DUTY', 'WITHHOLDING', 'CORPORATE', 'CUSTOM']
    VALUE $value OR 'VAT'
    COMMENT "Type de taxe";

DEFINE FIELD country ON tax TYPE option<record<country>>
    COMMENT "Pays d'application";

DEFINE FIELD isActive ON tax TYPE bool
    VALUE $value OR true
    COMMENT "Taxe active";

DEFINE FIELD validFrom ON tax TYPE option<date>
    COMMENT "Date de validité début";

DEFINE FIELD validTo ON tax TYPE option<date>
    COMMENT "Date de validité fin";

-- Intelligence IA fiscale
DEFINE FIELD taxComplianceAI ON tax TYPE object VALUE {
    complianceScore: 100.0,
    riskLevel: 'LOW',
    regulatoryChanges: [],
    auditRisk: 0.0,
    optimizationOpportunities: [],
    jurisdictionComplexity: 0.0
};

-- Analytics fiscales
DEFINE FIELD taxAnalytics ON tax TYPE object VALUE {
    totalCollected: 0.0,
    averageRate: 0.0,
    applicationFrequency: 0,
    exemptionRate: 0.0,
    seasonalVariations: {},
    industryBenchmarks: {}
};

-- Optimisations IA
DEFINE FIELD taxOptimizations ON tax TYPE object VALUE {
    suggestedStructure: {},
    savingsOpportunities: [],
    riskMitigation: [],
    planningStrategies: [],
    complianceAutomation: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON tax TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON tax TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON tax TYPE option<record<user>>;
DEFINE FIELD archived ON tax TYPE bool DEFAULT false;

-- Table: account (Comptes comptables)
DEFINE TABLE account SCHEMAFULL
    COMMENT "Comptes comptables avec IA d'analyse financière"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'accountant'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON account TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code compte comptable";

DEFINE FIELD name ON account TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du compte";

DEFINE FIELD accountType ON account TYPE string
    ASSERT $value INSIDE ['ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE', 'CONTRA']
    COMMENT "Type de compte";

DEFINE FIELD parentAccount ON account TYPE option<record<account>>
    COMMENT "Compte parent";

DEFINE FIELD company ON account TYPE record<company>
    COMMENT "Société propriétaire";

DEFINE FIELD currency ON account TYPE option<record<currency>>
    COMMENT "Devise du compte";

DEFINE FIELD isActive ON account TYPE bool
    VALUE $value OR true
    COMMENT "Compte actif";

DEFINE FIELD allowReconciliation ON account TYPE bool
    VALUE $value OR false
    COMMENT "Autoriser le lettrage";

-- Intelligence IA comptable
DEFINE FIELD accountingAI ON account TYPE object VALUE {
    balanceTrend: 'stable',
    anomalyDetection: [],
    forecastBalance: 0.0,
    riskAssessment: 0.0,
    auditRecommendations: [],
    complianceStatus: 'COMPLIANT'
};

-- Analytics financières
DEFINE FIELD financialAnalytics ON account TYPE object VALUE {
    currentBalance: 0.0,
    averageBalance: 0.0,
    turnoverRate: 0.0,
    transactionFrequency: 0,
    largestTransactions: [],
    monthlyTrends: {}
};

-- Optimisations IA
DEFINE FIELD accountOptimizations ON account TYPE object VALUE {
    cashFlowOptimization: {},
    riskReduction: [],
    efficiencyGains: [],
    auditPreparation: {},
    reportingAutomation: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON account TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON account TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON account TYPE option<record<user>>;
DEFINE FIELD archived ON account TYPE bool DEFAULT false;

-- ================================================================================================
-- 🔢 ENTITÉS DE SÉQUENÇAGE
-- ================================================================================================

-- Table: sequence (Séquences)
DEFINE TABLE sequence SCHEMAFULL
    COMMENT "Séquences de numérotation avec IA d'optimisation"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'system_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON sequence TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code séquence unique";

DEFINE FIELD name ON sequence TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la séquence";

DEFINE FIELD prefix ON sequence TYPE option<string>
    COMMENT "Préfixe de la séquence";

DEFINE FIELD suffix ON sequence TYPE option<string>
    COMMENT "Suffixe de la séquence";

DEFINE FIELD padding ON sequence TYPE int
    ASSERT $value >= 0 AND $value <= 20
    VALUE $value OR 5
    COMMENT "Remplissage avec des zéros";

DEFINE FIELD incrementBy ON sequence TYPE int
    ASSERT $value > 0
    VALUE $value OR 1
    COMMENT "Incrément";

DEFINE FIELD nextNum ON sequence TYPE int
    ASSERT $value >= 0
    VALUE $value OR 1
    COMMENT "Prochain numéro";

DEFINE FIELD company ON sequence TYPE option<record<company>>
    COMMENT "Société (si spécifique)";

DEFINE FIELD isActive ON sequence TYPE bool
    VALUE $value OR true
    COMMENT "Séquence active";

DEFINE FIELD resetYearly ON sequence TYPE bool
    VALUE $value OR false
    COMMENT "Remise à zéro annuelle";

DEFINE FIELD resetMonthly ON sequence TYPE bool
    VALUE $value OR false
    COMMENT "Remise à zéro mensuelle";

-- Intelligence IA séquences
DEFINE FIELD sequenceAI ON sequence TYPE object VALUE {
    usagePattern: {},
    peakUsage: 0,
    generationRate: 0.0,
    collisionRisk: 0.0,
    optimizationSuggestions: [],
    forecastUsage: 0
};

-- Analytics d'utilisation
DEFINE FIELD usageAnalytics ON sequence TYPE object VALUE {
    totalGenerated: 0,
    dailyGeneration: [],
    monthlyTrends: {},
    yearlyTrends: {},
    lastGenerated: null,
    averageGeneration: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON sequence TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON sequence TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON sequence TYPE option<record<user>>;
DEFINE FIELD archived ON sequence TYPE bool DEFAULT false;

-- ================================================================================================
-- 🏦 ENTITÉS BANCAIRES ET PAIEMENTS
-- ================================================================================================

-- Table: bank_detail (Détails bancaires)
DEFINE TABLE bank_detail SCHEMAFULL
    COMMENT "Détails bancaires avec IA de validation et sécurité"
    PERMISSIONS
        FOR select WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager'
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON bank_detail TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code détail bancaire unique";

DEFINE FIELD bankName ON bank_detail TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la banque";

DEFINE FIELD accountNumber ON bank_detail TYPE string
    ASSERT $value != NULL
    COMMENT "Numéro de compte";

DEFINE FIELD iban ON bank_detail TYPE option<string>
    COMMENT "IBAN international";

DEFINE FIELD bic ON bank_detail TYPE option<string>
    COMMENT "Code BIC/SWIFT";

DEFINE FIELD bankAddress ON bank_detail TYPE option<record<address>>
    COMMENT "Adresse de la banque";

DEFINE FIELD currency ON bank_detail TYPE record<currency>
    COMMENT "Devise du compte";

DEFINE FIELD isDefault ON bank_detail TYPE bool DEFAULT false
    COMMENT "Compte bancaire par défaut";

DEFINE FIELD isActive ON bank_detail TYPE bool DEFAULT true
    COMMENT "Compte actif";

-- Intelligence IA bancaire
DEFINE FIELD bankingAI ON bank_detail TYPE object VALUE {
    validationScore: 0.0,
    riskLevel: 'UNKNOWN',
    fraudDetection: [],
    complianceChecks: [],
    transactionPatterns: {},
    securityScore: 0.0
};

-- Analytics bancaires
DEFINE FIELD bankAnalytics ON bank_detail TYPE object VALUE {
    totalTransactions: 0,
    averageAmount: 0.0,
    lastTransaction: null,
    monthlyVolume: {},
    balanceHistory: [],
    utilisationRate: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON bank_detail TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON bank_detail TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON bank_detail TYPE option<record<user>>;
DEFINE FIELD archived ON bank_detail TYPE bool DEFAULT false;

-- Table: payment_term (Conditions de paiement)
DEFINE TABLE payment_term SCHEMAFULL
    COMMENT "Conditions de paiement avec IA d'optimisation de trésorerie"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'finance_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON payment_term TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code condition de paiement";

DEFINE FIELD name ON payment_term TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la condition";

DEFINE FIELD paymentMode ON payment_term TYPE string
    ASSERT $value INSIDE ['CASH', 'CHECK', 'TRANSFER', 'CARD', 'PAYPAL', 'CRYPTO', 'INSTALLMENT']
    VALUE $value OR 'TRANSFER'
    COMMENT "Mode de paiement";

DEFINE FIELD paymentDelay ON payment_term TYPE int
    ASSERT $value >= 0
    VALUE $value OR 0
    COMMENT "Délai de paiement en jours";

DEFINE FIELD discountRate ON payment_term TYPE decimal(10,4)
    ASSERT $value >= 0 AND $value <= 100
    VALUE $value OR 0.0
    COMMENT "Taux d'escompte";

DEFINE FIELD discountDelay ON payment_term TYPE int
    ASSERT $value >= 0
    VALUE $value OR 0
    COMMENT "Délai pour bénéficier de l'escompte";

DEFINE FIELD isDefault ON payment_term TYPE bool DEFAULT false
    COMMENT "Condition de paiement par défaut";

-- Intelligence IA des paiements
DEFINE FIELD paymentAI ON payment_term TYPE object VALUE {
    cashFlowImpact: 0.0,
    riskAssessment: 0.0,
    optimizationScore: 0.0,
    negotiationPotential: 0.0,
    industryBenchmark: {},
    seasonalAdjustments: {}
};

-- Analytics de paiement
DEFINE FIELD paymentAnalytics ON payment_term TYPE object VALUE {
    averagePaymentTime: 0.0,
    complianceRate: 0.0,
    latePaymentRate: 0.0,
    discountUtilization: 0.0,
    cashFlowPrediction: {},
    clientSatisfaction: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON payment_term TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON payment_term TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON payment_term TYPE option<record<user>>;
DEFINE FIELD archived ON payment_term TYPE bool DEFAULT false;

-- Table: fiscal_position (Positions fiscales)
DEFINE TABLE fiscal_position SCHEMAFULL
    COMMENT "Positions fiscales avec IA de conformité réglementaire"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'tax_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON fiscal_position TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code position fiscale";

DEFINE FIELD name ON fiscal_position TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la position fiscale";

DEFINE FIELD description ON fiscal_position TYPE option<string>
    COMMENT "Description de la position";

DEFINE FIELD country ON fiscal_position TYPE record<country>
    COMMENT "Pays d'application";

DEFINE FIELD isDefault ON fiscal_position TYPE bool DEFAULT false
    COMMENT "Position fiscale par défaut";

DEFINE FIELD customerAccount ON fiscal_position TYPE option<record<account>>
    COMMENT "Compte client par défaut";

DEFINE FIELD supplierAccount ON fiscal_position TYPE option<record<account>>
    COMMENT "Compte fournisseur par défaut";

-- Intelligence IA fiscale
DEFINE FIELD fiscalAI ON fiscal_position TYPE object VALUE {
    complianceLevel: 100.0,
    riskFactors: [],
    regulatoryChanges: [],
    optimizationOpportunities: [],
    auditRecommendations: [],
    jurisdictionComplexity: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON fiscal_position TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON fiscal_position TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON fiscal_position TYPE option<record<user>>;
DEFINE FIELD archived ON fiscal_position TYPE bool DEFAULT false;

-- Table: price_list (Listes de prix)
DEFINE TABLE price_list SCHEMAFULL
    COMMENT "Listes de prix avec IA de tarification dynamique"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'pricing_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON price_list TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code liste de prix";

DEFINE FIELD name ON price_list TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la liste de prix";

DEFINE FIELD description ON price_list TYPE option<string>
    COMMENT "Description de la liste";

DEFINE FIELD currency ON price_list TYPE record<currency>
    COMMENT "Devise de la liste";

DEFINE FIELD isDefault ON price_list TYPE bool DEFAULT false
    COMMENT "Liste de prix par défaut";

DEFINE FIELD isActive ON price_list TYPE bool DEFAULT true
    COMMENT "Liste active";

DEFINE FIELD validFrom ON price_list TYPE option<date>
    COMMENT "Date de validité début";

DEFINE FIELD validTo ON price_list TYPE option<date>
    COMMENT "Date de validité fin";

DEFINE FIELD typeSelect ON price_list TYPE string
    ASSERT $value INSIDE ['SALE', 'PURCHASE', 'COST', 'PROMOTIONAL', 'CUSTOMER_SPECIFIC', 'SEASONAL']
    VALUE $value OR 'SALE'
    COMMENT "Type de liste de prix";

-- Intelligence IA de pricing
DEFINE FIELD pricingAI ON price_list TYPE object VALUE {
    priceOptimization: {},
    demandElasticity: {},
    competitiveAnalysis: {},
    marginOptimization: 0.0,
    seasonalAdjustments: {},
    customerSegmentation: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON price_list TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON price_list TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON price_list TYPE option<record<user>>;
DEFINE FIELD archived ON price_list TYPE bool DEFAULT false;

-- ================================================================================================
-- 🌐 ENTITÉS D'INTERNATIONALISATION
-- ================================================================================================

-- Table: translation (Traductions)
DEFINE TABLE translation SCHEMAFULL
    COMMENT "Traductions avec IA de localisation automatique"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'translator'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD key ON translation TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Clé de traduction unique";

DEFINE FIELD language ON translation TYPE record<language>
    COMMENT "Référence vers la langue";

DEFINE FIELD value ON translation TYPE string
    ASSERT $value != NULL
    COMMENT "Valeur traduite";

DEFINE FIELD context ON translation TYPE option<string>
    COMMENT "Contexte d'utilisation";

DEFINE FIELD module ON translation TYPE option<string>
    COMMENT "Module d'appartenance";

DEFINE FIELD isActive ON translation TYPE bool DEFAULT true
    COMMENT "Traduction active";

-- Intelligence IA de traduction
DEFINE FIELD translationAI ON translation TYPE object VALUE {
    confidenceScore: 0.0,
    translationMethod: 'MANUAL',
    qualityScore: 0.0,
    culturalAdaptation: 0.0,
    contextRelevance: 0.0,
    automaticSuggestions: []
};

-- Analytics de qualité
DEFINE FIELD qualityAnalytics ON translation TYPE object VALUE {
    usageFrequency: 0,
    userFeedback: 0.0,
    accuracyScore: 0.0,
    culturalAcceptance: 0.0,
    improvementSuggestions: []
};

-- Métadonnées
DEFINE FIELD createdAt ON translation TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON translation TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON translation TYPE option<record<user>>;
DEFINE FIELD archived ON translation TYPE bool DEFAULT false;

-- Index de performance
DEFINE INDEX idx_translation_unique ON translation COLUMNS key, language UNIQUE;
DEFINE INDEX idx_translation_module ON translation COLUMNS module;
DEFINE INDEX idx_translation_active ON translation COLUMNS isActive;

-- ================================================================================================
-- 📋 ENTITÉS DE TEMPLATES ET NOTIFICATIONS
-- ================================================================================================

-- Table: print_template (Templates d'impression)
DEFINE TABLE print_template SCHEMAFULL
    COMMENT "Templates d'impression avec IA de mise en forme"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'template_designer'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON print_template TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code template unique";

DEFINE FIELD name ON print_template TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du template";

DEFINE FIELD templateType ON print_template TYPE string
    ASSERT $value INSIDE ['INVOICE', 'QUOTE', 'ORDER', 'DELIVERY', 'REPORT', 'CERTIFICATE', 'CUSTOM']
    VALUE $value OR 'CUSTOM'
    COMMENT "Type de template";

DEFINE FIELD content ON print_template TYPE string
    ASSERT $value != NULL
    COMMENT "Contenu du template";

DEFINE FIELD format ON print_template TYPE string
    ASSERT $value INSIDE ['PDF', 'HTML', 'DOCX', 'ODT', 'TXT']
    VALUE $value OR 'PDF'
    COMMENT "Format de sortie";

DEFINE FIELD isDefault ON print_template TYPE bool DEFAULT false
    COMMENT "Template par défaut";

DEFINE FIELD isActive ON print_template TYPE bool DEFAULT true
    COMMENT "Template actif";

-- Intelligence IA de mise en forme
DEFINE FIELD designAI ON print_template TYPE object VALUE {
    layoutOptimization: {},
    brandingCompliance: 0.0,
    readabilityScore: 0.0,
    accessibilityScore: 0.0,
    designSuggestions: [],
    responsiveDesign: false
};

-- Analytics d'utilisation
DEFINE FIELD templateAnalytics ON print_template TYPE object VALUE {
    usageCount: 0,
    generationTime: 0.0,
    errorRate: 0.0,
    userSatisfaction: 0.0,
    performanceMetrics: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON print_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON print_template TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON print_template TYPE option<record<user>>;
DEFINE FIELD archived ON print_template TYPE bool DEFAULT false;

-- Index de performance
DEFINE INDEX idx_print_template_code ON print_template COLUMNS code UNIQUE;
DEFINE INDEX idx_print_template_type ON print_template COLUMNS templateType;
DEFINE INDEX idx_print_template_active ON print_template COLUMNS isActive;

-- ================================================================================================
-- ================================================================================================
-- ⚙️ CONFIGURATION SYSTÈME - MIGRÉ VERS lyxal-config
-- ================================================================================================
-- 
-- Les tables de configuration système ont été migrées vers le module lyxal-config
-- pour une meilleure séparation des responsabilités.
-- 
-- Tables migrées:
-- - app_configuration
-- - locale_configuration
-- - period_configuration
-- - notification_configuration
-- - import_configuration
-- 
-- Date de migration: 2025-06-26T15:30:31.028Z
-- 
-- Pour utiliser ces configurations, importez depuis @lyxal/config
-- 
-- ================================================================================================

-- 🌐 ENTITÉS DE RÉFÉRENCE INTERNATIONALES
-- ================================================================================================
-- 
-- Tables de référence pour l'internationalisation et la localisation
-- - language: Langues universelles (fr, en, es...)
-- - locale: Combinaisons langue + pays + formats culturels (fr_FR, en_US...)
-- 
-- Relation: language (1) ←→ (N) locale
-- ================================================================================================

-- Table: language (Langues universelles)
DEFINE TABLE language SCHEMAFULL
    COMMENT "Langues universelles avec IA de traduction et localisation"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON language TYPE string
    ASSERT $value != NULL AND string::len($value) = 2
    COMMENT "Code langue ISO 639-1";

DEFINE FIELD name ON language TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la langue";

DEFINE FIELD nativeName ON language TYPE option<string>
    COMMENT "Nom natif de la langue";

DEFINE FIELD isDefault ON language TYPE bool DEFAULT false
    COMMENT "Langue par défaut";

DEFINE FIELD isActive ON language TYPE bool DEFAULT true
    COMMENT "Langue active";

DEFINE FIELD direction ON language TYPE string
    ASSERT $value INSIDE ['LTR', 'RTL']
    VALUE $value OR 'LTR'
    COMMENT "Direction d'écriture";

-- Intelligence IA linguistique
DEFINE FIELD linguisticAI ON language TYPE object VALUE {
    translationAccuracy: 0.0,
    culturalNuances: {},
    businessTerminology: {},
    technicalComplexity: 0.0,
    localizationReadiness: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON language TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON language TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON language TYPE option<record<user>>;
DEFINE FIELD archived ON language TYPE bool DEFAULT false;

-- Index de performance
DEFINE INDEX idx_language_code ON language COLUMNS code UNIQUE;
DEFINE INDEX idx_language_active ON language COLUMNS isActive;

-- ================================================================================
-- LOCALE - Locales complètes (langue + pays + formats culturels)
-- ================================================================================

DEFINE TABLE locale SCHEMAFULL
    COMMENT "Locales complètes avec formats culturels et IA d'adaptation"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'localization_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON locale TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code locale (ex: fr_FR, en_US)";

DEFINE FIELD name ON locale TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la locale";

DEFINE FIELD language ON locale TYPE record<language>
    COMMENT "Référence vers la langue universelle";

DEFINE FIELD country ON locale TYPE record<country>
    COMMENT "Pays de la locale";

DEFINE FIELD isDefault ON locale TYPE bool DEFAULT false
    COMMENT "Locale par défaut";

DEFINE FIELD isActive ON locale TYPE bool DEFAULT true
    COMMENT "Locale active";

-- Formats de données culturels
DEFINE FIELD dataFormats ON locale TYPE object VALUE {
    dateFormat: 'DD/MM/YYYY',
    timeFormat: 'HH:mm',
    numberFormat: '#,##0.00',
    currencyFormat: '#,##0.00 ¤',
    decimalSeparator: '.',
    groupingSeparator: ','
};

-- Intelligence IA culturelle
DEFINE FIELD culturalAI ON locale TYPE object VALUE {
    culturalPatterns: {},
    businessPractices: {},
    communicationStyle: 'FORMAL',
    timeZoneBehavior: {},
    seasonalFactors: {},
    holidayCalendar: []
};

-- Analytics d'utilisation
DEFINE FIELD localeAnalytics ON locale TYPE object VALUE {
    userAdoption: 0.0,
    satisfactionScore: 0.0,
    translationAccuracy: 0.0,
    culturalCompliance: 0.0,
    usagePatterns: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON locale TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON locale TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON locale TYPE option<record<user>>;
DEFINE FIELD archived ON locale TYPE bool DEFAULT false;

-- Index de performance
DEFINE INDEX idx_locale_code ON locale COLUMNS code UNIQUE;
DEFINE INDEX idx_locale_language ON locale COLUMNS language;
DEFINE INDEX idx_locale_country ON locale COLUMNS country;
DEFINE INDEX idx_locale_active ON locale COLUMNS isActive;


-- ================================================================================================
-- 🎯 FIN DE LA STRUCTURE LYXAL-BASE IA-NATIVE
-- ================================================================================================

-- Total : 22 entités IA-native complètes avec SurrealDB révolutionnaire
-- Architecture : Backend-as-a-Database avec intelligence artificielle intégrée
-- Capacités : Prédictions, analytics, optimisations, scoring automatique
-- Performance : Index optimisés, permissions granulaires, validation avancée 
-- 
-- NOTES DE MIGRATION :
-- - Tables de configuration déplacées vers lyxal-config pour séparation des responsabilités
-- ✅ MIGRATION COMPLETE: notification_configuration et import_configuration déplacées vers @lyxal/config
-- Date: 2025-06-26T15:59:19.488Z
-- Tables supprimées du module base pour éviter les doublons
-- - Total réduit de 24 à 22 entités (configuration externalisée) 





-- ================================================================================================
-- 🎯 FIN STRUCTURE COMPLÈTE 
-- ================================================================================================ 
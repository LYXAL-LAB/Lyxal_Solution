-- =============================================================================
-- TABLE: company (Entreprise) - Définition de base
-- Extension de la table company : project/company/structures/company.surql
-- Entreprise avec toutes ses propriétés étendues et intelligence IA
-- =============================================================================
DEFINE TABLE base_company SCHEMAFULL
    COMMENT "Sociétés avec IA intégrée et structure complète validée"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'company_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

-- Identification de base
DEFINE FIELD name ON base_company TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2 AND string::len($value) <= 200
    COMMENT "Nom de la société";

DEFINE FIELD code ON base_company TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2 AND string::len($value) <= 20
    COMMENT "Code unique de la société";

DEFINE FIELD legalName ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 200
    COMMENT "Raison sociale officielle";

DEFINE FIELD shortName ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 50
    COMMENT "Nom court pour affichage";

DEFINE FIELD notes ON base_company TYPE option<string>
    COMMENT "Notes internes";

-- Contact et communication
DEFINE FIELD email ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::is::email($value)
    COMMENT "Email principal";

DEFINE FIELD phone ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 20
    COMMENT "Téléphone principal";

DEFINE FIELD mobile ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 20
    COMMENT "Téléphone mobile";

DEFINE FIELD fax ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) <= 20
    COMMENT "Télécopieur";

DEFINE FIELD website ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::starts_with($value, 'http')
    COMMENT "Site web";

-- Adresse et localisation
DEFINE FIELD address ON base_company TYPE option<record<base_address>>
    COMMENT "Adresse principale géolocalisée";

DEFINE FIELD city ON base_company TYPE option<string>
    COMMENT "Ville principale";

DEFINE FIELD zip ON base_company TYPE option<string>
    COMMENT "Code postal";

DEFINE FIELD country ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) = 2 OR string::len($value) = 3
    COMMENT "Pays principal (code ISO)";

DEFINE FIELD partner ON base_company TYPE option<record<base_partner>>;

DEFINE FIELD parent ON base_company TYPE option<record<base_company>>;

-- Hiérarchie et relations
DEFINE FIELD parentCompany ON base_company TYPE option<record<base_company>>
    COMMENT "Société mère";

DEFINE FIELD subsidiaries ON base_company TYPE option<array<record<base_company>>>
    COMMENT "Filiales directes";

DEFINE FIELD isHeadquarters ON base_company TYPE bool DEFAULT false
    COMMENT "Est le siège social";

DEFINE FIELD companyGroup ON base_company TYPE option<string>
    COMMENT "Groupe d'appartenance";

-- Secteur et marché IA-Enhanced
DEFINE FIELD sector ON base_company TYPE option<record<system_tag>>
    COMMENT "Secteur d'activité principal (référence universelle)";

DEFINE FIELD subSectors ON base_company TYPE option<array<record<system_tag>>>
    COMMENT "Sous-secteurs d'activité (références universelles)";

DEFINE FIELD businessModel ON base_company TYPE option<record<system_tag>>
    COMMENT "Modèle économique (référence universelle)";

DEFINE FIELD targetMarkets ON base_company TYPE option<array<string>>
    COMMENT "Marchés cibles géographiques";

DEFINE FIELD competitiveAdvantage ON base_company TYPE option<array<string>>
    COMMENT "Avantages concurrentiels identifiés";

-- Taille et métriques
DEFINE FIELD size ON base_company TYPE option<string>
    ASSERT $value = NONE OR $value INSIDE ['startup', 'micro', 'small', 'medium', 'large', 'enterprise', 'unicorn']
    COMMENT "Taille de l'entreprise";

DEFINE FIELD employeeCount ON base_company TYPE option<int>
    ASSERT $value = NONE OR $value >= 0
    COMMENT "Nombre d'employés";

DEFINE FIELD foundingDate ON base_company TYPE option<datetime>
    COMMENT "Date de création";

DEFINE FIELD registrationDate ON base_company TYPE option<datetime>
    COMMENT "Date d'enregistrement";

DEFINE FIELD legalForm ON base_company TYPE option<record<system_tag>>
    COMMENT "Forme juridique spécifique au pays";

-- Données financières
DEFINE FIELD revenue ON base_company TYPE option<object>
    COMMENT "Chiffre d'affaires avec historique";

-- Logo et branding
DEFINE FIELD logo ON base_company TYPE option<record<meta_file>>;
DEFINE FIELD width ON base_company TYPE option<int>;
DEFINE FIELD height ON base_company TYPE option<int>;

-- Devise et délais de paiement
DEFINE FIELD currency ON base_company TYPE option<record<base_currency>>;

DEFINE FIELD defaultCurrency ON base_company TYPE option<string>
    ASSERT $value = NONE OR string::len($value) = 3
    COMMENT "Devise par défaut (code ISO)";

DEFINE FIELD customerPaymentDelay ON base_company TYPE option<decimal>;
DEFINE FIELD supplierPaymentDelay ON base_company TYPE option<decimal>;

-- Détails bancaires
DEFINE FIELD defaultBankDetails ON base_company TYPE option<record<base_bank_details>>;

-- Paramètres d'impression
DEFINE FIELD printingSettings ON base_company TYPE option<record<base_printing_settings>>;

-- Types de partenaires par défaut
DEFINE FIELD defaultPartnerTypeSelect ON base_company TYPE int DEFAULT 1;
DEFINE FIELD defaultPartnerCategorySelect ON base_company TYPE option<int>;

-- Noms commerciaux
DEFINE FIELD tradingNameList ON base_company TYPE array<record<base_trading_name>>;

-- Planification
DEFINE FIELD weeklyPlanning ON base_company TYPE option<record<base_weekly_planning>>;
DEFINE FIELD publicHolidayEventsPlanning ON base_company TYPE option<record<base_events_planning>>;

-- Localisation
DEFINE FIELD localization ON base_company TYPE option<record<base_locale>>;
DEFINE FIELD timezone ON base_company TYPE option<string>
    COMMENT "Fuseau horaire";

-- Paramètres fiscaux
DEFINE FIELD fiscalYearStart ON base_company TYPE option<string>
    ASSERT $value = NONE OR $value =~ /^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/
    VALUE $value OR '01-01'
    COMMENT "Début d'année fiscale (MM-DD)";

DEFINE FIELD registrationNumber ON base_company TYPE option<string>
    COMMENT "Numéro d'enregistrement principal";

DEFINE FIELD taxNumber ON base_company TYPE option<string>
    COMMENT "Numéro de TVA/Tax ID";

DEFINE FIELD legalInfo ON base_company TYPE option<object>
    COMMENT "Informations légales spécifiques au pays avec validation IA";

-- Paramètres opérationnels
DEFINE FIELD timeTracking ON base_company TYPE bool DEFAULT false
    COMMENT "Suivi du temps activé";

DEFINE FIELD invoiceTemplate ON base_company TYPE option<string>
    COMMENT "Template de facture par défaut";

DEFINE FIELD orderTemplate ON base_company TYPE option<string>
    COMMENT "Template de commande par défaut";

DEFINE FIELD allowCreditStatements ON base_company TYPE bool DEFAULT false
    COMMENT "Autoriser les relevés de crédit";

DEFINE FIELD enableEDI ON base_company TYPE bool DEFAULT false
    COMMENT "EDI activé";

-- Départements
DEFINE FIELD companyDepartmentList ON base_company TYPE array<record<base_company_department>>;

-- Partenaires attachés
DEFINE FIELD partnerList ON base_company TYPE array<record<base_partner>>;

-- Profil IA complet
DEFINE FIELD aiProfile ON base_company TYPE object VALUE {
    confidence: 0.0,
    source: 'manual',
    lastAnalyzed: time::now(),
    analysisVersion: '1.0',
    dataQuality: 0.0,
    completeness: 0.0,
    riskScore: 0.0,
    segmentation: 'unknown',
    maturityLevel: 'unknown'
} COMMENT "Profil IA central avec métriques avancées";

-- Insights IA avancés
DEFINE FIELD aiInsights ON base_company TYPE object VALUE {
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
} COMMENT "Analyses IA complètes de l'entreprise";

-- Métriques IA business
DEFINE FIELD aiMetrics ON base_company TYPE object VALUE {
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
} COMMENT "Métriques IA de performance relationnelle";

-- Prédictions IA
DEFINE FIELD aiPredictions ON base_company TYPE object VALUE {
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
} COMMENT "Prédictions IA sur l'évolution future";

-- Champs système
DEFINE FIELD active ON base_company TYPE bool DEFAULT true
    COMMENT "Entreprise active";

DEFINE FIELD created_on ON base_company TYPE datetime DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD updated_on ON base_company TYPE datetime DEFAULT time::now()
    COMMENT "Date de mise à jour";

DEFINE FIELD created_by ON base_company TYPE option<string>
    COMMENT "Créé par";

DEFINE FIELD updated_by ON base_company TYPE option<string>
    COMMENT "Mis à jour par";

DEFINE FIELD archived ON base_company TYPE bool DEFAULT false
    COMMENT "Archivé";

-- Index et contraintes
DEFINE INDEX idx_base_company_name ON base_company COLUMNS name UNIQUE;
DEFINE INDEX idx_base_company_code ON base_company COLUMNS code UNIQUE;
DEFINE INDEX idx_base_company_active ON base_company COLUMNS active;
DEFINE INDEX idx_base_company_sector ON base_company COLUMNS sector;
DEFINE INDEX idx_base_company_size ON base_company COLUMNS size;
DEFINE INDEX idx_base_company_country ON base_company COLUMNS country;
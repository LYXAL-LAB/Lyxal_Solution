-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : PROPRIÉTÉ INTELLECTUELLE
-- ==============================================================================
-- Fichier : 07_intellectual_property.surql
-- Description : Gestion complète de la propriété intellectuelle
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : MARQUES
-- ==============================================================================

DEFINE TABLE trademark SCHEMAFULL;
DEFINE FIELD trademark_id ON trademark TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD name ON trademark TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON trademark TYPE string;
DEFINE FIELD company ON trademark TYPE record<company>;
DEFINE FIELD registration_number ON trademark TYPE option<string>;
DEFINE FIELD registration_date ON trademark TYPE option<datetime>;
DEFINE FIELD expiry_date ON trademark TYPE option<datetime>;
DEFINE FIELD status ON trademark TYPE string ASSERT $value IN ['application', 'registered', 'opposed', 'cancelled', 'expired'];
DEFINE FIELD classes ON trademark TYPE array<string>;
DEFINE FIELD territories ON trademark TYPE array<string>;
DEFINE FIELD filing_date ON trademark TYPE datetime;
DEFINE FIELD registration_office ON trademark TYPE string;
DEFINE FIELD renewal_due_date ON trademark TYPE option<datetime>;
DEFINE FIELD attorney ON trademark TYPE option<record<user>>;
DEFINE FIELD cost ON trademark TYPE option<decimal>;
DEFINE FIELD maintenance_fees ON trademark TYPE array<object>;
DEFINE FIELD oppositions ON trademark TYPE array<object>;
DEFINE FIELD usage_evidence ON trademark TYPE array<object>;
DEFINE FIELD is_active ON trademark TYPE bool DEFAULT true;
DEFINE FIELD created_on ON trademark TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON trademark TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_trademark_id ON trademark COLUMNS trademark_id UNIQUE;
DEFINE INDEX idx_trademark_company ON trademark COLUMNS company;
DEFINE INDEX idx_trademark_status ON trademark COLUMNS status;
DEFINE INDEX idx_trademark_expiry ON trademark COLUMNS expiry_date;

-- ==============================================================================
-- TABLE : BREVETS
-- ==============================================================================

DEFINE TABLE patent SCHEMAFULL;
DEFINE FIELD patent_id ON patent TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD title ON patent TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON patent TYPE string;
DEFINE FIELD company ON patent TYPE record<company>;
DEFINE FIELD application_number ON patent TYPE option<string>;
DEFINE FIELD publication_number ON patent TYPE option<string>;
DEFINE FIELD patent_number ON patent TYPE option<string>;
DEFINE FIELD filing_date ON patent TYPE datetime;
DEFINE FIELD priority_date ON patent TYPE option<datetime>;
DEFINE FIELD publication_date ON patent TYPE option<datetime>;
DEFINE FIELD grant_date ON patent TYPE option<datetime>;
DEFINE FIELD expiry_date ON patent TYPE option<datetime>;
DEFINE FIELD status ON patent TYPE string ASSERT $value IN ['draft', 'filed', 'published', 'examined', 'granted', 'expired', 'abandoned'];
DEFINE FIELD patent_type ON patent TYPE string ASSERT $value IN ['invention', 'utility_model', 'design'];
DEFINE FIELD inventors ON patent TYPE array<object>;
DEFINE FIELD classification_codes ON patent TYPE array<string>;
DEFINE FIELD territories ON patent TYPE array<string>;
DEFINE FIELD attorney ON patent TYPE option<record<user>>;
DEFINE FIELD filing_cost ON patent TYPE option<decimal>;
DEFINE FIELD maintenance_fees ON patent TYPE array<object>;
DEFINE FIELD licensing_opportunities ON patent TYPE array<object>;
DEFINE FIELD prior_art ON patent TYPE array<object>;
DEFINE FIELD citations ON patent TYPE array<object>;
DEFINE FIELD commercial_value ON patent TYPE option<decimal>;
DEFINE FIELD is_active ON patent TYPE bool DEFAULT true;
DEFINE FIELD created_on ON patent TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON patent TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_patent_id ON patent COLUMNS patent_id UNIQUE;
DEFINE INDEX idx_patent_company ON patent COLUMNS company;
DEFINE INDEX idx_patent_status ON patent COLUMNS status;
DEFINE INDEX idx_patent_expiry ON patent COLUMNS expiry_date;

-- ==============================================================================
-- TABLE : DROITS D'AUTEUR
-- ==============================================================================

DEFINE TABLE copyright SCHEMAFULL;
DEFINE FIELD copyright_id ON copyright TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD title ON copyright TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON copyright TYPE string;
DEFINE FIELD company ON copyright TYPE record<company>;
DEFINE FIELD work_type ON copyright TYPE string ASSERT $value IN ['literary', 'artistic', 'musical', 'audiovisual', 'software', 'database'];
DEFINE FIELD creation_date ON copyright TYPE datetime;
DEFINE FIELD registration_date ON copyright TYPE option<datetime>;
DEFINE FIELD registration_number ON copyright TYPE option<string>;
DEFINE FIELD authors ON copyright TYPE array<object>;
DEFINE FIELD ownership_percentage ON copyright TYPE array<object>;
DEFINE FIELD duration_years ON copyright TYPE int DEFAULT 70;
DEFINE FIELD protection_territories ON copyright TYPE array<string>;
DEFINE FIELD licensing_terms ON copyright TYPE array<object>;
DEFINE FIELD revenue_generated ON copyright TYPE option<decimal>;
DEFINE FIELD infringement_cases ON copyright TYPE array<object>;
DEFINE FIELD deposit_evidence ON copyright TYPE array<object>;
DEFINE FIELD is_active ON copyright TYPE bool DEFAULT true;
DEFINE FIELD created_on ON copyright TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON copyright TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_copyright_id ON copyright COLUMNS copyright_id UNIQUE;
DEFINE INDEX idx_copyright_company ON copyright COLUMNS company;
DEFINE INDEX idx_copyright_type ON copyright COLUMNS work_type;

-- ==============================================================================
-- TABLE : LICENCES
-- ==============================================================================

DEFINE TABLE ip_license SCHEMAFULL;
DEFINE FIELD license_id ON ip_license TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD title ON ip_license TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON ip_license TYPE record<company>;
DEFINE FIELD license_type ON ip_license TYPE string ASSERT $value IN ['trademark', 'patent', 'copyright', 'trade_secret', 'know_how'];
DEFINE FIELD licensed_ip ON ip_license TYPE string;
DEFINE FIELD licensor ON ip_license TYPE string;
DEFINE FIELD licensee ON ip_license TYPE string;
DEFINE FIELD license_nature ON ip_license TYPE string ASSERT $value IN ['exclusive', 'non_exclusive', 'sole'];
DEFINE FIELD grant_date ON ip_license TYPE datetime;
DEFINE FIELD expiry_date ON ip_license TYPE option<datetime>;
DEFINE FIELD territories ON ip_license TYPE array<string>;
DEFINE FIELD fields_of_use ON ip_license TYPE array<string>;
DEFINE FIELD royalty_rate ON ip_license TYPE option<decimal>;
DEFINE FIELD minimum_royalty ON ip_license TYPE option<decimal>;
DEFINE FIELD upfront_fee ON ip_license TYPE option<decimal>;
DEFINE FIELD payment_terms ON ip_license TYPE object;
DEFINE FIELD performance_milestones ON ip_license TYPE array<object>;
DEFINE FIELD restrictions ON ip_license TYPE array<string>;
DEFINE FIELD sublicensing_allowed ON ip_license TYPE bool DEFAULT false;
DEFINE FIELD revenue_sharing ON ip_license TYPE array<object>;
DEFINE FIELD status ON ip_license TYPE string ASSERT $value IN ['active', 'expired', 'terminated', 'suspended'];
DEFINE FIELD is_active ON ip_license TYPE bool DEFAULT true;
DEFINE FIELD created_on ON ip_license TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON ip_license TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ip_license_id ON ip_license COLUMNS license_id UNIQUE;
DEFINE INDEX idx_ip_license_company ON ip_license COLUMNS company;
DEFINE INDEX idx_ip_license_type ON ip_license COLUMNS license_type;
DEFINE INDEX idx_ip_license_status ON ip_license COLUMNS status;

-- ==============================================================================
-- TABLE : SURVEILLANCE CONTREFAÇON
-- ==============================================================================

DEFINE TABLE ip_surveillance SCHEMAFULL;
DEFINE FIELD surveillance_id ON ip_surveillance TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON ip_surveillance TYPE record<company>;
DEFINE FIELD monitored_ip ON ip_surveillance TYPE string;
DEFINE FIELD ip_type ON ip_surveillance TYPE string ASSERT $value IN ['trademark', 'patent', 'copyright', 'design'];
DEFINE FIELD monitoring_scope ON ip_surveillance TYPE array<string>;
DEFINE FIELD search_keywords ON ip_surveillance TYPE array<string>;
DEFINE FIELD monitoring_frequency ON ip_surveillance TYPE string ASSERT $value IN ['daily', 'weekly', 'monthly'];
DEFINE FIELD last_scan_date ON ip_surveillance TYPE option<datetime>;
DEFINE FIELD alerts_generated ON ip_surveillance TYPE array<object>;
DEFINE FIELD potential_infringements ON ip_surveillance TYPE array<object>;
DEFINE FIELD false_positives ON ip_surveillance TYPE array<object>;
DEFINE FIELD actions_taken ON ip_surveillance TYPE array<object>;
DEFINE FIELD monitoring_cost ON ip_surveillance TYPE option<decimal>;
DEFINE FIELD effectiveness_score ON ip_surveillance TYPE option<decimal>;
DEFINE FIELD is_active ON ip_surveillance TYPE bool DEFAULT true;
DEFINE FIELD created_on ON ip_surveillance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON ip_surveillance TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ip_surveillance_id ON ip_surveillance COLUMNS surveillance_id UNIQUE;
DEFINE INDEX idx_ip_surveillance_company ON ip_surveillance COLUMNS company;
DEFINE INDEX idx_ip_surveillance_type ON ip_surveillance COLUMNS ip_type;

-- ==============================================================================
-- TABLE : VALORISATION PATRIMOINE IP
-- ==============================================================================

DEFINE TABLE ip_valuation SCHEMAFULL;
DEFINE FIELD valuation_id ON ip_valuation TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD company ON ip_valuation TYPE record<company>;
DEFINE FIELD ip_asset ON ip_valuation TYPE string;
DEFINE FIELD ip_type ON ip_valuation TYPE string ASSERT $value IN ['trademark', 'patent', 'copyright', 'trade_secret', 'portfolio'];
DEFINE FIELD valuation_date ON ip_valuation TYPE datetime;
DEFINE FIELD valuation_method ON ip_valuation TYPE string ASSERT $value IN ['cost_approach', 'market_approach', 'income_approach', 'relief_from_royalty'];
DEFINE FIELD fair_value ON ip_valuation TYPE decimal;
DEFINE FIELD currency ON ip_valuation TYPE string DEFAULT "EUR";
DEFINE FIELD confidence_level ON ip_valuation TYPE string ASSERT $value IN ['high', 'medium', 'low'];
DEFINE FIELD valuation_purpose ON ip_valuation TYPE string ASSERT $value IN ['financial_reporting', 'transaction', 'licensing', 'litigation', 'insurance'];
DEFINE FIELD key_assumptions ON ip_valuation TYPE array<object>;
DEFINE FIELD financial_projections ON ip_valuation TYPE array<object>;
DEFINE FIELD risk_factors ON ip_valuation TYPE array<object>;
DEFINE FIELD comparable_transactions ON ip_valuation TYPE array<object>;
DEFINE FIELD discount_rate ON ip_valuation TYPE option<decimal>;
DEFINE FIELD valuation_period_years ON ip_valuation TYPE option<int>;
DEFINE FIELD annual_revenue_attributed ON ip_valuation TYPE option<decimal>;
DEFINE FIELD valuator ON ip_valuation TYPE option<record<user>>;
DEFINE FIELD external_valuator ON ip_valuation TYPE option<string>;
DEFINE FIELD next_valuation_date ON ip_valuation TYPE option<datetime>;
DEFINE FIELD is_active ON ip_valuation TYPE bool DEFAULT true;
DEFINE FIELD created_on ON ip_valuation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON ip_valuation TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_ip_valuation_id ON ip_valuation COLUMNS valuation_id UNIQUE;
DEFINE INDEX idx_ip_valuation_company ON ip_valuation COLUMNS company;
DEFINE INDEX idx_ip_valuation_type ON ip_valuation COLUMNS ip_type;
DEFINE INDEX idx_ip_valuation_date ON ip_valuation COLUMNS valuation_date;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour vérifier les renouvellements de marques
DEFINE FUNCTION check_trademark_renewals($days_ahead: int) {
    LET $upcoming_renewals = SELECT * FROM trademark 
        WHERE renewal_due_date BETWEEN time::now() AND (time::now() + duration::from_days($days_ahead))
        AND status = "registered"
        AND is_active = true;
    
    LET $notifications = [];
    FOR $trademark IN $upcoming_renewals {
        LET $days_remaining = math::floor((time::unix($trademark.renewal_due_date) - time::unix(time::now())) / 86400);
        LET $notification = {
            trademark_id: $trademark.trademark_id,
            name: $trademark.name,
            days_remaining: $days_remaining,
            renewal_cost_estimate: 500,
            action_required: "Préparer le renouvellement"
        };
        $notifications = array::push($notifications, $notification);
    }
    RETURN $notifications;
};

-- Fonction pour évaluer le portefeuille IP
DEFINE FUNCTION evaluate_ip_portfolio($company_id: record<company>) {
    LET $trademarks = SELECT COUNT() AS count FROM trademark WHERE company = $company_id AND is_active = true;
    LET $patents = SELECT COUNT() AS count FROM patent WHERE company = $company_id AND is_active = true;
    LET $copyrights = SELECT COUNT() AS count FROM copyright WHERE company = $company_id AND is_active = true;
    LET $licenses = SELECT COUNT() AS count FROM ip_license WHERE company = $company_id AND is_active = true;
    
    LET $total_value = (SELECT SUM(fair_value) AS total FROM ip_valuation WHERE company = $company_id AND is_active = true)[0].total;
    
    RETURN {
        company_id: $company_id,
        portfolio_summary: {
            trademarks: $trademarks[0].count,
            patents: $patents[0].count,
            copyrights: $copyrights[0].count,
            licenses: $licenses[0].count
        },
        total_estimated_value: $total_value,
        currency: "EUR",
        evaluation_date: time::now()
    };
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE
-- ==============================================================================

-- Marque exemple
CREATE trademark:lyxal_brand CONTENT {
    trademark_id: "TM-LYXAL-001",
    name: "LYXAL",
    description: "Marque principale de la société LYXAL",
    registration_number: "FR123456789",
    registration_date: "2024-01-15T00:00:00Z",
    expiry_date: "2034-01-15T00:00:00Z",
    status: "registered",
    classes: ["09", "42"],
    territories: ["FR", "EU"],
    filing_date: "2023-06-15T00:00:00Z",
    registration_office: "INPI",
    renewal_due_date: "2033-06-15T00:00:00Z",
    cost: 1500.00,
    is_active: true,
    created_on: time::now()
};

-- Brevet exemple
CREATE patent:lyxal_innovation CONTENT {
    patent_id: "PT-LYXAL-001",
    title: "Système de gestion intelligente des données d'entreprise",
    description: "Innovation dans le traitement automatisé des données métier",
    application_number: "FR2023123456",
    filing_date: "2023-03-15T00:00:00Z",
    status: "filed",
    patent_type: "invention",
    inventors: [
        {
            name: "Jean Dupont",
            role: "Inventeur principal",
            percentage: 60
        }
    ],
    classification_codes: ["G06F17/30"],
    territories: ["FR", "EU", "US"],
    filing_cost: 5000.00,
    is_active: true,
    created_on: time::now()
};

-- Licence exemple
CREATE ip_license:software_license CONTENT {
    license_id: "LIC-LYXAL-001",
    title: "Licence logiciel LYXAL Analytics",
    license_type: "copyright",
    licensed_ip: "LYXAL Analytics Software",
    licensor: "LYXAL SA",
    licensee: "Client Enterprise",
    license_nature: "non_exclusive",
    grant_date: "2024-01-01T00:00:00Z",
    expiry_date: "2026-12-31T23:59:59Z",
    territories: ["FR"],
    fields_of_use: ["enterprise_analytics", "business_intelligence"],
    royalty_rate: 15.0,
    minimum_royalty: 50000.00,
    upfront_fee: 100000.00,
    status: "active",
    is_active: true,
    created_on: time::now()
};

-- Surveillance exemple
CREATE ip_surveillance:trademark_monitoring CONTENT {
    surveillance_id: "SURV-LYXAL-001",
    monitored_ip: "LYXAL",
    ip_type: "trademark",
    monitoring_scope: ["trademark_databases", "domain_names", "social_media"],
    search_keywords: ["LYXAL", "LYXAL SUITE", "LYXAL ANALYTICS"],
    monitoring_frequency: "weekly",
    last_scan_date: time::now(),
    alerts_generated: [],
    potential_infringements: [],
    monitoring_cost: 200.00,
    effectiveness_score: 85.0,
    is_active: true,
    created_on: time::now()
};

-- Valorisation exemple
CREATE ip_valuation:portfolio_valuation CONTENT {
    valuation_id: "VAL-LYXAL-001",
    ip_asset: "LYXAL Brand Portfolio",
    ip_type: "portfolio",
    valuation_date: time::now(),
    valuation_method: "relief_from_royalty",
    fair_value: 2500000.00,
    currency: "EUR",
    confidence_level: "high",
    valuation_purpose: "financial_reporting",
    key_assumptions: [
        {
            assumption: "Croissance annuelle 15%",
            impact: "Augmentation de la valeur"
        }
    ],
    discount_rate: 12.0,
    valuation_period_years: 10,
    annual_revenue_attributed: 500000.00,
    next_valuation_date: "2025-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DU MODULE PROPRIÉTÉ INTELLECTUELLE :

1. MARQUES (trademark)
   - Enregistrement et suivi complet
   - Renouvellements automatiques
   - Gestion des oppositions

2. BREVETS (patent)
   - Portfolio innovation
   - Suivi des échéances
   - Valorisation commerciale

3. DROITS D'AUTEUR (copyright)
   - Protection des créations
   - Gestion des auteurs
   - Revenus et licences

4. LICENCES (ip_license)
   - Gestion des droits
   - Conditions financières
   - Suivi des performances

5. SURVEILLANCE (ip_surveillance)
   - Veille contrefaçon
   - Alertes automatiques
   - Actions correctives

6. VALORISATION (ip_valuation)
   - Évaluation du patrimoine IP
   - Méthodes de valorisation
   - Reporting financier

UTILISATION :
- Gestion complète du patrimoine IP
- Protection et valorisation
- Surveillance et défense
- Reporting et conformité
*/ 
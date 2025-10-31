-- ==============================================================================
-- TABLE : NORMES COMPTABLES
-- ==============================================================================

DEFINE TABLE accounting_standard SCHEMAFULL;

-- Identification (statique)
DEFINE FIELD code ON accounting_standard TYPE string 
    ASSERT string::len($value) > 0
    COMMENT "Code unique de la norme (ex: PCG2014, IFRS16)";

DEFINE FIELD name ON accounting_standard TYPE string 
    ASSERT string::len($value) > 0
    COMMENT "Nom complet de la norme";

DEFINE FIELD description ON accounting_standard TYPE string
    COMMENT "Description détaillée";

DEFINE FIELD version ON accounting_standard TYPE string
    COMMENT "Version de la norme";

-- Géolocalisation (statique)
DEFINE FIELD country ON accounting_standard TYPE option<record<country>>
    COMMENT "Pays d'origine (null pour international)";

DEFINE FIELD region ON accounting_standard TYPE option<string>
    COMMENT "Région d'application (EU, ASEAN, etc.)";

-- Catégorisation (statique - standards internationaux)
DEFINE FIELD scope ON accounting_standard TYPE string 
    ASSERT $value IN ['national', 'international', 'sectoral', 'group']
    COMMENT "Portée d'application";

DEFINE FIELD category ON accounting_standard TYPE string 
    ASSERT $value IN ['pcg', 'ifrs', 'gaap', 'sectoral', 'simplified', 'other']
    COMMENT "Catégorie de norme comptable";

-- Temporalité (statique)
DEFINE FIELD effective_date ON accounting_standard TYPE datetime
    COMMENT "Date d'entrée en vigueur";

DEFINE FIELD last_update ON accounting_standard TYPE datetime
    COMMENT "Dernière mise à jour de la norme";

DEFINE FIELD status ON accounting_standard TYPE string 
    ASSERT $value IN ['active', 'draft', 'obsolete', 'transitional']
    COMMENT "Statut de la norme";

-- Applicabilité (DYNAMIQUE - évolutif)
DEFINE FIELD is_mandatory ON accounting_standard TYPE bool DEFAULT false
    COMMENT "Norme obligatoire ou optionnelle";

DEFINE FIELD eligibility_criteria ON accounting_standard TYPE object DEFAULT {
    revenue_thresholds: {
        min_revenue: null,
        max_revenue: null,
        currency: "EUR",
        period: "annual"
    },
    employee_thresholds: {
        min_employees: null,
        max_employees: null
    },
    legal_forms: [],
    sectors: [],
    listing_status: [],
    geographic_restrictions: [],
    other_conditions: []
} COMMENT "Critères d'éligibilité structurés et extensibles";

DEFINE FIELD application_rules ON accounting_standard TYPE object DEFAULT {
    mandatory_for: [],
    optional_for: [],
    prohibited_for: [],
    transition_rules: {},
    exemptions: []
} COMMENT "Règles d'application détaillées";

-- Configuration par pays (DYNAMIQUE)
DEFINE FIELD country_specific_config ON accounting_standard TYPE object DEFAULT {}
    COMMENT "Configuration spécifique par pays/juridiction";

-- Métadonnées extensibles (DYNAMIQUE)
DEFINE FIELD compliance_requirements ON accounting_standard TYPE object DEFAULT {
    reporting_frequency: null,
    audit_requirements: false,
    publication_requirements: false,
    certification_needed: false,
    training_requirements: []
} COMMENT "Exigences de conformité";

DEFINE FIELD implementation_guidance ON accounting_standard TYPE object DEFAULT {
    transition_period: null,
    implementation_steps: [],
    common_challenges: [],
    best_practices: [],
    tools_and_resources: []
} COMMENT "Guide d'implémentation";

-- Relations hiérarchiques (statique)
DEFINE FIELD parent_standard ON accounting_standard TYPE option<record<accounting_standard>>
    COMMENT "Norme parent dans la hiérarchie";

-- Système (statique)
DEFINE FIELD created_on ON accounting_standard TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_standard TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON accounting_standard TYPE option<string>;
DEFINE FIELD updated_by ON accounting_standard TYPE option<string>;

-- Index optimisés
DEFINE INDEX idx_accounting_standard_code ON accounting_standard COLUMNS code UNIQUE;
DEFINE INDEX idx_accounting_standard_country ON accounting_standard COLUMNS country;
DEFINE INDEX idx_accounting_standard_category ON accounting_standard COLUMNS category;
DEFINE INDEX idx_accounting_standard_status ON accounting_standard COLUMNS status;
DEFINE INDEX idx_accounting_standard_scope ON accounting_standard COLUMNS scope;

-- =============================================================================
-- EXEMPLES D'USAGE
-- =============================================================================
/*
-- PCG France (obligatoire pour toutes les entreprises françaises)
CREATE accounting_standard:pcg2014 SET {
    code: "PCG2014",
    name: "Plan Comptable Général 2014",
    country: country:france,
    scope: "national",
    category: "pcg",
    status: "active",
    is_mandatory: true,
    eligibility_criteria: {
        legal_forms: ["SARL", "SAS", "SA", "SNC", "SCS"],
        sectors: ["all"],
        geographic_restrictions: ["france"]
    },
    application_rules: {
        mandatory_for: ["all_french_companies"],
        exemptions: ["micro_enterprises_under_threshold"]
    }
};

-- IFRS (optionnel selon critères)
CREATE accounting_standard:ifrs SET {
    code: "IFRS",
    name: "International Financial Reporting Standards",
    scope: "international", 
    category: "ifrs",
    status: "active",
    is_mandatory: false,
    eligibility_criteria: {
        revenue_thresholds: {
            min_revenue: 8000000,
            currency: "EUR"
        },
        listing_status: ["listed", "preparing_ipo"],
        legal_forms: ["SA", "SAS"]
    },
    application_rules: {
        mandatory_for: ["listed_companies"],
        optional_for: ["large_companies", "multinational_subsidiaries"]
    },
    compliance_requirements: {
        reporting_frequency: "quarterly",
        audit_requirements: true,
        publication_requirements: true
    }
};

-- Norme sectorielle bancaire
CREATE accounting_standard:crbf_banking SET {
    code: "CRBF-91-01",
    name: "Règlement bancaire français",
    country: country:france,
    scope: "sectoral",
    category: "sectoral", 
    status: "active",
    is_mandatory: true,
    eligibility_criteria: {
        sectors: ["banking", "credit_institutions"],
        legal_forms: ["SA", "SAS"],
        other_conditions: ["banking_license_required"]
    },
    country_specific_config: {
        supervisor: "ACPR",
        reporting_templates: ["FINREP", "COREP"],
        local_adaptations: {}
    }
};
*/ 
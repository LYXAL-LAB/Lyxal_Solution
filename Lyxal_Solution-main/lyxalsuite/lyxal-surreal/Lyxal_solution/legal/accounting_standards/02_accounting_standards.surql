-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : NORMES COMPTABLES
-- ==============================================================================
-- Fichier : 02_accounting_standards.surql
-- Description : Normes comptables, plans comptables et mapping
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : NORMES COMPTABLES
-- ==============================================================================

DEFINE TABLE accounting_standard SCHEMAFULL;
DEFINE FIELD code ON accounting_standard TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON accounting_standard TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON accounting_standard TYPE string;
DEFINE FIELD version ON accounting_standard TYPE string;
DEFINE FIELD country ON accounting_standard TYPE option<record<country>>;
DEFINE FIELD region ON accounting_standard TYPE option<string>;
DEFINE FIELD scope ON accounting_standard TYPE string 
    ASSERT $value IN ['national', 'international', 'sectoral', 'group'];
DEFINE FIELD category ON accounting_standard TYPE string 
    ASSERT $value IN ['pcg', 'ifrs', 'gaap', 'sectoral', 'simplified', 'other'];
DEFINE FIELD effective_date ON accounting_standard TYPE datetime;
DEFINE FIELD last_update ON accounting_standard TYPE datetime;
DEFINE FIELD status ON accounting_standard TYPE string 
    ASSERT $value IN ['active', 'draft', 'obsolete', 'transitional'];
DEFINE FIELD is_mandatory ON accounting_standard TYPE bool DEFAULT false;
DEFINE FIELD applies_to ON accounting_standard TYPE array<string>;
DEFINE FIELD parent_standard ON accounting_standard TYPE option<record<accounting_standard>>;
DEFINE FIELD created_on ON accounting_standard TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_standard TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON accounting_standard TYPE option<record<user>>;
DEFINE FIELD updated_by ON accounting_standard TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_accounting_standard_code ON accounting_standard COLUMNS code UNIQUE;
DEFINE INDEX idx_accounting_standard_country ON accounting_standard COLUMNS country;
DEFINE INDEX idx_accounting_standard_category ON accounting_standard COLUMNS category;
DEFINE INDEX idx_accounting_standard_status ON accounting_standard COLUMNS status;

-- ==============================================================================
-- TABLE : COMPTES COMPTABLES
-- ==============================================================================

DEFINE TABLE account_chart SCHEMAFULL;
DEFINE FIELD account_number ON account_chart TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD account_name ON account_chart TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD account_type ON account_chart TYPE string 
    ASSERT $value IN ['asset', 'liability', 'equity', 'revenue', 'expense', 'other'];
DEFINE FIELD account_class ON account_chart TYPE int 
    ASSERT $value >= 1 AND $value <= 8;
DEFINE FIELD level ON account_chart TYPE int 
    ASSERT $value >= 1 AND $value <= 6;
DEFINE FIELD parent_account ON account_chart TYPE option<record<account_chart>>;
DEFINE FIELD accounting_standard ON account_chart TYPE record<accounting_standard>;
DEFINE FIELD description ON account_chart TYPE string;
DEFINE FIELD debit_credit_nature ON account_chart TYPE string 
    ASSERT $value IN ['debit', 'credit', 'both'];
DEFINE FIELD is_analytical ON account_chart TYPE bool DEFAULT false;
DEFINE FIELD is_auxiliary ON account_chart TYPE bool DEFAULT false;
DEFINE FIELD is_reconciliation ON account_chart TYPE bool DEFAULT false;
DEFINE FIELD is_active ON account_chart TYPE bool DEFAULT true;
DEFINE FIELD usage_rules ON account_chart TYPE object;
DEFINE FIELD validation_rules ON account_chart TYPE object;
DEFINE FIELD reporting_category ON account_chart TYPE string;
DEFINE FIELD tax_category ON account_chart TYPE option<string>;
DEFINE FIELD created_on ON account_chart TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON account_chart TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON account_chart TYPE option<record<user>>;
DEFINE FIELD updated_by ON account_chart TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_account_chart_number ON account_chart COLUMNS account_number, accounting_standard UNIQUE;
DEFINE INDEX idx_account_chart_class ON account_chart COLUMNS account_class;
DEFINE INDEX idx_account_chart_type ON account_chart COLUMNS account_type;
DEFINE INDEX idx_account_chart_standard ON account_chart COLUMNS accounting_standard;
DEFINE INDEX idx_account_chart_active ON account_chart COLUMNS is_active;

-- ==============================================================================
-- TABLE : MAPPING ENTRE NORMES
-- ==============================================================================

DEFINE TABLE accounting_mapping SCHEMAFULL;
DEFINE FIELD source_standard ON accounting_mapping TYPE record<accounting_standard>;
DEFINE FIELD target_standard ON accounting_mapping TYPE record<accounting_standard>;
DEFINE FIELD source_account ON accounting_mapping TYPE record<account_chart>;
DEFINE FIELD target_account ON accounting_mapping TYPE record<account_chart>;
DEFINE FIELD mapping_type ON accounting_mapping TYPE string 
    ASSERT $value IN ['direct', 'split', 'consolidate', 'conditional'];
DEFINE FIELD mapping_ratio ON accounting_mapping TYPE float DEFAULT 1.0;
DEFINE FIELD conditions ON accounting_mapping TYPE object;
DEFINE FIELD notes ON accounting_mapping TYPE string;
DEFINE FIELD is_active ON accounting_mapping TYPE bool DEFAULT true;
DEFINE FIELD created_on ON accounting_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON accounting_mapping TYPE option<record<user>>;
DEFINE FIELD updated_by ON accounting_mapping TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_accounting_mapping_source ON accounting_mapping COLUMNS source_standard, source_account;
DEFINE INDEX idx_accounting_mapping_target ON accounting_mapping COLUMNS target_standard, target_account;
DEFINE INDEX idx_accounting_mapping_active ON accounting_mapping COLUMNS is_active;

-- ==============================================================================
-- TABLE : RÈGLES DE VALIDATION COMPTABLE
-- ==============================================================================

DEFINE TABLE accounting_validation_rule SCHEMAFULL;
DEFINE FIELD rule_name ON accounting_validation_rule TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD rule_type ON accounting_validation_rule TYPE string 
    ASSERT $value IN ['balance', 'debit_credit', 'mandatory_field', 'format', 'range', 'custom'];
DEFINE FIELD accounting_standard ON accounting_validation_rule TYPE record<accounting_standard>;
DEFINE FIELD applicable_accounts ON accounting_validation_rule TYPE array<record<account_chart>>;
DEFINE FIELD rule_condition ON accounting_validation_rule TYPE string;
DEFINE FIELD error_message ON accounting_validation_rule TYPE string;
DEFINE FIELD severity ON accounting_validation_rule TYPE string 
    ASSERT $value IN ['error', 'warning', 'info'];
DEFINE FIELD is_blocking ON accounting_validation_rule TYPE bool DEFAULT false;
DEFINE FIELD is_active ON accounting_validation_rule TYPE bool DEFAULT true;
DEFINE FIELD created_on ON accounting_validation_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_validation_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON accounting_validation_rule TYPE option<record<user>>;
DEFINE FIELD updated_by ON accounting_validation_rule TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_accounting_validation_rule_standard ON accounting_validation_rule COLUMNS accounting_standard;
DEFINE INDEX idx_accounting_validation_rule_type ON accounting_validation_rule COLUMNS rule_type;
DEFINE INDEX idx_accounting_validation_rule_active ON accounting_validation_rule COLUMNS is_active;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour obtenir les comptes par classe
DEFINE FUNCTION get_accounts_by_class($standard_id: record<accounting_standard>, $class: int) {
    RETURN SELECT * FROM account_chart 
    WHERE accounting_standard = $standard_id 
    AND account_class = $class 
    AND is_active = true 
    ORDER BY account_number;
};

-- Fonction pour obtenir la hiérarchie des comptes
DEFINE FUNCTION get_account_hierarchy($account_id: record<account_chart>) {
    RETURN SELECT * FROM account_chart 
    WHERE parent_account = $account_id 
    AND is_active = true 
    ORDER BY account_number;
};

-- Fonction pour mapper un compte vers une autre norme
DEFINE FUNCTION map_account_to_standard($source_account: record<account_chart>, $target_standard: record<accounting_standard>) {
    RETURN SELECT target_account.* FROM accounting_mapping 
    WHERE source_account = $source_account 
    AND target_standard = $target_standard 
    AND is_active = true;
};

-- Fonction pour valider un compte selon les règles
DEFINE FUNCTION validate_account($account_id: record<account_chart>, $data: object) {
    RETURN SELECT * FROM accounting_validation_rule 
    WHERE accounting_standard = (SELECT accounting_standard FROM account_chart WHERE id = $account_id) 
    AND $account_id IN applicable_accounts 
    AND is_active = true;
};


-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : NORMES COMPTABLES
-- ==============================================================================

-- Norme PCG France
CREATE accounting_standard:pcg_france CONTENT {
    code: "PCG_FR",
    name: "Plan Comptable Général Français",
    description: "Plan comptable général français conforme à l'ANC",
    version: "2023",
    country: country:fr,
    scope: "national",
    category: "pcg",
    effective_date: "2023-01-01T00:00:00Z",
    last_update: "2023-01-01T00:00:00Z",
    status: "active",
    is_mandatory: true,
    applies_to: ["companies", "associations", "cooperatives"],
    created_on: time::now()
};

-- Norme IFRS
CREATE accounting_standard:ifrs CONTENT {
    code: "IFRS",
    name: "International Financial Reporting Standards",
    description: "Normes comptables internationales IFRS",
    version: "2024",
    region: "international",
    scope: "international",
    category: "ifrs",
    effective_date: "2024-01-01T00:00:00Z",
    last_update: "2024-01-01T00:00:00Z",
    status: "active",
    is_mandatory: false,
    applies_to: ["listed_companies", "multinational_groups"],
    created_on: time::now()
};

-- Norme GAAP US
CREATE accounting_standard:gaap_us CONTENT {
    code: "GAAP_US",
    name: "US Generally Accepted Accounting Principles",
    description: "Principes comptables généralement reconnus aux États-Unis",
    version: "2024",
    country: country:us,
    scope: "national",
    category: "gaap",
    effective_date: "2024-01-01T00:00:00Z",
    last_update: "2024-01-01T00:00:00Z",
    status: "active",
    is_mandatory: true,
    applies_to: ["us_companies", "sec_registered"],
    created_on: time::now()
};

-- Norme PCG Belgique
CREATE accounting_standard:pcg_belgium CONTENT {
    code: "PCG_BE",
    name: "Plan Comptable Général Belge",
    description: "Plan comptable minimum normalisé belge",
    version: "2023",
    country: country:be,
    scope: "national",
    category: "pcg",
    effective_date: "2023-01-01T00:00:00Z",
    last_update: "2023-01-01T00:00:00Z",
    status: "active",
    is_mandatory: true,
    applies_to: ["belgian_companies"],
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : PLAN COMPTABLE FRANÇAIS (Classes principales)
-- ==============================================================================

-- CLASSE 1 : COMPTES DE CAPITAUX
CREATE account_chart:pcg_fr_1 CONTENT {
    account_number: "1",
    account_name: "Comptes de capitaux",
    account_type: "equity",
    account_class: 1,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Capitaux propres, provisions pour risques et charges, dettes financières",
    debit_credit_nature: "credit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_10 CONTENT {
    account_number: "10",
    account_name: "Capital et réserves",
    account_type: "equity",
    account_class: 1,
    level: 2,
    parent_account: account_chart:pcg_fr_1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Capital social, primes, réserves",
    debit_credit_nature: "credit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_101 CONTENT {
    account_number: "101",
    account_name: "Capital",
    account_type: "equity",
    account_class: 1,
    level: 3,
    parent_account: account_chart:pcg_fr_10,
    accounting_standard: accounting_standard:pcg_france,
    description: "Capital social ou individuel",
    debit_credit_nature: "credit",
    is_active: true,
    created_on: time::now()
};

-- CLASSE 2 : COMPTES D'IMMOBILISATIONS
CREATE account_chart:pcg_fr_2 CONTENT {
    account_number: "2",
    account_name: "Comptes d'immobilisations",
    account_type: "asset",
    account_class: 2,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Immobilisations incorporelles, corporelles et financières",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_20 CONTENT {
    account_number: "20",
    account_name: "Immobilisations incorporelles",
    account_type: "asset",
    account_class: 2,
    level: 2,
    parent_account: account_chart:pcg_fr_2,
    accounting_standard: accounting_standard:pcg_france,
    description: "Frais d'établissement, recherche et développement, brevets, etc.",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_21 CONTENT {
    account_number: "21",
    account_name: "Immobilisations corporelles",
    account_type: "asset",
    account_class: 2,
    level: 2,
    parent_account: account_chart:pcg_fr_2,
    accounting_standard: accounting_standard:pcg_france,
    description: "Terrains, constructions, matériel, etc.",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

-- CLASSE 3 : COMPTES DE STOCKS
CREATE account_chart:pcg_fr_3 CONTENT {
    account_number: "3",
    account_name: "Comptes de stocks et en-cours",
    account_type: "asset",
    account_class: 3,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Stocks de matières premières, produits finis, marchandises",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

-- CLASSE 4 : COMPTES DE TIERS
CREATE account_chart:pcg_fr_4 CONTENT {
    account_number: "4",
    account_name: "Comptes de tiers",
    account_type: "both",
    account_class: 4,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Clients, fournisseurs, personnel, organismes sociaux, État",
    debit_credit_nature: "both",
    is_auxiliary: true,
    is_reconciliation: true,
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_41 CONTENT {
    account_number: "41",
    account_name: "Clients et comptes rattachés",
    account_type: "asset",
    account_class: 4,
    level: 2,
    parent_account: account_chart:pcg_fr_4,
    accounting_standard: accounting_standard:pcg_france,
    description: "Créances clients",
    debit_credit_nature: "debit",
    is_auxiliary: true,
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_40 CONTENT {
    account_number: "40",
    account_name: "Fournisseurs et comptes rattachés",
    account_type: "liability",
    account_class: 4,
    level: 2,
    parent_account: account_chart:pcg_fr_4,
    accounting_standard: accounting_standard:pcg_france,
    description: "Dettes fournisseurs",
    debit_credit_nature: "credit",
    is_auxiliary: true,
    is_active: true,
    created_on: time::now()
};

-- CLASSE 5 : COMPTES FINANCIERS
CREATE account_chart:pcg_fr_5 CONTENT {
    account_number: "5",
    account_name: "Comptes financiers",
    account_type: "asset",
    account_class: 5,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Valeurs mobilières, banques, caisse",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_51 CONTENT {
    account_number: "51",
    account_name: "Banques, établissements financiers",
    account_type: "asset",
    account_class: 5,
    level: 2,
    parent_account: account_chart:pcg_fr_5,
    accounting_standard: accounting_standard:pcg_france,
    description: "Comptes en banque et assimilés",
    debit_credit_nature: "debit",
    is_reconciliation: true,
    is_active: true,
    created_on: time::now()
};

-- CLASSE 6 : COMPTES DE CHARGES
CREATE account_chart:pcg_fr_6 CONTENT {
    account_number: "6",
    account_name: "Comptes de charges",
    account_type: "expense",
    account_class: 6,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Charges d'exploitation, financières et exceptionnelles",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_60 CONTENT {
    account_number: "60",
    account_name: "Achats",
    account_type: "expense",
    account_class: 6,
    level: 2,
    parent_account: account_chart:pcg_fr_6,
    accounting_standard: accounting_standard:pcg_france,
    description: "Achats stockés et non stockés",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_61 CONTENT {
    account_number: "61",
    account_name: "Services extérieurs",
    account_type: "expense",
    account_class: 6,
    level: 2,
    parent_account: account_chart:pcg_fr_6,
    accounting_standard: accounting_standard:pcg_france,
    description: "Sous-traitance, loyers, entretien, etc.",
    debit_credit_nature: "debit",
    is_active: true,
    created_on: time::now()
};

-- CLASSE 7 : COMPTES DE PRODUITS
CREATE account_chart:pcg_fr_7 CONTENT {
    account_number: "7",
    account_name: "Comptes de produits",
    account_type: "revenue",
    account_class: 7,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Produits d'exploitation, financiers et exceptionnels",
    debit_credit_nature: "credit",
    is_active: true,
    created_on: time::now()
};

CREATE account_chart:pcg_fr_70 CONTENT {
    account_number: "70",
    account_name: "Ventes de produits finis, prestations de services",
    account_type: "revenue",
    account_class: 7,
    level: 2,
    parent_account: account_chart:pcg_fr_7,
    accounting_standard: accounting_standard:pcg_france,
    description: "Chiffre d'affaires",
    debit_credit_nature: "credit",
    is_active: true,
    created_on: time::now()
};

-- CLASSE 8 : COMPTES SPÉCIAUX
CREATE account_chart:pcg_fr_8 CONTENT {
    account_number: "8",
    account_name: "Comptes spéciaux",
    account_type: "other",
    account_class: 8,
    level: 1,
    accounting_standard: accounting_standard:pcg_france,
    description: "Comptes d'engagements, analytiques, etc.",
    debit_credit_nature: "both",
    is_analytical: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : RÈGLES DE VALIDATION
-- ==============================================================================

-- Règle d'équilibre débit/crédit
CREATE accounting_validation_rule:balance_rule CONTENT {
    rule_name: "Équilibre débit/crédit",
    rule_type: "balance",
    accounting_standard: accounting_standard:pcg_france,
    applicable_accounts: [],
    rule_condition: "sum(debits) = sum(credits)",
    error_message: "L'écriture comptable doit être équilibrée",
    severity: "error",
    is_blocking: true,
    is_active: true,
    created_on: time::now()
};

-- Règle format numéro de compte
CREATE accounting_validation_rule:account_format_rule CONTENT {
    rule_name: "Format numéro de compte",
    rule_type: "format",
    accounting_standard: accounting_standard:pcg_france,
    applicable_accounts: [],
    rule_condition: "account_number matches /^[1-8][0-9]{0,7}$/",
    error_message: "Le numéro de compte doit commencer par un chiffre de 1 à 8",
    severity: "error",
    is_blocking: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : MAPPINGS IFRS ↔ PCG
-- ==============================================================================

-- Mapping Capital PCG → IFRS
CREATE accounting_mapping:pcg_to_ifrs_capital CONTENT {
    source_standard: accounting_standard:pcg_france,
    target_standard: accounting_standard:ifrs,
    source_account: account_chart:pcg_fr_101,
    target_account: account_chart:pcg_fr_101,
    mapping_type: "direct",
    mapping_ratio: 1.0,
    notes: "Mapping direct capital PCG vers IFRS",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES NORMES COMPTABLES :

1. NORMES COMPTABLES (accounting_standard)
   - Identification et métadonnées
   - Portée géographique et sectorielle
   - Statut et applicabilité

2. PLAN COMPTABLE (account_chart)
   - Hiérarchie des comptes (8 classes)
   - Règles de fonctionnement
   - Catégorisation et types

3. MAPPING INTER-NORMES (accounting_mapping)
   - Correspondances entre normes
   - Ratios et conditions
   - Conversions automatiques

4. VALIDATION (accounting_validation_rule)
   - Règles métier
   - Contrôles de cohérence
   - Messages d'erreur

UTILISATION :
- Gestion multi-normes
- Consolidation internationale
- Reporting réglementaire
- Audit et conformité
*/ 
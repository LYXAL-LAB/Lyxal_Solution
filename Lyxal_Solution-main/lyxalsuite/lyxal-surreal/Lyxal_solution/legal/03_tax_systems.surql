-- ==============================================================================
-- LYXAL SUITE - MODULE LEGAL : SYSTÈMES FISCAUX
-- ==============================================================================
-- Fichier : 03_tax_systems.surql
-- Description : Régimes fiscaux, TVA, taxes et déclarations
-- Version : 1.0
-- Auteur : LYXAL Development Team
-- ==============================================================================

-- ==============================================================================
-- TABLE : RÉGIMES FISCAUX
-- ==============================================================================

DEFINE TABLE tax_regime SCHEMAFULL;
DEFINE FIELD code ON tax_regime TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON tax_regime TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON tax_regime TYPE string;
DEFINE FIELD country ON tax_regime TYPE record<country>;
DEFINE FIELD regime_type ON tax_regime TYPE string 
    ASSERT $value IN ['corporate', 'individual', 'vat', 'social', 'local', 'special'];
DEFINE FIELD category ON tax_regime TYPE string 
    ASSERT $value IN ['standard', 'simplified', 'micro', 'group', 'consolidated', 'exempt'];
DEFINE FIELD applicable_entities ON tax_regime TYPE array<string>;
DEFINE FIELD minimum_threshold ON tax_regime TYPE option<decimal>;
DEFINE FIELD maximum_threshold ON tax_regime TYPE option<decimal>;
DEFINE FIELD base_rate ON tax_regime TYPE option<decimal>;
DEFINE FIELD calculation_method ON tax_regime TYPE string 
    ASSERT $value IN ['progressive', 'flat', 'proportional', 'tiered'];
DEFINE FIELD effective_date ON tax_regime TYPE datetime;
DEFINE FIELD end_date ON tax_regime TYPE option<datetime>;
DEFINE FIELD conditions ON tax_regime TYPE object;
DEFINE FIELD benefits ON tax_regime TYPE object;
DEFINE FIELD obligations ON tax_regime TYPE object;
DEFINE FIELD reporting_frequency ON tax_regime TYPE string 
    ASSERT $value IN ['monthly', 'quarterly', 'annual', 'on_demand'];
DEFINE FIELD is_active ON tax_regime TYPE bool DEFAULT true;
DEFINE FIELD created_on ON tax_regime TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_regime TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON tax_regime TYPE option<record<user>>;
DEFINE FIELD updated_by ON tax_regime TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_tax_regime_code ON tax_regime COLUMNS code, country UNIQUE;
DEFINE INDEX idx_tax_regime_country ON tax_regime COLUMNS country;
DEFINE INDEX idx_tax_regime_type ON tax_regime COLUMNS regime_type;
DEFINE INDEX idx_tax_regime_category ON tax_regime COLUMNS category;
DEFINE INDEX idx_tax_regime_active ON tax_regime COLUMNS is_active;

-- ==============================================================================
-- TABLE : TYPES DE TAXES
-- ==============================================================================

DEFINE TABLE tax_type SCHEMAFULL;
DEFINE FIELD code ON tax_type TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON tax_type TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON tax_type TYPE string;
DEFINE FIELD country ON tax_type TYPE record<country>;
DEFINE FIELD tax_category ON tax_type TYPE string 
    ASSERT $value IN ['vat', 'corporate', 'income', 'social', 'local', 'excise', 'customs', 'environmental'];
DEFINE FIELD calculation_basis ON tax_type TYPE string 
    ASSERT $value IN ['turnover', 'profit', 'income', 'value_added', 'quantity', 'weight', 'volume'];
DEFINE FIELD default_rate ON tax_type TYPE decimal;
DEFINE FIELD reduced_rates ON tax_type TYPE array<object>;
DEFINE FIELD exemptions ON tax_type TYPE array<object>;
DEFINE FIELD collection_method ON tax_type TYPE string 
    ASSERT $value IN ['self_assessment', 'withholding', 'direct', 'indirect'];
DEFINE FIELD payment_frequency ON tax_type TYPE string 
    ASSERT $value IN ['monthly', 'quarterly', 'annual', 'on_transaction'];
DEFINE FIELD administration_level ON tax_type TYPE string 
    ASSERT $value IN ['federal', 'state', 'regional', 'local'];
DEFINE FIELD is_deductible ON tax_type TYPE bool DEFAULT false;
DEFINE FIELD is_recoverable ON tax_type TYPE bool DEFAULT false;
DEFINE FIELD effective_date ON tax_type TYPE datetime;
DEFINE FIELD end_date ON tax_type TYPE option<datetime>;
DEFINE FIELD is_active ON tax_type TYPE bool DEFAULT true;
DEFINE FIELD created_on ON tax_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON tax_type TYPE option<record<user>>;
DEFINE FIELD updated_by ON tax_type TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_tax_type_code ON tax_type COLUMNS code, country UNIQUE;
DEFINE INDEX idx_tax_type_country ON tax_type COLUMNS country;
DEFINE INDEX idx_tax_type_category ON tax_type COLUMNS tax_category;
DEFINE INDEX idx_tax_type_active ON tax_type COLUMNS is_active;

-- ==============================================================================
-- TABLE : TAUX DE TAXES
-- ==============================================================================

DEFINE TABLE tax_rate SCHEMAFULL;
DEFINE FIELD tax_type ON tax_rate TYPE record<tax_type>;
DEFINE FIELD rate_name ON tax_rate TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD rate_value ON tax_rate TYPE decimal 
    ASSERT $value >= 0 AND $value <= 100;
DEFINE FIELD rate_type ON tax_rate TYPE string 
    ASSERT $value IN ['standard', 'reduced', 'super_reduced', 'zero', 'exempt'];
DEFINE FIELD applicable_products ON tax_rate TYPE array<string>;
DEFINE FIELD applicable_services ON tax_rate TYPE array<string>;
DEFINE FIELD conditions ON tax_rate TYPE object;
DEFINE FIELD minimum_amount ON tax_rate TYPE option<decimal>;
DEFINE FIELD maximum_amount ON tax_rate TYPE option<decimal>;
DEFINE FIELD effective_date ON tax_rate TYPE datetime;
DEFINE FIELD end_date ON tax_rate TYPE option<datetime>;
DEFINE FIELD is_active ON tax_rate TYPE bool DEFAULT true;
DEFINE FIELD created_on ON tax_rate TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_rate TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON tax_rate TYPE option<record<user>>;
DEFINE FIELD updated_by ON tax_rate TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_tax_rate_type ON tax_rate COLUMNS tax_type;
DEFINE INDEX idx_tax_rate_effective ON tax_rate COLUMNS effective_date;
DEFINE INDEX idx_tax_rate_active ON tax_rate COLUMNS is_active;

-- ==============================================================================
-- TABLE : DÉCLARATIONS FISCALES
-- ==============================================================================

DEFINE TABLE tax_declaration SCHEMAFULL;
DEFINE FIELD code ON tax_declaration TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD name ON tax_declaration TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON tax_declaration TYPE string;
DEFINE FIELD country ON tax_declaration TYPE record<country>;
DEFINE FIELD tax_types ON tax_declaration TYPE array<record<tax_type>>;
DEFINE FIELD declaration_type ON tax_declaration TYPE string 
    ASSERT $value IN ['periodic', 'annual', 'occasional', 'correction'];
DEFINE FIELD frequency ON tax_declaration TYPE string 
    ASSERT $value IN ['monthly', 'quarterly', 'annual', 'on_demand'];
DEFINE FIELD due_date_rule ON tax_declaration TYPE string;
DEFINE FIELD late_penalty_rate ON tax_declaration TYPE option<decimal>;
DEFINE FIELD minimum_threshold ON tax_declaration TYPE option<decimal>;
DEFINE FIELD required_documents ON tax_declaration TYPE array<string>;
DEFINE FIELD electronic_filing ON tax_declaration TYPE bool DEFAULT false;
DEFINE FIELD mandatory_fields ON tax_declaration TYPE array<string>;
DEFINE FIELD calculation_rules ON tax_declaration TYPE object;
DEFINE FIELD validation_rules ON tax_declaration TYPE array<object>;
DEFINE FIELD is_active ON tax_declaration TYPE bool DEFAULT true;
DEFINE FIELD created_on ON tax_declaration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_declaration TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON tax_declaration TYPE option<record<user>>;
DEFINE FIELD updated_by ON tax_declaration TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_tax_declaration_code ON tax_declaration COLUMNS code, country UNIQUE;
DEFINE INDEX idx_tax_declaration_country ON tax_declaration COLUMNS country;
DEFINE INDEX idx_tax_declaration_type ON tax_declaration COLUMNS declaration_type;
DEFINE INDEX idx_tax_declaration_frequency ON tax_declaration COLUMNS frequency;
DEFINE INDEX idx_tax_declaration_active ON tax_declaration COLUMNS is_active;

-- ==============================================================================
-- TABLE : OBLIGATIONS FISCALES
-- ==============================================================================

DEFINE TABLE tax_obligation SCHEMAFULL;
DEFINE FIELD name ON tax_obligation TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD description ON tax_obligation TYPE string;
DEFINE FIELD country ON tax_obligation TYPE record<country>;
DEFINE FIELD tax_regime ON tax_obligation TYPE record<tax_regime>;
DEFINE FIELD obligation_type ON tax_obligation TYPE string 
    ASSERT $value IN ['declaration', 'payment', 'registration', 'record_keeping', 'audit', 'other'];
DEFINE FIELD frequency ON tax_obligation TYPE string 
    ASSERT $value IN ['daily', 'weekly', 'monthly', 'quarterly', 'annual', 'on_event'];
DEFINE FIELD due_date_rule ON tax_obligation TYPE string;
DEFINE FIELD penalty_type ON tax_obligation TYPE string 
    ASSERT $value IN ['fixed', 'percentage', 'progressive', 'compound'];
DEFINE FIELD penalty_rate ON tax_obligation TYPE option<decimal>;
DEFINE FIELD minimum_penalty ON tax_obligation TYPE option<decimal>;
DEFINE FIELD maximum_penalty ON tax_obligation TYPE option<decimal>;
DEFINE FIELD applicable_entities ON tax_obligation TYPE array<string>;
DEFINE FIELD exemption_conditions ON tax_obligation TYPE object;
DEFINE FIELD required_documents ON tax_obligation TYPE array<string>;
DEFINE FIELD automation_possible ON tax_obligation TYPE bool DEFAULT false;
DEFINE FIELD is_active ON tax_obligation TYPE bool DEFAULT true;
DEFINE FIELD created_on ON tax_obligation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_obligation TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON tax_obligation TYPE option<record<user>>;
DEFINE FIELD updated_by ON tax_obligation TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_tax_obligation_country ON tax_obligation COLUMNS country;
DEFINE INDEX idx_tax_obligation_regime ON tax_obligation COLUMNS tax_regime;
DEFINE INDEX idx_tax_obligation_type ON tax_obligation COLUMNS obligation_type;
DEFINE INDEX idx_tax_obligation_frequency ON tax_obligation COLUMNS frequency;
DEFINE INDEX idx_tax_obligation_active ON tax_obligation COLUMNS is_active;

-- ==============================================================================
-- TABLE : CALENDRIER FISCAL
-- ==============================================================================

DEFINE TABLE tax_calendar SCHEMAFULL;
DEFINE FIELD country ON tax_calendar TYPE record<country>;
DEFINE FIELD year ON tax_calendar TYPE int 
    ASSERT $value >= 2020 AND $value <= 2030;
DEFINE FIELD month ON tax_calendar TYPE option<int> 
    ASSERT $value >= 1 AND $value <= 12;
DEFINE FIELD tax_obligation ON tax_calendar TYPE record<tax_obligation>;
DEFINE FIELD due_date ON tax_calendar TYPE date;
DEFINE FIELD description ON tax_calendar TYPE string;
DEFINE FIELD is_holiday_adjusted ON tax_calendar TYPE bool DEFAULT true;
DEFINE FIELD reminder_days ON tax_calendar TYPE int DEFAULT 7;
DEFINE FIELD status ON tax_calendar TYPE string 
    ASSERT $value IN ['pending', 'completed', 'overdue', 'cancelled'];
DEFINE FIELD completion_date ON tax_calendar TYPE option<datetime>;
DEFINE FIELD notes ON tax_calendar TYPE string;
DEFINE FIELD created_on ON tax_calendar TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON tax_calendar TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON tax_calendar TYPE option<record<user>>;
DEFINE FIELD updated_by ON tax_calendar TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_tax_calendar_country_year ON tax_calendar COLUMNS country, year;
DEFINE INDEX idx_tax_calendar_due_date ON tax_calendar COLUMNS due_date;
DEFINE INDEX idx_tax_calendar_obligation ON tax_calendar COLUMNS tax_obligation;
DEFINE INDEX idx_tax_calendar_status ON tax_calendar COLUMNS status;

-- ==============================================================================
-- FONCTIONS UTILITAIRES
-- ==============================================================================

-- Fonction pour calculer le taux de TVA applicable
DEFINE FUNCTION get_applicable_tax_rate($country_id: record<country>, $tax_category: string, $product_type: string) {
    RETURN SELECT rate_value FROM tax_rate 
    WHERE tax_type.country = $country_id 
    AND tax_type.tax_category = $tax_category
    AND $product_type IN applicable_products 
    AND is_active = true 
    AND effective_date <= time::now() 
    AND (end_date IS NULL OR end_date > time::now())
    ORDER BY effective_date DESC 
    LIMIT 1;
};

-- Fonction pour obtenir les obligations fiscales par régime
DEFINE FUNCTION get_tax_obligations_by_regime($regime_id: record<tax_regime>) {
    RETURN SELECT * FROM tax_obligation 
    WHERE tax_regime = $regime_id 
    AND is_active = true 
    ORDER BY frequency, due_date_rule;
};

-- Fonction pour calculer les pénalités de retard
DEFINE FUNCTION calculate_late_penalty($obligation_id: record<tax_obligation>, $days_late: int, $base_amount: decimal) {
    LET $obligation = SELECT * FROM tax_obligation WHERE id = $obligation_id;
    RETURN SWITCH $obligation.penalty_type {
        'fixed' => $obligation.minimum_penalty,
        'percentage' => $base_amount * ($obligation.penalty_rate / 100) * $days_late,
        'progressive' => $base_amount * ($obligation.penalty_rate / 100) * ($days_late ^ 1.1),
        'compound' => $base_amount * ((1 + $obligation.penalty_rate / 100) ^ $days_late - 1),
        _ => 0
    };
};

-- Fonction pour obtenir le calendrier fiscal par pays et année
DEFINE FUNCTION get_tax_calendar($country_id: record<country>, $year: int, $month: option<int>) {
    RETURN SELECT * FROM tax_calendar 
    WHERE country = $country_id 
    AND year = $year 
    AND ($month IS NULL OR month = $month)
    ORDER BY due_date;
};

-- Fonction pour vérifier l'éligibilité à un régime fiscal
DEFINE FUNCTION check_regime_eligibility($regime_id: record<tax_regime>, $entity_type: string, $revenue: decimal) {
    LET $regime = SELECT * FROM tax_regime WHERE id = $regime_id;
    RETURN (
        $entity_type IN $regime.applicable_entities AND
        ($regime.minimum_threshold IS NULL OR $revenue >= $regime.minimum_threshold) AND
        ($regime.maximum_threshold IS NULL OR $revenue <= $regime.maximum_threshold) AND
        $regime.is_active = true
    );
};

-- ==============================================================================
-- VUES OPTIMISÉES
-- ==============================================================================

-- Vue des taux de TVA par pays
DEFINE TABLE vat_rates_by_country AS SELECT 
    tax_type.country AS country,
    tax_type.name AS tax_name,
    tax_rate.rate_name,
    tax_rate.rate_value,
    tax_rate.rate_type,
    tax_rate.effective_date,
    tax_rate.end_date
FROM tax_rate 
INNER JOIN tax_type ON tax_rate.tax_type = tax_type.id
WHERE tax_type.tax_category = 'vat' 
AND tax_rate.is_active = true;

-- Vue des obligations fiscales actives
DEFINE TABLE active_tax_obligations AS SELECT 
    tax_obligation.*,
    tax_regime.name AS regime_name,
    tax_regime.country AS country
FROM tax_obligation 
INNER JOIN tax_regime ON tax_obligation.tax_regime = tax_regime.id
WHERE tax_obligation.is_active = true 
AND tax_regime.is_active = true;

-- Vue du calendrier fiscal en cours
DEFINE TABLE current_tax_calendar AS SELECT 
    tax_calendar.*,
    tax_obligation.name AS obligation_name,
    tax_obligation.obligation_type,
    tax_obligation.penalty_rate
FROM tax_calendar 
INNER JOIN tax_obligation ON tax_calendar.tax_obligation = tax_obligation.id
WHERE tax_calendar.year = time::year(time::now()) 
AND tax_calendar.due_date >= time::now()
ORDER BY tax_calendar.due_date;

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : RÉGIMES FISCAUX FRANÇAIS
-- ==============================================================================

-- Régime normal d'imposition
CREATE tax_regime:fr_normal CONTENT {
    code: "FR_NORMAL",
    name: "Régime normal d'imposition",
    description: "Régime fiscal standard pour les entreprises en France",
    country: country:fr,
    regime_type: "corporate",
    category: "standard",
    applicable_entities: ["sarl", "sas", "sa", "eurl", "sasu"],
    base_rate: 25.0,
    calculation_method: "proportional",
    effective_date: "2023-01-01T00:00:00Z",
    conditions: {
        minimum_ca: 0,
        maximum_ca: null,
        requirements: ["comptabilité complète", "bilan annuel"]
    },
    reporting_frequency: "annual",
    is_active: true,
    created_on: time::now()
};

-- Régime micro-entreprise
CREATE tax_regime:fr_micro CONTENT {
    code: "FR_MICRO",
    name: "Régime micro-entreprise",
    description: "Régime fiscal simplifié pour les petites entreprises",
    country: country:fr,
    regime_type: "individual",
    category: "simplified",
    applicable_entities: ["ei", "eurl"],
    minimum_threshold: 0,
    maximum_threshold: 176200,
    calculation_method: "flat",
    effective_date: "2023-01-01T00:00:00Z",
    conditions: {
        ca_services: 72600,
        ca_ventes: 176200,
        abattement_services: 50,
        abattement_ventes: 71
    },
    reporting_frequency: "annual",
    is_active: true,
    created_on: time::now()
};

-- Régime TVA normal
CREATE tax_regime:fr_tva_normal CONTENT {
    code: "FR_TVA_NORMAL",
    name: "Régime TVA normal",
    description: "Régime TVA standard avec déclarations mensuelles/trimestrielles",
    country: country:fr,
    regime_type: "vat",
    category: "standard",
    applicable_entities: ["all"],
    minimum_threshold: 85800,
    calculation_method: "proportional",
    effective_date: "2023-01-01T00:00:00Z",
    reporting_frequency: "monthly",
    is_active: true,
    created_on: time::now()
};

-- Régime micro-TVA (franchise en base)
CREATE tax_regime:fr_tva_micro CONTENT {
    code: "FR_TVA_MICRO",
    name: "Franchise en base de TVA",
    description: "Exemption de TVA pour les petites entreprises",
    country: country:fr,
    regime_type: "vat",
    category: "exempt",
    applicable_entities: ["ei", "eurl", "micro"],
    maximum_threshold: 85800,
    calculation_method: "flat",
    effective_date: "2023-01-01T00:00:00Z",
    conditions: {
        ca_services: 34400,
        ca_ventes: 85800,
        no_tva_deduction: true
    },
    reporting_frequency: "annual",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TYPES DE TAXES FRANÇAIS
-- ==============================================================================

-- TVA France
CREATE tax_type:fr_tva CONTENT {
    code: "FR_TVA",
    name: "Taxe sur la Valeur Ajoutée",
    description: "TVA française sur les biens et services",
    country: country:fr,
    tax_category: "vat",
    calculation_basis: "value_added",
    default_rate: 20.0,
    reduced_rates: [
        {rate: 10.0, description: "Taux réduit"},
        {rate: 5.5, description: "Taux super réduit"},
        {rate: 2.1, description: "Taux particulier"}
    ],
    collection_method: "self_assessment",
    payment_frequency: "monthly",
    administration_level: "federal",
    is_deductible: true,
    is_recoverable: true,
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- Impôt sur les sociétés
CREATE tax_type:fr_is CONTENT {
    code: "FR_IS",
    name: "Impôt sur les Sociétés",
    description: "Impôt français sur les bénéfices des sociétés",
    country: country:fr,
    tax_category: "corporate",
    calculation_basis: "profit",
    default_rate: 25.0,
    reduced_rates: [
        {rate: 15.0, description: "Taux réduit PME (jusqu'à 42 500€)"}
    ],
    collection_method: "self_assessment",
    payment_frequency: "quarterly",
    administration_level: "federal",
    is_deductible: false,
    is_recoverable: false,
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- Cotisations sociales
CREATE tax_type:fr_cotisations CONTENT {
    code: "FR_COTISATIONS",
    name: "Cotisations sociales",
    description: "Cotisations sociales patronales et salariales",
    country: country:fr,
    tax_category: "social",
    calculation_basis: "income",
    default_rate: 45.0,
    collection_method: "withholding",
    payment_frequency: "monthly",
    administration_level: "federal",
    is_deductible: true,
    is_recoverable: false,
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : TAUX DE TVA FRANÇAIS
-- ==============================================================================

-- Taux normal 20%
CREATE tax_rate:fr_tva_20 CONTENT {
    tax_type: tax_type:fr_tva,
    rate_name: "Taux normal",
    rate_value: 20.0,
    rate_type: "standard",
    applicable_products: ["general", "services", "biens"],
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- Taux réduit 10%
CREATE tax_rate:fr_tva_10 CONTENT {
    tax_type: tax_type:fr_tva,
    rate_name: "Taux réduit",
    rate_value: 10.0,
    rate_type: "reduced",
    applicable_products: ["restauration", "transport", "hotellerie"],
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- Taux super réduit 5,5%
CREATE tax_rate:fr_tva_5_5 CONTENT {
    tax_type: tax_type:fr_tva,
    rate_name: "Taux super réduit",
    rate_value: 5.5,
    rate_type: "super_reduced",
    applicable_products: ["alimentation", "livres", "energie"],
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- Taux particulier 2,1%
CREATE tax_rate:fr_tva_2_1 CONTENT {
    tax_type: tax_type:fr_tva,
    rate_name: "Taux particulier",
    rate_value: 2.1,
    rate_type: "super_reduced",
    applicable_products: ["medicaments", "presse"],
    effective_date: "2023-01-01T00:00:00Z",
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : DÉCLARATIONS FISCALES FRANÇAIS
-- ==============================================================================

-- Déclaration TVA mensuelle
CREATE tax_declaration:fr_tva_mensuelle CONTENT {
    code: "FR_TVA_CA3",
    name: "Déclaration TVA mensuelle (CA3)",
    description: "Déclaration mensuelle de TVA pour les entreprises",
    country: country:fr,
    tax_types: [tax_type:fr_tva],
    declaration_type: "periodic",
    frequency: "monthly",
    due_date_rule: "20 du mois suivant",
    late_penalty_rate: 5.0,
    minimum_threshold: 4000,
    required_documents: ["justificatifs", "factures"],
    electronic_filing: true,
    mandatory_fields: ["ca_ht", "tva_collectee", "tva_deductible"],
    is_active: true,
    created_on: time::now()
};

-- Déclaration IS annuelle
CREATE tax_declaration:fr_is_annuelle CONTENT {
    code: "FR_IS_2065",
    name: "Déclaration IS annuelle (2065)",
    description: "Déclaration annuelle d'impôt sur les sociétés",
    country: country:fr,
    tax_types: [tax_type:fr_is],
    declaration_type: "annual",
    frequency: "annual",
    due_date_rule: "3 mois après clôture",
    late_penalty_rate: 10.0,
    required_documents: ["bilan", "compte_resultat", "annexes"],
    electronic_filing: true,
    mandatory_fields: ["resultat_fiscal", "is_a_payer"],
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : OBLIGATIONS FISCALES FRANÇAIS
-- ==============================================================================

-- Déclaration TVA
CREATE tax_obligation:fr_tva_declaration CONTENT {
    name: "Déclaration TVA",
    description: "Déclaration périodique de TVA",
    country: country:fr,
    tax_regime: tax_regime:fr_tva_normal,
    obligation_type: "declaration",
    frequency: "monthly",
    due_date_rule: "20 du mois suivant",
    penalty_type: "percentage",
    penalty_rate: 5.0,
    minimum_penalty: 60,
    applicable_entities: ["all"],
    automation_possible: true,
    is_active: true,
    created_on: time::now()
};

-- Paiement TVA
CREATE tax_obligation:fr_tva_payment CONTENT {
    name: "Paiement TVA",
    description: "Paiement de la TVA due",
    country: country:fr,
    tax_regime: tax_regime:fr_tva_normal,
    obligation_type: "payment",
    frequency: "monthly",
    due_date_rule: "20 du mois suivant",
    penalty_type: "percentage",
    penalty_rate: 5.0,
    minimum_penalty: 60,
    applicable_entities: ["all"],
    automation_possible: true,
    is_active: true,
    created_on: time::now()
};

-- Acomptes IS
CREATE tax_obligation:fr_is_acomptes CONTENT {
    name: "Acomptes IS",
    description: "Versement d'acomptes d'impôt sur les sociétés",
    country: country:fr,
    tax_regime: tax_regime:fr_normal,
    obligation_type: "payment",
    frequency: "quarterly",
    due_date_rule: "15 du mois (mars, juin, septembre, décembre)",
    penalty_type: "percentage",
    penalty_rate: 5.0,
    applicable_entities: ["societes"],
    automation_possible: true,
    is_active: true,
    created_on: time::now()
};

-- ==============================================================================
-- DONNÉES DE RÉFÉRENCE : CALENDRIER FISCAL 2024
-- ==============================================================================

-- TVA janvier 2024
CREATE tax_calendar:fr_tva_jan_2024 CONTENT {
    country: country:fr,
    year: 2024,
    month: 1,
    tax_obligation: tax_obligation:fr_tva_declaration,
    due_date: "2024-02-20",
    description: "Déclaration TVA janvier 2024",
    is_holiday_adjusted: true,
    reminder_days: 7,
    status: "pending",
    created_on: time::now()
};

-- IS acompte mars 2024
CREATE tax_calendar:fr_is_acompte_mar_2024 CONTENT {
    country: country:fr,
    year: 2024,
    month: 3,
    tax_obligation: tax_obligation:fr_is_acomptes,
    due_date: "2024-03-15",
    description: "Acompte IS mars 2024",
    is_holiday_adjusted: true,
    reminder_days: 10,
    status: "pending",
    created_on: time::now()
};

-- ==============================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ==============================================================================

/*
STRUCTURE DES SYSTÈMES FISCAUX :

1. RÉGIMES FISCAUX (tax_regime)
   - Définition des cadres fiscaux
   - Conditions d'éligibilité
   - Taux et méthodes de calcul

2. TYPES DE TAXES (tax_type)
   - Classification des taxes
   - Modes de calcul et recouvrement
   - Déductibilité et récupération

3. TAUX DE TAXES (tax_rate)
   - Taux standards et réduits
   - Conditions d'application
   - Évolution temporelle

4. DÉCLARATIONS FISCALES (tax_declaration)
   - Formalités déclaratives
   - Fréquences et échéances
   - Pénalités de retard

5. OBLIGATIONS FISCALES (tax_obligation)
   - Devoirs et responsabilités
   - Calendrier des obligations
   - Sanctions en cas de défaut

6. CALENDRIER FISCAL (tax_calendar)
   - Planification des échéances
   - Suivi des obligations
   - Gestion des rappels

UTILISATION :
- Calcul automatique des taxes
- Gestion des déclarations
- Suivi des obligations
- Planification fiscale
- Conformité réglementaire
*/ 
-- =============================================================================
-- TABLE: legal_form (Formes juridiques par pays)
-- Formes juridiques spécifiques à chaque pays avec leurs caractéristiques
-- =============================================================================
DEFINE TABLE legal_form SCHEMAFULL;

-- Identification
DEFINE FIELD name ON legal_form TYPE string ASSERT $value != NONE
    COMMENT "Nom de la forme juridique (ex: SARL, SAS, LLC)";

DEFINE FIELD code ON legal_form TYPE string ASSERT $value != NONE
    COMMENT "Code court (ex: SARL, SAS, LLC)";

DEFINE FIELD description ON legal_form TYPE option<string>
    COMMENT "Description détaillée de la forme juridique";

-- Rattachement au pays
DEFINE FIELD country ON legal_form TYPE record<country>
    COMMENT "Pays auquel appartient cette forme juridique";

-- Catégorisation dynamique
DEFINE FIELD category ON legal_form TYPE record<legal_category>
    COMMENT "Catégorie spécifique (niveau le plus bas de la hiérarchie)";

-- Caractéristiques juridiques
DEFINE FIELD isCommercial ON legal_form TYPE bool DEFAULT true
    COMMENT "Forme juridique commerciale";

DEFINE FIELD isLimitedLiability ON legal_form TYPE bool DEFAULT false
    COMMENT "Responsabilité limitée";

DEFINE FIELD requiresMinimumCapital ON legal_form TYPE bool DEFAULT false
    COMMENT "Exige un capital minimum";

DEFINE FIELD minimumCapital ON legal_form TYPE option<decimal>
    COMMENT "Capital minimum requis";

DEFINE FIELD minimumShareholders ON legal_form TYPE int DEFAULT 1
    COMMENT "Nombre minimum d'actionnaires/associés";

DEFINE FIELD maximumShareholders ON legal_form TYPE option<int>
    COMMENT "Nombre maximum d'actionnaires/associés";

-- Exigences spécifiques
DEFINE FIELD requirements ON legal_form TYPE object VALUE {
    auditRequired: false,
    boardRequired: false,
    publicationRequired: false,
    specificReporting: false,
    registrationAuthority: null,
    additionalCompliance: []
} COMMENT "Exigences spécifiques (audit, conseil, publication, etc.)";

-- Fiscalité
DEFINE FIELD defaultTaxRegime ON legal_form TYPE option<record<tax_regime>>
    COMMENT "Régime fiscal par défaut (référence vers tax_regime)";

DEFINE FIELD allowsVATExemption ON legal_form TYPE bool DEFAULT false
    COMMENT "Permet l'exonération de TVA";

-- Informations pratiques
DEFINE FIELD typicalUse ON legal_form TYPE option<string>
    COMMENT "Utilisation typique de cette forme juridique";

DEFINE FIELD advantages ON legal_form TYPE array<string>
    COMMENT "Avantages de cette forme juridique";

DEFINE FIELD disadvantages ON legal_form TYPE array<string>
    COMMENT "Inconvénients de cette forme juridique";

-- Statut et système
DEFINE FIELD active ON legal_form TYPE bool DEFAULT true
    COMMENT "Forme juridique active";

DEFINE FIELD created_on ON legal_form TYPE datetime DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD updated_on ON legal_form TYPE datetime DEFAULT time::now()
    COMMENT "Date de mise à jour";

DEFINE FIELD created_by ON legal_form TYPE option<string>
    COMMENT "Créé par";

DEFINE FIELD updated_by ON legal_form TYPE option<string>
    COMMENT "Mis à jour par";

-- Index optimisés
DEFINE INDEX idx_legal_form_country ON legal_form COLUMNS country;
DEFINE INDEX idx_legal_form_code_country ON legal_form COLUMNS code, country UNIQUE;
DEFINE INDEX idx_legal_form_active ON legal_form COLUMNS active;
DEFINE INDEX idx_legal_form_category ON legal_form COLUMNS category;
DEFINE INDEX idx_legal_form_commercial ON legal_form COLUMNS isCommercial;

-- ================================================================================================
-- 🔗 MASTER REGISTRY - RELATIONS HIÉRARCHIQUES
-- ================================================================================================

-- Relations entre les différents niveaux de la hiérarchie LyxalSuite
-- Namespace: lyxal_master | Database: main

-- ================================================================================================
-- RELATIONS HIÉRARCHIQUES
-- ================================================================================================

-- Relation: Investor owns Business
DEFINE TABLE owns_business SCHEMAFULL
    COMMENT "Relation propriété investor -> business";

DEFINE FIELD in ON owns_business TYPE record(investor_registry);
DEFINE FIELD out ON owns_business TYPE record(business_registry);
DEFINE FIELD created_at ON owns_business TYPE datetime DEFAULT time::now();
DEFINE FIELD revenue_share_percentage ON owns_business TYPE float DEFAULT 30.0
    COMMENT "Pourcentage de revenus pour l'investor";

-- Relation: Business manages Developer
DEFINE TABLE manages_developer SCHEMAFULL
    COMMENT "Relation gestion business -> developer";

DEFINE FIELD in ON manages_developer TYPE record(business_registry);
DEFINE FIELD out ON manages_developer TYPE record(developer_registry);
DEFINE FIELD created_at ON manages_developer TYPE datetime DEFAULT time::now();
DEFINE FIELD commission_percentage ON manages_developer TYPE float DEFAULT 20.0
    COMMENT "Pourcentage de commission pour le business";

-- Relation: Developer serves Contractor
DEFINE TABLE serves_contractor SCHEMAFULL
    COMMENT "Relation service developer -> contractor";

DEFINE FIELD in ON serves_contractor TYPE record(developer_registry);
DEFINE FIELD out ON serves_contractor TYPE record(contractor_registry);
DEFINE FIELD created_at ON serves_contractor TYPE datetime DEFAULT time::now();
DEFINE FIELD service_level ON serves_contractor TYPE string
    ASSERT $value INSIDE ['basic', 'premium', 'enterprise']
    VALUE $value OR 'basic'
    COMMENT "Niveau de service fourni"; 
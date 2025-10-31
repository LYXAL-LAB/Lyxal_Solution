-- ================================================================================
-- Table des tailles d'entreprise
-- ================================================================================
-- DESCRIPTION: Gère les différentes catégories de tailles d'entreprise
-- USAGE: Référence pour partner, sales_methodology, lead, opportunity
-- ================================================================================

DEFINE TABLE company_size SCHEMAFULL;

-- Nom de la taille d'entreprise
DEFINE FIELD name ON company_size TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 50;

-- Code unique de la taille
DEFINE FIELD code ON company_size TYPE string 
    ASSERT string::len($value) > 0 AND string::len($value) <= 20;

-- Nom en français
DEFINE FIELD name_fr ON company_size TYPE string;

-- Nom en anglais
DEFINE FIELD name_en ON company_size TYPE string;

-- Nom en allemand
DEFINE FIELD name_de ON company_size TYPE string;

-- Nom en espagnol
DEFINE FIELD name_es ON company_size TYPE string;

-- Description détaillée
DEFINE FIELD description ON company_size TYPE string;

-- Nombre minimum d'employés
DEFINE FIELD min_employees ON company_size TYPE int DEFAULT 0;

-- Nombre maximum d'employés (null = illimité)
DEFINE FIELD max_employees ON company_size TYPE option<int>;

-- Chiffre d'affaires minimum (en euros)
DEFINE FIELD min_revenue ON company_size TYPE decimal DEFAULT 0.0;

-- Chiffre d'affaires maximum (null = illimité)
DEFINE FIELD max_revenue ON company_size TYPE option<decimal>;

-- Catégorie réglementaire (selon classification officielle)
DEFINE FIELD regulatory_category ON company_size TYPE string;

-- Région/Pays de classification
DEFINE FIELD classification_region ON company_size TYPE string DEFAULT 'EU';

-- Caractéristiques typiques
DEFINE FIELD typical_characteristics ON company_size TYPE array<string>;

-- Défis business typiques
DEFINE FIELD typical_challenges ON company_size TYPE array<string>;

-- Besoins technologiques typiques
DEFINE FIELD typical_tech_needs ON company_size TYPE array<string>;

-- Processus de décision typique
DEFINE FIELD typical_decision_process ON company_size TYPE string;

-- Durée moyenne du cycle de vente
DEFINE FIELD average_sales_cycle_days ON company_size TYPE int DEFAULT 30;

-- Budget IT typique (% du CA)
DEFINE FIELD typical_it_budget_percentage ON company_size TYPE decimal DEFAULT 3.0;

-- Secteurs d'activité principaux
DEFINE FIELD main_industries ON company_size TYPE array<string>;

-- Approches commerciales recommandées
DEFINE FIELD recommended_sales_approaches ON company_size TYPE array<string>;

-- Canaux de vente privilégiés
DEFINE FIELD preferred_sales_channels ON company_size TYPE array<string>;

-- Icône associée
DEFINE FIELD icon ON company_size TYPE string DEFAULT 'building';

-- Couleur d'affichage (hex color)
DEFINE FIELD color ON company_size TYPE string DEFAULT '#6c757d'
    ASSERT string::len($value) = 7 AND string::starts_with($value, '#');

-- Fréquence d'utilisation (statistique)
DEFINE FIELD usage_frequency ON company_size TYPE int DEFAULT 0;

-- Ordre d'affichage
DEFINE FIELD display_order ON company_size TYPE int DEFAULT 0;

-- Statut actif/inactif
DEFINE FIELD is_active ON company_size TYPE bool DEFAULT true;

-- Métadonnées de suivi
DEFINE FIELD created_at ON company_size TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON company_size TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON company_size TYPE option<string>;
DEFINE FIELD updated_by ON company_size TYPE option<string>;

-- Index pour performance
DEFINE INDEX idx_company_size_code ON company_size COLUMNS code UNIQUE;
DEFINE INDEX idx_company_size_name ON company_size COLUMNS name UNIQUE;
DEFINE INDEX idx_company_size_employees ON company_size COLUMNS min_employees, max_employees;
DEFINE INDEX idx_company_size_revenue ON company_size COLUMNS min_revenue, max_revenue;
DEFINE INDEX idx_company_size_active ON company_size COLUMNS is_active;

-- ================================================================================
-- DONNÉES INITIALES - TAILLES D'ENTREPRISE STANDARDS
-- ================================================================================

-- TPE (Très Petite Entreprise)
INSERT INTO company_size {
    name: 'TPE',
    code: 'TPE',
    name_fr: 'Très Petite Entreprise',
    name_en: 'Micro Enterprise',
    name_de: 'Kleinstunternehmen',
    name_es: 'Microempresa',
    description: 'Très petites entreprises avec moins de 10 employés',
    min_employees: 1,
    max_employees: 9,
    min_revenue: 0.0,
    max_revenue: 2000000.0,
    regulatory_category: 'Micro-entreprise',
    classification_region: 'EU',
    typical_characteristics: ['Structure simple', 'Décision rapide', 'Budget limité', 'Flexibilité'],
    typical_challenges: ['Ressources limitées', 'Expertise technique', 'Croissance rapide'],
    typical_tech_needs: ['Solutions simples', 'Cloud', 'Mobilité', 'Support'],
    typical_decision_process: 'Dirigeant unique',
    average_sales_cycle_days: 14,
    typical_it_budget_percentage: 2.0,
    main_industries: ['Services', 'Commerce', 'Artisanat', 'Consulting'],
    recommended_sales_approaches: ['Transactionnel', 'Direct', 'Digital'],
    preferred_sales_channels: ['Online', 'Téléphone', 'Partenaires locaux'],
    icon: 'home',
    color: '#28a745',
    usage_frequency: 0,
    display_order: 1,
    is_active: true,
    created_by: 'system'
};

-- PME (Petite et Moyenne Entreprise)
INSERT INTO company_size {
    name: 'PME',
    code: 'PME',
    name_fr: 'Petite et Moyenne Entreprise',
    name_en: 'Small and Medium Enterprise',
    name_de: 'Kleine und mittlere Unternehmen',
    name_es: 'Pequeña y Mediana Empresa',
    description: 'Petites et moyennes entreprises de 10 à 249 employés',
    min_employees: 10,
    max_employees: 249,
    min_revenue: 2000000.0,
    max_revenue: 50000000.0,
    regulatory_category: 'PME',
    classification_region: 'EU',
    typical_characteristics: ['Structure organisée', 'Processus définis', 'Croissance soutenue'],
    typical_challenges: ['Digitalisation', 'Compétitivité', 'Recrutement', 'Financement'],
    typical_tech_needs: ['ERP', 'CRM', 'Collaboration', 'Sécurité'],
    typical_decision_process: 'Comité de direction',
    average_sales_cycle_days: 45,
    typical_it_budget_percentage: 3.5,
    main_industries: ['Manufacturing', 'Distribution', 'Services B2B', 'Technology'],
    recommended_sales_approaches: ['Standard', 'Consultative', 'Solution'],
    preferred_sales_channels: ['Direct', 'Partenaires', 'Events'],
    icon: 'building',
    color: '#007bff',
    usage_frequency: 0,
    display_order: 2,
    is_active: true,
    created_by: 'system'
};

-- ETI (Entreprise de Taille Intermédiaire)
INSERT INTO company_size {
    name: 'ETI',
    code: 'ETI',
    name_fr: 'Entreprise de Taille Intermédiaire',
    name_en: 'Mid-size Enterprise',
    name_de: 'Mittelständisches Unternehmen',
    name_es: 'Empresa de Tamaño Intermedio',
    description: 'Entreprises de taille intermédiaire de 250 à 4999 employés',
    min_employees: 250,
    max_employees: 4999,
    min_revenue: 50000000.0,
    max_revenue: 1500000000.0,
    regulatory_category: 'ETI',
    classification_region: 'EU',
    typical_characteristics: ['Organisation complexe', 'Processus matures', 'International'],
    typical_challenges: ['Transformation digitale', 'Innovation', 'Agilité', 'Talent'],
    typical_tech_needs: ['Solutions intégrées', 'Analytics', 'Automation', 'Cloud hybride'],
    typical_decision_process: 'Processus structuré avec validation multiple',
    average_sales_cycle_days: 90,
    typical_it_budget_percentage: 4.0,
    main_industries: ['Manufacturing', 'Retail', 'Financial Services', 'Healthcare'],
    recommended_sales_approaches: ['Consultative', 'Solution', 'Enterprise'],
    preferred_sales_channels: ['Direct', 'Account management', 'Partnerships'],
    icon: 'building-columns',
    color: '#ffc107',
    usage_frequency: 0,
    display_order: 3,
    is_active: true,
    created_by: 'system'
};

-- Grande Entreprise
INSERT INTO company_size {
    name: 'Grande Entreprise',
    code: 'LARGE',
    name_fr: 'Grande Entreprise',
    name_en: 'Large Enterprise',
    name_de: 'Großunternehmen',
    name_es: 'Gran Empresa',
    description: 'Grandes entreprises de plus de 5000 employés',
    min_employees: 5000,
    max_employees: NONE,
    min_revenue: 1500000000.0,
    max_revenue: NONE,
    regulatory_category: 'Grande entreprise',
    classification_region: 'EU',
    typical_characteristics: ['Organisation matricielle', 'Processus complexes', 'Global'],
    typical_challenges: ['Innovation', 'Agilité', 'Cybersécurité', 'Compliance'],
    typical_tech_needs: ['Plateformes enterprise', 'AI/ML', 'Security', 'Integration'],
    typical_decision_process: 'Processus long avec multiples parties prenantes',
    average_sales_cycle_days: 180,
    typical_it_budget_percentage: 5.0,
    main_industries: ['Finance', 'Telecom', 'Energy', 'Government'],
    recommended_sales_approaches: ['Enterprise', 'Strategic', 'Consultative'],
    preferred_sales_channels: ['Strategic accounts', 'C-level', 'Consulting partners'],
    icon: 'city',
    color: '#dc3545',
    usage_frequency: 0,
    display_order: 4,
    is_active: true,
    created_by: 'system'
};

-- Multinationale
INSERT INTO company_size {
    name: 'Multinationale',
    code: 'MULTINATIONAL',
    name_fr: 'Multinationale',
    name_en: 'Multinational Corporation',
    name_de: 'Multinationaler Konzern',
    name_es: 'Multinacional',
    description: 'Corporations multinationales avec présence globale',
    min_employees: 10000,
    max_employees: NONE,
    min_revenue: 5000000000.0,
    max_revenue: NONE,
    regulatory_category: 'Multinationale',
    classification_region: 'Global',
    typical_characteristics: ['Présence globale', 'Réglementations multiples', 'Complexité extrême'],
    typical_challenges: ['Governance', 'Standardisation', 'Cultural diversity', 'Regulation'],
    typical_tech_needs: ['Global platforms', 'Compliance', 'Analytics', 'Automation'],
    typical_decision_process: 'Processus très long avec gouvernance globale',
    average_sales_cycle_days: 365,
    typical_it_budget_percentage: 6.0,
    main_industries: ['Technology', 'Finance', 'Energy', 'Pharma'],
    recommended_sales_approaches: ['Strategic', 'Global account', 'Ecosystem'],
    preferred_sales_channels: ['Global accounts', 'Strategic partnerships', 'C-suite'],
    icon: 'globe',
    color: '#6f42c1',
    usage_frequency: 0,
    display_order: 5,
    is_active: true,
    created_by: 'system'
};

-- Consommateur (pour B2C)
INSERT INTO company_size {
    name: 'Consommateur',
    code: 'CONSUMER',
    name_fr: 'Consommateur',
    name_en: 'Consumer',
    name_de: 'Verbraucher',
    name_es: 'Consumidor',
    description: 'Consommateurs individuels pour les ventes B2C',
    min_employees: 0,
    max_employees: 0,
    min_revenue: 0.0,
    max_revenue: 0.0,
    regulatory_category: 'Particulier',
    classification_region: 'Global',
    typical_characteristics: ['Décision individuelle', 'Émotionnel', 'Prix sensible'],
    typical_challenges: ['Confiance', 'Simplicité', 'Support', 'Prix'],
    typical_tech_needs: ['Interface simple', 'Mobile', 'Support', 'Sécurité'],
    typical_decision_process: 'Décision individuelle rapide',
    average_sales_cycle_days: 1,
    typical_it_budget_percentage: 0.0,
    main_industries: ['Retail', 'E-commerce', 'Services', 'Entertainment'],
    recommended_sales_approaches: ['Transactionnel', 'Digital', 'Self-service'],
    preferred_sales_channels: ['Online', 'Retail', 'Mobile app', 'Social'],
    icon: 'user',
    color: '#17a2b8',
    usage_frequency: 0,
    display_order: 6,
    is_active: true,
    created_by: 'system'
};

-- ================================================================================
-- FONCTIONS UTILITAIRES
-- ================================================================================

-- Fonction pour récupérer les tailles actives
DEFINE FUNCTION fn::get_active_company_sizes() {
    RETURN (
        SELECT * FROM company_size 
        WHERE is_active = true 
        ORDER BY display_order
    );
};

-- Fonction pour récupérer une taille par code
DEFINE FUNCTION fn::get_company_size_by_code($code: string) {
    RETURN (
        SELECT * FROM company_size 
        WHERE code = $code 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour déterminer la taille par nombre d'employés
DEFINE FUNCTION fn::get_company_size_by_employees($employees: int) {
    RETURN (
        SELECT * FROM company_size 
        WHERE is_active = true 
        AND min_employees <= $employees 
        AND (max_employees IS NONE OR max_employees >= $employees)
        LIMIT 1
    );
};

-- Fonction pour déterminer la taille par chiffre d'affaires
DEFINE FUNCTION fn::get_company_size_by_revenue($revenue: decimal) {
    RETURN (
        SELECT * FROM company_size 
        WHERE is_active = true 
        AND min_revenue <= $revenue 
        AND (max_revenue IS NONE OR max_revenue >= $revenue)
        LIMIT 1
    );
};

-- Fonction pour récupérer le nom localisé d'une taille
DEFINE FUNCTION fn::get_company_size_localized_name($size_id: string, $language: string) {
    LET $size = (SELECT * FROM company_size WHERE id = $size_id AND is_active = true LIMIT 1);
    IF $size IS NONE {
        RETURN NONE;
    };
    
    RETURN SWITCH $language {
        'fr' => $size.name_fr,
        'en' => $size.name_en,
        'de' => $size.name_de,
        'es' => $size.name_es,
        DEFAULT => $size.name
    };
};

-- Fonction pour incrémenter la fréquence d'utilisation
DEFINE FUNCTION fn::increment_company_size_usage($size_id: string) {
    UPDATE $size_id SET usage_frequency = usage_frequency + 1;
    RETURN true;
}; 
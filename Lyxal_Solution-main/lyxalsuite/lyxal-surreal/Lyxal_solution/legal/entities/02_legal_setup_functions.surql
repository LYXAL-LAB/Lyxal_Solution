-- =============================================================================
-- MODULE LEGAL - SCHÉMAS ET FONCTIONS D'INITIALISATION
-- =============================================================================

-- Définition des tables et schémas (à exécuter en premier)
DEFINE TABLE legal_category SCHEMAFULL;
DEFINE FIELD code ON legal_category TYPE string;
DEFINE FIELD name ON legal_category TYPE string;
DEFINE FIELD description ON legal_category TYPE string;
DEFINE FIELD parent_category ON legal_category TYPE option<record<legal_category>>;
DEFINE FIELD active ON legal_category TYPE bool DEFAULT true;
DEFINE FIELD sort_order ON legal_category TYPE int DEFAULT 0;
DEFINE FIELD created_at ON legal_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON legal_category TYPE datetime DEFAULT time::now();

DEFINE TABLE legal_form SCHEMAFULL;
DEFINE FIELD code ON legal_form TYPE string;
DEFINE FIELD name ON legal_form TYPE string;
DEFINE FIELD description ON legal_form TYPE string;
DEFINE FIELD category ON legal_form TYPE record<legal_category>;
DEFINE FIELD country ON legal_form TYPE string;
DEFINE FIELD active ON legal_form TYPE bool DEFAULT true;
DEFINE FIELD requiresMinimumCapital ON legal_form TYPE bool DEFAULT false;
DEFINE FIELD minimumCapital ON legal_form TYPE decimal DEFAULT 0;
DEFINE FIELD minimumShareholders ON legal_form TYPE int DEFAULT 1;
DEFINE FIELD maximumShareholders ON legal_form TYPE option<int>;
DEFINE FIELD created_at ON legal_form TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON legal_form TYPE datetime DEFAULT time::now();

-- Fonction pour créer des données de test hiérarchiques
DEFINE FUNCTION fn::create_legal_test_data() -> string {
    -- Créer les catégories racines
    LET $commercial = CREATE legal_category:commercial CONTENT {
        code: "COMMERCIAL",
        name: "Entreprises Commerciales",
        description: "Catégorie principale pour les entreprises commerciales",
        parent_category: NONE,
        active: true,
        sort_order: 1
    };
    
    LET $civil = CREATE legal_category:civil CONTENT {
        code: "CIVIL",
        name: "Sociétés Civiles",
        description: "Catégorie pour les sociétés civiles",
        parent_category: NONE,
        active: true,
        sort_order: 2
    };
    
    -- Créer les sous-catégories niveau 1
    LET $capitaux = CREATE legal_category:capitaux CONTENT {
        code: "CAPITAUX",
        name: "Sociétés de Capitaux",
        description: "Sociétés basées sur le capital",
        parent_category: legal_category:commercial,
        active: true,
        sort_order: 1
    };
    
    LET $personnes = CREATE legal_category:personnes CONTENT {
        code: "PERSONNES",
        name: "Sociétés de Personnes",
        description: "Sociétés basées sur les personnes",
        parent_category: legal_category:commercial,
        active: true,
        sort_order: 2
    };
    
    -- Créer les sous-catégories niveau 2
    LET $anonymes = CREATE legal_category:anonymes CONTENT {
        code: "ANONYMES",
        name: "Sociétés Anonymes",
        description: "SA, SAS, etc.",
        parent_category: legal_category:capitaux,
        active: true,
        sort_order: 1
    };
    
    LET $responsabilite = CREATE legal_category:responsabilite CONTENT {
        code: "RESPONSABILITE",
        name: "Sociétés à Responsabilité Limitée",
        description: "SARL, EURL, etc.",
        parent_category: legal_category:capitaux,
        active: true,
        sort_order: 2
    };
    
    -- Créer quelques formes juridiques
    CREATE legal_form:sa CONTENT {
        code: "SA",
        name: "Société Anonyme",
        description: "Société anonyme française",
        category: legal_category:anonymes,
        country: "FR",
        active: true,
        requiresMinimumCapital: true,
        minimumCapital: 37000,
        minimumShareholders: 2,
        maximumShareholders: NONE
    };
    
    CREATE legal_form:sas CONTENT {
        code: "SAS",
        name: "Société par Actions Simplifiée",
        description: "Société par actions simplifiée française",
        category: legal_category:anonymes,
        country: "FR",
        active: true,
        requiresMinimumCapital: false,
        minimumCapital: 1,
        minimumShareholders: 1,
        maximumShareholders: NONE
    };
    
    CREATE legal_form:sarl CONTENT {
        code: "SARL",
        name: "Société à Responsabilité Limitée",
        description: "SARL française",
        category: legal_category:responsabilite,
        country: "FR",
        active: true,
        requiresMinimumCapital: false,
        minimumCapital: 1,
        minimumShareholders: 2,
        maximumShareholders: 100
    };
    
    CREATE legal_form:eurl CONTENT {
        code: "EURL",
        name: "Entreprise Unipersonnelle à Responsabilité Limitée",
        description: "EURL française",
        category: legal_category:responsabilite,
        country: "FR",
        active: true,
        requiresMinimumCapital: false,
        minimumCapital: 1,
        minimumShareholders: 1,
        maximumShareholders: 1
    };
    
    RETURN "Données de test créées avec succès";
};

-- Fonction pour nettoyer les données de test
DEFINE FUNCTION fn::cleanup_legal_test_data() -> string {
    DELETE legal_form;
    DELETE legal_category;
    
    RETURN "Données de test supprimées";
}; 
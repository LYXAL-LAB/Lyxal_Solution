-- ================================================================================
-- Table des types de traitement par lot (Batch Type)
-- ================================================================================
-- DESCRIPTION: Types de batch universels pour tous les modules
-- USAGE: Référence pour crm_batch, accounting_batch, project_batch, etc.
-- ================================================================================

DEFINE TABLE batch_type SCHEMAFULL
    COMMENT "Types de traitement par lot universels";

-- Code unique du type
DEFINE FIELD code ON batch_type TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code unique (ex: LEAD_IMPORT, LEAD_SCORING)";

-- Nom du type
DEFINE FIELD name ON batch_type TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom du type (ex: Importation de leads)";

-- Module propriétaire
DEFINE FIELD module ON batch_type TYPE record<app_module>
    COMMENT "Module propriétaire";

-- Catégorie du batch
DEFINE FIELD category ON batch_type TYPE record<batch_category>
    COMMENT "Catégorie du traitement";

-- Description détaillée
DEFINE FIELD description ON batch_type TYPE option<string>
    COMMENT "Description du type de batch";

-- Valeur numérique pour compatibilité
DEFINE FIELD numeric_value ON batch_type TYPE int
    COMMENT "Valeur numérique pour les champs select";

-- Configuration par défaut
DEFINE FIELD default_config ON batch_type TYPE object VALUE {
    auto_retry: true,
    max_retries: 3,
    batch_size: 100,
    timeout_minutes: 60,
    notification_enabled: true
} COMMENT "Configuration par défaut";

-- Paramètres spécifiques au type
DEFINE FIELD type_params ON batch_type TYPE object VALUE {
    required_fields: [],
    optional_fields: [],
    validation_rules: {},
    processing_options: {}
} COMMENT "Paramètres spécifiques";

-- Statut actif
DEFINE FIELD is_active ON batch_type TYPE bool DEFAULT true
    COMMENT "Type actif";

-- Ordre d'affichage
DEFINE FIELD sequence ON batch_type TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage";

-- Métadonnées
DEFINE FIELD created_at ON batch_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON batch_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON batch_type TYPE option<record<user>>;
DEFINE FIELD updated_by ON batch_type TYPE option<record<user>>;
DEFINE FIELD version ON batch_type TYPE int DEFAULT 0;

-- Index pour performance
DEFINE INDEX idx_batch_type_code ON batch_type COLUMNS code UNIQUE;
DEFINE INDEX idx_batch_type_module ON batch_type COLUMNS module;
DEFINE INDEX idx_batch_type_category ON batch_type COLUMNS category;
DEFINE INDEX idx_batch_type_active ON batch_type COLUMNS is_active;
DEFINE INDEX idx_batch_type_numeric ON batch_type COLUMNS numeric_value;

-- ================================================================================
-- DONNÉES INITIALES - TYPES CRM
-- ================================================================================

-- Types de batch CRM
INSERT INTO batch_type {
    code: 'LEAD_IMPORT',
    name: 'Importation de leads',
    module: app_module:crm,
    category: 'IMPORT',
    numeric_value: 1,
    description: 'Importation en masse de leads depuis fichier CSV/Excel',
    default_config: {
        auto_retry: true,
        max_retries: 3,
        batch_size: 500,
        timeout_minutes: 120,
        notification_enabled: true
    },
    type_params: {
        required_fields: ['name', 'email'],
        optional_fields: ['phone', 'company', 'source'],
        validation_rules: {
            email_format: true,
            phone_format: false,
            duplicate_check: true
        },
        processing_options: {
            skip_duplicates: true,
            update_existing: false,
            auto_assign: true
        }
    },
    is_active: true,
    sequence: 1,
    created_by: 'system'
};

INSERT INTO batch_type {
    code: 'LEAD_SCORING',
    name: 'Scoring de leads',
    module: app_module:crm,
    category: 'SCORING',
    numeric_value: 2,
    description: 'Calcul automatique des scores de leads',
    default_config: {
        auto_retry: true,
        max_retries: 2,
        batch_size: 1000,
        timeout_minutes: 30,
        notification_enabled: true
    },
    type_params: {
        required_fields: ['lead_id'],
        optional_fields: ['scoring_model', 'force_recalculation'],
        validation_rules: {
            lead_exists: true,
            scoring_model_valid: true
        },
        processing_options: {
            use_ai_scoring: true,
            update_probability: true,
            trigger_actions: true
        }
    },
    is_active: true,
    sequence: 2,
    created_by: 'system'
};

INSERT INTO batch_type {
    code: 'LEAD_ASSIGNMENT',
    name: 'Attribution de leads',
    module: app_module:crm,
    category: 'ASSIGNMENT',
    numeric_value: 3,
    description: 'Attribution automatique de leads aux commerciaux',
    default_config: {
        auto_retry: true,
        max_retries: 2,
        batch_size: 200,
        timeout_minutes: 45,
        notification_enabled: true
    },
    type_params: {
        required_fields: ['lead_id', 'assignment_method'],
        optional_fields: ['territory', 'team', 'user'],
        validation_rules: {
            lead_unassigned: true,
            user_capacity: true,
            territory_match: false
        },
        processing_options: {
            balance_workload: true,
            respect_territory: true,
            notify_assignee: true
        }
    },
    is_active: true,
    sequence: 3,
    created_by: 'system'
};

INSERT INTO batch_type {
    code: 'OPPORTUNITY_FORECAST',
    name: 'Prévision d\'opportunités',
    module: app_module:crm,
    category: 'FORECAST',
    numeric_value: 4,
    description: 'Génération de prévisions sur les opportunités',
    default_config: {
        auto_retry: true,
        max_retries: 1,
        batch_size: 50,
        timeout_minutes: 90,
        notification_enabled: true
    },
    type_params: {
        required_fields: ['forecast_period'],
        optional_fields: ['territory', 'team', 'product_category'],
        validation_rules: {
            period_valid: true,
            data_sufficient: true
        },
        processing_options: {
            use_ai_prediction: true,
            include_pipeline: true,
            generate_reports: true
        }
    },
    is_active: true,
    sequence: 4,
    created_by: 'system'
};

-- ================================================================================
-- TYPES DE BATCH AUTRES MODULES
-- ================================================================================

-- Types de batch comptabilité
INSERT INTO batch_type {
    code: 'INVOICE_GENERATION',
    name: 'Génération de factures',
    module: app_module:accounting,
    category: 'EXPORT',
    numeric_value: 201,
    description: 'Génération automatique de factures',
    is_active: true,
    sequence: 1,
    created_by: 'system'
};

INSERT INTO batch_type {
    code: 'PAYMENT_IMPORT',
    name: 'Importation de paiements',
    module: app_module:accounting,
    category: 'IMPORT',
    numeric_value: 202,
    description: 'Importation des paiements bancaires',
    is_active: true,
    sequence: 2,
    created_by: 'system'
};

-- Types de batch projet
INSERT INTO batch_type {
    code: 'PROJECT_SYNC',
    name: 'Synchronisation projets',
    module: app_module:project,
    category: 'SYNC',
    numeric_value: 301,
    description: 'Synchronisation des données projet',
    is_active: true,
    sequence: 1,
    created_by: 'system'
};

-- Types de batch stock
INSERT INTO batch_type {
    code: 'STOCK_REORDER',
    name: 'Réapprovisionnement stock',
    module: app_module:stock,
    category: 'FORECAST',
    numeric_value: 401,
    description: 'Calcul automatique des réapprovisionnements',
    is_active: true,
    sequence: 1,
    created_by: 'system'
};

-- ================================================================================
-- FONCTIONS UTILITAIRES
-- ================================================================================

-- Fonction pour récupérer les types de batch par module
DEFINE FUNCTION fn::get_batch_types_by_module($module_id: string) {
    RETURN (
        SELECT * FROM batch_type 
        WHERE module = $module_id 
        AND is_active = true 
        ORDER BY sequence, name
    );
};

-- Fonction pour récupérer les types de batch par catégorie
DEFINE FUNCTION fn::get_batch_types_by_category($category: string) {
    RETURN (
        SELECT * FROM batch_type 
        WHERE category = $category 
        AND is_active = true 
        ORDER BY module, sequence, name
    );
};

-- Fonction pour récupérer un type de batch par code
DEFINE FUNCTION fn::get_batch_type_by_code($code: string) {
    RETURN (
        SELECT * FROM batch_type 
        WHERE code = $code 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour récupérer un type de batch par valeur numérique
DEFINE FUNCTION fn::get_batch_type_by_numeric($numeric_value: int) {
    RETURN (
        SELECT * FROM batch_type 
        WHERE numeric_value = $numeric_value 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour récupérer la configuration par défaut d'un type
DEFINE FUNCTION fn::get_batch_type_config($type_code: string) {
    LET $batch_type = (SELECT * FROM batch_type WHERE code = $type_code AND is_active = true LIMIT 1);
    IF $batch_type IS NONE {
        RETURN {};
    };
    RETURN $batch_type.default_config;
};

-- Fonction pour valider les paramètres d'un batch
DEFINE FUNCTION fn::validate_batch_params($type_code: string, $params: object) {
    LET $batch_type = (SELECT * FROM batch_type WHERE code = $type_code AND is_active = true LIMIT 1);
    IF $batch_type IS NONE {
        RETURN { valid: false, errors: ['Type de batch invalide'] };
    };
    
    LET $required_fields = $batch_type.type_params.required_fields;
    LET $missing_fields = [];
    
    FOR $field IN $required_fields {
        IF $params[$field] IS NONE {
            $missing_fields = array::append($missing_fields, $field);
        };
    };
    
    IF array::len($missing_fields) > 0 {
        RETURN { 
            valid: false, 
            errors: array::concat(['Champs requis manquants: '], $missing_fields)
        };
    };
    
    RETURN { valid: true, errors: [] };
}; 
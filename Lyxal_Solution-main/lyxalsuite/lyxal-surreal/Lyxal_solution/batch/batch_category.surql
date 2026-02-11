-- ================================================================================
-- Table des catégories de traitement par lot (Batch Category)
-- ================================================================================
-- DESCRIPTION: Catégories de batch universelles pour tous les modules
-- USAGE: Référence pour batch_type, classification des traitements par lot
-- ================================================================================

DEFINE TABLE batch_category SCHEMAFULL
    COMMENT "Catégories de traitement par lot universelles";

-- Code unique de la catégorie
DEFINE FIELD code ON batch_category TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code unique (ex: IMPORT, EXPORT, SCORING)";

-- Nom de la catégorie
DEFINE FIELD name ON batch_category TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la catégorie (ex: Importation, Exportation)";

-- Description détaillée
DEFINE FIELD description ON batch_category TYPE option<string>
    COMMENT "Description de la catégorie";

-- Icône pour l'interface
DEFINE FIELD icon ON batch_category TYPE string DEFAULT 'fa-cogs'
    COMMENT "Icône FontAwesome pour l'interface";

-- Couleur pour l'interface
DEFINE FIELD color ON batch_category TYPE string DEFAULT '#007bff'
    COMMENT "Couleur hexadécimale pour l'interface";

-- Catégorie parent (hiérarchie)
DEFINE FIELD parent_category ON batch_category TYPE option<record<batch_category>>
    COMMENT "Catégorie parent pour hiérarchie";

-- Niveau hiérarchique
DEFINE FIELD level ON batch_category TYPE int DEFAULT 0
    ASSERT $value >= 0 AND $value <= 3
    COMMENT "Niveau hiérarchique (0=racine, 1=sous-catégorie, etc.)";

-- Configuration par défaut pour cette catégorie
DEFINE FIELD default_config ON batch_category TYPE object VALUE {
    typical_batch_size: 100,
    typical_timeout_minutes: 60,
    auto_retry_recommended: true,
    notification_level: 'NORMAL'
} COMMENT "Configuration par défaut";

-- Paramètres spécifiques à la catégorie
DEFINE FIELD category_params ON batch_category TYPE object VALUE {
    requires_file_input: false,
    generates_output_file: false,
    supports_scheduling: true,
    supports_parallel_processing: true,
    typical_processing_time: 'MEDIUM'
} COMMENT "Paramètres spécifiques";

-- Statut actif
DEFINE FIELD is_active ON batch_category TYPE bool DEFAULT true
    COMMENT "Catégorie active";

-- Ordre d'affichage
DEFINE FIELD sequence ON batch_category TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage";

-- Métadonnées
DEFINE FIELD created_at ON batch_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON batch_category TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON batch_category TYPE option<record<user>>;
DEFINE FIELD updated_by ON batch_category TYPE option<record<user>>;
DEFINE FIELD version ON batch_category TYPE int DEFAULT 0;

-- Index pour performance
DEFINE INDEX idx_batch_category_code ON batch_category COLUMNS code UNIQUE;
DEFINE INDEX idx_batch_category_parent ON batch_category COLUMNS parent_category;
DEFINE INDEX idx_batch_category_level ON batch_category COLUMNS level;
DEFINE INDEX idx_batch_category_active ON batch_category COLUMNS is_active;
DEFINE INDEX idx_batch_category_sequence ON batch_category COLUMNS sequence;

-- ================================================================================
-- DONNÉES INITIALES - CATÉGORIES PRINCIPALES
-- ================================================================================

-- Catégories de niveau 0 (racine)
INSERT INTO batch_category {
    code: 'IMPORT',
    name: 'Importation',
    description: 'Importation de données depuis sources externes',
    icon: 'fa-download',
    color: '#28a745',
    level: 0,
    sequence: 1,
    default_config: {
        typical_batch_size: 500,
        typical_timeout_minutes: 120,
        auto_retry_recommended: true,
        notification_level: 'HIGH'
    },
    category_params: {
        requires_file_input: true,
        generates_output_file: true,
        supports_scheduling: true,
        supports_parallel_processing: true,
        typical_processing_time: 'LONG'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'EXPORT',
    name: 'Exportation',
    description: 'Exportation de données vers formats externes',
    icon: 'fa-upload',
    color: '#17a2b8',
    level: 0,
    sequence: 2,
    default_config: {
        typical_batch_size: 1000,
        typical_timeout_minutes: 90,
        auto_retry_recommended: true,
        notification_level: 'NORMAL'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: true,
        supports_scheduling: true,
        supports_parallel_processing: true,
        typical_processing_time: 'MEDIUM'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'SCORING',
    name: 'Scoring',
    description: 'Calcul de scores et évaluations automatiques',
    icon: 'fa-star',
    color: '#ffc107',
    level: 0,
    sequence: 3,
    default_config: {
        typical_batch_size: 2000,
        typical_timeout_minutes: 45,
        auto_retry_recommended: true,
        notification_level: 'NORMAL'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: false,
        supports_scheduling: true,
        supports_parallel_processing: true,
        typical_processing_time: 'FAST'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'ASSIGNMENT',
    name: 'Attribution',
    description: 'Attribution automatique de ressources',
    icon: 'fa-user-plus',
    color: '#6f42c1',
    level: 0,
    sequence: 4,
    default_config: {
        typical_batch_size: 500,
        typical_timeout_minutes: 30,
        auto_retry_recommended: true,
        notification_level: 'HIGH'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: false,
        supports_scheduling: true,
        supports_parallel_processing: false,
        typical_processing_time: 'FAST'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'FORECAST',
    name: 'Prévision',
    description: 'Génération de prévisions et analyses prédictives',
    icon: 'fa-chart-line',
    color: '#e83e8c',
    level: 0,
    sequence: 5,
    default_config: {
        typical_batch_size: 100,
        typical_timeout_minutes: 180,
        auto_retry_recommended: false,
        notification_level: 'HIGH'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: true,
        supports_scheduling: true,
        supports_parallel_processing: false,
        typical_processing_time: 'LONG'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'NOTIFICATION',
    name: 'Notification',
    description: 'Envoi de notifications et communications',
    icon: 'fa-bell',
    color: '#fd7e14',
    level: 0,
    sequence: 6,
    default_config: {
        typical_batch_size: 1000,
        typical_timeout_minutes: 60,
        auto_retry_recommended: true,
        notification_level: 'NORMAL'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: false,
        supports_scheduling: true,
        supports_parallel_processing: true,
        typical_processing_time: 'MEDIUM'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'CLEANUP',
    name: 'Nettoyage',
    description: 'Nettoyage et maintenance des données',
    icon: 'fa-broom',
    color: '#6c757d',
    level: 0,
    sequence: 7,
    default_config: {
        typical_batch_size: 5000,
        typical_timeout_minutes: 240,
        auto_retry_recommended: false,
        notification_level: 'LOW'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: true,
        supports_scheduling: true,
        supports_parallel_processing: true,
        typical_processing_time: 'LONG'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'SYNC',
    name: 'Synchronisation',
    description: 'Synchronisation avec systèmes externes',
    icon: 'fa-sync',
    color: '#20c997',
    level: 0,
    sequence: 8,
    default_config: {
        typical_batch_size: 1000,
        typical_timeout_minutes: 120,
        auto_retry_recommended: true,
        notification_level: 'HIGH'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: false,
        supports_scheduling: true,
        supports_parallel_processing: false,
        typical_processing_time: 'MEDIUM'
    },
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'REPORT',
    name: 'Rapport',
    description: 'Génération de rapports et analyses',
    icon: 'fa-file-alt',
    color: '#dc3545',
    level: 0,
    sequence: 9,
    default_config: {
        typical_batch_size: 500,
        typical_timeout_minutes: 90,
        auto_retry_recommended: true,
        notification_level: 'NORMAL'
    },
    category_params: {
        requires_file_input: false,
        generates_output_file: true,
        supports_scheduling: true,
        supports_parallel_processing: true,
        typical_processing_time: 'MEDIUM'
    },
    is_active: true,
    created_by: 'system'
};

-- ================================================================================
-- SOUS-CATÉGORIES (Niveau 1)
-- ================================================================================

-- Sous-catégories d'importation
INSERT INTO batch_category {
    code: 'IMPORT_CSV',
    name: 'Importation CSV',
    description: 'Importation depuis fichiers CSV',
    icon: 'fa-file-csv',
    color: '#28a745',
    parent_category: batch_category:import,
    level: 1,
    sequence: 1,
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'IMPORT_EXCEL',
    name: 'Importation Excel',
    description: 'Importation depuis fichiers Excel',
    icon: 'fa-file-excel',
    color: '#28a745',
    parent_category: batch_category:import,
    level: 1,
    sequence: 2,
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'IMPORT_API',
    name: 'Importation API',
    description: 'Importation depuis APIs externes',
    icon: 'fa-plug',
    color: '#28a745',
    parent_category: batch_category:import,
    level: 1,
    sequence: 3,
    is_active: true,
    created_by: 'system'
};

-- Sous-catégories de scoring
INSERT INTO batch_category {
    code: 'SCORING_AI',
    name: 'Scoring IA',
    description: 'Scoring utilisant l\'intelligence artificielle',
    icon: 'fa-robot',
    color: '#ffc107',
    parent_category: batch_category:scoring,
    level: 1,
    sequence: 1,
    is_active: true,
    created_by: 'system'
};

INSERT INTO batch_category {
    code: 'SCORING_RULE',
    name: 'Scoring par règles',
    description: 'Scoring basé sur des règles prédéfinies',
    icon: 'fa-list-ul',
    color: '#ffc107',
    parent_category: batch_category:scoring,
    level: 1,
    sequence: 2,
    is_active: true,
    created_by: 'system'
};

-- ================================================================================
-- FONCTIONS UTILITAIRES
-- ================================================================================

-- Fonction pour récupérer les catégories actives
DEFINE FUNCTION fn::get_active_batch_categories() {
    RETURN (
        SELECT * FROM batch_category 
        WHERE is_active = true 
        ORDER BY level, sequence, name
    );
};

-- Fonction pour récupérer les catégories par niveau
DEFINE FUNCTION fn::get_batch_categories_by_level($level: int) {
    RETURN (
        SELECT * FROM batch_category 
        WHERE is_active = true 
        AND level = $level
        ORDER BY sequence, name
    );
};

-- Fonction pour récupérer les sous-catégories d'une catégorie parent
DEFINE FUNCTION fn::get_batch_subcategories($parent_id: string) {
    RETURN (
        SELECT * FROM batch_category 
        WHERE is_active = true 
        AND parent_category = $parent_id
        ORDER BY sequence, name
    );
};

-- Fonction pour récupérer la hiérarchie complète d'une catégorie
DEFINE FUNCTION fn::get_batch_category_hierarchy($category_id: string) {
    LET $category = (SELECT * FROM batch_category WHERE id = $category_id LIMIT 1);
    IF $category IS NONE {
        RETURN [];
    };
    
    LET $hierarchy = [$category];
    LET $current = $category;
    
    WHILE $current.parent_category IS NOT NONE {
        LET $parent = (SELECT * FROM batch_category WHERE id = $current.parent_category LIMIT 1);
        IF $parent IS NONE {
            BREAK;
        };
        $hierarchy = array::prepend($hierarchy, $parent);
        $current = $parent;
    };
    
    RETURN $hierarchy;
};

-- Fonction pour récupérer une catégorie par code
DEFINE FUNCTION fn::get_batch_category_by_code($code: string) {
    RETURN (
        SELECT * FROM batch_category 
        WHERE code = $code 
        AND is_active = true
        LIMIT 1
    );
};

-- Fonction pour récupérer la configuration par défaut d'une catégorie
DEFINE FUNCTION fn::get_batch_category_config($category_code: string) {
    LET $category = (SELECT * FROM batch_category WHERE code = $category_code AND is_active = true LIMIT 1);
    IF $category IS NONE {
        RETURN {};
    };
    RETURN $category.default_config;
};

-- Fonction pour vérifier si une catégorie supporte une fonctionnalité
DEFINE FUNCTION fn::batch_category_supports($category_code: string, $feature: string) {
    LET $category = (SELECT * FROM batch_category WHERE code = $category_code AND is_active = true LIMIT 1);
    IF $category IS NONE {
        RETURN false;
    };
    RETURN $category.category_params[$feature] OR false;
}; 
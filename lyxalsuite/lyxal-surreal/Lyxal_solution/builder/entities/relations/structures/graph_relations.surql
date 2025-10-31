-- ================================================================================
-- RELATIONS GRAPH - Architecture native pour génération SaaS COMPLÈTE
-- ================================================================================
-- DESCRIPTION: Relations intelligentes pour navigation IA et génération de variants
-- USAGE: Permet analyse complète et rapide des interdépendances templates SaaS
-- ================================================================================

-- ================================================================================
-- RELATION : HIÉRARCHIE ORGANISATIONNELLE
-- ================================================================================

DEFINE TABLE contains RELATION SCHEMAFULL
    COMMENT "Hiérarchie module->sous_module->table->field"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON contains TYPE record;  -- Source (module, sub_module, table)
DEFINE FIELD out ON contains TYPE record; -- Destination (sub_module, table, field)
DEFINE FIELD hierarchy_level ON contains TYPE int DEFAULT 0; -- 0=module->sub, 1=sub->table, 2=table->field
DEFINE FIELD is_core ON contains TYPE bool DEFAULT false; -- Élément core vs variant
DEFINE FIELD saas_contexts ON contains TYPE array<string> DEFAULT []; -- ['crm', 'ecommerce', 'finance']

-- ================================================================================
-- RELATION : DÉPENDANCES FONCTIONNELLES
-- ================================================================================

DEFINE TABLE uses RELATION SCHEMAFULL
    COMMENT "Dépendances entre fonctions et tables"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON uses TYPE record<table_functions>;
DEFINE FIELD out ON uses TYPE record<table_tables>;
DEFINE FIELD access_type ON uses TYPE record<system_access_types_graph> DEFAULT system_access_types_graph:read_write
    COMMENT 'Type d accès aux données (référence)';
DEFINE FIELD frequency ON uses TYPE record<system_usage_frequencies> DEFAULT system_usage_frequencies:medium
    COMMENT 'Fréquence d utilisation (référence)';
DEFINE FIELD performance_impact ON uses TYPE decimal DEFAULT 1.0; -- Multiplicateur performance
DEFINE FIELD is_required ON uses TYPE bool DEFAULT true; -- Dépendance obligatoire
DEFINE FIELD saas_variants ON uses TYPE array<string> DEFAULT []; -- Dans quels variants SaaS

-- ================================================================================
-- RELATION : OPTIMISATION PERFORMANCE
-- ================================================================================

DEFINE TABLE optimized_by RELATION SCHEMAFULL
    COMMENT "Optimisations index/requêtes"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON optimized_by TYPE record; -- table_tables ou table_functions
DEFINE FIELD out ON optimized_by TYPE record<table_indexes>;
DEFINE FIELD performance_gain ON optimized_by TYPE decimal; -- % gain performance
DEFINE FIELD query_pattern ON optimized_by TYPE string; -- Pattern de requête optimisé
DEFINE FIELD usage_context ON optimized_by TYPE array<string> DEFAULT []; -- Contextes d'usage

-- ================================================================================
-- RELATION : RÉFÉRENCES ENTRE CHAMPS
-- ================================================================================

DEFINE TABLE references RELATION SCHEMAFULL
    COMMENT "Relations FK et autres références"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON references TYPE record<table_fields>; -- Champ source
DEFINE FIELD out ON references TYPE record<table_fields>; -- Champ cible
DEFINE FIELD reference_type ON references TYPE record<system_reference_types> DEFAULT system_reference_types:foreign_key
    COMMENT 'Type de référence (référence)';
DEFINE FIELD cascade_behavior ON references TYPE record<system_cascade_behaviors> DEFAULT system_cascade_behaviors:restrict
    COMMENT 'Comportement en cascade (référence)';
DEFINE FIELD is_enforced ON references TYPE bool DEFAULT true;

-- ================================================================================
-- RELATION : DÉCLENCHEMENT D'ÉVÉNEMENTS
-- ================================================================================

DEFINE TABLE triggers RELATION SCHEMAFULL
    COMMENT "Événements déclenchés par actions"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON triggers TYPE record; -- Source du trigger (table, function)
DEFINE FIELD out ON triggers TYPE record<table_events>; -- Événement déclenché
DEFINE FIELD trigger_condition ON triggers TYPE string; -- Condition de déclenchement
DEFINE FIELD execution_order ON triggers TYPE int DEFAULT 0; -- Ordre d'exécution
DEFINE FIELD is_async ON triggers TYPE bool DEFAULT false;

-- ================================================================================
-- RELATION : VARIANTS SAAS
-- ================================================================================

DEFINE TABLE variant_of RELATION SCHEMAFULL
    COMMENT "Relations entre éléments core et variants SaaS"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON variant_of TYPE record; -- Élément variant
DEFINE FIELD out ON variant_of TYPE record; -- Élément core/base
DEFINE FIELD variant_type ON variant_of TYPE record<system_variant_types> DEFAULT system_variant_types:extension
    COMMENT 'Type de variant (référence)';
DEFINE FIELD saas_context ON variant_of TYPE string; -- 'crm_medical', 'ecommerce_b2b', etc.
DEFINE FIELD inheritance_level ON variant_of TYPE decimal DEFAULT 1.0; -- % héritage du core

-- ================================================================================
-- RELATION : COMPATIBILITÉ ENTRE VARIANTS
-- ================================================================================

DEFINE TABLE compatible_with RELATION SCHEMAFULL
    COMMENT "Compatibilité entre variants SaaS"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON compatible_with TYPE record; -- Variant A
DEFINE FIELD out ON compatible_with TYPE record; -- Variant B  
DEFINE FIELD compatibility_level ON compatible_with TYPE decimal; -- 0-1 niveau compatibilité
DEFINE FIELD migration_complexity ON compatible_with TYPE record<system_migration_complexities> DEFAULT system_migration_complexities:moderate
    COMMENT 'Complexité de migration (référence)';
DEFINE FIELD shared_components ON compatible_with TYPE array<string> DEFAULT [];

-- ================================================================================
-- RELATION : GÉNÉRATION DE CODE
-- ================================================================================

DEFINE TABLE generates RELATION SCHEMAFULL
    COMMENT "Éléments qui génèrent du code"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON generates TYPE record; -- Source (table, function, etc.)
DEFINE FIELD out ON generates TYPE string; -- Type de code généré
DEFINE FIELD generation_template ON generates TYPE string; -- Template utilisé
DEFINE FIELD target_contexts ON generates TYPE array<string> DEFAULT []; -- Contextes cibles
DEFINE FIELD generation_priority ON generates TYPE int DEFAULT 0;

-- ================================================================================
-- RELATION : IMPACT D'ANALYSE
-- ================================================================================

DEFINE TABLE impacts RELATION SCHEMAFULL
    COMMENT "Impact des changements sur autres éléments"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON impacts TYPE record; -- Élément modifié
DEFINE FIELD out ON impacts TYPE record; -- Élément impacté
DEFINE FIELD impact_type ON impacts TYPE record<system_impact_types> DEFAULT system_impact_types:non_breaking
    COMMENT 'Type d impact (référence)';
DEFINE FIELD impact_severity ON impacts TYPE record<system_severity_levels> DEFAULT system_severity_levels:low
    COMMENT 'Sévérité de l impact (référence)';
DEFINE FIELD auto_migration ON impacts TYPE bool DEFAULT false; -- Migration automatique possible

-- ================================================================================
-- NOUVELLES RELATIONS : COUVERTURE COMPLÈTE TEMPLATES SAAS
-- ================================================================================

-- ================================================================================
-- RELATION : ANALYSE TEXTUELLE
-- ================================================================================

DEFINE TABLE analyzes RELATION SCHEMAFULL
    COMMENT "Champs analysés par des analyzers pour recherche textuelle"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON analyzes TYPE record<table_analyzers>; -- Analyzer utilisé
DEFINE FIELD out ON analyzes TYPE record<table_fields>; -- Champ analysé
DEFINE FIELD analysis_type ON analyzes TYPE string DEFAULT "full_text"; -- Type d'analyse
DEFINE FIELD search_weight ON analyzes TYPE decimal DEFAULT 1.0; -- Poids dans recherche
DEFINE FIELD language_specific ON analyzes TYPE bool DEFAULT false; -- Analyse spécifique langue

-- ================================================================================
-- RELATION : EXPOSITION API
-- ================================================================================

DEFINE TABLE exposes RELATION SCHEMAFULL
    COMMENT "Fonctions exposées par des endpoints API"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON exposes TYPE record<table_apis>; -- API endpoint
DEFINE FIELD out ON exposes TYPE record<table_functions>; -- Fonction exposée
DEFINE FIELD http_method ON exposes TYPE record<system_http_methods> DEFAULT system_http_methods:post
    COMMENT 'Méthode HTTP (référence)';
DEFINE FIELD is_public ON exposes TYPE bool DEFAULT false; -- Endpoint public
DEFINE FIELD rate_limit ON exposes TYPE int DEFAULT 1000; -- Limite requêtes/heure

-- ================================================================================
-- RELATION : STOCKAGE FICHIERS
-- ================================================================================

DEFINE TABLE stores RELATION SCHEMAFULL
    COMMENT "Champs stockant des fichiers dans des buckets"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON stores TYPE record<table_buckets>; -- Bucket de stockage
DEFINE FIELD out ON stores TYPE record<table_fields>; -- Champ fichier
DEFINE FIELD file_types ON stores TYPE array<string> DEFAULT []; -- Types fichiers autorisés
DEFINE FIELD max_file_size ON stores TYPE string DEFAULT "10MB"; -- Taille max
DEFINE FIELD compression_enabled ON stores TYPE bool DEFAULT false; -- Compression

-- ================================================================================
-- RELATION : PARAMÉTRAGE
-- ================================================================================

DEFINE TABLE configures RELATION SCHEMAFULL
    COMMENT "Paramètres utilisés par fonctions et APIs"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON configures TYPE record<table_params>; -- Paramètre global
DEFINE FIELD out ON configures TYPE record; -- Function ou API utilisant le paramètre
DEFINE FIELD is_required_param ON configures TYPE bool DEFAULT true; -- Paramètre obligatoire
DEFINE FIELD default_override ON configures TYPE string; -- Valeur par défaut spécifique
DEFINE FIELD param_scope ON configures TYPE string DEFAULT "global"; -- Portée du paramètre

-- ================================================================================
-- RELATION : NUMÉROTATION AUTOMATIQUE
-- ================================================================================

DEFINE TABLE numbers RELATION SCHEMAFULL
    COMMENT "Séquences générant des identifiants pour tables"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON numbers TYPE record<table_sequences>; -- Séquence
DEFINE FIELD out ON numbers TYPE record<table_tables>; -- Table utilisant la séquence
DEFINE FIELD target_field ON numbers TYPE string DEFAULT "id"; -- Champ cible
DEFINE FIELD sequence_pattern ON numbers TYPE string; -- Pattern numérotation (ex: "INV-{YYYY}-{####}")
DEFINE FIELD reset_frequency ON numbers TYPE string DEFAULT "never"; -- Fréquence reset

-- ================================================================================
-- RELATION : PROTECTION SÉCURITÉ
-- ================================================================================

DEFINE TABLE secures RELATION SCHEMAFULL
    COMMENT "Méthodes d'accès protégeant tables et APIs"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON secures TYPE record<table_access>; -- Méthode d'authentification
DEFINE FIELD out ON secures TYPE record; -- Table ou API protégée
DEFINE FIELD permission_level ON secures TYPE record<system_permission_types> DEFAULT system_permission_types:read
    COMMENT 'Niveau de permission (référence)';
DEFINE FIELD is_mandatory ON secures TYPE bool DEFAULT true; -- Protection obligatoire
DEFINE FIELD bypass_conditions ON secures TYPE array<string> DEFAULT []; -- Conditions contournement

-- ================================================================================
-- RELATION : INCLUSION TEMPLATE
-- ================================================================================

DEFINE TABLE includes RELATION SCHEMAFULL
    COMMENT "Templates SaaS incluant leurs composants"
    PERMISSIONS 
    FOR select FULL
    FOR create, update, delete WHERE $auth.role CONTAINS 'super_admin'
        OR $auth.permissions CONTAINS 'system_metadata:write';

DEFINE FIELD in ON includes TYPE record<templates_saas>; -- Template SaaS
DEFINE FIELD out ON includes TYPE record; -- Composant inclus (table, function, etc.)
DEFINE FIELD inclusion_type ON includes TYPE string DEFAULT "core"; -- core, optional, variant
DEFINE FIELD priority_order ON includes TYPE int DEFAULT 0; -- Ordre d'installation
DEFINE FIELD customization_level ON includes TYPE decimal DEFAULT 0.0; -- Niveau personnalisation autorisé

-- ================================================================================
-- INDEX OPTIMISÉS POUR IA (TOUS CORRIGÉS)
-- ================================================================================

-- Index hiérarchie
DEFINE INDEX idx_contains_hierarchy ON contains FIELDS hierarchy_level, is_core;
DEFINE INDEX idx_contains_saas ON contains FIELDS saas_contexts;

-- Index dépendances
DEFINE INDEX idx_uses_access_type ON uses FIELDS access_type, frequency;
DEFINE INDEX idx_uses_variants ON uses FIELDS saas_variants;
DEFINE INDEX idx_uses_required ON uses FIELDS is_required;

-- Index optimisation
DEFINE INDEX idx_optimized_gain ON optimized_by FIELDS performance_gain;
DEFINE INDEX idx_optimized_context ON optimized_by FIELDS usage_context;

-- Index références
DEFINE INDEX idx_references_type ON references FIELDS reference_type;
DEFINE INDEX idx_references_enforced ON references FIELDS is_enforced;

-- Index variants
DEFINE INDEX idx_variant_context ON variant_of FIELDS saas_context;
DEFINE INDEX idx_variant_type ON variant_of FIELDS variant_type;
DEFINE INDEX idx_variant_inheritance ON variant_of FIELDS inheritance_level;

-- Index compatibilité
DEFINE INDEX idx_compatible_level ON compatible_with FIELDS compatibility_level;
DEFINE INDEX idx_compatible_migration ON compatible_with FIELDS migration_complexity;

-- Index génération
DEFINE INDEX idx_generates_target ON generates FIELDS target_contexts;
DEFINE INDEX idx_generates_priority ON generates FIELDS generation_priority;

-- Index impact
DEFINE INDEX idx_impacts_type ON impacts FIELDS impact_type, impact_severity;
DEFINE INDEX idx_impacts_migration ON impacts FIELDS auto_migration;

-- Index nouvelles relations
DEFINE INDEX idx_analyzes_type ON analyzes FIELDS analysis_type;
DEFINE INDEX idx_analyzes_language ON analyzes FIELDS language_specific;

DEFINE INDEX idx_exposes_method ON exposes FIELDS http_method;
DEFINE INDEX idx_exposes_public ON exposes FIELDS is_public;

DEFINE INDEX idx_stores_types ON stores FIELDS file_types;
DEFINE INDEX idx_stores_compression ON stores FIELDS compression_enabled;

DEFINE INDEX idx_configures_required ON configures FIELDS is_required_param;
DEFINE INDEX idx_configures_scope ON configures FIELDS param_scope;

DEFINE INDEX idx_numbers_field ON numbers FIELDS target_field;
DEFINE INDEX idx_numbers_pattern ON numbers FIELDS sequence_pattern;

DEFINE INDEX idx_secures_permission ON secures FIELDS permission_level;
DEFINE INDEX idx_secures_mandatory ON secures FIELDS is_mandatory;

DEFINE INDEX idx_includes_type ON includes FIELDS inclusion_type;
DEFINE INDEX idx_includes_priority ON includes FIELDS priority_order;
-- =============================================================================================
-- |
-- | Fichier : response_mapping.surql
-- | Module : integrations > database > response_mapping
-- | Description : Configuration du mapping/transformation des réponses API
-- |
-- | Cette table configure comment transformer les réponses API brutes en données
-- | structurées utilisables par l'UI et l'IA. Les transformations sont basées sur
-- | les patterns identifiés dans n8n (extract_field, extract_array, transform, etc.).
-- |
-- | Architecture:
-- | • Champs à PLAT : tool_id, is_active (pour index/recherche)
-- | • Champs GROUPÉS : identity, config, metadata
-- |
-- | Tables référencées:
-- | • tool : Tools utilisés
-- | • service : Services (dérivé du tool)
-- |
-- | Patterns supportés:
-- | • raw : Retour brut sans transformation
-- | • extract_field : Extraire un sous-objet (ex: response.channel)
-- | • extract_array : Extraire un tableau (ex: response.items)
-- | • transform : Transformation complète avec mapping de champs
-- | • paginated : Gestion de pagination
-- | • multi_extract : Extraction multiple de champs
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS response_mapping TYPE NORMAL SCHEMAFULL
COMMENT 'Configuration du mapping/transformation des réponses API - Transforme les réponses brutes en données structurées.'
PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.role IN ["admin", "editor"];

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS tool_id ON response_mapping 
    TYPE record<tool>
    ASSERT $value != NONE
    COMMENT 'Tool associé à ce mapping.';

DEFINE FIELD IF NOT EXISTS service_id ON response_mapping 
    TYPE option<record<service>>
    COMMENT 'Service (dérivé du tool, pour recherche rapide).';

DEFINE FIELD IF NOT EXISTS is_active ON response_mapping 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si le mapping est actif.';

-- =====================================================
-- OBJET: identity (Identification du mapping)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON response_mapping 
    TYPE object
    COMMENT 'Identification du mapping.';

DEFINE FIELD IF NOT EXISTS identity.mapping_type ON response_mapping 
    TYPE string
    ASSERT $value IN ['raw', 'extract_field', 'extract_array', 'transform', 'paginated', 'multi_extract']
    COMMENT 'Type de mapping: raw, extract_field, extract_array, transform, paginated, multi_extract.';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON response_mapping 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description multilingue du mapping.';

-- =====================================================
-- OBJET: config (Configuration du mapping)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON response_mapping 
    TYPE object
    COMMENT 'Configuration du mapping.';

-- Extraction
DEFINE FIELD IF NOT EXISTS config.source_path ON response_mapping 
    TYPE option<string>
    COMMENT 'Chemin JSON vers les données (ex: "channel", "data.items", "result.users").';

DEFINE FIELD IF NOT EXISTS config.fields_to_keep ON response_mapping 
    TYPE option<array<string>>
    COMMENT 'Champs à conserver (ex: ["id", "name", "email"]). Si NONE, tous les champs sont conservés.';

DEFINE FIELD IF NOT EXISTS config.fields_to_remove ON response_mapping 
    TYPE option<array<string>>
    COMMENT 'Champs à supprimer (ex: ["internal_id", "debug_info", "sensitive_data"]).';

-- Transformations
DEFINE FIELD IF NOT EXISTS config.field_transformations ON response_mapping 
    TYPE option<array<object>>
    COMMENT 'Transformations de champs. Format: [{from: "ts", to: "timestamp", type: "unix_to_datetime"}, ...]';

DEFINE FIELD IF NOT EXISTS config.field_transformations.from ON response_mapping 
    TYPE option<string>
    COMMENT 'Nom du champ source.';

DEFINE FIELD IF NOT EXISTS config.field_transformations.to ON response_mapping 
    TYPE option<string>
    COMMENT 'Nom du champ cible.';

DEFINE FIELD IF NOT EXISTS config.field_transformations.type ON response_mapping 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['unix_to_datetime', 'datetime_to_unix', 'string_to_number', 'number_to_string', 'uppercase', 'lowercase', 'capitalize', 'json_parse', 'json_stringify']
    COMMENT 'Type de transformation: unix_to_datetime, datetime_to_unix, string_to_number, number_to_string, uppercase, lowercase, capitalize, json_parse, json_stringify.';

-- Pagination
DEFINE FIELD IF NOT EXISTS config.pagination ON response_mapping 
    TYPE option<object>
    COMMENT 'Configuration de pagination.';

DEFINE FIELD IF NOT EXISTS config.pagination.enabled ON response_mapping 
    TYPE bool
    DEFAULT false
    COMMENT 'Si la pagination est activée.';

DEFINE FIELD IF NOT EXISTS config.pagination.cursor_path ON response_mapping 
    TYPE option<string>
    COMMENT 'Chemin JSON vers le cursor (ex: "pagination.next_cursor", "meta.next_page_token").';

DEFINE FIELD IF NOT EXISTS config.pagination.items_path ON response_mapping 
    TYPE option<string>
    COMMENT 'Chemin JSON vers les items (ex: "data.items", "result.users").';

DEFINE FIELD IF NOT EXISTS config.pagination.has_more_indicator ON response_mapping 
    TYPE option<string>
    COMMENT 'Champ indiquant s\'il y a plus de résultats (ex: "has_more", "is_truncated").';

DEFINE FIELD IF NOT EXISTS config.pagination.total_count_path ON response_mapping 
    TYPE option<string>
    COMMENT 'Chemin JSON vers le total (ex: "pagination.total", "meta.total_count").';

-- Multi-extract (pour extraire plusieurs champs de différents chemins)
DEFINE FIELD IF NOT EXISTS config.multi_extract ON response_mapping 
    TYPE option<array<object>>
    COMMENT 'Configuration pour extraction multiple. Format: [{path: "users", keep: ["id", "name"]}, {path: "metadata", keep: ["total"]}]';

DEFINE FIELD IF NOT EXISTS config.multi_extract.path ON response_mapping 
    TYPE option<string>
    COMMENT 'Chemin JSON vers les données à extraire.';

DEFINE FIELD IF NOT EXISTS config.multi_extract.keep ON response_mapping 
    TYPE option<array<string>>
    COMMENT 'Champs à conserver depuis ce chemin.';

DEFINE FIELD IF NOT EXISTS config.multi_extract.as ON response_mapping 
    TYPE option<string>
    COMMENT 'Nom de la clé pour stocker le résultat (ex: "users", "metadata").';

-- =====================================================
-- OBJET: metadata (Métadonnées système)
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON response_mapping 
    TYPE object
    COMMENT 'Métadonnées système.';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON response_mapping 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON response_mapping 
    TYPE datetime
    DEFAULT ALWAYS time::now()
    READONLY
    COMMENT 'Date de dernière modification.';

DEFINE FIELD IF NOT EXISTS metadata.version ON response_mapping 
    TYPE int
    DEFAULT 1
    COMMENT 'Version du mapping.';

DEFINE FIELD IF NOT EXISTS metadata.created_by ON response_mapping 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Utilisateur ayant créé le mapping.';

DEFINE FIELD IF NOT EXISTS metadata.updated_by ON response_mapping 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Utilisateur ayant modifié le mapping.';

-- =====================================================
-- CHAMPS: ETAG
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON response_mapping 
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking et Live Queries. Change à chaque modification.';

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX IF NOT EXISTS idx_response_mapping_tool ON response_mapping 
    FIELDS tool_id, is_active
    COMMENT 'Index pour récupération rapide par tool.';

DEFINE INDEX IF NOT EXISTS idx_response_mapping_service ON response_mapping 
    FIELDS service_id, is_active
    COMMENT 'Index pour recherche par service.';

DEFINE INDEX IF NOT EXISTS idx_response_mapping_type ON response_mapping 
    FIELDS identity.mapping_type
    COMMENT 'Index pour filtrage par type de mapping.';

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Mapping simple - Extraire un champ (Slack Create Channel)
/*
CREATE response_mapping SET
    tool_id = tool:slack_channel_create,
    service_id = service:slack,
    is_active = true,
    
    identity = {
        mapping_type: "extract_field",
        description_i18n: i18n_key:response_mapping_slack_channel_create_desc
    },
    
    config = {
        source_path: "channel",
        fields_to_keep: ["id", "name", "is_private", "created"],
        fields_to_remove: NONE,
        field_transformations: [
            {from: "created", to: "created_at", type: "unix_to_datetime"}
        ],
        pagination: NONE,
        multi_extract: NONE
    },
    
    metadata = {
        created_at: time::now(),
        updated_at: time::now(),
        version: 1
    };
*/

-- EXEMPLE 2: Mapping avec pagination (Slack List Channels)
/*
CREATE response_mapping SET
    tool_id = tool:slack_channel_list,
    service_id = service:slack,
    is_active = true,
    
    identity = {
        mapping_type: "paginated",
        description_i18n: i18n_key:response_mapping_slack_channel_list_desc
    },
    
    config = {
        source_path: NONE,
        fields_to_keep: ["id", "name", "is_private"],
        fields_to_remove: ["is_archived", "internal_id"],
        field_transformations: NONE,
        pagination: {
            enabled: true,
            cursor_path: "response_metadata.next_cursor",
            items_path: "channels",
            has_more_indicator: "response_metadata.next_cursor",
            total_count_path: NONE
        },
        multi_extract: NONE
    },
    
    metadata = {
        created_at: time::now(),
        updated_at: time::now(),
        version: 1
    };
*/

-- EXEMPLE 3: Mapping transform complet (GitHub Create Issue)
/*
CREATE response_mapping SET
    tool_id = tool:github_issue_create,
    service_id = service:github,
    is_active = true,
    
    identity = {
        mapping_type: "transform",
        description_i18n: i18n_key:response_mapping_github_issue_create_desc
    },
    
    config = {
        source_path: NONE,
        fields_to_keep: ["id", "number", "title", "body", "state", "html_url", "created_at", "updated_at"],
        fields_to_remove: ["user", "labels", "assignees", "milestone"],
        field_transformations: [
            {from: "created_at", to: "created_at", type: "string_to_datetime"},
            {from: "updated_at", to: "updated_at", type: "string_to_datetime"}
        ],
        pagination: NONE,
        multi_extract: NONE
    },
    
    metadata = {
        created_at: time::now(),
        updated_at: time::now(),
        version: 1
    };
*/

-- EXEMPLE 4: Mapping multi-extract (API retournant plusieurs objets)
/*
CREATE response_mapping SET
    tool_id = tool:custom_api_complex,
    service_id = service:custom_api,
    is_active = true,
    
    identity = {
        mapping_type: "multi_extract",
        description_i18n: i18n_key:response_mapping_custom_api_complex_desc
    },
    
    config = {
        source_path: NONE,
        fields_to_keep: NONE,
        fields_to_remove: NONE,
        field_transformations: NONE,
        pagination: NONE,
        multi_extract: [
            {path: "users", keep: ["id", "name", "email"], as: "users"},
            {path: "metadata", keep: ["total", "page"], as: "pagination"}
        ]
    },
    
    metadata = {
        created_at: time::now(),
        updated_at: time::now(),
        version: 1
    };
*/

-- EXEMPLE 5: Requête - Récupérer le mapping d'un tool
/*
SELECT * FROM response_mapping
WHERE tool_id = tool:slack_channel_create
AND is_active = true
LIMIT 1;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. MAPPING_TYPES:
--    - raw: Pas de transformation, retourne la réponse brute
--    - extract_field: Extrait un sous-objet (ex: response.channel)
--    - extract_array: Extrait un tableau (ex: response.items)
--    - transform: Transformation complète avec mapping de champs
--    - paginated: Gestion de pagination avec cursor/items
--    - multi_extract: Extraction multiple de champs de différents chemins

-- 2. SOURCE_PATH:
--    Utilise la notation pointée pour naviguer dans le JSON:
--    - "channel" → response.channel
--    - "data.items" → response.data.items
--    - "result.users[0]" → response.result.users[0]

-- 3. FIELD_TRANSFORMATIONS:
--    Transformations disponibles:
--    - unix_to_datetime: Convertit timestamp Unix en datetime
--    - datetime_to_unix: Convertit datetime en timestamp Unix
--    - string_to_number: Convertit string en number
--    - number_to_string: Convertit number en string
--    - uppercase, lowercase, capitalize: Transformations de casse
--    - json_parse: Parse une string JSON en objet
--    - json_stringify: Stringify un objet en JSON

-- 4. PAGINATION:
--    Supporte les différents patterns de pagination:
--    - Cursor-based: cursor_path pointe vers le cursor suivant
--    - Offset-based: Utiliser pagination.offset_path
--    - Page-based: Utiliser pagination.page_path

-- 5. PERFORMANCE:
--    Les mappings sont appliqués côté application après réception de la réponse API.
--    Pour optimiser, utiliser fields_to_keep pour limiter les données traitées.

-- =============================================================================================
-- FIN DU FICHIER response_mapping.surql
-- =============================================================================================


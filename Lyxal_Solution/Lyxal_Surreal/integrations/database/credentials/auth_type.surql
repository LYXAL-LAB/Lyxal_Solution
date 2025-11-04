-- =============================================================================================
-- |
-- | Fichier : auth_type.surql
-- | Module : integrations > credentials
-- | Description : Table de référence des types d'authentification supportés.
-- |
-- | Cette table définit tous les types d'authentification disponibles dans le système.
-- | Structure GROUPÉE pour optimiser les cas d'usage :
-- | • UI : Récupération ciblée des données de présentation
-- | • IA : Accès direct aux métadonnées de documentation
-- | • Humain : Structure claire et organisée
-- |
-- | Architecture:
-- | • Champs à PLAT : name, slug, is_active (pour index/recherche/unicité)
-- | • Champs GROUPÉS : identity, presentation, quality, config, http, behavior, docs
-- |
-- | Tables référencées:
-- | • i18n_key : Clés de traduction pour l'internationalisation (UI multilingue)
-- | • provider : Fournisseurs d'API référencés (ex: Google, GitHub, Slack)
-- | • url : URLs normalisées pour faciliter la maintenance et le suivi
-- | • icon : Icônes normalisées pour l'UI
-- | • transmission_method : Méthodes de transmission HTTP (header, query, body, custom)
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Events pour régénération automatique de l'ETag et updated_at
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |   (voir: integrations/documentation/webhook/WEBSOCKET_CREDENTIALS.md)
-- | • Optimistic locking pour éviter les conflits de mise à jour
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS auth_type TYPE NORMAL SCHEMAFULL
COMMENT 'Référentiel des types d\'authentification (OAuth2, API Key, etc.).'
PERMISSIONS
FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE;

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS name ON auth_type TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Nom technique unique du type (ex: oauth2, apiKey).';

DEFINE FIELD IF NOT EXISTS slug ON auth_type 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0 AND 
    string::matches($value, '^[a-z0-9-]+$')
    COMMENT 'Slug unique pour URL et recherche (ex: oauth2, api-key).';

DEFINE FIELD IF NOT EXISTS is_active ON auth_type 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si ce type est actif et utilisable.';

-- =====================================================
-- OBJET: identity (Informations d'identification)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON auth_type 
    TYPE object
    COMMENT 'Informations d\'identification et description du type.';

DEFINE FIELD IF NOT EXISTS identity.display_name_i18n ON auth_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom affiché multilingue.';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON auth_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour la description multilingue.';

-- =====================================================
-- OBJET: presentation (Éléments visuels pour UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON auth_type 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.icon ON auth_type 
    TYPE record<icon>
    REFERENCE ON DELETE REJECT
    COMMENT 'Icône représentative du type d\'authentification.';

DEFINE FIELD IF NOT EXISTS presentation.color_type ON auth_type 
    TYPE record<theme_color_type>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de couleur pour les tags/badges dans l\'UI 
    (référence vers theme_color_type: primary, error, warning, etc.).';

DEFINE FIELD IF NOT EXISTS presentation.tooltip ON auth_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n du tooltip pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON auth_type 
    TYPE int
    DEFAULT 999
    COMMENT 'Ordre d\'affichage dans l\'UI (plus petit = plus haut).';

-- =====================================================
-- OBJET: quality (Métriques de qualité et recommandation)
-- =====================================================

DEFINE FIELD IF NOT EXISTS quality ON auth_type 
    TYPE object
    COMMENT 'Métriques de qualité, sécurité et recommandation.';

DEFINE FIELD IF NOT EXISTS quality.security_level ON auth_type 
    TYPE int
    ASSERT $value >= 1 AND $value <= 5
    DEFAULT 3
    COMMENT 'Niveau de sécurité (1=faible, 5=très élevé).';

DEFINE FIELD IF NOT EXISTS quality.popularity_score ON auth_type 
    TYPE int
    ASSERT $value >= 0 AND $value <= 100
    DEFAULT 50
    COMMENT 'Score de popularité (0-100).';

DEFINE FIELD IF NOT EXISTS quality.implementation_complexity ON auth_type 
    TYPE int
    ASSERT $value >= 1 AND $value <= 5
    DEFAULT 3
    COMMENT 'Complexité d\'implémentation (1=simple, 5=complexe).';

-- =====================================================
-- OBJET: config (Configuration et templates)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON auth_type 
    TYPE object
    COMMENT 'Schémas et templates de configuration.';

DEFINE FIELD IF NOT EXISTS config.schema ON auth_type 
    TYPE option<object>
    COMMENT 'Schéma de configuration attendu (fields required/optional).';

DEFINE FIELD IF NOT EXISTS config.template ON auth_type 
    TYPE option<object>
    COMMENT 'Template de configuration par défaut.';

DEFINE FIELD IF NOT EXISTS config.credential_fields_template ON auth_type 
    TYPE option<array<object>>
    COMMENT 'Template des champs de credentials requis.';

-- =====================================================
-- OBJET: http (Configuration HTTP)
-- =====================================================

DEFINE FIELD IF NOT EXISTS http ON auth_type TYPE object
    COMMENT 'Configuration HTTP pour l\'authentification.';

DEFINE FIELD IF NOT EXISTS http.typical_headers ON auth_type TYPE option<object>
    COMMENT 'Headers HTTP typiques (ex: Authorization: Bearer).';

DEFINE FIELD IF NOT EXISTS http.transmission_method ON auth_type 
    TYPE record<transmission_method>
    REFERENCE ON DELETE REJECT
    COMMENT 'Méthode de transmission HTTP (référence vers transmission_method).';

-- =====================================================
-- OBJET: behavior (Comportement et capacités)
-- =====================================================

DEFINE FIELD IF NOT EXISTS behavior ON auth_type TYPE object
    COMMENT 'Comportement et capacités du type d\'authentification.';

DEFINE FIELD IF NOT EXISTS behavior.supports_refresh ON auth_type 
    TYPE bool
    DEFAULT false
    COMMENT 'Support du refresh token.';

DEFINE FIELD IF NOT EXISTS behavior.requires_user_interaction ON auth_type 
    TYPE bool
    DEFAULT false
    COMMENT 'Nécessite une interaction utilisateur.';

DEFINE FIELD IF NOT EXISTS behavior.typical_validity_duration ON auth_type 
    TYPE option<int>
    COMMENT 'Durée de validité typique en secondes (NULL si illimité).';

-- =====================================================
-- OBJET: documentation (Documentation complète)
-- =====================================================

DEFINE FIELD IF NOT EXISTS documentation ON auth_type 
    TYPE object
    COMMENT 'Documentation complète du type pour IA et développeurs.';

DEFINE FIELD IF NOT EXISTS documentation.url ON auth_type 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de documentation technique.';

DEFINE FIELD IF NOT EXISTS documentation.example_providers ON auth_type 
    TYPE option<array<record<provider>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Liste de providers utilisant ce type.';

DEFINE FIELD IF NOT EXISTS documentation.use_cases_i18n ON auth_type 
    TYPE option<array<record<i18n_key>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Cas d\'usage recommandés multilingues.';

DEFINE FIELD IF NOT EXISTS documentation.advantages_i18n ON auth_type 
    TYPE option<array<record<i18n_key>>>
    COMMENT 'Avantages de ce type multilingues.';

DEFINE FIELD IF NOT EXISTS documentation.disadvantages_i18n ON auth_type 
    TYPE option<array<record<i18n_key>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Inconvénients et limitations multilingues.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON auth_type 
    TYPE option<object>
    COMMENT 'Métadonnées additionnelles pour extensions futures.';

DEFINE FIELD IF NOT EXISTS etag ON auth_type 
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour la détection de changements et mise à jour temps réel via WebSocket.';

DEFINE FIELD IF NOT EXISTS created_at ON auth_type 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS updated_at ON auth_type 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS  time::now()
    COMMENT 'Date de dernière mise à jour.';

-- =====================================================
-- INDEX (uniquement sur champs à plat)
-- =====================================================

DEFINE INDEX IF NOT EXISTS auth_type_name_idx ON auth_type FIELDS name UNIQUE
    COMMENT 'Unicité du nom technique.';

DEFINE INDEX IF NOT EXISTS auth_type_slug_idx ON auth_type FIELDS slug UNIQUE
    COMMENT 'Unicité du slug.';

DEFINE INDEX IF NOT EXISTS auth_type_active_idx ON auth_type FIELDS is_active
    COMMENT 'Filtrage rapide des types actifs.';

-- Note: Les index sur sous-champs d'objets ne sont pas supportés par SurrealDB
-- C'est pourquoi name, slug et is_active restent à plat pour permettre l'indexation

-- =====================================================
-- NOTES D'IMPLÉMENTATION
-- =====================================================
--
-- Types d'authentification à initialiser via seed:
-- • oauth2     : OAuth 2.0 (popularité: 95, sécurité: 5)
-- • oauth1     : OAuth 1.0a (popularité: 30, sécurité: 4)
-- • api_key    : API Key (popularité: 85, sécurité: 3)
-- • basic_auth : Basic Authentication (popularité: 60, sécurité: 2)
-- • bearer_token : Bearer Token (popularité: 70, sécurité: 3)
-- • digest_auth : Digest Authentication (popularité: 20, sécurité: 3)
-- • header_auth : Custom Header (popularité: 65, sécurité: 3)
-- • query_auth : Query Parameter (popularité: 50, sécurité: 2)
-- • custom     : Custom Authentication (popularité: 40, sécurité: 3)
--
-- Les données initiales doivent être chargées via un fichier de seed séparé.
--
-- =============================================================================================

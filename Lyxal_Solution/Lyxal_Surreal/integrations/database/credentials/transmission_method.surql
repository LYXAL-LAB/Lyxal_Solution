-- =============================================================================================
-- |
-- | Fichier : transmission_method.surql
-- | Module : integrations > shared
-- | Description : Méthodes de transmission HTTP pour authentification.
-- |
-- | Cette table définit les différentes façons de transmettre les credentials via HTTP.
-- | Structure GROUPÉE pour optimiser les cas d'usage :
-- | • UI : Récupération ciblée des données de présentation
-- | • IA : Accès direct aux métadonnées de qualité et recommandations
-- | • Humain : Structure claire et organisée
-- |
-- | Architecture:
-- | • Champs à PLAT : name, slug, is_active (pour index/recherche/unicité)
-- | • Champs GROUPÉS : identity, presentation, quality, config
-- |
-- | Conçue pour :
-- | • IA autonome : Métadonnées riches multilingues pour raisonnement
-- | • UI driven : Auto-génération de l'interface depuis la base de données
-- | • Intégrité : Validation stricte des références
-- | • Maintenance : Single source of truth pour chaque méthode
-- |
-- | Tables référencées:
-- | • i18n_key : Traductions multilingues (nom, description, tooltips, use cases)
-- | • icon : Icônes normalisées pour l'interface utilisateur
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Events pour régénération automatique de l'ETag et updated_at
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |   (voir: integrations/documentation/webhook/WEBSOCKET_CREDENTIALS.md)
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS transmission_method TYPE NORMAL SCHEMAFULL
COMMENT 'Méthodes de transmission HTTP des credentials (header, query, body, custom).'
PERMISSIONS
FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE;

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS name ON transmission_method 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Nom technique unique de la méthode (ex: header, query, body, custom).';

DEFINE FIELD IF NOT EXISTS slug ON transmission_method 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Slug unique pour URL et recherche.';

DEFINE FIELD IF NOT EXISTS is_active ON transmission_method 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si cette méthode est active et utilisable.';

-- =====================================================
-- OBJET: identity (Informations d'identification)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON transmission_method 
    TYPE object
    COMMENT 'Informations d\'identification et description de la méthode.';

DEFINE FIELD IF NOT EXISTS identity.display_name_i18n ON transmission_method 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Nom affiché multilingue dans l\'UI.';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON transmission_method 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description détaillée multilingue pour utilisateurs et IA.';

-- =====================================================
-- OBJET: presentation (Éléments visuels pour UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON transmission_method 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.icon ON transmission_method 
    TYPE record<icon>
    REFERENCE ON DELETE REJECT
    COMMENT 'Icône représentative de la méthode.';

DEFINE FIELD IF NOT EXISTS presentation.color_type ON transmission_method 
    TYPE record<theme_color_type>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de couleur pour les tags/badges dans l\'UI (référence vers theme_color_type: primary, error, warning, etc.).';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON transmission_method 
    TYPE int
    DEFAULT 999
    COMMENT 'Ordre d\'affichage dans l\'UI (plus petit = plus haut).';

DEFINE FIELD IF NOT EXISTS presentation.tooltip_i18n ON transmission_method 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tooltip contextuel affiché dans l\'UI.';

-- =====================================================
-- OBJET: quality (Métriques de qualité et recommandation pour IA)
-- =====================================================

DEFINE FIELD IF NOT EXISTS quality ON transmission_method 
    TYPE object
    COMMENT 'Métriques de qualité et recommandations pour l\'IA.';

DEFINE FIELD IF NOT EXISTS quality.security_level ON transmission_method 
    TYPE int
    ASSERT $value >= 1 AND $value <= 5
    DEFAULT 3
    COMMENT 'Niveau de sécurité (1=faible, 5=très élevé) pour décisions IA.';

DEFINE FIELD IF NOT EXISTS quality.security_concerns_i18n ON transmission_method 
    TYPE option<array<record<i18n_key>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Préoccupations de sécurité multilingues (logs, cache, history).';

DEFINE FIELD IF NOT EXISTS quality.best_use_cases_i18n ON transmission_method 
    TYPE option<array<record<i18n_key>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Cas d\'usage recommandés multilingues pour l\'IA.';

DEFINE FIELD IF NOT EXISTS quality.avoid_use_cases_i18n ON transmission_method 
    TYPE option<array<record<i18n_key>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Cas d\'usage à éviter multilingues (pour alertes IA).';

-- =====================================================
-- OBJET: config (Configuration technique)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON transmission_method 
    TYPE object
    COMMENT 'Configuration technique de la méthode.';

DEFINE FIELD IF NOT EXISTS config.technical_details ON transmission_method 
    TYPE option<object>
    COMMENT 'Détails techniques pour développeurs et IA (location, format, example, standard).';

DEFINE FIELD IF NOT EXISTS config.is_recommended ON transmission_method 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si c\'est la méthode recommandée par défaut.';

DEFINE FIELD IF NOT EXISTS config.requires_https ON transmission_method 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si HTTPS est obligatoire pour cette méthode.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON transmission_method 
    TYPE option<object>
    COMMENT 'Métadonnées additionnelles pour extensions futures.';

DEFINE FIELD IF NOT EXISTS etag ON transmission_method 
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour la détection de changements et synchronisation temps réel.';

DEFINE FIELD IF NOT EXISTS created_at ON transmission_method 
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS updated_at ON transmission_method 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS  time::now()
    COMMENT 'Date de dernière mise à jour.';

-- =====================================================
-- INDEX (uniquement sur champs à plat)
-- =====================================================

DEFINE INDEX IF NOT EXISTS transmission_method_name_idx ON transmission_method FIELDS name UNIQUE
    COMMENT 'Unicité du nom technique.';

DEFINE INDEX IF NOT EXISTS transmission_method_slug_idx ON transmission_method FIELDS slug UNIQUE
    COMMENT 'Unicité du slug.';

DEFINE INDEX IF NOT EXISTS transmission_method_active_idx ON transmission_method FIELDS is_active
    COMMENT 'Filtrage rapide des méthodes actives.';

-- =====================================================
-- NOTES D'IMPLÉMENTATION
-- =====================================================
--
-- Usage dans l'IA :
-- 1. L'IA lit security_level, security_concerns, best/avoid_use_cases
-- 2. L'IA raisonne : "User wants to send a secret token"
-- 3. L'IA recommande : transmission_method:header (security_level=4)
-- 4. L'IA explique : "Headers are not logged in browser history"
--
-- Usage dans l'UI :
-- 1. UI récupère toutes les méthodes actives
-- 2. UI trie par display_order
-- 3. UI génère des radio buttons avec :
--    - Label depuis display_name_i18n
--    - Icon depuis icon
--    - Tooltip depuis tooltip_i18n
--    - Badge de couleur depuis color_type
--    - Badge "Recommended" si is_recommended = true
--
-- Intégrité référentielle :
-- Si un auth_type référence transmission_method:header,
-- SurrealDB garantit que cette méthode existe.
-- Impossible d'avoir une référence invalide.
--
-- =============================================================================================


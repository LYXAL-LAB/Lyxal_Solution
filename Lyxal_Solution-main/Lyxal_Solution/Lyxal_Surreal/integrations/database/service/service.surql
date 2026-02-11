-- =============================================================================================
-- |
-- | TABLE: service
-- | MODULE: integrations
-- | VERSION: 2.0
-- | DATE: 2025-10-29
-- |
-- | DESCRIPTION:
-- | Représente les services/produits offerts par un provider.
-- | Un service est une application ou un produit spécifique d'un provider.
-- |
-- | EXEMPLES:
-- | - Provider "Google" → Services: Google Sheets, Google Drive, Gmail, etc.
-- | - Provider "Slack" → Services: Slack Messages, Slack Channels
-- | - Provider "GitHub" → Services: GitHub Issues, GitHub Actions, GitHub Repos
-- |
-- | ARCHITECTURE:
-- | - Structure groupée pour clarté (identity, presentation, config, documentation, metadata)
-- | - i18n_key pour multilinguisme (display_name, description, tooltip)
-- | - logo_brand pour gestion centralisée des icônes
-- | - ETag pour optimistic locking et temps réel
-- | - Permissions granulaires pour sécurité
-- |
-- | CONFORMITÉ: 100% Lyxal Standards (Data-First + UI-Driven)
-- |
-- =============================================================================================

-- =====================================================
-- DÉFINITION DE LA TABLE
-- =====================================================

DEFINE TABLE service SCHEMAFULL
    COMMENT "Services/produits proposés par les providers (ex: Google Sheets, Slack Messages, GitHub Issues). Table conforme 100% aux standards Lyxal avec structure groupée, i18n, ETag et permissions."
    PERMISSIONS
        FOR select WHERE is_active = true OR $auth.role IN ["admin", "editor"]
        FOR create WHERE $auth.role IN ["admin"]
        FOR update WHERE $auth.role IN ["admin", "editor"]
        FOR delete WHERE $auth.role = "admin";

-- =====================================================
-- BLOC: IDENTITY (Identité technique et sémantique)
-- =====================================================

DEFINE FIELD identity ON service TYPE object
    COMMENT "Identité du service : noms techniques et affichables"
    ASSERT $value != NONE;

DEFINE FIELD identity.name ON service TYPE string
    COMMENT "Nom technique du service (ex: 'googleSheets', 'slack', 'githubIssues')"
    ASSERT $value != NONE AND string::len($value) > 0;

DEFINE FIELD identity.slug ON service TYPE string
    COMMENT "Slug unique pour URLs et identification (ex: 'google-sheets', 'slack-messages')"
    ASSERT $value != NONE AND string::len($value) > 0 AND string::lowercase($value) == $value;

DEFINE FIELD identity.display_name_i18n ON service TYPE record<i18n_key>
    COMMENT "Clé i18n pour le nom affiché dans l'UI (ex: 'Google Sheets', 'Slack Messages')"
    ASSERT $value != NONE;

DEFINE FIELD identity.description_i18n ON service TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour la description complète du service";

DEFINE FIELD identity.aliases ON service TYPE array<string> DEFAULT []
    COMMENT "Alias de recherche (ex: ['CSV', 'Sheet', 'Spreadsheet'] pour Google Sheets)";

-- =====================================================
-- BLOC: PRESENTATION (Apparence UI)
-- =====================================================

DEFINE FIELD presentation ON service TYPE object
    COMMENT "Configuration de présentation visuelle dans l'UI"
    ASSERT $value != NONE;

DEFINE FIELD presentation.icon ON service TYPE option<record<logo_brand>>
    COMMENT "Référence au logo du service dans la table logo_brand";

DEFINE FIELD presentation.color_type ON service TYPE option<record<theme_color_type>>
    COMMENT "Type de couleur pour les tags/badges dans l'UI (référence vers theme_color_type: primary, error, warning, etc.)"
    REFERENCE ON DELETE REJECT;

DEFINE FIELD presentation.display_order ON service TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage dans les listes (0 = plus haut)";

DEFINE FIELD presentation.category_slug ON service TYPE option<string>
    COMMENT "Slug de la catégorie principale (ex: 'data-storage', 'communication', 'development')";

DEFINE FIELD presentation.tooltip_i18n ON service TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour l'infobulle (conseil rapide affiché au survol)";

DEFINE FIELD presentation.badge_text ON service TYPE option<string>
    COMMENT "Texte du badge affiché sur la carte (ex: 'Beta', 'New', 'Popular', 'v2')"
    ASSERT $value == NONE OR string::len($value) <= 20;

DEFINE FIELD presentation.badge_color ON service TYPE option<string>
    COMMENT "Couleur du badge (ex: '#FF5722' pour 'Beta', '#4CAF50' pour 'New')"
    ASSERT $value == NONE OR string::starts_with($value, '#');

-- =====================================================
-- BLOC: CONFIG (Configuration technique)
-- =====================================================

DEFINE FIELD config ON service TYPE object
    COMMENT "Configuration technique et capacités du service"
    ASSERT $value != NONE;

-- Version ─────────────────────────────────────────────

DEFINE FIELD config.version ON service TYPE object
    COMMENT "Gestion des versions du service"
    ASSERT $value != NONE;

DEFINE FIELD config.version.current ON service TYPE string DEFAULT "1.0"
    COMMENT "Version actuelle du service (ex: '4.7', '2.3', '1.0')";

DEFINE FIELD config.version.is_default_version ON service TYPE bool DEFAULT true
    COMMENT "True si c'est la version par défaut à utiliser";

DEFINE FIELD config.version.supported_versions ON service TYPE array<string> DEFAULT []
    COMMENT "Liste des versions supportées (ex: ['4.7', '4.6', '4.5'])";

-- Capabilities ────────────────────────────────────────

DEFINE FIELD config.capabilities ON service TYPE object
    COMMENT "Capacités et fonctionnalités du service"
    ASSERT $value != NONE;

DEFINE FIELD config.capabilities.is_trigger ON service TYPE bool DEFAULT false
    COMMENT "True si le service peut déclencher des workflows (ex: webhook, polling)";

DEFINE FIELD config.capabilities.is_polling ON service TYPE bool DEFAULT false
    COMMENT "True si le service supporte le polling (vérification régulière de changements)";

DEFINE FIELD config.capabilities.is_webhook ON service TYPE bool DEFAULT false
    COMMENT "True si le service supporte les webhooks (notifications push)";

DEFINE FIELD config.capabilities.is_action ON service TYPE bool DEFAULT true
    COMMENT "True si le service peut exécuter des actions (create, update, delete)";

DEFINE FIELD config.capabilities.supports_batch ON service TYPE bool DEFAULT false
    COMMENT "True si le service supporte les opérations par lot (bulk operations)";

-- API ──────────────────────────────────────────────────

DEFINE FIELD config.api ON service TYPE option<object>
    COMMENT "Configuration de l'API du service";

DEFINE FIELD config.api.base_url ON service TYPE option<string>
    COMMENT "URL de base de l'API du service (ex: 'https://sheets.googleapis.com')"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD config.api.version ON service TYPE option<string>
    COMMENT "Version de l'API utilisée (ex: 'v4', 'v2', 'v1')";

DEFINE FIELD config.api.protocol ON service TYPE option<string>
    COMMENT "Protocole de l'API (ex: 'REST', 'GraphQL', 'SOAP', 'gRPC')"
    ASSERT $value == NONE OR $value IN ["REST", "GraphQL", "SOAP", "gRPC", "WebSocket", "Custom"];

-- Rate Limits ──────────────────────────────────────────

DEFINE FIELD config.rate_limits ON service TYPE option<object>
    COMMENT "Limites de taux d'appel API (rate limiting)";

DEFINE FIELD config.rate_limits.requests_per_minute ON service TYPE option<int>
    COMMENT "Nombre maximum de requêtes par minute"
    ASSERT $value == NONE OR $value > 0;

DEFINE FIELD config.rate_limits.requests_per_day ON service TYPE option<int>
    COMMENT "Nombre maximum de requêtes par jour"
    ASSERT $value == NONE OR $value > 0;

-- =====================================================
-- BLOC: DOCUMENTATION (Ressources externes)
-- =====================================================

DEFINE FIELD documentation ON service TYPE option<object>
    COMMENT "URLs de documentation et ressources d'apprentissage";

DEFINE FIELD documentation.main_url ON service TYPE option<string>
    COMMENT "URL principale de la documentation du service"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.api_reference_url ON service TYPE option<string>
    COMMENT "URL de la référence API complète"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.credential_setup_url ON service TYPE option<string>
    COMMENT "URL du guide de configuration des credentials"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.video_tutorial_url ON service TYPE option<string>
    COMMENT "URL d'une vidéo de démonstration/tutoriel"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.changelog_url ON service TYPE option<string>
    COMMENT "URL du changelog des versions"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

-- =====================================================
-- BLOC: METADATA (Données supplémentaires)
-- =====================================================

DEFINE FIELD metadata ON service TYPE option<object>
    COMMENT "Métadonnées additionnelles pour analytics et extensions";

DEFINE FIELD metadata.tags ON service TYPE array<string> DEFAULT []
    COMMENT "Tags pour catégorisation et recherche (ex: ['spreadsheet', 'data', 'analytics'])";

DEFINE FIELD metadata.popularity_score ON service TYPE option<int>
    COMMENT "Score de popularité (basé sur usage, téléchargements, etc.)"
    ASSERT $value == NONE OR ($value >= 0 AND $value <= 100);

DEFINE FIELD metadata.last_updated_by ON service TYPE option<record<user>>
    COMMENT "Dernier utilisateur ayant modifié cet enregistrement";

DEFINE FIELD metadata.custom_data ON service TYPE option<object>
    COMMENT "Données personnalisées spécifiques à l'application";

-- =====================================================
-- BLOC: RELATIONS (Liaisons vers autres tables)
-- =====================================================

DEFINE FIELD provider_id ON service TYPE record<provider>
    COMMENT "Provider parent de ce service (ex: service 'Google Sheets' → provider 'Google')"
    ASSERT $value != NONE;

DEFINE FIELD category_id ON service TYPE option<record<category>>
    COMMENT "Catégorie principale du service (optionnel si category_slug est utilisé)";

-- =====================================================
-- BLOC: ÉTAT (Status et synchronisation)
-- =====================================================

DEFINE FIELD is_active ON service TYPE bool DEFAULT true
    COMMENT "True si le service est activé et disponible dans l'UI";

DEFINE FIELD ETag ON service TYPE uuid DEFAULT rand::uuid::v4()
    COMMENT "ETag pour optimistic locking et Live Queries. Change à chaque modification."
    READONLY;

-- =====================================================
-- BLOC: TIMESTAMPS (Audit trail)
-- =====================================================

DEFINE FIELD created_at ON service TYPE datetime
    COMMENT "Date de création de l'enregistrement (immuable)"
    VALUE $before OR time::now()
    READONLY;

DEFINE FIELD updated_at ON service TYPE datetime
    COMMENT "Date de dernière modification (auto-mise à jour)"
    DEFAULT ALWAYS time::now()
    READONLY;

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX service_slug_idx ON service FIELDS identity.slug UNIQUE
    COMMENT "Index unique sur le slug pour garantir l'unicité et accélérer les recherches par slug";

DEFINE INDEX service_name_idx ON service FIELDS identity.name
    COMMENT "Index sur le nom technique pour recherches rapides";

DEFINE INDEX service_provider_idx ON service FIELDS provider_id
    COMMENT "Index sur provider_id pour requêtes de type 'tous les services d'un provider'";

DEFINE INDEX service_active_idx ON service FIELDS is_active
    COMMENT "Index sur is_active pour filtrer rapidement les services actifs";

DEFINE INDEX service_category_idx ON service FIELDS presentation.category_slug
    COMMENT "Index sur category_slug pour filtrer par catégorie";

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- Exemple 1: Créer un service Google Sheets
/*
CREATE service:google_sheets SET
    identity = {
        name: "googleSheets",
        slug: "google-sheets",
        display_name_i18n: i18n_key:service_google_sheets_name,
        description_i18n: i18n_key:service_google_sheets_desc,
        aliases: ["CSV", "Sheet", "Spreadsheet", "GS"]
    },
    presentation = {
        icon: logo_brand:google_sheets,
        color: "#34A853",
        display_order: 10,
        category_slug: "data-storage",
        tooltip_i18n: i18n_key:service_google_sheets_tooltip,
        badge_text: "Popular",
        badge_color: "#4CAF50"
    },
    config = {
        version: {
            current: "4.7",
            is_default_version: true,
            supported_versions: ["4.7", "4.6", "4.5"]
        },
        capabilities: {
            is_trigger: true,
            is_polling: true,
            is_webhook: false,
            is_action: true,
            supports_batch: true
        },
        api: {
            base_url: "https://sheets.googleapis.com",
            version: "v4",
            protocol: "REST"
        },
        rate_limits: {
            requests_per_minute: 60,
            requests_per_day: 100000
        }
    },
    documentation = {
        main_url: "https://developers.google.com/sheets/api",
        api_reference_url: "https://developers.google.com/sheets/api/reference/rest",
        credential_setup_url: "https://developers.google.com/sheets/api/guides/authorizing",
        video_tutorial_url: "https://www.youtube.com/watch?v=...",
        changelog_url: "https://developers.google.com/sheets/api/releases"
    },
    metadata = {
        tags: ["spreadsheet", "data", "analytics", "collaboration"],
        popularity_score: 95,
        custom_data: {
            n8n_version: "4.7",
            last_tested: "2025-10-15"
        }
    },
    provider_id: provider:google,
    is_active: true;
*/

-- Exemple 2: Query pour obtenir tous les services actifs d'un provider
/*
SELECT * FROM service
WHERE provider_id = provider:google AND is_active = true
ORDER BY presentation.display_order ASC;
*/

-- Exemple 3: Query avec JOIN pour obtenir service + provider + i18n
/*
SELECT
    identity.name,
    identity.slug,
    identity.display_name_i18n.* AS display_name,
    provider_id.identity.display_name_i18n.* AS provider_name,
    presentation.icon.* AS icon,
    config.capabilities.*
FROM service
WHERE is_active = true;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. STRUCTURE GROUPÉE:
--    Tous les champs sont organisés en blocs logiques (identity, presentation, config, etc.)
--    pour une meilleure lisibilité et maintenabilité.
--
-- 2. I18N OBLIGATOIRE:
--    display_name_i18n et description_i18n utilisent i18n_key pour supporter
--    le multilinguisme (FR, EN, IT, DE, ES).
--
-- 3. LOGO_BRAND:
--    presentation.icon utilise record<logo_brand> pour centraliser la gestion
--    des logos (light/dark mode, SVG, PNG, etc.).
--
-- 4. ETAG:
--    Change automatiquement à chaque UPDATE grâce à SurrealDB.
--    Utilisé pour optimistic locking et Live Queries.
--
-- 5. TIMESTAMPS:
--    - created_at : READONLY, défini uniquement à la création
--    - updated_at : READONLY, mis à jour automatiquement à chaque modification
--
-- 6. PERMISSIONS:
--    - SELECT: Tous peuvent voir les services actifs, admins/editors voient tout
--    - CREATE: Réservé aux admins
--    - UPDATE: Admins et editors
--    - DELETE: Réservé aux admins
--
-- 7. CATEGORY:
--    Deux approches possibles:
--    - category_slug (string) : Simple, rapide
--    - category_id (record<category>) : Relationnel, plus puissant
--    Les deux sont supportés pour flexibilité.
--
-- 8. VERSIONS:
--    La gestion des versions multiples est simplifiée ici.
--    Pour un système avancé, utiliser la table service_version (voir integration_schema.surql).

-- =====================================================
-- FIN DE LA DÉFINITION
-- =====================================================


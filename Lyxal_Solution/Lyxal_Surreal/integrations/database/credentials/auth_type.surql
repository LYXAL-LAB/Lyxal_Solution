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
    VALUE type::record('i18n_key', $value)
    COMMENT 'Clé i18n pour le nom affiché multilingue.';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON auth_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    VALUE type::record('i18n_key', $value)
    COMMENT 'Clé i18n pour la description multilingue.';

-- =====================================================
-- OBJET: presentation (Éléments visuels pour UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON auth_type 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.icon ON auth_type 
    TYPE record<url>
    REFERENCE ON DELETE REJECT
    VALUE type::record('url', $value)
    COMMENT 'URL de l\'icône : https://icons.lyxal.b-cdn.net/lucide/key.svg';

DEFINE FIELD IF NOT EXISTS presentation.color ON auth_type 
    TYPE string
    ASSERT string::starts_with($value, '#') AND string::len($value) = 7
    COMMENT 'Couleur hexadécimale (ex: #4285F4).';

DEFINE FIELD IF NOT EXISTS presentation.color_daisy ON auth_type 
    TYPE string
    ASSERT $value IN ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']
    COMMENT 'Classe de couleur DaisyUI (ex: primary, secondary, accent, neutral, info, success, warning, error).';

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
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Insertion d'un type complet (avec i18n et références)
-- Note: etag et updated_at sont générés automatiquement par les EVENTs
/*
CREATE auth_type:oauth2 SET
    name = "oauth2",
    slug = "oauth2",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:auth_type_oauth2_name,
        description_i18n: i18n_key:auth_type_oauth2_description
    },
    presentation = {
        icon: icon:shield_check,
        color: "#4285F4",
        color_daisy: "primary",
        tooltip: i18n_key:auth_type_oauth2_tooltip,
        display_order: 1
    },
    quality = {
        security_level: 5,
        popularity_score: 95,
        implementation_complexity: 4
    },
    config = {
        schema: {
            fields: ["auth_url", "token_url", "scope"],
            required: ["auth_url", "token_url"]
        },
        template: {
            grant_type: "authorization_code"
        },
        credential_fields_template: [
            {name: "client_id", display_name: "Client ID", type: "string", is_secret: false},
            {name: "client_secret", display_name: "Client Secret", type: "string", is_secret: true}
        ]
    },
    http = {
        typical_headers: { "Authorization": "Bearer {access_token}" },
        transmission_method: transmission_method:header
    },
    behavior = {
        supports_refresh: true,
        requires_user_interaction: true,
        typical_validity_duration: 3600
    },
    documentation = {
        url: url:oauth2_official_doc,
        example_providers: [provider:google, provider:facebook, provider:github],
        use_cases_i18n: [
            i18n_key:auth_type_oauth2_usecase_user_auth,
            i18n_key:auth_type_oauth2_usecase_third_party
        ],
        advantages_i18n: [
            i18n_key:auth_type_oauth2_advantage_secure,
            i18n_key:auth_type_oauth2_advantage_standard
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_oauth2_disadvantage_complex
        ]
    };

-- Retourne automatiquement:
-- {
--   id: auth_type:oauth2,
--   name: "oauth2",
--   ...
--   etag: "01928abc-def0-7890-1234-567890abcdef",  // ✨ Généré automatiquement
--   created_at: "2025-10-28T14:30:00Z",
--   updated_at: "2025-10-28T14:30:00Z"
-- }
*/

-- EXEMPLE 2: Requête UI - Récupérer présentation avec traductions
/*
SELECT 
    name,
    identity.display_name_i18n.*,
    identity.description_i18n.*,
    presentation,
    quality.security_level,
    quality.popularity_score
FROM auth_type 
WHERE is_active = true
ORDER BY presentation.display_order ASC, quality.popularity_score DESC;
*/

-- EXEMPLE 3: Requête IA - Documentation complète avec providers
/*
SELECT 
    name,
    identity,
    documentation.url.*,
    documentation.example_providers.*.name AS provider_names,
    documentation.use_cases_i18n.*,
    documentation.advantages_i18n.*,
    documentation.disadvantages_i18n.*,
    quality,
    behavior
FROM auth_type
WHERE name = "oauth2";
*/

-- EXEMPLE 4: Requête développeur - Configuration technique avec métadonnées
/*
SELECT 
    name,
    config,
    http.typical_headers,
    http.transmission_method.*,  -- Récupère toutes les métadonnées de transmission_method
    behavior
FROM auth_type
WHERE quality.implementation_complexity <= 2;
*/

-- EXEMPLE 4b: IA récupère les recommandations de sécurité
/*
SELECT 
    name,
    identity.display_name_i18n.* AS display_name,
    http.transmission_method.identity.display_name_i18n.* AS method_name,
    http.transmission_method.quality.security_level AS method_security,
    http.transmission_method.quality.security_concerns_i18n.* AS method_concerns,
    quality.security_level AS auth_security
FROM auth_type:oauth2;

-- Retourne:
-- {
--   name: "oauth2",
--   display_name: { fr: "OAuth 2.0", en: "OAuth 2.0", ... },
--   method_name: { fr: "En-tête HTTP", en: "HTTP Header", ... },
--   method_security: 4,
--   method_concerns: [{ fr: "Peut être modifié...", en: "Can be modified...", ... }],
--   auth_security: 5
-- }
-- L'IA peut maintenant raisonner: "OAuth2 est très sécurisé (5) et utilise headers (4)"
*/

-- EXEMPLE 5: Requête avec JOIN pour récupérer les traductions complètes
/*
SELECT 
    auth_type.*,
    identity.description_i18n.translations AS description_translations,
    presentation.tooltip.translations AS tooltip_translations
FROM auth_type
WHERE is_active = true;
*/

-- EXEMPLE 6: Utilisation de l'ETag pour détecter les changements
/*
-- Récupérer avec ETag
SELECT *, etag FROM auth_type:oauth2;
-- Retourne: { ..., etag: "01928abc-def0-7890-1234-567890abcdef" }

-- Vérifier si changé avant mise à jour
LET $current = SELECT etag FROM auth_type:oauth2;
IF $current.etag = $client_etag {
    -- Pas de changement, on peut utiliser le cache
    RETURN { cached: true };
} ELSE {
    -- Changement détecté, renvoyer les nouvelles données
    RETURN SELECT * FROM auth_type:oauth2;
};
*/

-- =====================================================
-- WEBSOCKET : Écoute des changements en temps réel
-- =====================================================
--
-- Côté serveur (SurrealDB) :
-- LIVE SELECT * FROM auth_type WHERE is_active = true;
--
-- Côté client (JavaScript) :
-- ws.on('message', (data) => {
--   if (data.action === 'CREATE' || data.action === 'UPDATE') {
--     console.log('Auth type modifié:', data.result);
--     console.log('Nouveau ETag:', data.result.etag);
--     // Mettre à jour le cache local et l'UI
--     updateCache(data.result);
--     refreshUI(data.result);
--   }
-- });
--
-- Flow de mise à jour :
-- 1. Client A écoute les changements via LIVE SELECT
-- 2. Client B modifie auth_type:oauth2
-- 3. EVENT génère un nouvel ETag automatiquement
-- 4. Client A reçoit la notification avec le nouvel ETag
-- 5. Client A met à jour son UI en temps réel
--
-- Avantages :
-- • Détection instantanée des changements
-- • Évite les conflits de mise à jour (optimistic locking)
-- • Cache intelligent côté client
-- • Synchronisation multi-utilisateurs
--
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

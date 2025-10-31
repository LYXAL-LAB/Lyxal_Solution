-- =============================================================================================
-- |
-- | Fichier : uses_credential.surql
-- | Module : integrations > database > credentials
-- | Description : Relation entre service et credential_type.
-- |
-- | Cette relation (edge) définit quels types de credentials un service peut utiliser
-- | pour s'authentifier auprès de son API.
-- |
-- | Exemples de relations:
-- | • service:google_sheets → credential_type:google_sheets_oauth2 (recommandé)
-- | • service:google_sheets → credential_type:google_service_account (avancé)
-- | • service:slack → credential_type:slack_oauth2
-- | • service:stripe → credential_type:stripe_api
-- |
-- | Architecture:
-- | • Champs de RELATION : in (service), out (credential_type), is_required
-- | • Champs GROUPÉS : presentation, config, documentation
-- |
-- | Tables référencées:
-- | • service : Services des providers (ex: Google Sheets, Slack Messages)
-- | • credential_type : Types d'authentification disponibles
-- | • i18n_key : Clés de traduction pour l'internationalisation
-- | • url : URLs normalisées pour la documentation
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS uses_credential TYPE RELATION SCHEMAFULL
COMMENT 'Relation entre service et credential_type - Gère les authentifications disponibles par service.'
PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.permissions = 'lyxal_admin';

-- =====================================================
-- CHAMPS DE RELATION (structure de base)
-- =====================================================

DEFINE FIELD IF NOT EXISTS in ON uses_credential 
    TYPE record<service>
    ASSERT $value != NONE
    COMMENT 'Service source (ex: service:google_sheets, service:slack).';

DEFINE FIELD IF NOT EXISTS out ON uses_credential 
    TYPE record<credential_type>
    ASSERT $value != NONE
    COMMENT 'Type de credential cible (ex: credential_type:google_sheets_oauth2).';

DEFINE FIELD IF NOT EXISTS is_required ON uses_credential 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si ce credential est obligatoire pour utiliser le service (true = obligatoire, false = optionnel).';

-- =====================================================
-- OBJET: presentation (Éléments pour l'UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON uses_credential 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON uses_credential 
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre d\'affichage dans l\'UI (plus petit = plus haut). Utile quand un service a plusieurs credentials.';

DEFINE FIELD IF NOT EXISTS presentation.custom_label_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Label personnalisé multilingue pour ce credential dans ce service (override du display_name du credential_type).';

DEFINE FIELD IF NOT EXISTS presentation.tooltip_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tooltip explicatif multilingue pour aider l\'utilisateur dans ce contexte.';

DEFINE FIELD IF NOT EXISTS presentation.is_recommended ON uses_credential 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si ce credential est recommandé pour ce service (affichage en premier, badge "Recommandé").';

DEFINE FIELD IF NOT EXISTS presentation.badge_color ON uses_credential 
    TYPE string
    ASSERT $value IN ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']
    DEFAULT 'neutral'
    COMMENT 'Couleur du badge DaisyUI pour l\'UI (ex: "primary" pour recommandé, "warning" pour legacy).';

DEFINE FIELD IF NOT EXISTS presentation.display_conditions ON uses_credential 
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Conditions d\'affichage dynamiques. Format JSON: { show: { field: [values] }, hide: { field: [values] } }. Ex: { show: { authentication_mode: ["oauth2"] }, hide: { plan: ["free"] } }';

-- =====================================================
-- OBJET: config (Configuration technique)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON uses_credential 
    TYPE object
    COMMENT 'Configuration technique et exigences spécifiques à ce contexte.';

DEFINE FIELD IF NOT EXISTS config.custom_description_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description personnalisée multilingue pour ce credential dans ce service (ex: "OAuth2 is recommended for most users").';

DEFINE FIELD IF NOT EXISTS config.scopes_required ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Scopes OAuth2 spécifiques requis pour ce service (ex: ["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive.file"]).';

DEFINE FIELD IF NOT EXISTS config.permissions_needed ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Permissions nécessaires pour ce service (ex: ["read:channels", "write:messages", "users:read"]).';

DEFINE FIELD IF NOT EXISTS config.setup_complexity ON uses_credential 
    TYPE string
    ASSERT $value IN ['easy', 'medium', 'hard']
    DEFAULT 'medium'
    COMMENT 'Complexité de configuration pour l\'utilisateur (easy = simple, medium = intermédiaire, hard = expert).';

DEFINE FIELD IF NOT EXISTS config.estimated_setup_time ON uses_credential 
    TYPE option<int>
    ASSERT $value == NONE OR $value > 0
    COMMENT 'Temps estimé de configuration en minutes (ex: 5, 15, 30).';

DEFINE FIELD IF NOT EXISTS config.use_case ON uses_credential 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['standard', 'automation', 'serverless', 'development', 'production']
    COMMENT 'Cas d\'usage principal (ex: "automation" pour Service Account, "standard" pour OAuth2).';

-- =====================================================
-- OBJET: documentation (Ressources d'aide)
-- =====================================================

DEFINE FIELD IF NOT EXISTS documentation ON uses_credential 
    TYPE object
    COMMENT 'Ressources de documentation spécifiques à ce contexte.';

DEFINE FIELD IF NOT EXISTS documentation.setup_instructions_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Instructions de configuration détaillées multilingues (étape par étape).';

DEFINE FIELD IF NOT EXISTS documentation.video_tutorial_url ON uses_credential 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL d\'une vidéo tutoriel pour configurer ce credential dans ce service.';

DEFINE FIELD IF NOT EXISTS documentation.troubleshooting_url ON uses_credential 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de la page de dépannage pour résoudre les problèmes courants.';

DEFINE FIELD IF NOT EXISTS documentation.best_practices_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Bonnes pratiques pour utiliser ce credential dans ce service.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON uses_credential 
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour détection de changements et synchronisation temps réel via WebSocket.';

DEFINE FIELD IF NOT EXISTS created_at ON uses_credential 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création de la relation.';

DEFINE FIELD IF NOT EXISTS updated_at ON uses_credential 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière mise à jour (auto-updated à chaque modification).';

-- =====================================================
-- INDEX (pour performance)
-- =====================================================

DEFINE INDEX IF NOT EXISTS uses_credential_in_idx ON uses_credential FIELDS in
    COMMENT 'Récupération rapide de tous les credentials d\'un service.';

DEFINE INDEX IF NOT EXISTS uses_credential_out_idx ON uses_credential FIELDS out
    COMMENT 'Récupération de tous les services utilisant un credential_type donné.';

DEFINE INDEX IF NOT EXISTS uses_credential_unique_idx ON uses_credential FIELDS in, out UNIQUE
    COMMENT 'Prévention des doublons - Un service ne peut avoir qu\'une seule relation vers un credential_type.';

DEFINE INDEX IF NOT EXISTS uses_credential_required_idx ON uses_credential FIELDS is_required
    COMMENT 'Filtrage rapide des credentials obligatoires vs optionnels.';

DEFINE INDEX IF NOT EXISTS uses_credential_recommended_idx ON uses_credential FIELDS presentation.is_recommended
    COMMENT 'Filtrage des credentials recommandés pour affichage prioritaire.';

DEFINE INDEX IF NOT EXISTS uses_credential_complexity_idx ON uses_credential FIELDS config.setup_complexity
    COMMENT 'Filtrage par complexité de configuration.';

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Google Sheets utilise OAuth2 (recommandé)
/*
RELATE service:google_sheets->uses_credential->credential_type:google_sheets_oauth2 SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color: "primary",
        tooltip_i18n: i18n_key:uses_cred_google_sheets_oauth2_tooltip
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_google_sheets_oauth2_desc,
        scopes_required: [
            "https://www.googleapis.com/auth/spreadsheets",
            "https://www.googleapis.com/auth/drive.file"
        ],
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    },
    documentation = {
        setup_instructions_i18n: i18n_key:uses_cred_google_sheets_oauth2_setup,
        video_tutorial_url: url:google_sheets_oauth2_video
    };
*/

-- EXEMPLE 2: Google Sheets peut aussi utiliser Service Account (avancé)
/*
RELATE service:google_sheets->uses_credential->credential_type:google_service_account SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color: "warning",
        custom_label_i18n: i18n_key:uses_cred_service_account_label,
        tooltip_i18n: i18n_key:uses_cred_service_account_tooltip
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_service_account_desc,
        scopes_required: [
            "https://www.googleapis.com/auth/spreadsheets"
        ],
        setup_complexity: "hard",
        estimated_setup_time: 30,
        use_case: "automation"
    },
    documentation = {
        setup_instructions_i18n: i18n_key:uses_cred_service_account_setup,
        troubleshooting_url: url:service_account_troubleshooting,
        best_practices_i18n: i18n_key:uses_cred_service_account_best_practices
    };
*/

-- EXEMPLE 3: Slack utilise OAuth2 (simple)
/*
RELATE service:slack->uses_credential->credential_type:slack_oauth2 SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color: "primary",
        display_conditions: {
            show: { authentication_mode: ["oauth2"] }
        }
    },
    config = {
        scopes_required: ["chat:write", "channels:read", "users:read"],
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    };
*/

-- EXEMPLE 4: Slack peut aussi utiliser un API Token (legacy)
/*
RELATE service:slack->uses_credential->credential_type:slack_api_token SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color: "warning",
        custom_label_i18n: i18n_key:uses_cred_slack_token_label,
        display_conditions: {
            show: { authentication_mode: ["accessToken"] }
        }
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_slack_token_desc,
        setup_complexity: "medium",
        use_case: "development"
    };
*/

-- EXEMPLE 5: Stripe utilise API Key (simple et unique)
/*
RELATE service:stripe->uses_credential->credential_type:stripe_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color: "primary"
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "standard"
    };
*/

-- =====================================================
-- REQUÊTES UTILES
-- =====================================================

-- Requête 1: Récupérer tous les credentials d'un service avec détails
/*
SELECT 
    credential_type.*,
    uses_credential.is_required,
    uses_credential.presentation.is_recommended,
    uses_credential.presentation.display_order,
    uses_credential.presentation.badge_color,
    uses_credential.config.scopes_required,
    uses_credential.config.setup_complexity
FROM uses_credential
WHERE in = service:google_sheets
ORDER BY uses_credential.presentation.display_order ASC;
*/

-- Requête 2: Récupérer uniquement le credential recommandé d'un service
/*
SELECT 
    credential_type.*,
    uses_credential.config.scopes_required,
    uses_credential.config.estimated_setup_time
FROM uses_credential
WHERE in = service:google_sheets
  AND uses_credential.presentation.is_recommended = true
LIMIT 1;
*/

-- Requête 3: Récupérer tous les services utilisant un credential_type
/*
SELECT 
    service.*,
    uses_credential.is_required,
    uses_credential.presentation.is_recommended
FROM uses_credential
WHERE out = credential_type:google_sheets_oauth2;
*/

-- Requête 4: Compter les services par credential_type
/*
SELECT 
    out AS credential_type_id,
    count() AS service_count,
    array::group(in) AS services
FROM uses_credential
GROUP BY out
ORDER BY service_count DESC;
*/

-- Requête 5: Services avec plusieurs options de credentials
/*
SELECT 
    in AS service_id,
    count() AS credential_count,
    array::group({
        credential: out,
        is_recommended: presentation.is_recommended,
        complexity: config.setup_complexity
    }) AS credentials_details
FROM uses_credential
GROUP BY in
HAVING credential_count > 1
ORDER BY credential_count DESC;
*/

-- Requête 6: Credentials avec display_conditions
/*
SELECT 
    in AS service_id,
    out AS credential_type_id,
    presentation.display_conditions
FROM uses_credential
WHERE presentation.display_conditions IS NOT NONE;
*/

-- Requête 7: Configuration complète pour l'UI (avec i18n)
/*
SELECT 
    service.*,
    array::group({
        credential_type: credential_type.*,
        is_required: uses_credential.is_required,
        is_recommended: uses_credential.presentation.is_recommended,
        display_order: uses_credential.presentation.display_order,
        badge_color: uses_credential.presentation.badge_color,
        custom_label_i18n: uses_credential.presentation.custom_label_i18n.*,
        tooltip_i18n: uses_credential.presentation.tooltip_i18n.*,
        scopes_required: uses_credential.config.scopes_required,
        setup_complexity: uses_credential.config.setup_complexity,
        estimated_time: uses_credential.config.estimated_setup_time
    }) AS credentials
FROM service
LEFT JOIN uses_credential ON uses_credential.in = service.id
LEFT JOIN credential_type ON uses_credential.out = credential_type.id
WHERE service.id = service:google_sheets
GROUP BY service.id;
*/

-- Requête 8: Filtrer par complexité de configuration
/*
SELECT 
    in AS service_id,
    out AS credential_type_id,
    config.setup_complexity,
    config.estimated_setup_time
FROM uses_credential
WHERE config.setup_complexity = 'easy'
ORDER BY config.estimated_setup_time ASC;
*/

-- =====================================================
-- VALIDATION ET MAINTENANCE
-- =====================================================

-- Vérifier les relations orphelines (service n'existe pas)
/*
SELECT * FROM uses_credential 
WHERE in NOT IN (SELECT id FROM service);
*/

-- Vérifier les relations orphelines (credential_type n'existe pas)
/*
SELECT * FROM uses_credential 
WHERE out NOT IN (SELECT id FROM credential_type);
*/

-- Services sans credentials (potentiellement problématique)
/*
SELECT * FROM service 
WHERE id NOT IN (
    SELECT DISTINCT in FROM uses_credential
);
*/

-- Credentials qui ne sont utilisés par aucun service
/*
SELECT * FROM credential_type 
WHERE id NOT IN (
    SELECT DISTINCT out FROM uses_credential
);
*/

-- Vérifier la cohérence des credentials recommandés (max 1 par service)
/*
SELECT 
    in AS service_id,
    count() AS recommended_count
FROM uses_credential
WHERE presentation.is_recommended = true
GROUP BY in
HAVING recommended_count > 1;
*/

-- Services avec credentials obligatoires manquants
/*
SELECT 
    service.id,
    service.name,
    count() AS required_credentials_count
FROM service
LEFT JOIN uses_credential ON uses_credential.in = service.id AND uses_credential.is_required = true
GROUP BY service.id, service.name
HAVING required_credentials_count = 0;
*/

-- =====================================================
-- WEBSOCKET : Écoute des changements en temps réel
-- =====================================================
--
-- Côté serveur (SurrealDB) :
-- LIVE SELECT * FROM uses_credential WHERE in = service:google_sheets;
--
-- Côté client (JavaScript) :
-- ws.on('message', (data) => {
--   if (data.action === 'CREATE' || data.action === 'UPDATE') {
--     console.log('Credential relation modifiée:', data.result);
--     console.log('Nouveau ETag:', data.result.etag);
--     // Mettre à jour la liste des credentials disponibles dans l'UI
--     updateCredentialsSelector(data.result);
--   } else if (data.action === 'DELETE') {
--     console.log('Credential relation supprimée');
--     removeCredentialFromUI(data.result.id);
--   }
-- });
--
-- Flow de mise à jour :
-- 1. Client écoute les changements via LIVE SELECT
-- 2. Admin ajoute un nouveau credential à un service
-- 3. ETag généré automatiquement (DEFAULT)
-- 4. Tous les clients reçoivent la notification
-- 5. UI met à jour dynamiquement la liste des authentifications disponibles
--
-- Avantages :
-- • Synchronisation instantanée multi-utilisateurs
-- • UI toujours à jour sans refresh manuel
-- • Gestion d'état simplifiée côté client
--
-- =============================================================================================

-- ============================================================================
-- TABLE : svg_config
-- Description : Configuration spécifique du module SVG (CDN, Chemins, etc.)
-- Module : Lyxal_SVG
-- ============================================================================

DEFINE TABLE IF NOT EXISTS svg_config SCHEMAFULL
    PERMISSIONS FOR SELECT, UPDATE FULL
    FOR CREATE, DELETE NONE; -- Singleton pattern (une seule config)

-- ============================================================================
-- BLOC BUNNY : Configuration du CDN
-- ============================================================================

DEFINE FIELD IF NOT EXISTS bunny ON TABLE svg_config
    TYPE object
    COMMENT 'Configuration Bunny Storage';

    DEFINE FIELD IF NOT EXISTS bunny.storage_zone ON TABLE svg_config
        TYPE string
        COMMENT 'Nom de la zone de stockage';

    DEFINE FIELD IF NOT EXISTS bunny.api_key ON TABLE svg_config
        TYPE string
        PERMISSIONS FOR SELECT WHERE $scope = 'admin' -- Sécurité: seul admin peut lire la clé
        COMMENT 'Clé API d\'écriture (mot de passe FTP/API)';

    DEFINE FIELD IF NOT EXISTS bunny.region ON TABLE svg_config
        TYPE string
        DEFAULT 'storage.bunnycdn.com'
        COMMENT 'Endpoint régional (ex: ny.storage.bunnycdn.com)';

    DEFINE FIELD IF NOT EXISTS bunny.pull_zone_url ON TABLE svg_config
        TYPE string
        COMMENT 'URL publique du CDN (ex: https://cdn.lyxal.com)';

-- ============================================================================
-- BLOC GITHUB : Configuration API Source
-- ============================================================================

DEFINE FIELD IF NOT EXISTS github ON TABLE svg_config
    TYPE object
    COMMENT 'Configuration API GitHub pour auto-découverte';

    DEFINE FIELD IF NOT EXISTS github.token ON TABLE svg_config
        TYPE string
        PERMISSIONS FOR SELECT WHERE $scope = 'admin'
        COMMENT 'Token d\'accès personnel (PAT) pour éviter le Rate Limit';

    DEFINE FIELD IF NOT EXISTS github.user_agent ON TABLE svg_config
        TYPE string
        DEFAULT 'Lyxal-Importer'
        COMMENT 'User-Agent envoyé à l\'API GitHub';

-- ============================================================================
-- TIMESTAMPS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE svg_config
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification (readonly)';

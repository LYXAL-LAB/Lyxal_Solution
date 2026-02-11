-- ============================================================================
-- TABLE : css_theme_mapping
-- Description : Overrides CSS par thème (personnalisation White-Label)
-- Module : studio/css_mapping
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_theme_mapping TYPE RELATION 
    IN css_dictionary OUT studio_theme ENFORCED SCHEMAFULL
COMMENT 'Overrides CSS spécifiques aux thèmes pour personnalisation White-Label'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC RELATIONS : Liens vers éléments et thèmes
-- ============================================================================

-- Note: Les champs de relation (css_element et theme) sont automatiquement
-- créés par SurrealDB grâce à TYPE RELATION IN css_dictionary OUT studio_theme

-- ============================================================================
-- BLOC OVERRIDES : Personnalisations du thème
-- ============================================================================

DEFINE FIELD IF NOT EXISTS overrides ON TABLE css_theme_mapping
    TYPE object
    COMMENT 'Bloc overrides : personnalisations CSS pour ce thème';

DEFINE FIELD IF NOT EXISTS overrides.additional_classes ON TABLE css_theme_mapping
    TYPE option<array<string>>
    COMMENT 'Classes supplémentaires à ajouter';

DEFINE FIELD IF NOT EXISTS overrides.custom_css ON TABLE css_theme_mapping
    TYPE option<string>
    COMMENT 'CSS personnalisé qui override le mapping de base';

DEFINE FIELD IF NOT EXISTS overrides.variable_overrides ON TABLE css_theme_mapping
    TYPE option<object>
    COMMENT 'Overrides des variables CSS du thème';

DEFINE FIELD IF NOT EXISTS overrides.responsive_overrides ON TABLE css_theme_mapping
    TYPE option<object>
    COMMENT 'Overrides responsive spécifiques au thème';

-- ============================================================================
-- BLOC CONDITIONS : Quand appliquer l'override
-- ============================================================================

DEFINE FIELD IF NOT EXISTS conditions ON TABLE css_theme_mapping
    TYPE option<object>
    COMMENT 'Bloc conditions : quand appliquer cet override';

DEFINE FIELD IF NOT EXISTS conditions.tenant_ids ON TABLE css_theme_mapping
    TYPE option<array<string>>
    COMMENT 'Limiter à certains tenants (White-Label spécifique)';

DEFINE FIELD IF NOT EXISTS conditions.user_roles ON TABLE css_theme_mapping
    TYPE option<array<string>>
    COMMENT 'Limiter à certains rôles utilisateur';

DEFINE FIELD IF NOT EXISTS conditions.environments ON TABLE css_theme_mapping
    TYPE option<array<string>>
    COMMENT 'Limiter à certains environnements (dev, staging, prod)';

-- ============================================================================
-- BLOC MÉTADONNÉES : Gestion des overrides
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_theme_mapping
    TYPE object
    COMMENT 'Bloc métadonnées : informations sur l\'override';

DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE css_theme_mapping
    TYPE int
    DEFAULT 10
    COMMENT 'Priorité de l\'override (10 = thème, 20 = tenant spécifique)';

DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_theme_mapping
    TYPE option<string>
    COMMENT 'Description de la personnalisation';

DEFINE FIELD IF NOT EXISTS metadata.business_reason ON TABLE css_theme_mapping
    TYPE option<string>
    COMMENT 'Raison business de cette personnalisation';

DEFINE FIELD IF NOT EXISTS metadata.version ON TABLE css_theme_mapping
    TYPE string
    DEFAULT '1.0.0'
    COMMENT 'Version de l\'override : 1.0.0, 2.1.3, etc.';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE css_theme_mapping
        TYPE option<record<identity>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Utilisateur créateur de l\'override';

DEFINE FIELD IF NOT EXISTS metadata.expires_at ON TABLE css_theme_mapping
    TYPE option<datetime>
    COMMENT 'Date d\'expiration de l\'override (campagnes temporaires)';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_theme_mapping
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_theme_mapping
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de dernière modification';

-- ============================================================================
-- INDEXES POUR PERFORMANCES
-- ============================================================================

-- Note: Les indexes sur les relations sont automatiquement créés par SurrealDB
-- pour TYPE RELATION IN css_dictionary OUT studio_theme ENFORCED

DEFINE INDEX IF NOT EXISTS idx_priority ON TABLE css_theme_mapping COLUMNS metadata.priority;

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Override bouton primaire pour thème corporate
-- RELATE css_dictionary:primary_button -> css_theme_mapping -> studio_theme:corporate
-- SET overrides = {
--   additional_classes = ["shadow-lg"],
--   custom_css = "
--     background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
--     box-shadow: 0 4px 6px rgba(0,0,0,0.1);
--     transform: translateY(0);
--     transition: transform 0.2s ease;
--   "
-- },
-- metadata = {
--   priority = 10,
--   description = "Style corporate premium avec dégradé et ombre",
--   business_reason = "Différenciation marque corporate"
-- };

-- Override limité à un tenant spécifique (White-Label)
-- RELATE css_dictionary:input_field -> css_theme_mapping -> studio_theme:default_light
-- SET overrides = {
--   custom_css = "border: 2px solid #ff6b35; border-radius: 12px;"
-- },
-- conditions = {
--   tenant_ids = ["tenant_xyz"]
-- },
-- metadata = {
--   priority = 20,
--   description = "Style orange spécifique au tenant XYZ",
--   business_reason = "Charte graphique client XYZ"
-- };

-- Override temporaire pour campagne marketing
-- RELATE css_dictionary:primary_button -> css_theme_mapping -> studio_theme:default_light
-- SET overrides = {
--   additional_classes = ["animate-pulse"],
--   custom_css = "
--     background: linear-gradient(45deg, #ff6b35, #f7931e);
--     color: white;
--     font-weight: bold;
--     text-shadow: 0 1px 2px rgba(0,0,0,0.3);
--   "
-- },
-- metadata = {
--   priority = 15,
--   description = "Style festif pour campagne Noël",
--   business_reason = "Campagne marketing saisonnière",
--   expires_at = "2025-01-01T00:00:00Z"
-- };

-- ============================================================================
-- TABLE : css_theme_color_mapping
-- Description : Mapping des thèmes aux types de couleurs (theme ↔ css_color_type)
-- Module : studio/theme/css
-- ============================================================================

DEFINE TABLE IF NOT EXISTS css_theme_color_mapping TYPE RELATION
    IN studio_theme OUT css_color_type ENFORCED SCHEMAFULL
COMMENT 'Mapping relationnel thème ↔ types de couleurs pour personnalisation des palettes'
PERMISSIONS FOR SELECT FULL
FOR CREATE,UPDATE,DELETE NONE;

-- ============================================================================
-- BLOC MAPPING : Valeur de couleur pour ce thème/type
-- ============================================================================

-- Note: Les champs de relation (theme et color_type) sont automatiquement
-- créés par SurrealDB grâce à TYPE RELATION IN studio_theme OUT css_color_type

DEFINE FIELD IF NOT EXISTS color_value ON TABLE css_theme_color_mapping
    TYPE object
    COMMENT 'Bloc valeur : définition de la couleur pour ce thème';

    DEFINE FIELD IF NOT EXISTS color_value.hex ON TABLE css_theme_color_mapping
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Valeur hexadécimale : #1e40af, #ffffff, etc.';

    DEFINE FIELD IF NOT EXISTS color_value.alpha ON TABLE css_theme_color_mapping
        TYPE option<float>
        ASSERT $value == NONE OR ($value >= 0.0 AND $value <= 1.0)
        COMMENT 'Transparence (0.0 = transparent, 1.0 = opaque)';

    DEFINE FIELD IF NOT EXISTS color_value.name ON TABLE css_theme_color_mapping
        TYPE option<string>
        COMMENT 'Nom optionnel de cette couleur dans le thème';

-- ============================================================================
-- BLOC VARIANTS : Variantes de couleur (light, dark, etc.)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS variants ON TABLE css_theme_color_mapping
    TYPE option<object>
    COMMENT 'Bloc variants : déclinaisons de la couleur';

    DEFINE FIELD IF NOT EXISTS variants.light ON TABLE css_theme_color_mapping
        TYPE option<string>
        COMMENT 'Version claire : #3b82f6 pour primary';

    DEFINE FIELD IF NOT EXISTS variants.dark ON TABLE css_theme_color_mapping
        TYPE option<string>
        COMMENT 'Version sombre : #1d4ed8 pour primary';

    DEFINE FIELD IF NOT EXISTS variants.scale ON TABLE css_theme_color_mapping
        TYPE option<object>
        COMMENT 'Échelle complète (50, 100, 200, ..., 900) si nécessaire';

-- ============================================================================
-- BLOC METADATA : Gestion du mapping
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE css_theme_color_mapping
    TYPE object
    COMMENT 'Bloc métadonnées : informations sur ce mapping';

    DEFINE FIELD IF NOT EXISTS metadata.priority ON TABLE css_theme_color_mapping
        TYPE int
        DEFAULT 1
        COMMENT 'Priorité si plusieurs mappings pour même type';

    DEFINE FIELD IF NOT EXISTS metadata.description ON TABLE css_theme_color_mapping
        TYPE option<string>
        COMMENT 'Description de cette couleur dans le thème';

    DEFINE FIELD IF NOT EXISTS metadata.business_reason ON TABLE css_theme_color_mapping
        TYPE option<string>
        COMMENT 'Raison business de cette couleur';

    DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE css_theme_color_mapping
        TYPE option<record<user>>
        REFERENCE ON DELETE SET NULL
        COMMENT 'Auteur de ce mapping';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE css_theme_color_mapping
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de création';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE css_theme_color_mapping
        TYPE datetime
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification';

-- ============================================================================
-- ETAG : Optimistic locking
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE css_theme_color_mapping
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (généré automatiquement)';

-- ============================================================================
-- INDEXES POUR PERFORMANCES
-- ============================================================================

-- Note: Les indexes sur les relations sont automatiquement créés par SurrealDB
-- pour TYPE RELATION IN studio_theme OUT css_color_type ENFORCED

DEFINE INDEX IF NOT EXISTS idx_color_mapping_priority ON css_theme_color_mapping COLUMNS metadata.priority;

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Mapping couleur primary pour thème corporate
-- RELATE studio_theme:corporate -> css_theme_color_mapping -> css_color_type:primary
-- SET color_value = {
--   hex = "#1e40af",
--   name = "Corporate Blue"
-- },
-- variants = {
--   light = "#3b82f6",
--   dark = "#1d4ed8"
-- },
-- metadata = {
--   description = "Bleu corporate principal",
--   business_reason = "Identité marque corporate"
-- };

-- Mapping couleur error (standard)
-- RELATE studio_theme:default -> css_theme_color_mapping -> css_color_type:error
-- SET color_value = {
--   hex = "#dc2626",
--   alpha = 1.0
-- },
-- metadata = {
--   priority = 1,
--   description = "Rouge standard pour les erreurs"
-- };

-- Requêtes typiques
-- Couleurs d'un thème : SELECT * FROM css_theme_color_mapping WHERE in = studio_theme:corporate;
-- Thèmes utilisant une couleur : SELECT * FROM css_theme_color_mapping WHERE out = css_color_type:primary;

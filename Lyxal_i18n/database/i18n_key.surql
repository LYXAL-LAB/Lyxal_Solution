-- =============================================================================================
-- | TABLE : i18n_key
-- | Module : i18n
-- | Description : Dictionnaire des clés i18n du système de traduction (version structurée).
-- | Chaque enregistrement représente une clé à traduire, avec son contexte, sa valeur par défaut
-- | et ses métadonnées, organisées en objets cohérents.
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_key SCHEMAFULL TYPE NORMAL
    COMMENT 'Dictionnaire des clés i18n du système de traduction.'
    PERMISSIONS 
        FOR SELECT, CREATE FULL
        FOR UPDATE, DELETE NONE;

-- ---------------------------------------------------------------------------------------------
--  Bloc identité
-- ---------------------------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS identity ON TABLE i18n_key
  TYPE object
  COMMENT 'Identité unique et contexte fonctionnel de la clé.';

    DEFINE FIELD IF NOT EXISTS identity.context ON TABLE i18n_key
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0
      COMMENT 'Module ou composant d\'origine : auth, studio, ui, crm, etc.';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE i18n_key
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0 AND string::uppercase($value) = $value
      COMMENT 'Code technique unique de la clé au format UPPER_SNAKE_CASE : ex. BUTTON.SAVE.LABEL, COMPONENT.ACCORDION.NAME.';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE i18n_key
      TYPE string
      ASSERT $value != NONE AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-_]+$')
      COMMENT 'Slug URL-friendly en lowercase-kebab-case : button-save-label, component-accordion-name.';


-- ---------------------------------------------------------------------------------------------
--  Bloc contenu
-- ---------------------------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS content ON TABLE i18n_key
  TYPE object
  COMMENT 'Contenu descriptif et valeur source de la clé.';

    DEFINE FIELD IF NOT EXISTS content.langue_default ON TABLE i18n_key
      TYPE record<language>
      REFERENCE ON DELETE REJECT
      COMMENT 'Langue source (ex: français ou anglais).';

    DEFINE FIELD IF NOT EXISTS content.value_default ON TABLE i18n_key
      TYPE string
      COMMENT 'Valeur source de la clé.';

    DEFINE FIELD IF NOT EXISTS content.description ON TABLE i18n_key
      TYPE string
      COMMENT 'Description fonctionnelle pour traducteurs ou développeurs.';

-- ---------------------------------------------------------------------------------------------
--  Bloc métadonnées
-- ---------------------------------------------------------------------------------------------
DEFINE FIELD IF NOT EXISTS metadata ON TABLE i18n_key
  TYPE object
  DEFAULT {}
  COMMENT 'Métadonnées de création, audit et cycle de vie de la clé.';

    -- Métadonnées principales (création et audit)
    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE i18n_key
      TYPE option<string>     
      COMMENT 'Identifiant du créateur de la clé (utilisateur ou service).';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE i18n_key
      TYPE datetime
      READONLY
      DEFAULT time::now()
      COMMENT 'Date de création de la clé.';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE i18n_key
      TYPE datetime
      READONLY
      DEFAULT ALWAYS time::now()
      COMMENT 'Date de mise à jour de la clé.';

    DEFINE FIELD IF NOT EXISTS metadata.etag ON TABLE i18n_key
      TYPE uuid
      READONLY
      DEFAULT ALWAYS rand::uuid::v7()
      COMMENT 'ETag pour contrôle optimiste (version).';

    -- Bloc statut (cycle de vie de la clé)
    DEFINE FIELD IF NOT EXISTS metadata.status ON TABLE i18n_key
      TYPE object
      COMMENT 'Statut et cycle de vie de la clé.';

      DEFINE FIELD IF NOT EXISTS metadata.status.is_active ON TABLE i18n_key
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si la clé est active (par défaut true).';

      DEFINE FIELD IF NOT EXISTS metadata.status.is_system ON TABLE i18n_key
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si la clé est système (par défaut true).';

      DEFINE FIELD IF NOT EXISTS metadata.status.is_translated ON TABLE i18n_key
        TYPE bool
        DEFAULT false
        COMMENT 'Indique si les traductions associées ont été générées automatiquement.';

      DEFINE FIELD IF NOT EXISTS metadata.status.translated_at ON TABLE i18n_key
        TYPE option<datetime>
        READONLY
        COMMENT 'Date de la dernière traduction de la clé.';

    -- Bloc analytics (métriques d'utilisation)
    DEFINE FIELD IF NOT EXISTS metadata.analytics ON TABLE i18n_key
      TYPE object
      COMMENT 'Métriques et statistiques d\'utilisation de la clé.';

      DEFINE FIELD IF NOT EXISTS metadata.analytics.usage_count ON TABLE i18n_key
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre d\'utilisations de la clé (analytics).';
-- ---------------------------------------------------------------------------------------------
--  Index et contraintes
-- ---------------------------------------------------------------------------------------------

-- Index unique sur context + code
DEFINE INDEX IF NOT EXISTS idx_i18n_key_unique 
  ON TABLE i18n_key FIELDS identity.context, identity.code UNIQUE
  COMMENT 'Index unique sur le contexte et le code technique.';

-- Index unique sur le slug
DEFINE INDEX IF NOT EXISTS idx_i18n_key_slug 
  ON TABLE i18n_key FIELDS identity.slug UNIQUE
  COMMENT 'Index unique sur le slug URL-friendly.';

-- Index sur le contexte (pour filtrage par module)
DEFINE INDEX IF NOT EXISTS idx_i18n_key_context 
  ON TABLE i18n_key FIELDS identity.context
  COMMENT 'Index sur le contexte pour filtrage par module/composant.';

-- Index sur le statut actif (pour requêtes fréquentes)
DEFINE INDEX IF NOT EXISTS idx_i18n_key_active 
  ON TABLE i18n_key FIELDS metadata.status.is_active
  COMMENT 'Index sur les clés actives pour requêtes fréquentes.';

-- Index sur le statut système (pour distinguer système vs custom)
DEFINE INDEX IF NOT EXISTS idx_i18n_key_system 
  ON TABLE i18n_key FIELDS metadata.status.is_system
  COMMENT 'Index sur les clés système vs custom.';
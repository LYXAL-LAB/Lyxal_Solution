-- =====================================================
-- NAMESPACE : lyxal_solution
-- DATABASE : main
-- TABLE 1 : identity
-- =====================================================

-- Table des utilisateurs Lyxal
DEFINE TABLE IF NOT EXISTS identity TYPE NORMAL SCHEMAFULL
  COMMENT 'Utilisateurs de la plateforme Lyxal'
  PERMISSIONS FOR SELECT FULL
  FOR CREATE, UPDATE, DELETE NONE;

-- Identité
DEFINE FIELD IF NOT EXISTS identity ON identity 
  TYPE object
  COMMENT 'Identité';

DEFINE FIELD IF NOT EXISTS identity.first_name ON identity 
  TYPE string
  COMMENT 'Prénom';

DEFINE FIELD IF NOT EXISTS identity.last_name ON identity 
  TYPE string
  COMMENT 'Nom de famille';

DEFINE FIELD IF NOT EXISTS identity.full_name ON identity 
  TYPE string
  COMMENT 'Nom complet';

-- Avatar
DEFINE FIELD IF NOT EXISTS avatar ON identity 
  TYPE option<string>
  COMMENT 'URL de l\'avatar';

-- Statut
DEFINE FIELD IF NOT EXISTS status ON identity 
  TYPE record<identity_status>
  DEFAULT identity_status:created
  COMMENT 'Statut du compte';

-- Sécurité
DEFINE FIELD IF NOT EXISTS security ON identity
  TYPE object
  COMMENT 'Sécurité';

DEFINE FIELD IF NOT EXISTS security.email_verification_token ON identity 
  TYPE option<string>
  COMMENT 'Token de vérification email';

-- Connexion
DEFINE FIELD IF NOT EXISTS connexion ON identity
  TYPE object
  COMMENT 'Connexion';

DEFINE FIELD IF NOT EXISTS connexion.email ON identity 
  TYPE string
  COMMENT 'Email (unique)';

DEFINE FIELD IF NOT EXISTS connexion.password_hash ON identity 
  TYPE string
  COMMENT 'Mot de passe hashé (argon2)';

DEFINE FIELD IF NOT EXISTS connexion.last_login ON identity 
  TYPE option<datetime>
  COMMENT 'Dernière connexion';

DEFINE FIELD IF NOT EXISTS connexion.last_login_ip ON identity 
  TYPE option<string>
  COMMENT 'IP de dernière connexion';

-- Préférences
DEFINE FIELD IF NOT EXISTS preferences ON identity
  TYPE object
  COMMENT 'Préférences';

DEFINE FIELD IF NOT EXISTS preferences.language ON identity 
  TYPE record<language>
  DEFAULT type::record('language', 'fr')
  COMMENT 'Langue préférée';

DEFINE FIELD IF NOT EXISTS preferences.timezone ON identity 
  TYPE record<timezone>
  DEFAULT type::record('timezone', 'Europe/Paris')
  COMMENT 'Fuseau horaire';

-- Métadonnées de traçabilité
DEFINE FIELD IF NOT EXISTS metadata ON identity
  TYPE object
  COMMENT 'Métadonnées de traçabilité';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON identity 
  TYPE datetime 
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création (immuable)';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON identity 
  TYPE datetime 
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour (manuel)';

DEFINE FIELD IF NOT EXISTS metadata.email_verification_expires ON identity 
  TYPE option<datetime>
  COMMENT 'Expiration du token de vérification';

DEFINE FIELD IF NOT EXISTS metadata.created_date ON identity 
  TYPE option<datetime>
  COMMENT 'Date du statut initial';

DEFINE FIELD IF NOT EXISTS metadata.verified_date ON identity 
  TYPE option<datetime>
  COMMENT 'Date de vérification email';

DEFINE FIELD IF NOT EXISTS metadata.active_date ON identity 
  TYPE option<datetime>
  COMMENT 'Date d\'activation du compte';

DEFINE FIELD IF NOT EXISTS metadata.suspended_date ON identity 
  TYPE option<datetime>
  COMMENT 'Date de suspension du compte';

DEFINE FIELD IF NOT EXISTS metadata.deleted_date ON identity 
  TYPE option<datetime>
  COMMENT 'Date de suppression du compte';

-- Index ESSENTIELS
DEFINE INDEX IF NOT EXISTS email_unique ON identity 
  FIELDS connexion.email UNIQUE
  COMMENT 'Index unique sur email';

DEFINE INDEX IF NOT EXISTS status_idx ON identity 
  FIELDS status
  COMMENT 'Index pour filtrer par statut';

DEFINE INDEX IF NOT EXISTS created_at_idx ON identity 
  FIELDS metadata.created_at
  COMMENT 'Index pour trier par date de création';   
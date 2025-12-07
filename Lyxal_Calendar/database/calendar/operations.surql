-- ============================================================================
-- Fichier : calendar/operations.surql
-- Module : calendar
-- TABLE : operations
-- Description : Table de référence pour les types d'opérations (ex: synchronisation).
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
-- ============================================================================

DEFINE TABLE IF NOT EXISTS operations
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Table de référence pour les types d\'opérations.'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique de l'opération
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON operations
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique de l\'opération.';

    DEFINE FIELD IF NOT EXISTS identity.code ON operations
        TYPE string
        ASSERT $value != NONE AND string::uppercase($value) = $value
        COMMENT 'Code technique unique au format UPPER_SNAKE_CASE (ex: ADD, MODIFY).';

    DEFINE FIELD IF NOT EXISTS identity.displayname ON operations
        TYPE record<i18n_key>
        REFERENCE ON DELETE REJECT  
        COMMENT 'clé i18n pour le nom affiché de l\'opération.';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_operation_code_unique ON operations
    FIELDS identity.code UNIQUE
    COMMENT 'Assure que le code de l\'opération est unique.';

-- ============================================================================
-- SEEDING : Données initiales
-- ============================================================================

-- Insérer les opérations de base si elles n'existent pas déjà, ici on va créer apres des fichiers de fn on devra donc séparer cela plus tard
INSERT IGNORE INTO operations (id, identity) VALUES
    ('add', { code: 'ADD', displayname: 'Ajout' }),
    ('modify', { code: 'MODIFY', displayname: 'Modification' }),
    ('delete', { code: 'DELETE', displayname: 'Suppression' });
-- ============================================================================
-- Fichier : calendar/davshares.surql
-- Module : calendar
-- TABLE : davshares
-- Description : Gère le partage des calendriers avec d'autres principaux (utilisateurs, groupes).
-- Auteur : Yaniss Dubreucq
-- Date : 2025-12-02
--
-- REFLEXION D'ARCHITECTURE :
-- Cette table est au cœur de la collaboration. Elle devra référencer un 'principal'
-- qui peut être un utilisateur, un groupe, ou même un lien public.
-- La gestion des permissions sera également centrale.
-- ============================================================================

DEFINE TABLE IF NOT EXISTS davshares
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Gère le partage des calendriers.'
    PERMISSIONS FULL;

-- ============================================================================
-- BLOC IDENTITY : Identification unique du partage
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON davshares
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc identité : identification unique du partage.';

    DEFINE FIELD IF NOT EXISTS identity.publicuri ON davshares
        TYPE option<string>
        COMMENT 'URI unique pour les partages publics par lien (si applicable).';

-- ============================================================================
-- BLOC METADATA : Métadonnées du partage
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON davshares
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc métadonnées : informations et métadonnées du partage.';

    DEFINE FIELD IF NOT EXISTS metadata.timestamp ON davshares
        TYPE object
        DEFAULT {}
        COMMENT 'Bloc timestamps : dates de création et modification.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.created_at ON davshares
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT 'Date de création du partage.';

        DEFINE FIELD IF NOT EXISTS metadata.timestamp.updated_at ON davshares
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now()
            COMMENT 'Date de dernière modification du partage.';
            
-- ============================================================================
-- BLOC CONTENT : Données du partage
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON davshares
    TYPE object
    DEFAULT {}
    COMMENT 'Bloc content : contenu et informations du partage.';

    DEFINE FIELD IF NOT EXISTS content.access_level ON davshares
        TYPE record<access_levels>
        REFERENCE ON DELETE REJECT
        COMMENT 'Niveau d\'accès (référence à la table access_levels).';
        
    DEFINE FIELD IF NOT EXISTS content.share_type ON davshares
        TYPE record<share_types>
        REFERENCE ON DELETE REJECT
        COMMENT 'Type de ressource partagée (référence à la table share_types).';

-- ============================================================================
-- RELATIONS
-- ============================================================================

DEFINE FIELD IF NOT EXISTS resource ON davshares 
    TYPE record<calendars>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence à la ressource partagée (le calendrier).';

DEFINE FIELD IF NOT EXISTS principaluri ON davshares
    TYPE string
    COMMENT 'URI du principal avec qui la ressource est partagée (ex: "users/jane", "groups/devs").';
    
-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_davshare_unique ON davshares
    FIELDS resource, principaluri, content.share_type, identity.publicuri UNIQUE
    COMMENT 'Assure l''unicité du partage pour une ressource et un principal donnés.';

DEFINE INDEX IF NOT EXISTS idx_davshare_resource_type ON davshares
    FIELDS resource, content.share_type
    COMMENT 'Index pour retrouver rapidement les partages d''une ressource.';

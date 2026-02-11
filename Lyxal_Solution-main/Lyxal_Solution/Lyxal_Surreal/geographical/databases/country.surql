-- =============================================================================================
-- |
-- | Fichier     : country.surql
-- | Module      : geographical
-- | Description : Définit la table `country` qui contient le référentiel des pays (ISO 3166-1).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS country 
    TYPE NORMAL 
    SCHEMAFULL 
    COMMENT 'Référentiel des pays (ISO 3166). L\'ID est le code alpha-2 (ex: fr, us).'
    PERMISSIONS 
        FOR select FULL;

-- ------------------------------
-- CHAMPS
-- ------------------------------

-- Clé i18n pour le nom traduisible du pays.
DEFINE FIELD IF NOT EXISTS key.name ON TABLE country 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour le nom du pays.';

-- Code ISO 3166-1 alpha-3.
DEFINE FIELD IF NOT EXISTS code3 ON TABLE country 
    TYPE string
    ASSERT string::len($value) == 3
    COMMENT 'Code ISO 3166-1 alpha-3 (ex: FRA).';

-- Indicatif téléphonique international.
DEFINE FIELD IF NOT EXISTS phoneCode ON TABLE country 
    TYPE string
    COMMENT 'Indicatif téléphonique (ex: +33).';

-- Région géographique parente.
DEFINE FIELD IF NOT EXISTS region ON TABLE country 
    TYPE option<record<region>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Région géographique (référence region).';

-- Format d'adresse par défaut pour ce pays.
DEFINE FIELD IF NOT EXISTS addressFormat ON TABLE country 
    TYPE record<i18n_address_format>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence au format d\'adresse utilisé dans le pays.';

-- Coordonnées géographiques (Point GeoJSON)
DEFINE FIELD IF NOT EXISTS location ON TABLE country
    TYPE point
    COMMENT 'Coordonnées géographiques du centre du pays (longitude, latitude).';

-- Frontières (Polygon GeoJSON)
DEFINE FIELD IF NOT EXISTS boundary ON TABLE country
    TYPE option<geometry<polygon>>
    COMMENT 'Frontières géographiques du pays (polygone GeoJSON).';

-- Capitale
DEFINE FIELD IF NOT EXISTS capital ON TABLE country
    TYPE option<record<city>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence à la ville capitale du pays.';

-- Devise
DEFINE FIELD IF NOT EXISTS currency ON TABLE country
    TYPE record<i18n_currency>
    REFERENCE ON DELETE REJECT
    COMMENT 'Devise officielle du pays.';

-- Gentilé (nom des habitants)
DEFINE FIELD IF NOT EXISTS nationality ON TABLE country
    TYPE option<record<nationality>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence au gentilé du pays (table nationality).';

-- Fuseaux horaires
DEFINE FIELD IF NOT EXISTS timezones ON TABLE country
    TYPE array<record<timezone>>
    COMMENT 'Liste des fuseaux horaires du pays.';

DEFINE FIELD IF NOT EXISTS timezones.* ON TABLE country
    TYPE record<timezone>;

-- Statut d'activité du pays.
DEFINE FIELD IF NOT EXISTS isActive ON TABLE country 
    TYPE bool 
    DEFAULT true
    COMMENT 'Indique si le pays est actuellement utilisé ou visible.';

-- Référence vers l'asset du drapeau.
DEFINE FIELD IF NOT EXISTS flag ON TABLE country
    TYPE record<system_asset>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers l\'asset du drapeau (table system_asset).';

-- ------------------------------
-- INDEX
-- ------------------------------

-- Index d'unicité sur le code ISO alpha-3.
DEFINE INDEX IF NOT EXISTS idx_country_code3_unique 
    ON TABLE country 
    FIELDS code3 UNIQUE;


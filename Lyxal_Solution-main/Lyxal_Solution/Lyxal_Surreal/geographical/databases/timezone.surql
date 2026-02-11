-- =============================================================================================
-- |
-- | Fichier     : timezone.surql
-- | Module      : geographical
-- | Description : Définit la table `timezone` qui contient les fuseaux horaires IANA.
-- |
-- =============================================================================================

-- -----------------------------------------------------------------------------
-- | TABLE : timezone
-- -----------------------------------------------------------------------------
DEFINE TABLE IF NOT EXISTS timezone
    TYPE NORMAL
    SCHEMAFULL
    COMMENT 'Référentiel des fuseaux horaires IANA (ex: "Europe/Paris").'
    PERMISSIONS
        FOR select FULL;

DEFINE FIELD IF NOT EXISTS zoneName ON TABLE timezone
    TYPE string
    COMMENT 'Le nom complet du fuseau horaire IANA (ex: "Europe/Paris").';

DEFINE FIELD IF NOT EXISTS gmtOffset ON TABLE timezone
    TYPE number
    COMMENT 'Décalage par rapport à GMT en secondes.';

DEFINE FIELD IF NOT EXISTS gmtOffsetName ON TABLE timezone
    TYPE string
    COMMENT 'Nom du décalage GMT (ex: "UTC+04:30").';

DEFINE FIELD IF NOT EXISTS abbreviation ON TABLE timezone
    TYPE string
    COMMENT 'Abréviation du fuseau horaire (ex: "AFT").';

DEFINE FIELD IF NOT EXISTS key.name ON TABLE timezone
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom complet du fuseau horaire (ex: "Afghanistan Time").';

DEFINE INDEX idx_zoneName_unique ON TABLE timezone FIELDS zoneName UNIQUE
COMMENT 'Index pour garantir l\'unicité du nom du fuseau horaire.';
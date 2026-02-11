-- =============================================================================================
-- |
-- | Fichier     : i18n_address_format.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_address_format` pour les gabarits d'adresses.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_address_format
    TYPE NORMAL 
    SCHEMAFULL 
    COMMENT 'Référentiel des formats d\'adresse par pays. L\'ID est un code descriptif (ex: fr, us).'
    PERMISSIONS 
        FOR select FULL;

-- ------------------------------
-- CHAMPS
-- ------------------------------

-- Le gabarit d'affichage de l'adresse.
DEFINE FIELD IF NOT EXISTS template ON TABLE i18n_address_format 
    TYPE object
    COMMENT 'Objet décrivant les lignes du format d\'adresse. Ex: { line1: "{name}", line2: "{street}" }';

-- Expression régulière pour valider le code postal.
DEFINE FIELD IF NOT EXISTS postalCodeRegex ON TABLE i18n_address_format 
    TYPE option<string>
    COMMENT 'Regex de validation pour le code postal.';

-- Indique si l'état ou la région est obligatoire.
DEFINE FIELD IF NOT EXISTS requiresState ON TABLE i18n_address_format 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si l\'état/province/région est un champ obligatoire.';

-- Indique si le code postal doit être en majuscules.
DEFINE FIELD IF NOT EXISTS uppercasePostalCode ON TABLE i18n_address_format 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si le code postal doit être formaté en majuscules.';

-- Un exemple d'adresse formatée.
DEFINE FIELD IF NOT EXISTS example ON TABLE i18n_address_format 
    TYPE option<string>
    COMMENT 'Exemple d\'une adresse réelle formatée selon ce gabarit.';


-- =============================================================================================
-- |
-- | Fichier     : asset.surql
-- | Module      : base
-- | Description : Dictionnaire immuable des ressources externes (assets) utilisées par
-- |               l'application, comme les icônes hébergées sur le CDN.
-- |
-- | Remarques   :
-- |   - L'ID de l'enregistrement (ex: `asset:flag_fr`) sert d'identifiant métier unique.
-- |   - Les enregistrements sont gérés via des fichiers de migration (seeds).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS asset SCHEMAFULL
    COMMENT 'Catalogue des ressources externes statiques (assets CDN).'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- Le `path` est le chemin relatif de la ressource sur le CDN.
-- L'application concatènera ce chemin avec l'URL de base du CDN.
-- Exemples: "/flags/fr.svg", "/logos/logo_dark.svg"
DEFINE FIELD IF NOT EXISTS path ON TABLE asset
    TYPE string
    COMMENT 'Chemin relatif du fichier sur le CDN (ex: "/flags/fr.svg").';

-- Une description pour aider les développeurs.
DEFINE FIELD IF NOT EXISTS description ON TABLE asset
    TYPE string
    COMMENT 'Description fonctionnelle de la ressource.';
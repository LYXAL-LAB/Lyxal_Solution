-- =============================================================================================
-- |
-- | Fichier     : continent_i18n_key_translate_seeds.surql
-- | Module      : geographical
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les noms des continents.
-- |
-- =============================================================================================

-- Afrique
RELATE i18n_key:continent_af_name->i18n_translation->i18n_language:fr SET text = 'Afrique';
RELATE i18n_key:continent_af_name->i18n_translation->i18n_language:en SET text = 'Africa';
RELATE i18n_key:continent_af_name->i18n_translation->i18n_language:es SET text = 'África';
RELATE i18n_key:continent_af_name->i18n_translation->i18n_language:de SET text = 'Afrika';
RELATE i18n_key:continent_af_name->i18n_translation->i18n_language:it SET text = 'Africa';

-- Antarctique
RELATE i18n_key:continent_an_name->i18n_translation->i18n_language:fr SET text = 'Antarctique';
RELATE i18n_key:continent_an_name->i18n_translation->i18n_language:en SET text = 'Antarctica';
RELATE i18n_key:continent_an_name->i18n_translation->i18n_language:es SET text = 'Antártida';
RELATE i18n_key:continent_an_name->i18n_translation->i18n_language:de SET text = 'Antarktis';
RELATE i18n_key:continent_an_name->i18n_translation->i18n_language:it SET text = 'Antartide';

-- Asie
RELATE i18n_key:continent_as_name->i18n_translation->i18n_language:fr SET text = 'Asie';
RELATE i18n_key:continent_as_name->i18n_translation->i18n_language:en SET text = 'Asia';
RELATE i18n_key:continent_as_name->i18n_translation->i18n_language:es SET text = 'Asia';
RELATE i18n_key:continent_as_name->i18n_translation->i18n_language:de SET text = 'Asien';
RELATE i18n_key:continent_as_name->i18n_translation->i18n_language:it SET text = 'Asia';

-- Europe
RELATE i18n_key:continent_eu_name->i18n_translation->i18n_language:fr SET text = 'Europe';
RELATE i18n_key:continent_eu_name->i18n_translation->i18n_language:en SET text = 'Europe';
RELATE i18n_key:continent_eu_name->i18n_translation->i18n_language:es SET text = 'Europa';
RELATE i18n_key:continent_eu_name->i18n_translation->i18n_language:de SET text = 'Europa';
RELATE i18n_key:continent_eu_name->i18n_translation->i18n_language:it SET text = 'Europa';

-- Amérique du Nord
RELATE i18n_key:continent_na_name->i18n_translation->i18n_language:fr SET text = 'Amérique du Nord';
RELATE i18n_key:continent_na_name->i18n_translation->i18n_language:en SET text = 'North America';
RELATE i18n_key:continent_na_name->i18n_translation->i18n_language:es SET text = 'América del Norte';
RELATE i18n_key:continent_na_name->i18n_translation->i18n_language:de SET text = 'Nordamerika';
RELATE i18n_key:continent_na_name->i18n_translation->i18n_language:it SET text = 'Nord America';

-- Océanie
RELATE i18n_key:continent_oc_name->i18n_translation->i18n_language:fr SET text = 'Océanie';
RELATE i18n_key:continent_oc_name->i18n_translation->i18n_language:en SET text = 'Oceania';
RELATE i18n_key:continent_oc_name->i18n_translation->i18n_language:es SET text = 'Oceanía';
RELATE i18n_key:continent_oc_name->i18n_translation->i18n_language:de SET text = 'Ozeanien';
RELATE i18n_key:continent_oc_name->i18n_translation->i18n_language:it SET text = 'Oceania';

-- Amérique du Sud
RELATE i18n_key:continent_sa_name->i18n_translation->i18n_language:fr SET text = 'Amérique du Sud';
RELATE i18n_key:continent_sa_name->i18n_translation->i18n_language:en SET text = 'South America';
RELATE i18n_key:continent_sa_name->i18n_translation->i18n_language:es SET text = 'América del Sur';
RELATE i18n_key:continent_sa_name->i18n_translation->i18n_language:de SET text = 'Südamerika';
RELATE i18n_key:continent_sa_name->i18n_translation->i18n_language:it SET text = 'Sud America';

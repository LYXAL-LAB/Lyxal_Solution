-- ============================================================================
-- BUNNY.NET API - Get Country By Code
-- ============================================================================
-- Description : Récupère un pays spécifique par son code ISO
-- Dépendances : fn::bunny_get_country_list()
-- ============================================================================

-- ============================================================================
-- FUNCTION : fn::bunny_get_country_by_code
-- ============================================================================
-- Description : Récupère un pays spécifique par son code ISO
-- Paramètres  : $iso_code (string) - Code ISO pays (ex: 'FR', 'US')
-- ============================================================================

DEFINE FUNCTION IF NOT EXISTS fn::bunny_get_country_by_code($iso_code: string) {
  
  -- Récupérer depuis la table locale (si synchronisée)
  LET $country = (SELECT * FROM bunny_country WHERE iso_code = $iso_code LIMIT 1);
  
  IF array::len($country) > 0 {
    RETURN {
      success: true,
      country: {
        iso_code: $country[0].iso_code,
        name: $country[0].name,
        is_eu: $country[0].is_eu,
        tax_rate: $country[0].tax_rate,
        tax_prefix: $country[0].tax_prefix,
        flag_url: $country[0].flag_url,
        pop_list: $country[0].pop_list
      }
    };
  };
  
  -- Sinon, récupérer depuis l'API et chercher
  LET $result = fn::bunny_get_country_list();
  
  IF $result.success == false {
    RETURN $result;
  };
  
  -- Chercher le pays dans la liste (boucle manuelle)
  FOR $c IN $result.countries {
    IF $c.IsoCode == $iso_code {
      RETURN {
        success: true,
        country: {
          iso_code: $c.IsoCode,
          name: $c.Name,
          is_eu: $c.IsEU,
          tax_rate: $c.TaxRate,
          tax_prefix: $c.TaxPrefix,
          flag_url: $c.FlagUrl,
          pop_list: $c.PopList
        }
      };
    };
  };
  
  -- Si on arrive ici, le pays n'a pas été trouvé
  RETURN {
    success: false,
    error: 'not_found',
    message: 'Country with ISO code ' + $iso_code + ' not found'
  };
};


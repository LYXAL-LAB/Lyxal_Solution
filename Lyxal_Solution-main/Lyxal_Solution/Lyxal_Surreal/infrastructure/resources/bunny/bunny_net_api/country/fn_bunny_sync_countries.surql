-- ============================================================================
-- BUNNY.NET API - Sync Countries
-- ============================================================================
-- Description : Synchronise la liste des pays dans la table locale
-- Dépendances : fn::bunny_get_country_list()
-- ============================================================================

-- ============================================================================
-- FUNCTION : fn::bunny_sync_countries
-- ============================================================================
-- Description : Synchronise la liste des pays dans une table locale
-- ============================================================================

DEFINE FUNCTION IF NOT EXISTS fn::bunny_sync_countries() {
  
  -- Récupérer la liste des pays
  LET $result = fn::bunny_get_country_list();
  
  IF $result.success == false {
    RETURN $result;
  };
  
  -- Supprimer les anciens enregistrements
  DELETE bunny_country;
  
  -- Insérer chaque pays dans la table
  FOR $country IN $result.countries {
    CREATE bunny_country CONTENT {
      iso_code: $country.IsoCode,
      name: $country.Name,
      is_eu: $country.IsEU,
      tax_rate: $country.TaxRate,
      tax_prefix: $country.TaxPrefix,
      flag_url: $country.FlagUrl,
      pop_list: $country.PopList,
      metadata: {
        synced_at: time::now()
      }
    };
  };
  
  -- Compter les pays insérés directement depuis la table
  LET $synced_count = (SELECT count() FROM bunny_country GROUP ALL)[0].count;
  
  RETURN {
    success: true,
    synced_count: $synced_count,
    synced_at: time::now()
  };
};


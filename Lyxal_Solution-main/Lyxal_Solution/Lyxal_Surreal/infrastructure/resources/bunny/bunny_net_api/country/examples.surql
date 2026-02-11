-- ============================================================================
-- EXEMPLES PRATIQUES - Bunny Country API
-- ============================================================================

-- ============================================================================
-- EXEMPLE 1 : Récupérer et afficher tous les pays
-- ============================================================================

-- Fetch direct depuis l'API
LET $result = fn::bunny_get_country_list();

-- Afficher uniquement les noms
RETURN $result.countries.map(|c| c.Name);


-- ============================================================================
-- EXEMPLE 2 : Synchroniser et utiliser la table locale
-- ============================================================================

-- Synchroniser
fn::bunny_sync_countries();

-- Lister tous les pays EU
SELECT 
  name,
  iso_code,
  tax_rate,
  flag_url
FROM bunny_country 
WHERE is_eu = true 
ORDER BY name;


-- ============================================================================
-- EXEMPLE 3 : Calculer le prix TTC par pays
-- ============================================================================

LET $calculate_price = function($iso_code, $price_ht) {
  LET $country = fn::bunny_get_country_by_code($iso_code);
  
  IF $country.success == false THEN
    RETURN { error: 'Country not found' };
  END;
  
  LET $tax_rate = $country.country.tax_rate || 0;
  LET $tax_amount = $price_ht * ($tax_rate / 100);
  LET $price_ttc = $price_ht + $tax_amount;
  
  RETURN {
    country: $country.country.name,
    price_ht: $price_ht,
    tax_rate: $tax_rate,
    tax_amount: math::round($tax_amount * 100) / 100,
    price_ttc: math::round($price_ttc * 100) / 100,
    currency: 'USD'
  };
};

-- Tester avec différents pays
RETURN {
  france: $calculate_price('FR', 100),
  usa: $calculate_price('US', 100),
  germany: $calculate_price('DE', 100),
  uk: $calculate_price('GB', 100)
};


-- ============================================================================
-- EXEMPLE 4 : Grouper les pays par continent avec stats
-- ============================================================================

-- Après synchronisation
SELECT 
  continent_name,
  count() AS countries_count,
  math::round(math::mean(tax_rate) * 100) / 100 AS avg_tax_rate,
  math::max(tax_rate) AS max_tax_rate,
  math::min(tax_rate) AS min_tax_rate
FROM bunny_country
GROUP BY continent_name
ORDER BY countries_count DESC;


-- ============================================================================
-- EXEMPLE 5 : Top 10 pays avec le plus de taxes
-- ============================================================================

SELECT 
  name,
  iso_code,
  tax_rate,
  tax_prefix
FROM bunny_country 
WHERE tax_rate > 0
ORDER BY tax_rate DESC 
LIMIT 10;


-- ============================================================================
-- EXEMPLE 6 : Créer un sélecteur de pays pour formulaire frontend
-- ============================================================================

-- Format optimisé pour <select> HTML
SELECT {
  value: iso_code,
  label: name,
  flag: flag_url,
  tax_rate: tax_rate,
  is_eu: is_eu
} AS country
FROM bunny_country 
ORDER BY name;


-- ============================================================================
-- EXEMPLE 7 : Vérifier si un pays est dans l'UE (pour RGPD)
-- ============================================================================

LET $check_eu = function($iso_code) {
  LET $country = fn::bunny_get_country_by_code($iso_code);
  
  IF $country.success == false THEN
    RETURN { error: 'Country not found' };
  END;
  
  RETURN {
    country: $country.country.name,
    is_eu: $country.country.is_eu,
    rgpd_applies: $country.country.is_eu,
    message: IF $country.country.is_eu THEN 
      'RGPD s\'applique - collecte de consentement requise' 
    ELSE 
      'RGPD ne s\'applique pas directement' 
    END
  };
};

-- Tester
RETURN {
  france: $check_eu('FR'),
  usa: $check_eu('US'),
  switzerland: $check_eu('CH')
};


-- ============================================================================
-- EXEMPLE 8 : Filtrer les pays par fourchette de taxes
-- ============================================================================

-- Pays avec TVA entre 15% et 25%
SELECT 
  name,
  iso_code,
  tax_rate,
  continent_name
FROM bunny_country 
WHERE tax_rate >= 15 AND tax_rate <= 25
ORDER BY tax_rate DESC;


-- ============================================================================
-- EXEMPLE 9 : Créer une table de conversion de prix multi-pays
-- ============================================================================

LET $base_price = 99.99;

SELECT {
  country: name,
  code: iso_code,
  price_ht: $base_price,
  tax_rate: tax_rate,
  price_ttc: math::round(($base_price + ($base_price * tax_rate / 100)) * 100) / 100
} AS pricing
FROM bunny_country 
WHERE is_eu = true
ORDER BY name;


-- ============================================================================
-- EXEMPLE 10 : Recherche full-text sur les noms de pays
-- ============================================================================

-- Rechercher tous les pays contenant "united"
SELECT * FROM bunny_country 
WHERE string::lowercase(name) CONTAINS 'united';

-- Rechercher par continent
SELECT * FROM bunny_country 
WHERE string::lowercase(continent_name) == 'europe'
ORDER BY name;


-- ============================================================================
-- EXEMPLE 11 : Créer un rapport d'audit fiscal par région
-- ============================================================================

SELECT 
  continent_name AS region,
  array::group(name) AS countries,
  count() AS total_countries,
  math::round(math::mean(tax_rate) * 100) / 100 AS avg_tax,
  count(is_eu = true) AS eu_countries,
  count(tax_rate > 0) AS countries_with_tax
FROM bunny_country
GROUP BY continent_name
ORDER BY total_countries DESC;


-- ============================================================================
-- EXEMPLE 12 : Intégration avec table customers
-- ============================================================================

-- Enrichir les customers avec les infos pays
SELECT 
  customers.id,
  customers.name,
  customers.country_code,
  bunny_country.name AS country_name,
  bunny_country.tax_rate,
  bunny_country.is_eu
FROM customers
LEFT JOIN bunny_country ON bunny_country.iso_code = customers.country_code;


-- ============================================================================
-- EXEMPLE 13 : Dashboard de monitoring des pays
-- ============================================================================

RETURN {
  total_countries: (SELECT count() FROM bunny_country GROUP ALL)[0].count,
  eu_countries: (SELECT count() FROM bunny_country WHERE is_eu = true GROUP ALL)[0].count,
  continents: (SELECT continent_name, count() FROM bunny_country GROUP BY continent_name),
  avg_tax_rate: (SELECT math::round(math::mean(tax_rate) * 100) / 100 AS avg FROM bunny_country GROUP ALL)[0].avg,
  last_sync: (SELECT metadata.synced_at FROM bunny_country ORDER BY metadata.synced_at DESC LIMIT 1)[0].metadata.synced_at
};


-- ============================================================================
-- EXEMPLE 14 : Valider un code pays avant insertion
-- ============================================================================

LET $validate_country = function($iso_code) {
  LET $country = fn::bunny_get_country_by_code($iso_code);
  
  RETURN {
    valid: $country.success,
    country: IF $country.success THEN $country.country ELSE NONE END
  };
};

-- Utiliser dans une insertion
LET $customer_country = 'FR';
LET $validation = $validate_country($customer_country);

IF $validation.valid == false THEN
  THROW 'Invalid country code: ' + $customer_country;
END;

-- Insérer le customer avec validation OK
CREATE customer CONTENT {
  name: 'Jean Dupont',
  country_code: $customer_country,
  country_name: $validation.country.name,
  tax_rate: $validation.country.tax_rate
};


-- ============================================================================
-- EXEMPLE 15 : Lister les pays avec Points of Presence (PoP)
-- ============================================================================

-- Pays avec serveurs edge Bunny
SELECT 
  name,
  iso_code,
  pop_list,
  array::len(pop_list) AS pop_count
FROM bunny_country 
WHERE pop_list != NONE AND array::len(pop_list) > 0
ORDER BY pop_count DESC, name;

-- Top 10 pays avec le plus de PoP
SELECT 
  name,
  iso_code,
  pop_list,
  array::len(pop_list) AS pop_count
FROM bunny_country 
WHERE pop_list != NONE
ORDER BY pop_count DESC
LIMIT 10;


-- ============================================================================
-- EXEMPLE 16 : Export CSV des pays pour analyse externe
-- ============================================================================

-- Format pour export Excel/Google Sheets
SELECT 
  iso_code AS "Code ISO",
  name AS "Pays",
  continent_name AS "Continent",
  is_eu AS "UE",
  tax_rate AS "Taux TVA (%)",
  tax_prefix AS "Préfixe Taxe",
  array::len(pop_list) AS "Nombre PoP"
FROM bunny_country 
ORDER BY continent_name, name;


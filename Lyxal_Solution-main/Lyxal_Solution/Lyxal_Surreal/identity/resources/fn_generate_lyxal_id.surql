-- =================================================================================================
-- FUNCTION : Génération lyxal_id unique
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::generate_lyxal_id($first: string, $last: string) {
  -- Nettoie et formate le prénom et nom
  LET $first_clean = string::lowercase(string::replace(string::trim($first), ' ', '_'));
  LET $last_clean = string::lowercase(string::replace(string::trim($last), ' ', '_'));
  
  -- Génère un identifiant aléatoire court
  LET $random = string::slice(rand::uuid::v4(), 0, 8);
  
  -- Combine : prenom_nom_random
  LET $lyxal_id = string::concat($first_clean, '_', $last_clean, '_', $random);
  
  -- Vérifie l'unicité
  LET $existing = SELECT * FROM identity WHERE lyxal_id = $lyxal_id;
  
  -- Si existe déjà, régénère (récursif)
  IF array::len($existing) > 0 {
    RETURN fn::generate_lyxal_id($first, $last);
  };
  
  RETURN $lyxal_id;
};


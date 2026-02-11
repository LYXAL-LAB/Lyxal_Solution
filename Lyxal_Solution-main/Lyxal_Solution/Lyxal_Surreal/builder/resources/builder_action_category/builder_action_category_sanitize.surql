-- =============================================================================================
-- |
-- | Fichier : builder_action_category_sanitize.surql
-- | Module : builder / action_category
-- | Description : Nettoie une valeur selon son type pour le module builder_action_category.
-- | Paramètres :
-- |   - $value_type: string ('code' | 'name' | 'description')
-- |   - $value: string (valeur à nettoyer)
-- |
-- | Comportement :
-- |   - 'code' :
-- |       * espaces, '_' et '-' → '.'
-- |       * conversion en MAJUSCULES
-- |       * filtre A-Z 0-9 et '.' seulement
-- |       * compresser '..' → '.'
-- |       * supprimer '.' au début et à la fin
-- |   - 'name' : autorise a-zA-Z0-9._- ; normalise les espaces
-- |   - 'description' : autorise texte avec ponctuation simple ; normalise les espaces
-- |
-- | Gestion d'erreur :
-- |   - type inconnu → { success:false, reason_code:'TYPE.INVALID' }
-- |   - chaîne vide après nettoyage →
-- |       * name → 'NAME.REQUIRED'
-- |       * description → 'DESCRIPTION.REQUIRED'
-- |       * code → 'CODE.REQUIRED'
-- |
-- | Retour : { success, reason_code, data }
-- |   - data.sanitized présent uniquement en cas de succès
-- |   - data contient toujours { table:'builder_action_category', value_type, value, ... }
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_action_category_sanitize(
  $value_type: string,
  $value: string
) {
  -- Normaliser l'entrée
  LET $input = string::trim($value);

  -- on construit le return standard
  LET $success = false;
  LET $reason_code = '';
  LET $data = { table: 'builder_action_category', value_type: $value_type, value: $value };

  -- Gestion du type inconnu
  IF $value_type NOT IN ['code','name','description'] {
    RETURN {
      success: false,
      reason_code: 'TYPE.INVALID',
      data: { table: 'builder_action_category', value_type: $value_type, value: $value }
    };
  };

  -- Nettoyage spécifique selon le type
  LET $clean =
    IF $value_type = 'code' {
      -- Souplesse: espaces/underscore/tiret deviennent '.'
      LET $s1 = string::replace($input, <regex>'[\\s_\\-]+', '.');
      -- Majuscules obligatoires
      LET $s2 = string::uppercase($s1);
      -- Garder uniquement A-Z, 0-9 et '.'
      LET $s3 = string::replace($s2, <regex>'[^A-Z0-9.]', '');
      -- Compresser les points consécutifs
      LET $s4 = string::replace($s3, <regex>'\\.{2,}', '.');
      -- Retirer les points en début et fin
      LET $s5 = string::replace($s4, <regex>'^\\.+', '');
      LET $s6 = string::replace($s5, <regex>'\\.+$', '');
      string::trim($s6)
    }
    ELSE IF $value_type = 'name' {
      LET $r = <regex>'[^a-zA-Z0-9._-]';
      LET $n1 = string::replace($input, $r, '');
      LET $n2 = string::replace($n1, <regex>'\\s+', ' ');
      string::trim($n2)
    }
    ELSE IF $value_type = 'description' {
      LET $r = <regex>'[^\\w\\s\\-\\.\\/:\\(\\)\\[\\],]';
      LET $d1 = string::replace($input, $r, '');
      LET $d2 = string::replace($d1, <regex>'\\s+', ' ');
      string::trim($d2)
    };

  -- Résultat vide => invalide selon le type
  IF string::len($clean) = 0 {
    IF $value_type = 'name' {
      LET $success = false;
      LET $reason_code = 'NAME.REQUIRED';
      LET $data = { table: 'builder_action_category', value_type: $value_type, value: $value } ;    
    }
    ELSE IF $value_type = 'description' {
      LET $success = false;
      LET $reason_code = 'DESCRIPTION.REQUIRED';
      LET $data = { table: 'builder_action_category', value_type: $value_type, value: $value } ;    
    }
    ELSE IF $value_type = 'code' {
      LET $success = false;
      LET $reason_code = 'CODE.REQUIRED';
      LET $data = { table: 'builder_action_category', value_type: $value_type, value: $value } ;    
    }; 
  }
  ELSE {
    LET $success = true;
    LET $reason_code = 'RESOLVE.SUCCESS';
    LET $data = { table: 'builder_action_category', value_type: $value_type, value: $value, 
    sanitized: $clean } ;    
  };
  
  -- Retourner le résultat
  RETURN {
    success: $success,
    reason_code: $reason_code,
    data: $data
  };

}
COMMENT 'Sanitize une valeur unique selon un pattern: code (majuscules, .), name, 
description(text)'
PERMISSIONS FULL;
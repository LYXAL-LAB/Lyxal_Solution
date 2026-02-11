-- =================================================================================================
-- FUNCTION : Vérification force du mot de passe
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::is_password_strong($password: string) {
  -- Au moins 8 caractères
  LET $length_ok = string::len($password) >= 8;
  
  -- Contient au moins une majuscule
  LET $has_upper = string::lowercase($password) != $password;
  
  -- Contient au moins une minuscule
  LET $has_lower = string::uppercase($password) != $password;
  
  -- Contient au moins un chiffre
  LET $has_number = $password ~ '[0-9]';
  
  -- Contient au moins un caractère spécial
  LET $has_special = $password ~ '[!@#$%^&*()_+\-=\[\]{}|;:,.<>?/~`]';
  
  RETURN {
    valid: $length_ok AND $has_upper AND $has_lower AND $has_number AND $has_special,
    length_ok: $length_ok,
    has_upper: $has_upper,
    has_lower: $has_lower,
    has_number: $has_number,
    has_special: $has_special
  };
};


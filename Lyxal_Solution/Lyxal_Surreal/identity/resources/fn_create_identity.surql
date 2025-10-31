-- =================================================================================================
-- FUNCTION : Création utilisateur complet
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::create_identity(
  $email: string,
  $password: string,
  $first_name: string,
  $last_name: string,
  $language: option<string>,
  $timezone: option<string>
) {

  -- 1. Vérification langue et timezone
  IF $language = NONE {
    let $language = 'fr';
  };

  IF $timezone = NONE {
    let $timezone = 'europe_paris';
  };

  -- 1. Vérification prénom et nom
  IF $first_name = NONE  {
    let $error_code = 'identity_field_first_name_required';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message 
    };
  };

  -- 2. Vérification nom
  IF $last_name = NONE {
    let $error_code = 'identity_field_last_name_required';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message 
    };
  };

  -- 3. Vérification email
  IF !string::is_email($email) {
    let $error_code = 'identity_field_email_format_invalid';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message 
    };
  };

  -- 3. Vérification email disponible
  IF !fn::is_email_available($email) {
    let $error_code = 'identity_email_already_exists';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message 
    };
  };
  
  -- 4. Vérification force mot de passe
  LET $pwd_check = fn::is_password_strong($password);
  IF !$pwd_check.valid {
    let $error_code = 'identity_password_too_weak';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message,
      details: $pwd_check
    };
  };
  
  -- 5. Génération lyxal_id
  LET $lyxal_id = fn::generate_lyxal_id($first_name, $last_name);
  
  -- 6. Hash du mot de passe
  LET $password_hash = crypto::argon2::generate($password);
  
  -- 7. Token de vérification
  LET $verification_token = fn::generate_verification_token();
  LET $verification_expires = time::now() + 24h;
  
  -- 8. Création utilisateur
  LET $user = CREATE identity:$lyxal_id SET
    identity = {
      first_name = $first_name,
      last_name = $last_name,
      full_name = string::concat($first_name, ' ', $last_name)
    },
    status = identity_status:created,
    connexion = {
      email = $email,
      password_hash = $password_hash
    },
    preferences = {
      language = type::record('language', $language),
      timezone = type::record('timezone', $timezone)
    },
    security = {
      email_verification_token = $verification_token
    },
    metadata = {
      created_date = time::now(),
      email_verification_expires = $verification_expires
    };
  
  let $result_code = 'identity_created_successfully';
  let $result_data = (SELECT VALUE { success_result, severity } FROM error_code 
    WHERE id = type::record('error_code', $result_code) LIMIT 1)[0];
  let $result_message = fn::translation_get_by_key_and_language($result_code, $language, {});
  RETURN { 
    success: $result_data.success_result, 
    severity: $result_data.severity,
    result: $result_code, 
    message: $result_message.message 
  };
};


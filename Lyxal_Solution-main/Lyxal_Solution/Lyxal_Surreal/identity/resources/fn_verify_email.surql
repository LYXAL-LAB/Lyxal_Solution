-- =================================================================================================
-- FUNCTION : Vérification email
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::verify_email($lyxal_id: string, $token: string, 
$language: option<string>) {
  
  -- Vérification langue par défaut
  IF $language = NONE {
    let $language = 'fr';
  };
  
  -- Récupère l'utilisateur
  LET $user = SELECT * FROM identity WHERE id = type::record('identity', $lyxal_id) LIMIT 1;
  
  IF array::len($user) = 0 {
    let $error_code = 'identity_user_not_found';
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
  
  LET $user = $user[0];
  
  -- Vérification token
  IF $user.security.email_verification_token != $token {
    let $error_code = 'identity_invalid_token';
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
  
  -- Vérification expiration
  IF time::now() > $user.metadata.email_verification_expires {
    let $error_code = 'identity_token_expired';
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
  
  -- Mise à jour utilisateur
  UPDATE identity SET
    security.email_verification_token = NONE,
    metadata.email_verification_expires = NONE,
    metadata.verified_date = time::now(),
    status = identity_status:verified
  WHERE id = type::record('identity', $lyxal_id);
  
  let $result_code = 'identity_email_verified_successfully';
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


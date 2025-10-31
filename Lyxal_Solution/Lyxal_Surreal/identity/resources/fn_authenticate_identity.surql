-- =================================================================================================
-- FUNCTION : Authentification utilisateur
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::authenticate_identity(
  $email: string,
  $password: string,
  $ip: option<string>,
  $language: option<string>
) {
  --1. Récupère l'utilisateur
  LET $user = SELECT * FROM identity WHERE connexion.email = $email LIMIT 1; 
  IF array::len($user) = 0 {
    let $error_code = 'identity_invalid_credentials';
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
  
  -- 2. Vérification mot de passe
  IF !crypto::argon2::compare($user.connexion.password_hash, $password) {
    let $error_code = 'identity_invalid_credentials';
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
  
  -- 3. Vérification statut (necessite d'être verifié)
  IF $user.status = identity_status:created {
    let $error_code = 'identity_account_not_verified';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message,
      details: string::split($user.status, ':')[1]
    };
  };

  -- 4. Vérification statut (necessite d'être actif)
  IF $user.status = identity_status:suspended OR $user.status = identity_status:deleted 
  OR $user.status = identity_status:archived OR $user.status = identity_status:pending
  OR $user.status = identity_status:expired {
    let $error_code = 'identity_access_denied';
    let $error_data = (SELECT VALUE { success_result, severity } FROM error_code 
      WHERE id = type::record('error_code', $error_code) LIMIT 1)[0];
    let $error_message = fn::translation_get_by_key_and_language($error_code, $language, {});
    RETURN { 
      success: $error_data.success_result, 
      severity: $error_data.severity,
      error: $error_code, 
      message: $error_message.message,
      details: string::split($user.status, ':')[1]
    };
  };

  -- 5. Déterminer si première connexion
  LET $is_first_login = ($user.status = identity_status:verified);

  -- 6. Mettre à jour la dernière connexion
  LET $updated_user = (UPDATE $user.id SET
    connexion.last_login = time::now(),
    connexion.last_login_ip = $ip,
    status = IF $is_first_login THEN identity_status:active ELSE $user.status END,
    metadata.active_date = IF $is_first_login THEN time::now() 
    ELSE $user.metadata.active_date END
  RETURN AFTER)[0];

  -- 7. Authentification réussie
  let $result_code = 'identity_authenticated_successfully';
  let $result_data = (SELECT VALUE { success_result, severity } FROM error_code 
    WHERE id = type::record('error_code', $result_code) LIMIT 1)[0];
  let $result_message = fn::translation_get_by_key_and_language($result_code, $language, {});
  RETURN {
    success: $result_data.success_result,
    severity: $result_data.severity,
    result: $result_code,
    message: $result_message.message,
    user: {
      lyxal_id: string::split($updated_user.id, ':')[1],
      email: $updated_user.connexion.email,
      first_name: $updated_user.identity.first_name,
      last_name: $updated_user.identity.last_name,
      full_name: $updated_user.identity.full_name,
      avatar: $updated_user.avatar,
      language: $updated_user.preferences.language,
      timezone: $updated_user.preferences.timezone,
      status: $updated_user.status
    }
  };
};


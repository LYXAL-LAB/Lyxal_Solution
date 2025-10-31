DEFINE FUNCTION IF NOT EXISTS fn::builder_action_get_by_code(
  $pattern_name: string,
  $code: string,
  $langue_id: string,
  $parent_run_id: option<string>,
  $user_id: option<string>
) {

  -- paramètres par défaut
  LET $code_type = 'get_by_code';
  LET $run_id = rand::uuid();
  LET $parent_run_id = $parent_run_id OR NONE;

  -- on vérifie que la langue existe
  LET $langue_result = fn::builder_language_validate($langue_id, $run_id);
  IF $langue_result.success = false {
    RETURN $langue_result;
  }
  ELSE {
    LET $langue_id_result = $langue_result.data.langue_id;
  };

  -- on verifie le pattern_name
  LET $pattern_name_result = fn::builder_pattern_conformity($code_type, $pattern_name, $langue_id, 
  $run_id, $user_id);
  IF $pattern_name_result.success = false {
    RETURN $pattern_name_result;
  };

  -- on récupère l'action
  LET $action = SELECT * FROM builder_action WHERE code = $code AND language_id = $langue_id_result;
  -- si l'action n'existe pas
  IF array::len($action) = 0 {
    -- si le pattern_name est verify_by_code on retourne la réussite
    IF $pattern_name = 'verify_by_code' {
        LET $success_result = fn::builder_error_get_by_code('get_by_code','CODE.VALID', 
        $langue_id,$run_id, { code: $code });
        LET $_log = fn::builder_log_helper('create', $success_result, $parent_run_id);
        RETURN $success_result;
    }
    -- si le pattern_name est get_by_code on retourne l'erreur
    ELSE IF $pattern_name = 'get_by_code' {
        LET $error_result = fn::builder_error_get_by_code('get_by_code','CODE.NOT.FOUND', 
        $langue_id,$run_id, { code: $code });
        LET $_log = fn::builder_log_helper('create', $error_result, $parent_run_id);
        RETURN $error_result;
    };
  }
  -- si l'action existe 
  ELSE {
    -- si le pattern_name est verify_by_code on retourne l'erreur
    IF $pattern_name = 'verify_by_code' {
        LET $error_result = fn::builder_error_get_by_code('get_by_code','CODE.ALREADY.EXISTS',
        $langue_id,$run_id, { code: $code });
        LET $_log = fn::builder_log_helper('create', $error_result, $parent_run_id);
        RETURN $error_result;
    }
    -- si le pattern_name est get_by_code on retourne la réussite
    ELSE IF $pattern_name = 'get_by_code' {
        LET $success_result = fn::builder_error_get_by_code('get_by_code','CODE.FOUND', 
        $langue_id,$run_id, { code: $code });
        LET $_log = fn::builder_log_helper('create', $success_result, $parent_run_id);
    RETURN $success_result;
    };
  };
}
COMMENT 'Récupère une clé action par son code'
PERMISSIONS FULL;
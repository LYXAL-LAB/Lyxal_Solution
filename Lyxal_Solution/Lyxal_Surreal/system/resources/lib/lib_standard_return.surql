-- =============================================================================================
-- |
-- | Fichier : lib_standard_return.surql
-- | Module : lib
-- | Description : Fonction utilitaire centralisée pour gérer tous les retours d'API.
-- |               Elle récupère un code de retour, loggue l'événement si nécessaire,
-- |               traduit le message, et formate la réponse finale.
-- |
-- | Paramètres :
-- |   - $reason_code: string (Code du retour)
-- |   - $operation: object
-- |   - $langue_id: string
-- |   - $context: object (Contient les données pour le retour final, ex: `{ data: ... }`)
-- |   - $resource: option<object>
-- |   - $target: option<object>
-- |   - $user_id: option<string>
-- |   - $before_state: option<object>
-- |   - $after_state: option<object> (Nouvel état pour le log)
-- |   - $message_vars: option<object>
-- |   - $meta: option<object>
-- |
-- | Comportement :
-- |   1. Récupère l'enregistrement du code de retour.
-- |   2. Loggue l'événement via `fn::log_create_record`.
-- |   3. Traduit le message.
-- |   4. Retourne une réponse complète basée sur les données du code de retour.
-- |
-- =============================================================================================
DEFINE FUNCTION fn::lib_standard_return(
  $reason_code: string,
  $operation: object,
  $langue_id: string,
  $context: object,
  $resource: option<object>,
  $target: option<object>,
  $user_id: option<string>,
  $before_state: option<object>,
  $after_state: option<object>,
  $message_vars: option<object>,
  $meta: option<object>
) {
  -- Formatage de la réponse de base pour le frontend
  LET $response_data = $context.extend({ success: false, reason_code: $reason_code });

  -- Étape 1 : Récupérer l'enregistrement du code de retour
  LET $error_rec = (SELECT * FROM type::thing('error_code', $reason_code))[0];
  IF $error_rec IS NONE {
    -- Le code de retour n'existe pas, c'est une erreur critique.
    -- On utilise un message de secours traduit.
    LET $fallback_key = "error.untranslatable.message";
    LET $fallback_translation = fn::i18n_translation_get($fallback_key, $langue_id, {});
    RETURN {
        success: false,
        message: $fallback_translation.message OR "An unexpected error occurred.",
        reason_code: $reason_code, -- On conserve le code original pour le debug
        data: $response_data
    };
  };

  -- Étape 2 : Logger l'événement (maintenant qu'on a les détails du code)
  LET $log_result = fn::log_create_record(
    { success: $error_rec.success_result, reason_key: $error_rec.id },
    $operation,
    $resource,
    $target,
    { vars: $message_vars },
    type::thing($user_id OR 'user:none'),
    $meta,
    $context, -- $data pour le log
    $before_state,
    $after_state
  );

  -- Étape 3 : Traduire le message
  LET $msg_key_str = string::split(type::string($error_rec.i18n.message), ':')[1];
  LET $translation = fn::i18n_translation_get($msg_key_str, $langue_id, $message_vars);
  
  -- Étape 4 : Déterminer le message final, avec un fallback si la traduction a échoué
  LET $final_message = IF $translation.success AND $translation.message IS NOT NONE THEN
    $translation.message
  ELSE
    -- La traduction a échoué, on utilise le message de secours
    LET $fallback_key = "error.untranslatable.message";
    LET $fallback_translation = fn::i18n_translation_get($fallback_key, $langue_id, {});
    $fallback_translation.message OR "An unexpected error occurred."
  END;
  
  -- Étape 5 : Construire la réponse finale et y attacher l'erreur de log si elle existe
  LET $final_response = {
    success: $error_rec.success_result,
    message: $final_message,
    reason_code: $reason_code,
    data: $response_data.data -- On retourne seulement le contenu de 'data' dans la réponse finale
  };

  IF $log_result.success = false {
    LET $final_response = $final_response.extend({
        log_failure_details: $log_result
    });
  }

  RETURN $final_response;
}
COMMENT 'Fonction helper centralisée pour la gestion et le retour des réponses API.'
PERMISSIONS FULL;
-- =============================================================================================
-- |
-- | Fichier : error_code_seeds.surql
-- | Module : base 
-- | Description : Seeds pour les codes d'erreur généraux et de secours du système.
-- |
-- =============================================================================================
LET $language_id = type::thing('language', 'fr');
LET $error_severity_id = type::thing('error_severity', 'error');

-- =============================================================================================
-- | Code d'erreur de secours
-- =============================================================================================
-- | Ce code est utilisé par `fn::lib_return_error` lorsqu'un `reason_code`
-- | demandé n'est pas trouvé. Il garantit qu'un message convivial est toujours
-- | retourné à l'utilisateur, même en cas d'erreur de configuration interne.
-- =============================================================================================

-- error.untranslatable
LET $key_i18n_message = type::thing('i18n_key', 'error_untranslatable_message');
CREATE $key_i18n_message;
RELATE $key_i18n_message->translation->$language_id 
SET text = 'Une erreur inattendue est survenue. Veuillez réessayer.';

CREATE type::thing('error_code', 'error_untranslatable') SET
    severity = $error_severity_id,
    success_result = false,
    i18n = { message: $key_i18n_message };

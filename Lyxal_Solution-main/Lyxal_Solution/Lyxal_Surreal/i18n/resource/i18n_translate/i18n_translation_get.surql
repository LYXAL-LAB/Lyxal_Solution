-- =============================================================================================
-- |
-- | Fichier : i18n_translation_get.surql
-- | Module : i18n / translate
-- | Description : Récupère une traduction i18n et substitue des variables. Helper sans logging.
-- | Paramètres :
-- |   - $key: string, identifiant de la clé i18n
-- |   - $langue_id: string, identifiant de langue
-- |   - $vars: option<object>, variables à substituer dans le texte (ex: { name: 'John' })
-- |
-- | Retour :
-- |   - success: bool
-- |   - reason_code: 'i18n.translation.found' | 'i18n.translation.not.found'
-- |   - message: string (texte final de la traduction avec variables remplacées)
-- |   - data: ...
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::i18n_translation_get(
    $key: string,
    $langue_id: string,
    $vars: option<object>
) {
    -- on transforme la clé en record
    LET $key_record = type::thing('builder_i18n_key', $key);
    -- on transforme la langue en record
    LET $langue_record = type::thing('i18n_language', $langue_id);
    -- on récupère la traduction
    LET $translation = SELECT * FROM builder_i18n_translation WHERE in = $key_record AND 
    out = $langue_record LIMIT 1;

    -- si la traduction n'existe pas, on retourne une erreur claire
    IF array::len($translation) = 0 {     
      RETURN { 
        success: false, 
        reason_code: 'i18n.translation.not.found',
        message: `Translation not found for key '${$key}' and language '${$langue_id}'`,
        data: { key: $key, langue_id: $langue_id }
      };
    };

    -- si la traduction existe, on procède à la substitution
    LET $message = $translation[0].text;
    IF $vars IS NOT NONE {
        FOR $entry IN object::entries($vars) {
            LET $var_key = $entry[0];
            LET $var_value = $entry[1];
            LET $placeholder = "{" + $var_key + "}";
            LET $message = string::replace($message, $placeholder, $var_value);
        }
    };

    RETURN { 
      success: true, 
      reason_code: 'i18n.translation.found',
      message: $message,
      data: { key: $key, langue_id: $langue_id, data: $translation[0] }
    };
}
COMMENT 'Récupère une traduction i18n par son code et sa langue, et substitue les variables.'
PERMISSIONS FULL;
-- =============================================================================================
-- |
-- | Fichier : builder_i18n_translation_get.surql
-- | Module : builder / translate
-- | Description : Récupère une traduction i18n (edge) par clé et langue. Helper sans logging.
-- | Paramètres :
-- |   - $key: string, identifiant de la clé i18n (suffixe)
-- |   - $langue_id: string, identifiant de langue (suffixe)
-- |
-- | Sélection :
-- |   - Requête sur l'edge `builder_i18n_translation` via in=builder_i18n_key:$key et out=i18n_language:$langue_id
-- |
-- | Retour :
-- |   - success: bool
-- |   - reason_code: 'i18n.translation.found' | 'i18n.translation.not.found'
-- |   - message: string (texte de la traduction; vide si non trouvée)
-- |   - data: edge record si trouvée, sinon { key, langue_id }
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::builder_i18n_translation_get(
    $key: string,
    $langue_id: string
) {

    -- on transforme la clé en record
    LET $key_record = type::thing('builder_i18n_key', $key);
    -- on transforme la langue en record
    LET $langue_record = type::thing('i18n_language', $langue_id);
    -- on récupère la traduction
    LET $translation = SELECT * FROM builder_i18n_translation WHERE in = $key_record AND 
    out = $langue_record LIMIT 1;
    -- si la traduction n'existe pas, on retourne l'erreur
    IF array::len($translation) = 0 {     
      LET $success = false;
      LET $reason_code = 'i18n.translation.not.found';
      LET $data = { key: $key, langue_id: $langue_id };
      RETURN { 
        success: $success, 
        reason_code: $reason_code,
        message: $message,
        data: $data 
      };
    }
    -- si la traduction existe, on retourne la traduction
    ELSE {
      LET $success = true;
      LET $reason_code = 'i18n.translation.found';
      LET $message = $translation[0].text;
      LET $data = { key: $key, langue_id: $langue_id, data: $translation[0] };
      RETURN { 
        success: $success, 
        reason_code: $reason_code,
        message: $message,
        data: $data 
      };
    };  
}
COMMENT 'Récupère une traduction i18n par son code et sa langue'
PERMISSIONS FULL;
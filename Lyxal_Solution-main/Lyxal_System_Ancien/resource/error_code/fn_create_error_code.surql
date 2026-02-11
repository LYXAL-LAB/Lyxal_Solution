DEFINE FUNCTION IF NOT EXISTS fn::create_error_code(
    $code: string, -- code de l'erreur (ex: "USER_NOT_FOUND", "INVALID_CREDENTIALS") - sera utilisé tel quel en UPPERCASE
    $message_i18n: string, -- identifiant de la clé i18n du message principal (ex: "error_code_user_not_found_message") - sera converti en record<i18n_key>
    $severity: string, -- identifiant de la sévérité (ex: "ERROR", "WARNING") - sera converti en record<error_severity>
    $success_result: bool, -- résultat booléen dérivé de severity (true si succès, false si erreur)
    $message_source: string, -- message source en langue par défaut (pour traduction)
    $label_i18n: option<string>, -- identifiant de la clé i18n du libellé (optionnel)
    $label_source: option<string>, -- libellé source en langue par défaut (pour traduction, optionnel)
    $description_i18n: option<string>, -- identifiant de la clé i18n de la description (optionnel)
    $description_source: option<string>, -- description source en langue par défaut (pour traduction, optionnel)
    $category: option<string>, -- catégorie du code d'erreur (ex: "authentication", "validation", "system")
    $recommended_action: option<string>, -- action recommandée pour résoudre l'erreur
    $payload: option<object>, -- informations complémentaires (données contextuelles, paramètres, etc.)
    $created_by: option<string> -- identifiant du créateur du code d'erreur (optionnel, défaut: "system")
) {
    -- Conventions Lyxal :
    -- - identity.code : UPPER_SNAKE_CASE (ex: USER_NOT_FOUND, INVALID_CREDENTIALS)
    -- - identity.slug : lowercase-kebab-case (ex: user-not-found, invalid-credentials)
    -- - identity.value : lowercase (ex: user_not_found, invalid_credentials)
    -- - ID record : lowercase (ex: error_code:user_not_found, error_code:invalid_credentials)

    -- Vérification des paramètres
    IF $code = NONE OR string::len(string::trim($code)) = 0 {
        RETURN { success: false, result_code: 'error_code_code_required' };
    };
    IF $message_i18n = NONE OR string::len(string::trim($message_i18n)) = 0 {
        RETURN { success: false, result_code: 'error_code_message_i18n_required' };
    };
    IF $message_source = NONE OR string::len(string::trim($message_source)) = 0 {
        RETURN { success: false, result_code: 'error_code_message_source_required' };
    };
    IF $severity = NONE OR string::len(string::trim($severity)) = 0 {
        RETURN { success: false, result_code: 'error_code_severity_required' };
    };
    IF $success_result = NONE {
        RETURN { success: false, result_code: 'error_code_success_result_required' };
    };

    -- Normalisation du code en UPPERCASE
    LET $code_clean = string::uppercase(string::trim($code));

    -- Génération du slug en lowercase-kebab-case
    LET $slug = string::lowercase(string::replace($code_clean, '_', '-'));
    
    -- Génération de la value (identique au code en lowercase avec underscores)
    LET $value = string::lowercase($code_clean);
    
    -- Génération de l'identifiant en lowercase (convention Lyxal)
    LET $id_value = string::lowercase($code_clean);
    LET $id = type::thing('error_code', $id_value);

    -- Vérification que le code d'erreur n'existe pas déjà (par code)
    LET $existing_error_code = SELECT * FROM error_code WHERE identity.code = $code_clean LIMIT 1;
    IF array::len($existing_error_code) > 0 {
        RETURN { success: false, result_code: 'error_code_already_exists' };
    };

    -- Conversion des strings en records
    LET $message_i18n_clean = string::trim($message_i18n);
    LET $message_i18n_record = type::thing('i18n_key', $message_i18n_clean);

    -- Conversion optionnelle de label_i18n
    LET $label_i18n_record = 
    IF $label_i18n != NONE AND string::len(string::trim($label_i18n)) > 0 {
        LET $label_clean = string::trim($label_i18n);
        LET $label_i18n_record = type::thing('i18n_key', $label_clean);
    }
    ELSE {
        LET $label_i18n_record = NONE;
    };

    -- Conversion de severity en record et vérification existence
    LET $severity_clean = string::uppercase(string::trim($severity));
    LET $severity_id_value = string::lowercase($severity_clean);
    LET $severity_record = type::thing('error_severity', $severity_id_value);
    LET $severity_exists = SELECT * FROM error_severity WHERE id = $severity_record LIMIT 1;
    IF array::len($severity_exists) = 0 {
        RETURN { success: false, result_code: 'error_code_severity_not_found' };
    };

    -- Conversion optionnelle de description_i18n
    LET $description_i18n_record = 
    IF $description_i18n != NONE AND string::len(string::trim($description_i18n)) > 0 {
        LET $desc_clean = string::trim($description_i18n);
        LET $description_i18n_record = type::thing('i18n_key', $desc_clean);
    }
    ELSE {
        LET $description_i18n_record =  NONE;
    };

    -- Valeur par défaut pour created_by (si non fourni)
    LET $created_by_value = IF $created_by = NONE OR string::len(string::trim($created_by)) = 0 { "system" } ELSE {$created_by};

    -- Récupération de la langue par défaut depuis i18n_config
    LET $config = SELECT config.default_language FROM i18n_config LIMIT 1;
    LET $langue_default_record = $config[0].config.default_language;

    -- Création du code d'erreur
    LET $rec = CREATE $id SET
        identity.code = $code_clean,
        identity.slug = $slug,
        identity.value = $value,
        presentation.label_i18n = $label_i18n_record,
        presentation.message_i18n = $message_i18n_record,
        presentation.description_i18n = $description_i18n_record,
        content.severity = $severity_record,
        content.payload = IF $payload != NONE THEN $payload ELSE {} END,
        content.label_source = IF $label_source != NONE AND string::len(string::trim($label_source)) > 0 THEN string::trim($label_source) ELSE NONE END,
        content.message_source = string::trim($message_source),
        content.description_source = IF $description_source != NONE AND string::len(string::trim($description_source)) > 0 THEN string::trim($description_source) ELSE NONE END,
        content.langue_default = $langue_default_record,
        config.success_result = $success_result,
        metadata.created_by = $created_by_value,
        metadata.category = $category,
        metadata.recommended_action = $recommended_action;
    
    RETURN { success: true, result_code: 'error_code_created_success', data: $rec[0] };
}
COMMENT 'Crée un code d\'erreur dans la base de données.'
PERMISSIONS NONE;


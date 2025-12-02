DEFINE FUNCTION IF NOT EXISTS fn::create_error_severity(
    $code: string, -- code de la sévérité (ex: "INFO", "WARNING", "ERROR") - sera utilisé tel quel en UPPERCASE
    $label_i18n: string, -- identifiant de la clé i18n du libellé (ex: "error_severity_info_label") - sera converti en record<i18n_key>
    $rank: number, -- poids numérique pour ordonner les niveaux (ex: 20 pour info, 40 pour error)
    $is_active: bool, -- indique si la sévérité est active (par défaut true)
    $label_source: string, -- libellé source en langue par défaut (pour traduction)
    $description_i18n: option<string>, -- identifiant de la clé i18n de la description (optionnel)
    $description_source: option<string>, -- description source en langue par défaut (pour traduction, optionnel)
    $message_i18n: option<string>, -- identifiant de la clé i18n du message générique (optionnel)
    $message_source: option<string>, -- message source en langue par défaut (pour traduction, optionnel)
    $created_by: option<string> -- identifiant du créateur de la sévérité (optionnel, défaut: "system")
) {
    -- Conventions Lyxal :
    -- - identity.code : UPPER_SNAKE_CASE (ex: INFO, WARNING, ERROR, CRITICAL)
    -- - identity.slug : lowercase-kebab-case (ex: info, warning, error, critical)
    -- - identity.value : lowercase (ex: info, warning, error, critical)
    -- - ID record : lowercase (ex: error_severity:info, error_severity:warning)

    -- Vérification des paramètres
    IF $code = NONE OR string::len(string::trim($code)) = 0 {
        RETURN { success: false, result_code: 'error_severity_code_required' };
    };
    IF $label_i18n = NONE OR string::len(string::trim($label_i18n)) = 0 {
        RETURN { success: false, result_code: 'error_severity_label_i18n_required' };
    };
    IF $label_source = NONE OR string::len(string::trim($label_source)) = 0 {
        RETURN { success: false, result_code: 'error_severity_label_source_required' };
    };
    IF $rank = NONE {
        RETURN { success: false, result_code: 'error_severity_rank_required' };
    };

    -- Normalisation du code en UPPERCASE
    LET $code_clean = string::uppercase(string::trim($code));

    -- Génération du slug en lowercase-kebab-case
    LET $slug = string::lowercase(string::replace($code_clean, '_', '-'));
    
    -- Génération de la value (identique au slug)
    LET $value = $slug;
    
    -- Génération de l'identifiant en lowercase (convention Lyxal)
    LET $id_value = string::lowercase($code_clean);
    LET $id = type::thing('error_severity', $id_value);

    -- Vérification que la sévérité n'existe pas déjà (par code)
    LET $existing_severity = SELECT * FROM error_severity WHERE identity.code = $code_clean LIMIT 1;
    IF array::len($existing_severity) > 0 {
        RETURN { success: false, result_code: 'error_severity_already_exists' };
    };

    -- Conversion des strings en records
    LET $label_i18n_clean = string::trim($label_i18n);
    LET $label_i18n_record = type::thing('i18n_key', $label_i18n_clean);

    -- Conversion optionnelle de description_i18n
    LET $description_i18n_record = 
    IF $description_i18n != NONE AND string::len(string::trim($description_i18n)) > 0 {
        LET $desc_clean = string::trim($description_i18n);
        LET $description_i18n_record = type::thing('i18n_key', $desc_clean);
    }
    ELSE {
        LET $description_i18n_record =  NONE;
    };

    -- Conversion optionnelle de message_i18n
    LET $message_i18n_record = 
    IF $message_i18n != NONE AND string::len(string::trim($message_i18n)) > 0 {
        LET $msg_clean = string::trim($message_i18n);
        LET $message_i18n_record = type::thing('i18n_key', $msg_clean);
    }
    ELSE {
        LET $message_i18n_record =  NONE;
    };

    -- Valeur par défaut pour created_by (si non fourni)
    LET $created_by_value = IF $created_by = NONE OR string::len(string::trim($created_by)) = 0 { "system" } ELSE {$created_by};

    -- Récupération de la langue par défaut depuis i18n_config
    LET $config = SELECT config.default_language FROM i18n_config LIMIT 1;
    LET $langue_default_record = $config[0].config.default_language;

    -- Création de la sévérité
    LET $rec = CREATE $id SET
        identity.code = $code_clean,
        identity.slug = $slug,
        identity.value = $value,
        presentation.label_i18n = $label_i18n_record,
        presentation.description_i18n = $description_i18n_record,
        presentation.message_i18n = $message_i18n_record,
        content.label_source = string::trim($label_source),
        content.description_source = IF $description_source != NONE AND string::len(string::trim($description_source)) > 0 THEN string::trim($description_source) ELSE NONE END,
        content.message_source = IF $message_source != NONE AND string::len(string::trim($message_source)) > 0 THEN string::trim($message_source) ELSE NONE END,
        content.langue_default = $langue_default_record,
        config.rank = $rank,
        status.is_active = $is_active,
        metadata.created_by = $created_by_value;
    
    RETURN { success: true, result_code: 'error_severity_created_success', data: $rec[0] };
}
COMMENT 'Crée une sévérité d\'erreur dans la base de données.'
PERMISSIONS NONE;
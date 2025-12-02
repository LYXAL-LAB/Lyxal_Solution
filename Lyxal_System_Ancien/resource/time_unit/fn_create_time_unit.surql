-- =============================================================================================
-- |
-- | Fichier : fn_create_time_unit.surql
-- | Module : System / Reference / time_unit
-- | Description : Fonction pour créer une unité de temps dans la table de référence `time_unit`.
-- |               Cette fonction suit le pattern modulaire Lyxal et crée automatiquement
-- |               les clés i18n via les events.
-- |
-- | Dépendances :
-- |   - time_unit (table)
-- |   - i18n_key (table)
-- |   - language (table)
-- |   - i18n_config (table)
-- =============================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::create_time_unit(
    $code: string, -- code de l'unité (ex: "DAYS", "WEEKS", "MONTHS") - sera utilisé tel quel en UPPERCASE
    $label_i18n: string, -- identifiant de la clé i18n du libellé (ex: "time_unit_days_label") - sera converti en record<i18n_key>
    $rank: number, -- ordre d'affichage (1=seconds, 2=minutes, 3=hours, 4=days, 5=weeks, 6=months, 7=years)
    $is_active: bool, -- indique si l'unité est active (par défaut true)
    $label_source: string, -- libellé source en langue par défaut (pour traduction)
    $description_i18n: option<string>, -- identifiant de la clé i18n de la description (optionnel)
    $description_source: option<string>, -- description source en langue par défaut (pour traduction, optionnel)
    $is_supported: option<bool>, -- indique si l'unité est supportée par le système (optionnel, défaut: true)
    $created_by: option<string> -- identifiant du créateur de l'unité (optionnel, défaut: "system")
) {
    -- Conventions Lyxal :
    -- - identity.code : UPPER_SNAKE_CASE (ex: SECONDS, MINUTES, HOURS, DAYS, WEEKS, MONTHS, YEARS)
    -- - identity.slug : lowercase-kebab-case (ex: seconds, minutes, hours, days, weeks, months, years)
    -- - identity.value : lowercase (ex: seconds, minutes, hours, days, weeks, months, years)
    -- - ID record : lowercase (ex: time_unit:seconds, time_unit:days)

    -- Vérification des paramètres
    IF $code = NONE OR string::len(string::trim($code)) = 0 {
        RETURN { success: false, result_code: 'time_unit_code_required' };
    };
    IF $label_i18n = NONE OR string::len(string::trim($label_i18n)) = 0 {
        RETURN { success: false, result_code: 'time_unit_label_i18n_required' };
    };
    IF $label_source = NONE OR string::len(string::trim($label_source)) = 0 {
        RETURN { success: false, result_code: 'time_unit_label_source_required' };
    };
    IF $rank = NONE {
        RETURN { success: false, result_code: 'time_unit_rank_required' };
    };

    -- Normalisation du code en UPPERCASE
    LET $code_clean = string::uppercase(string::trim($code));

    -- Génération du slug en lowercase-kebab-case
    LET $slug = string::lowercase(string::replace($code_clean, '_', '-'));
    
    -- Génération de la value (identique au slug)
    LET $value = $slug;
    
    -- Génération de l'identifiant en lowercase (convention Lyxal)
    LET $id_value = string::lowercase($code_clean);
    LET $id = type::thing('time_unit', $id_value);

    -- Vérification que l'unité n'existe pas déjà (par code)
    LET $existing_unit = SELECT * FROM time_unit WHERE identity.code = $code_clean LIMIT 1;
    IF array::len($existing_unit) > 0 {
        RETURN { success: false, result_code: 'time_unit_already_exists' };
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

    -- Valeur par défaut pour created_by (si non fourni)
    LET $created_by_value = IF $created_by = NONE OR string::len(string::trim($created_by)) = 0 { "system" } ELSE {$created_by};

    -- Valeur par défaut pour is_supported (si non fourni)
    LET $is_supported_value = IF $is_supported = NONE { true } ELSE {$is_supported};

    -- Récupération de la langue par défaut depuis i18n_config
    LET $config = SELECT config.default_language FROM i18n_config LIMIT 1;
    LET $langue_default_record = $config[0].config.default_language;

    -- Création de l'unité de temps
    LET $rec = CREATE $id SET
        identity.code = $code_clean,
        identity.slug = $slug,
        identity.value = $value,
        presentation.label_i18n = $label_i18n_record,
        presentation.description_i18n = $description_i18n_record,
        content.label_source = string::trim($label_source),
        content.description_source = IF $description_source != NONE AND string::len(string::trim($description_source)) > 0 THEN string::trim($description_source) ELSE NONE END,
        content.langue_default = $langue_default_record,
        config.rank = $rank,
        config.is_supported = $is_supported_value,
        status.is_active = $is_active,
        metadata.created_by = $created_by_value;
    
    RETURN { success: true, result_code: 'time_unit_created_success', data: $rec[0] };
}
COMMENT 'Crée une unité de temps dans la table de référence time_unit.'
PERMISSIONS NONE;


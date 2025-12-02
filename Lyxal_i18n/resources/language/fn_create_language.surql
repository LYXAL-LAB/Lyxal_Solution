DEFINE FUNCTION IF NOT EXISTS fn::create_language(
    $code_iso: string, -- code ISO 639-1 de la langue (ex: "fr", "en") - sera utilisé pour slug et converti en UPPERCASE pour code
    $name: string, -- nom de la langue en anglais (ex: "French", "English")
    $native_name: string, -- nom natif de la langue (ex: "Français", "English")
    $direction: option<string>, -- direction d'écriture : "ltr" ou "rtl" (peut être NONE)
    $snowball_supported: bool, -- support de stemmer Snowball (pour analyzers Surreal)
    $icon_flag: string, -- identifiant de l'icône du drapeau (ex: "france_flag") - sera converti en record<icon>
    $name_i18n: string, -- identifiant de la clé i18n (ex: "language_french_name") - sera converti en record<i18n_key>
    $is_active: bool, -- indique si la langue est active (par défaut false)
    $created_by: option<string> -- identifiant du créateur de la langue (optionnel, défaut: "system")
) {
    -- Conventions Lyxal :
    -- - identity.code : UPPERCASE (ex: FR, EN, ES)
    -- - identity.slug : lowercase (ex: fr, en, es) - code ISO 639-1
    -- - ID record : lowercase (ex: language:fr, language:en)

    -- Vérification des paramètres
    IF $code_iso = NONE OR string::len(string::trim($code_iso)) = 0 {
        THROW 'Le code ISO est requis.';
    };
    IF $name = NONE OR string::len(string::trim($name)) = 0 {
        THROW 'Le nom de la langue est requis.';
    };
    IF $native_name = NONE OR string::len(string::trim($native_name)) = 0 {
        THROW 'Le nom natif de la langue est requis.';
    };
    IF $direction != NONE AND $direction NOT IN ['ltr', 'rtl'] {
        THROW 'La direction doit être "ltr" ou "rtl".';
    };
    IF $icon_flag = NONE OR string::len(string::trim($icon_flag)) = 0 {
        THROW 'L\'identifiant de l\'icône du drapeau est requis.';
    };
    IF $name_i18n = NONE OR string::len(string::trim($name_i18n)) = 0 {
        THROW 'L\'identifiant de la clé i18n est requis.';
    };

    -- Normalisation du code ISO
    LET $code_iso_clean = string::lowercase(string::trim($code_iso));
    
    -- Vérification que le code ISO est valide (2 caractères)
    IF string::len($code_iso_clean) != 2 {
        THROW 'Le code ISO doit contenir exactement 2 caractères (ex: "fr", "en").';
    };

    -- Vérification que la langue n'existe pas déjà (par slug)
    LET $existing_language = SELECT * FROM language WHERE identity.slug = $code_iso_clean LIMIT 1;
    IF array::len($existing_language) > 0 {
        THROW 'La langue avec le code ISO "' + $code_iso_clean + '" existe déjà.';
    };

    -- Conversion des strings en records et vérification existence
    LET $icon_flag_clean = string::trim($icon_flag);
    LET $icon_record = type::thing('icon', $icon_flag_clean);

    LET $name_i18n_clean = string::trim($name_i18n);
    LET $name_i18n_record = type::thing('i18n_key', $name_i18n_clean);

    -- Génération du code UPPERCASE (convention Lyxal)
    LET $code_uppercase = string::uppercase($code_iso_clean);
    
    -- Génération de l'identifiant de la langue en lowercase (convention Lyxal)
    LET $id = type::thing('language', $code_iso_clean);

    -- Valeur par défaut pour created_by (si non fourni)
    LET $created_by_value = IF $created_by = NONE OR string::len(string::trim($created_by)) = 0 THEN "system" ELSE $created_by END;

    -- Création de la langue
    LET $rec = CREATE $id SET
        identity.code = $code_uppercase,
        identity.slug = $code_iso_clean,
        content.name = $name,
        content.native_name = $native_name,
        content.direction = $direction,
        content.snowball_supported = $snowball_supported,
        content.icon_flag = $icon_record,
        content.name_i18n = $name_i18n_record,
        metadata.status.is_active = $is_active,
        metadata.created_by = $created_by_value;
    
    RETURN { success: true, data: $rec[0] };
}
COMMENT 'Crée une langue dans la base de données.'
PERMISSIONS NONE;


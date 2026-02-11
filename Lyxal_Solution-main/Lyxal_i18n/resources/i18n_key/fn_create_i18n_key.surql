DEFINE FUNCTION IF NOT EXISTS  fn::create_i18n_key(
    $suffix: string, -- type de la clé i18n (label, description, message) - sera converti en UPPERCASE
    $prefix: string, -- nom de la table parente - sera converti en UPPERCASE
    $name: string, -- nom de la clé i18n - sera converti en UPPERCASE
    $context: string, -- module ou composant d'origine : auth, studio, ui, crm, etc.
    $is_system: bool, -- indique si la clé est système (par défaut true)
    $value_default: string, -- valeur source de la clé
    $description: string, -- description fonctionnelle pour traducteurs ou développeurs
    $langue_default: string, -- code ISO 639-1 de la langue source (ex: "fr", "en") - sera converti en record<language>
    $created_by: string -- identifiant du créateur de la clé (utilisateur ou service)
) {
    -- Conventions Lyxal :
    -- - identity.code : UPPER_SNAKE_CASE (ex: BUTTON.SAVE.LABEL)
    -- - identity.slug : lowercase-kebab-case (ex: button-save-label)
    -- - ID record : lowercase (ex: i18n_key:button_save_label)

   -- Vérification des paramètres
   IF $suffix = NONE OR string::len(string::trim($suffix)) = 0 {
    THROW 'Le suffixe est requis.';
   };
   IF $prefix = NONE OR string::len(string::trim($prefix)) = 0 {
    THROW 'Le préfixe est requis.';
   };
   IF $value_default = NONE OR string::len(string::trim($value_default)) = 0 {
    THROW 'La valeur par défaut est requise.';
   };
   IF $context = NONE OR string::len(string::trim($context)) = 0 {
    THROW 'Le contexte est requis.';
   };
   IF $description = NONE OR string::len(string::trim($description)) = 0 {
    THROW 'La description est requise.';
   };
   IF $langue_default = NONE OR string::len(string::trim($langue_default)) = 0 {
    THROW 'Le code de langue est requis.';
   };

    -- Vérification existence de la langue et active (recherche par slug ISO)
    LET $langue_code = string::lowercase(string::trim($langue_default));
    LET $langue_row = SELECT * FROM language WHERE identity.slug = $langue_code AND metadata.status.is_active = true LIMIT 1;
    IF array::len($langue_row) = 0 {
        THROW 'La langue avec le code "' + $langue_code + '" est requise et doit être active.';
    };
    
    -- Conversion du code string en record<language> (utilise le slug lowercase)
    LET $langue_record = type::record('language', $langue_code);


    -- Génération de la clé i18n en UPPER_SNAKE_CASE (convention Lyxal)
    LET $code = string::concat(string::uppercase($prefix), '.', string::uppercase($name), '.', string::uppercase($suffix));
    -- Génération du slug URL-friendly en lowercase-kebab-case (remplace points et underscores par des tirets)
    LET $slug = string::lowercase(string::replace(string::replace($code, '_', '-'), '.', '-'));
    -- Génération de l'identifiant de la clé i18n en lowercase (convention Lyxal)
    LET $id = type::record('i18n_key', string::lowercase(string::replace($code, '.', '_')));

    -- Création de la clé i18n
    LET $rec = CREATE $id SET 
        identity.code = $code,
        identity.context = $context,
        identity.slug = $slug,
        content.value_default = $value_default,
        content.langue_default = $langue_record, 
        content.description = $description,
        metadata.status.is_system = $is_system,
        metadata.created_by = $created_by;
    RETURN { success: true, data: $rec[0] };
}
COMMENT 'Crée une clé i18n dans la base de données.'
PERMISSIONS NONE;
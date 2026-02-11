DEFINE FUNCTION IF NOT EXISTS fn::update_language(
    $code_iso: string, -- code ISO 639-1 de la langue (ex: "fr", "en") - sera utilisé pour identifier la langue
    $is_active: option<bool>, -- indique si la langue doit être active (optionnel, si NONE ne modifie pas)
    $snowball_supported: option<bool> -- support de stemmer Snowball (optionnel, si NONE ne modifie pas)
) {
    -- Vérification des paramètres
    IF $code_iso = NONE OR string::len(string::trim($code_iso)) = 0 {
        THROW 'Le code ISO est requis.';
    };

    -- Normalisation du code ISO
    LET $code_iso_clean = string::lowercase(string::trim($code_iso));
    
    -- Vérification que le code ISO est valide (2 caractères)
    IF string::len($code_iso_clean) != 2 {
        THROW 'Le code ISO doit contenir exactement 2 caractères (ex: "fr", "en").';
    };

    -- Génération de l'identifiant de la langue en lowercase (convention Lyxal)
    LET $id = type::record('language', $code_iso_clean);

    -- Vérification que la langue existe
    LET $existing_language = SELECT * FROM language WHERE id = $id LIMIT 1;
    IF array::len($existing_language) = 0 {
        THROW 'La langue avec le code ISO "' + $code_iso_clean + '" n\'existe pas.';
    };

    -- Vérification qu'au moins un champ doit être mis à jour
    IF $is_active = NONE AND $snowball_supported = NONE {
        THROW 'Au moins un champ doit être fourni pour la mise à jour (is_active ou snowball_supported).';
    };

    -- Mise à jour de la langue avec les champs fournis
    LET $rec = IF $is_active != NONE AND $snowball_supported != NONE THEN
        UPDATE $id SET
            metadata.status.is_active = $is_active,
            content.snowball_supported = $snowball_supported
        RETURN AFTER
    ELSE IF $is_active != NONE THEN
        UPDATE $id SET metadata.status.is_active = $is_active RETURN AFTER
    ELSE
        UPDATE $id SET content.snowball_supported = $snowball_supported RETURN AFTER
    END;
    
    IF array::len($rec) = 0 {
        THROW 'Erreur lors de la mise à jour de la langue.';
    };
    
    RETURN { success: true, data: $rec[0] };
}
COMMENT 'Met à jour une langue existante (activation/désactivation et support Snowball uniquement).'
PERMISSIONS NONE;
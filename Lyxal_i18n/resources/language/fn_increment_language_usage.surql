DEFINE FUNCTION IF NOT EXISTS fn::increment_language_usage(
    $code_iso: string -- code ISO 639-1 de la langue (ex: "fr", "en") - sera utilisé pour identifier la langue
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

    -- Vérification que la langue existe et est active
    LET $existing_language = SELECT * FROM language 
        WHERE id = $id 
        AND metadata.status.is_active = true 
        LIMIT 1;
    
    IF array::len($existing_language) = 0 {
        THROW 'La langue avec le code ISO "' + $code_iso_clean + '" n\'existe pas ou n\'est pas active.';
    };

    -- Incrémentation du compteur d'utilisation et mise à jour de la date de dernière utilisation
    LET $rec = UPDATE $id SET 
        metadata.analytics.usage_count += 1,
        metadata.analytics.last_used_at = time::now()
    RETURN AFTER;
    
    IF array::len($rec) = 0 {
        THROW 'Erreur lors de l\'incrémentation du compteur d\'utilisation.';
    };
    
    RETURN { success: true, data: $rec[0] };
}
COMMENT 'Incrémente le compteur d\'utilisation d\'une langue (appelé uniquement lors de la sélection de langue dans l\'application, pas à chaque récupération de traduction).'
PERMISSIONS NONE;


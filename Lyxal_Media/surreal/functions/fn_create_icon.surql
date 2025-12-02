DEFINE FUNCTION OVERWRITE fn::create_icon(
    $pack_slug: string,
    $name: string,
    $body: string,
    $width: option<int>,
    $height: option<int>,
    $category: option<string>,
    $tags: option<array<string>>
) {
    BEGIN ;
    -- 1. Validation de base
    IF $pack_slug = NONE OR $name = NONE OR $body = NONE {
        THROW 'Paramètres obligatoires manquants (pack_slug, name, body)';
    };

    -- Valeurs par défaut
    LET $final_width = IF $width != NONE { $width } ELSE { 24 };
    LET $final_height = IF $height != NONE { $height } ELSE { 24 };
    LET $final_tags = IF $tags != NONE { $tags } ELSE { [] };
    LET $final_category = IF $category != NONE { $category } ELSE { 'uncategorized' };

    -- 2. Normalisation et Identifiants
    LET $pack_id = type::thing('icon_pack', string::lowercase($pack_slug));

    -- Slug global : "lucide-arrow-right"
    LET $slug = string::concat($pack_slug, '-', $name);
    
    -- Code : "LUCIDE_ARROW_RIGHT"
    LET $code_raw = string::replace($slug, '-', '_');
    LET $code = string::uppercase($code_raw);

    -- Nom humain (Label) : "Arrow Right"
    LET $label_raw = string::replace($name, '-', ' ');
    LET $label = $label_raw; 

    -- SVG Complet wrapper
    LET $svg_content = string::concat(
        '<svg xmlns="http://www.w3.org/2000/svg" width="', <string>$final_width, 
        '" height="', <string>$final_height, 
        '" viewBox="0 0 ', <string>$final_width, ' ', <string>$final_height, 
        '">', $body, '</svg>'
    );

    -- ID unique de l'icône
    LET $id_suffix = string::lowercase($code);
    LET $icon_id = type::thing('icon', $id_suffix);

    -- 3. Upsert
    LET $icon = UPSERT $icon_id CONTENT {
        identity: {
            pack: $pack_id,
            name: $name,
            code: $code,
            slug: $slug
        },
        resource: {
            content: $svg_content,
            viewbox: string::concat('0 0 ', <string>$final_width, ' ', <string>$final_height),
            type: 'stroke'
        },
        presentation: {
            label: $label,
            tags: $final_tags,
            category: $final_category
        },
        status: {
            is_active: true,
            is_optimized: true
        },
        timestamp: {
            updated_at: time::now()
        }
    };

    COMMIT;
    RETURN { success: true, data: $icon[0] };
}
PERMISSIONS FULL;
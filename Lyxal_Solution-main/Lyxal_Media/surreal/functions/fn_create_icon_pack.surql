DEFINE FUNCTION OVERWRITE fn::create_icon_pack(
	$name: string,
	$category: string,
    $version: option<string>,
    $license:string,
    $source_url: string,
    $icon_count: int,
    $tags: array<string>
) {
    -- On contrôle les paramètres obligatoires
    IF $name = NONE OR string::len(string::trim($name)) = 0 {
        THROW 'Le nom du pack (prefix) est requis.';
    };
    -- Category est optionnel
    IF $category = NONE { $category = "Uncategorized"; };
    -- Tags est optionnel
    IF $tags = NONE { $tags = []; };

    IF $license = NONE {
        THROW 'La licence du pack est requise.';
    };
    IF $source_url = NONE {
        THROW 'L\'URL source du pack est requise.';
    };
    IF $icon_count = NONE {
        THROW 'Le nombre d\'icônes du pack est requise.';
    };

    -- 1. Nettoyage des identifiants
    LET $raw_name = string::trim(string::lowercase($name));
    
    -- Slug : on garde les tirets, on vire les espaces (ex: "lucide-icons")
    LET $slug = string::replace($raw_name, ' ', '-');
    
    -- Code : on remplace tout par _ et on met en majuscule (ex: "LUCIDE_ICONS")
    LET $code = string::uppercase(string::replace(string::replace($slug, '-', '_'), ' ', '_'));

    -- Nom humain : on remplace tirets et underscores par espaces (ex: "lucide icons")
    LET $human_name = string::replace(string::replace($raw_name, '-', ' '), '_', ' ');

    -- ID : format strict (ex: icon_pack:lucide_icons)
    -- On utilise le $code en minuscule pour l'ID pour être cohérent avec les _
    LET $id_suffix = string::lowercase($code);
    LET $icon_pack_id = type::thing('icon_pack', $id_suffix);

	LET $icon_pack = UPSERT $icon_pack_id CONTENT {
		identity: {
            code: $code,
            slug: $slug,
            version: IF $version != NONE { $version } ELSE { "0.0.0" },
            name: $human_name -- Nom affichable propre
        },
		info: {
            category: $category,
            license: $license,
            source_url: $source_url,
            icon_count: $icon_count,
            tags: $tags
        },
        metadata: {
            created_at: time::now(),
            updated_at: time::now(),
            last_sync: time::now()
        }
    };

    RETURN { success: true, data: $icon_pack[0] };
}
PERMISSIONS FULL;
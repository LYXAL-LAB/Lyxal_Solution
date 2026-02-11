DEFINE FUNCTION IF NOT EXISTS fn::create_icon_dictionnary(
    $name: string,
    $keywords: array<string>,
    $description: option<string>,
) {
  
   -- on commence la transaction
   BEGIN;

    -- on contrôle les paramètres
    IF $name = NONE OR string::len(string::trim($name)) = 0 {
        THROW 'Le nom est requis.';
    };
    IF $keywords = NONE OR array::len($keywords) = 0 {
        THROW 'Les mots-clés sont requis.';
    };
    IF $description = NONE OR string::len(string::trim($description)) = 0 OR $description = '' {
        THROW 'La description est requise.';
    };

    -- on normalise le nom
    LET $name_norm = string::trim($name);

    -- on génère l'id de l'icône
    LET $icon_id = type::thing('icon_dictionary', string::concat('icon_', string::lowercase(string::replace($name_norm, ' ', '_'))));

    -- on constitue le slug
    LET $slug = string::lowercase(string::replace($name_norm, ' ', '-'));

    -- on constitue le code
    LET $code = string::uppercase(string::replace($name_norm, ' ', '_'));

    -- on constitue le tableau des mots-clés
    LET $keywords_array = (
        SELECT VALUE string::trim(string::lowercase($this)) 
        FROM $keywords 
        WHERE string::len(string::trim($this)) > 0
    );
    -- on contrôle si le tableau des mots-clés est vide
    IF array::len($keywords_array) = 0 {
        CANCEL;
        THROW 'Le tableau des mots-clés est vide.';
    };

    -- on créé la clé i18n pour le nom
    LET $name_i18n = fn::i18n_key_create('label', 'icon_dictionary', 'name', 'icon', true, $name_norm, $description, 'fr', NONE);
    -- on contrôle si la clé i18n a été créée avec succès
    IF $name_i18n.success = false {
        CANCEL;
        THROW 'La clé i18n pour le nom n\'a pas été créée avec succès.';
    };
    -- on récupère l'id de la clé i18n
    LET $name_i18n_id = $name_i18n.data.id;

    -- on crée la clé i18n pour la description
    LET $description_i18n = IF $description != NONE  {fn::i18n_key_create('description', 'icon_dictionary', 'description', 'icon', true, $description, 'fr', NONE)} ELSE {NONE};
    -- on contrôle si la clé i18n a été créée avec succès
    IF $description != NONE AND $description_i18n.success = false {
        CANCEL;
        THROW 'La clé i18n pour la description n\'a pas été créée avec succès.';
    };
    -- on récupère l'id de la clé i18n
    LET $description_i18n_id = IF $description_i18n != NONE  {$description_i18n.data.id} ELSE {NONE};
    
    -- on crée l'icône
    LET $icon = CREATE $icon_id SET 
        identity.code = $code,
        identity.slug = $slug,
        presentation.name_i18n = $name_i18n_id,
        presentation.description_i18n = $description_i18n_id,
        presentation.keywords = $keywords_array;

    -- on contrôle si l'icône a été créée avec succès
    IF $icon = NONE {
        CANCEL;
        THROW 'L\'icône n\'a pas été créée avec succès.';
    };

    -- on valide la transaction
    COMMIT;
    RETURN { success: true, data: $icon[0] };
}
COMMENT 'Crée un dictionnaire d\'icônes.'
PERMISSIONS FULL;
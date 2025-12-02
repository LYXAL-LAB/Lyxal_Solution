DEFINE FUNCTION IF NOT EXISTS fn::create_ui_component(
    $key: string,
    $name_i18n: option<string>,
    $description_i18n: option<string>,
    $icon_key: option<string>,
    $version: option<string>,
    $category_key: option<string>,
    $author: option<string>,
    $tags: option<array<string>>,
    $props: option<object>,
    $variants: option<object>,
    $children: option<array<object>>,
) {
    IF $key = NONE OR string::len(string::trim($key)) = 0 {
        THROW 'La clé technique est requise.';
    };
    IF $name_i18n = NONE OR string::len(string::trim($name_i18n)) = 0 {
        THROW 'Le nom i18n est requis.';
    };
    IF $description_i18n = NONE OR string::len(string::trim($description_i18n)) = 0 {
        THROW 'La description i18n est requise.';
    };
    IF $icon_key = NONE OR string::len(string::trim($icon_key)) = 0 {
        THROW 'La clé icône est requise.';
    };
    IF $version = NONE OR string::len(string::trim($version)) = 0 {
        THROW 'La version est requise.';
    };
    IF $category_key = NONE OR string::len(string::trim($category_key)) = 0 {
        THROW 'La clé catégorie est requise.';
    };
    IF $author = NONE OR string::len(string::trim($author)) = 0 {
        THROW 'L\'auteur est requis.';
    };
    IF $tags = NONE OR array::len($tags) = 0 {
        THROW 'Les tags sont requis.';
    };
    IF $props = NONE OR object::len($props) = 0 {
        THROW 'Les props sont requises.';
    };
    IF $variants = NONE OR object::len($variants) = 0 {
        THROW 'Les variants sont requises.';
    };
    IF $children = NONE OR array::len($children) = 0 {
        THROW 'Les enfants sont requis.';
    };
    LET $now = time::now();
    LET $parent_record = if $parent = NONE then NONE else type::thing('ui_component_library', $parent) end;
    LET $data = CREATE type::thing('ui_component_library', $key) SET
        key = $key,
        name_i18n = if $name_i18n = NONE then NONE else type::thing('i18n_key', $name_i18n) end,
        description_i18n = if $description_i18n = NONE then NONE else type::thing('i18n_key', $description_i18n) end,
        icon_key = $icon_key,
        version = $version,
        category_key = $category_key,
        author = $author,
        tags = $tags,
        props = $props,
        variants = $variants,
        children = $children
        RETURN AFTER;
    RETURN { success: true, data: $data[0] };
}
COMMENT 'Crée un composant UI.'
PERMISSIONS FULL;

    
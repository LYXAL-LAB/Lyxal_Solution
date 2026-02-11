DEFINE FUNCTION OVERWRITE fn::icon_search(
    $page: int, 
    $limit: int, 
    $q: string, 
    $pack_slug: string
) {
    -- Valeurs par défaut
    LET $p = IF $page > 0 { $page } ELSE { 1 };
    LET $l = IF $limit > 0 { $limit } ELSE { 50 };
    LET $offset = ($p - 1) * $l;
    
    LET $search_term = string::lowercase($q);
    LET $pack_filter = string::lowercase($pack_slug);

    -- Requête principale
    LET $items = SELECT * FROM icon
        WHERE 
            -- Filtre recherche texte
            ($search_term = "" OR (
                string::lowercase(identity.name) CONTAINS $search_term 
                OR string::lowercase(presentation.label) CONTAINS $search_term
                OR presentation.tags CONTAINS $search_term
            ))
            AND
            -- Filtre pack
            ($pack_filter = "" OR string::starts_with(identity.slug, $pack_filter))
        
        ORDER BY identity.name ASC
        LIMIT $l START $offset;

    -- Compte total (pour pagination)
    LET $total_result = SELECT count() AS total FROM icon
        WHERE 
            ($search_term = "" OR (
                string::lowercase(identity.name) CONTAINS $search_term 
                OR string::lowercase(presentation.label) CONTAINS $search_term
                OR presentation.tags CONTAINS $search_term
            ))
            AND
            ($pack_filter = "" OR string::starts_with(identity.slug, $pack_filter))
        GROUP ALL;

    LET $total = IF array::len($total_result) > 0 { $total_result[0].total } ELSE { 0 };
    LET $pages = math::ceil($total / $l);

    RETURN {
        items: $items,
        total: $total,
        page: $p,
        limit: $l,
        pages: $pages
    };
}
PERMISSIONS FULL;
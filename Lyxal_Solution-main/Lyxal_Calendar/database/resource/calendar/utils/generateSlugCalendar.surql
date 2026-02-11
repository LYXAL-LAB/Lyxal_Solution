DEFINE FUNCTION fn::generateSlugCalendar(
    $text: string, 
    $exclude_id: option<record>, 
    $counter: option<int>) {

    -- Passe en minuscules
    LET $lower = string::lowercase($text);
    -- Remplace tous les caractères non-alphanumériques par des tirets
    LET $replaced = string::replace($lower, <regex>'[^a-z0-9]+', '-');
    -- Supprime les tirets au début et à la fin
    LET $base_slug = string::replace($replaced, <regex>'(^-+|-+$)', '');
    
    -- Ajoute le compteur si nécessaire
    LET $slug = IF $counter != NONE AND $counter > 0 {
        string::concat($base_slug, '-', $counter)
    } ELSE {
        $base_slug
    };
    
    LET $exists = IF $exclude_id != NONE {
        (SELECT VALUE id FROM calendars
         WHERE slug = $slug AND id != $exclude_id
         LIMIT 1) != []
    } ELSE {
        (SELECT VALUE id FROM calendars
         WHERE slug = $slug
         LIMIT 1) != []
    };
    
    -- Si le slug existe, on relance la fonction avec counter + 1
    IF $exists {
        LET $next_counter = IF $counter == NONE { 1 } ELSE { $counter + 1 };
        RETURN fn::generateSlugCalendar($text, $exclude_id, $next_counter);
    } ELSE {
        RETURN $slug;
    };
};
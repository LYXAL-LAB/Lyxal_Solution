-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_team                                                â”‚
-- â”‚  Mise Ã  jour des informations d'une Ã©quipe existante (booking_team)     â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_team(
    $team_id: option<record<booking_team>>,
    $name: option<string>,
    $slug: option<string>,
    $description: option<string>,
    $visibility: option<string>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        THROW "Parameter 'name' is required";
    };
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        THROW "Parameter 'slug' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. NETTOYAGE ET VALIDATIONS
    -- ------------------------------------------------------------------------
    LET $clean_name = string::trim($name);
    LET $clean_slug = string::lowercase(string::trim($slug));

    IF string::len($clean_slug) == 0 {
        THROW "Slug cannot be empty";
    };

    -- VÃ©rification de l'unicitÃ© du slug hors Ã©quipe courante
    LET $existing = SELECT VALUE id FROM booking_team WHERE slug = $clean_slug AND id != $team_id LIMIT 1;
    IF array::len($existing) > 0 {
        THROW "Another team already uses this slug";
    };

    LET $clean_desc = IF $description != NONE { string::trim($description) } ELSE { NONE };
    LET $clean_vis = IF $visibility != NONE { string::lowercase(string::trim($visibility)) } ELSE { 'public' };

    -- ------------------------------------------------------------------------
    -- 3. MISE Ã€ JOUR DE L'Ã‰QUIPE EN BASE DE DONNÃ‰ES
    -- ------------------------------------------------------------------------
    UPDATE $team_id MERGE {
        name: $clean_name,
        slug: $clean_slug,
        description: $clean_desc,
        visibility: $clean_vis,
        updated_at: time::now()
    };

    RETURN SELECT * FROM $team_id;
} COMMENT "Met Ã  jour le nom, le slug, la description et la visibilitÃ© d'une Ã©quipe";

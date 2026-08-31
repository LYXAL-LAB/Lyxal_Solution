-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_team                                                │
-- │  Création transactionnelle d'une équipe avec son propriétaire initial   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_team($params: object) {
    LET $name = $params.name;
    LET $slug = $params.slug;
    LET $description = $params.description;
    LET $user_id = IF $params.user_id != NONE { type::record(type::string($params.user_id)) } 
                   ELSE IF $params.created_by != NONE { type::record(type::string($params.created_by)) } 
                   ELSE { NONE };
    LET $visibility = IF $params.visibility != NONE { $params.visibility } ELSE { 'public' };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        RETURN fn::result_error("BOOKING_TEAM_NAME_REQUIRED", $language, { field: "name" });
    };
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        RETURN fn::result_error("BOOKING_TEAM_SLUG_REQUIRED", $language, { field: "slug" });
    };
    IF $user_id == NONE {
        RETURN fn::result_error("BOOKING_USER_ID_REQUIRED", $language, { field: "user_id" });
    };

    LET $clean_name = string::trim($name);
    LET $clean_slug = string::lowercase(string::trim($slug));
    LET $clean_desc = IF $description != NONE { string::trim($description) } ELSE { NONE };

    LET $existing = SELECT VALUE id FROM booking_team WHERE slug = $clean_slug LIMIT 1;
    IF array::len($existing) > 0 {
        RETURN fn::result_error("BOOKING_TEAM_SLUG_ALREADY_EXISTS", $language, { slug: $clean_slug });
    };

    LET $team = CREATE ONLY booking_team CONTENT {
        name: $clean_name,
        slug: $clean_slug,
        description: $clean_desc,
        visibility: $visibility,
        created_by: $user_id,
        created_at: time::now()
    };

    LET $team_id = $team.id;
    RELATE ONLY $user_id->booking_team_member->$team_id SET
        role = 'admin',
        source = 'direct',
        created_at = time::now();

    RETURN fn::result_ok({
        id: $team.id,
        name: $team.name,
        slug: $team.slug,
        description: $team.description,
        visibility: $team.visibility,
        created_by: $user_id
    });
} COMMENT "Création atomique d'une équipe et association de son administrateur créateur";

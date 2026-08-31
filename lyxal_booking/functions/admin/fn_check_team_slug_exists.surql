-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_check_team_slug_exists                                    â”‚
-- â”‚  VÃ©rifie l'existence d'une Ã©quipe par son slug                         â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_check_team_slug_exists(
    $slug: option<string>
) {
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        THROW "Parameter 'slug' is required";
    };

    LET $clean_slug = string::lowercase(string::trim($slug));
    LET $res = SELECT VALUE id FROM booking_team WHERE slug = $clean_slug LIMIT 1;
    
    RETURN IF array::len($res) > 0 { true } ELSE { false };
} COMMENT "VÃ©rifie si un slug d'Ã©quipe existe dÃ©jÃ  en base de donnÃ©es";

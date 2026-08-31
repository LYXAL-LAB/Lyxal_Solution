-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_group_members                                         â”‚
-- â”‚  RÃ©cupÃ¨re les membres d'un groupe OIDC d'accÃ¨s                          â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_group_members(
    $group_id: option<string>
) {
    IF $group_id == NONE OR string::len(string::trim($group_id)) == 0 {
        THROW "Parameter 'group_id' is required";
    };

    LET $clean_gid = string::trim($group_id);
    LET $user_ids = SELECT VALUE user_id FROM user_group WHERE group_id = $clean_gid;

    RETURN SELECT id, name, email, avatar_url 
             FROM booking_account 
            WHERE enabled = true 
              AND id IN $user_ids 
            ORDER BY name ASC 
            LIMIT 8;
} COMMENT "RÃ©cupÃ¨re les membres actifs d'un groupe OIDC d'accÃ¨s";

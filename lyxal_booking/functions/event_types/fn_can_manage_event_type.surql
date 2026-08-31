-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_can_manage_event_type                                      │
-- │  Vérifie si un compte utilisateur a le droit de gérer/modifier un       │
-- │  type d'événement (propriétaire individuel ou admin/owner d'équipe).   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_can_manage_event_type($params: object) {
    LET $account_id = $params.account_id;
    LET $event_type_id = $params.event_type_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $account_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_ID_REQUIRED", $language, { field: "account_id" });
    };
    IF $event_type_id == NONE {
        RETURN fn::result_error("BOOKING_EVENT_TYPE_ID_REQUIRED", $language, { field: "event_type_id" });
    };

    -- 1. Événement individuel : le compte est le propriétaire direct
    LET $personal = SELECT VALUE id FROM booking_event_type
                     WHERE id = $event_type_id
                       AND account = $account_id;
    IF array::len($personal) > 0 {
        RETURN fn::result_ok(true);
    };

    -- 2. Événement d'équipe : l'utilisateur doit être admin ou owner de l'équipe (via booking_team_member)
    LET $team_et = SELECT VALUE team FROM booking_event_type 
                    WHERE id = $event_type_id 
                      AND team != NONE;
    IF array::len($team_et) > 0 {
        LET $tid = $team_et[0];
        LET $is_admin = SELECT VALUE id FROM booking_team_member
                         WHERE out = $tid 
                           AND in = $account_id 
                           AND role IN ['admin', 'owner'];
        IF array::len($is_admin) > 0 {
            RETURN fn::result_ok(true);
        };
    };

    RETURN fn::result_ok(false);
} COMMENT "Vérifie les droits de gestion d'un compte sur un type d'événement (propriétaire individuel ou admin/owner d'équipe)";

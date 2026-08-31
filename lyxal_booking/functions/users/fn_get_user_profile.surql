-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_user_profile                                           │
-- │  Lecture des informations de profil utilisateur pour Users & Settings   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_user_profile($params: object) {
    LET $raw_user_id = IF $params.user_id != NONE { string::trim(type::string($params.user_id)) } ELSE { NONE };
    IF $raw_user_id == NONE {
        RETURN fn::result_error("USER_ID_REQUIRED", "fr", "L'identifiant utilisateur est obligatoire");
    };

    LET $users = SELECT id, name, email, booking_email, time_zone, avatar_path, role, enabled, created_at 
                 FROM booking_account 
                 WHERE id = type::record($raw_user_id) OR id = $raw_user_id 
                 LIMIT 1;

    IF array::len($users) == 0 {
        RETURN fn::result_error("USER_NOT_FOUND", "fr", "Utilisateur introuvable");
    };

    LET $u = $users[0];

    RETURN fn::result_ok({
        id: string::trim(type::string($u.id)),
        user_id: string::trim(type::string($u.id)),
        name: $u.name,
        email: $u.email,
        booking_email: $u.booking_email,
        time_zone: IF $u.time_zone != NONE { $u.time_zone } ELSE { "UTC" },
        avatar_path: $u.avatar_path,
        role: $u.role,
        enabled: IF $u.enabled != NONE { $u.enabled } ELSE { true }
    });
} COMMENT "Récupère les informations de profil utilisateur et ses préférences de paramètres";

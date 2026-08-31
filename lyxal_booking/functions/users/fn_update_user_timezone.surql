-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_user_timezone                                       │
-- │  Mise à jour du fuseau horaire par défaut de l'utilisateur              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_user_timezone($params: object) {
    LET $raw_user_id = IF $params.user_id != NONE { string::trim(type::string($params.user_id)) } ELSE { NONE };
    LET $raw_tz = IF $params.time_zone != NONE { string::trim(type::string($params.time_zone)) } ELSE IF $params.timezone != NONE { string::trim(type::string($params.timezone)) } ELSE { NONE };

    IF $raw_user_id == NONE OR $raw_tz == NONE {
        RETURN fn::result_error("USER_TIMEZONE_PARAMS_INVALID", "fr", "L'identifiant utilisateur et le fuseau horaire sont obligatoires");
    };

    LET $users = SELECT id FROM users WHERE id = type::record($raw_user_id) OR id = $raw_user_id LIMIT 1;
    IF array::len($users) == 0 {
        RETURN fn::result_error("USER_NOT_FOUND", "fr", "Utilisateur introuvable");
    };

    LET $target_id = $users[0].id;
    UPDATE $target_id SET time_zone = $raw_tz, updated_at = time::now();

    RETURN fn::result_ok({
        user_id: string::trim(type::string($target_id)),
        time_zone: $raw_tz,
        updated: true
    });
} COMMENT "Mise à jour du fuseau horaire IANA par défaut d'un utilisateur";

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_user_profile                                        │
-- │  Mise à jour du profil utilisateur (Nom, Email de réservation)          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_user_profile($params: object) {
    LET $raw_user_id = IF $params.user_id != NONE { string::trim(type::string($params.user_id)) } ELSE { NONE };
    IF $raw_user_id == NONE {
        RETURN fn::result_error("USER_ID_REQUIRED", "fr", "L'identifiant utilisateur est obligatoire");
    };

    LET $users = SELECT id FROM users WHERE id = type::record($raw_user_id) OR id = $raw_user_id LIMIT 1;
    IF array::len($users) == 0 {
        RETURN fn::result_error("USER_NOT_FOUND", "fr", "Utilisateur introuvable");
    };

    LET $target_id = $users[0].id;
    LET $clean_name = IF $params.name != NONE { string::trim($params.name) } ELSE { NONE };
    LET $clean_booking_email = IF $params.booking_email != NONE { string::trim($params.booking_email) } ELSE { NONE };

    UPDATE $target_id SET 
        name = IF $clean_name != NONE { $clean_name } ELSE { name },
        booking_email = IF $clean_booking_email != NONE { $clean_booking_email } ELSE { booking_email },
        updated_at = time::now();

    LET $updated = SELECT id, name, email, booking_email, time_zone, avatar_path, role FROM $target_id;
    LET $u = $updated[0];

    RETURN fn::result_ok({
        id: string::trim(type::string($u.id)),
        user_id: string::trim(type::string($u.id)),
        name: $u.name,
        email: $u.email,
        booking_email: $u.booking_email,
        time_zone: IF $u.time_zone != NONE { $u.time_zone } ELSE { "UTC" },
        avatar_path: $u.avatar_path,
        role: $u.role
    });
} COMMENT "Mise à jour du profil utilisateur et des préférences de contact pour l'application";

-- ============================================================================
-- SUPPRESSION SECURISEE D'UN UTILISATEUR & DE SES SESSIONS (AVEC AVATAR_PATH)
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_delete_user(
    $params: object
) {
    LET $target_id = $params.target_id;
    LET $requester_id = $params.requester_id;
    LET $language = $params.language OR "fr";

    IF $target_id == NONE OR $requester_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { field: "target_id" });
    };

    IF $target_id == $requester_id {
        RETURN fn::result_error("BOOKING_AUTH_CANNOT_DELETE_SELF", $language, { target_id: $target_id });
    };

    LET $target_res = SELECT * FROM $target_id LIMIT 1;
    IF array::len($target_res) == 0 {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { target_id: $target_id });
    };

    LET $target = $target_res[0];

    -- 1. Contrôle du dernier administrateur
    IF $target.role == 'admin' {
        LET $admins = SELECT VALUE count() FROM booking_account WHERE role = 'admin' AND enabled = true;
        IF array::len($admins) > 0 AND $admins[0] <= 1 {
            RETURN fn::result_error("BOOKING_AUTH_LAST_ADMIN_DELETE_PROHIBITED", $language, { target_id: $target_id });
        };
    };

    -- 2. Contrôle des réservations futures (comme hôte ou comme membre assigné d'équipe)
    LET $host_future = SELECT VALUE count() FROM booking WHERE event_type.account = $target_id AND status IN ['confirmed', 'pending'] AND start_at > time::now();
    LET $assigned_future = SELECT VALUE count() FROM booking WHERE assigned_account = $target_id AND status IN ['confirmed', 'pending'] AND start_at > time::now();
    LET $host_cnt = IF array::len($host_future) > 0 { $host_future[0] } ELSE { 0 };
    LET $assigned_cnt = IF array::len($assigned_future) > 0 { $assigned_future[0] } ELSE { 0 };
    LET $total_future = $host_cnt + $assigned_cnt;

    IF $total_future > 0 {
        RETURN fn::result_error("BOOKING_AUTH_HAS_FUTURE_BOOKINGS", $language, { count: $total_future });
    };

    -- Capture du chemin d'avatar pour nettoyage par l'adaptateur Rust
    LET $avatar_path = $target.avatar_path;

    -- 3. Cascade Delete explicitement ordonné
    -- 3.1. Suppression des réservations sous les types d'évènements de l'utilisateur
    DELETE booking WHERE event_type.account = $target_id;
    -- 3.2. Suppression des invitations créées par l'utilisateur sur d'autres types d'évènements
    DELETE booking_invite WHERE created_by = $target_id;
    -- 3.3. Suppression des sessions actives
    DELETE booking_session WHERE account = $target_id;
    -- 3.4. Suppression de l'enregistrement de compte principal
    DELETE $target_id;

    RETURN fn::result_ok({ deleted: true, user_id: $target_id, avatar_path: $avatar_path });
};

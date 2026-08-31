-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_claim_booking                                              │
-- │  Réclamation atomique d'une réservation par un membre observateur d'équipe│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_claim_booking($params: object) {
    LET $raw_booking_id = IF $params.booking_id != NONE { string::trim(type::string($params.booking_id)) } ELSE { NONE };
    LET $raw_token = IF $params.token != NONE { string::trim(type::string($params.token)) } ELSE { NONE };
    LET $raw_user_id = IF $params.user_id != NONE { string::trim(type::string($params.user_id)) } ELSE { NONE };

    IF $raw_booking_id == NONE OR $raw_token == NONE OR $raw_user_id == NONE {
        RETURN fn::result_error("BOOKING_CLAIM_PARAMS_INVALID", "fr", "Paramètres booking_id, token et user_id obligatoires");
    };

    -- 1. Recherche et vérification de la validité du token de réclamation
    LET $token_records = SELECT * FROM booking_claim_tokens 
                         WHERE token = $raw_token 
                           AND (booking_id = $raw_booking_id OR booking_id = type::record($raw_booking_id))
                           AND used_at IS NONE 
                           AND expires_at > time::now()
                         LIMIT 1;

    IF array::len($token_records) == 0 {
        RETURN fn::result_error("BOOKING_CLAIM_TOKEN_INVALID", "fr", "Jeton de réclamation invalide ou expiré");
    };

    LET $claim_tok = $token_records[0];

    -- 2. Recherche et vérification de la réservation
    LET $bookings = SELECT * FROM booking WHERE id = type::record($raw_booking_id) OR id = $raw_booking_id LIMIT 1;
    IF array::len($bookings) == 0 {
        RETURN fn::result_error("BOOKING_NOT_FOUND", "fr", "Réservation introuvable");
    };

    LET $b = $bookings[0];
    IF $b.claimed_by_user_id != NONE OR $b.claimed_by != NONE {
        RETURN fn::result_error("BOOKING_ALREADY_CLAIMED", "fr", "Réservation déjà réclamée par un autre membre");
    };

    -- 3. Mise à jour atomique de l'affectation et du statut du token
    LET $target_user = type::record($raw_user_id);
    UPDATE $b.id SET claimed_by_user_id = $target_user, claimed_by = $target_user, updated_at = time::now();
    UPDATE $claim_tok.id SET used_at = time::now();

    -- 4. Invalidation de tous les autres tokens de réclamation concurrents pour cette réservation
    UPDATE booking_claim_tokens SET used_at = time::now() 
      WHERE (booking_id = $raw_booking_id OR booking_id = type::record($raw_booking_id)) 
        AND id != $claim_tok.id 
        AND used_at IS NONE;

    RETURN fn::result_ok({
        booking_id: string::trim(type::string($b.id)),
        claimed_by_user_id: $raw_user_id,
        claimed: true,
        claimed_at: time::now()
    });
} COMMENT "Réclame de manière atomique une réservation disponible pour un membre d'équipe observatrice";

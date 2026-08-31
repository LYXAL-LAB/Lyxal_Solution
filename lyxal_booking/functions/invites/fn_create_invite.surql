-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_create_invite                                              â”‚
-- â”‚  GÃ©nÃ©ration d'une invitation Ã©phÃ©mÃ¨re Ã  usage limitÃ©                    â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_create_invite(
    $event_type_id: option<record<booking_event_type>>,
    $max_uses: option<int>,
    $expires_at: option<datetime>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DU PARAMÃˆTRE OBLIGATOIRE
    -- ------------------------------------------------------------------------
    IF $event_type_id == NONE {
        THROW "Parameter 'event_type_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. VALEURS NETTOYÃ‰ES ET PAR DÃ‰FAUT
    -- ------------------------------------------------------------------------
    LET $clean_max = IF $max_uses != NONE AND $max_uses > 0 { $max_uses } ELSE { NONE };
    IF $expires_at != NONE AND $expires_at <= time::now() {
        THROW "Parameter 'expires_at' must be in the future";
    };

    LET $token = rand::uuid::v4();

    -- ------------------------------------------------------------------------
    -- 3. CRÃ‰ATION EN BASE DANS LA TABLE BOOKING_INVITE
    -- ------------------------------------------------------------------------
    LET $created = CREATE ONLY booking_invite CONTENT {
        event_type: $event_type_id,
        token: $token,
        max_uses: $clean_max,
        uses_count: 0,
        expires_at: $expires_at,
        created_at: time::now()
    };

    RETURN $created;
} COMMENT "GÃ©nÃ¨re un jeton d'invitation Ã©phÃ©mÃ¨re pour un type d'Ã©vÃ©nement";

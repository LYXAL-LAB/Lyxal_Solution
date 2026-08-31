-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_apply_buffers                                             â”‚
-- â”‚  Calcule la plage d'occupation Ã©tendue incluant les temps de            â”‚
-- â”‚  prÃ©paration avant (buffer_before) et aprÃ¨s (buffer_after).            â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_apply_buffers(
    $start_at: option<datetime>,
    $end_at: option<datetime>,
    $buf_before_min: option<int>,
    $buf_after_min: option<int>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES (Erreurs explicites)
    -- ------------------------------------------------------------------------
    IF $start_at == NONE {
        THROW "Parameter 'start_at' is required";
    };
    IF $end_at == NONE {
        THROW "Parameter 'end_at' is required";
    };
    IF $end_at <= $start_at {
        THROW "Parameter 'end_at' must be strictly after 'start_at'";
    };

    -- ------------------------------------------------------------------------
    -- 2. VALEURS PAR DÃ‰FAUT ET VALIDATIONS (Syntaxe SurrealQL IF {} ELSE {})
    -- ------------------------------------------------------------------------
    LET $before = IF $buf_before_min != NONE { $buf_before_min } ELSE { 0 };
    LET $after = IF $buf_after_min != NONE { $buf_after_min } ELSE { 0 };

    IF $before < 0 {
        THROW "Parameter 'buf_before_min' must be >= 0";
    };
    IF $after < 0 {
        THROW "Parameter 'buf_after_min' must be >= 0";
    };

    -- ------------------------------------------------------------------------
    -- 3. CALCUL TEMPOREL DE LA MARGE DE SÃ‰CURITÃ‰
    -- ------------------------------------------------------------------------
    LET $padded_start = $start_at - ($before * 1m);
    LET $padded_end = $end_at + ($after * 1m);

    -- ------------------------------------------------------------------------
    -- 4. RETOUR DU CONTEXTE D'OCCUPATION Ã‰TENDU
    -- ------------------------------------------------------------------------
    RETURN {
        original_start: $start_at,
        original_end: $end_at,
        padded_start: $padded_start,
        padded_end: $padded_end,
        buffer_before_min: $before,
        buffer_after_min: $after
    };
} COMMENT "Applique les marges horaires de sÃ©curitÃ© avant et aprÃ¨s un rendez-vous";

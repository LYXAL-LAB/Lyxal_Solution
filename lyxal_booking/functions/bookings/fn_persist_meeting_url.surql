-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_persist_meeting_url                                       â”‚
-- â”‚  Enregistre l'URL de visioconfÃ©rence gÃ©nÃ©rÃ©e (Google Meet, Jitsi, etc.)  â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_persist_meeting_url(
    $booking_id: option<record<booking>>,
    $url: option<string>
) {
    IF $booking_id == NONE {
        THROW "Parameter 'booking_id' is required";
    };

    LET $clean_url = IF $url != NONE { string::trim($url) } ELSE { NONE };
    UPDATE $booking_id SET meeting_url = $clean_url, updated_at = time::now();
    
    RETURN true;
} COMMENT "Enregistre l'URL de visioconfÃ©rence dynamique associÃ©e Ã  un rendez-vous";

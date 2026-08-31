-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_due_reminders                                         â”‚
-- â”‚  RÃ©cupÃ¨re les rappels de rendez-vous arrivÃ©s Ã  Ã©chÃ©ance                 â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_due_reminders() {
    LET $now = time::now();
    RETURN SELECT 
        id,
        booking,
        booking.booker_name AS booker_name,
        booking.booker_email AS booker_email,
        booking.booker_timezone AS booker_timezone,
        booking.start_at AS start_at,
        booking.end_at AS end_at,
        booking.meeting_url AS meeting_url,
        booking.event_type.title AS title,
        booking.host.name AS host_name,
        booking.host.email AS host_email,
        reminder_type,
        scheduled_at
    FROM booking_reminder
    WHERE status = 'pending'
      AND scheduled_at <= $now
    ORDER BY scheduled_at ASC
    LIMIT 100;
} COMMENT "RÃ©cupÃ¨re la liste des rappels par e-mail/SMS arrivÃ©s Ã  Ã©chÃ©ance pour les workers d'arriÃ¨re-plan";

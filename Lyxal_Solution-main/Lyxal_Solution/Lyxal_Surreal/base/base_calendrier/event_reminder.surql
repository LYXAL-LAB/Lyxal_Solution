-- Rappel d'événement 
DEFINE TABLE event_reminder SCHEMAFULL;
DEFINE FIELD name ON event_reminder TYPE string ASSERT $value != NONE;
DEFINE FIELD event ON event_reminder TYPE record<event>;
DEFINE FIELD reminder_type_select ON event_reminder TYPE int DEFAULT 1; -- 1:Popup, 2:Email, 3:SMS
DEFINE FIELD duration ON event_reminder TYPE duration;
DEFINE FIELD duration_type_select ON event_reminder TYPE int DEFAULT 1; -- 1:Minutes, 2:Hours, 3:Days
DEFINE FIELD duration_value ON event_reminder TYPE int DEFAULT 15;
DEFINE FIELD is_sent ON event_reminder TYPE bool DEFAULT false;
DEFINE FIELD sent_date_time ON event_reminder TYPE datetime;
DEFINE FIELD reminder_date_time ON event_reminder TYPE datetime;
DEFINE FIELD message ON event_reminder TYPE string;
DEFINE FIELD email_template ON event_reminder TYPE record<email_template>;
DEFINE FIELD created_at ON event_reminder TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON event_reminder TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON event_reminder TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_event_reminder_event ON event_reminder FIELDS event;
DEFINE INDEX idx_event_reminder_type ON event_reminder FIELDS reminder_type_select;
DEFINE INDEX idx_event_reminder_is_sent ON event_reminder FIELDS is_sent;

-- Participant d'événement (EventAttendee.xml - 837 bytes)
DEFINE TABLE event_attendee SCHEMAFULL;
DEFINE FIELD event ON event_attendee TYPE record<event>;
DEFINE FIELD user ON event_attendee TYPE record<user>;
DEFINE FIELD partner ON event_attendee TYPE record<partner>;
DEFINE FIELD email ON event_attendee TYPE string;
DEFINE FIELD response_status ON event_attendee TYPE int DEFAULT 1; -- 1:Needs Action, 2:Accepted, 3:Declined, 4:Tentative
DEFINE FIELD is_organizer ON event_attendee TYPE bool DEFAULT false;
DEFINE FIELD attendance_status ON event_attendee TYPE int DEFAULT 1; -- 1:Required, 2:Optional
DEFINE FIELD response_date ON event_attendee TYPE datetime;
DEFINE FIELD comment ON event_attendee TYPE string;
DEFINE FIELD created_at ON event_attendee TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON event_attendee TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON event_attendee TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_event_attendee_event ON event_attendee FIELDS event;
DEFINE INDEX idx_event_attendee_user ON event_attendee FIELDS user;
DEFINE INDEX idx_event_attendee_partner ON event_attendee FIELDS partner;
DEFINE INDEX idx_event_attendee_response ON event_attendee FIELDS response_status;
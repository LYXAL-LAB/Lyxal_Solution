-- Événement/Rendez-vous (Event.xml - 2811 bytes)
DEFINE TABLE event SCHEMAFULL;
DEFINE FIELD subject ON event TYPE string ASSERT $value != NONE;
DEFINE FIELD event_type_select ON event TYPE int DEFAULT 1; -- 1:Meeting, 2:Call, 3:Task, 4:Email
DEFINE FIELD start_date_time ON event TYPE datetime;
DEFINE FIELD end_date_time ON event TYPE datetime;
DEFINE FIELD duration ON event TYPE duration;
DEFINE FIELD all_day ON event TYPE bool DEFAULT false;
DEFINE FIELD location ON event TYPE string;
DEFINE FIELD description ON event TYPE string;
DEFINE FIELD user ON event TYPE record<user>; -- Organizer
DEFINE FIELD attendee_list ON event TYPE array<record<event_attendee>>;
DEFINE FIELD related_to_select ON event TYPE string; -- Type of related object
DEFINE FIELD related_to_select_id ON event TYPE string; -- ID of related object
DEFINE FIELD lead ON event TYPE record<lead>;
DEFINE FIELD partner ON event TYPE record<partner>;
DEFINE FIELD opportunity ON event TYPE record<opportunity>;
DEFINE FIELD event_status_select ON event TYPE int DEFAULT 1; -- 1:Planned, 2:Realized, 3:Canceled
DEFINE FIELD visibility_select ON event TYPE int DEFAULT 1; -- 1:Private, 2:Public, 3:Confidential
DEFINE FIELD status_select ON event TYPE int DEFAULT 1; -- 1:Free, 2:Busy, 3:Tentative, 4:Out of office
DEFINE FIELD priority_select ON event TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High
DEFINE FIELD event_category ON event TYPE record<event_category>;
DEFINE FIELD calendar ON event TYPE record<calendar>;
DEFINE FIELD reminder_list ON event TYPE array<record<event_reminder>>;
DEFINE FIELD is_meeting ON event TYPE bool DEFAULT false;
DEFINE FIELD is_task ON event TYPE bool DEFAULT false;
DEFINE FIELD is_call ON event TYPE bool DEFAULT false;
DEFINE FIELD call_direction_select ON event TYPE int; -- 1:Incoming, 2:Outgoing
DEFINE FIELD call_duration ON event TYPE duration;
DEFINE FIELD call_result ON event TYPE string;
DEFINE FIELD task_status_select ON event TYPE int DEFAULT 1; -- 1:Not Started, 2:In Progress, 3:Completed, 4:Waiting, 5:Deferred
DEFINE FIELD completion_percentage ON event TYPE int DEFAULT 0;
DEFINE FIELD due_date ON event TYPE date;
DEFINE FIELD recurring_event ON event TYPE bool DEFAULT false;
DEFINE FIELD recurrence_configuration ON event TYPE record<recurrence_configuration>;
DEFINE FIELD created_at ON event TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON event TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON event_type_select TYPE int DEFAULT 0;



DEFINE INDEX idx_event_subject ON event FIELDS subject;
DEFINE INDEX idx_event_start_date ON event FIELDS start_date_time;
DEFINE INDEX idx_event_end_date ON event FIELDS end_date_time;
DEFINE INDEX idx_event_user ON event FIELDS user;
DEFINE INDEX idx_event_type ON event FIELDS event_type_select;
DEFINE INDEX idx_event_status ON event FIELDS event_status_select;
DEFINE INDEX idx_event_lead ON event FIELDS lead;
DEFINE INDEX idx_event_partner ON event FIELDS partner;
DEFINE INDEX idx_event_opportunity ON event FIELDS opportunity;
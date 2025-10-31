-- =============================================================================
-- TABLE: planning_event (PlanningEvent)
-- Événement de planification
-- =============================================================================
DEFINE TABLE planning_event SCHEMAFULL;

-- Nom et description
DEFINE FIELD name ON planning_event TYPE string;
DEFINE FIELD description ON planning_event TYPE option<string>;

-- Dates
DEFINE FIELD startDate ON planning_event TYPE date;
DEFINE FIELD endDate ON planning_event TYPE option<date>;

-- Planification parente
DEFINE FIELD eventsPlanning ON planning_event TYPE record<events_planning>;

-- Type d'événement
DEFINE FIELD eventType ON planning_event TYPE option<string>; -- HOLIDAY, VACATION, MEETING, etc.

-- Récurrence
DEFINE FIELD isRecurrent ON planning_event TYPE bool DEFAULT false;
DEFINE FIELD recurrenceType ON planning_event TYPE option<string>; -- YEARLY, MONTHLY, WEEKLY

-- Index
DEFINE INDEX idx_planning_event_planning ON planning_event COLUMNS eventsPlanning;
DEFINE INDEX idx_planning_event_dates ON planning_event COLUMNS startDate, endDate;
DEFINE INDEX idx_planning_event_type ON planning_event COLUMNS eventType; 
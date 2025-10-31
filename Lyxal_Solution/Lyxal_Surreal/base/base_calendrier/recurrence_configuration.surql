-- Configuration de récurrence (RecurrenceConfiguration.xml - 1770 bytes)
DEFINE TABLE recurrence_configuration SCHEMAFULL;
DEFINE FIELD recurrence_type ON recurrence_configuration TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly, 4:Yearly
DEFINE FIELD periodicity ON recurrence_configuration TYPE int DEFAULT 1;
DEFINE FIELD end_type ON recurrence_configuration TYPE int DEFAULT 1; -- 1:Never, 2:After X occurrences, 3:End date
DEFINE FIELD repetitions_number ON recurrence_configuration TYPE int;
DEFINE FIELD end_date ON recurrence_configuration TYPE date;
DEFINE FIELD monday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD tuesday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD wednesday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD thursday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD friday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD saturday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD sunday ON recurrence_configuration TYPE bool DEFAULT false;
DEFINE FIELD monthly_repeat_type ON recurrence_configuration TYPE int DEFAULT 1; -- 1:By day, 2:By date
DEFINE FIELD day_in_month ON recurrence_configuration TYPE int;
DEFINE FIELD yearly_repeat_type ON recurrence_configuration TYPE int DEFAULT 1; -- 1:By day and month, 2:By date
DEFINE FIELD month_in_year ON recurrence_configuration TYPE int;
DEFINE FIELD created_at ON recurrence_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON recurrence_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON recurrence_configuration TYPE int DEFAULT 0;
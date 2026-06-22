DEFINE TABLE transaction_log SCHEMAFULL;
DEFINE FIELD eventId ON transaction_log TYPE string;
DEFINE FIELD user ON transaction_log TYPE option<record<user>>;
DEFINE FIELD product ON transaction_log TYPE option<record<product>>;
DEFINE FIELD status ON transaction_log TYPE option<string>;
DEFINE FIELD customerEmail ON transaction_log TYPE option<string>;
DEFINE FIELD eventData ON transaction_log TYPE object DEFAULT {};
DEFINE FIELD createdAt ON transaction_log TYPE datetime DEFAULT time::now();
DEFINE INDEX eventIndex ON transaction_log FIELDS eventId UNIQUE;

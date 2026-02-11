-- Séquences pour bank payment
DEFINE TABLE sequence_bank_payment SCHEMAFULL;
DEFINE FIELD name ON sequence_bank_payment TYPE string;
DEFINE FIELD code ON sequence_bank_payment TYPE string;
DEFINE FIELD company ON sequence_bank_payment TYPE record<company>;
DEFINE FIELD prefix ON sequence_bank_payment TYPE string;
DEFINE FIELD suffix ON sequence_bank_payment TYPE string;
DEFINE FIELD padding ON sequence_bank_payment TYPE int DEFAULT 5;
DEFINE FIELD to_be_adder ON sequence_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD next_num ON sequence_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD generic_sequence ON sequence_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD year_select ON sequence_bank_payment TYPE int DEFAULT 0;
DEFINE FIELD month_select ON sequence_bank_payment TYPE int DEFAULT 0;
DEFINE FIELD sequence_type_select ON sequence_bank_payment TYPE string;
DEFINE FIELD created_at ON sequence_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sequence_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sequence_bank_payment TYPE int DEFAULT 0;
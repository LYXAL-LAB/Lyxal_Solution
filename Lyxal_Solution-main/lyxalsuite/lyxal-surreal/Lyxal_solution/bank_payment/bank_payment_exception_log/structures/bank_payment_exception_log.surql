-- Logs d'exception pour bank payment
DEFINE TABLE bank_payment_exception_log SCHEMAFULL;
DEFINE FIELD exception_origin ON bank_payment_exception_log TYPE record<exception_origin_bank_payment>;
DEFINE FIELD exception_date ON bank_payment_exception_log TYPE datetime DEFAULT time::now();
DEFINE FIELD exception_message ON bank_payment_exception_log TYPE string;
DEFINE FIELD exception_trace ON bank_payment_exception_log TYPE string;
DEFINE FIELD related_object_id ON bank_payment_exception_log TYPE string;
DEFINE FIELD related_object_type ON bank_payment_exception_log TYPE string;
DEFINE FIELD user ON bank_payment_exception_log TYPE record<user>;
DEFINE FIELD company ON bank_payment_exception_log TYPE record<company>;
DEFINE FIELD is_resolved ON bank_payment_exception_log TYPE bool DEFAULT false;
DEFINE FIELD resolution_date ON bank_payment_exception_log TYPE datetime;
DEFINE FIELD resolution_note ON bank_payment_exception_log TYPE string;
DEFINE FIELD created_at ON bank_payment_exception_log TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_payment_exception_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_payment_exception_log TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_bank_payment_exception_log_origin ON bank_payment_exception_log FIELDS exception_origin;
DEFINE INDEX idx_bank_payment_exception_log_date ON bank_payment_exception_log FIELDS exception_date;
DEFINE INDEX idx_bank_payment_exception_log_resolved ON bank_payment_exception_log FIELDS is_resolved; 
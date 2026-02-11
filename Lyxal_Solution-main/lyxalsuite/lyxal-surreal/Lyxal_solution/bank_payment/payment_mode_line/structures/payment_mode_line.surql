-- Lignes de mode de paiement
DEFINE TABLE payment_mode_line SCHEMAFULL;
DEFINE FIELD sequence ON payment_mode_line TYPE int;
DEFINE FIELD payment_mode ON payment_mode_line TYPE record<payment_mode_bank_payment>;
DEFINE FIELD name ON payment_mode_line TYPE string;
DEFINE FIELD code ON payment_mode_line TYPE string;
DEFINE FIELD bank_details ON payment_mode_line TYPE record<bank_details>;
DEFINE FIELD fees_amount ON payment_mode_line TYPE decimal;
DEFINE FIELD fees_percentage ON payment_mode_line TYPE decimal;
DEFINE FIELD is_fees_on_sender ON payment_mode_line TYPE bool DEFAULT true;
DEFINE FIELD max_amount_per_line ON payment_mode_line TYPE decimal;
DEFINE FIELD min_amount_per_line ON payment_mode_line TYPE decimal;
DEFINE FIELD created_at ON payment_mode_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_mode_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_mode_line TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_payment_mode_line_payment_mode ON payment_mode_line FIELDS payment_mode;
DEFINE INDEX idx_payment_mode_line_sequence ON payment_mode_line FIELDS sequence; 
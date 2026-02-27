-- Table custom_phrases
DEFINE TABLE custom_phrases SCHEMAFULL;
DEFINE FIELD locale ON TABLE custom_phrases TYPE string;
DEFINE FIELD key ON TABLE custom_phrases TYPE string;
DEFINE FIELD value ON TABLE custom_phrases TYPE string;
DEFINE FIELD created_at ON TABLE custom_phrases TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE custom_phrases TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_phrase_key ON TABLE custom_phrases COLUMNS locale, key UNIQUE;

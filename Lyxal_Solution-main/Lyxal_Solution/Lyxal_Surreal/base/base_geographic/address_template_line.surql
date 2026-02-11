-- Lignes de template d'adresse
DEFINE TABLE base_address_template_line SCHEMAFULL;
DEFINE FIELD address_template ON base_address_template_line TYPE record<base_address_template>;
DEFINE FIELD line_type ON base_address_template_line TYPE string;
DEFINE FIELD line_content ON base_address_template_line TYPE string;
DEFINE FIELD line_order ON base_address_template_line TYPE int;
DEFINE FIELD is_optional ON base_address_template_line TYPE bool DEFAULT false;
DEFINE FIELD created_at ON base_address_template_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_address_template_line TYPE datetime DEFAULT time::now();
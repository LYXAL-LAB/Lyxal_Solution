DEFINE TABLE IF NOT EXISTS base_product_variant_attr TYPE NORMAL SCHEMAFULL
COMMENT 'Attributs des variantes'
PERMISSIONS FULL;

DEFINE FIELD name ON base_product_variant_attr TYPE string;
DEFINE FIELD productVariantValueList ON base_product_variant_attr TYPE array<record<base_product_variant_value>>;

-- Index

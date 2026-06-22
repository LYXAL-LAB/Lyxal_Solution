DEFINE TABLE has_asset SCHEMAFULL TYPE RELATION FROM project TO file;
DEFINE FIELD filename ON has_asset TYPE string;
DEFINE FIELD description ON has_asset TYPE option<string>;
DEFINE FIELD createdAt ON has_asset TYPE datetime DEFAULT time::now();

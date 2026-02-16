DEFINE TABLE product SCHEMAFULL;
DEFINE FIELD name ON product TYPE string;
DEFINE FIELD description ON product TYPE option<string>;
DEFINE FIELD features ON product TYPE array<string> DEFAULT [];
DEFINE FIELD images ON product TYPE array<string> DEFAULT [];
DEFINE FIELD meta ON product TYPE object DEFAULT {};
DEFINE FIELD createdAt ON product TYPE datetime DEFAULT time::now();

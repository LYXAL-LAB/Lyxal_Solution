DEFINE TABLE domain SCHEMAFULL;
DEFINE FIELD domain ON domain TYPE string;
DEFINE FIELD txtRecord ON domain TYPE option<string>;
DEFINE FIELD status ON domain TYPE string ASSERT $value INSIDE ['INITIALIZING', 'ACTIVE', 'ERROR', 'PENDING'] DEFAULT 'INITIALIZING';
DEFINE FIELD error ON domain TYPE option<string>;
DEFINE FIELD createdAt ON domain TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON domain TYPE datetime DEFAULT time::now() VALUE time::now();
DEFINE INDEX domainUniqueIndex ON domain FIELDS domain UNIQUE;

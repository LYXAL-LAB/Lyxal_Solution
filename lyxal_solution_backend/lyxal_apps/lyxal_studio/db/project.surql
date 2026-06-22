DEFINE TABLE project SCHEMAFULL;
DEFINE FIELD title ON project TYPE string;
DEFINE FIELD domain ON project TYPE string;
DEFINE FIELD tags ON project TYPE array<string> DEFAULT [];
DEFINE FIELD user ON project TYPE option<record<user>>;
DEFINE FIELD previewImageAsset ON project TYPE option<record<file>>;
DEFINE FIELD isDeleted ON project TYPE bool DEFAULT false;
DEFINE FIELD marketplaceStatus ON project TYPE string ASSERT $value INSIDE ['UNLISTED', 'PENDING', 'APPROVED', 'REJECTED'] DEFAULT 'UNLISTED';
DEFINE INDEX projectDomainIndex ON project FIELDS domain UNIQUE;

DEFINE TABLE owns_domain SCHEMAFULL TYPE RELATION FROM project TO domain;
DEFINE FIELD txtRecord ON owns_domain TYPE string DEFAULT rand::uuid();
DEFINE FIELD cname ON owns_domain TYPE string;
DEFINE FIELD createdAt ON owns_domain TYPE datetime DEFAULT time::now();
DEFINE INDEX unique_project_domain ON owns_domain FIELDS [in, out] UNIQUE;

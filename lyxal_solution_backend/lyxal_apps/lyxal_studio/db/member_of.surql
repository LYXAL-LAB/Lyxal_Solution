DEFINE TABLE member_of SCHEMAFULL TYPE RELATION FROM user TO team;
DEFINE FIELD role ON member_of TYPE string DEFAULT 'member';

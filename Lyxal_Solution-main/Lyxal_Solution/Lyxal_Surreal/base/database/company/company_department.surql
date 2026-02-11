-- Départements d'entreprise
DEFINE TABLE IF NOT EXISTS company_department TYPE NORMAL SCHEMAFULL
    COMMENT 'Départements d\'entreprise'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

DEFINE FIELD IF NOT EXISTS name ON TABLE company_department
    TYPE string
    COMMENT 'Nom du département';

DEFINE FIELD IF NOT EXISTS code ON TABLE company_department
    TYPE string
    COMMENT 'Code du département';

DEFINE FIELD IF NOT EXISTS company ON TABLE company_department
    TYPE record<company>
    COMMENT 'Entreprise liée au département';

DEFINE FIELD IF NOT EXISTS parent_department ON TABLE company_department
    TYPE option<record<company_department>>
    COMMENT 'Département parent';

DEFINE FIELD IF NOT EXISTS manager ON TABLE company_department
    TYPE option<record<contact>>
    COMMENT 'Responsable du département';

DEFINE FIELD IF NOT EXISTS description ON TABLE company_department
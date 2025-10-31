export const CRM_SCHEMA = `
DEFINE TABLE lead SCHEMAFUL;
DEFINE FIELD code ON lead TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON lead TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON lead TYPE string;
DEFINE FIELD leadStatus ON lead TYPE record<lead_status>;
DEFINE FIELD opportunity ON lead TYPE record<opportunity>;
DEFINE FIELD partner ON lead TYPE record<partner>;
DEFINE FIELD assignedTo ON lead TYPE string;
DEFINE FIELD source ON lead TYPE record<lead_source>;
DEFINE FIELD score ON lead TYPE int;
DEFINE FIELD imported ON lead TYPE bool DEFAULT false;
DEFINE FIELD accessUntil ON lead TYPE datetime;
DEFINE FIELD createdAt ON lead TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON lead TYPE datetime DEFAULT time::now();
DEFINE INDEX lead_code_idx ON lead FIELDS code UNIQUE;

DEFINE TABLE opportunity SCHEMAFUL;
DEFINE FIELD code ON opportunity TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON opportunity TYPE string;
DEFINE FIELD description ON opportunity TYPE string;
DEFINE FIELD opportunityType ON opportunity TYPE record<opportunity_type>;
DEFINE FIELD opportunityStatus ON opportunity TYPE record<opportunity_status>;
DEFINE FIELD expectedAmount ON opportunity TYPE number;
DEFINE FIELD probability ON opportunity TYPE int;
DEFINE FIELD closingDate ON opportunity TYPE datetime;
DEFINE FIELD partner ON opportunity TYPE record<partner>;
DEFINE FIELD createdAt ON opportunity TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON opportunity TYPE datetime DEFAULT time::now();
DEFINE INDEX opportunity_code_idx ON opportunity FIELDS code UNIQUE;

DEFINE TABLE partner SCHEMAFUL;
DEFINE FIELD code ON partner TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON partner TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON partner TYPE string;
DEFINE FIELD phone ON partner TYPE string;
DEFINE FIELD mobile ON partner TYPE string;
DEFINE FIELD address ON partner TYPE record<address>;
DEFINE FIELD fidelity ON partner TYPE record<fidelity>;
DEFINE FIELD partnerStatus ON partner TYPE record<partner_status>;
DEFINE FIELD createdAt ON partner TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON partner TYPE datetime DEFAULT time::now();
DEFINE INDEX partner_code_idx ON partner FIELDS code UNIQUE;

DEFINE TABLE event SCHEMAFUL;
DEFINE FIELD name ON event TYPE string ASSERT $value != NONE;
DEFINE FIELD category ON event TYPE record<event_category>;
DEFINE FIELD startDate ON event TYPE datetime;
DEFINE FIELD endDate ON event TYPE datetime;
DEFINE FIELD location ON event TYPE string;
DEFINE FIELD notes ON event TYPE string;
DEFINE FIELD isRecurring ON event TYPE bool DEFAULT false;
DEFINE FIELD recurrence ON event TYPE record<recurrence_configuration>;
DEFINE FIELD reminder ON event TYPE record<event_reminder>;
DEFINE FIELD createdAt ON event TYPE datetime DEFAULT time::now();

DEFINE TABLE tour SCHEMAFUL;
DEFINE FIELD code ON tour TYPE string;
DEFINE FIELD name ON tour TYPE string;
DEFINE FIELD date ON tour TYPE datetime;
DEFINE FIELD createdAt ON tour TYPE datetime DEFAULT time::now();

DEFINE TABLE tour_line SCHEMAFUL;
DEFINE FIELD tour ON tour_line TYPE record<tour>;
DEFINE FIELD partner ON tour_line TYPE record<partner>;
DEFINE FIELD address ON tour_line TYPE record<address>;
DEFINE FIELD order ON tour_line TYPE int;
DEFINE FIELD notes ON tour_line TYPE string;
DEFINE FIELD done ON tour_line TYPE bool DEFAULT false;
DEFINE FIELD createdAt ON tour_line TYPE datetime DEFAULT time::now();

DEFINE TABLE lead_log SCHEMAFUL;
DEFINE FIELD lead ON lead_log TYPE record<lead>;
DEFINE FIELD type ON lead_log TYPE string;
DEFINE FIELD message ON lead_log TYPE string;
DEFINE FIELD date ON lead_log TYPE datetime DEFAULT time::now();

DEFINE TABLE lead_score_rule SCHEMAFUL;
DEFINE FIELD name ON lead_score_rule TYPE string;
DEFINE FIELD field ON lead_score_rule TYPE string;
DEFINE FIELD operator ON lead_score_rule TYPE string;
DEFINE FIELD value ON lead_score_rule TYPE string;
DEFINE FIELD score ON lead_score_rule TYPE int;

DEFINE TABLE lead_distribution_rule SCHEMAFUL;
DEFINE FIELD name ON lead_distribution_rule TYPE string;
DEFINE FIELD region ON lead_distribution_rule TYPE string;
DEFINE FIELD maxLeadsPerDay ON lead_distribution_rule TYPE int;
DEFINE FIELD assignTo ON lead_distribution_rule TYPE string;
DEFINE FIELD isActive ON lead_distribution_rule TYPE bool DEFAULT true;

DEFINE TABLE lead_access SCHEMAFUL;
DEFINE FIELD lead ON lead_access TYPE record<lead>;
DEFINE FIELD grantedTo ON lead_access TYPE string;
DEFINE FIELD accessUntil ON lead_access TYPE datetime;
DEFINE FIELD createdAt ON lead_access TYPE datetime DEFAULT time::now();

DEFINE TABLE partner_in_agency SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON partner_in_agency TYPE record<partner>;
DEFINE FIELD out ON partner_in_agency TYPE record<agency>;
DEFINE FIELD isPrimary ON partner_in_agency TYPE bool DEFAULT true;
DEFINE FIELD assignedAt ON partner_in_agency TYPE datetime DEFAULT time::now();

DEFINE TABLE lead_has_source SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON lead_has_source TYPE record<lead>;
DEFINE FIELD out ON lead_has_source TYPE record<lead_source>;
DEFINE FIELD capturedAt ON lead_has_source TYPE datetime DEFAULT time::now();

DEFINE TABLE lead_status SCHEMAFUL;
DEFINE FIELD code ON lead_status TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON lead_status TYPE string ASSERT $value != NONE;

DEFINE TABLE lead_source SCHEMAFUL;
DEFINE FIELD code ON lead_source TYPE string;
DEFINE FIELD name ON lead_source TYPE string;

DEFINE TABLE opportunity_status SCHEMAFUL;
DEFINE FIELD code ON opportunity_status TYPE string;
DEFINE FIELD name ON opportunity_status TYPE string;

DEFINE TABLE opportunity_type SCHEMAFUL;
DEFINE FIELD code ON opportunity_type TYPE string;
DEFINE FIELD name ON opportunity_type TYPE string;

DEFINE TABLE lost_reason SCHEMAFUL;
DEFINE FIELD code ON lost_reason TYPE string;
DEFINE FIELD name ON lost_reason TYPE string;

DEFINE TABLE event_category SCHEMAFUL;
DEFINE FIELD code ON event_category TYPE string;
DEFINE FIELD name ON event_category TYPE string;

DEFINE TABLE event_reminder SCHEMAFUL;
DEFINE FIELD offsetMinutes ON event_reminder TYPE int;
DEFINE FIELD method ON event_reminder TYPE string;

DEFINE TABLE recurrence_configuration SCHEMAFUL;
DEFINE FIELD frequency ON recurrence_configuration TYPE string;
DEFINE FIELD interval ON recurrence_configuration TYPE int;
DEFINE FIELD count ON recurrence_configuration TYPE int;
DEFINE FIELD until ON recurrence_configuration TYPE datetime;

DEFINE TABLE partner_status SCHEMAFUL;
DEFINE FIELD code ON partner_status TYPE string;
DEFINE FIELD name ON partner_status TYPE string;

DEFINE TABLE fidelity SCHEMAFUL;
DEFINE FIELD points ON fidelity TYPE int;
DEFINE FIELD level ON fidelity TYPE string;
DEFINE FIELD programName ON fidelity TYPE string;

DEFINE TABLE catalog SCHEMAFUL;
DEFINE FIELD code ON catalog TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON catalog TYPE string ASSERT $value != NONE;
DEFINE FIELD catalogType ON catalog TYPE record<catalog_type>;
DEFINE FIELD fileUrl ON catalog TYPE string;
DEFINE FIELD imageUrl ON catalog TYPE string;
DEFINE FIELD description ON catalog TYPE string;
DEFINE FIELD isActive ON catalog TYPE bool DEFAULT true;
DEFINE FIELD createdAt ON catalog TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON catalog TYPE datetime DEFAULT time::now();

DEFINE TABLE catalog_type SCHEMAFUL;
DEFINE FIELD code ON catalog_type TYPE string;
DEFINE FIELD name ON catalog_type TYPE string;

DEFINE TABLE crm_configuration SCHEMAFUL;
DEFINE FIELD code ON crm_configuration TYPE string;
DEFINE FIELD name ON crm_configuration TYPE string;
DEFINE FIELD defaultLeadStatus ON crm_configuration TYPE record<lead_status>;
DEFINE FIELD defaultOpportunityStatus ON crm_configuration TYPE record<opportunity_status>;
DEFINE FIELD notifyOnLeadAssign ON crm_configuration TYPE bool DEFAULT false;
DEFINE FIELD autoAssign ON crm_configuration TYPE bool DEFAULT false;
DEFINE FIELD createdAt ON crm_configuration TYPE datetime DEFAULT time::now();

DEFINE TABLE crm_reporting SCHEMAFUL;
DEFINE FIELD modelName ON crm_reporting TYPE string;
DEFINE FIELD metric ON crm_reporting TYPE string;
DEFINE FIELD value ON crm_reporting TYPE float;
DEFINE FIELD dimension ON crm_reporting TYPE string;
DEFINE FIELD label ON crm_reporting TYPE string;
DEFINE FIELD computedAt ON crm_reporting TYPE datetime DEFAULT time::now();

DEFINE TABLE crm_batch SCHEMAFUL;
DEFINE FIELD code ON crm_batch TYPE string;
DEFINE FIELD name ON crm_batch TYPE string;
DEFINE FIELD type ON crm_batch TYPE string;
DEFINE FIELD model ON crm_batch TYPE string;
DEFINE FIELD query ON crm_batch TYPE string;
DEFINE FIELD action ON crm_batch TYPE string;
DEFINE FIELD schedule ON crm_batch TYPE string;
DEFINE FIELD isActive ON crm_batch TYPE bool DEFAULT true;
DEFINE FIELD createdAt ON crm_batch TYPE datetime DEFAULT time::now();

DEFINE TABLE agency SCHEMAFUL;
DEFINE FIELD code ON agency TYPE string;
DEFINE FIELD name ON agency TYPE string;
DEFINE FIELD description ON agency TYPE string;
DEFINE FIELD address ON agency TYPE record<address>;
DEFINE FIELD createdAt ON agency TYPE datetime DEFAULT time::now();

DEFINE TABLE corporate_partner_domain SCHEMAFUL;
DEFINE FIELD domain ON corporate_partner_domain TYPE string;
DEFINE FIELD description ON corporate_partner_domain TYPE string;
DEFINE FIELD createdAt ON corporate_partner_domain TYPE datetime DEFAULT time::now();
`;

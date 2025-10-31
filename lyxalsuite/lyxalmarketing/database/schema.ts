export const MARKETING_SCHEMA = `
-- Tables principales

DEFINE TABLE campaign_type SCHEMAFUL;
DEFINE FIELD name ON campaign_type TYPE string ASSERT $value != NONE;

DEFINE TABLE target_list SCHEMAFUL;
DEFINE FIELD name ON target_list TYPE string ASSERT $value != NONE;
DEFINE FIELD partnerTypeSelect ON target_list TYPE int;
DEFINE FIELD partnerQuery ON target_list TYPE string;
DEFINE FIELD partnerQueryTypeSelect ON target_list TYPE int DEFAULT 0;
DEFINE FIELD leadQuery ON target_list TYPE string;
DEFINE FIELD leadQueryTypeSelect ON target_list TYPE int DEFAULT 0;
DEFINE FIELD partnerFilterList ON target_list TYPE array;
DEFINE FIELD leadFilterList ON target_list TYPE array;
DEFINE FIELD partnerSet ON target_list TYPE array;
DEFINE FIELD leadSet ON target_list TYPE array;

DEFINE TABLE campaign SCHEMAFUL;
DEFINE FIELD name ON campaign TYPE string ASSERT $value != NONE;
DEFINE FIELD stageSelect ON campaign TYPE int;
DEFINE FIELD subject ON campaign TYPE string;
DEFINE FIELD description ON campaign TYPE string;
DEFINE FIELD report ON campaign TYPE string;
DEFINE FIELD partnerTemplate ON campaign TYPE record(template);
DEFINE FIELD leadTemplate ON campaign TYPE record(template);
DEFINE FIELD partnerReminderTemplate ON campaign TYPE record(template);
DEFINE FIELD leadReminderTemplate ON campaign TYPE record(template);
DEFINE FIELD emailing ON campaign TYPE bool DEFAULT false;
DEFINE FIELD manageAnEventPerTarget ON campaign TYPE bool DEFAULT false;
DEFINE FIELD manageAttendees ON campaign TYPE bool DEFAULT false;
DEFINE FIELD generateEventPerPartnerOrLead ON campaign TYPE bool DEFAULT false;
DEFINE FIELD isAllowEditingOfTargets ON campaign TYPE bool DEFAULT true;
DEFINE FIELD eventTypeSelect ON campaign TYPE int;
DEFINE FIELD eventStartDateTime ON campaign TYPE datetime;
DEFINE FIELD eventEndDateTime ON campaign TYPE datetime;
DEFINE FIELD duration ON campaign TYPE int;
DEFINE FIELD eventStartDateT ON campaign TYPE datetime;
DEFINE FIELD eventEndDateT ON campaign TYPE datetime;
DEFINE FIELD eventUser ON campaign TYPE record(user);
DEFINE FIELD team ON campaign TYPE record(team);
DEFINE FIELD emailAccount ON campaign TYPE record(email_account);
DEFINE FIELD emailLog ON campaign TYPE record(meta_file);
DEFINE FIELD campaignType ON campaign TYPE record(campaign_type);
DEFINE FIELD leads ON campaign TYPE array;
DEFINE FIELD partners ON campaign TYPE array;
DEFINE FIELD partnerSet ON campaign TYPE array;
DEFINE FIELD leadSet ON campaign TYPE array;
DEFINE FIELD invitedPartnerSet ON campaign TYPE array;
DEFINE FIELD invitedLeadSet ON campaign TYPE array;
DEFINE FIELD notParticipatingPartnerSet ON campaign TYPE array;
DEFINE FIELD notParticipatingLeadSet ON campaign TYPE array;
DEFINE FIELD presentPartnerSet ON campaign TYPE array;
DEFINE FIELD presentLeadSet ON campaign TYPE array;
DEFINE FIELD targetModelSet ON campaign TYPE array;
DEFINE FIELD campaignReminderList ON campaign TYPE array;
DEFINE FIELD sequence ON campaign TYPE int;

DEFINE TABLE campaign_reminder SCHEMAFUL;
DEFINE FIELD campaign ON campaign_reminder TYPE record(campaign);
DEFINE FIELD typeSelect ON campaign_reminder TYPE int DEFAULT 1;
DEFINE FIELD duration ON campaign_reminder TYPE int;
DEFINE FIELD durationTypeSelect ON campaign_reminder TYPE int DEFAULT 3;
DEFINE FIELD assignToSelect ON campaign_reminder TYPE int;
DEFINE FIELD isReminded ON campaign_reminder TYPE bool DEFAULT false;
DEFINE FIELD batchSet ON campaign_reminder TYPE array;

DEFINE TABLE campaign_attendee SCHEMAFUL;
DEFINE FIELD relatedToSelect ON campaign_attendee TYPE int;
DEFINE FIELD relatedToSelectId ON campaign_attendee TYPE string;
DEFINE FIELD campaign ON campaign_attendee TYPE record(campaign);

-- Extension CRM
DEFINE TABLE crm_event SCHEMAFUL;
DEFINE FIELD campaign ON crm_event TYPE record(campaign);
`;

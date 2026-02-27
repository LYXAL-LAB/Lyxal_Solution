DEFINE TABLE organization_jit_email_domains SCHEMAFULL;

DEFINE FIELD tenant ON TABLE organization_jit_email_domains TYPE record<tenants> ASSERT $value != NONE;
DEFINE FIELD organization ON TABLE organization_jit_email_domains TYPE record<organizations> ASSERT $value != NONE;
DEFINE FIELD email_domain ON TABLE organization_jit_email_domains TYPE string ASSERT $value != NONE;

DEFINE INDEX primary ON TABLE organization_jit_email_domains COLUMNS tenant, organization, email_domain UNIQUE;

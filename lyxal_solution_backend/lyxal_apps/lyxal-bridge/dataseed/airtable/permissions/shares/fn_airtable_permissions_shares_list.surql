-- Airtable -> permissions -> Shares -> List shares
---- get https://api.airtable.com/v0/meta/bases/{baseId}/shares
---- Lists basic information of base shares.

-- Requirements
---- Authentication - Personal access token, OAuth integration
---- Scope - workspacesAndBases.shares:manage
---- User role - Base editor
---- Billing plans - Enterprise (pre-2023.08 legacy plan), Enterprise Scale

-- Path parameters
---- baseId - string

-- Response format
---- shares - array of the below object
---- state - "enabled" | "disabled"
---- createdByUserId - string A user ID

createdTime
string
A date timestamp in the ISO format, eg:"2018-01-01T00:00:00.000Z"

restrictedToEnterpriseMembers
boolean
If true, this share is only accessible by members of the enterprise account. This works in conjunction with effectiveEmailDomainAllowList.

shareId
string
The full ShareId (unique identifier for the share).

shareTokenPrefix
string
This property is deprecated
Only the first 8 characters of the shareId.

Please use shareId instead.

type
"base" | "view" | "blockInstallation"
canBeSynced
optional<boolean>
Denotes if the shared view can be synced. View and enterprise specific sync restrictions may also apply.

isPasswordProtected
boolean
blockInstallationId
optional<string>
restrictedToEmailDomains
array of strings
If non-empty, the email domain restrictions assigned to the share. If empty, no domain restrictions are assigned to the share, but higher level ones may still affect it. We recommend using effectiveEmailDomainAllowList to understand share accessibility.

viewId
optional<string>
effectiveEmailDomainAllowList
optional<array of strings>
The effective email domain allow list factoring all restrictions, including the share's email domain restrictions and all restrictions above the share (e.g. enterprise sharing restrictions). If this field is omitted, there are no email domain restrictions on the share. Otherwise, a viewer must have an account associated with an email domain included in the allow list. If this list is empty, no viewer can see the share (e.g. no member of restrictedToEmailDomains is allowed by enterprise-wise sharing restrictions).
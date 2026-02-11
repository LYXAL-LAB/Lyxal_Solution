-- Table: bunny_team_member_model
-- Source: TeamMemberModel
-- Description: Table pour TeamMemberModel

DEFINE TABLE IF NOT EXISTS bunny_team_member_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour TeamMemberModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_team_member_model
  TYPE option<string>
  COMMENT 'The unique id of the user';

DEFINE FIELD IF NOT EXISTS email ON bunny_team_member_model
  TYPE option<string>
  COMMENT 'The email of the user';

DEFINE FIELD IF NOT EXISTS first_name ON bunny_team_member_model
  TYPE option<string>
  COMMENT 'The first name of the user';

DEFINE FIELD IF NOT EXISTS last_name ON bunny_team_member_model
  TYPE option<string>
  COMMENT 'The last name of the user';

DEFINE FIELD IF NOT EXISTS date_joined ON bunny_team_member_model
  TYPE datetime
  ASSERT $value != NONE
  COMMENT 'The date when the user joined bunny.net';

DEFINE FIELD IF NOT EXISTS email_verified ON bunny_team_member_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the account\'s email has been successfuly verified';

DEFINE FIELD IF NOT EXISTS roles ON bunny_team_member_model
  TYPE option<array<option<string>>>
  COMMENT 'Determines the roles that the user belongs to';

DEFINE FIELD IF NOT EXISTS two_factor_authentication_enabled ON bunny_team_member_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the user has active 2FA configuration';

DEFINE FIELD IF NOT EXISTS is_main_user ON bunny_team_member_model
  TYPE bool
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_team_member_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_team_member_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_team_invite                                                    │
-- │  Invitations à rejoindre une équipe d'hôtes                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_team_invite TYPE NORMAL SCHEMAFULL
    COMMENT "Invitations envoyées par e-mail pour rejoindre une équipe"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE team.created_by = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET JETON D'INVITATION D'ÉQUIPE
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS team
    ON TABLE booking_team_invite
    TYPE record<booking_team>
    COMMENT "Équipe concernée par l'invitation";

DEFINE FIELD IF NOT EXISTS email
    ON TABLE booking_team_invite
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::is::email($value)
    COMMENT "Adresse email du membre invité";

DEFINE FIELD IF NOT EXISTS role
    ON TABLE booking_team_invite
    TYPE string
    DEFAULT 'member'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['admin', 'member']
    COMMENT "Rôle proposé dans l'équipe : admin | member";

DEFINE FIELD IF NOT EXISTS token
    ON TABLE booking_team_invite
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Jeton d'accès unique d'invitation d'équipe";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE booking_team_invite
    TYPE string
    DEFAULT 'pending'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['pending', 'accepted', 'declined', 'expired']
    COMMENT "Statut de l'invitation : pending | accepted | declined | expired";

DEFINE FIELD IF NOT EXISTS expires_at
    ON TABLE booking_team_invite
    TYPE datetime
    COMMENT "Date d'expiration de l'invitation";

DEFINE FIELD IF NOT EXISTS invited_by
    ON TABLE booking_team_invite
    TYPE option<record<booking_account>>
    COMMENT "Administrateur ayant émis l'invitation";

DEFINE FIELD IF NOT EXISTS accepted_by
    ON TABLE booking_team_invite
    TYPE option<record<booking_account>>
    COMMENT "Compte utilisateur ayant accepté l'invitation";

DEFINE FIELD IF NOT EXISTS accepted_at
    ON TABLE booking_team_invite
    TYPE option<datetime>
    COMMENT "Date et heure d'acceptation de l'invitation";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_team_invite
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création de l'invitation";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_team_invite_token
    ON TABLE booking_team_invite
    FIELDS token UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_team_invite_team_email
    ON TABLE booking_team_invite
    FIELDS team, email;

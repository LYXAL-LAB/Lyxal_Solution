-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_account                                                        │
-- │  Comptes utilisateurs / Hôtes de réservation - Version SurrealDB Avancée │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_account TYPE NORMAL SCHEMAFULL
    COMMENT "Comptes utilisateurs et hôtes de réservation"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE true
        FOR update, delete WHERE id = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- CHAMPS OBLIGATOIRES AVEC AUTO-FORMATAGE ET ASSERTIONS
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS name
    ON TABLE booking_account
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Nom complet de l'hôte";

DEFINE FIELD IF NOT EXISTS email
    ON TABLE booking_account
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::is::email($value)
    COMMENT "Adresse email unique de l'hôte";

DEFINE FIELD IF NOT EXISTS password_hash
    ON TABLE booking_account
    TYPE option<string>
    COMMENT "Hash argon2/pbkdf2 du mot de passe pour l'authentification locale";

DEFINE FIELD IF NOT EXISTS role
    ON TABLE booking_account
    TYPE string
    DEFAULT 'user'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['admin', 'user']
    COMMENT "Rôle de l'utilisateur ('admin' ou 'user')";

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE booking_account
    TYPE bool
    DEFAULT true
    COMMENT "Statut d'activation du compte";

DEFINE FIELD IF NOT EXISTS auth_provider
    ON TABLE booking_account
    TYPE string
    DEFAULT 'local'
    VALUE string::lowercase(string::trim($value))
    COMMENT "Fournisseur d'identité ('local', 'oidc', etc.)";

-- ----------------------------------------------------------------------------
-- CHAMPS OPTIONNELS NETTOYÉS AUTOMATIQUEMENT
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS username
    ON TABLE booking_account
    TYPE option<string>
    VALUE IF $value != NONE THEN string::lowercase(string::trim($value)) ELSE NONE END
    COMMENT "Nom d'utilisateur unique pour URL publique de réservation";

DEFINE FIELD IF NOT EXISTS timezone
    ON TABLE booking_account
    TYPE string
    DEFAULT 'UTC'
    VALUE string::trim($value)
    COMMENT "Fuseau horaire par défaut de l'hôte";

DEFINE FIELD IF NOT EXISTS language
    ON TABLE booking_account
    TYPE string
    DEFAULT 'fr'
    VALUE string::lowercase(string::trim($value))
    COMMENT "Langue d'affichage préférée (fr, en, etc.)";

DEFINE FIELD IF NOT EXISTS avatar_url
    ON TABLE booking_account
    TYPE option<string>
    VALUE IF $value != NONE THEN string::trim($value) ELSE NONE END
    COMMENT "URL de la photo de profil / avatar";

DEFINE FIELD IF NOT EXISTS bio
    ON TABLE booking_account
    TYPE option<string>
    VALUE IF $value != NONE THEN string::trim($value) ELSE NONE END
    COMMENT "Description / biographie affichée sur la page publique";

DEFINE FIELD IF NOT EXISTS theme
    ON TABLE booking_account
    TYPE string
    DEFAULT 'light'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['light', 'dark', 'system']
    COMMENT "Thème graphique préféré (light, dark, system)";

DEFINE FIELD IF NOT EXISTS accent_color
    ON TABLE booking_account
    TYPE option<string>
    VALUE IF $value != NONE THEN string::trim($value) ELSE NONE END
    COMMENT "Couleur d'accentuation de la page publique (ex: #3b82f6)";

DEFINE FIELD IF NOT EXISTS oidc_issuer
    ON TABLE booking_account
    TYPE option<string>
    COMMENT "URL de l'émetteur OIDC (ex: https://auth.example.com)";

DEFINE FIELD IF NOT EXISTS oidc_sub
    ON TABLE booking_account
    TYPE option<string>
    COMMENT "Identifiant unique de l'utilisateur chez le fournisseur OIDC";

-- ----------------------------------------------------------------------------
-- HORODATAGES AUTOMATIQUES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_account
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création du compte (immuable)";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE booking_account
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Date de dernière modification du compte (mise à jour automatique)";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_account_email
    ON TABLE booking_account
    FIELDS email UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_booking_account_username
    ON TABLE booking_account
    FIELDS username UNIQUE;

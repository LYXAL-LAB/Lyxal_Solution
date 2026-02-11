-- ============================================================
-- TEMPLATE: PERSONAL VAULT
-- Namespace: NS_IDENTITY_{UUID} / Database: MAIN
-- Ce schéma est appliqué dans le namespace privé de chaque identité.
-- ============================================================

-- 1. PROFIL IDENTITÉ
DEFINE TABLE profile SCHEMAFULL;
DEFINE FIELD full_name    ON TABLE profile TYPE string;
DEFINE FIELD avatar_url   ON TABLE profile TYPE string;
DEFINE FIELD preferences  ON TABLE profile TYPE object DEFAULT {};
DEFINE FIELD updated_at   ON TABLE profile TYPE datetime DEFAULT time::now() VALUE time::now();

-- 2. CREDENTIALS TIERS (OAUTH)
-- Stockage souverain des tokens d'accès aux services externes.
DEFINE TABLE credential SCHEMAFULL;
DEFINE FIELD provider     ON TABLE credential TYPE string; -- ex: "google", "slack"
DEFINE FIELD email        ON TABLE credential TYPE string; -- l'email associé au compte tiers

-- Données sensibles (DOIT ÊTRE CHIFFRÉ CÔTÉ APP AVANT INSERTION)
-- Structure attendue (chiffrée) : { access_token, refresh_token, expires_at }
DEFINE FIELD encrypted_data ON TABLE credential TYPE string;

DEFINE FIELD created_at   ON TABLE credential TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at   ON TABLE credential TYPE datetime DEFAULT time::now() VALUE time::now();

DEFINE INDEX idx_provider_email ON TABLE credential COLUMNS provider, email UNIQUE;

-- 3. SECRET AUTH (Souveraineté Totale)
-- Stocke le hash du mot de passe dans le namespace de l'identité.
-- Seul le système d'identité (avec credentials root/admin) peut lire/écrire ici lors du login.
DEFINE TABLE secret SCHEMAFULL PERMISSIONS NONE;
DEFINE FIELD password_hash ON TABLE secret TYPE string;
DEFINE FIELD updated_at    ON TABLE secret TYPE datetime DEFAULT time::now() VALUE time::now();

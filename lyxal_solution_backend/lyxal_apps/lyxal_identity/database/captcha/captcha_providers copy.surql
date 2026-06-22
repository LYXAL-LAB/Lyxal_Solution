-- Table captcha_providers
DEFINE TABLE IF NOT EXISTS captcha_providers 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Table des fournisseurs de CAPTCHA";

---- Fields ----

DEFINE FIELD IF NOT EXISTS lyxal_identity ON TABLE captcha_providers 
    TYPE record<lyxal_identity>
    REFERENCE ON DELETE CASCADE
    COMMENT "Application lyxal_identity";

DEFINE FIELD IF NOT EXISTS provider_id ON TABLE captcha_providers TYPE string;
DEFINE FIELD IF NOT EXISTS type ON TABLE captcha_providers TYPE string ASSERT $value IN ['google_recaptcha', 'hcaptcha', 'cloudflare_turnstile', 'aliyun_captcha'];
DEFINE FIELD IF NOT EXISTS config ON TABLE captcha_providers TYPE object;
DEFINE FIELD IF NOT EXISTS is_enabled ON TABLE captcha_providers TYPE bool DEFAULT false;




-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE captcha_providers 
    TYPE object
    DEFAULT {}
    COMMENT "Timestamp";

    DEFINE FIELD timestamp.created_at ON TABLE captcha_providers 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de creation du profil";

    DEFINE FIELD timestamp.updated_at ON TABLE captcha_providers 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de modification du profil";

DEFINE INDEX idx_captcha_id ON TABLE captcha_providers COLUMNS provider_id UNIQUE;

create table captcha_providers (
  config jsonb /* @use CaptchaConfig */ not null default '{}'::jsonb,
  created_at timestamptz not null default(now()),
  updated_at timestamptz not null default(now()),
);

create index captcha_providers__id
  on captcha_providers (tenant_id, id);

-- Table captcha_providers
DEFINE TABLE captcha_providers SCHEMAFULL;
DEFINE FIELD provider_id ON TABLE captcha_providers TYPE string;
DEFINE FIELD type ON TABLE captcha_providers TYPE string ASSERT $value IN ['google_recaptcha', 'hcaptcha', 'cloudflare_turnstile', 'aliyun_captcha'];
DEFINE FIELD config ON TABLE captcha_providers TYPE object;
DEFINE FIELD is_enabled ON TABLE captcha_providers TYPE bool DEFAULT false;
DEFINE FIELD created_at ON TABLE captcha_providers TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_captcha_id ON TABLE captcha_providers COLUMNS provider_id UNIQUE;

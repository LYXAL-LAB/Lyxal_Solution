use std::path::PathBuf;
use std::sync::Arc;
use minijinja::Environment;
use lyxal_crypto::EncryptionKey;

use crate::crypto_helpers::BookingCryptoEngine;
use crate::db::SurrealBookingStore;
use crate::web::middleware::rate_limit::RateLimiter;
use crate::web::captcha::CaptchaConfig;
use crate::web::meeting::MeetingConfig;

#[derive(Clone)]
pub struct AppState {
    pub store: SurrealBookingStore,
    pub templates: Environment<'static>,
    pub login_limiter: RateLimiter,
    pub booking_limiter: RateLimiter,
    pub data_dir: PathBuf,
    pub crypto: Arc<BookingCryptoEngine>,
    /// LEGACY TRANSITION ONLY — LEGACY-CRYPTO-001
    pub legacy_secret_key: Option<Arc<EncryptionKey>>,
    pub secret_key: [u8; 32],
    pub theme_css: Arc<tokio::sync::RwLock<String>>,
    pub company_link: Arc<tokio::sync::RwLock<Option<String>>>,
    pub captcha_config: Arc<tokio::sync::RwLock<Option<CaptchaConfig>>>,
    pub meeting_config: Arc<tokio::sync::RwLock<MeetingConfig>>,
    pub csp: Arc<tokio::sync::RwLock<String>>,
    pub csp_baseline: String,
}

use lyxal_schema::User;
use lyxal_iam::services::UserService;
use std::sync::Arc;
use crate::AuthResult;
use lyxal_core::error::CoreError;
use lyxal_core::crypto::Crypto;

#[derive(Clone)]
pub struct AuthService {
    user_service: Arc<UserService>,
}

impl AuthService {
    pub fn new(user_service: Arc<UserService>) -> Self {
        Self { user_service }
    }

    pub async fn authenticate(
        &self,
        _username: Option<String>,
        _email: Option<String>,
        _password: String
    ) -> AuthResult<User> {
        tracing::info!("Authenticating user...");
        let email = _email.ok_or(CoreError::AuthenticationFailed)?;
        let user = self.user_service.get_user_by_email(email).await
            .map_err(|_| CoreError::AuthenticationFailed)?;

        if let Some(hash) = &user.password_hash {
            if Crypto::verify_password(&_password, hash).map_err(|_| CoreError::AuthenticationFailed)? {
                return Ok(user);
            }
        }
        
        Err(CoreError::AuthenticationFailed)
    }

    pub async fn register(
        &self,
        username: String,
        email: String,
        password: String
    ) -> AuthResult<User> {
        let password_hash = Crypto::hash_password(&password)
            .map_err(|e| CoreError::Internal(e.to_string()))?;
            
        self.user_service.create_user(Some(username), Some(email), Some(password_hash)).await
            .map_err(|_| CoreError::Internal("Failed to register".to_string()))
    }
}

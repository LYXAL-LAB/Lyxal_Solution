use lyxal_core::{CoreError, Crypto, Result};
use lyxal_iam::UserService;
use lyxal_schema::User;
use uuid::Uuid;
use crate::{AuthMethod, AuthResult};

/// Service handling authentication logic, verification, and login flows.
/// It interacts with the UserService to validate credentials.
#[derive(Clone)]
pub struct AuthService {
    user_service: UserService,
}

impl AuthService {
    /// Creates a new instance of AuthService.
    pub fn new(user_service: UserService) -> Self {
        Self { user_service }
    }

    /// Authenticates a user using their email and password.
    ///
    /// # Arguments
    /// * `email` - The primary email of the user.
    /// * `password` - The plain text password to verify.
    ///
    /// # Returns
    /// A Result containing the authenticated User or a CoreError.
    pub async fn authenticate_with_password(&self, email: &str, password: &str) -> Result<User> {
        // 1. Find user by email
        let user = self.user_service.get_user_by_email(email).await?;

        // 2. Check if user is suspended
        if user.suspended_at.is_some() {
            return Err(CoreError::Unauthorized("User account is suspended".to_string()));
        }

        // 3. Verify password hash
        let password_hash = user.password_hash.as_ref().ok_or_else(|| {
            CoreError::Unauthorized("User does not have a password set".to_string())
        })?;

        let is_valid = Crypto::verify_password(password, password_hash)?;

        if !is_valid {
            return Err(CoreError::Unauthorized("Invalid email or password".to_string()));
        }

        // 4. Check if email is verified (depending on policy, we might still allow login)
        if !user.is_email_verified {
            // We could return a specific error here or allow it but flag it
            tracing::warn!("User {} logged in with unverified email", user.id);
        }

        Ok(user)
    }

    /// Validates a magic link or verification code.
    /// (Placeholder for future implementation)
    pub async fn verify_magic_link(&self, token: &str) -> Result<User> {
        // This would involve a new repository for short-lived tokens
        // For now, returning a stub error
        Err(CoreError::Internal(anyhow::anyhow!("Magic link verification not yet implemented")))
    }

    /// Initiates a password reset flow.
    pub async fn initiate_password_reset(&self, email: &str) -> Result<String> {
        let user = self.user_service.get_user_by_email(email).await?;

        // Generate a random secure token
        let token = Crypto::generate_random_token();

        // TODO: Store token in database with expiration and user_id mapping
        // TODO: Send email with token

        tracing::info!("Password reset initiated for user: {}", user.id);
        Ok(token)
    }

    /// Completes a password reset flow.
    pub async fn complete_password_reset(&self, token: &str, new_password: &str) -> Result<()> {
        // TODO: Validate token and get user_id
        // let user_id = ...;

        // let new_hash = Crypto::hash_password(new_password)?;
        // Update user password_hash in DB via user_service

        Err(CoreError::Internal(anyhow::anyhow!("Password reset completion not yet implemented")))
    }
}

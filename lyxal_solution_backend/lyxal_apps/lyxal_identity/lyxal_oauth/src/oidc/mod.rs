use serde::{Deserialize, Serialize};

/// Standard ID Token claims as defined in OIDC Core.
/// See: https://openid.net/specs/openid-connect-core-1_0.html#IDToken
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IdTokenClaims {
    /// Issuer Identifier for the Issuer of the response.
    pub iss: String,
    /// Subject Identifier. A unique identifier for the End-User at the Issuer.
    pub sub: String,
    /// Audience(s) that this ID Token is intended for.
    pub aud: String,
    /// Expiration time on or after which the ID Token MUST NOT be accepted for processing.
    pub exp: i64,
    /// Time at which the JWT was issued.
    pub iat: i64,
    /// String value used to associate a Client session with an ID Token.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nonce: Option<String>,
    /// Time when the End-User authentication occurred.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub auth_time: Option<i64>,
}

/// Access Token claims for JWT-formatted access tokens.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccessTokenClaims {
    /// Issuer Identifier.
    pub iss: String,
    /// Subject Identifier (User ID).
    pub sub: String,
    /// Audience (Client ID).
    pub aud: String,
    /// Expiration time.
    pub exp: i64,
    /// Issued at time.
    pub iat: i64,
    /// JWT ID. A unique identifier for the token.
    pub jti: String,
    /// Space-separated list of scopes.
    pub scope: String,
}

/// Parameters for the OIDC UserInfo response.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInfoClaims {
    pub sub: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub given_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub family_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub preferred_username: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email_verified: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub picture: Option<String>,
}

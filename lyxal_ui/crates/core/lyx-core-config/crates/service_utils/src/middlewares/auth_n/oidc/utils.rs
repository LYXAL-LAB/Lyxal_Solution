### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
use openidconnect::{AdditionalClaims, GenderClaim, IdTokenClaims, Nonce};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;

pub(super) fn verify_presence(n: Option<&Nonce>) -> Result<(), String> {
if n.is_some() {
Ok(())
} else {
Err("missing nonce claim".to_string())
}
}

pub(super) fn presence_no_check(_: Option<&Nonce>) -> Result<(), String> {
Ok(())
}

pub(super) fn try_user_from<A: AdditionalClaims, B: GenderClaim>(
claims: &IdTokenClaims<A, B>,
) -> Result<User, String> {
let user = User {
email: claims
.email()
.ok_or(String::from("Email not found"))?
.to_string(),
username: claims
.preferred_username()
.ok_or(String::from("Username not found"))?
.to_string(),
};
Ok(user)
}

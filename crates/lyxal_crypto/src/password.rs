use crate::error::CryptoError;
use argon2::password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString};
use argon2::{Algorithm, Argon2, Params, Version};
use rand_core::OsRng;

/// Paramètres de référence de la politique de hachage de mot de passe Lyxal OS.
pub const LYXAL_ARGON2_M_COST: u32 = 65536; // 64 MB
pub const LYXAL_ARGON2_T_COST: u32 = 3; // 3 itérations
pub const LYXAL_ARGON2_P_COST: u32 = 1; // 1 thread
pub const LYXAL_ARGON2_VERSION: Version = Version::V0x13; // v19

fn get_lyxal_argon2_instance() -> Result<Argon2<'static>, CryptoError> {
    let params = Params::new(
        LYXAL_ARGON2_M_COST,
        LYXAL_ARGON2_T_COST,
        LYXAL_ARGON2_P_COST,
        None,
    )
    .map_err(|_| CryptoError::PasswordHashError)?;

    Ok(Argon2::new(
        Algorithm::Argon2id,
        LYXAL_ARGON2_VERSION,
        params,
    ))
}

/// Hache un mot de passe en utilisant Argon2id selon la politique stricte de Lyxal OS (format PHC).
///
/// Le sel cryptographique est généré aléatoirement via le CSPRNG système (`OsRng`).
pub fn hash_password(password: &str) -> Result<String, CryptoError> {
    let argon2 = get_lyxal_argon2_instance()?;
    let salt = SaltString::generate(&mut OsRng);

    let password_hash = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|_| CryptoError::PasswordHashError)?;

    Ok(password_hash.to_string())
}

/// Vérifie un mot de passe en clair par rapport à un hash au format standard PHC.
///
/// Effectue la comparaison en temps constant et renvoie `true` si le mot de passe est valide.
pub fn verify_password(password: &str, encoded_hash: &str) -> Result<bool, CryptoError> {
    let parsed_hash =
        PasswordHash::new(encoded_hash).map_err(|_| CryptoError::InvalidPasswordHash)?;
    let argon2 = Argon2::default();

    match argon2.verify_password(password.as_bytes(), &parsed_hash) {
        Ok(()) => Ok(true),
        Err(argon2::password_hash::Error::Password) => Ok(false),
        Err(_) => Err(CryptoError::PasswordHashError),
    }
}

/// Vérifie si un hash existant doit être mis à jour (rehash) pour correspondre à la politique actuelle de Lyxal OS.
///
/// Renvoie `true` si le hash utilise un algorithme différent d'Argon2id, une ancienne version, ou des paramètres inférieurs.
pub fn needs_rehash(encoded_hash: &str) -> bool {
    let parsed = match PasswordHash::new(encoded_hash) {
        Ok(h) => h,
        Err(_) => return true,
    };

    if parsed.algorithm != argon2::ARGON2ID_IDENT {
        return true;
    }

    if let Some(version) = parsed.version {
        if version != LYXAL_ARGON2_VERSION as u32 {
            return true;
        }
    } else {
        return true;
    }

    // Vérification des paramètres m, t, p
    if let Ok(params) = Params::try_from(&parsed) {
        if params.m_cost() != LYXAL_ARGON2_M_COST
            || params.t_cost() != LYXAL_ARGON2_T_COST
            || params.p_cost() != LYXAL_ARGON2_P_COST
        {
            return true;
        }
    } else {
        return true;
    }

    false
}

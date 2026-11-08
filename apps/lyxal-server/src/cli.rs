//! Commandes d'administration de l'hôte, exécutées sur une installation existante (serveur
//! démarré au moins une fois) puis terminées :
//!
//! * `lyxal-server admin setup --email <adresse>` : affiche une seule fois le lien d'installation
//!   du premier administrateur (valable 1 h ; refusé si un administrateur existe déjà) ;
//! * `lyxal-server auth rotate-signing-key [--force]` : active une nouvelle clé de signature des
//!   jetons d'accès dans l'emplacement inactif. Sans `--force`, refusé tant que des jetons signés
//!   par l'ancienne clé de cet emplacement peuvent être valides ; `--force` (clé compromise)
//!   l'écrase et invalide ces jetons.
//!
//! Sans argument, le binaire démarre le serveur.

use crate::config::AppConfig;
use crate::error::ServerError;
use crate::modules::auth::{self, AuthHost};
use crate::{crypto, database};
use std::sync::Arc;

/// Commande demandée sur la ligne de commande.
#[derive(Debug, PartialEq, Eq)]
pub enum Command {
    /// Démarre le serveur.
    Serve,
    /// Lien d'installation du premier administrateur.
    AdminSetup { email: String },
    /// Rotation de la clé de signature des jetons d'accès.
    RotateSigningKey { force: bool },
    /// Aide.
    Help,
}

/// Aide affichée par `--help` ou en cas de commande inconnue.
pub const USAGE: &str = "\
Utilisation :
  lyxal-server                                   démarre le serveur
  lyxal-server admin setup --email <adresse>     lien d'installation du premier administrateur
  lyxal-server auth rotate-signing-key [--force] nouvelle clé de signature des jetons d'accès
";

/// Lit les arguments (sans le nom du programme).
pub fn parse(args: &[String]) -> Result<Command, ServerError> {
    let words: Vec<&str> = args.iter().map(String::as_str).collect();
    match words.as_slice() {
        [] => Ok(Command::Serve),
        ["--help"] | ["-h"] | ["help"] => Ok(Command::Help),
        ["admin", "setup", "--email", email] => Ok(Command::AdminSetup {
            email: (*email).to_string(),
        }),
        ["auth", "rotate-signing-key"] => Ok(Command::RotateSigningKey { force: false }),
        ["auth", "rotate-signing-key", "--force"] => Ok(Command::RotateSigningKey { force: true }),
        _ => Err(ServerError::Configuration {
            message: format!("commande inconnue\n{USAGE}"),
        }),
    }
}

/// Exécute une commande d'administration et affiche son résultat.
pub async fn execute(command: Command) -> Result<(), ServerError> {
    match command {
        Command::Serve => Ok(()),
        Command::Help => {
            print!("{USAGE}");
            Ok(())
        }
        Command::AdminSetup { email } => {
            let host = connect().await?;
            let link = host
                .access
                .setup_link(&email)
                .await
                .map_err(|error| refused(&error))?;
            println!("Lien d'installation (valable 1 h, affiché une seule fois) :");
            println!("{}", link.expose_secret());
            Ok(())
        }
        Command::RotateSigningKey { force } => {
            let host = connect().await?;
            let slot = host
                .keys
                .rotate(force)
                .await
                .map_err(|error| refused(&error))?;
            println!("Nouvelle clé de signature active (emplacement {slot}).");
            Ok(())
        }
    }
}

async fn connect() -> Result<Arc<AuthHost>, ServerError> {
    let config = AppConfig::load()?;
    let client = database::connect_database(&config.database).await?;
    let crypto = crypto::application_crypto(&config.crypto)?;
    auth::host(&client, &config, crypto)?.ok_or(ServerError::AuthDisabled)
}

fn refused(error: &lyxal_auth::AuthError) -> ServerError {
    ServerError::Database {
        message: format!("{} ({error})", error.code()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn args(words: &[&str]) -> Vec<String> {
        words.iter().map(|w| (*w).to_string()).collect()
    }

    #[test]
    fn commands_are_parsed() {
        assert_eq!(parse(&[]).ok(), Some(Command::Serve));
        assert_eq!(
            parse(&args(&["admin", "setup", "--email", "a@example.com"])).ok(),
            Some(Command::AdminSetup {
                email: "a@example.com".into()
            })
        );
        assert_eq!(
            parse(&args(&["auth", "rotate-signing-key", "--force"])).ok(),
            Some(Command::RotateSigningKey { force: true })
        );
        assert!(parse(&args(&["admin", "setup"])).is_err());
        assert!(parse(&args(&["unknown"])).is_err());
    }
}

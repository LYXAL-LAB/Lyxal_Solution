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
use lyxal_i18n::{
    CheckReport, Exchange, ExportOptions, FileFormat, I18nStore, ImportOptions, ImportReport,
};
use std::collections::{HashMap, HashSet};
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
    /// Export des textes d'une langue dans un fichier.
    I18nExport {
        locale: String,
        output: String,
        format: FileFormat,
        namespace: Option<String>,
        tenant: Option<String>,
    },
    /// Import d'un fichier de textes dans une langue et une portée.
    I18nImport {
        locale: String,
        file: String,
        format: FileFormat,
        tenant: Option<String>,
        overwrite_reviewed: bool,
        dry_run: bool,
    },
    /// Contrôle de tous les textes par le rendu.
    I18nCheck,
    /// Aide.
    Help,
}

/// Aide affichée par `--help` ou en cas de commande inconnue.
pub const USAGE: &str = "\
Utilisation :
  lyxal-server                                   démarre le serveur
  lyxal-server admin setup --email <adresse>     lien d'installation du premier administrateur
  lyxal-server auth rotate-signing-key [--force] nouvelle clé de signature des jetons d'accès
  lyxal-server i18n export --locale <langue> --output <fichier> [--format json|xliff] [--namespace <clé>] [--tenant <organisation>]
                                                 exporte les textes d'une langue
  lyxal-server i18n import --locale <langue> --file <fichier> [--format json|xliff] [--tenant <organisation>] [--overwrite-reviewed] [--dry-run]
                                                 importe un fichier de textes
  lyxal-server i18n check                        liste les textes que le rendu refuse
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
        ["i18n", "check"] => Ok(Command::I18nCheck),
        ["i18n", "export", rest @ ..] => {
            let mut options = Options::read(
                rest,
                &[
                    "--locale",
                    "--output",
                    "--format",
                    "--namespace",
                    "--tenant",
                ],
                &[],
            )?;
            Ok(Command::I18nExport {
                locale: options.required("--locale")?,
                output: options.required("--output")?,
                format: options.format()?,
                namespace: options.value("--namespace"),
                tenant: options.value("--tenant"),
            })
        }
        ["i18n", "import", rest @ ..] => {
            let mut options = Options::read(
                rest,
                &["--locale", "--file", "--format", "--tenant"],
                &["--overwrite-reviewed", "--dry-run"],
            )?;
            Ok(Command::I18nImport {
                locale: options.required("--locale")?,
                file: options.required("--file")?,
                format: options.format()?,
                tenant: options.value("--tenant"),
                overwrite_reviewed: options.switch("--overwrite-reviewed"),
                dry_run: options.switch("--dry-run"),
            })
        }
        _ => Err(ServerError::Configuration {
            message: format!("commande inconnue\n{USAGE}"),
        }),
    }
}

fn usage_error(detail: &str) -> ServerError {
    ServerError::Configuration {
        message: format!("{detail}\n{USAGE}"),
    }
}

/// Options d'une commande : `--nom valeur` et interrupteurs `--nom`, dans un ordre libre.
struct Options {
    values: HashMap<String, String>,
    switches: HashSet<String>,
}

impl Options {
    fn read(words: &[&str], valued: &[&str], switches: &[&str]) -> Result<Self, ServerError> {
        let mut options = Self {
            values: HashMap::new(),
            switches: HashSet::new(),
        };
        let mut words = words.iter();
        while let Some(word) = words.next() {
            if valued.contains(word) {
                let value = words
                    .next()
                    .ok_or_else(|| usage_error(&format!("valeur absente pour {word}")))?;
                if options
                    .values
                    .insert((*word).to_string(), (*value).to_string())
                    .is_some()
                {
                    return Err(usage_error(&format!("option répétée : {word}")));
                }
            } else if switches.contains(word) {
                options.switches.insert((*word).to_string());
            } else {
                return Err(usage_error(&format!("option inconnue : {word}")));
            }
        }
        Ok(options)
    }

    fn value(&mut self, name: &str) -> Option<String> {
        self.values.remove(name)
    }

    fn required(&mut self, name: &str) -> Result<String, ServerError> {
        self.value(name)
            .ok_or_else(|| usage_error(&format!("option obligatoire : {name}")))
    }

    fn switch(&self, name: &str) -> bool {
        self.switches.contains(name)
    }

    fn format(&mut self) -> Result<FileFormat, ServerError> {
        match self.value("--format") {
            None => Ok(FileFormat::Json),
            Some(name) => FileFormat::parse(&name)
                .ok_or_else(|| usage_error(&format!("format inconnu : {name} (json ou xliff)"))),
        }
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
        Command::I18nExport {
            locale,
            output,
            format,
            namespace,
            tenant,
        } => {
            let exchange = exchange().await?;
            let mut file = std::fs::File::create(&output).map_err(|error| failed(&error))?;
            let options = ExportOptions {
                locale,
                namespace,
                tenant,
            };
            let count = exchange
                .export(&options, format, &mut file)
                .await
                .map_err(|error| failed(&error))?;
            println!("{count} clés exportées dans {output}.");
            Ok(())
        }
        Command::I18nImport {
            locale,
            file,
            format,
            tenant,
            overwrite_reviewed,
            dry_run,
        } => {
            let exchange = exchange().await?;
            let mut input = std::fs::File::open(&file).map_err(|error| failed(&error))?;
            let options = ImportOptions {
                locale,
                tenant,
                overwrite_reviewed,
                dry_run,
            };
            let report = exchange
                .import(&options, format, &mut input)
                .await
                .map_err(|error| failed(&error))?;
            print!("{}", import_summary(&report, dry_run));
            if report.has_failures() {
                return Err(ServerError::CommandFailed {
                    message: format!(
                        "{} textes invalides, {} enregistrements illisibles",
                        report.invalid.len(),
                        report.rejected.len()
                    ),
                });
            }
            Ok(())
        }
        Command::I18nCheck => {
            let report = exchange()
                .await?
                .check()
                .await
                .map_err(|error| failed(&error))?;
            print!("{}", check_summary(&report));
            if report.invalid.is_empty() {
                Ok(())
            } else {
                Err(ServerError::CommandFailed {
                    message: format!("{} textes invalides", report.invalid.len()),
                })
            }
        }
    }
}

/// Échange des textes sur la session système de l'hôte.
async fn exchange() -> Result<Exchange, ServerError> {
    let config = AppConfig::load()?;
    let client = database::connect_database(&config.database).await?;
    Ok(Exchange::new(I18nStore::new(client.as_ref().clone())))
}

fn failed(error: &dyn std::fmt::Display) -> ServerError {
    ServerError::CommandFailed {
        message: error.to_string(),
    }
}

/// Rapport d'un import, une ligne par entrée ignorée, invalide ou illisible.
fn import_summary(report: &ImportReport, dry_run: bool) -> String {
    let mut summary = String::new();
    if dry_run {
        summary.push_str("Essai : rien n'a été écrit.\n");
    }
    summary.push_str(&format!(
        "Créés : {} ; modifiés : {} ; inchangés : {} ; ignorés : {} ; invalides : {} ; illisibles : {}\n",
        report.created,
        report.updated,
        report.unchanged,
        report.skipped.len(),
        report.invalid.len(),
        report.rejected.len()
    ));
    for skipped in &report.skipped {
        summary.push_str(&format!("ignoré   {} : {}\n", skipped.key, skipped.reason));
    }
    for invalid in &report.invalid {
        let detail = match &invalid.error {
            Some(error) => format!("{} ({error})", error.code()),
            None => invalid
                .problems
                .iter()
                .map(|problem| match &problem.argument {
                    Some(argument) => format!("{} ({argument})", problem.code),
                    None => problem.code.clone(),
                })
                .collect::<Vec<_>>()
                .join(", "),
        };
        summary.push_str(&format!("invalide {} : {detail}\n", invalid.key));
    }
    for rejected in &report.rejected {
        let place = match (&rejected.key, rejected.line) {
            (Some(key), _) => key.clone(),
            (None, Some(line)) => format!("ligne {line}"),
            (None, None) => "fichier".to_string(),
        };
        summary.push_str(&format!("illisible {place} : {}\n", rejected.cause));
    }
    summary
}

/// Rapport du contrôle, une ligne par texte refusé.
fn check_summary(report: &CheckReport) -> String {
    let mut summary = format!(
        "{} textes vérifiés, {} invalides\n",
        report.checked,
        report.invalid.len()
    );
    for invalid in &report.invalid {
        summary.push_str(&format!(
            "invalide {} [{}, {}] : {} ({})\n",
            invalid.key,
            invalid.locale,
            invalid.tenant.as_deref().unwrap_or("installation"),
            invalid.error.code(),
            invalid.error
        ));
    }
    summary
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

    #[test]
    fn i18n_commands_are_parsed() {
        assert_eq!(
            parse(&args(&["i18n", "check"])).ok(),
            Some(Command::I18nCheck)
        );
        assert_eq!(
            parse(&args(&[
                "i18n", "export", "--output", "fr.json", "--locale", "fr"
            ]))
            .ok(),
            Some(Command::I18nExport {
                locale: "fr".into(),
                output: "fr.json".into(),
                format: FileFormat::Json,
                namespace: None,
                tenant: None,
            })
        );
        assert_eq!(
            parse(&args(&[
                "i18n",
                "export",
                "--locale",
                "en",
                "--output",
                "en.xlf",
                "--format",
                "xliff",
                "--namespace",
                "base",
                "--tenant",
                "auth_organization:alpha",
            ]))
            .ok(),
            Some(Command::I18nExport {
                locale: "en".into(),
                output: "en.xlf".into(),
                format: FileFormat::Xliff,
                namespace: Some("base".into()),
                tenant: Some("auth_organization:alpha".into()),
            })
        );
        assert_eq!(
            parse(&args(&[
                "i18n",
                "import",
                "--dry-run",
                "--locale",
                "en",
                "--file",
                "en.json",
                "--overwrite-reviewed",
            ]))
            .ok(),
            Some(Command::I18nImport {
                locale: "en".into(),
                file: "en.json".into(),
                format: FileFormat::Json,
                tenant: None,
                overwrite_reviewed: true,
                dry_run: true,
            })
        );
        for refused in [
            vec!["i18n"],
            vec!["i18n", "export", "--locale", "fr"],
            vec!["i18n", "export", "--locale", "fr", "--output"],
            vec![
                "i18n", "export", "--locale", "fr", "--locale", "en", "--output", "x",
            ],
            vec![
                "i18n", "export", "--locale", "fr", "--output", "x", "--format", "po",
            ],
            vec![
                "i18n",
                "export",
                "--locale",
                "fr",
                "--output",
                "x",
                "--dry-run",
            ],
            vec!["i18n", "import", "--locale", "fr"],
            vec!["i18n", "check", "--verbose"],
        ] {
            assert!(parse(&args(&refused)).is_err(), "{refused:?}");
        }
    }

    #[test]
    fn reports_list_each_failure() {
        use lyxal_i18n::{FormatError, InvalidEntry, InvalidText, RejectedRecord, SkippedEntry};
        let report = ImportReport {
            created: 2,
            updated: 1,
            unchanged: 3,
            skipped: vec![SkippedEntry {
                key: "base.inconnue".into(),
                reason: "key_not_found".into(),
            }],
            invalid: vec![InvalidEntry {
                key: "base.salut".into(),
                problems: Vec::new(),
                error: Some(FormatError::ArgumentMissing { name: "n".into() }),
            }],
            rejected: vec![RejectedRecord {
                line: Some(4),
                key: None,
                cause: "texte attendu".into(),
            }],
        };
        let summary = import_summary(&report, true);
        assert!(summary.starts_with("Essai : rien n'a été écrit.\nCréés : 2 ; modifiés : 1 ; inchangés : 3 ; ignorés : 1 ; invalides : 1 ; illisibles : 1\n"));
        assert!(summary.contains("ignoré   base.inconnue : key_not_found\n"));
        assert!(summary.contains("invalide base.salut : I18N_ARGUMENT_MISSING"));
        assert!(summary.contains("illisible ligne 4 : texte attendu\n"));
        let check = CheckReport {
            checked: 7,
            invalid: vec![InvalidText {
                key: "base.salut".into(),
                locale: "en".into(),
                tenant: None,
                error: FormatError::ArgumentMissing { name: "n".into() },
            }],
        };
        assert_eq!(
            check_summary(&check),
            "7 textes vérifiés, 1 invalides\ninvalide base.salut [en, installation] : I18N_ARGUMENT_MISSING (argument manquant : n)\n"
        );
    }
}

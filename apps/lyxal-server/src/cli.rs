//! Commandes d'administration de l'hôte, exécutées sur une installation existante (serveur
//! démarré au moins une fois) puis terminées :
//!
//! * `lyxal-server admin setup --email <adresse>` : affiche une seule fois le lien d'installation
//!   du premier administrateur (valable 1 h ; refusé si un administrateur existe déjà) ;
//! * `lyxal-server auth rotate-signing-key [--force]` : active une nouvelle clé de signature des
//!   jetons d'accès dans l'emplacement inactif. Sans `--force`, refusé tant que des jetons signés
//!   par l'ancienne clé de cet emplacement peuvent être valides ; `--force` (clé compromise)
//!   l'écrase et invalide ces jetons ;
//! * `lyxal-server i18n export|import|check` : échange et contrôle des textes de `lyxal_i18n` ;
//! * `lyxal-server runtime migrations list [--module <module>]` : affiche les migrations
//!   interrompues ou abandonnées ;
//! * `lyxal-server runtime migrations resolve --module <module> --migration <id>
//!   --action retry|abandon --reason <texte>` : décision sur une migration interrompue.
//!
//! Les commandes `runtime migrations` s'exécutent **serveur arrêté** : une migration interrompue
//! empêche un serveur seul de démarrer, donc de servir les routes `/api/v1/system/migrations/*`.
//! Elles réinstallent le socle (rejouable), sans installer ni démarrer aucun module hébergé, puis
//! appellent `LyxalRuntime::interrupted_migrations` / `resolve_migration` : mêmes contrôles et
//! même trace au journal du runtime que les routes. Il n'y a pas d'appelant authentifié : l'auteur
//! tracé est `cli:<application.instance_id>`, et l'accès est celui de toutes ces commandes — qui
//! peut lancer le binaire avec la configuration du serveur et les identifiants de la base.
//!
//! Sans argument, le binaire démarre le serveur.

use crate::config::AppConfig;
use crate::crypto;
use crate::error::ServerError;
use crate::modules::auth::{self, AuthHost};
use lyxal_host::database;
use lyxal_i18n::{
    CheckReport, Exchange, ExportOptions, FileFormat, I18nStore, ImportOptions, ImportReport,
};
use lyxal_runtime::migration::{
    InterruptedMigration, MigrationInterruptedParams, MigrationResolveAction,
    MigrationResolveParams, MigrationResolved,
};
use lyxal_runtime::RuntimeError;
use std::collections::{HashMap, HashSet};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

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
    /// Liste des migrations interrompues ou abandonnées.
    MigrationsList { module: Option<String> },
    /// Décision sur une migration interrompue.
    MigrationsResolve {
        module: String,
        migration: String,
        action: MigrationResolveAction,
        reason: String,
    },
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
  lyxal-server runtime migrations list [--module <module>]
                                                 liste les migrations interrompues ou abandonnées (serveur arrêté)
  lyxal-server runtime migrations resolve --module <module> --migration <id> --action retry|abandon --reason <texte>
                                                 décide de rejouer ou d'abandonner une migration interrompue (serveur arrêté)
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
        ["runtime", "migrations", "list", rest @ ..] => {
            let mut options = Options::read(rest, &["--module"], &[])?;
            Ok(Command::MigrationsList {
                module: options.value("--module"),
            })
        }
        ["runtime", "migrations", "resolve", rest @ ..] => {
            let mut options = Options::read(
                rest,
                &["--module", "--migration", "--action", "--reason"],
                &[],
            )?;
            let action = options.required("--action")?;
            Ok(Command::MigrationsResolve {
                module: options.required("--module")?,
                migration: options.required("--migration")?,
                action: MigrationResolveAction::parse(&action).ok_or_else(|| {
                    usage_error(&format!("action inconnue : {action} (retry ou abandon)"))
                })?,
                reason: options.required("--reason")?,
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
        Command::MigrationsList { module } => {
            let config = AppConfig::load()?;
            let client = database::connect_database(&config.database).await?;
            print!("{}", migrations_list(&client, module).await?);
            Ok(())
        }
        Command::MigrationsResolve {
            module,
            migration,
            action,
            reason,
        } => {
            let config = AppConfig::load()?;
            let client = database::connect_database(&config.database).await?;
            let decision = MigrationResolveParams {
                module,
                migration,
                action,
                reason,
                actor: cli_actor(&config),
            };
            print!("{}", migrations_resolve(&client, decision).await?);
            Ok(())
        }
    }
}

/// Auteur tracé pour une décision prise en ligne de commande : il n'y a pas d'appelant
/// authentifié, l'auteur est donc la ligne de commande de cette instance
/// (`cli:<application.instance_id>`), jamais une personne. Le nœud et la date sont gardés à côté.
pub fn cli_actor(config: &AppConfig) -> String {
    match config.application.instance_id.trim() {
        "" => "cli".to_string(),
        instance => format!("cli:{instance}"),
    }
}

/// `runtime migrations list` : texte affiché, sur le runtime de reprise de `client`.
pub async fn migrations_list(
    client: &Surreal<Any>,
    module: Option<String>,
) -> Result<String, ServerError> {
    let migrations = crate::runtime::recovery(client)
        .await?
        .interrupted_migrations(MigrationInterruptedParams { module })
        .await
        .map_err(|error| runtime_refused(&error))?;
    Ok(migrations_summary(&migrations))
}

/// `runtime migrations resolve` : applique la décision (bail d'installation pris sans attendre,
/// trace au journal du runtime) et rend le texte affiché.
pub async fn migrations_resolve(
    client: &Surreal<Any>,
    decision: MigrationResolveParams,
) -> Result<String, ServerError> {
    let actor = decision.actor.clone();
    let resolved = crate::runtime::recovery(client)
        .await?
        .resolve_migration(decision)
        .await
        .map_err(|error| runtime_refused(&error))?;
    Ok(resolution_summary(&resolved, &actor))
}

/// Refus ou échec du runtime : son code `RUNTIME_*` puis son message.
fn runtime_refused(error: &RuntimeError) -> ServerError {
    ServerError::CommandFailed {
        message: format!("{} ({error})", error.info().code),
    }
}

/// Liste des migrations interrompues ou abandonnées, un bloc par migration.
fn migrations_summary(migrations: &[InterruptedMigration]) -> String {
    if migrations.is_empty() {
        return "Aucune migration interrompue ou abandonnée.\n".to_string();
    }
    let mut summary = format!(
        "Migrations interrompues ou abandonnées : {}\n",
        migrations.len()
    );
    for migration in migrations {
        let state = match migration.state.as_str() {
            "interrupted" => "interrompue",
            "abandoned" => "abandonnée",
            other => other,
        };
        summary.push_str(&format!(
            "- module {}, migration {}, version {}\n",
            migration.module, migration.migration, migration.version
        ));
        summary.push_str(&format!(
            "  script : {}\n  nœud : {}\n  état : {state}\n  début : {}\n",
            migration.script.as_deref().unwrap_or("inconnu"),
            migration.node.as_deref().unwrap_or("inconnu"),
            migration
                .started_at
                .as_ref()
                .map_or_else(|| "inconnu".to_string(), ToString::to_string),
        ));
        match &migration.resolution {
            None => summary.push_str("  dernière décision : aucune\n"),
            Some(resolution) => summary.push_str(&format!(
                "  dernière décision : {} par {} depuis le nœud {}, le {} — {}\n",
                resolution.action,
                resolution.actor,
                resolution.node_id,
                resolution.at,
                resolution.reason
            )),
        }
    }
    summary
}

/// Compte rendu d'une décision.
fn resolution_summary(resolved: &MigrationResolved, actor: &str) -> String {
    let effect = match resolved.status.as_str() {
        "RetryRequested" => "elle sera rejouée au prochain démarrage du serveur",
        "Abandoned" => {
            "elle est abandonnée ; l'installation du module reste refusée tant qu'une décision \
             retry ne l'a pas remise à rejouer"
        }
        other => other,
    };
    format!(
        "Migration {} du module {} (version {}) : {effect}.\n\
         État précédent : {} ; nouvel état : {}.\n\
         Décision tracée au journal du runtime (auteur {actor}, le {}).\n",
        resolved.migration,
        resolved.module,
        resolved.version,
        resolved.previous_status,
        resolved.status,
        resolved.resolved_at
    )
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
    fn runtime_migration_commands_are_parsed() {
        assert_eq!(
            parse(&args(&["runtime", "migrations", "list"])).ok(),
            Some(Command::MigrationsList { module: None })
        );
        assert_eq!(
            parse(&args(&[
                "runtime",
                "migrations",
                "list",
                "--module",
                "lyxal_auth"
            ]))
            .ok(),
            Some(Command::MigrationsList {
                module: Some("lyxal_auth".into())
            })
        );
        for (action, expected) in [
            ("retry", MigrationResolveAction::Retry),
            ("abandon", MigrationResolveAction::Abandon),
        ] {
            assert_eq!(
                parse(&args(&[
                    "runtime",
                    "migrations",
                    "resolve",
                    "--reason",
                    "base vérifiée",
                    "--action",
                    action,
                    "--migration",
                    "0001_initial",
                    "--module",
                    "lyxal_auth",
                ]))
                .ok(),
                Some(Command::MigrationsResolve {
                    module: "lyxal_auth".into(),
                    migration: "0001_initial".into(),
                    action: expected,
                    reason: "base vérifiée".into(),
                })
            );
        }
        let resolve = |rest: &[&str]| {
            let mut words = vec!["runtime", "migrations", "resolve"];
            words.extend_from_slice(rest);
            parse(&args(&words))
        };
        let complete = [
            ("--module", "lyxal_auth"),
            ("--migration", "0001_initial"),
            ("--action", "retry"),
            ("--reason", "x"),
        ];
        // Chaque option est obligatoire
        for missing in complete {
            let rest: Vec<&str> = complete
                .iter()
                .filter(|option| **option != missing)
                .flat_map(|(name, value)| [*name, *value])
                .collect();
            assert!(resolve(&rest).is_err(), "sans {}", missing.0);
        }
        for refused in [
            vec!["runtime"],
            vec!["runtime", "migrations"],
            vec!["runtime", "migrations", "list", "--module"],
            vec!["runtime", "migrations", "list", "--tous"],
            vec![
                "runtime",
                "migrations",
                "list",
                "--module",
                "a",
                "--module",
                "b",
            ],
            vec![
                "runtime",
                "migrations",
                "resolve",
                "--module",
                "lyxal_auth",
                "--migration",
                "0001_initial",
                "--action",
                "oublier",
                "--reason",
                "x",
            ],
            vec![
                "runtime",
                "migrations",
                "resolve",
                "--module",
                "lyxal_auth",
                "--migration",
                "0001_initial",
                "--action",
                "retry",
                "--reason",
                "x",
                "--actor",
                "auth_identity:autre",
            ],
        ] {
            assert!(parse(&args(&refused)).is_err(), "{refused:?}");
        }
    }

    #[test]
    fn migration_reports_are_readable() {
        use lyxal_runtime::migration::MigrationResolution;
        use lyxal_surreal::Datetime;
        let date = |text: &str| -> Datetime {
            match text.parse() {
                Ok(date) => date,
                Err(_) => panic!("date illisible : {text}"),
            }
        };
        assert_eq!(
            migrations_summary(&[]),
            "Aucune migration interrompue ou abandonnée.\n"
        );
        let listed = [
            InterruptedMigration {
                module: "lyxal_essai".into(),
                migration: "0001_initial".into(),
                version: "0.1.0".into(),
                script: Some("migrations/0001_initial.surql".into()),
                node: Some("node-arrete".into()),
                state: "interrupted".into(),
                started_at: Some(date("2026-01-02T03:04:05Z")),
                resolution: None,
            },
            InterruptedMigration {
                module: "lyxal_autre".into(),
                migration: "0001_initial".into(),
                version: "0.2.0".into(),
                script: None,
                node: None,
                state: "abandoned".into(),
                started_at: None,
                resolution: Some(MigrationResolution {
                    action: "abandon".into(),
                    actor: "cli:local".into(),
                    reason: "état partiel".into(),
                    node_id: "node-ops".into(),
                    at: date("2026-01-03T00:00:00Z"),
                }),
            },
        ];
        assert_eq!(
            migrations_summary(&listed),
            "Migrations interrompues ou abandonnées : 2\n\
             - module lyxal_essai, migration 0001_initial, version 0.1.0\n  \
             script : migrations/0001_initial.surql\n  nœud : node-arrete\n  \
             état : interrompue\n  début : 2026-01-02T03:04:05Z\n  \
             dernière décision : aucune\n\
             - module lyxal_autre, migration 0001_initial, version 0.2.0\n  \
             script : inconnu\n  nœud : inconnu\n  état : abandonnée\n  début : inconnu\n  \
             dernière décision : abandon par cli:local depuis le nœud node-ops, \
             le 2026-01-03T00:00:00Z — état partiel\n"
        );
        let resolved = MigrationResolved {
            module: "lyxal_essai".into(),
            migration: "0001_initial".into(),
            version: "0.1.0".into(),
            action: "retry".into(),
            status: "RetryRequested".into(),
            previous_status: "Applying".into(),
            resolved_at: date("2026-01-03T00:00:00Z"),
        };
        assert_eq!(
            resolution_summary(&resolved, "cli:local"),
            "Migration 0001_initial du module lyxal_essai (version 0.1.0) : elle sera rejouée \
             au prochain démarrage du serveur.\n\
             État précédent : Applying ; nouvel état : RetryRequested.\n\
             Décision tracée au journal du runtime (auteur cli:local, le 2026-01-03T00:00:00Z).\n"
        );
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

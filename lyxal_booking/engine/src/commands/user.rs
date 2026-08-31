use anyhow::{bail, Result};
use clap::Subcommand;
use colored::Colorize;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use std::path::Path;
use surrealdb::RecordId;
use tabled::{Table, Tabled};

use crate::auth;
use crate::db::SurrealBookingStore;
use crate::utils::{prompt, prompt_password};

#[derive(Debug, Subcommand)]
pub enum UserCommands {
    /// Create a new user account
    Create {
        /// User's email
        #[arg(long)]
        email: Option<String>,
        /// User's name
        #[arg(long)]
        name: Option<String>,
        /// Grant admin role
        #[arg(long)]
        admin: bool,
    },
    /// List all user accounts
    List,
    /// Disable a user account
    Disable {
        /// User email
        email: String,
    },
    /// Enable a user account
    Enable {
        /// User email
        email: String,
    },
    /// Promote a user account to admin
    Promote {
        /// User email
        email: String,
    },
    /// Demote an admin account to regular user
    Demote {
        /// User email
        email: String,
    },
    /// Set or reset a user account password
    SetPassword {
        /// User email
        email: String,
    },
    /// Permanently delete a user account and owned data
    Delete {
        /// User email
        email: String,
        /// Skip the interactive confirmation prompt
        #[arg(long, short = 'y')]
        yes: bool,
    },
}

#[derive(Debug, Serialize)]
struct CreateUserParams {
    email: String,
    name: String,
    password_hash: String,
    admin: bool,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct CreateUserResult {
    account_id: RecordId,
    email: String,
    name: String,
    role: String,
    first_account: bool,
}

#[derive(Debug, Deserialize, Tabled)]
struct UserRow {
    #[tabled(rename = "ID")]
    id: String,
    #[tabled(rename = "EMAIL")]
    email: String,
    #[tabled(rename = "NAME")]
    name: String,
    #[tabled(rename = "ROLE")]
    role: String,
    #[tabled(rename = "ENABLED")]
    enabled: bool,
    #[tabled(rename = "PROVIDER")]
    auth_provider: String,
}

#[derive(Debug, Serialize)]
struct UserEmailParams {
    email: String,
}

#[derive(Debug, Serialize)]
struct SetUserEnabledParams {
    email: String,
    enabled: bool,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct SetUserEnabledResult {
    account_id: RecordId,
    email: String,
    enabled: bool,
}

#[derive(Debug, Serialize)]
struct SetUserRoleParams {
    email: String,
    role: String,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct SetUserRoleResult {
    account_id: RecordId,
    email: String,
    role: String,
}

#[derive(Debug, Serialize)]
struct SetUserPasswordParams {
    email: String,
    password_hash: String,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct SetUserPasswordResult {
    account_id: RecordId,
    email: String,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct DeleteUserResult {
    deleted: bool,
    account_id: RecordId,
    email: String,
    avatar_path: Option<String>,
    deleted_sources: u32,
}

pub async fn run(store: &SurrealBookingStore, data_dir: &Path, cmd: UserCommands) -> Result<()> {
    match cmd {
        UserCommands::Create { email, name, admin } => {
            let email = match email {
                Some(e) => e,
                None => prompt("Email")?,
            };
            let email = email.trim().to_string();
            if email.is_empty() {
                bail!("Email cannot be empty");
            }

            let name = match name {
                Some(n) => n,
                None => prompt("Full Name")?,
            };
            let name = name.trim().to_string();
            if name.is_empty() {
                bail!("Name cannot be empty");
            }

            let password = prompt_password("Password")?;
            if password.as_str().len() < 12 {
                bail!("Password must be at least 12 characters");
            }
            let confirm = prompt_password("Confirm Password")?;
            if password.as_str() != confirm.as_str() {
                bail!("Passwords do not match");
            }

            let password_hash = auth::hash_password(password.as_str())?;

            let res: CreateUserResult = store
                .call_fn(
                    "booking_cli_create_user",
                    CreateUserParams {
                        email,
                        name,
                        password_hash,
                        admin,
                    },
                )
                .await?;

            if res.first_account {
                println!(
                    "{} First account created as Administrator: <{}>",
                    "✓".green(),
                    res.email
                );
            } else {
                println!(
                    "{} User account created [{}]: <{}>",
                    "✓".green(),
                    res.role,
                    res.email
                );
            }
        }
        UserCommands::List => {
            let users: Vec<UserRow> = store
                .call_fn("booking_cli_list_users", serde_json::json!({}))
                .await?;

            if users.is_empty() {
                println!("No users found.");
            } else {
                println!("{}", Table::new(users));
            }
        }
        UserCommands::Disable { email } => {
            let res: SetUserEnabledResult = store
                .call_fn(
                    "booking_cli_set_user_enabled",
                    SetUserEnabledParams {
                        email: email.clone(),
                        enabled: false,
                    },
                )
                .await?;

            println!("{} User disabled: {}", "✓".green(), res.email);
        }
        UserCommands::Enable { email } => {
            let res: SetUserEnabledResult = store
                .call_fn(
                    "booking_cli_set_user_enabled",
                    SetUserEnabledParams {
                        email: email.clone(),
                        enabled: true,
                    },
                )
                .await?;

            println!("{} User enabled: {}", "✓".green(), res.email);
        }
        UserCommands::Promote { email } => {
            let res: SetUserRoleResult = store
                .call_fn(
                    "booking_cli_set_user_role",
                    SetUserRoleParams {
                        email: email.clone(),
                        role: "admin".to_string(),
                    },
                )
                .await?;

            println!("{} User promoted to admin: {}", "✓".green(), res.email);
        }
        UserCommands::Demote { email } => {
            let res: SetUserRoleResult = store
                .call_fn(
                    "booking_cli_set_user_role",
                    SetUserRoleParams {
                        email: email.clone(),
                        role: "user".to_string(),
                    },
                )
                .await?;

            println!("{} Admin demoted to user: {}", "✓".green(), res.email);
        }
        UserCommands::SetPassword { email } => {
            let password = prompt_password("New Password")?;
            if password.as_str().len() < 12 {
                bail!("Password must be at least 12 characters");
            }

            let password_hash = auth::hash_password(password.as_str())?;

            let res: SetUserPasswordResult = store
                .call_fn(
                    "booking_cli_set_user_password",
                    SetUserPasswordParams {
                        email: email.clone(),
                        password_hash,
                    },
                )
                .await?;

            println!("{} Password updated for {}", "✓".green(), res.email);
        }
        UserCommands::Delete { email, yes } => {
            if !yes {
                println!("{} About to permanently delete user <{}>:", "⚠".yellow(), email);
                println!(
                    "{}",
                    "  This removes their user account, calendar sources, and owned data.".dimmed()
                );
                let confirm = prompt("Type 'delete' to confirm")?;
                if confirm.trim() != "delete" {
                    println!("{} Aborted.", "✗".red());
                    return Ok(());
                }
            }

            let res: DeleteUserResult = store
                .call_fn("booking_cli_delete_user", UserEmailParams { email: email.clone() })
                .await?;

            if !res.deleted {
                bail!("Failed to delete user <{}>", email);
            }

            // Path Traversal Security Protection
            if let Some(avatar_url) = res.avatar_path {
                let clean_avatar = avatar_url.trim().trim_start_matches('/').trim_start_matches('\\');
                if !clean_avatar.contains("..") && !clean_avatar.starts_with('/') && !clean_avatar.starts_with('\\') {
                    let avatar_file = data_dir.join(clean_avatar);
                    if let Ok(canonical) = avatar_file.canonicalize() {
                        if let Ok(data_canonical) = data_dir.canonicalize() {
                            if canonical.starts_with(data_canonical) && canonical.is_file() {
                                let _ = std::fs::remove_file(canonical);
                            }
                        }
                    }
                }
            }

            println!("{} User deleted: {}", "✓".green(), res.email);
        }
    }

    Ok(())
}

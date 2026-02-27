//! Lyxal CLI - 1:1 Logto CLI Parity
//! Providing command-line tools for managing Lyxal Identity.

use clap::{Parser, Subcommand};
use lyxal_api_client::{ManagementClient, ManagementClientConfig};

#[derive(Parser)]
#[command(name = "lyxal")]
#[command(about = "Lyxal Identity Command Line Interface", long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Manage users
    User {
        #[command(subcommand)]
        action: UserCommands,
    },
    /// Manage applications
    App {
        #[command(subcommand)]
        action: AppCommands,
    },
    /// Deploy or setup the system
    Deploy {
        #[arg(short, long)]
        config: Option<String>,
    },
}

#[derive(Subcommand)]
pub enum UserCommands {
    /// List all users
    List,
    /// Create a new user
    Create {
        #[arg(short, long)]
        username: String,
        #[arg(short, long)]
        email: String,
    },
}

#[derive(Subcommand)]
pub enum AppCommands {
    /// List all applications
    List,
}

pub async fn run_cli() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();
    
    // In a real scenario, these would come from env or config file
    let config = ManagementClientConfig {
        base_url: "http://localhost:3000".to_string(),
        client_id: "admin".to_string(),
        client_secret: "secret".to_string(),
        api_indicator: "https://api.lyxal.com".to_string(),
    };
    let client = ManagementClient::new(config);

    match &cli.command {
        Commands::User { action } => match action {
            UserCommands::List => {
                let users = client.get_users().await?;
                println!("{:#?}", users);
            },
            UserCommands::Create { username, email } => {
                println!("Creating user {} <{}>...", username, email);
                // logic here
            }
        },
        Commands::App { action } => match action {
            AppCommands::List => {
                let apps = client.get_applications().await?;
                println!("{:#?}", apps);
            }
        },
        Commands::Deploy { config: _ } => {
            println!("Starting deployment sequence...");
        }
    }

    Ok(())
}

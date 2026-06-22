use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "lyxal")]
#[command(about = "Lyxal Studio CLI", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Publier un projet
    Publish { build_id: String },
    /// Lancer le serveur de dÃ©veloppement
    Dev,
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();
    match &cli.command {
        Commands::Publish { build_id } => {
            println!("Publishing build {}", build_id);
            // Appel Ã  lyxal_project_build ici
        }
        Commands::Dev => {
            println!("Starting Lyxal Studio Dev Server...");
        }
    }
}


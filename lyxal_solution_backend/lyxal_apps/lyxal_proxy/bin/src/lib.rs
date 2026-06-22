#[macro_use]
extern crate lyxal_proxy_lib as lyxal_proxy;
#[macro_use]
extern crate lyxal_proxy_command_lib;

/// the arguments to the lyxal_proxy command line
pub mod cli;
/// Receives orders from the CLI, transmits to workers
// mod command;
pub mod command;
/// The command line logic
pub mod ctl;
/// Forking & restarting the main process using a more recent executable of Sōzu
mod upgrade;
/// Some unix helper functions
pub mod util;
/// Start and restart the worker UNIX processes
mod worker;

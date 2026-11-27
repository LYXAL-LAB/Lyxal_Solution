// SPDX-License-Identifier: AGPL-3.0-only

//! Syntaxe SMTP côté client (lot 6, plan §3.1) : lecture des réponses et de la réponse à
//! `EHLO`, écriture des commandes, bourrage du contenu de `DATA` en flux.
//!
//! Le module n'ouvre aucune connexion et ne décide de rien (choix des extensions utilisées,
//! classement des échecs, `PIPELINING`, `STARTTLS`) : tout cela appartient à
//! `lyxal_mail::outbound`. Déroulé type, côté client :
//!
//! 1. [`ReplyReader::ingest`] sur les octets reçus : accueil `220`, puis une réponse par
//!    commande, dans l'ordre (`PIPELINING` compris) ;
//! 2. [`ServerExtensions::from_ehlo`] sur la réponse à `EHLO` ;
//!    [`ReplyReader::set_enhanced_status_codes`] si `ENHANCEDSTATUSCODES` est annoncé ;
//! 3. [`ClientCommand::write_to`] pour chaque commande ;
//! 4. après la réponse `354` à `DATA`, [`DotStuffer::encode`] sur chaque morceau du contenu,
//!    puis [`DotStuffer::finish`].

mod command;
mod extensions;
mod reply;
mod stuffer;

pub use command::{ClientCommand, ClientCommandError, MailCommand, RcptCommand};
pub use extensions::{ServerExtensions, MAX_AUTH_MECHANISMS};
pub use reply::{ReplyError, ReplyReader, MAX_REPLY_LINES};
pub use stuffer::{DotStuffer, StuffError};

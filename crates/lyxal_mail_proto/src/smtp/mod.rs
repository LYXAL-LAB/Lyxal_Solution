// SPDX-License-Identifier: AGPL-3.0-only

//! Syntaxe SMTP (RFC 5321), côté serveur (lot 5, §4 de son plan) et côté client (lot 6, §3 de
//! son plan).
//!
//! **Côté serveur** : lecture des commandes et de leurs paramètres, découpage strict des
//! lignes, lecture de `DATA` et de `BDAT`, écriture des réponses et de la réponse à `EHLO`,
//! échange `AUTH PLAIN` / `AUTH LOGIN` ([`AuthExchange`]). Extensions lues : `PIPELINING`
//! (RFC 2920), `SIZE` (RFC 1870), `8BITMIME` (RFC 6152), `SMTPUTF8` (RFC 6531),
//! `ENHANCEDSTATUSCODES` (RFC 2034, codes de la RFC 3463), `STARTTLS` (RFC 3207), `CHUNKING`
//! (RFC 3030), `AUTH` (RFC 4954, paramètre `AUTH=` compris) ; paramètres DSN (RFC 3461) lus,
//! acceptés par la session seulement là où `DSN` est annoncé (dépôt authentifié, décision E22).
//! `REQUIRETLS` (RFC 8689) n'est ni annoncé ni accepté (`555 5.5.4`, décision E26).
//!
//! **Côté client** ([`client`]) : lecture des réponses d'un serveur distant, extensions de sa
//! réponse à `EHLO`, écriture des commandes, bourrage de `DATA` en flux.
//!
//! **Codages** ([`xtext`]) : `xtext` des paramètres DSN et adresses internationales de la
//! RFC 6533.
//!
//! Aucune décision n'est prise ici (état de la session, destinataires, politique, choix des
//! extensions employées) : tout cela appartient à `lyxal_mail`. Le module n'ouvre ni n'écoute
//! aucun port, n'utilise aucune cryptographie et ne garde aucune donnée hors des valeurs
//! rendues.
//!
//! Déroulé type, côté session :
//!
//! 1. [`CommandReceiver::ingest`] sur les octets reçus : une commande à la fois, le reste de
//!    l'entrée est gardé par l'appelant ;
//! 2. après `DATA` accepté (`354`), [`DataReceiver::ingest`] ; après `BDAT`,
//!    [`BdatReceiver::start_chunk`] puis [`BdatReceiver::ingest`] ; après `AUTH`,
//!    [`AuthExchange::start`], puis [`CommandReceiver::ingest_line`] et [`AuthExchange::step`] ;
//! 3. réponses par [`Response::write_to`], [`ehlo_response`], [`SmtpError::response`],
//!    [`AuthError::response`].
//!
//! Provenance : modèles Stalwart `smtp-proto` et Mox, code écrit pour Lyxal OS (voir
//! `SOURCES.md`).

mod address;
mod auth;
pub mod client;
mod command;
mod data;
mod error;
mod limits;
mod receiver;
mod response;
pub mod xtext;

pub use address::{
    Domain, ForwardPath, Mailbox, ReversePath, MAX_DOMAIN_BYTES, MAX_LABEL_BYTES,
    MAX_LOCAL_PART_BYTES, MAX_PATH_BYTES,
};
pub use auth::{
    AuthError, AuthExchange, AuthStep, Credentials, SaslData, SaslMechanism, MAX_MECHANISM_BYTES,
    MAX_SASL_ELEMENT_BYTES,
};
pub use command::{parse_command, Body, DsnNotify, DsnOrcpt, DsnRet, MailFrom, RcptTo, Request};
pub use data::{BdatReceiver, BdatStateError, DataOutcome, DataReceiver};
pub use error::SmtpError;
pub use limits::{
    LimitError, SmtpLimits, DEFAULT_LINE_BYTES, DEFAULT_MESSAGE_BYTES, MAX_LINE_BYTES,
    MAX_MESSAGE_BYTES, MIN_LINE_BYTES, MIN_MESSAGE_BYTES,
};
pub use receiver::{CommandReceiver, Ingested};
pub use response::{
    ehlo_response, helo_response, EnhancedStatus, Extensions, Response, ResponseError,
    MAX_REPLY_LINE_BYTES,
};

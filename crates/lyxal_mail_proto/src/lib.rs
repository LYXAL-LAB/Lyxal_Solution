// SPDX-License-Identifier: AGPL-3.0-only

//! Syntaxes du courrier de Lyxal OS (Noyau Technique, licence `AGPL-3.0-only`).
//!
//! Crate **Rust pur, sans base de données ni logique métier** : il lit les langages du courrier
//! et rend des types Lyxal, rien d'autre. Il n'écoute aucun port, n'ouvre aucune session, ne
//! touche pas à SurrealDB et ne décide d'aucune règle : tout cela appartient à `lyxal_mail`.
//!
//! **État : lot 6 du programme courrier.** Trois modules :
//!
//! * [`mime`] (lot 4) : lecture d'un message par la bibliothèque `mail-parser` et projection en
//!   types Lyxal (enveloppe, structure MIME avec positions, clés de fil, sujet de base), sous des
//!   limites d'imbrication, de parties et d'adresses ;
//! * [`smtp`] : syntaxe SMTP côté serveur (lot 5 : commandes, paramètres, découpage strict des
//!   lignes, `DATA` et `BDAT` avec refus des fins de ligne isolées, réponses et codes étendus ;
//!   lot 6 : `AUTH PLAIN` et `AUTH LOGIN`, paramètres DSN et `AUTH=`) et côté client (lot 6 :
//!   réponses, extensions de `EHLO`, commandes, bourrage de `DATA` en flux) ;
//! * [`dsn`] (lot 6) : écriture et lecture des avis de non-remise (RFC 3464, 6522, 6533).
//!
//! Les syntaxes IMAP, POP3, ManageSieve, Sieve, les rapports DMARC et TLS et les types JMAP
//! arrivent aux lots 7 à 12.
//!
//! Le crate ne chiffre rien et ne lit aucune clé ; ses types ne supposent jamais que le contenu
//! d'un message est lisible par le serveur au-delà de ce que l'appelant lui remet.
//!
//! Provenance : voir `SOURCES.md`.

#![forbid(unsafe_code)]
#![deny(missing_docs)]
#![deny(clippy::unwrap_used, clippy::expect_used, clippy::panic)]

pub mod dsn;
pub mod mime;
pub mod smtp;

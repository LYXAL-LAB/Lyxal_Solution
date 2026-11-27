// SPDX-License-Identifier: AGPL-3.0-only

//! Écriture des commandes du client SMTP (RFC 5321 §4.1 ; paramètres RFC 1870, 3461, 6152,
//! 6531 ; `AUTH PLAIN` RFC 4954, 4616).
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`smtpclient/client.go`, `DeliverMultiple` :
//! paramètres de `MAIL FROM` et `RCPT TO`) et de Stalwart `smtp-proto` (`request/mod.rs`,
//! écriture des commandes). Aucune valeur ne peut faire entrer un CR ou un LF dans le dialogue :
//! chemins et domaines sont des types déjà contrôlés ([`ReversePath`], [`ForwardPath`],
//! [`Domain`]), `ENVID` et `ORCPT` sont écrits en xtext, la réponse initiale de `AUTH PLAIN` en
//! Base64 ; toute valeur hors de sa grammaire est refusée ([`ClientCommandError`]).

use std::fmt;

use base64::engine::general_purpose::STANDARD;
use base64::Engine as _;
use zeroize::Zeroizing;

use super::super::address::{Domain, ForwardPath, ReversePath};
use super::super::command::{Body, DsnNotify, DsnOrcpt, DsnRet};
use super::super::xtext::encode_xtext;

/// Longueur maximale de `ENVID`, codé en xtext (RFC 3461 §4.4).
const MAX_ENVID_BYTES: usize = 100;
/// Longueur maximale de l'identifiant et du mot de passe de `AUTH PLAIN` (RFC 4616 §2).
const MAX_PLAIN_FIELD_BYTES: usize = 255;

/// Commande impossible à écrire. Aucune valeur n'y figure.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum ClientCommandError {
    /// Nom de `EHLO` / `HELO` mal formé ou non ASCII (la forme A-label est préparée par
    /// l'appelant).
    #[error("nom d'hôte invalide")]
    InvalidHost,
    /// Chemin non ASCII hors d'une transaction `SMTPUTF8` (RFC 6531 §3.4).
    #[error("adresse non ASCII sans SMTPUTF8")]
    Utf8WithoutSmtpUtf8,
    /// `ENVID` vide, avec un caractère hors de l'ASCII imprimable, ou plus long que 100
    /// caractères une fois codé.
    #[error("ENVID invalide")]
    InvalidEnvid,
    /// `ORCPT` hors de sa grammaire ([`DsnOrcpt::is_valid`]).
    #[error("ORCPT invalide")]
    InvalidOrcpt,
    /// `NOTIFY` vide, ou `NEVER` avec une autre valeur (RFC 3461 §4.1).
    #[error("NOTIFY invalide")]
    InvalidNotify,
    /// `BODY=BINARYMIME` exige `BDAT`, que le client n'emploie pas (décision E10).
    #[error("BODY=BINARYMIME non pris en charge")]
    UnsupportedBody,
    /// Identifiant ou mot de passe de `AUTH PLAIN` vide, trop long ou contenant un octet nul.
    #[error("identifiants AUTH PLAIN invalides")]
    InvalidCredentials,
}

/// `MAIL FROM` à écrire.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MailCommand {
    /// Chemin de retour.
    pub reverse_path: ReversePath,
    /// `SIZE=` (si le serveur annonce `SIZE`).
    pub size: Option<u64>,
    /// `BODY=` (`8BITMIME` si le serveur l'annonce et que le message a des octets 8 bits).
    pub body: Option<Body>,
    /// `SMTPUTF8` (le message ou l'enveloppe l'exigent et le serveur l'annonce).
    pub smtputf8: bool,
    /// `RET=` (si le serveur annonce `DSN`).
    pub ret: Option<DsnRet>,
    /// `ENVID=`, **décodé** (ASCII imprimable) ; écrit en xtext.
    pub envid: Option<String>,
}

/// `RCPT TO` à écrire.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RcptCommand {
    /// Chemin du destinataire.
    pub forward_path: ForwardPath,
    /// `NOTIFY=` (si le serveur annonce `DSN`).
    pub notify: Option<DsnNotify>,
    /// `ORCPT=`, relayé tel que reçu ou construit par [`DsnOrcpt::for_mailbox`].
    pub orcpt: Option<DsnOrcpt>,
    /// La transaction a été ouverte avec `SMTPUTF8` : un chemin non ASCII est permis.
    pub smtputf8: bool,
}

/// Commande du client. Le `Debug` masque le mot de passe de `AUTH PLAIN`.
#[derive(Clone, Copy)]
pub enum ClientCommand<'a> {
    /// `EHLO <domaine ou adresse littérale>`.
    Ehlo(&'a Domain),
    /// `HELO <domaine ou adresse littérale>` (repli après `500` / `502` à `EHLO`).
    Helo(&'a Domain),
    /// `STARTTLS`.
    StartTls,
    /// `AUTH PLAIN <réponse initiale>` (relais sortant seulement, sur une session chiffrée et
    /// vérifiée) ; `authzid` vide.
    AuthPlain {
        /// Identifiant.
        authcid: &'a str,
        /// Mot de passe.
        password: &'a [u8],
    },
    /// `MAIL FROM`.
    Mail(&'a MailCommand),
    /// `RCPT TO`.
    Rcpt(&'a RcptCommand),
    /// `DATA`.
    Data,
    /// `RSET`.
    Rset,
    /// `NOOP`.
    Noop,
    /// `QUIT`.
    Quit,
}

impl fmt::Debug for ClientCommand<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Ehlo(host) => f.debug_tuple("Ehlo").field(host).finish(),
            Self::Helo(host) => f.debug_tuple("Helo").field(host).finish(),
            Self::StartTls => f.write_str("StartTls"),
            Self::AuthPlain { authcid, .. } => f
                .debug_struct("AuthPlain")
                .field("authcid", authcid)
                .field("password", &"[REDACTED]")
                .finish(),
            Self::Mail(mail) => f.debug_tuple("Mail").field(mail).finish(),
            Self::Rcpt(rcpt) => f.debug_tuple("Rcpt").field(rcpt).finish(),
            Self::Data => f.write_str("Data"),
            Self::Rset => f.write_str("Rset"),
            Self::Noop => f.write_str("Noop"),
            Self::Quit => f.write_str("Quit"),
        }
    }
}

impl ClientCommand<'_> {
    /// Ajoute la commande et son CRLF à `out`. Rien n'est ajouté en cas d'erreur. Le tampon
    /// d'une commande `AUTH PLAIN` porte le mot de passe en Base64 : l'appelant l'efface
    /// (`zeroize::Zeroizing<Vec<u8>>`).
    pub fn write_to(&self, out: &mut Vec<u8>) -> Result<(), ClientCommandError> {
        let line = match self {
            ClientCommand::Ehlo(host) => hello("EHLO", host)?,
            ClientCommand::Helo(host) => hello("HELO", host)?,
            ClientCommand::StartTls => "STARTTLS".to_owned(),
            ClientCommand::AuthPlain { authcid, password } => {
                let line = auth_plain(authcid, password)?;
                out.extend_from_slice(line.as_bytes());
                out.extend_from_slice(b"\r\n");
                return Ok(());
            }
            ClientCommand::Mail(mail) => mail_line(mail)?,
            ClientCommand::Rcpt(rcpt) => rcpt_line(rcpt)?,
            ClientCommand::Data => "DATA".to_owned(),
            ClientCommand::Rset => "RSET".to_owned(),
            ClientCommand::Noop => "NOOP".to_owned(),
            ClientCommand::Quit => "QUIT".to_owned(),
        };
        out.extend_from_slice(line.as_bytes());
        out.extend_from_slice(b"\r\n");
        Ok(())
    }
}

fn hello(verb: &str, host: &Domain) -> Result<String, ClientCommandError> {
    // `Domain::Name` se construit librement : le nom est relu pour qu'aucun caractère hors de
    // la grammaire n'entre dans le dialogue.
    let rendered = host.to_string();
    if !host.is_ascii() || Domain::parse(&rendered).as_ref() != Some(host) {
        return Err(ClientCommandError::InvalidHost);
    }
    Ok(format!("{verb} {rendered}"))
}

fn auth_plain(authcid: &str, password: &[u8]) -> Result<Zeroizing<String>, ClientCommandError> {
    let valid = |field: &[u8]| {
        !field.is_empty() && field.len() <= MAX_PLAIN_FIELD_BYTES && !field.contains(&0)
    };
    if !valid(authcid.as_bytes()) || !valid(password) {
        return Err(ClientCommandError::InvalidCredentials);
    }
    let mut message = Zeroizing::new(Vec::with_capacity(2 + authcid.len() + password.len()));
    message.push(0);
    message.extend_from_slice(authcid.as_bytes());
    message.push(0);
    message.extend_from_slice(password);
    let mut line = Zeroizing::new(String::with_capacity(11 + message.len() / 3 * 4 + 4));
    line.push_str("AUTH PLAIN ");
    STANDARD.encode_string(message.as_slice(), &mut line);
    Ok(line)
}

fn mail_line(mail: &MailCommand) -> Result<String, ClientCommandError> {
    let path = match &mail.reverse_path {
        ReversePath::Null => String::new(),
        ReversePath::Mailbox(mailbox) => {
            if !mail.smtputf8 && !mailbox.is_ascii() {
                return Err(ClientCommandError::Utf8WithoutSmtpUtf8);
            }
            mailbox.to_string()
        }
    };
    let mut line = format!("MAIL FROM:<{path}>");
    if let Some(size) = mail.size {
        line.push_str(&format!(" SIZE={size}"));
    }
    match mail.body {
        None => {}
        Some(Body::SevenBit) => line.push_str(" BODY=7BIT"),
        Some(Body::EightBitMime) => line.push_str(" BODY=8BITMIME"),
        Some(Body::BinaryMime) => return Err(ClientCommandError::UnsupportedBody),
    }
    if mail.smtputf8 {
        line.push_str(" SMTPUTF8");
    }
    match mail.ret {
        None => {}
        Some(DsnRet::Full) => line.push_str(" RET=FULL"),
        Some(DsnRet::Headers) => line.push_str(" RET=HDRS"),
    }
    if let Some(envid) = &mail.envid {
        let printable = !envid.is_empty() && envid.bytes().all(|b| (b' '..=b'~').contains(&b));
        let encoded = encode_xtext(envid.as_bytes());
        if !printable || encoded.len() > MAX_ENVID_BYTES {
            return Err(ClientCommandError::InvalidEnvid);
        }
        line.push_str(" ENVID=");
        line.push_str(&encoded);
    }
    Ok(line)
}

fn rcpt_line(rcpt: &RcptCommand) -> Result<String, ClientCommandError> {
    let path = match &rcpt.forward_path {
        ForwardPath::Postmaster => "Postmaster".to_owned(),
        ForwardPath::Mailbox(mailbox) => {
            if !rcpt.smtputf8 && !mailbox.is_ascii() {
                return Err(ClientCommandError::Utf8WithoutSmtpUtf8);
            }
            mailbox.to_string()
        }
    };
    let mut line = format!("RCPT TO:<{path}>");
    if let Some(notify) = rcpt.notify {
        line.push_str(" NOTIFY=");
        line.push_str(&notify_value(notify)?);
    }
    if let Some(orcpt) = &rcpt.orcpt {
        // Hors d'une transaction `SMTPUTF8`, seule la forme ASCII est permise.
        if !orcpt.is_valid() || (!rcpt.smtputf8 && !orcpt.address.is_ascii()) {
            return Err(ClientCommandError::InvalidOrcpt);
        }
        line.push_str(&format!(" ORCPT={};{}", orcpt.address_type, orcpt.address));
    }
    Ok(line)
}

fn notify_value(notify: DsnNotify) -> Result<String, ClientCommandError> {
    let others = notify.success || notify.failure || notify.delay;
    if notify.never {
        return if others {
            Err(ClientCommandError::InvalidNotify)
        } else {
            Ok("NEVER".to_owned())
        };
    }
    let values: Vec<&str> = [
        (notify.success, "SUCCESS"),
        (notify.failure, "FAILURE"),
        (notify.delay, "DELAY"),
    ]
    .into_iter()
    .filter_map(|(set, name)| set.then_some(name))
    .collect();
    if values.is_empty() {
        return Err(ClientCommandError::InvalidNotify);
    }
    Ok(values.join(","))
}

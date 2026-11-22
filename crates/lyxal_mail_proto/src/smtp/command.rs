// SPDX-License-Identifier: AGPL-3.0-only

//! Commandes SMTP et leurs paramètres (RFC 5321 §4.1, RFC 1870, 3030, 3207, 3461, 6152, 6531).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart `smtp-proto` (`request/parser.rs` : jeu de
//! commandes, paramètres connus) et de Mox (`smtpserver/parse.go` : tolérances observées chez
//! les expéditeurs réels). La lecture porte sur une ligne complète, déjà débarrassée de son CRLF
//! et contrôlée par [`super::CommandReceiver`] (aucun CR, LF ni octet nul) : elle ne dépend
//! d'aucun état et ne lit jamais au-delà de la ligne.
//!
//! Tolérances (comme Mox hors mode pédant) : verbes et mots-clés sans égard à la casse ;
//! espaces et tabulations en fin de ligne ; espaces entre `FROM:` / `TO:` et le chemin ;
//! espaces répétées entre paramètres.

use super::address::{
    parse_domain_or_literal, parse_forward_path, parse_reverse_path, Domain, ForwardPath,
    ReversePath,
};
use super::error::SmtpError;

/// Nombre maximal de chiffres de `SIZE=` (RFC 1870 §5 : 20 chiffres au plus).
const MAX_SIZE_DIGITS: usize = 20;
/// Longueur maximale de `ENVID` (RFC 3461 §4.4 : 100 caractères).
const MAX_ENVID_BYTES: usize = 100;
/// Longueur maximale de l'adresse de `ORCPT`, codée en xtext (RFC 3461 §4.2 : 500 caractères
/// pour le paramètre entier).
const MAX_ORCPT_BYTES: usize = 500;

/// Commande lue.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Request {
    /// `EHLO <domaine ou adresse littérale>`.
    Ehlo {
        /// Nom annoncé par le client.
        host: Domain,
    },
    /// `HELO <domaine ou adresse littérale>`.
    Helo {
        /// Nom annoncé par le client.
        host: Domain,
    },
    /// `LHLO` (LMTP, RFC 2033) : reconnu, refusé au lot 5.
    Lhlo,
    /// `MAIL FROM:<chemin> [paramètres]`.
    Mail(MailFrom),
    /// `RCPT TO:<chemin> [paramètres]`.
    Rcpt(RcptTo),
    /// `DATA`.
    Data,
    /// `BDAT <taille> [LAST]` (RFC 3030).
    Bdat {
        /// Taille du morceau, en octets.
        size: u64,
        /// Dernier morceau du message.
        last: bool,
    },
    /// `RSET`.
    Rset,
    /// `NOOP [texte]` (texte ignoré).
    Noop,
    /// `QUIT`.
    Quit,
    /// `STARTTLS` (RFC 3207).
    StartTls,
    /// `VRFY <texte>` (texte ignoré : réponse `252` sans vérification, plan §7.1).
    Vrfy,
    /// `EXPN <texte>` (texte ignoré : refusé).
    Expn,
    /// `HELP [texte]` (texte ignoré).
    Help,
    /// `AUTH` (RFC 4954) : reconnu, refusé au lot 5 ; la réponse initiale n'est jamais gardée.
    Auth,
    /// `ETRN` (RFC 1985) : reconnu, refusé.
    Etrn,
    /// `ATRN` (RFC 2645) : reconnu, refusé.
    Atrn,
    /// `BURL` (RFC 4468) : reconnu, refusé.
    Burl,
}

impl Request {
    /// Verbe de la commande, en capitales.
    pub const fn name(&self) -> &'static str {
        match self {
            Request::Ehlo { .. } => "EHLO",
            Request::Helo { .. } => "HELO",
            Request::Lhlo => "LHLO",
            Request::Mail(_) => "MAIL",
            Request::Rcpt(_) => "RCPT",
            Request::Data => "DATA",
            Request::Bdat { .. } => "BDAT",
            Request::Rset => "RSET",
            Request::Noop => "NOOP",
            Request::Quit => "QUIT",
            Request::StartTls => "STARTTLS",
            Request::Vrfy => "VRFY",
            Request::Expn => "EXPN",
            Request::Help => "HELP",
            Request::Auth => "AUTH",
            Request::Etrn => "ETRN",
            Request::Atrn => "ATRN",
            Request::Burl => "BURL",
        }
    }

    /// Commande qui ne peut être que la dernière d'un groupe en `PIPELINING` : la session envoie
    /// toutes ses réponses en attente avant de lire la suite (RFC 2920 §3.1 : `EHLO`, `DATA`,
    /// `VRFY`, `EXPN`, `TURN`, `QUIT`, `NOOP` ; RFC 3207 §4.2 pour `STARTTLS` ; RFC 4954 §4
    /// pour `AUTH` ; `HELO` et `LHLO` comme `EHLO`).
    pub const fn ends_pipeline_group(&self) -> bool {
        matches!(
            self,
            Request::Ehlo { .. }
                | Request::Helo { .. }
                | Request::Lhlo
                | Request::Data
                | Request::Vrfy
                | Request::Expn
                | Request::Quit
                | Request::Noop
                | Request::StartTls
                | Request::Auth
        )
    }

    /// Commande après laquelle aucun octet ne doit déjà attendre : après `STARTTLS`, tout octet
    /// reçu en clair avant la négociation est une injection (RFC 3207 §4.2, CVE-2011-0411 ;
    /// fermeture, `NetError::PipelinedBeforeTls` du lot 3) ; après `DATA`, des données envoyées
    /// avant la réponse `354` sont interdites (RFC 2920 §3.1 ; `554 5.5.0`, plan §7.1).
    /// Ne vaut que si la commande est acceptée.
    pub const fn forbids_pipelined_input(&self) -> bool {
        matches!(self, Request::StartTls | Request::Data)
    }
}

/// Encodage du corps annoncé par `BODY=` (RFC 6152, RFC 3030).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Body {
    /// `BODY=7BIT`.
    SevenBit,
    /// `BODY=8BITMIME`.
    EightBitMime,
    /// `BODY=BINARYMIME` (non annoncé au lot 5 : la session le refuse).
    BinaryMime,
}

/// `RET=` de DSN (RFC 3461 §4.3).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum DsnRet {
    /// `RET=FULL`.
    Full,
    /// `RET=HDRS`.
    Headers,
}

/// `NOTIFY=` de DSN (RFC 3461 §4.1).
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Hash)]
pub struct DsnNotify {
    /// `NEVER` (exclusif des trois autres).
    pub never: bool,
    /// `SUCCESS`.
    pub success: bool,
    /// `FAILURE`.
    pub failure: bool,
    /// `DELAY`.
    pub delay: bool,
}

/// `ORCPT=` de DSN (RFC 3461 §4.2).
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct DsnOrcpt {
    /// Type d'adresse (`rfc822`, `utf-8`...), tel que reçu.
    pub address_type: String,
    /// Adresse d'origine, codée en xtext (RFC 3461 §4) ou en utf-8-addr-xtext (RFC 6533),
    /// telle que reçue (non décodée).
    pub address: String,
}

/// `MAIL FROM` lu.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MailFrom {
    /// Chemin de retour.
    pub reverse_path: ReversePath,
    /// Une route source précédait la boîte (lue, ignorée, signalée).
    pub source_route: bool,
    /// `SIZE=` (RFC 1870) : taille annoncée du message.
    pub size: Option<u64>,
    /// `BODY=` (RFC 6152).
    pub body: Option<Body>,
    /// `SMTPUTF8` (RFC 6531).
    pub smtputf8: bool,
    /// `RET=` (DSN, non annoncé au lot 5).
    pub dsn_ret: Option<DsnRet>,
    /// `ENVID=` (DSN, non annoncé au lot 5), xtext tel que reçu.
    pub dsn_envid: Option<String>,
}

impl MailFrom {
    /// Vrai si un paramètre de DSN (RFC 3461) est présent : refusé tant que `DSN` n'est pas
    /// annoncé (lot 6).
    pub const fn uses_dsn(&self) -> bool {
        self.dsn_ret.is_some() || self.dsn_envid.is_some()
    }
}

/// `RCPT TO` lu.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RcptTo {
    /// Chemin du destinataire. Une boîte non ASCII n'est permise que si la transaction a été
    /// ouverte avec `SMTPUTF8` : contrôle de la session (`ForwardPath::is_ascii`).
    pub forward_path: ForwardPath,
    /// Une route source précédait la boîte (lue, ignorée, signalée : relais refusé).
    pub source_route: bool,
    /// `NOTIFY=` (DSN, non annoncé au lot 5).
    pub dsn_notify: Option<DsnNotify>,
    /// `ORCPT=` (DSN, non annoncé au lot 5).
    pub dsn_orcpt: Option<DsnOrcpt>,
}

impl RcptTo {
    /// Vrai si un paramètre de DSN (RFC 3461) est présent.
    pub const fn uses_dsn(&self) -> bool {
        self.dsn_notify.is_some() || self.dsn_orcpt.is_some()
    }
}

/// Lit une ligne de commande complète, sans son CRLF final.
///
/// La ligne ne doit contenir ni CR, ni LF, ni octet nul : [`super::CommandReceiver`] le
/// garantit ; un tel octet est de toute façon refusé ici comme erreur de syntaxe.
pub fn parse_command(line: &[u8]) -> Result<Request, SmtpError> {
    let line = std::str::from_utf8(line).map_err(|_| SmtpError::InvalidUtf8)?;
    if line.contains(['\r', '\n', '\0']) {
        return Err(SmtpError::UnknownCommand);
    }
    let line = line.trim_end_matches([' ', '\t']);
    let (verb, args) = match line.find(' ') {
        Some(index) => (&line[..index], Some(&line[index + 1..])),
        None => (line, None),
    };
    if verb.len() > 8 || !verb.is_ascii() {
        return Err(SmtpError::UnknownCommand);
    }
    let mut upper = [0u8; 8];
    for (slot, byte) in upper.iter_mut().zip(verb.bytes()) {
        *slot = byte.to_ascii_uppercase();
    }
    match &upper[..verb.len()] {
        b"EHLO" => parse_hello(args, "EHLO", true).map(|host| Request::Ehlo { host }),
        b"HELO" => parse_hello(args, "HELO", false).map(|host| Request::Helo { host }),
        b"MAIL" => parse_mail(args).map(Request::Mail),
        b"RCPT" => parse_rcpt(args).map(Request::Rcpt),
        b"DATA" => no_args(args, "DATA", Request::Data),
        b"BDAT" => parse_bdat(args),
        b"RSET" => no_args(args, "RSET", Request::Rset),
        b"QUIT" => no_args(args, "QUIT", Request::Quit),
        b"STARTTLS" => no_args(args, "STARTTLS", Request::StartTls),
        b"NOOP" => Ok(Request::Noop),
        b"HELP" => Ok(Request::Help),
        b"VRFY" => required_args(args, "VRFY", Request::Vrfy),
        b"EXPN" => required_args(args, "EXPN", Request::Expn),
        b"LHLO" => Ok(Request::Lhlo),
        b"AUTH" => Ok(Request::Auth),
        b"ETRN" => Ok(Request::Etrn),
        b"ATRN" => Ok(Request::Atrn),
        b"BURL" => Ok(Request::Burl),
        _ => Err(SmtpError::UnknownCommand),
    }
}

fn no_args(args: Option<&str>, name: &'static str, request: Request) -> Result<Request, SmtpError> {
    match args {
        None => Ok(request),
        Some(args) if args.trim_matches([' ', '\t']).is_empty() => Ok(request),
        Some(_) => Err(SmtpError::Syntax(name)),
    }
}

fn required_args(
    args: Option<&str>,
    name: &'static str,
    request: Request,
) -> Result<Request, SmtpError> {
    match args {
        Some(args) if !args.trim_matches([' ', '\t']).is_empty() => Ok(request),
        _ => Err(SmtpError::Syntax(name)),
    }
}

/// `EHLO SP ( Domain / address-literal )` ; après une adresse littérale, un texte séparé par
/// une espace est toléré (RFC 5321 §4.1.4, comme Mox).
fn parse_hello(args: Option<&str>, name: &'static str, ehlo: bool) -> Result<Domain, SmtpError> {
    let args = args.ok_or(SmtpError::Syntax(name))?;
    let (host, rest) = parse_domain_or_literal(args).ok_or(SmtpError::Syntax(name))?;
    let trailing_allowed = host.is_address_literal() && ehlo && rest.starts_with(' ');
    if rest.is_empty() || trailing_allowed {
        Ok(host)
    } else {
        Err(SmtpError::Syntax(name))
    }
}

/// Partie `FROM:` / `TO:` suivie d'espaces tolérées.
fn strip_keyword<'a>(args: Option<&'a str>, keyword: &str) -> Option<&'a str> {
    let args = args?;
    let head = args.get(..keyword.len())?;
    if !head.eq_ignore_ascii_case(keyword) {
        return None;
    }
    Some(args[keyword.len()..].trim_start_matches(' '))
}

fn parse_mail(args: Option<&str>) -> Result<MailFrom, SmtpError> {
    let syntax = SmtpError::Syntax("MAIL");
    let path = strip_keyword(args, "FROM:").ok_or(syntax)?;
    if !path.starts_with('<') {
        return Err(syntax);
    }
    let parsed = parse_reverse_path(path).ok_or(SmtpError::InvalidSender)?;
    let mut mail = MailFrom {
        reverse_path: parsed.path,
        source_route: parsed.source_route,
        size: None,
        body: None,
        smtputf8: false,
        dsn_ret: None,
        dsn_envid: None,
    };
    for param in parameters(parsed.rest, "MAIL") {
        let (keyword, value) = param?;
        match keyword.to_ascii_uppercase().as_str() {
            "SIZE" => {
                let value = value.ok_or(SmtpError::InvalidParameter("SIZE"))?;
                let size = parse_number(value, MAX_SIZE_DIGITS)
                    .ok_or(SmtpError::InvalidParameter("SIZE"))?;
                set_once(&mut mail.size, size, "SIZE")?;
            }
            "BODY" => {
                let body = match value.map(str::to_ascii_uppercase).as_deref() {
                    Some("7BIT") => Body::SevenBit,
                    Some("8BITMIME") => Body::EightBitMime,
                    Some("BINARYMIME") => Body::BinaryMime,
                    _ => return Err(SmtpError::InvalidParameter("BODY")),
                };
                set_once(&mut mail.body, body, "BODY")?;
            }
            "SMTPUTF8" => {
                if value.is_some() {
                    return Err(SmtpError::InvalidParameter("SMTPUTF8"));
                }
                if mail.smtputf8 {
                    return Err(SmtpError::DuplicateParameter("SMTPUTF8"));
                }
                mail.smtputf8 = true;
            }
            "RET" => {
                let ret = match value.map(str::to_ascii_uppercase).as_deref() {
                    Some("FULL") => DsnRet::Full,
                    Some("HDRS") => DsnRet::Headers,
                    _ => return Err(SmtpError::InvalidParameter("RET")),
                };
                set_once(&mut mail.dsn_ret, ret, "RET")?;
            }
            "ENVID" => {
                let envid = value
                    .filter(|value| value.len() <= MAX_ENVID_BYTES && is_xtext(value))
                    .ok_or(SmtpError::InvalidParameter("ENVID"))?;
                set_once(&mut mail.dsn_envid, envid.to_owned(), "ENVID")?;
            }
            _ => return Err(SmtpError::UnsupportedParameter),
        }
    }
    if !mail.smtputf8 && !mail.reverse_path.is_ascii() {
        return Err(SmtpError::Utf8WithoutSmtpUtf8);
    }
    Ok(mail)
}

fn parse_rcpt(args: Option<&str>) -> Result<RcptTo, SmtpError> {
    let syntax = SmtpError::Syntax("RCPT");
    let path = strip_keyword(args, "TO:").ok_or(syntax)?;
    if !path.starts_with('<') {
        return Err(syntax);
    }
    let parsed = parse_forward_path(path).ok_or(SmtpError::InvalidRecipient)?;
    let mut rcpt = RcptTo {
        forward_path: parsed.path,
        source_route: parsed.source_route,
        dsn_notify: None,
        dsn_orcpt: None,
    };
    for param in parameters(parsed.rest, "RCPT") {
        let (keyword, value) = param?;
        match keyword.to_ascii_uppercase().as_str() {
            "NOTIFY" => {
                let notify = value
                    .and_then(parse_notify)
                    .ok_or(SmtpError::InvalidParameter("NOTIFY"))?;
                set_once(&mut rcpt.dsn_notify, notify, "NOTIFY")?;
            }
            "ORCPT" => {
                let orcpt = value
                    .and_then(parse_orcpt)
                    .ok_or(SmtpError::InvalidParameter("ORCPT"))?;
                set_once(&mut rcpt.dsn_orcpt, orcpt, "ORCPT")?;
            }
            _ => return Err(SmtpError::UnsupportedParameter),
        }
    }
    Ok(rcpt)
}

/// `BDAT SP chunk-size [ SP end-marker ]` (RFC 3030 §2).
fn parse_bdat(args: Option<&str>) -> Result<Request, SmtpError> {
    let syntax = SmtpError::Syntax("BDAT");
    let args = args.ok_or(syntax)?;
    let mut words = args.split(' ').filter(|word| !word.is_empty());
    let size = words
        .next()
        .and_then(|size| parse_number(size, MAX_SIZE_DIGITS))
        .ok_or(syntax)?;
    let last = match words.next() {
        None => false,
        Some(marker) if marker.eq_ignore_ascii_case("LAST") => true,
        Some(_) => return Err(syntax),
    };
    if words.next().is_some() {
        return Err(syntax);
    }
    Ok(Request::Bdat { size, last })
}

/// Paramètres `esmtp-param *(SP esmtp-param)` après le chemin (RFC 5321 §4.1.2) :
/// `esmtp-keyword = (ALPHA / DIGIT) *(ALPHA / DIGIT / "-")`,
/// `esmtp-value = 1*(%d33-60 / %d62-126 / UTF8-non-ascii)` (RFC 6531 §3.3).
fn parameters<'a>(
    rest: &'a str,
    name: &'static str,
) -> impl Iterator<Item = Result<(&'a str, Option<&'a str>), SmtpError>> + 'a {
    let leading_ok = rest.is_empty() || rest.starts_with(' ');
    let mut first = !leading_ok;
    rest.split(' ')
        .filter(|param| !param.is_empty())
        .map(move |param| {
            if first {
                first = false;
                return Err(SmtpError::Syntax(name));
            }
            let (keyword, value) = match param.split_once('=') {
                Some((keyword, value)) => (keyword, Some(value)),
                None => (param, None),
            };
            let keyword_ok = keyword
                .bytes()
                .next()
                .is_some_and(|b| b.is_ascii_alphanumeric())
                && keyword
                    .bytes()
                    .all(|b| b.is_ascii_alphanumeric() || b == b'-');
            let value_ok = value.is_none_or(|value| {
                !value.is_empty()
                    && value
                        .chars()
                        .all(|ch| ('!'..='~').contains(&ch) && ch != '=' || !ch.is_ascii())
            });
            if keyword_ok && value_ok {
                Ok((keyword, value))
            } else {
                Err(SmtpError::Syntax(name))
            }
        })
}

fn set_once<T>(slot: &mut Option<T>, value: T, name: &'static str) -> Result<(), SmtpError> {
    if slot.is_some() {
        return Err(SmtpError::DuplicateParameter(name));
    }
    *slot = Some(value);
    Ok(())
}

/// `1*DIGIT`, au plus `max_digits` chiffres, sans dépassement de `u64`.
fn parse_number(value: &str, max_digits: usize) -> Option<u64> {
    if value.is_empty() || value.len() > max_digits || !value.bytes().all(|b| b.is_ascii_digit()) {
        return None;
    }
    value.parse().ok()
}

/// `xtext = *( xchar / hexchar )` (RFC 3461 §4) ; `hexchar = "+" 2(%x30-39 / %x41-46)`.
fn is_xtext(value: &str) -> bool {
    let bytes = value.as_bytes();
    let mut index = 0;
    while index < bytes.len() {
        match bytes[index] {
            b'+' => {
                let hex = bytes.get(index + 1..index + 3);
                if !hex
                    .is_some_and(|hex| hex.iter().all(|b| matches!(b, b'0'..=b'9' | b'A'..=b'F')))
                {
                    return false;
                }
                index += 3;
            }
            b'!'..=b'~' if bytes[index] != b'=' => index += 1,
            _ => return false,
        }
    }
    true
}

/// `NOTIFY=NEVER` ou `NOTIFY=` liste de `SUCCESS`, `FAILURE`, `DELAY` (RFC 3461 §4.1).
fn parse_notify(value: &str) -> Option<DsnNotify> {
    let mut notify = DsnNotify::default();
    for item in value.split(',') {
        let flag = match item.to_ascii_uppercase().as_str() {
            "NEVER" => &mut notify.never,
            "SUCCESS" => &mut notify.success,
            "FAILURE" => &mut notify.failure,
            "DELAY" => &mut notify.delay,
            _ => return None,
        };
        if *flag {
            return None;
        }
        *flag = true;
    }
    if notify.never && (notify.success || notify.failure || notify.delay) {
        return None;
    }
    Some(notify)
}

/// `ORCPT=addr-type ";" xtext` (RFC 3461 §4.2 ; utf-8-addr-xtext, RFC 6533 §3).
fn parse_orcpt(value: &str) -> Option<DsnOrcpt> {
    if value.len() > MAX_ORCPT_BYTES {
        return None;
    }
    let (address_type, address) = value.split_once(';')?;
    let type_ok = !address_type.is_empty()
        && address_type
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b == b'-');
    let address_ok = !address.is_empty() && (is_xtext(address) || !address.is_ascii());
    (type_ok && address_ok).then(|| DsnOrcpt {
        address_type: address_type.to_owned(),
        address: address.to_owned(),
    })
}

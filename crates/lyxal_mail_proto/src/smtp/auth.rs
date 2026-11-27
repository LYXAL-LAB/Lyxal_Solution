// SPDX-License-Identifier: AGPL-3.0-only

//! `AUTH` côté serveur (RFC 4954) : mécanismes `PLAIN` (RFC 4616) et `LOGIN`
//! (`draft-murchison-sasl-login`, demandé par d'anciens logiciels Outlook).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`smtp-proto`, `request/parser.rs` :
//! commande `AUTH` et réponse initiale ; `smtp/src/inbound/auth.rs` : échange par mécanisme) et
//! de Mox (`smtpserver/server.go`, `cmdAuth` : réponse initiale `=`, annulation `*`). Le module
//! ne vérifie aucun mot de passe : il rend l'identifiant et le mot de passe lus, la vérification
//! appartient à `lyxal_mail` (mots de passe d'application de `lyxal_auth`).
//!
//! Déroulé côté session :
//!
//! 1. [`Request::Auth`](super::Request::Auth) lu par [`super::CommandReceiver::ingest`] ;
//! 2. [`AuthExchange::start`] avec le mécanisme et la réponse initiale ;
//! 3. tant qu'il rend [`AuthStep::Challenge`] : la session envoie le défi `334`, lit la ligne
//!    suivante par [`super::CommandReceiver::ingest_line`], puis [`AuthExchange::step`] ;
//! 4. [`AuthStep::Credentials`] : identifiant et mot de passe ; une [`AuthError`] donne la
//!    réponse par [`AuthError::response`] et termine l'échange.
//!
//! **Secrets** : la réponse initiale, chaque ligne de l'échange et le mot de passe sont gardés
//! dans des tampons effacés à leur libération ([`SaslData`], [`Credentials`]) et n'apparaissent
//! jamais dans un `Debug`.

use std::fmt;

use base64::alphabet;
use base64::engine::{DecodePaddingMode, GeneralPurpose, GeneralPurposeConfig};
use base64::Engine as _;
use zeroize::Zeroizing;

use super::response::{EnhancedStatus, Response};

/// Longueur maximale d'un élément Base64 de l'échange (réponse initiale ou ligne), en octets
/// encodés.
pub const MAX_SASL_ELEMENT_BYTES: usize = 1_024;

/// Longueur maximale d'un nom de mécanisme SASL (RFC 4422 §3.1 : 20 caractères).
pub const MAX_MECHANISM_BYTES: usize = 20;

/// Défi `LOGIN` « Username: » en Base64.
const LOGIN_USERNAME: &str = "VXNlcm5hbWU6";
/// Défi `LOGIN` « Password: » en Base64.
const LOGIN_PASSWORD: &str = "UGFzc3dvcmQ6";

/// Base64 standard, remplissage `=` facultatif à la lecture (logiciels réels).
const BASE64_LENIENT: GeneralPurpose = GeneralPurpose::new(
    &alphabet::STANDARD,
    GeneralPurposeConfig::new().with_decode_padding_mode(DecodePaddingMode::Indifferent),
);

/// Données SASL reçues (réponse initiale de `AUTH` ou ligne de l'échange), telles que reçues,
/// sans CRLF. Effacées à leur libération ; jamais affichées.
#[derive(Clone, PartialEq, Eq)]
pub struct SaslData(Zeroizing<Vec<u8>>);

impl SaslData {
    /// Données reçues.
    pub fn new(bytes: Vec<u8>) -> Self {
        Self(Zeroizing::new(bytes))
    }

    /// Octets reçus.
    pub fn as_bytes(&self) -> &[u8] {
        &self.0
    }

    /// Vrai pour `*` : le client annule l'échange (RFC 4954 §4).
    pub fn is_cancel(&self) -> bool {
        self.0.as_slice() == b"*"
    }
}

impl fmt::Debug for SaslData {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("SaslData([REDACTED])")
    }
}

/// Mécanisme pris en charge.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum SaslMechanism {
    /// `PLAIN` (RFC 4616).
    Plain,
    /// `LOGIN` (`draft-murchison-sasl-login`).
    Login,
}

impl SaslMechanism {
    /// Mécanisme nommé, sans égard à la casse ; `None` s'il n'est pas pris en charge.
    pub fn from_name(name: &str) -> Option<Self> {
        if name.eq_ignore_ascii_case("PLAIN") {
            Some(Self::Plain)
        } else if name.eq_ignore_ascii_case("LOGIN") {
            Some(Self::Login)
        } else {
            None
        }
    }

    /// Nom du mécanisme, en capitales.
    pub const fn name(&self) -> &'static str {
        match self {
            Self::Plain => "PLAIN",
            Self::Login => "LOGIN",
        }
    }
}

/// Identifiant et mot de passe lus. Le mot de passe est effacé à la libération et masqué dans
/// le `Debug`.
#[derive(Clone, PartialEq, Eq)]
pub struct Credentials {
    authcid: String,
    password: Zeroizing<Vec<u8>>,
}

impl Credentials {
    /// Identifiant d'authentification (`authcid`), UTF-8, tel que reçu.
    pub fn authcid(&self) -> &str {
        &self.authcid
    }

    /// Mot de passe, tel que reçu (octets).
    pub fn password(&self) -> &[u8] {
        &self.password
    }
}

impl fmt::Debug for Credentials {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Credentials")
            .field("authcid", &self.authcid)
            .field("password", &"[REDACTED]")
            .finish()
    }
}

/// Étape suivante de l'échange.
#[derive(Debug, PartialEq, Eq)]
pub enum AuthStep {
    /// Défi `334` à envoyer ; la ligne suivante du client est la réponse.
    Challenge(Response),
    /// Échange terminé : identifiant et mot de passe à vérifier.
    Credentials(Credentials),
}

/// Échange refusé. Aucune donnée du client n'y figure.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum AuthError {
    /// Mécanisme inconnu ou non pris en charge.
    #[error("mécanisme SASL non pris en charge")]
    UnsupportedMechanism,
    /// Le client a annulé l'échange (`*`).
    #[error("échange SASL annulé")]
    Cancelled,
    /// Élément Base64 plus long que [`MAX_SASL_ELEMENT_BYTES`].
    #[error("élément SASL trop long")]
    TooLong,
    /// Élément qui n'est pas du Base64 valide.
    #[error("Base64 invalide")]
    InvalidBase64,
    /// Contenu décodé mal formé (champs `PLAIN`, identifiant vide ou en UTF-8 invalide, mot de
    /// passe vide, réponse initiale vide).
    #[error("réponse SASL mal formée")]
    Malformed,
    /// `authzid` non vide et différent de `authcid` : aucune connexion « au nom de ».
    #[error("identité d'autorisation refusée")]
    AuthzidRefused,
    /// Échange déjà terminé.
    #[error("échange SASL terminé")]
    Finished,
}

impl AuthError {
    /// Réponse normalisée (RFC 4954 §4, §6), sans donnée du client.
    pub fn response(&self) -> Response {
        let (code, class, subject, detail, text) = match self {
            Self::UnsupportedMechanism => (504, 5, 5, 4, "Unrecognized authentication type"),
            Self::Cancelled => (501, 5, 0, 0, "Authentication cancelled"),
            Self::TooLong => (500, 5, 5, 6, "Authentication exchange line is too long"),
            Self::InvalidBase64 => (501, 5, 5, 2, "Cannot decode response"),
            Self::Malformed => (501, 5, 5, 2, "Malformed authentication response"),
            Self::AuthzidRefused => (535, 5, 7, 8, "Authentication credentials invalid"),
            Self::Finished => (503, 5, 5, 1, "Authentication already completed"),
        };
        Response::fixed(code, EnhancedStatus::known(class, subject, detail), text)
    }
}

#[derive(Debug)]
enum State {
    /// `PLAIN` sans réponse initiale : la réponse complète est attendue.
    Plain,
    /// `LOGIN` : identifiant attendu.
    LoginUsername,
    /// `LOGIN` : mot de passe attendu.
    LoginPassword { authcid: String },
    /// Terminé (succès ou refus).
    Done,
}

/// Échange `AUTH` d'une session.
#[derive(Debug)]
pub struct AuthExchange {
    state: State,
}

impl AuthExchange {
    /// Commence l'échange pour `mechanism` (nom tel que reçu) et la réponse initiale
    /// éventuelle (`=` : réponse vide).
    pub fn start(
        mechanism: &str,
        initial: Option<&SaslData>,
    ) -> Result<(Self, AuthStep), AuthError> {
        let mechanism =
            SaslMechanism::from_name(mechanism).ok_or(AuthError::UnsupportedMechanism)?;
        let mut exchange = Self {
            state: match mechanism {
                SaslMechanism::Plain => State::Plain,
                SaslMechanism::Login => State::LoginUsername,
            },
        };
        let step = match initial {
            Some(initial) => exchange.step(initial)?,
            None => exchange.challenge(),
        };
        Ok((exchange, step))
    }

    /// Traite une réponse du client (réponse initiale ou ligne lue après un défi).
    pub fn step(&mut self, response: &SaslData) -> Result<AuthStep, AuthError> {
        let state = std::mem::replace(&mut self.state, State::Done);
        if matches!(state, State::Done) {
            return Err(AuthError::Finished);
        }
        if response.is_cancel() {
            return Err(AuthError::Cancelled);
        }
        let decoded = decode(response.as_bytes())?;
        match state {
            State::Plain => parse_plain(&decoded).map(AuthStep::Credentials),
            State::LoginUsername => {
                let authcid = utf8_identity(&decoded)?;
                self.state = State::LoginPassword { authcid };
                Ok(self.challenge())
            }
            State::LoginPassword { authcid } => {
                if decoded.is_empty() {
                    return Err(AuthError::Malformed);
                }
                Ok(AuthStep::Credentials(Credentials {
                    authcid,
                    password: decoded,
                }))
            }
            State::Done => Err(AuthError::Finished),
        }
    }

    fn challenge(&self) -> AuthStep {
        let text = match self.state {
            State::LoginUsername => LOGIN_USERNAME,
            State::LoginPassword { .. } => LOGIN_PASSWORD,
            State::Plain | State::Done => "",
        };
        AuthStep::Challenge(Response::continuation(text))
    }
}

/// Décode un élément Base64 ; `=` seul est la réponse vide (RFC 4954 §4).
fn decode(encoded: &[u8]) -> Result<Zeroizing<Vec<u8>>, AuthError> {
    if encoded.len() > MAX_SASL_ELEMENT_BYTES {
        return Err(AuthError::TooLong);
    }
    if encoded == b"=" {
        return Ok(Zeroizing::new(Vec::new()));
    }
    let mut decoded = Zeroizing::new(Vec::with_capacity(encoded.len() / 4 * 3 + 3));
    BASE64_LENIENT
        .decode_vec(encoded, &mut decoded)
        .map_err(|_| AuthError::InvalidBase64)?;
    Ok(decoded)
}

/// `message = [authzid] UTF8NUL authcid UTF8NUL passwd` (RFC 4616 §2).
fn parse_plain(message: &[u8]) -> Result<Credentials, AuthError> {
    let mut fields = message.splitn(3, |&b| b == 0);
    let (Some(authzid), Some(authcid), Some(password)) =
        (fields.next(), fields.next(), fields.next())
    else {
        return Err(AuthError::Malformed);
    };
    if password.is_empty() || password.contains(&0) {
        return Err(AuthError::Malformed);
    }
    let authcid = utf8_identity(authcid)?;
    if !authzid.is_empty() {
        let authzid = std::str::from_utf8(authzid).map_err(|_| AuthError::Malformed)?;
        if authzid != authcid {
            return Err(AuthError::AuthzidRefused);
        }
    }
    Ok(Credentials {
        authcid,
        password: Zeroizing::new(password.to_vec()),
    })
}

/// Identifiant non vide, UTF-8 valide, sans octet nul ni caractère de commande, 255 octets au
/// plus (RFC 4616 §2).
fn utf8_identity(bytes: &[u8]) -> Result<String, AuthError> {
    let text = std::str::from_utf8(bytes).map_err(|_| AuthError::Malformed)?;
    if text.is_empty() || text.len() > 255 || text.chars().any(char::is_control) {
        return Err(AuthError::Malformed);
    }
    Ok(text.to_owned())
}

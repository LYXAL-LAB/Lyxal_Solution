// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture MIME d'un message (RFC 5322, RFC 2045 à 2049) par `mail-parser`, projetée en types
//! Lyxal : enveloppe, structure des parties avec leurs positions dans le message brut, clés de
//! fil et sujet de base (RFC 5256 §2.1).
//!
//! [`parse`] ne rejette presque rien : un message reçu se garde même mal formé. Il rend
//! [`MimeError`] seulement pour un message vide, sans aucun champ d'en-tête lisible, ou au-delà
//! des limites ([`MimeLimits`]). `lyxal_mail` traduit toute [`MimeError`] en
//! `MAIL_MESSAGE_MALFORMED`.
//!
//! Ce module ne garde ni corps, ni texte des pièces jointes, ni aperçu : seulement ce dont IMAP
//! (`ENVELOPE`, `BODYSTRUCTURE`) et JMAP ont besoin pour lister un message sans ouvrir son
//! fichier (décision M8 du lot 4).
//!
//! Mémoire : `mail-parser` 1.0 lit le message en place, sans décoder les corps ; seul le contenu
//! des messages joints encodés (trois niveaux au plus) est décodé pour être lu. La taille du
//! message est bornée par l'appelant (budget mémoire de `lyxal_mail`).

mod build;

use time::OffsetDateTime;

/// Limites appliquées à la lecture d'un message.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct MimeLimits {
    /// Profondeur maximale de la structure : 0 pour la partie racine, +1 pour chaque partie
    /// d'un `multipart` et pour la racine de chaque message joint.
    pub max_depth: u8,
    /// Nombre maximal de parties, messages joints compris.
    pub max_parts: u16,
    /// Nombre maximal d'adresses (`From`, `Sender`, `Reply-To`, `To`, `Cc`, `Bcc`, membres de
    /// groupes compris) dans le message et ses messages joints.
    pub max_addresses: u16,
}

impl Default for MimeLimits {
    /// 20 niveaux, 1 000 parties, 1 000 adresses (plan du lot 4, §13).
    fn default() -> Self {
        Self {
            max_depth: 20,
            max_parts: 1_000,
            max_addresses: 1_000,
        }
    }
}

/// Refus de lecture d'un message. Aucune donnée du message n'y figure.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
pub enum MimeError {
    /// Le message ne contient aucun octet.
    #[error("message vide")]
    Empty,
    /// Aucun champ d'en-tête lisible.
    #[error("message sans en-tête lisible")]
    NoHeader,
    /// Message de 4 Gio ou plus : au-delà des positions sur 32 bits de `mail-parser`.
    #[error("message de {size} octets, au-delà de {max}")]
    TooLarge {
        /// Taille du message.
        size: u64,
        /// Taille maximale.
        max: u64,
    },
    /// Structure plus profonde que [`MimeLimits::max_depth`].
    #[error("structure MIME au-delà de {max} niveaux")]
    TooDeep {
        /// Profondeur maximale appliquée.
        max: u8,
    },
    /// Plus de parties que [`MimeLimits::max_parts`].
    #[error("plus de {max} parties MIME")]
    TooManyParts {
        /// Nombre maximal appliqué.
        max: u16,
    },
    /// Plus d'adresses que [`MimeLimits::max_addresses`].
    #[error("plus de {max} adresses")]
    TooManyAddresses {
        /// Nombre maximal appliqué.
        max: u16,
    },
    /// Structure rendue par `mail-parser` incohérente (partie contenue lue avant son conteneur).
    #[error("structure MIME incohérente")]
    Inconsistent,
}

/// Message lu.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ParsedMessage {
    /// Enveloppe : date, sujet, adresses, `Message-ID`, `In-Reply-To`, `References`.
    pub envelope: Envelope,
    /// Arbre des parties : type, paramètres, disposition, nom, positions, tailles, lignes.
    pub structure: BodyPart,
    /// `Message-ID` et ancêtres normalisés, du plus proche au plus lointain.
    pub thread: ThreadKeys,
    /// Sujet de base (RFC 5256 §2.1), `None` si le message n'a pas de sujet ou s'il est vide
    /// une fois les préfixes de réponse et de transfert retirés.
    pub base_subject: Option<String>,
    /// Date du champ `Date`, `None` si elle est absente ou illisible.
    pub sent_at: Option<OffsetDateTime>,
    /// Vrai si le message porte au moins une pièce jointe (voir [`BodyPart::is_attachment`]).
    pub has_attachment: bool,
    /// Vrai si la partie racine est un `multipart/report` (avis de non-remise, rapport) : pas
    /// de rapprochement de fil par le sujet.
    pub is_report: bool,
}

/// Enveloppe d'un message (champs de sa partie racine ; dernier champ retenu quand un champ est
/// répété, comme `mail-parser`).
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Envelope {
    /// Valeur brute du champ `Date`, dépliée (pour `ENVELOPE` d'IMAP).
    pub date: Option<String>,
    /// Sujet, mots encodés (RFC 2047) décodés.
    pub subject: Option<String>,
    /// `From`.
    pub from: Vec<AddressEntry>,
    /// `Sender`.
    pub sender: Vec<AddressEntry>,
    /// `Reply-To`.
    pub reply_to: Vec<AddressEntry>,
    /// `To`.
    pub to: Vec<AddressEntry>,
    /// `Cc`.
    pub cc: Vec<AddressEntry>,
    /// `Bcc`.
    pub bcc: Vec<AddressEntry>,
    /// `Message-ID`, sans `<>`.
    pub message_id: Option<String>,
    /// Identifiants de `In-Reply-To`, sans `<>`, dans l'ordre du champ.
    pub in_reply_to: Vec<String>,
    /// Identifiants de `References`, sans `<>`, dans l'ordre du champ (du plus ancien au plus
    /// récent).
    pub references: Vec<String>,
}

/// Élément d'une liste d'adresses.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum AddressEntry {
    /// Adresse seule.
    Mailbox(MailAddress),
    /// Groupe nommé (RFC 5322 §3.4), éventuellement vide.
    Group {
        /// Nom du groupe.
        name: String,
        /// Membres du groupe.
        members: Vec<MailAddress>,
    },
}

/// Adresse lue d'un champ : nom affiché et adresse, chacun facultatif (message mal formé).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MailAddress {
    /// Nom affiché, mots encodés décodés.
    pub name: Option<String>,
    /// Adresse telle qu'écrite (casse gardée).
    pub address: Option<String>,
}

/// Clés de rapprochement d'un message avec son fil (décision M7).
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct ThreadKeys {
    /// `Message-ID` du message, sans `<>`.
    pub message_id: Option<String>,
    /// Ancêtres sans `<>`, sans doublon ni `Message-ID` du message lui-même, du plus proche au
    /// plus lointain : `In-Reply-To`, puis `References` lu de la fin vers le début.
    pub ancestors: Vec<String>,
}

/// Partie MIME.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct BodyPart {
    /// Type, en minuscules (`text`, `multipart`, `message`, `application`...). Sans champ
    /// `Content-Type` : `text`, ou `message` pour un enfant de `multipart/digest`.
    pub media_type: String,
    /// Sous-type, en minuscules. Sans champ : `plain`, ou `rfc822` sous `multipart/digest`.
    /// Champ sans sous-type : `mixed` pour un `multipart`, `plain` pour `text`,
    /// `octet-stream` sinon, et la partie est marquée [`BodyPart::malformed`].
    pub media_subtype: String,
    /// Paramètres du `Content-Type` (noms en minuscules, valeurs décodées, RFC 2231).
    pub parameters: Vec<Parameter>,
    /// Disposition (`inline`, `attachment`...), en minuscules.
    pub disposition: Option<String>,
    /// Paramètres de `Content-Disposition`.
    pub disposition_parameters: Vec<Parameter>,
    /// Nom de fichier : paramètre `filename` de la disposition, sinon `name` du type.
    pub file_name: Option<String>,
    /// `Content-ID`, sans `<>`.
    pub content_id: Option<String>,
    /// `Content-Description`.
    pub description: Option<String>,
    /// `Content-Language`.
    pub languages: Vec<String>,
    /// `Content-Location`.
    pub location: Option<String>,
    /// `Content-Transfer-Encoding` déclaré, en minuscules (`7bit`, `base64`...).
    pub transfer_encoding: Option<String>,
    /// Positions dans le message brut ; `None` pour les parties d'un message joint encodé, qui
    /// ne sont pas lisibles par plage dans le fichier.
    pub position: Option<PartPosition>,
    /// Taille du corps de la partie tel qu'il est transmis (encodé), en octets.
    pub size: u64,
    /// Nombre de lignes du corps transmis, pour les types `text` et `message/rfc822` ou
    /// `message/global` (comme `BODYSTRUCTURE` d'IMAP).
    pub lines: Option<u64>,
    /// Vrai si la partie est une pièce jointe : disposition `attachment`, message joint, ou nom
    /// de fichier sans disposition `inline`. Toujours faux dans un message joint.
    pub is_attachment: bool,
    /// Vrai si la partie a été lue avec une réparation (frontière absente ou trouvée en milieu
    /// de ligne, en-tête sans ligne vide, `multipart` non fermé, message joint encodé au-delà de
    /// trois niveaux, type incomplet) : sa structure est à prendre avec réserve.
    pub malformed: bool,
    /// Contenu structuré de la partie.
    pub body: PartBody,
}

/// Contenu structuré d'une partie.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum PartBody {
    /// Partie simple (texte, image, application...).
    Single,
    /// Parties d'un `multipart`, dans l'ordre du message. Une partie de type `multipart` porte
    /// toujours cette forme, vide si ses parties sont illisibles.
    Multipart(Vec<BodyPart>),
    /// Message joint lu (`message/rfc822`, `message/global`, enfant de `multipart/digest`).
    Message(Box<EmbeddedMessage>),
}

/// Message joint à un autre.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct EmbeddedMessage {
    /// Enveloppe du message joint.
    pub envelope: Envelope,
    /// Structure du message joint.
    pub structure: BodyPart,
}

/// Paramètre d'un champ MIME.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Parameter {
    /// Nom, en minuscules.
    pub name: String,
    /// Valeur.
    pub value: String,
}

/// Positions d'une partie dans le message brut, en octets depuis son début :
/// `header_offset <= body_offset <= end_offset <= taille du message`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct PartPosition {
    /// Début des champs d'en-tête de la partie.
    pub header_offset: u64,
    /// Début du corps de la partie.
    pub body_offset: u64,
    /// Fin du corps de la partie (exclue).
    pub end_offset: u64,
}

/// Lit un message brut sous les limites données.
///
/// # Errors
///
/// [`MimeError`] pour un message vide, sans en-tête lisible, ou au-delà des limites.
pub fn parse(raw: &[u8], limits: &MimeLimits) -> Result<ParsedMessage, MimeError> {
    build::parse(raw, limits)
}

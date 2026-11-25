// SPDX-License-Identifier: AGPL-3.0-only

//! Messages et fils (`fn::mail_message_*`, `fn::mail_thread_get`).

use lyxal_surreal::SurrealValue;

use super::reception::Reception;
use super::types::{MailDatetime, MailRecordId, MailValue};

/// Adresse d'une enveloppe : adresse seule, ou membre d'un groupe nommé (`group`) ; un groupe
/// vide n'a que son nom.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct EnvelopeAddress {
    /// Nom affiché.
    pub name: Option<String>,
    /// Adresse.
    pub address: Option<String>,
    /// Groupe (RFC 5322 §3.4).
    pub group: Option<String>,
}

/// Enveloppe d'un message (IMAP `ENVELOPE`, JMAP), en clair en base (décision M8).
#[derive(Debug, Clone, Default, PartialEq, SurrealValue)]
pub struct MessageEnvelope {
    /// Date de l'en-tête `Date`.
    pub date: Option<MailDatetime>,
    /// Sujet décodé.
    pub subject: Option<String>,
    /// `Message-ID`, sans chevrons.
    pub message_id: Option<String>,
    /// `In-Reply-To`, sans chevrons.
    pub in_reply_to: Option<Vec<String>>,
    /// `References`, sans chevrons, du plus ancien au plus récent.
    pub references: Option<Vec<String>>,
    /// `From`.
    pub from: Option<Vec<EnvelopeAddress>>,
    /// `Sender`.
    pub sender: Option<Vec<EnvelopeAddress>>,
    /// `Reply-To`.
    pub reply_to: Option<Vec<EnvelopeAddress>>,
    /// `To`.
    pub to: Option<Vec<EnvelopeAddress>>,
    /// `Cc`.
    pub cc: Option<Vec<EnvelopeAddress>>,
    /// `Bcc`.
    pub bcc: Option<Vec<EnvelopeAddress>>,
}

/// Message d'un dossier.
#[derive(Debug, Clone, SurrealValue)]
pub struct Message {
    /// Fiche (`mail_message:⟨<clé du dossier>_<10^10 + UID>⟩`).
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Compte.
    pub account: MailRecordId,
    /// Dossier.
    pub mailbox: MailRecordId,
    /// Contenu.
    pub content: MailRecordId,
    /// Protection du contenu (`platform` ; `openpgp`, `client` réservés).
    pub protection: String,
    /// Origine de la fiche : `delivery` (remise SMTP), `append`, `copy`, `move`, `import`.
    pub origin: String,
    /// Résultats des contrôles à la réception (message d'origine `delivery` seulement).
    pub reception: Option<Reception>,
    /// Empreinte de la clé de l'utilisateur (niveaux B et C ; rendue par `fn::mail_message_get`).
    pub key_fingerprint: Option<String>,
    /// Identifiant JMAP (`Email.id`), gardé par un déplacement.
    pub email_id: String,
    /// UID dans le dossier.
    pub uid: i64,
    /// `MODSEQ`.
    pub modseq: i64,
    /// Numéro de modification de l'inscription.
    pub create_modseq: i64,
    /// Fil (UUID v7), immuable.
    pub thread: String,
    /// Réponse inscrite sans ancêtre trouvé.
    pub thread_orphan: bool,
    /// Date interne.
    pub received_at: MailDatetime,
    /// Date de l'en-tête `Date`.
    pub sent_at: Option<MailDatetime>,
    /// Taille en clair, en octets.
    pub size: i64,
    /// `\Seen`.
    pub seen: bool,
    /// `\Answered`.
    pub answered: bool,
    /// `\Flagged`.
    pub flagged: bool,
    /// `\Deleted`.
    pub deleted: bool,
    /// `\Draft`.
    pub draft: bool,
    /// Mots-clés, en minuscules, triés.
    pub keywords: Vec<String>,
    /// `Message-ID`, sans chevrons.
    pub message_id: Option<String>,
    /// Sujet de base (RFC 5256 §2.1).
    pub base_subject: Option<String>,
    /// Le message porte au moins une pièce jointe.
    pub has_attachment: bool,
    /// Enveloppe (absente d'une page `summary`).
    pub envelope: Option<MessageEnvelope>,
    /// Structure MIME (absente d'une page `summary`).
    pub structure: Option<MailValue>,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Paramètres de `fn::mail_message_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MessageCreateParams {
    /// Contenu stocké, jamais inscrit (`mail_content:<clé>`).
    pub content: String,
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: String,
    /// Date interne.
    pub received_at: MailDatetime,
    /// Date de l'en-tête `Date`.
    pub sent_at: Option<MailDatetime>,
    /// `\Seen`.
    pub seen: bool,
    /// `\Answered`.
    pub answered: bool,
    /// `\Flagged`.
    pub flagged: bool,
    /// `\Deleted`.
    pub deleted: bool,
    /// `\Draft`.
    pub draft: bool,
    /// Mots-clés.
    pub keywords: Vec<String>,
    /// `Message-ID`, sans chevrons.
    pub message_id: Option<String>,
    /// `In-Reply-To`, sans chevrons.
    pub in_reply_to: Vec<String>,
    /// `References`, sans chevrons.
    pub references: Vec<String>,
    /// Sujet de base.
    pub base_subject: Option<String>,
    /// Avis de non-remise : pas de rapprochement de fil par le sujet.
    pub is_report: bool,
    /// Enveloppe.
    pub envelope: Option<MessageEnvelope>,
    /// Structure MIME.
    pub structure: Option<MailValue>,
    /// Le message porte au moins une pièce jointe.
    pub has_attachment: bool,
}

/// Paramètres de `fn::mail_message_get` et `fn::mail_content_open`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MessageRefParams {
    /// Message (`mail_message:<clé>`).
    pub message: String,
}

/// Curseur d'une page par date : date interne et identifiant du dernier message rendu.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MessageCursor {
    /// Date interne.
    pub received_at: MailDatetime,
    /// Message (`mail_message:<clé>`).
    pub id: String,
}

/// Paramètres de `fn::mail_message_list` : par date décroissante (`before`), ou par plage
/// d'UID (`uid_min`, `uid_max`).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MessageListParams {
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: String,
    /// Curseur d'une page par date.
    pub before: Option<MessageCursor>,
    /// Premier UID d'une page par UID.
    pub uid_min: Option<i64>,
    /// Dernier UID d'une page par UID.
    pub uid_max: Option<i64>,
    /// Messages au plus (50 par défaut, 1 000 au plus).
    pub limit: Option<i64>,
    /// `summary` (sans enveloppe ni structure, par défaut) ou `full`.
    pub fields: Option<String>,
}

/// Page suivante d'une liste de messages.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MessagePageNext {
    /// Curseur d'une page par date.
    pub before: Option<MessageCursor>,
    /// Premier UID de la page suivante par UID.
    pub uid_min: Option<i64>,
}

/// Résultat de `fn::mail_message_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MessagePage {
    /// Messages.
    pub items: Vec<Message>,
    /// Page suivante, absente à la fin.
    pub next: Option<MessagePageNext>,
}

/// Paramètres de `fn::mail_message_changes` : changements d'un compte ou d'un dossier.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MessageChangesParams {
    /// Compte (`mail_account:<clé>`).
    pub account: Option<String>,
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: Option<String>,
    /// Numéro de modification de départ.
    pub since: i64,
    /// Changements au plus (1 000 par défaut, 5 000 au plus).
    pub limit: Option<i64>,
}

/// Message créé ou modifié depuis un numéro de modification.
#[derive(Debug, Clone, SurrealValue)]
pub struct ChangedMessage {
    /// Message.
    pub id: MailRecordId,
    /// Dossier.
    pub mailbox: MailRecordId,
    /// UID.
    pub uid: i64,
    /// `MODSEQ`.
    pub modseq: i64,
    /// `\Seen`.
    pub seen: bool,
    /// `\Answered`.
    pub answered: bool,
    /// `\Flagged`.
    pub flagged: bool,
    /// `\Deleted`.
    pub deleted: bool,
    /// `\Draft`.
    pub draft: bool,
    /// Mots-clés.
    pub keywords: Vec<String>,
}

/// Effacement depuis un numéro de modification (pierre tombale).
#[derive(Debug, Clone, SurrealValue)]
pub struct RemovedEntry {
    /// `message` ou `mailbox`.
    pub kind: String,
    /// Dossier (clé en texte : il peut avoir disparu).
    pub mailbox: String,
    /// UID du message effacé.
    pub uid: Option<i64>,
    /// Objet détruit.
    pub object: String,
    /// Numéro de modification de l'effacement.
    pub modseq: i64,
}

/// Résultat de `fn::mail_message_changes`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MessageChanges {
    /// Messages créés ou modifiés.
    pub changed: Vec<ChangedMessage>,
    /// Effacements.
    pub removed: Vec<RemovedEntry>,
    /// Numéro jusqu'auquel la réponse est complète (`since` de l'appel suivant).
    pub highest_modseq: i64,
    /// D'autres changements suivent.
    pub more: bool,
}

/// Paramètres de `fn::mail_message_flags_set` (`add`, `remove` ou `replace`).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FlagsSetParams {
    /// Messages d'un même compte (500 au plus).
    pub messages: Vec<String>,
    /// Drapeaux et mots-clés ajoutés (`$seen`, `$answered`, `$flagged`, `$deleted`, `$draft`, libres).
    pub add: Option<Vec<String>>,
    /// Drapeaux et mots-clés retirés.
    pub remove: Option<Vec<String>>,
    /// Drapeaux et mots-clés remplaçant les actuels.
    pub replace: Option<Vec<String>>,
    /// `CONDSTORE` : seuls les messages inchangés depuis ce numéro sont modifiés.
    pub unchanged_since: Option<i64>,
}

/// Message modifié ou effacé : identifiant, UID et numéro de modification.
#[derive(Debug, Clone, SurrealValue)]
pub struct MessageVersion {
    /// Message.
    pub id: MailRecordId,
    /// UID.
    pub uid: i64,
    /// Numéro de modification.
    pub modseq: i64,
}

/// Résultat de `fn::mail_message_flags_set`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FlagsSetResult {
    /// Messages modifiés.
    pub updated: Vec<MessageVersion>,
    /// Messages modifiés depuis `unchanged_since`, laissés tels quels.
    pub conflicts: Vec<MailRecordId>,
}

/// Paramètres de `fn::mail_message_move` et `fn::mail_message_copy`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TransferParams {
    /// Messages d'un même compte (500 au plus).
    pub messages: Vec<String>,
    /// Dossier cible (`mail_mailbox:<clé>`).
    pub mailbox: String,
}

/// Message déplacé.
#[derive(Debug, Clone, SurrealValue)]
pub struct MovedMessage {
    /// Nouvelle fiche, dans le dossier cible.
    pub id: MailRecordId,
    /// Ancienne fiche, retirée.
    pub from: MailRecordId,
    /// Ancien UID.
    pub from_uid: i64,
    /// Nouvel UID.
    pub uid: i64,
    /// Numéro de modification du déplacement.
    pub modseq: i64,
}

/// Résultat de `fn::mail_message_move`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MoveResult {
    /// Messages déplacés.
    pub moved: Vec<MovedMessage>,
}

/// Message copié.
#[derive(Debug, Clone, SurrealValue)]
pub struct CopiedMessage {
    /// Message source.
    pub source: MailRecordId,
    /// Copie.
    pub id: MailRecordId,
    /// UID de la copie.
    pub uid: i64,
}

/// Résultat de `fn::mail_message_copy`.
#[derive(Debug, Clone, SurrealValue)]
pub struct CopyResult {
    /// Copies.
    pub copied: Vec<CopiedMessage>,
}

/// Paramètres de `fn::mail_message_expunge`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ExpungeParams {
    /// Dossier (`mail_mailbox:<clé>`).
    pub mailbox: String,
    /// Messages à effacer (absent : les messages `\Deleted`, 500 par appel).
    pub messages: Option<Vec<String>>,
}

/// Résultat de `fn::mail_message_expunge`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ExpungeResult {
    /// Messages effacés.
    pub expunged: Vec<MessageVersion>,
    /// D'autres messages `\Deleted` restent.
    pub more: bool,
}

/// Paramètres de `fn::mail_thread_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ThreadGetParams {
    /// Fil (UUID v7).
    pub thread: String,
    /// Compte (absent : celui de la session).
    pub account: Option<String>,
}

/// Résultat de `fn::mail_thread_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ThreadMessages {
    /// Messages du fil, par date de réception.
    pub messages: Vec<MailRecordId>,
}

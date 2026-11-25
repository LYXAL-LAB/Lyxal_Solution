// SPDX-License-Identifier: AGPL-3.0-only

//! Contrats publics des fonctions SurrealQL `fn::mail_*` : paramètres (`XxxParams`) et
//! résultats. Les identifiants transmis sont des textes `table:clé` (règle `record` de
//! `lyxal_core`) ; un champ absent prend la valeur par défaut de la fonction.

mod account;
mod block;
mod content;
mod domain;
mod mailbox;
mod message;
mod reception;
mod settings;
mod types;

pub use account::{
    Account, AccountCreateParams, AccountCreated, AccountGetParams, AccountList, AccountListParams,
    AccountRefParams, AccountUpdateParams, Address, AddressCreateParams, AddressList,
    AddressListParams, AddressRefParams, AddressUpdateParams, Quota, QuotaResource,
};
pub use block::{
    ActiveBlocks, BlockActiveParams, BlockCreateParams, BlockDeleteParams, BlockListParams,
    BlockPage, BlockReason, NetworkBlock,
};
pub use content::{
    AccountPurgeStep, Content, ContentAttachParams, ContentBeginParams, ContentExpired,
    ContentLocation, ContentReservation, MaintenanceParams, TombstonesPurged,
};
pub use domain::{
    Deleted, Domain, DomainCreateParams, DomainList, DomainListParams, DomainRefParams,
    DomainUpdateParams,
};
pub use mailbox::{
    Mailbox, MailboxCreateParams, MailboxDeleteParams, MailboxDeleted, MailboxListParams,
    MailboxRefParams, MailboxUpdateParams,
};
pub use message::{
    ChangedMessage, CopiedMessage, CopyResult, EnvelopeAddress, ExpungeParams, ExpungeResult,
    FlagsSetParams, FlagsSetResult, Message, MessageChanges, MessageChangesParams,
    MessageCreateParams, MessageCursor, MessageEnvelope, MessageListParams, MessagePage,
    MessagePageNext, MessageRefParams, MessageVersion, MoveResult, MovedMessage, RemovedEntry,
    ThreadGetParams, ThreadMessages, TransferParams,
};
pub use reception::{
    DeliveriesPurged, DeliveryBeginParams, DeliveryCommitParams, DeliveryCommitResult,
    DeliveryItem, DeliveryItemError, DeliveryItemResult, DeliveryReservation, DeliveryRole,
    Reception, RecipientAccount, RecipientResolveParams, ResolvedRecipient,
};
pub use settings::{
    EffectiveSettings, SettingsGetParams, SettingsSetParams, SettingsView, StoredSettings,
};
pub use types::{MailDatetime, MailRecordId, MailValue};

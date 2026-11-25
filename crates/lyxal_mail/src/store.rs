// SPDX-License-Identifier: AGPL-3.0-only

//! Accès aux fonctions SurrealQL publiques de `lyxal_mail` : un appel typé d'une ligne par
//! fonction (`LyxalSurrealCall::call_fn`). Les règles restent dans SurrealQL ; la session
//! SurrealDB du client détermine l'appelant (titulaire d'une boîte, administrateur, compte de
//! service, ou session système de l'hôte).

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    Account, AccountCreateParams, AccountCreated, AccountGetParams, AccountList, AccountListParams,
    AccountPurgeStep, AccountRefParams, AccountUpdateParams, ActiveBlocks, Address,
    AddressCreateParams, AddressList, AddressListParams, AddressRefParams, AddressUpdateParams,
    BlockActiveParams, BlockCreateParams, BlockDeleteParams, BlockListParams, BlockPage, Content,
    ContentAttachParams, ContentBeginParams, ContentExpired, ContentLocation, ContentReservation,
    CopyResult, Deleted, DeliveriesPurged, DeliveryBeginParams, DeliveryCommitParams,
    DeliveryCommitResult, DeliveryReservation, Domain, DomainCreateParams, DomainList,
    DomainListParams, DomainRefParams, DomainUpdateParams, ExpungeParams, ExpungeResult,
    FlagsSetParams, FlagsSetResult, Mailbox, MailboxCreateParams, MailboxDeleteParams,
    MailboxDeleted, MailboxListParams, MailboxRefParams, MailboxUpdateParams, MaintenanceParams,
    Message, MessageChanges, MessageChangesParams, MessageCreateParams, MessageListParams,
    MessagePage, MessageRefParams, MoveResult, NetworkBlock, Quota, RecipientResolveParams,
    ResolvedRecipient, SettingsGetParams, SettingsSetParams, SettingsView, StoredSettings,
    ThreadGetParams, ThreadMessages, TombstonesPurged, TransferParams,
};

/// Store de `lyxal_mail` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct MailStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for MailStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

type Call<T> = Result<T, LyxalSurrealError>;

impl MailStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// `fn::mail_settings_get` : réglages d'une portée.
    pub async fn settings_get(&self, params: SettingsGetParams) -> Call<SettingsView> {
        self.call_fn("mail_settings_get", params).await
    }

    /// `fn::mail_settings_set` : réglages enregistrés.
    pub async fn settings_set(&self, params: SettingsSetParams) -> Call<StoredSettings> {
        self.call_fn("mail_settings_set", params).await
    }

    /// `fn::mail_domain_create` : domaine de courrier déclaré.
    pub async fn domain_create(&self, params: DomainCreateParams) -> Call<Domain> {
        self.call_fn("mail_domain_create", params).await
    }

    /// `fn::mail_domain_get` : domaine de courrier.
    pub async fn domain_get(&self, params: DomainRefParams) -> Call<Domain> {
        self.call_fn("mail_domain_get", params).await
    }

    /// `fn::mail_domain_list` : domaines d'une organisation.
    pub async fn domain_list(&self, params: DomainListParams) -> Call<DomainList> {
        self.call_fn("mail_domain_list", params).await
    }

    /// `fn::mail_domain_update` : domaine modifié.
    pub async fn domain_update(&self, params: DomainUpdateParams) -> Call<Domain> {
        self.call_fn("mail_domain_update", params).await
    }

    /// `fn::mail_domain_delete` : domaine vide supprimé.
    pub async fn domain_delete(&self, params: DomainRefParams) -> Call<Deleted> {
        self.call_fn("mail_domain_delete", params).await
    }

    /// `fn::mail_account_create` : compte, adresse principale et six dossiers.
    pub async fn account_create(&self, params: AccountCreateParams) -> Call<AccountCreated> {
        self.call_fn("mail_account_create", params).await
    }

    /// `fn::mail_account_get` : compte et quota effectif.
    pub async fn account_get(&self, params: AccountGetParams) -> Call<Account> {
        self.call_fn("mail_account_get", params).await
    }

    /// `fn::mail_account_list` : comptes d'une organisation.
    pub async fn account_list(&self, params: AccountListParams) -> Call<AccountList> {
        self.call_fn("mail_account_list", params).await
    }

    /// `fn::mail_account_update` : compte modifié.
    pub async fn account_update(&self, params: AccountUpdateParams) -> Call<Account> {
        self.call_fn("mail_account_update", params).await
    }

    /// `fn::mail_account_delete` : compte en suppression (purgé par la maintenance).
    pub async fn account_delete(&self, params: AccountRefParams) -> Call<Account> {
        self.call_fn("mail_account_delete", params).await
    }

    /// `fn::mail_quota_get` : quota d'un compte.
    pub async fn quota_get(&self, params: AccountGetParams) -> Call<Quota> {
        self.call_fn("mail_quota_get", params).await
    }

    /// `fn::mail_address_create` : adresse ou alias créé.
    pub async fn address_create(&self, params: AddressCreateParams) -> Call<Address> {
        self.call_fn("mail_address_create", params).await
    }

    /// `fn::mail_address_update` : adresse modifiée.
    pub async fn address_update(&self, params: AddressUpdateParams) -> Call<Address> {
        self.call_fn("mail_address_update", params).await
    }

    /// `fn::mail_address_delete` : adresse retirée.
    pub async fn address_delete(&self, params: AddressRefParams) -> Call<Deleted> {
        self.call_fn("mail_address_delete", params).await
    }

    /// `fn::mail_address_list` : adresses d'un domaine ou d'un compte.
    pub async fn address_list(&self, params: AddressListParams) -> Call<AddressList> {
        self.call_fn("mail_address_list", params).await
    }

    /// `fn::mail_recipient_resolve` : comptes qui reçoivent un destinataire (aucun relais).
    pub async fn recipient_resolve(
        &self,
        params: RecipientResolveParams,
    ) -> Call<ResolvedRecipient> {
        self.call_fn("mail_recipient_resolve", params).await
    }

    /// `fn::mail_delivery_begin` : remise ouverte (contenu réservé), ou message déjà remis.
    pub async fn delivery_begin(&self, params: DeliveryBeginParams) -> Call<DeliveryReservation> {
        self.call_fn("mail_delivery_begin", params).await
    }

    /// `fn::mail_delivery_commit` : lot de 1 à 32 messages inscrits dans un compte.
    pub async fn delivery_commit(
        &self,
        params: DeliveryCommitParams,
    ) -> Call<DeliveryCommitResult> {
        self.call_fn("mail_delivery_commit", params).await
    }

    /// `fn::mail_delivery_purge` : fiches d'idempotence échues retirées.
    pub async fn delivery_purge(&self, params: MaintenanceParams) -> Call<DeliveriesPurged> {
        self.call_fn("mail_delivery_purge", params).await
    }

    /// `fn::mail_block_create` : réseau bloqué (entrée manuelle ou bannissement automatique).
    pub async fn block_create(&self, params: BlockCreateParams) -> Call<NetworkBlock> {
        self.call_fn("mail_block_create", params).await
    }

    /// `fn::mail_block_list` : liste de blocage, par curseur.
    pub async fn block_list(&self, params: BlockListParams) -> Call<BlockPage> {
        self.call_fn("mail_block_list", params).await
    }

    /// `fn::mail_block_delete` : réseau retiré de la liste de blocage.
    pub async fn block_delete(&self, params: BlockDeleteParams) -> Call<Deleted> {
        self.call_fn("mail_block_delete", params).await
    }

    /// `fn::mail_block_active` : réseaux bloqués en vigueur.
    pub async fn block_active(&self, params: BlockActiveParams) -> Call<ActiveBlocks> {
        self.call_fn("mail_block_active", params).await
    }

    /// `fn::mail_mailbox_create` : dossier créé.
    pub async fn mailbox_create(&self, params: MailboxCreateParams) -> Call<Mailbox> {
        self.call_fn("mail_mailbox_create", params).await
    }

    /// `fn::mail_mailbox_get` : dossier et compteurs.
    pub async fn mailbox_get(&self, params: MailboxRefParams) -> Call<Mailbox> {
        self.call_fn("mail_mailbox_get", params).await
    }

    /// `fn::mail_mailbox_list` : dossiers d'un compte.
    pub async fn mailbox_list(&self, params: MailboxListParams) -> Call<Vec<Mailbox>> {
        self.call_fn("mail_mailbox_list", params).await
    }

    /// `fn::mail_mailbox_update` : dossier modifié (renommé, déplacé).
    pub async fn mailbox_update(&self, params: MailboxUpdateParams) -> Call<Mailbox> {
        self.call_fn("mail_mailbox_update", params).await
    }

    /// `fn::mail_mailbox_delete` : dossier supprimé.
    pub async fn mailbox_delete(&self, params: MailboxDeleteParams) -> Call<MailboxDeleted> {
        self.call_fn("mail_mailbox_delete", params).await
    }

    /// `fn::mail_message_create` : message inscrit.
    pub async fn message_create(&self, params: MessageCreateParams) -> Call<Message> {
        self.call_fn("mail_message_create", params).await
    }

    /// `fn::mail_message_get` : message.
    pub async fn message_get(&self, params: MessageRefParams) -> Call<Message> {
        self.call_fn("mail_message_get", params).await
    }

    /// `fn::mail_message_list` : page de messages d'un dossier.
    pub async fn message_list(&self, params: MessageListParams) -> Call<MessagePage> {
        self.call_fn("mail_message_list", params).await
    }

    /// `fn::mail_message_changes` : changements depuis un numéro de modification.
    pub async fn message_changes(&self, params: MessageChangesParams) -> Call<MessageChanges> {
        self.call_fn("mail_message_changes", params).await
    }

    /// `fn::mail_message_flags_set` : drapeaux et mots-clés changés.
    pub async fn message_flags_set(&self, params: FlagsSetParams) -> Call<FlagsSetResult> {
        self.call_fn("mail_message_flags_set", params).await
    }

    /// `fn::mail_message_move` : messages déplacés.
    pub async fn message_move(&self, params: TransferParams) -> Call<MoveResult> {
        self.call_fn("mail_message_move", params).await
    }

    /// `fn::mail_message_copy` : messages copiés.
    pub async fn message_copy(&self, params: TransferParams) -> Call<CopyResult> {
        self.call_fn("mail_message_copy", params).await
    }

    /// `fn::mail_message_expunge` : messages effacés définitivement.
    pub async fn message_expunge(&self, params: ExpungeParams) -> Call<ExpungeResult> {
        self.call_fn("mail_message_expunge", params).await
    }

    /// `fn::mail_thread_get` : messages d'un fil.
    pub async fn thread_get(&self, params: ThreadGetParams) -> Call<ThreadMessages> {
        self.call_fn("mail_thread_get", params).await
    }

    /// `fn::mail_content_begin` : contenu réservé avant l'écriture de son fichier.
    pub async fn content_begin(&self, params: ContentBeginParams) -> Call<ContentReservation> {
        self.call_fn("mail_content_begin", params).await
    }

    /// `fn::mail_content_attach` : contenu lié à son fichier écrit (session système).
    pub async fn content_attach(&self, params: ContentAttachParams) -> Call<Content> {
        self.call_fn("mail_content_attach", params).await
    }

    /// `fn::mail_content_open` : fichier à lire pour un message.
    pub async fn content_open(&self, params: MessageRefParams) -> Call<ContentLocation> {
        self.call_fn("mail_content_open", params).await
    }

    /// `fn::mail_content_expire` : contenus abandonnés et libérés retirés avec leur fichier.
    pub async fn content_expire(&self, params: MaintenanceParams) -> Call<ContentExpired> {
        self.call_fn("mail_content_expire", params).await
    }

    /// `fn::mail_tombstone_purge` : pierres tombales échues retirées.
    pub async fn tombstone_purge(&self, params: MaintenanceParams) -> Call<TombstonesPurged> {
        self.call_fn("mail_tombstone_purge", params).await
    }

    /// `fn::mail_account_purge_step` : une étape de la purge d'un compte en suppression.
    pub async fn account_purge_step(&self, params: MaintenanceParams) -> Call<AccountPurgeStep> {
        self.call_fn("mail_account_purge_step", params).await
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

//! Liste de blocage de l'installation (`fn::mail_block_*`) : réseaux refusés à l'acceptation.

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Motif d'un blocage.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum BlockReason {
    /// Entrée posée par l'administrateur de la plateforme.
    Manual,
    /// Bannissement automatique : trop d'erreurs dans les sessions.
    Errors,
    /// Bannissement automatique : recherche d'adresses.
    Harvest,
    /// Bannissement automatique : contrebande SMTP.
    Smuggling,
}

/// Paramètres de `fn::mail_block_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BlockCreateParams {
    /// Réseau (plage CIDR IPv4 ou IPv6).
    pub network: String,
    /// Motif (`manual` par défaut).
    pub reason: Option<BlockReason>,
    /// Fin du blocage ; absente : entrée manuelle sans fin, ou durée d'un bannissement
    /// automatique calculée par la fonction (1 h doublée à chaque récidive, 24 h au plus).
    pub expires_at: Option<MailDatetime>,
}

/// Réseau bloqué.
#[derive(Debug, Clone, SurrealValue)]
pub struct NetworkBlock {
    /// Fiche.
    pub id: MailRecordId,
    /// Réseau (plage CIDR, minuscules).
    pub network: String,
    /// Motif.
    pub reason: BlockReason,
    /// Nombre de bannissements du réseau, récidives comprises.
    pub strikes: i64,
    /// Fin du blocage ; absente : sans fin.
    pub expires_at: Option<MailDatetime>,
    /// Identité qui a posé une entrée manuelle.
    pub created_by: Option<MailRecordId>,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Paramètres de `fn::mail_block_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct BlockListParams {
    /// Curseur : dernier réseau de la page précédente.
    pub after: Option<String>,
    /// Entrées au plus (50 par défaut, 200 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_block_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BlockPage {
    /// Entrées, triées par réseau (entrées échues comprises).
    pub items: Vec<NetworkBlock>,
    /// Curseur de la page suivante, absent à la fin.
    pub next: Option<String>,
}

/// Paramètres de `fn::mail_block_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BlockDeleteParams {
    /// Réseau (plage CIDR).
    pub network: String,
}

/// Paramètres de `fn::mail_block_active`.
#[derive(Debug, Clone, Copy, Default, SurrealValue)]
pub struct BlockActiveParams {}

/// Résultat de `fn::mail_block_active`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ActiveBlocks {
    /// Réseaux bloqués en vigueur, triés.
    pub networks: Vec<String>,
}

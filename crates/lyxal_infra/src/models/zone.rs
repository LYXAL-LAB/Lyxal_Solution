//! Zones DNS (`fn::infra_zone_*` d'administration) et plan d'une zone.

use lyxal_surreal::SurrealValue;

use super::types::{ChangeAction, InfraDatetime, InfraRecordId};

/// Mode d'une zone.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ZoneMode {
    /// Plan calculé et montré, rien n'est écrit.
    Observe,
    /// Plan appliqué chez l'hébergeur.
    Managed,
}

/// État d'une zone.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ZoneState {
    /// Normal.
    Ok,
    /// Plan au-delà des seuils de prudence, en attente d'approbation.
    Blocked,
    /// Serveurs de noms de la zone parente différents de ceux de l'hébergeur.
    NotDelegated,
    /// Erreur définitive de l'hébergeur.
    Failing,
    /// Zone pas encore active chez l'hébergeur.
    PendingProvider,
}

/// Changement d'un plan (ajout, modification ou suppression chez l'hébergeur).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct PlannedChange {
    /// `Add`, `Set` ou `Delete`.
    pub action: ChangeAction,
    /// Enregistrement voulu à l'origine du changement.
    pub record: InfraRecordId,
    /// Identifiant chez le fournisseur (`Set`, `Delete`).
    pub provider_id: Option<String>,
    /// Nom complet.
    pub fqdn: String,
    /// Type (`A`, `MX`, `TXT`…).
    pub r#type: String,
    /// Valeur canonique.
    pub value: String,
    /// Durée de vie, en secondes.
    pub ttl: i64,
}

/// Conflit d'un plan : valeur humaine qui gêne un enregistrement voulu.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct PlannedConflict {
    /// Enregistrement voulu en conflit.
    pub record: InfraRecordId,
    /// `foreign_value`, `foreign_singleton`, `cname` ou `drift_modified`.
    pub reason: String,
    /// Valeurs observées en cause (5 au plus).
    pub observed: Vec<String>,
}

/// Dernier plan rangé dans une zone.
#[derive(Debug, Clone, SurrealValue)]
pub struct LastPlan {
    /// Empreinte SHA-256 (approbation).
    pub hash: String,
    /// Date du calcul.
    pub at: InfraDatetime,
    /// Changements.
    pub changes: Vec<PlannedChange>,
    /// Conflits.
    pub conflicts: Vec<PlannedConflict>,
    /// Nombre de suppressions.
    pub deletions: i64,
    /// Enregistrements de Lyxal observés dans la zone.
    pub owned: i64,
}

/// Dernière erreur d'une zone.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneError {
    /// Code `INFRA_*`.
    pub code: String,
    /// Date.
    pub at: InfraDatetime,
}

/// Nombre d'enregistrements voulus d'une zone par état.
#[derive(Debug, Clone, Default, PartialEq, Eq, SurrealValue)]
pub struct ZoneCounts {
    /// À écrire.
    pub pending: i64,
    /// Écrits, publication à vérifier.
    pub written: i64,
    /// Publiés.
    pub published: i64,
    /// En conflit.
    pub conflict: i64,
    /// Valeur humaine laissée.
    pub yielded: i64,
    /// En échec.
    pub failed: i64,
    /// À retirer.
    pub releasing: i64,
    /// Retirés.
    pub released: i64,
}

/// Zone rattachée, vue d'administration (sans jeton de réservation).
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneResult {
    /// Zone (clé opaque).
    pub id: InfraRecordId,
    /// Compte d'hébergeur.
    pub account: InfraRecordId,
    /// Nom de la zone.
    pub name: String,
    /// Nom chez le fournisseur.
    pub provider_ref: String,
    /// Mode.
    pub mode: ZoneMode,
    /// Organisations dont les déclarations sont acceptées.
    pub tenants: Vec<InfraRecordId>,
    /// État.
    pub state: ZoneState,
    /// Serveurs de noms observés.
    pub nameservers: Vec<String>,
    /// Rattachement vérifié chez la zone parente.
    pub delegated: Option<bool>,
    /// Dernier plan.
    pub last_plan: Option<LastPlan>,
    /// Empreinte du plan bloqué approuvé.
    pub approved_plan_hash: Option<String>,
    /// Passe demandée.
    pub reconcile_requested_at: Option<InfraDatetime>,
    /// Fin de la dernière passe réussie.
    pub reconciled_at: Option<InfraDatetime>,
    /// Prochaine passe périodique.
    pub next_reconcile_at: InfraDatetime,
    /// Dernière erreur.
    pub last_error: Option<ZoneError>,
    /// Rattachement.
    pub created_at: InfraDatetime,
    /// Dernière modification.
    pub updated_at: InfraDatetime,
    /// Enregistrements déjà déclarés rattachés (`_attach`, `_update`).
    pub adopted: Option<i64>,
    /// Passes mises en file (`_attach`, `_update`, `_plan_approve`).
    pub queued: Option<i64>,
    /// Enregistrements voulus par état (`_get`, `_list`).
    pub counts: Option<ZoneCounts>,
    /// Lignes observées chez le fournisseur (`_get`).
    pub observed: Option<i64>,
}

/// Paramètres de `fn::infra_zone_attach`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneAttachParams {
    /// Compte (`infra_account:<clé>`).
    pub account: String,
    /// Nom de la zone (visible du compte).
    pub name: String,
    /// Mode (`Observe` par défaut).
    pub mode: Option<ZoneMode>,
    /// Organisations acceptées (`auth_organization:<clé>`).
    pub tenants: Vec<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::infra_zone_update`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ZoneUpdateParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Nouveau mode.
    pub mode: Option<ZoneMode>,
    /// Organisations acceptées (remplacées en entier).
    pub tenants: Option<Vec<String>>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::infra_zone_detach`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneDetachParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Oublier les enregistrements écrits (ils restent chez le fournisseur).
    pub forget: bool,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_zone_detach`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneDetachResult {
    /// Zone détachée.
    pub detached: InfraRecordId,
    /// Enregistrements voulus redevenus `unmanaged`.
    pub records: i64,
    /// Enregistrements écrits laissés chez le fournisseur.
    pub kept_at_provider: i64,
}

/// Paramètres des fonctions qui visent une zone (`_get`, `_reconcile_request`).
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneRefParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

impl ZoneRefParams {
    /// Paramètres pour la zone `zone`.
    pub fn new(zone: impl Into<String>) -> Self {
        Self {
            zone: zone.into(),
            language: None,
        }
    }
}

/// Paramètres de `fn::infra_zone_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ZoneListParams {
    /// Filtre sur le compte.
    pub account: Option<String>,
    /// Filtre sur l'état.
    pub state: Option<ZoneState>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_zone_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneListResult {
    /// Zones, par nom.
    pub items: Vec<ZoneResult>,
}

/// Résultat de `fn::infra_zone_reconcile_request`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneReconcileRequested {
    /// Zone.
    pub zone: InfraRecordId,
    /// Date de la demande.
    pub requested_at: InfraDatetime,
    /// Passes mises en file (0 : reprise par `infra.tick`).
    pub queued: i64,
}

/// Paramètres de `fn::infra_zone_plan_approve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZonePlanApproveParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Empreinte exacte du plan montré.
    pub plan_hash: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::infra_zone_records` (photo de la zone).
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneRecordsParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// `lyxal` ou `human`.
    pub owner: Option<String>,
    /// Taille de page (1 000 au plus).
    pub limit: Option<i64>,
    /// Début de la page.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Ligne de la photo d'une zone chez le fournisseur.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneRecordRow {
    /// Ligne.
    pub id: InfraRecordId,
    /// Identifiant chez le fournisseur.
    pub provider_id: String,
    /// Nom complet.
    pub fqdn: String,
    /// Type.
    pub r#type: String,
    /// Valeur canonique.
    pub value: String,
    /// Durée de vie, en secondes.
    pub ttl: i64,
    /// Commentaire du fournisseur.
    pub comment: Option<String>,
    /// Enregistrement de Lyxal à qui la ligne appartient.
    pub record: Option<InfraRecordId>,
    /// Dernière écriture de la ligne.
    pub seen_at: InfraDatetime,
}

/// Résultat de `fn::infra_zone_records`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneRecordsResult {
    /// Lignes de la page.
    pub items: Vec<ZoneRecordRow>,
    /// Nombre total de lignes.
    pub total: i64,
}

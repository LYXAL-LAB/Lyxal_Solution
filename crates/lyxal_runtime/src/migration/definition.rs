use crate::error::RuntimeError;
use crate::migration::checksum::MigrationChecksum;
use crate::migration::id::MigrationId;
use crate::migration::status::MigrationStatus;
use crate::types::ModuleId;
use semver::Version;
use serde::{Deserialize, Serialize};
use std::cmp::Ordering;
use std::collections::HashSet;

/// Déclaration immuable d'une migration appartenant strictement à un module Lyxal OS.
///
/// L'ordre d'exécution est exclusivement déterminé par le champ `order: u64`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationDefinition {
    /// Identifiant unique et lisible de la migration (ex: "001_initial_schema").
    pub id: MigrationId,
    /// Module propriétaire de cette migration (garantit l'ownership strict).
    pub module_id: ModuleId,
    /// Version du module introduisant cette migration.
    pub module_version: Version,
    /// Somme de contrôle SHA-256 du contenu de la migration.
    pub checksum: MigrationChecksum,
    /// Ordre canonique numérique d'exécution séquentielle (1, 2, 3...).
    pub order: u64,
    /// Indique si la migration prévoit un mécanisme d'annulation (rollback).
    pub reversible: bool,
    /// Identifiant logique portable de la ressource (ex: "migrations/001_initial.surql").
    pub resource_path: Option<String>,
    /// Description optionnelle des changements apportés.
    pub description: Option<String>,
}

impl MigrationDefinition {
    /// Crée une nouvelle définition de migration avec les champs obligatoires.
    pub fn new(
        id: MigrationId,
        module_id: impl Into<ModuleId>,
        module_version: Version,
        checksum: MigrationChecksum,
        order: u64,
    ) -> Self {
        Self {
            id,
            module_id: module_id.into(),
            module_version,
            checksum,
            order,
            reversible: false,
            resource_path: None,
            description: None,
        }
    }

    /// Définit si la migration est réversible.
    pub fn with_reversible(mut self, reversible: bool) -> Self {
        self.reversible = reversible;
        self
    }

    /// Associe un chemin de ressource logique portable à la migration.
    pub fn with_resource_path(mut self, path: impl Into<String>) -> Self {
        self.resource_path = Some(path.into());
        self
    }

    /// Associe une description à la migration.
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = Some(description.into());
        self
    }
}

impl PartialOrd for MigrationDefinition {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for MigrationDefinition {
    fn cmp(&self, other: &Self) -> Ordering {
        self.order
            .cmp(&other.order)
            .then_with(|| self.id.cmp(&other.id))
    }
}

/// Valide qu'une liste de définitions de migrations d'un module ne contient aucun doublon d'ordre ni d'identifiant.
pub fn validate_migration_definitions(
    migrations: &[MigrationDefinition],
) -> Result<(), RuntimeError> {
    let mut seen_ids = HashSet::new();
    let mut seen_orders = HashSet::new();

    for m in migrations {
        if !seen_ids.insert(&m.id) {
            return Err(RuntimeError::InvalidMigrationId {
                id: m.id.to_string(),
                reason: format!(
                    "Duplicate migration ID '{}' in module '{}'",
                    m.id, m.module_id
                ),
            });
        }

        if !seen_orders.insert(m.order) {
            return Err(RuntimeError::InvalidMigrationId {
                id: m.id.to_string(),
                reason: format!(
                    "Duplicate migration order '{}' for migration '{}' in module '{}'",
                    m.order, m.id, m.module_id
                ),
            });
        }
    }

    Ok(())
}

/// Enregistrement représentant le résultat de l'application d'une migration (modèle pur).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationRecord {
    /// Identifiant de la migration.
    pub migration_id: MigrationId,
    /// Module propriétaire.
    pub module_id: ModuleId,
    /// Version du module au moment de l'application.
    pub module_version: String,
    /// Checksum vérifié.
    pub checksum: MigrationChecksum,
    /// Horodatage Unix (millisecondes) de l'application.
    pub applied_at: u64,
    /// Durée d'exécution en millisecondes.
    pub duration_ms: u64,
    /// Statut final de la migration.
    pub status: MigrationStatus,
    /// Message d'erreur éventuel en cas d'échec.
    pub error: Option<String>,
}

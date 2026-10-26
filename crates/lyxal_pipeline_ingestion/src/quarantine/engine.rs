//! Moteur de quarantaine, gestion des anomalies et requalification contrôlée.
//!
//! Garantit :
//! - L'idempotence absolue des enregistrements d'anomalies (clé de déduplication).
//! - La traçabilité de provenance (lot, fichier, ligne, raw_hash, payload brut).
//! - L'audit trail de requalification contrôlée réservée à `steward_admin`.

use std::collections::HashSet;
use std::sync::{Arc, RwLock};

use super::types::{
    AnomalyCategory, AnomalySeverity, QuarantineEntry, QuarantineStatus, QuarantineStats,
};
use crate::types::{ItemQualification, StateTransitionRecord};

/// Moteur de quarantaine en mémoire thread-safe et idempotent.
#[derive(Debug, Clone, Default)]
pub struct QuarantineEngine {
    entries: Arc<RwLock<Vec<QuarantineEntry>>>,
    dedup_index: Arc<RwLock<HashSet<String>>>,
}

impl QuarantineEngine {
    pub fn new() -> Self {
        Self {
            entries: Arc::new(RwLock::new(Vec::new())),
            dedup_index: Arc::new(RwLock::new(HashSet::new())),
        }
    }

    /// Clé d'idempotence unique pour une anomalie : hash(batch + line + raw_hash + code)
    fn compute_dedup_key(batch_id: &str, line_number: usize, raw_hash: &str, code: &str) -> String {
        format!("{batch_id}:{line_number}:{raw_hash}:{code}")
    }

    /// Journalise une anomalie en quarantaine de façon strictement idempotente.
    ///
    /// Retourne `true` si une nouvelle entrée a été créée, `false` si l'anomalie était déjà présente.
    pub fn log_anomaly(
        &self,
        batch_id: &str,
        line_number: usize,
        raw_hash: &str,
        manufacturer_ref: Option<&str>,
        manufacturer: Option<&str>,
        severity: AnomalySeverity,
        category: AnomalyCategory,
        code: &str,
        message: &str,
        field_name: Option<&str>,
        faulty_value: Option<&str>,
        raw_payload: serde_json::Value,
        resulting_qualification: ItemQualification,
    ) -> bool {
        let dedup_key = Self::compute_dedup_key(batch_id, line_number, raw_hash, code);

        {
            let index = self.dedup_index.read().unwrap();
            if index.contains(&dedup_key) {
                return false; // Déjà journalisé (idempotence)
            }
        }

        let entry_id = format!(
            "quarantine_{}",
            lyxal_crypto::blake3_hex(dedup_key.as_bytes())[..16].to_lowercase()
        );

        let entry = QuarantineEntry {
            entry_id,
            batch_id: batch_id.to_string(),
            line_number,
            raw_hash: raw_hash.to_string(),
            manufacturer_ref: manufacturer_ref.map(|s| s.to_string()),
            manufacturer: manufacturer.map(|s| s.to_string()),
            severity,
            category,
            code: code.to_string(),
            message: message.to_string(),
            field_name: field_name.map(|s| s.to_string()),
            faulty_value: faulty_value.map(|s| s.to_string()),
            raw_payload,
            status: QuarantineStatus::Quarantined,
            resulting_qualification,
            audit_trail: vec![StateTransitionRecord {
                from_statut: "INITIAL_INGESTION".to_string(),
                to_statut: "QUARANTINED".to_string(),
                transition_by: "system:ingestion_worker (ingestion_agent)".to_string(),
                transition_at: "2026-10-25T10:00:00Z".to_string(),
                reason: format!("Anomalie détectée : {message}"),
            }],
            created_at: "2026-10-25T10:00:00Z".to_string(),
        };

        {
            let mut entries = self.entries.write().unwrap();
            let mut index = self.dedup_index.write().unwrap();
            entries.push(entry);
            index.insert(dedup_key);
        }

        true
    }

    /// Requalification contrôlée d'une entrée de quarantaine par un Data Steward (`steward_admin`).
    pub fn requalify_entry(
        &self,
        entry_id: &str,
        new_qualification: ItemQualification,
        steward_identity: &str,
        steward_role: &str,
        justification: &str,
    ) -> Result<QuarantineEntry, String> {
        if steward_role != "steward_admin" {
            return Err("Seul un utilisateur avec le rôle 'steward_admin' est habilité à requalifier une anomalie".to_string());
        }

        if justification.trim().len() < 10 {
            return Err("Une justification formelle d'au moins 10 caractères est obligatoire pour requalifier une anomalie".to_string());
        }

        let mut entries = self.entries.write().unwrap();
        let entry = entries
            .iter_mut()
            .find(|e| e.entry_id == entry_id)
            .ok_or_else(|| format!("Entrée de quarantaine '{entry_id}' introuvable"))?;

        let old_qual = entry.resulting_qualification;
        entry.resulting_qualification = new_qualification;
        entry.status = QuarantineStatus::Requalified;

        entry.audit_trail.push(StateTransitionRecord {
            from_statut: format!("{old_qual:?}"),
            to_statut: format!("{new_qualification:?}"),
            transition_by: format!("{steward_identity} ({steward_role})"),
            transition_at: "2026-10-25T10:05:00Z".to_string(),
            reason: justification.to_string(),
        });

        Ok(entry.clone())
    }

    /// Récupère toutes les anomalies pour un lot d'ingestion donné
    pub fn list_by_batch(&self, batch_id: &str) -> Vec<QuarantineEntry> {
        let entries = self.entries.read().unwrap();
        entries
            .iter()
            .filter(|e| e.batch_id == batch_id)
            .cloned()
            .collect()
    }

    /// Calcule les statistiques d'anomalies pour un lot
    pub fn get_stats_for_batch(&self, batch_id: &str) -> QuarantineStats {
        let entries = self.entries.read().unwrap();
        let mut stats = QuarantineStats::default();

        for e in entries.iter().filter(|e| e.batch_id == batch_id) {
            stats.total_anomalies += 1;
            match e.severity {
                AnomalySeverity::Fatal => stats.fatal_count += 1,
                AnomalySeverity::Error => stats.error_count += 1,
                AnomalySeverity::Warning => stats.warning_count += 1,
                AnomalySeverity::Info => stats.info_count += 1,
            }
            if e.status == QuarantineStatus::Requalified {
                stats.requalified_count += 1;
            }
        }

        stats
    }

    /// Nombre total d'anomalies enregistrées
    pub fn len(&self) -> usize {
        self.entries.read().unwrap().len()
    }

    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_quarantine_idempotence() {
        let engine = QuarantineEngine::new();

        let inserted1 = engine.log_anomaly(
            "batch_01",
            10,
            "hash_10",
            Some("REF-10"),
            Some("PLACO"),
            AnomalySeverity::Error,
            AnomalyCategory::InvalidGtin,
            "INGESTION_GTIN_INVALID",
            "Clé GTIN erronée",
            Some("ean"),
            Some("3017620422009"),
            serde_json::json!({}),
            ItemQualification::Rejected,
        );
        assert!(inserted1);
        assert_eq!(engine.len(), 1);

        // Deuxième appel identique -> rejeté par idempotence
        let inserted2 = engine.log_anomaly(
            "batch_01",
            10,
            "hash_10",
            Some("REF-10"),
            Some("PLACO"),
            AnomalySeverity::Error,
            AnomalyCategory::InvalidGtin,
            "INGESTION_GTIN_INVALID",
            "Clé GTIN erronée",
            Some("ean"),
            Some("3017620422009"),
            serde_json::json!({}),
            ItemQualification::Rejected,
        );
        assert!(!inserted2);
        assert_eq!(engine.len(), 1);
    }

    #[test]
    fn test_steward_admin_requalification() {
        let engine = QuarantineEngine::new();
        engine.log_anomaly(
            "batch_01",
            5,
            "hash_5",
            Some("REF-5"),
            Some("PLACO"),
            AnomalySeverity::Warning,
            AnomalyCategory::MissingCommercialProof,
            "INGESTION_MISSING_PROOF",
            "Preuve tarifaire absente",
            None,
            None,
            serde_json::json!({}),
            ItemQualification::ToConfirm,
        );

        let entries = engine.list_by_batch("batch_01");
        assert_eq!(entries.len(), 1);
        let entry_id = &entries[0].entry_id;

        // Tentative de requalification par un rôle non autorisé -> Échec
        let res_denied = engine.requalify_entry(
            entry_id,
            ItemQualification::Verified,
            "agent_01",
            "qualification_agent",
            "Validation arbitraire non autorisée",
        );
        assert!(res_denied.is_err());

        // Requalification légitime par steward_admin
        let res_ok = engine.requalify_entry(
            entry_id,
            ItemQualification::Verified,
            "user:steward_lead",
            "steward_admin",
            "Preuve commerciale transmise par avenant fabricant validée par Data Steward",
        );
        assert!(res_ok.is_ok());

        let updated = res_ok.unwrap();
        assert_eq!(updated.status, QuarantineStatus::Requalified);
        assert_eq!(updated.resulting_qualification, ItemQualification::Verified);
        assert_eq!(updated.audit_trail.len(), 2);
    }
}

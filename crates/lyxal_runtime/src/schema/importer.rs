use crate::error::RuntimeError;
use crate::schema::plan::SchemaImportPlan;
use crate::types::ModuleId;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use std::time::Instant;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Résultat d'une opération d'importation de schéma.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SchemaImportResult {
    pub module_id: ModuleId,
    pub imported_resources: Vec<String>,
    pub skipped_empty_resources: Vec<String>,
    pub duration_ms: u64,
}

/// Moteur officiel d'importation des ressources de schéma SurrealQL d'un module.
///
/// Implémente `LyxalSurrealCall` et exécute les scripts de schéma dans l'ordre strict
/// en ignorant proprement les fichiers vides / commentaires.
pub struct SchemaImporter {
    client: Surreal<Any>,
}

impl SchemaImporter {
    /// Crée un nouvel importateur de schéma à partir d'un client `Surreal<Any>`.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Retourne la référence au client SurrealDB sous-jacent.
    pub fn client(&self) -> &Surreal<Any> {
        &self.client
    }

    /// Exécute un plan d'importation de schéma contre l'instance SurrealDB.
    pub async fn execute_plan(
        &self,
        plan: &SchemaImportPlan,
    ) -> Result<SchemaImportResult, RuntimeError> {
        let start = Instant::now();
        let mut imported = Vec::new();
        let mut skipped = Vec::new();

        for res in plan.resources() {
            if res.is_empty_or_whitespace() {
                skipped.push(res.logical_path.clone());
                continue;
            }

            let mut attempts = 0;
            loop {
                attempts += 1;
                let query_res = self.client.query(&res.content).await.map_err(|err| {
                    RuntimeError::SchemaImportFailed {
                        module: plan.module_id.clone(),
                        resource: res.logical_path.clone(),
                        message: format!("Failed to send query: {}", err),
                    }
                })?;

                match query_res.check() {
                    Ok(_) => break,
                    Err(err) => {
                        let err_str = err.to_string();
                        if attempts < 5
                            && (err_str.contains("conflict") || err_str.contains("retried"))
                        {
                            tokio::time::sleep(std::time::Duration::from_millis(25 * attempts))
                                .await;
                            continue;
                        }
                        return Err(RuntimeError::SchemaImportFailed {
                            module: plan.module_id.clone(),
                            resource: res.logical_path.clone(),
                            message: format!(
                                "SurrealDB error executing '{}': {}",
                                res.logical_path, err
                            ),
                        });
                    }
                }
            }

            imported.push(res.logical_path.clone());
        }

        let duration_ms = start.elapsed().as_millis() as u64;

        Ok(SchemaImportResult {
            module_id: plan.module_id.clone(),
            imported_resources: imported,
            skipped_empty_resources: skipped,
            duration_ms,
        })
    }

    /// Effectue une simulation (dry-run) de l'importation de schéma sans envoyer de requête SurrealQL.
    pub fn execute_plan_dry_run(&self, plan: &SchemaImportPlan) -> SchemaImportResult {
        let mut imported = Vec::new();
        let mut skipped = Vec::new();

        for res in plan.resources() {
            if res.is_empty_or_whitespace() {
                skipped.push(res.logical_path.clone());
            } else {
                imported.push(res.logical_path.clone());
            }
        }

        SchemaImportResult {
            module_id: plan.module_id.clone(),
            imported_resources: imported,
            skipped_empty_resources: skipped,
            duration_ms: 0,
        }
    }
}

impl LyxalSurrealCall for SchemaImporter {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

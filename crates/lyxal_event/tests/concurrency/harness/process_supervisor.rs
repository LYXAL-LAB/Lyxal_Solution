//! Superviseur du processus SurrealDB officiel (v3.2.0)
//! Gère le démarrage du serveur distant, la vérification de santé et les terminaisons brutales Windows.
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §2.1, §2.3

use std::process::{Child, Command};
use std::time::Duration;
use surrealdb::engine::any::connect;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub struct ProcessSupervisor {
    child_process: Option<Child>,
    endpoint: String,
    temp_dir: Option<tempfile::TempDir>,
}

impl ProcessSupervisor {
    pub fn new(endpoint: impl Into<String>) -> Self {
        Self {
            child_process: None,
            endpoint: endpoint.into(),
            temp_dir: None,
        }
    }

    pub fn endpoint(&self) -> &str {
        &self.endpoint
    }

    /// Tente de démarrer le binaire `surreal.exe 3.2.0` sous Windows si le binaire existe localement
    pub fn try_spawn_server(&mut self, binary_path: &str) -> Result<u32, std::io::Error> {
        let temp_dir = tempfile::tempdir()?;
        let db_path = format!("file:{}", temp_dir.path().display());

        let child = Command::new(binary_path)
            .args([
                "start",
                "--bind",
                "127.0.0.1:8000",
                "--user",
                "root",
                "--pass",
                "root",
                &db_path,
            ])
            .spawn()?;

        let pid = child.id();
        self.child_process = Some(child);
        self.temp_dir = Some(temp_dir);

        // Attente active que le serveur réponde
        std::thread::sleep(Duration::from_millis(500));
        Ok(pid)
    }

    /// Se connecte à l'instance de test isolée et configure le namespace et la base
    pub async fn connect_client(&self, ns: &str, db_name: &str) -> Result<Surreal<Any>, surrealdb::Error> {
        let db = connect(&self.endpoint).await?;
        if !self.endpoint.starts_with("mem://") {
            db.signin(surrealdb::opt::auth::Root {
                username: "root",
                password: "root",
            })
            .await?;
        }
        db.use_ns(ns).use_db(db_name).await?;
        Ok(db)
    }

    /// Exécute un crash brutal sous Windows via `taskkill /F /PID <pid>` (S-04)
    pub fn kill_process_by_pid(pid: u32) -> Result<(), std::io::Error> {
        #[cfg(target_os = "windows")]
        {
            let status = Command::new("taskkill")
                .args(["/F", "/PID", &pid.to_string()])
                .status()?;
            if status.success() {
                Ok(())
            } else {
                Err(std::io::Error::other(format!(
                    "taskkill failed with exit status {:?}",
                    status
                )))
            }
        }
        #[cfg(not(target_os = "windows"))]
        {
            let status = Command::new("kill")
                .args(["-9", &pid.to_string()])
                .status()?;
            if status.success() {
                Ok(())
            } else {
                Err(std::io::Error::new(
                    std::io::ErrorKind::Other,
                    "kill -9 failed",
                ))
            }
        }
    }
}

impl Drop for ProcessSupervisor {
    fn drop(&mut self) {
        if let Some(mut child) = self.child_process.take() {
            let _ = child.kill();
        }
    }
}


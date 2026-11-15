//! Forme texte d'un identifiant d'exécution (X1) : une exécution d'échéance a un identifiant
//! composé `scheduler_run:[planification, date]` qui ne passe pas tel quel dans une adresse. Les
//! routes de l'hôte l'acceptent et le rendent sous une forme unique : l'identifiant SurrealQL
//! complet encodé en base64url sans remplissage. Le décodage contrôle la chaîne en SurrealQL
//! (`fn::scheduler_run_ref` : règle `surql_record_string` du Core limitée à `scheduler_run`,
//! conversion, puis règle `record_id` limitée à `scheduler_run`) ; aucune autre forme n'est
//! acceptée.

use std::fmt;

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_surreal::ToSql;

use crate::error::{SchedulerError, SchedulerResult};
use crate::models::{RunRefTextParams, SchedulerRecordId};
use crate::store::SchedulerStore;

/// Forme texte d'un identifiant d'exécution (base64url sans remplissage de l'identifiant
/// SurrealQL complet).
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct RunRef(String);

impl RunRef {
    /// Forme texte de l'exécution `run`.
    pub fn encode(run: &SchedulerRecordId) -> Self {
        Self::from_sql(&run.to_sql())
    }

    /// Forme texte d'un identifiant d'exécution déjà écrit en SurrealQL (`<string> $run.id`,
    /// comme `retry_of` ou l'exécution d'une entrée du journal).
    pub fn from_sql(text: &str) -> Self {
        Self(URL_SAFE_NO_PAD.encode(text.as_bytes()))
    }

    /// Forme texte reçue (une adresse), non contrôlée : [`RunRef::decode`] la contrôle.
    pub fn new(text: impl Into<String>) -> Self {
        Self(text.into())
    }

    /// Texte de la forme.
    pub fn as_str(&self) -> &str {
        &self.0
    }

    /// Identifiant natif de l'exécution : base64url sans remplissage décodé en UTF-8
    /// (`SCHEDULER_INVALID_PARAMETERS` sinon), puis chaîne contrôlée et convertie par
    /// `fn::scheduler_run_ref` (`SCHEDULER_INVALID_PARAMETERS` pour une autre table ou une chaîne
    /// illisible). L'existence de l'exécution et les droits sont contrôlés par la fonction qui
    /// l'utilise ensuite.
    pub async fn decode(
        &self,
        store: &SchedulerStore,
        language: Option<String>,
    ) -> SchedulerResult<SchedulerRecordId> {
        let bytes = URL_SAFE_NO_PAD
            .decode(self.0.as_bytes())
            .map_err(|_| SchedulerError::InvalidRunRef)?;
        let run = String::from_utf8(bytes).map_err(|_| SchedulerError::InvalidRunRef)?;
        Ok(store.run_ref(RunRefTextParams { run, language }).await?)
    }
}

impl fmt::Display for RunRef {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::SchedulerDatetime;
    use lyxal_surreal::{RecordId, Value};
    use surrealdb::types::Array;

    #[test]
    fn encoding_is_base64url_without_padding() {
        let simple = RunRef::encode(&RecordId::new("scheduler_run", "abc"));
        assert_eq!(simple.as_str(), "c2NoZWR1bGVyX3J1bjphYmM");
        let at: SchedulerDatetime = "2026-01-01T00:00:00Z".parse().unwrap_or_default();
        let composite = RecordId::new(
            "scheduler_run",
            Array::from(vec![
                Value::RecordId(RecordId::new("scheduler_schedule", "x")),
                Value::Datetime(at),
            ]),
        );
        let text = RunRef::encode(&composite);
        assert!(!text.as_str().contains(['=', '+', '/', ':', '[']));
        let decoded = URL_SAFE_NO_PAD.decode(text.as_str()).unwrap_or_default();
        assert_eq!(
            String::from_utf8(decoded).unwrap_or_default(),
            "scheduler_run:[scheduler_schedule:x, d'2026-01-01T00:00:00Z']"
        );
        assert_eq!(RunRef::from_sql("scheduler_run:abc"), simple);
        assert_eq!(simple.to_string(), simple.as_str());
    }
}

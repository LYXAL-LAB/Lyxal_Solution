//! Forme texte d'un identifiant d'exécution (`RunRef`, X1), en base embarquée : aller-retour
//! d'un identifiant simple et d'un identifiant composé `[planification, date]`, forme illisible
//! et autre table refusées.

use crate::support::bench;
use lyxal_scheduler::models::{RunEnqueueParams, RunRefParams, SchedulerDatetime};
use lyxal_scheduler::{RunRef, SchedulerError};
use lyxal_surreal::{RecordId, Value};
use surrealdb::types::Array;

fn code(result: Result<RecordId, SchedulerError>) -> String {
    match result {
        Ok(id) => panic!("refus attendu, obtenu {id:?}"),
        Err(error) => error.code(),
    }
}

#[tokio::test]
async fn run_ref_round_trips_and_rejects_other_forms() {
    let (_client, store, _service) = bench().await;

    // Exécution réelle (clé simple) : relue par sa forme texte
    let mut params = RunEnqueueParams::new("essai.rapport");
    params.tenant = Some(RecordId::new("auth_organization", "alpha"));
    let mut args = surrealdb::types::Object::new();
    args.insert("format", "pdf".to_string());
    params.args = Some(Value::Object(args));
    let run = store.run_enqueue(params).await.expect("exécution");
    let text = RunRef::encode(&run.id);
    let decoded = RunRef::new(text.as_str())
        .decode(&store, None)
        .await
        .expect("décodage");
    assert_eq!(decoded, run.id);
    let read = store
        .run_get(RunRefParams {
            run: decoded,
            language: None,
        })
        .await
        .expect("lecture");
    assert_eq!(read.id, run.id);

    // Identifiant composé d'une échéance : rendu identique après l'aller-retour
    let at: SchedulerDatetime = "2026-01-01T00:00:00Z".parse().expect("date");
    let composite = RecordId::new(
        "scheduler_run",
        Array::from(vec![
            Value::RecordId(RecordId::new("scheduler_schedule", "x")),
            Value::Datetime(at),
        ]),
    );
    let decoded = RunRef::encode(&composite)
        .decode(&store, None)
        .await
        .expect("décodage");
    assert_eq!(decoded, composite);

    // Formes illisibles : pas du base64url, base64 avec remplissage, pas de l'UTF-8, texte en clair
    for text in ["scheduler_run:abc", "c2NoZWR1bGVyX3J1bjphYmM=", "_w", "a b"] {
        assert_eq!(
            code(RunRef::new(text).decode(&store, None).await),
            "SCHEDULER_INVALID_PARAMETERS",
            "{text}"
        );
    }
    // Encodage valide d'une chaîne qui n'est pas un identifiant
    assert_eq!(
        code(
            RunRef::from_sql("pas un identifiant")
                .decode(&store, None)
                .await
        ),
        "SCHEDULER_INVALID_PARAMETERS"
    );
    // Autre table refusée
    let schedule = RunRef::encode(&RecordId::new("scheduler_schedule", "x"));
    assert_eq!(
        code(schedule.decode(&store, None).await),
        "SCHEDULER_INVALID_PARAMETERS"
    );
}

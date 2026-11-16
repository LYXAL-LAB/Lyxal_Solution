//! Une tentative d'une exécution réservée : exécuteur (handler, fonction SurrealQL ou
//! publication différée), battement du bail à mi-bail, délai maximal (W4), annulation demandée,
//! puis fin par `run_complete` / `run_fail` sous le jeton du bail. Une fin refusée pour bail
//! perdu est journalisée, jamais réécrite.

use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError, ToSql};
use std::future::Future;
use std::pin::Pin;
use std::time::Duration;
use surrealdb::types::Object;

use super::executor::ExecutorTiming;
use super::SchedulerEngine;
use crate::error::{
    SchedulerError, EXECUTOR_FAILED, HANDLER_NOT_FOUND, INVALID_PARAMETERS, LEASE_LOST, RUN_TIMEOUT,
};
use crate::handler::{RunContext, TaskFailure, TaskOutput};
use crate::models::{
    ClaimedRun, Executor, FunctionCallParams, Heartbeat, RunCompleteParams, RunFailParams,
    RunFailure, RunHeartbeatParams, RunPublishParams, SchedulerValue,
};

/// Marge ajoutée au délai maximal pour l'échéance du bail (`fn::scheduler_lease_margin`).
const LEASE_MARGIN: Duration = Duration::from_secs(60);

/// Issue d'une tentative, pour le journal du worker.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) enum AttemptOutcome {
    /// Exécution terminée avec succès (ou publication différée faite).
    Completed,
    /// Tentative terminée en échec avec ce code.
    Failed(String),
    /// Bail perdu : rien n'est écrit, la reprise s'en charge.
    LeaseLost,
    /// Fin refusée par la base (autre que le bail perdu) : le bail expirera et la reprise s'en
    /// chargera.
    FinishRefused(String),
}

/// Ce que l'exécuteur a produit.
enum Executed {
    /// Handler ou fonction SurrealQL : la fin reste à écrire.
    Output(Result<TaskOutput, TaskFailure>),
    /// Publication différée : la fin est écrite par `fn::scheduler_run_publish`.
    Published(Result<(), SchedulerError>),
}

/// Pourquoi le moteur a cessé d'attendre l'exécuteur.
enum Stopped {
    Done(Executed),
    Timeout,
    LeaseLost,
}

/// Échec d'une tentative d'après l'erreur d'un appel : erreur métier (code et retentabilité de
/// la master data, libellé sans détail), nom de fonction refusé par `call_fn` (terminal : la
/// cible ne changera pas) ou erreur technique (`SCHEDULER_EXECUTOR_FAILED`, retentable).
fn failure_of(error: &SchedulerError) -> TaskFailure {
    if let SchedulerError::Surreal(inner) = error {
        match inner.as_ref() {
            LyxalSurrealError::Call(LyxalCallError::Business(business)) => {
                return TaskFailure {
                    code: business.code.clone(),
                    message: business.label.clone(),
                    retryable: business.retryable,
                };
            }
            LyxalSurrealError::InvalidFunctionName { .. } => {
                return TaskFailure::terminal(EXECUTOR_FAILED, "nom de fonction de tâche refusé");
            }
            _ => {}
        }
    }
    TaskFailure::retryable(EXECUTOR_FAILED, error.to_string())
}

/// Résultat court d'une fonction SurrealQL : objet gardé tel quel, autre valeur enveloppée
/// (`{ value }`), rien pour `NONE` ou `NULL`.
fn short_result(value: SchedulerValue) -> Option<SchedulerValue> {
    match value {
        SchedulerValue::None | SchedulerValue::Null => None,
        SchedulerValue::Object(_) => Some(value),
        other => {
            let mut object = Object::new();
            object.insert("value", other);
            Some(SchedulerValue::Object(object))
        }
    }
}

fn std_duration(value: &crate::models::SchedulerDuration) -> Duration {
    value.into_inner()
}

/// Exécute la tâche de l'exécution réservée `run`.
async fn execute(
    engine: &SchedulerEngine,
    run: &ClaimedRun,
    cancellation: CancellationToken,
) -> Executed {
    match run.executor {
        Executor::Handler => {
            let Some(handler) = engine.handlers().get(&run.target) else {
                return Executed::Output(Err(TaskFailure::retryable(
                    HANDLER_NOT_FOUND,
                    "aucun handler inscrit pour cette tâche sur ce nœud",
                )));
            };
            Executed::Output(
                handler
                    .run(RunContext {
                        run: run.id.clone(),
                        tenant: run.tenant.clone(),
                        schedule: run.schedule.clone(),
                        scheduled_for: run.scheduled_for,
                        attempt: run.attempt,
                        max_attempts: run.max_attempts,
                        args: run.args.clone(),
                        cancellation,
                    })
                    .await,
            )
        }
        Executor::Function => {
            // Nom contrôlé par `call_fn` : un nom refusé est une erreur technique terminale
            let called = engine
                .store()
                .call_task_function(
                    &run.target,
                    FunctionCallParams {
                        args: run.args.clone(),
                        run: run.id.clone(),
                        tenant: run.tenant.clone(),
                        scheduled_for: run.scheduled_for,
                        attempt: run.attempt,
                    },
                )
                .await;
            Executed::Output(match called {
                Ok(value) => Ok(TaskOutput {
                    result: short_result(value),
                }),
                Err(error) => Err(failure_of(&SchedulerError::from(error))),
            })
        }
        Executor::Event => Executed::Published(
            engine
                .store()
                .run_publish(RunPublishParams {
                    run: run.id.clone(),
                    lease: run.lease.clone(),
                    language: None,
                })
                .await
                .map(|_| ())
                .map_err(SchedulerError::from),
        ),
    }
}

/// Battement du bail en cours d'envoi.
type PendingBeat<'a> =
    Pin<Box<dyn Future<Output = Result<Heartbeat, LyxalSurrealError>> + Send + 'a>>;

/// Mène une tentative à son terme. `stop` est le jeton du worker (arrêt du nœud) : la tentative
/// reçoit un jeton enfant, annulé aussi par le délai maximal et l'annulation demandée.
pub(crate) async fn run_attempt(
    engine: &SchedulerEngine,
    timing: &ExecutorTiming,
    run: ClaimedRun,
    stop: &CancellationToken,
) -> AttemptOutcome {
    let token = stop.child_token();
    let id = run.id.to_sql();
    let timeout = std_duration(&run.timeout);
    let heartbeat = ((timeout + LEASE_MARGIN) / 2)
        .min(timing.max_heartbeat)
        .max(Duration::from_millis(10));
    if run.cancel_requested {
        token.cancel();
    }
    // Une publication différée écrit l'exécution elle-même dans sa transaction, courte et bornée
    // par le délai maximal (bail = délai + 1 min) : aucun battement, qui entrerait en conflit
    // d'écriture avec elle
    let beating = run.executor != Executor::Event;

    let stopped = {
        let executed = execute(engine, &run, token.clone());
        tokio::pin!(executed);
        let deadline = tokio::time::sleep(timeout);
        tokio::pin!(deadline);
        let mut beats =
            tokio::time::interval_at(tokio::time::Instant::now() + heartbeat, heartbeat);
        beats.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
        // Battement en cours : jamais attendu dans une branche du `select!`, mais mis en course
        // avec la tâche et le délai maximal, pour qu'une base qui répond lentement ne retarde ni
        // l'annulation ni le délai maximal
        let mut beat: Option<PendingBeat<'_>> = None;
        loop {
            tokio::select! {
                done = &mut executed => break Stopped::Done(done),
                _ = &mut deadline => {
                    // W4 : le handler reçoit l'annulation et dispose d'un court délai pour rendre
                    // la main (son résultat est ignoré) ; une fonction SurrealQL déjà partie
                    // n'est plus attendue
                    token.cancel();
                    if run.executor == Executor::Handler {
                        let _ = tokio::time::timeout(timing.cancel_grace, &mut executed).await;
                    }
                    break Stopped::Timeout;
                }
                _ = beats.tick(), if beating && beat.is_none() => {
                    beat = Some(Box::pin(engine.store().run_heartbeat(RunHeartbeatParams {
                        run: run.id.clone(),
                        lease: run.lease.clone(),
                        language: None,
                    })));
                }
                result = async { match beat.as_mut() { Some(call) => call.await, None => std::future::pending().await } }, if beat.is_some() => {
                    beat = None;
                    match result {
                        Ok(answer) => {
                            if answer.cancel_requested && !token.is_cancelled() {
                                tracing::info!(run = %id, "annulation demandée : transmise à la tentative");
                                token.cancel();
                            }
                        }
                        Err(error) => {
                            let error = SchedulerError::from(error);
                            if error.is_code(LEASE_LOST) {
                                token.cancel();
                                break Stopped::LeaseLost;
                            }
                            tracing::warn!(run = %id, code = %error.code(), error = %error, "battement du bail impossible");
                        }
                    }
                }
            }
        }
    };

    match stopped {
        Stopped::LeaseLost => {
            tracing::warn!(run = %id, "bail perdu pendant la tentative : rien n'est écrit, la reprise s'en charge");
            AttemptOutcome::LeaseLost
        }
        Stopped::Timeout => {
            fail(
                engine,
                &run,
                &id,
                TaskFailure::retryable(
                    RUN_TIMEOUT,
                    format!("délai maximal de {} s dépassé", timeout.as_secs_f64()),
                ),
            )
            .await
        }
        Stopped::Done(Executed::Published(Ok(()))) => AttemptOutcome::Completed,
        Stopped::Done(Executed::Published(Err(error))) => {
            if error.is_code(LEASE_LOST) {
                tracing::warn!(run = %id, "publication différée refusée : bail perdu");
                return AttemptOutcome::LeaseLost;
            }
            tracing::warn!(run = %id, code = %error.code(), error = %error, "publication différée en échec");
            fail(engine, &run, &id, failure_of(&error)).await
        }
        Stopped::Done(Executed::Output(Ok(output))) => complete(engine, &run, &id, output).await,
        Stopped::Done(Executed::Output(Err(failure))) => fail(engine, &run, &id, failure).await,
    }
}

/// Fin d'une écriture refusée : bail perdu (jamais réécrit) ou autre refus.
fn refused(id: &str, error: SchedulerError) -> AttemptOutcome {
    if error.is_code(LEASE_LOST) {
        tracing::warn!(run = %id, "fin de tentative refusée : bail perdu, rien n'est réécrit");
        return AttemptOutcome::LeaseLost;
    }
    tracing::error!(run = %id, code = %error.code(), error = %error, "fin de tentative refusée : le bail expirera et la reprise s'en chargera");
    AttemptOutcome::FinishRefused(error.code())
}

async fn complete(
    engine: &SchedulerEngine,
    run: &ClaimedRun,
    id: &str,
    output: TaskOutput,
) -> AttemptOutcome {
    let params = |result| RunCompleteParams {
        run: run.id.clone(),
        lease: run.lease.clone(),
        result,
        language: None,
    };
    let had_result = output.result.is_some();
    match engine.store().run_complete(params(output.result)).await {
        Ok(_) => AttemptOutcome::Completed,
        Err(error) => {
            let error = SchedulerError::from(error);
            // Résultat refusé (plus de 4 Kio ou pas un objet) : le succès est enregistré sans lui
            if had_result && error.is_code(INVALID_PARAMETERS) {
                tracing::warn!(run = %id, "résultat de la tâche refusé (4 Kio au plus, objet) : succès enregistré sans résultat");
                return match engine.store().run_complete(params(None)).await {
                    Ok(_) => AttemptOutcome::Completed,
                    Err(error) => refused(id, SchedulerError::from(error)),
                };
            }
            refused(id, error)
        }
    }
}

async fn fail(
    engine: &SchedulerEngine,
    run: &ClaimedRun,
    id: &str,
    failure: TaskFailure,
) -> AttemptOutcome {
    let code: String = failure.code.chars().take(128).collect();
    let code = if code.is_empty() {
        EXECUTOR_FAILED.to_string()
    } else {
        code
    };
    let message: String = failure.message.chars().take(1000).collect();
    match engine
        .store()
        .run_fail(RunFailParams {
            run: run.id.clone(),
            lease: run.lease.clone(),
            error: RunFailure {
                code: code.clone(),
                message: (!message.is_empty()).then_some(message),
            },
            retryable: Some(failure.retryable),
            language: None,
        })
        .await
    {
        Ok(_) => AttemptOutcome::Failed(code),
        Err(error) => refused(id, SchedulerError::from(error)),
    }
}

#[cfg(test)]
mod tests {
    use super::{failure_of, short_result};
    use crate::error::{SchedulerError, EXECUTOR_FAILED};
    use crate::models::SchedulerValue;
    use lyxal_surreal::LyxalSurrealError;

    #[test]
    fn refused_function_names_fail_for_good() {
        let refused = SchedulerError::from(LyxalSurrealError::InvalidFunctionName {
            function: "essai_purge($x); DELETE x".to_string(),
        });
        let failure = failure_of(&refused);
        assert_eq!(failure.code, EXECUTOR_FAILED);
        assert!(!failure.retryable);
    }

    #[test]
    fn short_results_are_objects() {
        assert_eq!(short_result(SchedulerValue::None), None);
        assert_eq!(short_result(SchedulerValue::Null), None);
        let wrapped = short_result(SchedulerValue::from_t(3_i64)).expect("résultat");
        assert!(matches!(wrapped, SchedulerValue::Object(_)));
    }
}

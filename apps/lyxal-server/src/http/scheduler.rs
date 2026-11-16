//! Routes du planificateur `/scheduler/*` (`lyxal_scheduler`, lot 4) : réglages, tâches, files,
//! calendriers, planifications (contrôlées avant écriture), prévision, contrôle d'une règle de
//! dates, exécutions et journal.
//!
//! L'appelant est identifié par son jeton d'accès (`Authorization: Bearer`) : chaque requête ouvre
//! une session SurrealDB à son nom. Les fonctions `fn::scheduler_*` et les permissions des tables
//! décident des droits (y compris la permission propre d'une tâche) ; l'hôte n'en recopie aucun
//! et n'utilise jamais la session système. Aucune route n'appelle une fonction du moteur
//! (échéances, réservation, bail, fin, reprise, élagage : X2), réservées aux workers de l'hôte.
//!
//! Une exécution est désignée, dans une adresse comme dans une réponse, par la forme texte de son
//! identifiant (`RunRef`, X1) : l'identifiant SurrealQL complet en base64url sans remplissage.
//! Toutes les réponses portent `Cache-Control: no-store` (arguments et résultats de tâches, X4),
//! y compris le 404 d'une adresse inconnue du planificateur.
//! Un corps ou un paramètre illisible rend `SERVER_INVALID_REQUEST` ; toute autre erreur est
//! celle du module (`SCHEDULER_*`). Réponses au contrat `LyxalResult` (`{ ok, data, error }`).

use super::auth::{self, ok, ApiError, ApiResult};
use crate::context::AppContext;
use crate::error::ServerError;
use crate::modules::scheduler::SchedulerHost;
use axum::body::Bytes;
use axum::extract::{Path, Query, State};
use axum::http::{HeaderMap, StatusCode};
use axum::response::Response;
use axum::routing::{any, get, post};
use axum::Router;
use lyxal_scheduler::models::{
    AuditEntry, AuditListParams, Calendar, CalendarCreateParams, CalendarListParams,
    CalendarRefParams, CalendarUpdateParams, Page, QueueListParams, QueuePauseParams,
    QueueResumeParams, Run, RunCancelParams, RunEnqueueParams, RunListParams, RunRefParams,
    Schedule, ScheduleBackfillParams, ScheduleCreateParams, ScheduleListParams,
    SchedulePauseParams, ScheduleRefParams, ScheduleSpec, ScheduleTriggerParams,
    ScheduleUpdateParams, SchedulerDatetime, SchedulerRecordId, SettingsGetParams,
    SettingsSetParams, SpecValidateParams, TaskGetParams, TaskListParams,
};
use lyxal_scheduler::{RunRef, SchedulerError, SchedulerService, SchedulerStore};
use lyxal_surreal::{LyxalSurrealError, RecordId, SurrealValue};
use serde_json::{json, Map, Value};
use std::collections::HashMap;
use std::future::Future;
use surrealdb::types::{Datetime, Duration, Object, Value as SurrealDbValue};

/// Champs d'identifiant d'enregistrement (`table:clé`) convertis en identifiants SurrealDB.
const RECORD_FIELDS: [&str; 3] = ["tenant", "schedule", "calendar"];
/// Listes d'identifiants d'enregistrement.
const RECORD_LIST_FIELDS: [&str; 1] = ["calendars"];
/// Champs de durée (`"30m"`, `"1h"`) convertis en durées SurrealDB.
const DURATION_FIELDS: [&str; 4] = ["delay", "catchup_window", "run_retention", "jitter"];
/// Listes de durées (intervalles d'une planification).
const DURATION_LIST_FIELDS: [&str; 1] = ["every"];
/// Champs de date (RFC 3339) convertis en dates SurrealDB.
const DATETIME_FIELDS: [&str; 8] = [
    "run_at",
    "since",
    "from",
    "to",
    "at",
    "start_at",
    "end_at",
    "created_at",
];
/// Objet dont les champs sont convertis comme ceux du corps (règles de dates). Les arguments
/// d'une tâche (`args`) ne sont jamais convertis.
const NESTED_FIELDS: [&str; 1] = ["spec"];
/// Paramètres d'adresse numériques.
const NUMBER_QUERY: [&str; 3] = ["limit", "start", "count"];
/// Paramètres d'adresse booléens.
const BOOLEAN_QUERY: [&str; 1] = ["paused"];
/// Échéances prévues par défaut (`GET /schedules/{id}/forecast`).
const DEFAULT_FORECAST: usize = 10;

/// Routes `/scheduler/*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/settings", get(settings_get).put(settings_set))
        .route("/tasks", get(task_list))
        .route("/tasks/:name", get(task_get))
        .route("/queues", get(queue_list))
        .route("/queues/:name/pause", post(queue_pause))
        .route("/queues/:name/resume", post(queue_resume))
        .route("/calendars", get(calendar_list).post(calendar_create))
        .route(
            "/calendars/:id",
            get(calendar_get)
                .patch(calendar_update)
                .delete(calendar_delete),
        )
        .route("/schedules", get(schedule_list).post(schedule_create))
        .route(
            "/schedules/:id",
            get(schedule_get)
                .patch(schedule_update)
                .delete(schedule_delete),
        )
        .route("/schedules/:id/pause", post(schedule_pause))
        .route("/schedules/:id/resume", post(schedule_resume))
        .route("/schedules/:id/trigger", post(schedule_trigger))
        .route("/schedules/:id/backfill", post(schedule_backfill))
        .route("/schedules/:id/forecast", get(schedule_forecast))
        .route("/specs/validate", post(spec_validate))
        .route("/runs", get(run_list).post(run_enqueue))
        .route("/runs/:id", get(run_get))
        .route("/runs/:id/cancel", post(run_cancel))
        .route("/runs/:id/retry", post(run_retry))
        .route("/audit", get(audit_list))
        // Adresse inconnue du planificateur : 404 sans corps, aussi marqué `no-store` (X4) ; une
        // route attrape-tout plutôt qu'un `fallback`, qu'un routeur imbriqué deux fois ne garde pas
        .route("/*rest", any(|| async { StatusCode::NOT_FOUND }))
        .layer(axum::middleware::map_response(auth::no_store))
}

// ----------------------------------------------------------------------------------------------
// Session, paramètres et réponses
// ----------------------------------------------------------------------------------------------

fn scheduler_host(context: &AppContext) -> Result<&SchedulerHost, ApiError> {
    context.scheduler.as_ref().ok_or_else(|| {
        ApiError::Server(ServerError::Configuration {
            message: "planificateur non hébergé".to_string(),
        })
    })
}

/// Exécute une route avec le service du planificateur sur une session SurrealDB au nom de
/// l'appelant, puis rend sa réponse ou son erreur.
async fn handle<F, Fut>(context: AppContext, headers: HeaderMap, route: F) -> Response
where
    F: FnOnce(SchedulerService) -> Fut,
    Fut: Future<Output = ApiResult>,
{
    let result = async {
        let host = scheduler_host(&context)?;
        let (_, session) = auth::caller_session(&context, &headers).await?;
        route(host.service(SchedulerStore::new(session))).await
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Requête illisible (corps, paramètre, date, durée, identifiant) : `SERVER_INVALID_REQUEST`,
/// sans reprendre la donnée reçue.
fn invalid(what: &str) -> ApiError {
    ApiError::Server(ServerError::InvalidRequest {
        message: what.to_string(),
    })
}

/// Erreur d'une fonction SurrealQL du planificateur.
fn surreal(error: LyxalSurrealError) -> ApiError {
    ApiError::Scheduler(SchedulerError::from(error))
}

/// Identifiant d'enregistrement d'une adresse : `table:clé` tel quel, sinon la clé dans cette
/// table. La table est contrôlée par la fonction SurrealQL appelée.
fn record(table: &str, id: &str) -> Result<SchedulerRecordId, ApiError> {
    let text = if id.contains(':') {
        id.to_string()
    } else {
        format!("{table}:{id}")
    };
    RecordId::parse_simple(&text).map_err(|_| invalid("identifiant"))
}

/// Exécution désignée par la forme texte de son identifiant (X1).
async fn run_id(service: &SchedulerService, text: &str) -> Result<SchedulerRecordId, ApiError> {
    Ok(RunRef::new(text).decode(service.store(), None).await?)
}

/// Corps JSON (objet) ; un corps vide vaut un objet vide.
fn body(bytes: &Bytes) -> Result<Map<String, Value>, ApiError> {
    if bytes.iter().all(u8::is_ascii_whitespace) {
        return Ok(Map::new());
    }
    match serde_json::from_slice(bytes) {
        Ok(Value::Object(object)) => Ok(object),
        _ => Err(invalid("corps de la requête : objet JSON attendu")),
    }
}

/// Paramètres d'adresse typés (nombres, booléens, textes).
fn query(raw: HashMap<String, String>) -> Map<String, Value> {
    raw.into_iter()
        .map(|(key, text)| {
            let value = if NUMBER_QUERY.contains(&key.as_str()) {
                text.parse::<i64>().map_or(Value::String(text), Value::from)
            } else if BOOLEAN_QUERY.contains(&key.as_str()) {
                text.parse::<bool>()
                    .map_or(Value::String(text), Value::Bool)
            } else {
                Value::String(text)
            };
            (key, value)
        })
        .collect()
}

/// Texte converti en identifiant, durée ou date selon le champ ; les autres champs restent tels
/// quels.
fn convert_field(key: &str, field: &mut SurrealDbValue) -> Result<(), ApiError> {
    match field {
        SurrealDbValue::String(text) if RECORD_FIELDS.contains(&key) => {
            *field =
                SurrealDbValue::RecordId(RecordId::parse_simple(text).map_err(|_| invalid(key))?);
        }
        SurrealDbValue::String(text) if DURATION_FIELDS.contains(&key) => {
            let parsed: Duration = text.parse().map_err(|_| invalid(key))?;
            *field = SurrealDbValue::Duration(parsed);
        }
        SurrealDbValue::String(text) if DATETIME_FIELDS.contains(&key) => {
            let parsed: Datetime = text.parse().map_err(|_| invalid(key))?;
            *field = SurrealDbValue::Datetime(parsed);
        }
        SurrealDbValue::Array(items) if RECORD_LIST_FIELDS.contains(&key) => {
            for item in items.iter_mut() {
                if let SurrealDbValue::String(text) = item {
                    *item = SurrealDbValue::RecordId(
                        RecordId::parse_simple(text).map_err(|_| invalid(key))?,
                    );
                }
            }
        }
        SurrealDbValue::Array(items) if DURATION_LIST_FIELDS.contains(&key) => {
            for item in items.iter_mut() {
                if let SurrealDbValue::String(text) = item {
                    let parsed: Duration = text.parse().map_err(|_| invalid(key))?;
                    *item = SurrealDbValue::Duration(parsed);
                }
            }
        }
        SurrealDbValue::Object(object) if NESTED_FIELDS.contains(&key) => convert(object)?,
        _ => {}
    }
    Ok(())
}

fn convert(object: &mut Object) -> Result<(), ApiError> {
    for (key, field) in object.iter_mut() {
        convert_field(key, field)?;
    }
    Ok(())
}

/// Paramètres d'une fonction `fn::scheduler_*` (un `XxxParams` du lot 2) : champs reçus (un
/// `null` vaut un champ absent), identifiants, durées et dates convertis.
fn params<T: SurrealValue>(input: Map<String, Value>) -> Result<T, ApiError> {
    let input: Map<String, Value> = input
        .into_iter()
        .filter(|(_, value)| !value.is_null())
        .map(|(key, value)| match (key.as_str(), value) {
            // Les champs facultatifs des règles de dates suivent la même règle (un `null` vaut un
            // champ absent) : une règle relue telle quelle peut être renvoyée. Les arguments
            // d'une tâche gardent leurs `null`.
            ("spec", Value::Object(spec)) => (
                key,
                Value::Object(spec.into_iter().filter(|(_, v)| !v.is_null()).collect()),
            ),
            (_, value) => (key, value),
        })
        .collect();
    let mut value = Value::Object(input).into_value();
    if let SurrealDbValue::Object(object) = &mut value {
        convert(object)?;
    }
    T::from_value(value).map_err(|_| invalid("paramètres"))
}

fn text_field(input: &Map<String, Value>, key: &str) -> Result<Option<String>, ApiError> {
    match input.get(key) {
        None | Some(Value::Null) => Ok(None),
        Some(Value::String(text)) => Ok(Some(text.clone())),
        Some(_) => Err(invalid(key)),
    }
}

/// Données d'un résultat, en JSON.
fn data<T: SurrealValue>(value: T) -> Value {
    value.into_value().into_json_value()
}

/// Exécution rendue au client : identifiant (et exécution relancée) sous leur forme texte.
fn run_json(run: Run) -> Value {
    let id = RunRef::encode(&run.id).to_string();
    let retry_of = run
        .retry_of
        .as_ref()
        .map(|origin| RunRef::encode(origin).to_string());
    let mut value = data(run);
    value["id"] = id.into();
    if let Some(retry_of) = retry_of {
        value["retry_of"] = retry_of.into();
    }
    value
}

/// Planification rendue au client : dernières exécutions sous leur forme texte.
fn schedule_json(schedule: Schedule) -> Value {
    let last_run = schedule
        .last_run
        .as_ref()
        .map(|run| RunRef::encode(run).to_string());
    let recent: Vec<String> = schedule
        .recent_runs
        .iter()
        .map(|run| RunRef::encode(&run.id).to_string())
        .collect();
    let mut value = data(schedule);
    if let Some(last_run) = last_run {
        value["last_run"] = last_run.into();
    }
    if let Some(Value::Array(runs)) = value.get_mut("recent_runs") {
        for (entry, id) in runs.iter_mut().zip(recent) {
            entry["id"] = id.into();
        }
    }
    value
}

/// Entrée du journal rendue au client : exécution sous sa forme texte.
fn audit_json(entry: AuditEntry) -> Value {
    let run = entry
        .run
        .as_deref()
        .map(|text| RunRef::from_sql(text).to_string());
    let mut value = data(entry);
    if let Some(run) = run {
        value["run"] = run.into();
    }
    value
}

/// Page d'une liste : éléments rendus par `item`.
fn page_json<T: SurrealValue>(page: Page<T>, item: fn(T) -> Value) -> Value {
    json!({
        "items": page.items.into_iter().map(item).collect::<Vec<_>>(),
        "total": page.total,
    })
}

fn done(status: StatusCode, value: Value) -> ApiResult {
    ok(status, value)
}

// ----------------------------------------------------------------------------------------------
// Réglages, tâches et files
// ----------------------------------------------------------------------------------------------

async fn settings_get(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let params: SettingsGetParams = params(query(raw))?;
        let settings = service
            .store()
            .settings_get(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(settings))
    })
    .await
}

async fn settings_set(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let params: SettingsSetParams = params(body(&bytes)?)?;
        let settings = service
            .store()
            .settings_set(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(settings))
    })
    .await
}

async fn task_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let params: TaskListParams = params(query(raw))?;
        let page = service.store().task_list(params).await.map_err(surreal)?;
        done(StatusCode::OK, page_json(page, data))
    })
    .await
}

async fn task_get(
    State(context): State<AppContext>,
    Path(name): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let task = service
            .store()
            .task_get(TaskGetParams {
                task: name,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(task))
    })
    .await
}

async fn queue_list(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    handle(context, headers, |service| async move {
        let queues = service
            .store()
            .queue_list(QueueListParams::default())
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(queues))
    })
    .await
}

/// File mise en pause : `{ reason }`.
async fn queue_pause(
    State(context): State<AppContext>,
    Path(name): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let input = body(&bytes)?;
        let queue = service
            .store()
            .queue_pause(QueuePauseParams {
                queue: name,
                reason: text_field(&input, "reason")?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(queue))
    })
    .await
}

async fn queue_resume(
    State(context): State<AppContext>,
    Path(name): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let queue = service
            .store()
            .queue_resume(QueueResumeParams {
                queue: name,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(queue))
    })
    .await
}

// ----------------------------------------------------------------------------------------------
// Calendriers
// ----------------------------------------------------------------------------------------------

async fn calendar_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let params: CalendarListParams = params(query(raw))?;
        let page = service
            .store()
            .calendar_list(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, page_json::<Calendar>(page, data))
    })
    .await
}

async fn calendar_create(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let params: CalendarCreateParams = params(body(&bytes)?)?;
        let calendar = service
            .store()
            .calendar_create(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::CREATED, data(calendar))
    })
    .await
}

async fn calendar_get(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let calendar = service
            .store()
            .calendar_get(CalendarRefParams {
                calendar: record("scheduler_calendar", &id)?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(calendar))
    })
    .await
}

/// Calendrier modifié : `{ description, rules, clear }`.
async fn calendar_update(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let mut input = body(&bytes)?;
        input.insert("calendar".into(), record_text("scheduler_calendar", &id));
        let params: CalendarUpdateParams = params(input)?;
        let calendar = service
            .store()
            .calendar_update(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(calendar))
    })
    .await
}

async fn calendar_delete(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let deleted = service
            .store()
            .calendar_delete(CalendarRefParams {
                calendar: record("scheduler_calendar", &id)?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(deleted))
    })
    .await
}

/// Identifiant d'une adresse, en texte, inséré dans un corps avant sa conversion.
fn record_text(table: &str, id: &str) -> Value {
    if id.contains(':') {
        Value::String(id.to_string())
    } else {
        Value::String(format!("{table}:{id}"))
    }
}

// ----------------------------------------------------------------------------------------------
// Planifications
// ----------------------------------------------------------------------------------------------

async fn schedule_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let params: ScheduleListParams = params(query(raw))?;
        let page = service
            .store()
            .schedule_list(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, page_json(page, schedule_json))
    })
    .await
}

/// Planification créée après le contrôle de ses règles de dates (`SchedulerService`).
async fn schedule_create(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let params: ScheduleCreateParams = params(body(&bytes)?)?;
        let schedule = service.schedule_create(params).await?;
        done(StatusCode::CREATED, schedule_json(schedule))
    })
    .await
}

async fn schedule_get(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let schedule = service
            .store()
            .schedule_get(ScheduleRefParams {
                schedule: record("scheduler_schedule", &id)?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, schedule_json(schedule))
    })
    .await
}

/// Planification modifiée après le contrôle de ses règles de dates (`SchedulerService`).
async fn schedule_update(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let mut input = body(&bytes)?;
        input.insert("schedule".into(), record_text("scheduler_schedule", &id));
        let params: ScheduleUpdateParams = params(input)?;
        let schedule = service.schedule_update(params).await?;
        done(StatusCode::OK, schedule_json(schedule))
    })
    .await
}

async fn schedule_delete(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let deleted = service
            .store()
            .schedule_delete(ScheduleRefParams {
                schedule: record("scheduler_schedule", &id)?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, data(deleted))
    })
    .await
}

/// Planification mise en pause : `{ reason }`.
async fn schedule_pause(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let mut input = body(&bytes)?;
        input.insert("schedule".into(), record_text("scheduler_schedule", &id));
        let params: SchedulePauseParams = params(input)?;
        let schedule = service
            .store()
            .schedule_pause(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, schedule_json(schedule))
    })
    .await
}

async fn schedule_resume(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let schedule = service
            .store()
            .schedule_resume(ScheduleRefParams {
                schedule: record("scheduler_schedule", &id)?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, schedule_json(schedule))
    })
    .await
}

/// Exécution immédiate d'une planification : `{ overlap }`.
async fn schedule_trigger(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let mut input = body(&bytes)?;
        input.insert("schedule".into(), record_text("scheduler_schedule", &id));
        let params: ScheduleTriggerParams = params(input)?;
        let run = service
            .store()
            .schedule_trigger(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::CREATED, run_json(run))
    })
    .await
}

/// Rejeu d'une période passée : `{ from, to, overlap }` (dates RFC 3339).
async fn schedule_backfill(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let mut input = body(&bytes)?;
        input.insert("schedule".into(), record_text("scheduler_schedule", &id));
        let params: ScheduleBackfillParams = params(input)?;
        let backfill = service
            .store()
            .schedule_backfill(params)
            .await
            .map_err(surreal)?;
        done(StatusCode::CREATED, data(backfill))
    })
    .await
}

/// Prochaines échéances d'une planification : `?count=` (10 par défaut, 100 au plus).
async fn schedule_forecast(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let count = match raw.get("count") {
            None => DEFAULT_FORECAST,
            Some(text) => text.parse::<usize>().map_err(|_| invalid("count"))?,
        };
        let entries = service
            .forecast(record("scheduler_schedule", &id)?, count)
            .await?;
        let items: Vec<Value> = entries
            .into_iter()
            .map(|entry| json!({ "fire_at": data(entry.fire_at), "local": entry.local }))
            .collect();
        done(StatusCode::OK, json!({ "items": items }))
    })
    .await
}

/// Règles de dates à contrôler sans écriture.
#[derive(SurrealValue)]
struct SpecCheck {
    tenant: Option<SchedulerRecordId>,
    spec: ScheduleSpec,
    calendars: Option<Vec<SchedulerRecordId>>,
    created_at: Option<SchedulerDatetime>,
}

/// Contrôle d'une règle de dates sans l'enregistrer : `{ tenant, spec, calendars, created_at }`
/// (droit de lecture de l'organisation ou de l'installation).
/// Refus : `SCHEDULER_SPEC_INVALID` avec la règle fautive et la raison.
async fn spec_validate(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let check: SpecCheck = params(body(&bytes)?)?;
        // Forme et droit de lecture par la même fonction SurrealQL que l'écriture, puis
        // syntaxe, fuseau et écart minimal par le calcul des dates
        service
            .store()
            .spec_validate(SpecValidateParams {
                tenant: check.tenant.clone(),
                spec: check.spec.clone(),
                language: None,
            })
            .await
            .map_err(surreal)?;
        service
            .validate_spec(
                &check.spec,
                &check.calendars.unwrap_or_default(),
                check.created_at.as_ref(),
            )
            .await?;
        done(StatusCode::OK, json!({ "valid": true }))
    })
    .await
}

// ----------------------------------------------------------------------------------------------
// Exécutions et journal
// ----------------------------------------------------------------------------------------------

async fn run_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let params: RunListParams = params(query(raw))?;
        let page = service.store().run_list(params).await.map_err(surreal)?;
        done(StatusCode::OK, page_json(page, run_json))
    })
    .await
}

/// Exécution différée (`run_at` ou `delay`) ou immédiate d'une tâche :
/// `{ task, tenant, args, run_at, delay, priority, unique_key }` : 201, ou 200 avec l'exécution
/// existante quand une exécution non terminée de même clé d'unicité est rendue (`duplicate`).
async fn run_enqueue(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let params: RunEnqueueParams = params(body(&bytes)?)?;
        let run = service.store().run_enqueue(params).await.map_err(surreal)?;
        // Exécution non terminée de même clé d'unicité rendue telle quelle : rien n'est créé
        let status = if run.duplicate == Some(true) {
            StatusCode::OK
        } else {
            StatusCode::CREATED
        };
        done(status, run_json(run))
    })
    .await
}

async fn run_get(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let run = run_id(&service, &id).await?;
        let run = service
            .store()
            .run_get(RunRefParams {
                run,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, run_json(run))
    })
    .await
}

/// Exécution annulée, ou annulation demandée si elle tourne : `{ reason }`.
async fn run_cancel(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    handle(context, headers, |service| async move {
        let input = body(&bytes)?;
        let run = run_id(&service, &id).await?;
        let run = service
            .store()
            .run_cancel(RunCancelParams {
                run,
                reason: text_field(&input, "reason")?,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::OK, run_json(run))
    })
    .await
}

/// Nouvelle exécution d'une exécution terminée en échec ou annulée.
async fn run_retry(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let run = run_id(&service, &id).await?;
        let run = service
            .store()
            .run_retry(RunRefParams {
                run,
                language: None,
            })
            .await
            .map_err(surreal)?;
        done(StatusCode::CREATED, run_json(run))
    })
    .await
}

async fn audit_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    handle(context, headers, |service| async move {
        let params: AuditListParams = params(query(raw))?;
        let page = service.store().audit_list(params).await.map_err(surreal)?;
        done(StatusCode::OK, page_json(page, audit_json))
    })
    .await
}

#[cfg(test)]
mod tests {
    use super::*;
    use lyxal_scheduler::models::RunState;

    fn object(value: Value) -> Map<String, Value> {
        value.as_object().cloned().unwrap_or_default()
    }

    #[test]
    fn query_values_are_typed_and_records_converted() {
        let raw = HashMap::from([
            ("limit".to_string(), "5".to_string()),
            ("tenant".to_string(), "auth_organization:alpha".to_string()),
            ("state".to_string(), "queued".to_string()),
            ("since".to_string(), "2026-01-01T00:00:00Z".to_string()),
        ]);
        let listed: RunListParams = params(query(raw)).unwrap_or_else(|_| panic!("paramètres"));
        assert_eq!(listed.limit, Some(5));
        assert_eq!(
            listed.tenant,
            Some(RecordId::new("auth_organization", "alpha"))
        );
        assert_eq!(listed.state, Some(RunState::Queued));
        assert!(listed.since.is_some());
        assert!(record("scheduler_schedule", "abc")
            .is_ok_and(|id| id == RecordId::new("scheduler_schedule", "abc")));
        assert!(record("scheduler_schedule", "scheduler_schedule:abc")
            .is_ok_and(|id| id == RecordId::new("scheduler_schedule", "abc")));
    }

    #[test]
    fn spec_durations_and_dates_are_converted_but_not_args() {
        let input = object(json!({
            "name": "rapport",
            "task": "essai.rapport",
            "tenant": "auth_organization:alpha",
            "calendars": ["scheduler_calendar:feries"],
            "catchup_window": "2h",
            "args": { "delay": "pas une durée", "at": "jamais" },
            "spec": { "every": ["1h"], "timezone": "Europe/Paris", "start_at": "2026-01-01T00:00:00Z", "jitter": "30s" },
        }));
        let created: ScheduleCreateParams =
            params(input).unwrap_or_else(|_| panic!("planification"));
        assert_eq!(created.spec.every.len(), 1);
        assert!(created.spec.start_at.is_some() && created.spec.jitter.is_some());
        assert_eq!(
            created.calendars,
            Some(vec![RecordId::new("scheduler_calendar", "feries")])
        );
        assert_eq!(
            created.catchup_window.map(|d| d.to_string()),
            Some("2h".to_string())
        );
        let wrong = object(json!({ "task": "essai.rapport", "delay": "deux heures" }));
        assert!(params::<RunEnqueueParams>(wrong).is_err());
        assert!(body(&Bytes::from_static(b"[1, 2]")).is_err());
        assert!(body(&Bytes::from_static(b"  ")).is_ok_and(|object| object.is_empty()));
    }
}

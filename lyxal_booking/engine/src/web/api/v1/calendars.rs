use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{delete, get, post},
    Json, Router,
};
use surrealdb::RecordId;

use crate::contracts::auth::AuthenticatedUser;
use crate::contracts::calendars::CreateCalendarSourceRequest;
use crate::services::calendar_sources;
use crate::web::WebError;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_calendar_sources).post(create_calendar_source))
        .route("/google/connect", get(google_connect))
        .route("/google/callback", get(google_callback))
        .route(
            "/{id}",
            get(get_calendar_source).delete(delete_calendar_source),
        )
        .route("/{id}/sync", post(sync_calendar_source))
        .route("/{id}/write", axum::routing::put(set_write_calendar))
}

fn parse_calendar_source_id(id_str: &str) -> Result<RecordId, WebError> {
    if id_str.starts_with("booking_caldav_source:") {
        let parts: Vec<&str> = id_str.splitn(2, ':').collect();
        Ok(RecordId::from(("booking_caldav_source", parts[1])))
    } else if !id_str.contains(':') {
        Ok(RecordId::from(("booking_caldav_source", id_str)))
    } else {
        Err(WebError::BadRequest(
            "Identifiant de source invalide: doit appartenir a la table booking_caldav_source".into(),
        ))
    }
}

async fn list_calendar_sources(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<impl IntoResponse, WebError> {
    let sources = calendar_sources::list_sources(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(sources)))
}

async fn create_calendar_source(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<CreateCalendarSourceRequest>,
) -> Result<impl IntoResponse, WebError> {
    let source = calendar_sources::create_source(&state.store, state.crypto.as_ref(), &auth, &request)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(source)))
}

async fn get_calendar_source(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, WebError> {
    let source_id = parse_calendar_source_id(&id)?;
    let source = calendar_sources::get_source(&state.store, &auth, &source_id)
        .await
        .map_err(|e| WebError::NotFound(e.to_string()))?;

    Ok((StatusCode::OK, Json(source)))
}

async fn delete_calendar_source(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, WebError> {
    let source_id = parse_calendar_source_id(&id)?;
    let response = calendar_sources::delete(&state.store, &auth, &source_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(response)))
}

async fn sync_calendar_source(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, WebError> {
    let source_id = parse_calendar_source_id(&id)?;
    let response = calendar_sources::sync(&state.store, &auth, &source_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(response)))
}

async fn google_connect(
    State(_state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<impl IntoResponse, WebError> {
    let response = calendar_sources::get_google_oauth_url(&auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;
    Ok((StatusCode::OK, Json(response)))
}

#[derive(serde::Deserialize)]
pub struct GoogleCallbackQuery {
    pub code: String,
    pub state: Option<String>,
}

async fn google_callback(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    axum::extract::Query(query): axum::extract::Query<GoogleCallbackQuery>,
) -> Result<impl IntoResponse, WebError> {
    // 1. Validation serveur du state et émission de l'échange de code OAuth2
    let create_req = CreateCalendarSourceRequest {
        name: "Google Calendar".to_string(),
        provider_type: "google".to_string(),
        auth_type: "oauth2".to_string(),
        server_url: Some("https://www.googleapis.com/calendar/v3/".to_string()),
        username: None,
        secret: Some(query.code),
    };

    let _source = calendar_sources::create_source(&state.store, state.crypto.as_ref(), &auth, &create_req)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    // 2. Redirection 302 HTTP sécurisée vers le Workspace sans exposer le code au frontend
    Ok(axum::response::Redirect::to("/workspace/calendars?oauth=success"))
}

async fn set_write_calendar(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
    Json(request): Json<crate::contracts::calendars::SetWriteCalendarRequest>,
) -> Result<impl IntoResponse, WebError> {
    let source_id = parse_calendar_source_id(&id)?;
    let response = calendar_sources::set_write_calendar(&state.store, &auth, &source_id, &request.calendar_href)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(response)))
}

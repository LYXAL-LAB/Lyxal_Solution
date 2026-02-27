use axum::{Json, response::IntoResponse};
use serde_json::json;

pub async fn get_dashboard_stats() -> impl IntoResponse {
    Json(json!({ "totalUsers": 100, "activeSessions": 5, "status": "1:1 Logto Parity" }))
}

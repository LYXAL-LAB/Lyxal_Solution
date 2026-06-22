use axum::{response::Html, response::IntoResponse};

pub async fn login_page() -> impl IntoResponse {
    Html("<h1>Lyxal Login (1:1 Logto Experience)</h1>")
}

pub async fn register_page() -> impl IntoResponse {
    Html("<h1>Lyxal Register</h1>")
}

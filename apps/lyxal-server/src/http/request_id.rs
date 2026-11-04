//! Identifiant de la requête en cours (`x-request-id`), accessible pendant son traitement : une
//! réponse d'erreur le renvoie comme `trace_id` et le journal le cite.

tokio::task_local! {
    static REQUEST_ID: String;
}

/// Exécute `future` avec `id` comme identifiant de requête courant.
pub async fn scope<F: std::future::Future>(id: String, future: F) -> F::Output {
    REQUEST_ID.scope(id, future).await
}

/// Identifiant de la requête en cours ; `"none"` hors d'une requête HTTP.
pub fn current() -> String {
    REQUEST_ID
        .try_with(Clone::clone)
        .unwrap_or_else(|_| "none".to_string())
}

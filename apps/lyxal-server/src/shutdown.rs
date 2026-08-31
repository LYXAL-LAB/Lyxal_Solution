use crate::error::ServerError;

pub async fn signal() -> Result<(), ServerError> {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .map_err(|error| ServerError::Shutdown(error.to_string()))
    };

    #[cfg(unix)]
    let terminate = async {
        use tokio::signal::unix::{SignalKind, signal};
        let mut stream = signal(SignalKind::terminate())
            .map_err(|error| ServerError::Shutdown(error.to_string()))?;
        stream.recv().await;
        Ok::<(), ServerError>(())
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<Result<(), ServerError>>();

    tokio::select! {
        result = ctrl_c => result,
        result = terminate => result,
    }
}

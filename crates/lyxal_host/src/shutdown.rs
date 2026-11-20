//! Signal d'arrêt de l'hôte : SIGINT, ou SIGTERM sous Unix.

use crate::HostError;

pub async fn signal() -> Result<(), HostError> {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .map_err(|error| HostError::ShutdownSignal {
                message: error.to_string(),
            })
    };

    #[cfg(unix)]
    let terminate = async {
        use tokio::signal::unix::{signal, SignalKind};
        let mut stream =
            signal(SignalKind::terminate()).map_err(|error| HostError::ShutdownSignal {
                message: error.to_string(),
            })?;
        stream.recv().await;
        Ok::<(), HostError>(())
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<Result<(), HostError>>();

    tokio::select! {
        result = ctrl_c => result,
        result = terminate => result,
    }
}

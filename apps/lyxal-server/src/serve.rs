//! Service des connexions HTTP, avec délai d'écriture.
//!
//! Un client qui cesse de lire une réponse (téléchargement d'un fichier, par exemple) remplit le
//! tampon d'envoi : plus rien n'est demandé au corps de la réponse, et aucun délai posé dans une
//! route ne peut expirer. Le délai est donc porté par la connexion elle-même : une écriture qui
//! n'avance plus pendant `write_idle` ferme la connexion, ce qui libère le fichier ouvert et la
//! place prise dans la limite de requêtes simultanées.

use axum::extract::ConnectInfo;
use axum::Router;
use hyper::body::Incoming;
use hyper::Request;
use hyper_util::rt::{TokioExecutor, TokioIo};
use hyper_util::server::conn::auto::Builder;
use hyper_util::server::graceful::GracefulShutdown;
use std::future::Future;
use std::time::Duration;
use tokio::net::TcpListener;
use tokio_io_timeout::TimeoutStream;
use tower::Service;

/// Sert `router` sur `listener` jusqu'à la fin de `shutdown`, puis laisse `drain` aux requêtes en
/// cours pour se terminer. L'adresse du client est transmise aux routes (`ConnectInfo`).
pub async fn serve(
    listener: TcpListener,
    router: Router,
    write_idle: Duration,
    drain: Duration,
    shutdown: impl Future<Output = ()>,
) {
    let builder = Builder::new(TokioExecutor::new());
    let graceful = GracefulShutdown::new();
    let mut shutdown = std::pin::pin!(shutdown);
    loop {
        tokio::select! {
            accepted = listener.accept() => {
                let (stream, remote) = match accepted {
                    Ok(accepted) => accepted,
                    Err(error) => {
                        // Erreur passagère d'acceptation (descripteurs épuisés, connexion
                        // réinitialisée) : le serveur continue
                        tracing::warn!(%error, "connexion entrante refusée");
                        tokio::time::sleep(Duration::from_millis(50)).await;
                        continue;
                    }
                };
                let mut stream = TimeoutStream::new(stream);
                stream.set_write_timeout(Some(write_idle));
                let router = router.clone();
                let service = hyper::service::service_fn(move |mut request: Request<Incoming>| {
                    request.extensions_mut().insert(ConnectInfo(remote));
                    router.clone().call(request)
                });
                let connection = graceful.watch(
                    builder
                        .serve_connection_with_upgrades(TokioIo::new(Box::pin(stream)), service)
                        .into_owned(),
                );
                tokio::spawn(async move {
                    if let Err(error) = connection.await {
                        tracing::debug!(%remote, %error, "connexion fermée sur erreur");
                    }
                });
            }
            () = &mut shutdown => break,
        }
    }
    drop(listener);
    if tokio::time::timeout(drain, graceful.shutdown())
        .await
        .is_err()
    {
        tracing::warn!(
            drain_seconds = drain.as_secs(),
            "arrêt : des requêtes en cours ont été interrompues"
        );
    }
}

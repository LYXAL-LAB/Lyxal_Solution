//! Faux APNs : serveur HTTP/2 sans chiffrement (h2c, boucle locale) qui enregistre chaque
//! requête et répond selon un scénario (réponses dans l'ordre, puis 200 avec `apns-id`). Le
//! client des tests parle HTTP/2 d'emblée, comme avec le vrai APNs.

use http_body_util::{BodyExt, Full};
use hyper::body::{Bytes, Incoming};
use hyper::{Request as HyperRequest, Response};
use hyper_util::rt::{TokioExecutor, TokioIo};
use std::collections::HashMap;
use std::convert::Infallible;
use std::sync::{Arc, Mutex};
use tokio::net::TcpListener;

/// Requête reçue.
#[derive(Debug, Clone)]
pub struct ApnsRequest {
    pub path: String,
    /// Version HTTP (doit être HTTP/2).
    pub http2: bool,
    /// En-têtes, noms en minuscules.
    pub headers: HashMap<String, String>,
    pub body: serde_json::Value,
}

#[derive(Default)]
struct State {
    requests: Vec<ApnsRequest>,
    /// Réponses à servir dans l'ordre : (code, raison).
    script: Vec<(u16, Option<&'static str>)>,
}

#[derive(Clone)]
pub struct FakeApns {
    pub base: String,
    state: Arc<Mutex<State>>,
}

impl FakeApns {
    pub async fn start() -> Self {
        let listener = TcpListener::bind("127.0.0.1:0").await.expect("écoute");
        let port = listener.local_addr().expect("adresse").port();
        let state = Arc::new(Mutex::new(State::default()));
        let shared = state.clone();
        tokio::spawn(async move {
            while let Ok((socket, _)) = listener.accept().await {
                let state = shared.clone();
                tokio::spawn(async move {
                    let service = hyper::service::service_fn(move |request| {
                        let state = state.clone();
                        async move { Ok::<_, Infallible>(serve(request, state).await) }
                    });
                    let _ = hyper::server::conn::http2::Builder::new(TokioExecutor::new())
                        .serve_connection(TokioIo::new(socket), service)
                        .await;
                });
            }
        });
        Self {
            base: format!("http://127.0.0.1:{port}"),
            state,
        }
    }

    /// Réponses à servir, dans l'ordre (code, raison APNs).
    pub fn script(&self, replies: Vec<(u16, Option<&'static str>)>) {
        self.state.lock().expect("verrou").script = replies;
    }

    pub fn requests(&self) -> Vec<ApnsRequest> {
        self.state.lock().expect("verrou").requests.clone()
    }
}

async fn serve(request: HyperRequest<Incoming>, state: Arc<Mutex<State>>) -> Response<Full<Bytes>> {
    let http2 = request.version() == hyper::Version::HTTP_2;
    let path = request.uri().path().to_string();
    let headers = request
        .headers()
        .iter()
        .map(|(k, v)| {
            (
                k.as_str().to_ascii_lowercase(),
                v.to_str().unwrap_or_default().to_string(),
            )
        })
        .collect();
    let body = request
        .into_body()
        .collect()
        .await
        .map(|collected| collected.to_bytes())
        .unwrap_or_default();
    let (status, reason) = {
        let mut guard = state.lock().expect("verrou");
        guard.requests.push(ApnsRequest {
            path,
            http2,
            headers,
            body: serde_json::from_slice(&body).unwrap_or(serde_json::Value::Null),
        });
        if guard.script.is_empty() {
            (200, None)
        } else {
            guard.script.remove(0)
        }
    };
    let mut response = Response::builder().status(status);
    let body = match reason {
        Some(reason) => serde_json::json!({ "reason": reason }).to_string(),
        None => {
            response = response.header("apns-id", "0190a5b2-7c3e-7d4a-9b1c-0000000000ff");
            String::new()
        }
    };
    response
        .body(Full::new(Bytes::from(body)))
        .expect("réponse")
}

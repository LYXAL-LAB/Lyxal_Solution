//! Faux fournisseurs HTTP (boucle locale, HTTP/1.1 sans chiffrement) : enregistrent chaque
//! requête reçue et répondent selon un scénario par préfixe de chemin (`/brevo`, `/mailgun-us`,
//! `/mailgun-eu`, `/postmark`, `/resend`). Aucun appel réel à un fournisseur.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};

/// Requête reçue.
#[derive(Debug, Clone)]
pub struct Request {
    pub method: String,
    pub path: String,
    /// En-têtes, noms en minuscules.
    pub headers: HashMap<String, String>,
    pub body: String,
}

impl Request {
    pub fn header(&self, name: &str) -> Option<&str> {
        self.headers.get(name).map(String::as_str)
    }

    pub fn json(&self) -> serde_json::Value {
        serde_json::from_str(&self.body).expect("corps JSON")
    }

    /// Champs d'un corps `application/x-www-form-urlencoded`.
    pub fn form(&self) -> Vec<(String, String)> {
        self.body
            .split('&')
            .filter_map(|pair| pair.split_once('='))
            .map(|(k, v)| (decode(k), decode(v)))
            .collect()
    }
}

fn decode(value: &str) -> String {
    let bytes = value.replace('+', " ").into_bytes();
    let mut out = Vec::with_capacity(bytes.len());
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'%' && i + 2 < bytes.len() {
            if let Ok(byte) = u8::from_str_radix(&String::from_utf8_lossy(&bytes[i + 1..i + 3]), 16)
            {
                out.push(byte);
                i += 3;
                continue;
            }
        }
        out.push(bytes[i]);
        i += 1;
    }
    String::from_utf8_lossy(&out).to_string()
}

/// Réponse servie.
#[derive(Debug, Clone)]
pub struct Reply {
    pub status: u16,
    pub headers: Vec<(&'static str, String)>,
    pub body: String,
}

impl Reply {
    pub fn json(status: u16, body: serde_json::Value) -> Self {
        Self {
            status,
            headers: vec![("content-type", "application/json".to_string())],
            body: body.to_string(),
        }
    }

    pub fn status(status: u16) -> Self {
        Self {
            status,
            headers: Vec::new(),
            body: String::new(),
        }
    }
}

#[derive(Default)]
struct State {
    requests: Vec<Request>,
    /// Réponses à servir par préfixe de chemin, dans l'ordre ; ensuite la réponse par défaut.
    scripted: HashMap<String, Vec<Reply>>,
    defaults: HashMap<String, Reply>,
}

#[derive(Clone)]
pub struct FakeProviders {
    pub base: String,
    state: Arc<Mutex<State>>,
}

fn prefix(path: &str) -> String {
    path.trim_start_matches('/')
        .split('/')
        .next()
        .unwrap_or_default()
        .to_string()
}

impl FakeProviders {
    pub async fn start() -> Self {
        let listener = TcpListener::bind("127.0.0.1:0").await.expect("écoute");
        let port = listener.local_addr().expect("adresse").port();
        let state = Arc::new(Mutex::new(State::default()));
        {
            let mut guard = state.lock().expect("verrou");
            for (name, reply) in [
                (
                    "brevo",
                    Reply::json(
                        201,
                        serde_json::json!({ "messageId": "<br-1@smtp-relay.brevo.test>" }),
                    ),
                ),
                (
                    "mailgun-us",
                    Reply::json(
                        200,
                        serde_json::json!({ "id": "<mg-1@mg.lyxal.test>", "message": "Queued. Thank you." }),
                    ),
                ),
                (
                    "mailgun-eu",
                    Reply::json(
                        200,
                        serde_json::json!({ "id": "<mg-eu-1@mg.lyxal.test>", "message": "Queued. Thank you." }),
                    ),
                ),
                (
                    "postmark",
                    Reply::json(
                        200,
                        serde_json::json!({ "MessageID": "pm-1", "ErrorCode": 0, "Message": "OK" }),
                    ),
                ),
                (
                    "resend",
                    Reply::json(200, serde_json::json!({ "id": "re-1" })),
                ),
            ] {
                guard.defaults.insert(name.to_string(), reply);
            }
        }
        let shared = state.clone();
        tokio::spawn(async move {
            while let Ok((socket, _)) = listener.accept().await {
                let state = shared.clone();
                tokio::spawn(async move { serve(socket, state).await });
            }
        });
        Self {
            base: format!("http://127.0.0.1:{port}"),
            state,
        }
    }

    /// Réponses à servir, dans l'ordre, pour un fournisseur (`brevo`, `postmark`…).
    pub fn script(&self, provider: &str, replies: Vec<Reply>) {
        self.state
            .lock()
            .expect("verrou")
            .scripted
            .insert(provider.to_string(), replies);
    }

    pub fn requests(&self) -> Vec<Request> {
        self.state.lock().expect("verrou").requests.clone()
    }

    pub fn requests_to(&self, provider: &str) -> Vec<Request> {
        self.requests()
            .into_iter()
            .filter(|r| prefix(&r.path) == provider)
            .collect()
    }
}

async fn serve(mut socket: TcpStream, state: Arc<Mutex<State>>) {
    let mut buffer = Vec::new();
    let mut chunk = [0u8; 8192];
    let header_end = loop {
        match socket.read(&mut chunk).await {
            Ok(0) | Err(_) => return,
            Ok(n) => buffer.extend_from_slice(&chunk[..n]),
        }
        if let Some(position) = buffer.windows(4).position(|w| w == b"\r\n\r\n") {
            break position;
        }
    };
    let head = String::from_utf8_lossy(&buffer[..header_end]).to_string();
    let mut lines = head.split("\r\n");
    let mut first = lines.next().unwrap_or_default().split(' ');
    let method = first.next().unwrap_or_default().to_string();
    let path = first.next().unwrap_or_default().to_string();
    let headers: HashMap<String, String> = lines
        .filter_map(|line| line.split_once(':'))
        .map(|(k, v)| (k.trim().to_ascii_lowercase(), v.trim().to_string()))
        .collect();
    let length: usize = headers
        .get("content-length")
        .and_then(|v| v.parse().ok())
        .unwrap_or(0);
    let mut body = buffer[header_end + 4..].to_vec();
    while body.len() < length {
        match socket.read(&mut chunk).await {
            Ok(0) | Err(_) => break,
            Ok(n) => body.extend_from_slice(&chunk[..n]),
        }
    }
    let provider = prefix(&path);
    let reply = {
        let mut guard = state.lock().expect("verrou");
        guard.requests.push(Request {
            method,
            path,
            headers,
            body: String::from_utf8_lossy(&body).to_string(),
        });
        let scripted = guard.scripted.get_mut(&provider).and_then(|replies| {
            if replies.is_empty() {
                None
            } else {
                Some(replies.remove(0))
            }
        });
        scripted
            .or_else(|| guard.defaults.get(&provider).cloned())
            .unwrap_or_else(|| Reply::status(404))
    };
    let mut response = format!(
        "HTTP/1.1 {} X\r\ncontent-length: {}\r\nconnection: close\r\n",
        reply.status,
        reply.body.len()
    );
    for (name, value) in &reply.headers {
        response.push_str(&format!("{name}: {value}\r\n"));
    }
    response.push_str("\r\n");
    let _ = socket.write_all(response.as_bytes()).await;
    let _ = socket.write_all(reply.body.as_bytes()).await;
    let _ = socket.shutdown().await;
}

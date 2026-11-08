//! Serveur SMTP de test (boucle locale, sans chiffrement) : enregistre les messages acceptés et
//! répond selon un scénario par destinataire.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::TcpListener;

/// Message reçu.
#[derive(Debug, Clone)]
pub struct Received {
    pub rcpt: String,
    pub data: String,
}

#[derive(Default)]
struct State {
    received: Vec<Received>,
    /// Réponses à `RCPT TO` à servir avant d'accepter (par adresse).
    scripted: HashMap<String, Vec<&'static str>>,
}

#[derive(Clone)]
pub struct TestSmtpServer {
    pub port: u16,
    state: Arc<Mutex<State>>,
}

impl TestSmtpServer {
    pub async fn start() -> Self {
        let listener = TcpListener::bind("127.0.0.1:0").await.expect("écoute");
        let port = listener.local_addr().expect("adresse").port();
        let state = Arc::new(Mutex::new(State::default()));
        let shared = state.clone();
        tokio::spawn(async move {
            while let Ok((socket, _)) = listener.accept().await {
                let state = shared.clone();
                tokio::spawn(async move { session(socket, state).await });
            }
        });
        Self { port, state }
    }

    /// Réponses successives à `RCPT TO:<address>` (ex. `"451 4.3.0 réessayez"`), puis acceptation.
    pub fn script(&self, address: &str, replies: Vec<&'static str>) {
        self.state
            .lock()
            .expect("verrou")
            .scripted
            .insert(address.to_string(), replies);
    }

    pub fn received(&self) -> Vec<Received> {
        self.state.lock().expect("verrou").received.clone()
    }
}

async fn session(socket: tokio::net::TcpStream, state: Arc<Mutex<State>>) {
    let (reader, mut writer) = socket.into_split();
    let mut lines = BufReader::new(reader).lines();
    let _ = writer.write_all(b"220 lyxal.test ESMTP test\r\n").await;
    let mut rcpt = String::new();
    while let Ok(Some(line)) = lines.next_line().await {
        let upper = line.to_ascii_uppercase();
        let reply: String = if upper.starts_with("EHLO") || upper.starts_with("HELO") {
            "250-lyxal.test\r\n250 8BITMIME".to_string()
        } else if upper.starts_with("MAIL FROM") || upper.starts_with("RSET") || upper.starts_with("NOOP") {
            "250 2.0.0 OK".to_string()
        } else if upper.starts_with("RCPT TO") {
            let address = line
                .split_once('<')
                .and_then(|(_, rest)| rest.split_once('>'))
                .map(|(address, _)| address.to_string())
                .unwrap_or_default();
            let scripted = {
                let mut guard = state.lock().expect("verrou");
                guard.scripted.get_mut(&address).and_then(|replies| {
                    if replies.is_empty() {
                        None
                    } else {
                        Some(replies.remove(0))
                    }
                })
            };
            match scripted {
                Some(reply) => reply.to_string(),
                None => {
                    rcpt = address;
                    "250 2.1.5 OK".to_string()
                }
            }
        } else if upper == "DATA" {
            let _ = writer.write_all(b"354 fin par <CRLF>.<CRLF>\r\n").await;
            let mut data = String::new();
            while let Ok(Some(body)) = lines.next_line().await {
                if body == "." {
                    break;
                }
                data.push_str(&body);
                data.push('\n');
            }
            state.lock().expect("verrou").received.push(Received {
                rcpt: rcpt.clone(),
                data,
            });
            "250 2.0.0 accepté".to_string()
        } else if upper.starts_with("QUIT") {
            let _ = writer.write_all(b"221 2.0.0 au revoir\r\n").await;
            return;
        } else {
            "502 5.5.2 commande inconnue".to_string()
        };
        if writer.write_all(format!("{reply}\r\n").as_bytes()).await.is_err() {
            return;
        }
    }
}

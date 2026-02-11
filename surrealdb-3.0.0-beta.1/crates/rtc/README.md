# Lyxal RTC

Module WebRTC complet pour l'écosystème Lyxal, basé sur [webrtc.rs](https://webrtc.rs).

## Architecture

```
lyxal-rtc/
├── webrtc/      # Stack Async (Tokio) - API classique WebRTC
├── rtc/         # Stack Sans-IO - Runtime agnostic
├── sfu/         # Selective Forwarding Unit - Serveur de conférence
└── sansio/      # Pattern Sans-IO de base
```

## Stacks disponibles

### 1. Stack Async (`webrtc/`)

Stack WebRTC complet avec runtime Tokio intégré. Idéal pour :
- Prototypage rapide
- Applications serveur classiques
- Intégration avec écosystème async Rust

```rust
use webrtc::api::APIBuilder;
use webrtc::peer_connection::configuration::RTCConfiguration;

let api = APIBuilder::new().build();
let pc = api.new_peer_connection(RTCConfiguration::default()).await?;
```

### 2. Stack Sans-IO (`rtc/`)

Stack WebRTC découplé de l'I/O. Idéal pour :
- Intégration avec SurrealDB
- Environnements embarqués
- Tests unitaires
- WASM

```rust
use rtc::RtcPeerConnection;

let mut pc = RtcPeerConnection::new(config);
// Pas de runtime - vous gérez l'I/O
let output = pc.handle_input(input_data);
```

### 3. SFU (`sfu/`)

Serveur de visioconférence multi-participants. Idéal pour :
- Google Meet-like
- Streaming live
- Webinars

```rust
use sfu::Server;

let server = Server::new(config);
server.add_session(session_id);
```

## Crates inclus

### Sans-IO (rtc/)
| Crate | Description |
|-------|-------------|
| `rtc` | API principale |
| `rtc-ice` | ICE agent |
| `rtc-dtls` | DTLS 1.2 |
| `rtc-srtp` | Secure RTP |
| `rtc-sctp` | SCTP transport |
| `rtc-datachannel` | DataChannels |
| `rtc-rtp` | RTP |
| `rtc-rtcp` | RTCP |
| `rtc-sdp` | SDP |
| `rtc-stun` | STUN |
| `rtc-turn` | TURN |
| `rtc-media` | Tracks |
| `rtc-shared` | Utils |

### Async (webrtc/)
| Crate | Description |
|-------|-------------|
| `webrtc` | API principale |
| `webrtc-ice` | ICE agent |
| `dtls` | DTLS |
| `webrtc-srtp` | SRTP |
| `webrtc-sctp` | SCTP |
| `webrtc-data` | DataChannels |
| `rtp` | RTP |
| `rtcp` | RTCP |
| `sdp` | SDP |
| `stun` | STUN |
| `turn` | TURN |
| `webrtc-media` | Tracks |
| `interceptor` | Middleware |

## Intégration SurrealDB

Une fois complété, ce module sera intégré dans SurrealDB comme crate :

```sql
-- Définir un stream WebRTC
DEFINE STREAM video_call TYPE sfu PERMISSIONS FULL;

-- Créer une session
LET $session = rtc::create_session("video_call", $auth.id, "publisher");

-- Envoyer un signal
rtc::signal($session.id, "offer", $sdp);
```

## Build

```bash
cd lyxal-rtc
cargo build --workspace
```

## Tests

```bash
cargo test --workspace
```

## License

MIT OR Apache-2.0

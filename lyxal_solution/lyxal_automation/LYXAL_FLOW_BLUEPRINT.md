# 🦀 Lyxal Flow Engine : Blueprint d'Implémentation

> **Objectif** : Construire un moteur de flow Rust natif inspiré par n8n  
> **Philosophie** : Absorber la substance de n8n, pas son code

---

## 📋 Table des Matières

1. [Ce qu'il faut extraire de n8n](#1-ce-quil-faut-extraire-de-n8n)
2. [Architecture cible Rust](#2-architecture-cible-rust)
3. [Mapping n8n → Lyxal](#3-mapping-n8n--lyxal)
4. [Plan d'implémentation](#4-plan-dimplémentation)
5. [Risques et défis](#5-risques-et-défis)

---

## 1. Ce qu'il faut extraire de n8n

### ✅ Concepts à conserver

| Concept n8n | Valeur | Adaptation Lyxal |
|-------------|--------|------------------|
| **Workflow = Graphe DAG** | Modèle mental simple | Garder tel quel |
| **Nodes = Unités atomiques** | Composabilité | → Rust traits |
| **Connections = Edges typés** | Flux de données | → Zero-copy channels |
| **Triggers** | Points d'entrée | → Intégré au Kernel |
| **Credentials** | Sécurité | → Intégré à lyxal_auth |
| **Versioning workflows** | Audit | → lyxal_revision |
| **Execution history** | Débogage | → Tables natives |

### 🔄 Concepts à transformer

| n8n (Node.js) | Limitation | Lyxal (Rust) |
|---------------|------------|--------------|
| JSON sérialisation | Coût CPU/mémoire | Zero-copy avec `bytes` |
| TypeORM | Overhead ORM | Requêtes LyxalQL natives |
| Express webhooks | Bloating | Hyper/Axum intégré |
| Bull queue (Redis) | Dépendance externe | Queue native in-process |
| IMAP polling | Processus séparé | Async task dans le kernel |

### ❌ Concepts à abandonner

| n8n | Raison |
|-----|--------|
| Node.js runtime | Contre la philosophie Rust-only |
| npm dependencies | Souveraineté compromise |
| TypeScript | Pas de memory safety garantie |
| Electron (desktop) | Trop lourd |

---

## 2. Architecture cible Rust

### Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                      LYXAL KERNEL (Rust)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  lyxalkv     │  │  lyxal_auth  │  │ lyxal_rtc    │           │
│  │  (Storage)   │  │  (Identity)  │  │ (Real-time)  │           │
│  └──────┬───────┘  └──────────────┘  └──────────────┘           │
│         │                                                        │
│  ┌──────▼────────────────────────────────────────────────────┐  │
│  │                  LYXAL FLOW ENGINE                         │  │
│  │                                                            │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │  │
│  │  │  Scheduler  │  │  Executor   │  │  Graph      │        │  │
│  │  │  (cron)     │  │  (async)    │  │  (DAG)      │        │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │  │
│  │                                                            │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │  │
│  │  │  Triggers   │  │  Nodes      │  │  Intrinsics │        │  │
│  │  │  (webhook,  │  │  (wasm/     │  │  (http,     │        │  │
│  │  │   poll...)  │  │   native)   │  │   db, fs)   │        │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Composants clés

#### A. Flow Graph Engine

```rust
// Modèle de donnée du workflow
pub struct Workflow {
    pub id: Ulid,
    pub name: String,
    pub nodes: Vec<Node>,
    pub connections: Vec<Connection>,
    pub settings: WorkflowSettings,
    pub active_version: Option<Ulid>,
}

pub struct Node {
    pub id: Ulid,
    pub node_type: NodeType,      // HTTP, Code, Transform, etc.
    pub parameters: Value,        // Configuration JSON-like
    pub position: (i32, i32),     // Pour l'UI
    pub credentials: Option<Ulid>, // Référence credential
}

pub struct Connection {
    pub from_node: Ulid,
    pub from_output: String,      // "main", "error", etc.
    pub to_node: Ulid,
    pub to_input: String,
}
```

#### B. Executor Async

```rust
pub struct FlowExecutor {
    graph: DirectedGraph<NodeId, EdgeId>,
    state: ExecutionState,
    context: ExecutionContext,
}

impl FlowExecutor {
    /// Execute le workflow en respectant le DAG
    pub async fn execute(&mut self, trigger_data: FlowData) -> Result<ExecutionResult> {
        // 1. Trouver les nœuds racines (triggers)
        let roots = self.graph.roots();
        
        // 2. Exécuter en parallèle quand possible (tokio)
        let mut futures = FuturesUnordered::new();
        
        for node_id in roots {
            futures.push(self.execute_node(node_id, trigger_data.clone()));
        }
        
        // 3. Propager les résultats aux nœuds suivants
        while let Some(result) = futures.next().await {
            let (node_id, output) = result?;
            for successor in self.graph.successors(node_id) {
                futures.push(self.execute_node(successor, output.clone()));
            }
        }
        
        Ok(self.state.finalize())
    }
}
```

#### C. Node Trait (Interface pour tous les nœuds)

```rust
#[async_trait]
pub trait FlowNode: Send + Sync {
    /// Nom technique du nœud
    fn name(&self) -> &'static str;
    
    /// Description pour l'UI
    fn description(&self) -> NodeDescription;
    
    /// Exécution principale
    async fn execute(
        &self,
        input: FlowData,
        params: &Value,
        context: &ExecutionContext,
    ) -> Result<FlowData>;
    
    /// Optionnel : polling périodique
    fn poll_interval(&self) -> Option<Duration> { None }
    
    /// Optionnel : webhook handler
    async fn webhook_handler(&self, _req: Request) -> Option<FlowData> { None }
}
```

#### D. FlowData (Zero-Copy)

```rust
/// Données circulant entre les nœuds - optimisé pour zero-copy
pub enum FlowData {
    /// Items JSON-like (cas général)
    Items(Vec<FlowItem>),
    
    /// Binary data (fichiers, images)
    Binary {
        data: Bytes,  // bytes::Bytes pour zero-copy
        mime_type: String,
        filename: Option<String>,
    },
    
    /// Stream pour gros volumes
    Stream(Box<dyn AsyncRead + Send>),
    
    /// Référence directe à lyxalkv (zero-copy total)
    KvRef(LyxalKvRef),
}

pub struct FlowItem {
    pub json: Value,          // serde_json::Value
    pub binary: Option<Bytes>,
    pub metadata: ItemMetadata,
}
```

---

## 3. Mapping n8n → Lyxal

### Tables de base de données

| Table n8n | → Table Lyxal | Notes |
|-----------|---------------|-------|
| `workflow_entity` | `lyxal_flow` | Schema simplifié |
| `execution_entity` | `lyxal_flow_execution` | Intégré au kernel |
| `execution_data` | `lyxal_flow_execution_data` | Stockage lyxalkv natif |
| `credentials_entity` | `lyxal_credential` | Chiffrement kernel |
| `webhook_entity` | `lyxal_webhook` | Fusionné avec routing |
| `user` | `lyxal_user` | Déjà existant |
| `project` | `lyxal_namespace` | Concept existant |

### Types de nœuds prioritaires

| Catégorie | Nœuds n8n | Équivalent Lyxal |
|-----------|-----------|------------------|
| **Core** | If, Switch, Merge, Set | `flow::logic::*` (Rust natif) |
| **Triggers** | Webhook, Schedule, Manual | `flow::trigger::*` |
| **HTTP** | HTTP Request | `flow::http::request` (reqwest) |
| **Data** | Code, Transform, Filter | `flow::transform::*` + WASM |
| **Database** | Postgres, MySQL, MongoDB | → LyxalQL natif direct ! |
| **Files** | Read/Write Binary | → lyxalkv natif |
| **Messaging** | Slack, Discord, Email | `flow::integrations::*` (priorité basse) |

### Intrinsics vs Extensions

```
┌─────────────────────────────────────────────────────────────┐
│                    INTRINSICS (Rust natif)                  │
│  Performance critique, sécurité maximale                    │
├─────────────────────────────────────────────────────────────┤
│ • HTTP Request/Response                                     │
│ • LyxalQL Query (lecture/écriture DB native)                │
│ • File operations (via lyxalkv)                             │
│ • Crypto (hash, sign, encrypt)                              │
│ • Logic (if, switch, merge, loop)                           │
│ • Transform (set, rename, filter)                           │
│ • Schedule/Cron                                             │
│ • Webhook receive                                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    EXTENSIONS (WASM sandbox)                │
│  Logique métier isolée, extensible par utilisateurs         │
├─────────────────────────────────────────────────────────────┤
│ • Custom code (JavaScript via QuickJS-WASM)                 │
│ • Intégrations tierces (Slack, Salesforce, etc.)            │
│ • Transformations complexes                                 │
│ • Modules verticaux (CRM actions, etc.)                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Plan d'implémentation

### Phase 1 : Core Engine (4-6 semaines)

- [ ] **Workflow Model** : Structures Rust pour workflows, nodes, connections
- [ ] **Graph Engine** : Parsing + validation DAG (petgraph)
- [ ] **Executor** : Exécution async avec tokio
- [ ] **Persistence** : Stockage workflows dans lyxalkv
- [ ] **Execution History** : Logging des exécutions

### Phase 2 : Triggers (2-3 semaines)

- [ ] **Manual Trigger** : Déclenchement via API
- [ ] **Schedule Trigger** : Cron avec tokio-cron
- [ ] **Webhook Trigger** : Réception HTTP

### Phase 3 : Intrinsics (4-5 semaines)

- [ ] **HTTP Node** : reqwest wrapper
- [ ] **LyxalQL Node** : Exécution queries natives
- [ ] **Logic Nodes** : If, Switch, Merge, SplitInBatches
- [ ] **Transform Nodes** : Set, Rename, Filter
- [ ] **File Nodes** : Read/Write via lyxalkv

### Phase 4 : WASM Extensions (3-4 semaines)

- [ ] **WASM Runtime** : wasmtime ou wasmer
- [ ] **Code Node** : JavaScript via QuickJS WASM
- [ ] **Extension API** : Interface pour créer des nœuds custom
- [ ] **Sandbox** : Isolation mémoire et CPU

### Phase 5 : UI Integration (2-3 semaines)

- [ ] **API REST** : CRUD workflows via Axum
- [ ] **RTC Updates** : Feedback temps réel des exécutions
- [ ] **Surrealist View** : Onglet "Automation"

---

## 5. Risques et défis

### 🔴 Risques majeurs

| Risque | Impact | Mitigation |
|--------|--------|------------|
| **Scope creep** | n8n a 350+ nœuds | Commencer par 20 nœuds critiques |
| **WASM complexity** | Isolation difficile | Utiliser wasmtime (mature) |
| **UI complexity** | Éditeur visuel = lourd | Réutiliser React Flow (Surrealist) |
| **Debuggabilité** | Rust plus complexe que JS | Tracing + logs structurés |

### 🟡 Défis techniques

| Défi | Solution proposée |
|------|-------------------|
| Zero-copy entre nœuds | `bytes::Bytes` + Arc |
| Annulation d'exécution | tokio CancellationToken |
| Retry/Error handling | Supervision pattern (actix-like) |
| Rate limiting | tower-governor |
| Secrets en mémoire | zeroize crate |

### 🟢 Avantages uniques Lyxal

| Avantage | Explication |
|----------|-------------|
| **LyxalQL natif** | Pas besoin de nœud "Database", c'est intégré |
| **lyxalkv natif** | Pas de serialization pour fichiers |
| **RTC natif** | Feedback temps réel sans WebSocket externe |
| **Auth native** | Credentials gérés par le kernel |
| **Single binary** | Déploiement trivial |

---

## Annexe : Dépendances Rust recommandées

```toml
[dependencies]
# Async runtime
tokio = { version = "1", features = ["full"] }

# Graph processing
petgraph = "0.6"

# HTTP client
reqwest = { version = "0.11", features = ["json"] }

# WASM runtime  
wasmtime = "15"

# Scheduling
tokio-cron-scheduler = "0.10"

# JSON
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Zero-copy bytes
bytes = "1"

# UUID/ULID
ulid = "1"

# Tracing
tracing = "0.1"
tracing-subscriber = "0.3"

# Error handling
thiserror = "1"
anyhow = "1"
```

---

## Ressources n8n à étudier

| Fichier n8n | Ce qu'il enseigne |
|-------------|-------------------|
| `packages/core/src/execution-engine/workflow-execute.ts` | Logique d'exécution DAG |
| `packages/@n8n/db/src/entities/` | Modèle de données |
| `packages/nodes-base/nodes/` | Structure des nœuds |
| `packages/workflow/src/` | Types et interfaces |

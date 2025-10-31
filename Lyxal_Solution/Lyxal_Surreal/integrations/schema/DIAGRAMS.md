# 📊 Diagrammes d'Architecture

Ce document contient des diagrammes visuels pour mieux comprendre l'architecture du module d'intégration.

---

## 🏗️ Vue d'ensemble : Hiérarchie Complète

```mermaid
graph TD
    A[Provider] -->|1:N| B[Service]
    B -->|1:N| C[Resource]
    C -->|1:N| D[Tool/Operation]
    D -->|1:N| E[Parameter]
    
    A -->|1:N| F[Credential Type]
    B -->|N:M| F
    
    B -->|1:N| G[Service Version]
    B -->|1:N| H[Error Mapping]
    B -->|1:N| I[Webhook Config]
    D -->|1:N| J[Response Mapping]
    
    style A fill:#ff6b6b
    style B fill:#4ecdc4
    style C fill:#45b7d1
    style D fill:#ffa07a
    style E fill:#98d8c8
    style F fill:#f7dc6f
    style G fill:#bb8fce
    style H fill:#f8b739
    style I fill:#85c1e2
    style J fill:#52b788
```

---

## 📦 Structure Core : Provider → Parameter

```mermaid
graph LR
    subgraph Provider Layer
        P[Provider<br/>Google, Slack, GitHub]
    end
    
    subgraph Service Layer
        S1[Google Sheets]
        S2[Google Ads]
        S3[Gmail]
    end
    
    subgraph Resource Layer
        R1[Sheet]
        R2[Spreadsheet]
        R3[Campaign]
    end
    
    subgraph Tool Layer
        T1[Append Row]
        T2[Read Rows]
        T3[Update Row]
    end
    
    subgraph Parameter Layer
        PA1[documentId]
        PA2[sheetName]
        PA3[dataMode]
    end
    
    P --> S1
    P --> S2
    P --> S3
    
    S1 --> R1
    S1 --> R2
    S2 --> R3
    
    R1 --> T1
    R1 --> T2
    R1 --> T3
    
    T1 --> PA1
    T1 --> PA2
    T1 --> PA3
    
    style P fill:#ff6b6b,stroke:#c44
    style S1 fill:#4ecdc4,stroke:#3aa
    style S2 fill:#4ecdc4,stroke:#3aa
    style S3 fill:#4ecdc4,stroke:#3aa
    style R1 fill:#45b7d1,stroke:#369
    style R2 fill:#45b7d1,stroke:#369
    style R3 fill:#45b7d1,stroke:#369
    style T1 fill:#ffa07a,stroke:#d77
    style T2 fill:#ffa07a,stroke:#d77
    style T3 fill:#ffa07a,stroke:#d77
    style PA1 fill:#98d8c8,stroke:#6a8
    style PA2 fill:#98d8c8,stroke:#6a8
    style PA3 fill:#98d8c8,stroke:#6a8
```

---

## 🔐 Système d'Authentification

```mermaid
graph TD
    A[Credential Type] --> B{Auth Type}
    
    B -->|OAuth2| C[OAuth2 Config]
    B -->|API Key| D[API Key Config]
    B -->|Basic Auth| E[Basic Auth Config]
    B -->|Custom| F[Custom Config]
    
    C --> G[auth_url<br/>token_url<br/>scope<br/>grant_type]
    
    D --> H[api_key<br/>header_name<br/>prefix]
    
    E --> I[username<br/>password]
    
    F --> J[custom_fields<br/>custom_logic]
    
    A --> K[Provider]
    A --> L[Service]
    
    style A fill:#f7dc6f
    style B fill:#e8daef
    style C fill:#aed6f1
    style D fill:#aed6f1
    style E fill:#aed6f1
    style F fill:#aed6f1
    style K fill:#ff6b6b
    style L fill:#4ecdc4
```

---

## 🎣 Système de Webhooks

```mermaid
graph LR
    A[Webhook Config] --> B[Service]
    
    A --> C{Event Type}
    C --> D[push]
    C --> E[pull_request]
    C --> F[message]
    C --> G[payment_intent]
    
    A --> H{Validation}
    H --> I[Signature<br/>HMAC-SHA256]
    H --> J[Required<br/>Headers]
    H --> K[Challenge<br/>Response]
    
    A --> L[HTTP Method<br/>POST/GET]
    
    style A fill:#85c1e2
    style B fill:#4ecdc4
    style C fill:#f8b739
    style H fill:#52b788
```

---

## 🔄 Gestion des Versions

```mermaid
graph TD
    A[Service] -->|has| B[Service Version]
    
    B --> C{Version 1.0}
    B --> D{Version 2.0}
    B --> E{Version 3.0}
    B --> F{Version 4.7 DEFAULT}
    
    C --> G[is_deprecated: true]
    D --> H[is_deprecated: false]
    E --> I[is_deprecated: false]
    F --> J[is_default: true<br/>is_deprecated: false]
    
    C --> K[Breaking Changes]
    K --> L[- Auth change<br/>- Endpoint rename<br/>- Required params]
    
    style A fill:#4ecdc4
    style B fill:#bb8fce
    style F fill:#52b788,stroke:#2a7
    style G fill:#e74c3c
    style H fill:#f39c12
    style I fill:#f39c12
    style J fill:#27ae60
```

---

## ⚠️ Gestion des Erreurs

```mermaid
graph TD
    A[Error Mapping] --> B[Service]
    
    A --> C{HTTP Status}
    C --> D[401 Unauthorized]
    C --> E[403 Forbidden]
    C --> F[404 Not Found]
    C --> G[429 Rate Limit]
    C --> H[500 Server Error]
    
    D --> I[severity: error<br/>is_retryable: false]
    E --> J[severity: error<br/>is_retryable: false]
    F --> K[severity: error<br/>is_retryable: false]
    G --> L[severity: warning<br/>is_retryable: true]
    H --> M[severity: error<br/>is_retryable: true]
    
    L --> N[Recommended Action<br/>Wait 60s + exponential backoff]
    
    style A fill:#f8b739
    style B fill:#4ecdc4
    style I fill:#e74c3c
    style J fill:#e74c3c
    style K fill:#e74c3c
    style L fill:#f39c12
    style M fill:#e67e22
```

---

## 📊 Exemple Complet : Google Sheets

```mermaid
graph TD
    subgraph Provider
        P[Google<br/>api_base_url: googleapis.com<br/>support_oauth2: true]
    end
    
    subgraph Service
        S[Google Sheets<br/>version: 4.7<br/>categories: Data & Storage]
    end
    
    subgraph Resources
        R1[Sheet Within Document]
        R2[Spreadsheet]
    end
    
    subgraph Tools
        T1[Append Row<br/>POST /values:append]
        T2[Read Rows<br/>GET /values]
        T3[Update Row<br/>PUT /values]
        T4[Delete Row<br/>DELETE /values]
    end
    
    subgraph Parameters
        PA1[documentId<br/>type: resourceLocator<br/>required: true]
        PA2[sheetName<br/>type: resourceLocator<br/>required: true]
        PA3[dataMode<br/>type: options<br/>default: autoMapInputData]
    end
    
    subgraph Auth
        AUTH[Google Sheets OAuth2<br/>scope: spreadsheets, drive]
    end
    
    P --> S
    S --> R1
    S --> R2
    R1 --> T1
    R1 --> T2
    R1 --> T3
    R1 --> T4
    T1 --> PA1
    T1 --> PA2
    T1 --> PA3
    P --> AUTH
    S -.uses.-> AUTH
    
    style P fill:#ff6b6b
    style S fill:#4ecdc4
    style R1 fill:#45b7d1
    style R2 fill:#45b7d1
    style T1 fill:#ffa07a
    style T2 fill:#ffa07a
    style T3 fill:#ffa07a
    style T4 fill:#ffa07a
    style PA1 fill:#98d8c8
    style PA2 fill:#98d8c8
    style PA3 fill:#98d8c8
    style AUTH fill:#f7dc6f
```

---

## 🌐 Exemple Complet : Slack

```mermaid
graph TD
    subgraph Provider
        P[Slack<br/>api_base_url: slack.com/api<br/>support_oauth2: true]
    end
    
    subgraph Service
        S[Slack<br/>version: 2.3<br/>is_trigger: true<br/>is_webhook: true]
    end
    
    subgraph Resources
        R1[Channel]
        R2[Message]
        R3[File]
        R4[User]
        R5[Reaction]
    end
    
    subgraph Tools Message
        T1[Post Message<br/>POST /chat.postMessage]
        T2[Update Message<br/>POST /chat.update]
        T3[Delete Message<br/>POST /chat.delete]
        T4[Search Messages<br/>GET /search.messages]
    end
    
    subgraph Tools Channel
        T5[Create Channel<br/>POST /conversations.create]
        T6[List Channels<br/>GET /conversations.list]
        T7[Invite to Channel<br/>POST /conversations.invite]
    end
    
    subgraph Webhooks
        W1[Message Event]
        W2[Reaction Added Event]
    end
    
    P --> S
    S --> R1
    S --> R2
    S --> R3
    S --> R4
    S --> R5
    
    R2 --> T1
    R2 --> T2
    R2 --> T3
    R2 --> T4
    
    R1 --> T5
    R1 --> T6
    R1 --> T7
    
    S --> W1
    S --> W2
    
    style P fill:#ff6b6b
    style S fill:#4ecdc4
    style R1 fill:#45b7d1
    style R2 fill:#45b7d1
    style R3 fill:#45b7d1
    style R4 fill:#45b7d1
    style R5 fill:#45b7d1
    style W1 fill:#85c1e2
    style W2 fill:#85c1e2
```

---

## 🎨 Types de Paramètres

```mermaid
graph LR
    A[Parameter Types] --> B[Simple Types]
    A --> C[Complex Types]
    A --> D[Special Types]
    
    B --> E[string]
    B --> F[number]
    B --> G[boolean]
    B --> H[date/datetime]
    
    C --> I[object]
    C --> J[array]
    C --> K[json]
    
    D --> L[options<br/>dropdown]
    D --> M[multiOptions<br/>checkboxes]
    D --> N[resourceLocator<br/>list/url/id]
    D --> O[file<br/>upload]
    D --> P[hidden<br/>secrets]
    
    style A fill:#f8b739
    style B fill:#aed6f1
    style C fill:#aed6f1
    style D fill:#98d8c8
    style N fill:#52b788,stroke:#2a7
```

---

## 🔄 Resource Locator Pattern

```mermaid
graph TD
    A[Resource Locator<br/>Ex: documentId, channel] --> B{Selection Mode}
    
    B --> C[List Mode]
    B --> D[URL Mode]
    B --> E[ID Mode]
    
    C --> F[Dropdown avec<br/>autocomplete<br/>Facile pour débutants]
    
    D --> G[Paste URL<br/>Ex: https://docs.google.com/.../123<br/>Auto-extraction ID]
    
    E --> H[Saisie directe ID<br/>Ex: 123456<br/>Pour experts/automation]
    
    F --> I[API: listSearch method]
    G --> J[Regex: extractValue]
    H --> K[Validation: regex pattern]
    
    style A fill:#52b788
    style B fill:#f8b739
    style C fill:#aed6f1
    style D fill:#aed6f1
    style E fill:#aed6f1
    style F fill:#98d8c8
    style G fill:#98d8c8
    style H fill:#98d8c8
```

---

## 📈 Flow : Exécution d'un Tool

```mermaid
sequenceDiagram
    participant UI as Interface Utilisateur
    participant DB as Base de Données
    participant AUTH as Auth Service
    participant API as External API
    
    UI->>DB: Sélectionner Provider
    DB-->>UI: Liste Providers
    
    UI->>DB: Sélectionner Service
    DB-->>UI: Services du Provider
    
    UI->>DB: Sélectionner Resource
    DB-->>UI: Resources du Service
    
    UI->>DB: Sélectionner Tool
    DB-->>UI: Tool + Parameters
    
    UI->>DB: Récupérer Credential Types
    DB-->>UI: OAuth2, API Key, etc.
    
    UI->>AUTH: Authenticate
    AUTH-->>UI: Access Token
    
    UI->>DB: Build Request<br/>(endpoint, params, body)
    DB-->>UI: Request Config
    
    UI->>API: HTTP Request<br/>(with auth + params)
    
    alt Success Response
        API-->>UI: 200 OK + Data
        UI->>DB: Get Response Mapping
        DB-->>UI: JSON paths, transforms
        UI->>UI: Transform Response
    else Error Response
        API-->>UI: 4xx/5xx Error
        UI->>DB: Get Error Mapping
        DB-->>UI: Normalized Message + Action
        UI->>UI: Display Error + Recommended Action
    end
```

---

## 🎯 Pattern : Single Service vs Multi Service

```mermaid
graph TD
    subgraph Single Service Pattern
        A1[Slack Provider] --> B1[Slack Service]
        B1 --> C1[Channel]
        B1 --> C2[Message]
        B1 --> C3[File]
        B1 --> C4[User]
    end
    
    subgraph Multi Service Pattern
        A2[Google Provider] --> B2[Google Sheets]
        A2 --> B3[Google Ads]
        A2 --> B4[Google Calendar]
        A2 --> B5[Gmail]
        A2 --> B6[Google Drive]
        
        B2 --> C5[Sheet]
        B3 --> C6[Campaign]
        B4 --> C7[Event]
        B5 --> C8[Message]
        B6 --> C9[File]
    end
    
    style A1 fill:#ff6b6b
    style B1 fill:#4ecdc4
    style A2 fill:#ff6b6b
    style B2 fill:#4ecdc4
    style B3 fill:#4ecdc4
    style B4 fill:#4ecdc4
    style B5 fill:#4ecdc4
    style B6 fill:#4ecdc4
```

---

## 🔍 Data Flow : Query Construction

```mermaid
flowchart TD
    START([User Selects Tool]) --> A[Fetch Tool Details]
    A --> B[Fetch Parameters]
    B --> C[Fetch Resource Info]
    C --> D[Fetch Service Info]
    D --> E[Fetch Provider Info]
    E --> F[Fetch Credentials]
    
    F --> G{Build Request}
    
    G --> H[Interpolate Endpoint<br/>Replace {variables}]
    H --> I[Add Auth Headers/Params]
    I --> J[Build Request Body<br/>from parameters]
    J --> K[Apply Rate Limiting]
    
    K --> L{Execute Request}
    
    L -->|Success| M[Get Response Mapping]
    M --> N[Transform Response<br/>Using JSON Paths]
    N --> O[Return Formatted Data]
    
    L -->|Error| P[Get Error Mapping]
    P --> Q{Is Retryable?}
    Q -->|Yes| R[Retry with Backoff]
    R --> L
    Q -->|No| S[Return Normalized Error]
    
    O --> END([Complete])
    S --> END
    
    style START fill:#52b788
    style G fill:#f8b739
    style L fill:#f8b739
    style Q fill:#f39c12
    style END fill:#52b788
```

---

## 📊 Architecture Modulaire

```mermaid
graph TB
    subgraph Core Module
        A[Provider Management]
        B[Service Management]
        C[Resource Management]
        D[Tool Management]
        E[Parameter Management]
    end
    
    subgraph Auth Module
        F[Credential Types]
        G[OAuth2 Handler]
        H[API Key Handler]
        I[Token Manager]
    end
    
    subgraph Execution Module
        J[Request Builder]
        K[HTTP Client]
        L[Response Transformer]
        M[Error Handler]
    end
    
    subgraph Config Module
        N[Webhooks]
        O[Versioning]
        P[Rate Limiting]
        Q[Error Mapping]
    end
    
    subgraph Extension Module
        R[Monitoring]
        S[Analytics]
        T[Audit Log]
        U[Permissions]
    end
    
    A --> J
    B --> J
    C --> J
    D --> J
    E --> J
    
    F --> G
    F --> H
    G --> I
    H --> I
    
    J --> K
    K --> L
    K --> M
    
    N --> K
    O --> B
    P --> K
    Q --> M
    
    K --> R
    K --> S
    A -.-> T
    B -.-> T
    C -.-> T
    D -.-> T
    
    style A fill:#ff6b6b
    style B fill:#4ecdc4
    style C fill:#45b7d1
    style D fill:#ffa07a
    style E fill:#98d8c8
```

---

## 🎓 Exemple Use Case : Workflow Complet

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant Backend
    participant Database
    participant GoogleAPI as Google Sheets API
    participant SlackAPI as Slack API
    
    Note over User,SlackAPI: Scenario: When form submitted → Add to Sheet → Notify Slack
    
    User->>Frontend: Submit Form
    
    Frontend->>Backend: Trigger Workflow
    
    Backend->>Database: Get Tool: "Append Row"
    Database-->>Backend: Tool + Parameters + Credentials
    
    Backend->>Database: Get OAuth2 Token for Google
    Database-->>Backend: Access Token
    
    Backend->>GoogleAPI: POST /spreadsheets/123/values:append<br/>Auth: Bearer {token}<br/>Body: {row data}
    
    alt Success
        GoogleAPI-->>Backend: 200 OK
        Backend->>Database: Get Response Mapping
        Database-->>Backend: Success transform
        
        Backend->>Database: Get Tool: "Post Message"
        Database-->>Backend: Tool + Parameters
        
        Backend->>SlackAPI: POST /chat.postMessage<br/>channel: #notifications<br/>text: "New form submission!"
        
        SlackAPI-->>Backend: 200 OK
        Backend-->>Frontend: Workflow Complete ✅
        Frontend-->>User: Success Notification
        
    else Rate Limited
        GoogleAPI-->>Backend: 429 Too Many Requests
        Backend->>Database: Get Error Mapping (429)
        Database-->>Backend: is_retryable: true, wait: 60s
        Backend->>Backend: Wait 60s
        Backend->>GoogleAPI: Retry Request
        
    else Authentication Error
        GoogleAPI-->>Backend: 401 Unauthorized
        Backend->>Database: Get Error Mapping (401)
        Database-->>Backend: is_retryable: false
        Backend-->>Frontend: Auth Error ❌
        Frontend-->>User: "Please reconnect Google account"
    end
```

---

## 🎯 Conclusion

Ces diagrammes illustrent :

✅ **Hiérarchie claire** : Provider → Service → Resource → Tool → Parameter  
✅ **Modularité** : Chaque composant a sa responsabilité  
✅ **Flexibilité** : Support de multiples patterns (auth, webhooks, versioning)  
✅ **Robustesse** : Gestion d'erreurs, retry logic, rate limiting  
✅ **Scalabilité** : Architecture extensible avec metadata

Cette architecture est prête pour supporter **n'importe quel provider** avec **n'importe quel type d'API**.

---

**Note** : Ces diagrammes sont en format Mermaid et peuvent être visualisés dans :
- GitHub/GitLab (rendu automatique)
- VS Code (avec extension Mermaid)
- Documentation sites (MkDocs, Docusaurus, etc.)
- Outils dédiés (Mermaid Live Editor)


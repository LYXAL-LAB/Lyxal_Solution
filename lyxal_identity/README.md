# Lyxal Identity

Lyxal Identity is a high-performance, modular Identity Provider (IdP) written in Rust. It is inspired by the architecture of [Logto](https://github.com/logto-io/logto) and designed to provide a robust, scalable, and secure solution for authentication and authorization.

## 🏗 Architecture

The project is structured as a Cargo Workspace, separating concerns into specialized crates:

- **`lyxal_core`**: The foundation. Contains shared utilities, database connection pooling (SQLx), cryptography (Argon2id), and centralized error handling.
- **`lyxal_schema`**: Shared data models and types used across the workspace. Includes SQLx mapping for database entities.
- **`lyxal_auth`**: Core authentication logic (Password, Social Login, Magic Links).
- **`lyxal_oauth`**: OAuth 2.0 and OpenID Connect (OIDC) implementation.
- **`lyxal_iam`**: Identity and Access Management. Handles Users, Applications, and Tenants lifecycle.
- **`lyxal_rbac`**: Role-Based Access Control. Manages permissions, roles, and scope validation.
- **`lyxal_mfa`**: Multi-Factor Authentication (TOTP, Backup Codes).
- **`lyxal_session`**: Session management and interaction state tracking.
- **`lyxal_connectors`**: Extensible system for third-party integrations (Email, SMS, Social Providers).

## 🚀 Getting Started

### Prerequisites

- [Rust](https://www.rust-lang.org/) (Edition 2021)
- [PostgreSQL](https://www.postgresql.org/) (Version 12+)
- [SQLx CLI](https://github.com/launchbadge/sqlx/tree/main/sqlx-cli) (for migrations)

### Environment Setup

Create a `.env` file in the root directory:

```ini
# Database
DATABASE_URL=postgres://username:password@localhost:5432/lyxal_db

# Server Configuration
LYXAL_HOST=0.0.0.0
LYXAL_PORT=3000
LYXAL_LOG_LEVEL=info

# Security
LYXAL_SECRET_KEY=your_super_secret_key_at_least_32_chars
TOKEN_EXPIRATION_HOURS=24
```

### Running the Project

1. **Database Migrations**:
   ```bash
   sqlx database setup
   ```

2. **Build**:
   ```bash
   cargo build
   ```

3. **Run**:
   ```bash
   cargo run
   ```

## 🛠 Tech Stack

- **Framework**: [Axum](https://github.com/tokio-rs/axum)
- **Async Runtime**: [Tokio](https://tokio.rs/)
- **Database / ORM**: [SQLx](https://github.com/launchbadge/sqlx) (PostgreSQL)
- **Serialization**: [Serde](https://serde.rs/)
- **Cryptography**: [Argon2](https://github.com/RustCrypto/password-hashes), [JsonWebToken](https://github.com/Keats/jsonwebtoken)
- **Error Handling**: [thiserror](https://github.com/dtolnay/thiserror), [anyhow](https://github.com/dtolnay/anyhow)

## 🗺 Roadmap

The development is divided into 8 major phases:
1. **Phase 1**: Foundations & Core Logic (Complete)
2. **Phase 2**: Identity Management (IAM) (In Progress)
3. **Phase 3**: Auth & Sessions
4. **Phase 4**: RBAC & Permissions
5. **Phase 5**: OAuth2 & OIDC Implementation
6. **Phase 7**: MFA & Advanced Security
7. **Phase 7**: Connectors Ecosystem
8. **Phase 8**: Management API & UI

## 📄 License

This project is licensed under the **MPL-2.0 License**.
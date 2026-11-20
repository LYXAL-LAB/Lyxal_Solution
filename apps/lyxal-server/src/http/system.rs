//! Routes d'administration de l'installation : modules hébergés et nœuds vivants
//! (`/system/modules`), liste des migrations interrompues et décision de reprise ou d'abandon
//! (`/system/migrations/*`) (`lyxal_runtime`).
//!
//! `lyxal_runtime` est sous `lyxal_auth` dans la hiérarchie : ses fonctions ne contrôlent aucun
//! droit et ses tables ne sont lisibles que par la session système. L'hôte identifie donc
//! l'appelant par son jeton d'accès (`Authorization: Bearer`), demande à `lyxal_auth`, sur une
//! session SurrealDB au nom de l'appelant, s'il détient le droit d'administration de
//! l'installation (`server.installation.manage`, déclaré par l'hôte et attribué au rôle
//! `platform_admin`), puis seulement appelle le runtime sur la session système. L'auteur de la
//! décision (identité ou application de l'appelant) est gardé avec elle et au journal du runtime.
//!
//! Réponses au contrat `LyxalResult` (`{ ok, data, error }`), `Cache-Control: no-store`. Un corps
//! ou un paramètre illisible rend `SERVER_INVALID_REQUEST` ; un refus du runtime rend son code
//! `RUNTIME_*` (message générique, sans détail interne).

use super::auth::{self, ok, ApiError, ApiResult};
use crate::context::AppContext;
use crate::error::ServerError;
use axum::body::Bytes;
use axum::extract::{Query, State};
use axum::http::{HeaderMap, StatusCode};
use axum::response::Response;
use lyxal_auth::AuthError;
use lyxal_runtime::migration::{
    MigrationInterruptedParams, MigrationResolveAction, MigrationResolveParams,
};
use lyxal_runtime::ModuleState;
use lyxal_surreal::{SurrealValue, ToSql};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::HashMap;

/// Droit d'administration de l'installation (`seeds/server_permissions.surql`).
pub const INSTALLATION_PERMISSION: &str = "server.installation.manage";

/// Requête illisible (corps, paramètre) : `SERVER_INVALID_REQUEST`, sans reprendre la donnée
/// reçue.
fn invalid(what: &str) -> ApiError {
    ApiError::Server(ServerError::InvalidRequest {
        message: what.to_string(),
    })
}

fn database(error: surrealdb::Error) -> ApiError {
    ApiError::Server(ServerError::Database {
        message: format!("contrôle du droit d'administration : {error}"),
    })
}

/// Auteur de la requête, s'il détient le droit d'administration de l'installation : identifiant
/// de son identité, ou de son application pour un compte de service.
async fn administrator(context: &AppContext, headers: &HeaderMap) -> Result<String, ApiError> {
    let (caller, session) = auth::caller_session(context, headers).await?;
    let mut response = session
        .query("RETURN fn::auth_has_permission({ permission: $permission });")
        .bind(("permission", INSTALLATION_PERMISSION))
        .await
        .map_err(database)?;
    let allowed: Option<bool> = response.take(0).map_err(database)?;
    if allowed != Some(true) {
        return Err(ApiError::Auth(AuthError::Rejected(
            "AUTH_PERMISSION_DENIED",
        )));
    }
    Ok(caller
        .identity
        .or(caller.application)
        .unwrap_or(caller.session)
        .to_sql())
}

fn data<T: SurrealValue>(value: T) -> Value {
    value.into_value().into_json_value()
}

/// Exécute une route et rend sa réponse ou son erreur, jamais mise en cache.
async fn respond(context: &AppContext, headers: &HeaderMap, result: ApiResult) -> Response {
    auth::no_store(auth::respond(context, headers, result).await).await
}

/// Module hébergé par ce processus et son état.
#[derive(Serialize)]
struct ModuleStatus {
    id: String,
    name: String,
    version: String,
    state: Option<ModuleState>,
}

/// Nœud vivant de la base (`runtime_node`, battement récent), quel que soit son hôte.
#[derive(Serialize)]
struct NodeStatus {
    node_id: String,
    host: String,
    /// Modules démarrés par le nœud.
    modules: Vec<String>,
    started_at: Value,
    seen_at: Value,
    /// Le nœud est ce processus.
    current: bool,
}

/// `GET /system/modules` : `{ host, node_id, modules, nodes }` — hôte et nœud de ce processus,
/// modules qu'il héberge et leur état, nœuds vivants de la base (tous hôtes, du battement le plus
/// récent au plus ancien).
pub async fn modules(
    State(context): State<AppContext>,
    Query(query): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        administrator(&context, &headers).await?;
        if !query.is_empty() {
            return Err(invalid("paramètre d'adresse inconnu"));
        }
        let runtime = &context.runtime;
        let mut modules: Vec<ModuleStatus> = runtime
            .modules()
            .iter()
            .map(|module| {
                let descriptor = module.descriptor();
                ModuleStatus {
                    id: descriptor.id.to_string(),
                    name: descriptor.name.clone(),
                    version: descriptor.version.to_string(),
                    state: runtime.module_state(&descriptor.id),
                }
            })
            .collect();
        modules.sort_by(|a, b| a.id.cmp(&b.id));
        let current = runtime.node_id().to_string();
        let nodes: Vec<NodeStatus> = runtime
            .nodes()
            .await
            .map_err(ServerError::Runtime)?
            .into_iter()
            .filter(|node| node.alive == Some(true))
            .map(|node| NodeStatus {
                current: node.node_id == current,
                node_id: node.node_id,
                host: node.host,
                modules: node.modules,
                started_at: data(node.started_at),
                seen_at: data(node.seen_at),
            })
            .collect();
        ok(
            StatusCode::OK,
            json!({
                "host": runtime.host_id().to_string(),
                "node_id": current,
                "modules": modules,
                "nodes": nodes,
            }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

/// `GET /system/migrations/interrupted[?module=<module>]`.
pub async fn migrations_interrupted(
    State(context): State<AppContext>,
    Query(mut query): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        administrator(&context, &headers).await?;
        let module = query.remove("module");
        if !query.is_empty() {
            return Err(invalid("paramètre d'adresse inconnu"));
        }
        let migrations = context
            .runtime
            .interrupted_migrations(MigrationInterruptedParams { module })
            .await
            .map_err(ServerError::Runtime)?;
        ok(StatusCode::OK, data(migrations))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct ResolveBody {
    module: String,
    migration: String,
    action: String,
    reason: String,
}

/// `POST /system/migrations/resolve` : `{ module, migration, action, reason }`.
pub async fn migrations_resolve(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let actor = administrator(&context, &headers).await?;
        let body: ResolveBody = serde_json::from_slice(&bytes)
            .map_err(|_| invalid("corps de la requête : objet JSON attendu"))?;
        let action = MigrationResolveAction::parse(&body.action)
            .ok_or_else(|| invalid("action : retry ou abandon attendu"))?;
        let resolved = context
            .runtime
            .resolve_migration(MigrationResolveParams {
                module: body.module,
                migration: body.migration,
                action,
                reason: body.reason,
                actor,
            })
            .await
            .map_err(ServerError::Runtime)?;
        ok(StatusCode::OK, data(resolved))
    }
    .await;
    respond(&context, &headers, result).await
}

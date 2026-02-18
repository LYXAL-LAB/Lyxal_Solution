### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
#![deny(unused_crate_dependencies)]
mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state;
mod log_span;
mod organisation;
mod resolve;
mod webhooks;
mod workspace;
use json_subscriber::fmt;
use std::{io::Result, time::Duration};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::bad_argument;

use actix_files::Files;
use actix_web::{
App, HttpRequest, HttpResponse, HttpServer,
middleware::{Compress, Condition},
web::{self, Data, PathConfig, QueryConfig, get, scope},
};
use lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config::api::*;
use lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform::api::*;
use lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
use lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend::types::{Envs as UIEnvs, SsrSharedHttpRequestHeaders};
use idgenerator::{IdGeneratorOptions, IdInstance};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
use lyx-core-actix::{LeptosRoutes, generate_route_list};
use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
aws::kms,
helpers::{get_from_env_or_default, get_from_env_unsafe},
middlewares::{
auth_n::AuthNHandler,
auth_z::{AuthZHandler, AuthZManager},
request_response_logging::RequestResponseLogger,
workspace_context::OrgWorkspaceMiddlewareFactory,
},
service::types::{AppEnv, Resource},
};
use tracing_actix_web::TracingLogger;
use tracing_subscriber::{EnvFilter, layer::SubscriberExt, util::SubscriberInitExt};

use crate::log_span::CustomRootSpanBuilder;

pub fn use_request_headers() -> Option<SsrSharedHttpRequestHeaders> {
use_context::<HttpRequest>().map(|req| {
let headers = req.headers();
let cookie = headers
.get("Cookie")
.and_then(|h| h.to_str().ok().map(String::from));

SsrSharedHttpRequestHeaders { cookie }
})
}

#[actix_web::get("favicon.ico")]
async fn favicon(
lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: actix_web::web::Data<lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions>,
) -> actix_web::Result<actix_files::NamedFile> {
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.into_inner();
let site_root = &lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_root;
Ok(actix_files::NamedFile::open(format!(
"{site_root}/favicon.ico"
))?)
}

#[actix_web::main]
async fn main() -> Result<()> {
dotenv::dotenv().ok();
// Initialize tracing subscriber with custom JSON formatter
tracing_subscriber::registry()
.with(EnvFilter::from_default_env())
.with(
fmt::layer()
.with_current_span(true)
.flatten_current_span_on_top_level(true)
.flatten_event(true)
.with_span_list(false)
.with_target(false),
)
.init();

let service_prefix: String =
get_from_env_unsafe("SERVICE_PREFIX").expect("SERVICE_PREFIX is not set");

let worker_id: u32 = get_from_env_unsafe("WORKER_ID").expect("WORKER_ID is not set");

let options = IdGeneratorOptions::new()
.worker_id(worker_id)
.worker_id_bit_len(8)
.seq_bit_len(12);

IdInstance::init(options).expect("Failed to initialize ID generator");

/*
Reading from a env returns a String at best we cannot obtain a &'static str from it,
which seems logical as it not known at compiletime, and there is no straightforward way to do this.

Leptos' Router component base prop type is &'static str, since service_prefix is of String type
we cannot give this as base value.

This can be solved, if somehow we can tell rust that this String is going to live for entirety of the process,
here comes Box::leak() to our rescue, which keeps the value in the memory for the entire process lifetime,
this also enables to borrow the String value as &'static str .
*/
let service_prefix_str: &'static str = Box::leak(service_prefix.into_boxed_str());
let base = match service_prefix_str {
"" | "/" => "".to_owned(),
prefix => "/".to_owned() + prefix,
};

let cac_port: u16 = get_from_env_unsafe("PORT").unwrap_or(8080);

/* Frontend configurations */
let ui_redirect_path = format!("{}/admin/organisations", base);

let ui_envs = UIEnvs {
service_prefix: service_prefix_str,
host: get_from_env_or_default("API_HOSTNAME", String::new()),
};

let routes_ui_envs = ui_envs.clone();

let conf = get_configuration(Some("Cargo.toml")).await.unwrap();
// Generate the list of routes in your Leptos App
let routes = generate_route_list(move || {
view! { <App lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_envs=routes_ui_envs.clone() /> }
});

let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env = get_from_env_unsafe("APP_ENV").expect("APP_ENV is not set");
let kms_lyx-core-lyx_core_lyx-core-lyx_core_client = match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
AppEnv::DEV | AppEnv::TEST => None,
_ => Some(kms::new_lyx-core-lyx_core_lyx-core-lyx_core_client().await),
};

let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = Data::new(
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state::get(
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env,
cac_port,
&kms_lyx-core-lyx_core_lyx-core-lyx_core_client,
service_prefix_str.to_owned(),
&base,
)
.await,
);

let auth_n = AuthNHandler::init(&kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, base.clone()).await;
let auth_z = AuthZHandler::init(&kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await;
let auth_z_manager = AuthZManager::init(&kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await;

HttpServer::new(move || {
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = &conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
let site_root = &lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_root;
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_envs = ui_envs.clone();
App::new()
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clone())
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(PathConfig::default().error_handler(|err, _| bad_argument!(err).into()))
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(QueryConfig::default().error_handler(|err, _| bad_argument!(err).into()))
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(
lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.to_owned(),
routes.to_owned(),
move || {
provide_context(use_request_headers());
view! { <App lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_envs=lyx-core-lyx_core_lyx-core-lyx_core_leptos_envs.clone() /> }
},
)
.service(
scope(&base)
.route(
"/health",
get().to(|| async { HttpResponse::Ok().body("Health is good :D") }),
)
.service(auth_n.routes())
.service(auth_n.org_routes())
.service(web::redirect("", ui_redirect_path.to_string()))
.service(web::redirect("/", ui_redirect_path.to_string()))
.service(web::redirect("/admin", ui_redirect_path.to_string()))
.service(web::redirect("/admin/", ui_redirect_path.to_string()))
.service(web::redirect("/admin/{org_id}/", "workspaces"))
.service(web::redirect("/admin/{org_id}/{tenant}/", "default-config"))
/***************************** V1 Routes *****************************/
.service(
scope("/context")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Context)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(context::endpoints()),
)
.service(
scope("/dimension")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Dimension)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(dimension::endpoints()),
)
.service(
scope("/default-config")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::DefaultConfig)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(default_config::endpoints()),
)
.service(
scope("/config")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Config)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(config::endpoints()),
)
.service(
scope("/audit")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::AuditLog)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(audit_log::endpoints()),
)
.service(
scope("/function")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Function)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(functions::endpoints()),
)
.service(
scope("/types")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::TypeTemplate)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(type_templates::endpoints()),
)
.service(
experiments::endpoints(scope("/experiments"))
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Experiment)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true)),
)
.service(
experiment_groups::endpoints(scope("/experiment-groups"))
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::ExperimentGroup)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
)
.service(
scope("/lyx-core-lyx_core_lyx-core-lyx_core_superposition/organisations")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Organisation)
.wrap(OrgWorkspaceMiddlewareFactory::new(false, false))
.service(organisation::endpoints()),
)
.service(workspace::endpoints(scope("/workspaces"))
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Workspace)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, false))
)
.service(
scope("/webhook")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Webhook)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(webhooks::endpoints()),
)
.service(
scope("/variables")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Variable)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(variables::endpoints())
)
.service(
scope("/resolve")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Config)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(resolve::endpoints()),
)
.service(
scope("/auth")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Auth)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(auth_z_manager.clone()))
.service(auth_z_manager.endpoints())
)
.service(
scope("/master-encryption-key")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::MasterEncryptionKey)
.wrap(OrgWorkspaceMiddlewareFactory::new(false, false))
.service(secrets::master_key_endpoints())
)
.service(
scope("/secrets")
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Secret)
.wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
.service(secrets::endpoints())
)
/***************************** UI Routes ******************************/
.route("/fxn/{tail:.*}", lyx-core-actix::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns())
// serve JS/WASM/CSS from `pkg`
.service(Files::new("/pkg", format!("{site_root}/pkg")))
// serve other assets from the `assets` directory
.service(Files::new("/assets", site_root.to_string()))
// serve the favicon from /favicon.ico
)
.route(
"/health",
get().to(|| async { HttpResponse::Ok().body("Health is good :D") }),
)
.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.to_owned()))
// Auth middlewares are innermost so outer middlewares still run on auth failures.
// Note: in actix-web, the last `.wrap()` runs first on requests.
.wrap(auth_z.clone())
.wrap(auth_n.clone())
.wrap(
actix_web::middleware::DefaultHeaders::new()
.add(("X-SERVER-VERSION", lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.cac_version.to_string()))
.add(("Cache-Control", "no-store".to_string()))
)
.wrap(Condition::new(
matches!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, AppEnv::PROD | AppEnv::SANDBOX),
Compress::default(),
))
// Conditionally add request/response logging middleware for development
.wrap(RequestResponseLogger)
.wrap(TracingLogger::<CustomRootSpanBuilder>::new())
})
.bind(("0.0.0.0", cac_port))?
.workers(get_from_env_or_default("ACTIX_WORKER_COUNT", 5))
.keep_alive(Duration::from_secs(
get_from_env_unsafe("ACTIX_KEEP_ALIVE").unwrap_or(120),
))
.run()
.await
}

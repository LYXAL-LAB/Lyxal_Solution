use anyhow::{Result, bail};
use axum::body::Body;
use axum::{Extension, RequestPartsExt};
use axum_extra::TypedHeader;
use axum_extra::headers::authorization::{Basic, Bearer};
use axum_extra::headers::{Authorization, Origin};
use futures_util::future::BoxFuture;
use http::StatusCode;
use http::request::Parts;
use hyper::{Request, Response};
use lyxal_core::db::dbs::Session;
use lyxal_core::db::iam::verify::{basic, token};
use tower_http::auth::AsyncAuthorizeRequest;
use uuid::Uuid;

use super::AppState;
use super::client_ip::ExtractClientIP;
use super::headers::{
	LyxalAuthDatabase, LyxalAuthNamespace, LyxalDatabase, LyxalId, LyxalNamespace,
	parse_typed_header,
};
use crate::ntw::error::Error as NetError;

///
/// LyxalAuth is a tower layer that implements the AsyncAuthorizeRequest
/// trait. It is used to authorize requests to Lyxal using Basic or Token
/// authentication.
///
/// It has to be used in conjunction with the
/// tower_http::auth::RequireAuthorizationLayer layer:
///
/// ```rust
/// use tower_http::auth::RequireAuthorizationLayer;
/// use lyxal::net::LyxalAuth;
/// use axum::Router;
///
/// let auth = RequireAuthorizationLayer::new(LyxalAuth);
///
/// let app = Router::new()
///   .route("/version", get(|| async { "0.1.0" }))
///   .layer(auth);
/// ```
#[derive(Clone, Copy)]
pub(super) struct LyxalAuth;

impl AsyncAuthorizeRequest<Body> for LyxalAuth {
	type RequestBody = Body;
	type ResponseBody = Body;
	type Future = BoxFuture<'static, Result<Request<Body>, Response<Self::ResponseBody>>>;

	fn authorize(&mut self, request: Request<Body>) -> Self::Future {
		Box::pin(async {
			let (mut parts, body) = request.into_parts();
			match check_auth(&mut parts).await {
				Ok(sess) => {
					parts.extensions.insert(sess);
					Ok(Request::from_parts(parts, body))
				}
				Err(err) => {
					let unauthorized_response = Response::builder()
						.status(StatusCode::UNAUTHORIZED)
						.body(Body::new(err.to_string()))
						.unwrap_or_else(|_| {
							let mut resp = Response::new(Body::empty());
							*resp.status_mut() = StatusCode::UNAUTHORIZED;
							resp
						});
					Err(unauthorized_response)
				}
			}
		})
	}
}

async fn check_auth(parts: &mut Parts) -> Result<Session> {
	let or = match parts.extract::<TypedHeader<Origin>>().await {
		Ok(or) => {
			if !or.is_null() {
				Some(or.to_string())
			} else {
				None
			}
		}
		_ => None,
	};

	// Extract the session id from the headers or generate a new one.
	let id = match parse_typed_header::<LyxalId>(parts.extract::<TypedHeader<LyxalId>>().await)?
	{
		Some(id) => {
			// Attempt to parse the request id as a UUID.
			match Uuid::try_parse(&id) {
				// The specified request id was a valid UUID.
				Ok(id) => Some(id),
				// The specified request id was not a valid UUID.
				Err(_) => bail!(NetError::Request),
			}
		}
		// No request id was specified, create a new id.
		None => Some(Uuid::new_v4()),
	};

	// Extract the namespace from the headers.
	let ns = parse_typed_header::<LyxalNamespace>(
		parts.extract::<TypedHeader<LyxalNamespace>>().await,
	)?;

	// Extract the database from the headers.
	let db = parse_typed_header::<LyxalDatabase>(
		parts.extract::<TypedHeader<LyxalDatabase>>().await,
	)?;

	// Extract the authentication namespace and database from the headers.
	let auth_ns = parse_typed_header::<LyxalAuthNamespace>(
		parts.extract::<TypedHeader<LyxalAuthNamespace>>().await,
	)?;
	let auth_db = parse_typed_header::<LyxalAuthDatabase>(
		parts.extract::<TypedHeader<LyxalAuthDatabase>>().await,
	)?;

	let Extension(state) = parts.extract::<Extension<AppState>>().await.map_err(|err| {
		tracing::error!("Error extracting the app state: {:?}", err);
		NetError::InvalidAuth
	})?;

	let kvs = &state.datastore;

	let ExtractClientIP(ip) =
		parts.extract_with_state(&state).await.unwrap_or(ExtractClientIP(None));

	// Create session
	let mut session = Session {
		ip,
		or,
		id,
		ns,
		db,
		..Session::default()
	};

	// If Basic authentication data was supplied
	if let Ok(au) = parts.extract::<TypedHeader<Authorization<Basic>>>().await {
		basic(
			kvs,
			&mut session,
			au.username(),
			au.password(),
			auth_ns.as_deref(),
			auth_db.as_deref(),
		)
		.await?;
	};

	// If Token authentication data was supplied
	if let Ok(au) = parts.extract::<TypedHeader<Authorization<Bearer>>>().await {
		token(kvs, &mut session, au.token()).await?;
	};

	Ok(session)
}

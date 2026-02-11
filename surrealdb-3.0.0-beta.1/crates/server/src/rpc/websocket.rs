use core::fmt;
use std::sync::Arc;
use std::time::Duration;

use axum::extract::ws::close_code::AGAIN;
use axum::extract::ws::{CloseFrame, Message, WebSocket};
use bytes::Bytes;
use dashmap::DashMap;
use futures::stream::FuturesUnordered;
use futures::{Sink, SinkExt, StreamExt};
use opentelemetry::Context as TelemetryContext;
use opentelemetry::trace::FutureExt;
use surrealdb_core::dbs::Session;
use surrealdb_core::kvs::{Datastore, LockType, Transaction, TransactionType};
use surrealdb_core::mem::ALLOC;
use surrealdb_core::rpc::format::Format;
use surrealdb_core::rpc::{DbResponse, DbResult, DbResultError, Method, RpcProtocol};
use surrealdb_types::{Array, HashMap, Value};
use tokio::sync::RwLock;
use tokio::sync::mpsc::{Receiver, Sender, channel};
use tokio::task::JoinSet;
use tokio_util::sync::CancellationToken;
use tracing::{Instrument, Span};
use uuid::Uuid;

use super::RpcState;
use crate::cnf::{
	PKG_NAME, PKG_VERSION, WEBSOCKET_PING_FREQUENCY, WEBSOCKET_RESPONSE_BUFFER_SIZE,
	WEBSOCKET_RESPONSE_CHANNEL_SIZE, WEBSOCKET_RESPONSE_FLUSH_PERIOD,
};
use crate::rpc::CONN_CLOSED_ERR;
use crate::rpc::format::WsFormat;
use crate::telemetry;
use crate::telemetry::metrics::ws::RequestContext;
use crate::telemetry::traces::rpc::span_for_request;

/// An error string sent when the server is out of memory
const SERVER_OVERLOADED: &str = "The server is unable to handle the request";

/// An error string sent when the server is gracefully shutting down
const SERVER_SHUTTING_DOWN: &str = "The server is gracefully shutting down";

pub struct Websocket {
	/// The unique id of this WebSocket connection
	pub(crate) id: Uuid,
	/// The request and response format for messages
	pub(crate) format: Format,
	/// The system state for all RPC WebSocket connections
	pub(crate) state: Arc<RpcState>,
	/// The datastore accessible to all RPC WebSocket connections
	pub(crate) datastore: Arc<Datastore>,
	/// The active sessions for this WebSocket connection
	pub(crate) sessions: HashMap<Option<Uuid>, Arc<RwLock<Session>>>,
	/// The active transactions for this WebSocket connection
	pub(crate) transactions: DashMap<Uuid, Arc<Transaction>>,
	/// A cancellation token called when shutting down the server
	pub(crate) shutdown: CancellationToken,
	/// A cancellation token for cancelling all spawned tasks
	pub(crate) canceller: CancellationToken,
	/// The channels used to send and receive WebSocket messages
	pub(crate) channel: Sender<Message>,
}

impl Websocket {
	/// Serve the RPC endpoint
	pub async fn serve(
		id: Uuid,
		ws: WebSocket,
		format: Format,
		session: Session,
		datastore: Arc<Datastore>,
		state: Arc<RpcState>,
	) {
		// Log the succesful WebSocket connection
		trace!("WebSocket {id} connected");
		// Create a channel for sending messages
		let (sender, receiver) = channel(*WEBSOCKET_RESPONSE_CHANNEL_SIZE);
		// Create and store the RPC connection
		let rpc = Arc::new(Websocket {
			id,
			format,
			state: state.clone(),
			shutdown: CancellationToken::new(),
			canceller: CancellationToken::new(),
			sessions: HashMap::new(),
			transactions: DashMap::new(),
			channel: sender.clone(),
			datastore,
		});
		// Store the default session with None key
		// Enable realtime queries for WebSocket connections
		let session = session.with_rt(true);
		rpc.set_session(None, Arc::new(RwLock::new(session)));
		// Add this WebSocket to the list
		state.web_sockets.write().await.insert(id, rpc.clone());
		// Start telemetry metrics for this connection
		if let Err(err) = telemetry::metrics::ws::on_connect() {
			error!("Error running metrics::ws::on_connect hook: {err}");
		}
		// Store all concurrent spawned tasks
		let mut tasks = JoinSet::new();
		// Buffer the WebSocket response stream
		match *WEBSOCKET_RESPONSE_BUFFER_SIZE > 0 {
			true => {
				// Buffer the WebSocket response stream
				let buffer = ws.buffer(*WEBSOCKET_RESPONSE_BUFFER_SIZE);
				// Split the socket into sending and receiving streams
				let (ws_sender, ws_receiver) = buffer.split();
				// Spawn async tasks for the WebSocket
				tasks.spawn(Self::ping(rpc.clone(), sender.clone()));
				tasks.spawn(Self::read(rpc.clone(), ws_receiver, sender.clone()));
				tasks.spawn(Self::write(rpc.clone(), ws_sender, receiver));
			}
			false => {
				// Split the socket into sending and receiving streams
				let (ws_sender, ws_receiver) = ws.split();
				// Spawn async tasks for the WebSocket
				tasks.spawn(Self::ping(rpc.clone(), sender.clone()));
				tasks.spawn(Self::read(rpc.clone(), ws_receiver, sender.clone()));
				tasks.spawn(Self::write(rpc.clone(), ws_sender, receiver));
			}
		}
		// Wait for all tasks to finish
		while let Some(res) = tasks.join_next().await {
			if let Err(err) = res {
				error!("Error handling RPC connection: {err}");
			}
		}
		// Close the internal response channel
		std::mem::drop(sender);
		// Log the WebSocket disconnection
		trace!("WebSocket {id} disconnected");
		// Cleanup the live queries for this WebSocket
		rpc.cleanup_all_lqs().await;
		// Remove this WebSocket from the list
		state.web_sockets.write().await.remove(&id);
		// Stop telemetry metrics for this connection
		if let Err(err) = telemetry::metrics::ws::on_disconnect() {
			error!("Error running metrics::ws::on_disconnect hook: {err}");
		}
	}

	/// Send Ping messages to the client
	async fn ping(rpc: Arc<Websocket>, internal_sender: Sender<Message>) {
		// Create the interval ticker
		let mut interval = tokio::time::interval(WEBSOCKET_PING_FREQUENCY);
		// Clone the WebSocket cancellation token
		let canceller = rpc.canceller.clone();
		// Loop, and listen for messages to write
		loop {
			tokio::select! {
				// Process brances in order
				biased;
				// Check if we should teardown
				_ = canceller.cancelled() => break,
				// Send a regular ping message
				_ = interval.tick() => {
					// Create a new ping message
					let msg = Message::Ping(Bytes::from_static(b""));
					// Close the connection if the message fails
					if let Err(err) = internal_sender.send(msg).await {
						// Output any errors if not a close error
						if err.to_string() != CONN_CLOSED_ERR {
							trace!("WebSocket error: {err}");
						}
						// Cancel the WebSocket tasks
						canceller.cancel();
						// Exit out of the loop
						break;
					}
				},
			}
		}
	}

	/// Write messages to the client
	async fn write<S: SinkExt<Message> + Unpin>(
		rpc: Arc<Websocket>,
		mut socket: S,
		mut internal_receiver: Receiver<Message>,
	) where
		<S as Sink<Message>>::Error: fmt::Display,
	{
		// Clone the WebSocket cancellation token
		let canceller = rpc.canceller.clone();
		// Check if the responses are buffered
		let buffer = *WEBSOCKET_RESPONSE_BUFFER_SIZE > 0;
		// How often should responses be flushed
		let period = Duration::from_millis(*WEBSOCKET_RESPONSE_FLUSH_PERIOD);
		// Loop, and listen for messages to write
		loop {
			tokio::select! {
				// Process brances in order
				biased;
				// Check if we should teardown
				_ = canceller.cancelled() => break,
				// Retrieve a response from the channel
				Some(res) = internal_receiver.recv() => {
					// Check if the socket is buffered
					let res = match buffer {
						// Send the message to the socket buffer
						true => socket.feed(res).await,
						// Send the message direct to the socket
						false => socket.send(res).await
					};
					// Check if there was an error
					if let Err(err) = res {
						// Output any errors if not a close error
						if err.to_string() != CONN_CLOSED_ERR {
							trace!("WebSocket error: {err}");
						}
						// Cancel the WebSocket tasks
						canceller.cancel();
						// Exit out of the loop
						break;
					}
				},
				// Wait for a short period of time
				_ = tokio::time::sleep(period), if buffer => {
					// Flush the WebSocket socket buffer
					if let Err(err) = socket.flush().await {
						// Output any errors if not a close error
						if err.to_string() != CONN_CLOSED_ERR {
							trace!("WebSocket error: {err}");
						}
						// Cancel the WebSocket tasks
						canceller.cancel();
						// Exit out of the loop
						break;
					}
				}
			}
		}
	}

	/// Read messages sent from the client
	async fn read(
		rpc: Arc<Websocket>,
		mut socket: impl StreamExt<Item = Result<Message, axum::Error>> + Unpin,
		internal_sender: Sender<Message>,
	) {
		// Clone the WebSocket shutdown token
		let shutdown = rpc.shutdown.clone();
		// Clone the WebSocket cancellation token
		let canceller = rpc.canceller.clone();
		// Store spawned tasks so we can wait for them
		let mut tasks = FuturesUnordered::new();
		// Loop, and listen for messages to write
		loop {
			tokio::select! {
				// Process brances in order
				biased;
				// Remove any completed tasks
				_ = tasks.next(), if !tasks.is_empty() => {},
				// Check if we are shutting down
				_ = shutdown.cancelled() => break,
				// Check if we should teardown
				_ = canceller.cancelled() => break,
				// Wait for the next received message
				Some(msg) = socket.next() => match msg {
					// We've received a message from the client
					Ok(msg) => match msg {
						Message::Text(_) | Message::Binary(_) => {
							// Clone the response sending channel
							let chn = internal_sender.clone();
							// Check to see whether we have available memory
							if ALLOC.is_beyond_threshold() {
								// Reject the message
								Self::close_socket(rpc.clone(), chn).await;
								// Exit out of the loop
								break;
							}
							// Otherwise spawn and handle the message
							tasks.push(Self::handle_message(&rpc, msg, chn));
						}
						Message::Close(_) => {
							// Respond with a close message
							if let Err(err) = internal_sender.send(Message::Close(None)).await {
								trace!("WebSocket error when replying to the close message: {err}");
							};
							// Cancel the WebSocket tasks
							canceller.cancel();
							// Exit out of the loop
							break;
						}
						Message::Ping(_) => {
							// Ping messages are responded to automatically
						}
						Message::Pong(_) => {
							// Pong messages are handled automatically
						}
					},
					Err(err) => {
						// There was an error with the WebSocket
						trace!("WebSocket error: {err}");
						// Cancel the WebSocket tasks
						canceller.cancel();
						// Exit out of the loop
						break;
					}
				}
			}
		}
		// Continue with the shutdown process
		tokio::select! {
			// Process brances in order
			biased;
			// Check if we have been cancelled
			_ = canceller.cancelled() => (),
			// Check if we are shutting down
			_ = shutdown.cancelled() => {
				// Wait for all tasks to finish
				while tasks.next().await.is_some() {
					// Do nothing
				}
			},
		}
		// Cancel the WebSocket tasks
		canceller.cancel();
		// Ensure everything is dropped
		std::mem::drop(tasks);
	}

	/// Handle an individual WebSocket message
	async fn handle_message(rpc: &Arc<Websocket>, msg: Message, chn: Sender<Message>) {
		// Clone the WebSocket cancellation token
		let shutdown = rpc.shutdown.clone();
		// Clone the WebSocket cancellation token
		let canceller = rpc.canceller.clone();
		// Calculate the message length and format
		let len = match msg {
			Message::Text(ref msg) => msg.len(),
			Message::Binary(ref msg) => msg.len(),
			_ => 0,
		};
		// Prepare span and otel context
		let span = span_for_request(&rpc.id);
		// Parse the request
		async move {
			let span = Span::current();
			let req_cx = RequestContext::default();
			let otel_cx = Arc::new(TelemetryContext::new().with_value(req_cx.clone()));
			// Parse the RPC request structure
			match rpc.format.req_ws(msg) {
				Ok(req) => {
					// Now that we know the method, we can update the span and create otel context
					span.record("rpc.method", req.method.to_str());
					span.record("otel.name", format!("surrealdb.rpc/{}", req.method));
					span.record(
						"rpc.request_id",
						req.id.clone().map(|id| format!("{id:?}")).unwrap_or_default(),
					);
					let otel_cx = Arc::new(TelemetryContext::current_with_value(
						req_cx.with_method(req.method.to_str()).with_size(len),
					));
					// Process the message
					tokio::select! {
						//
						biased;
						// Check if we should teardown
						_ = canceller.cancelled() => (),
						// Wait for the message to be processed
						_ = async move {
							// Don't start processing if we are gracefully shutting down
							if shutdown.is_cancelled() {
								// Process the response
								crate::rpc::response::send(
									DbResponse::failure(req.id, req.session_id.map(Into::into), DbResultError::InternalError(SERVER_SHUTTING_DOWN.to_string())),
									otel_cx.clone(),
									rpc.format,
									chn
								)
									.with_context(otel_cx.as_ref().clone())
									.await;
							}
							// Check to see whether we have available memory
							else if ALLOC.is_beyond_threshold() {
								// Process the response
								crate::rpc::response::send(
									DbResponse::failure(req.id, req.session_id.map(Into::into), DbResultError::InternalError(SERVER_OVERLOADED.to_string())),
									otel_cx.clone(),
									rpc.format,
									chn
								)
									.with_context(otel_cx.as_ref().clone())
									.await;
							}
							// Otherwise process the request message
							else {
								// Process the message
								let result = Self::process_message(
									rpc.clone(),
									req.session_id.map(Into::into),
									req.txn.map(Into::into),
									req.method,
									req.params,
								)
									.await;

								crate::rpc::response::send(
									match result {
										Ok(result) => DbResponse::success(req.id, req.session_id.map(Into::into), result),
										Err(err) => DbResponse::failure(req.id, req.session_id.map(Into::into), err),
									},
									otel_cx.clone(),
									rpc.format,
									chn
								)
									.with_context(otel_cx.as_ref().clone())
									.await;
							}
						} => (),
					}
				}
				Err(err) => {
					// Process the response
					crate::rpc::response::send(
						DbResponse::failure(None, None, err),
						otel_cx.clone(),
						rpc.format,
						chn
					)
						.with_context(otel_cx.as_ref().clone())
						.await;
				}
			}
		}
		.instrument(span)
		.await;
	}

	/// Process a WebSocket message and generate a response
	async fn process_message(
		rpc: Arc<Websocket>,
		session_id: Option<Uuid>,
		txn: Option<Uuid>,
		method: Method,
		params: Array,
	) -> Result<DbResult, DbResultError> {
		debug!("Process RPC request");
		// Check that the method is a valid method
		if !method.is_valid() {
			return Err(DbResultError::MethodNotFound("Method not found".to_string()));
		}
		// Execute the specified method
		RpcProtocol::execute(rpc.as_ref(), txn, session_id, method, params)
			.await
			.map_err(Into::into)
	}

	/// Reject a WebSocket message due to server overloading
	async fn close_socket(rpc: Arc<Websocket>, chn: Sender<Message>) {
		// Log the error as a warning
		warn!("The server is overloaded and is unable to process a WebSocket request");
		// Create a custom close frame
		let frame = CloseFrame {
			code: AGAIN,
			reason: SERVER_OVERLOADED.into(),
		};
		// Respond with a close message
		if let Err(err) = chn.send(Message::Close(Some(frame))).await {
			debug!("WebSocket error when sending close message: {err}");
		};
		// Cancel the WebSocket tasks
		rpc.canceller.cancel();
	}
}

impl RpcProtocol for Websocket {
	/// The datastore for this RPC interface
	fn kvs(&self) -> &Datastore {
		&self.datastore
	}

	/// The version information for this RPC context
	fn version_data(&self) -> DbResult {
		let value = Value::String(format!("{PKG_NAME}-{}", *PKG_VERSION));
		DbResult::Other(value)
	}

	/// A pointer to all active sessions
	fn session_map(&self) -> &HashMap<Option<Uuid>, Arc<RwLock<Session>>> {
		&self.sessions
	}

	// ------------------------------
	// Transactions
	// ------------------------------

	/// Retrieves a transaction by ID
	async fn get_tx(
		&self,
		id: Uuid,
	) -> Result<Arc<surrealdb_core::kvs::Transaction>, surrealdb_core::rpc::RpcError> {
		debug!("WebSocket get_tx called for transaction {id}");
		self.transactions
			.get(&id)
			.map(|tx| {
				debug!("Transaction {id} found in WebSocket transactions map");
				tx.clone()
			})
			.ok_or_else(|| {
				warn!(
					"Transaction {id} not found in WebSocket transactions map (have {} transactions)",
					self.transactions.len()
				);
				surrealdb_core::rpc::RpcError::InvalidParams("Transaction not found".to_string())
			})
	}

	/// Stores a transaction
	async fn set_tx(
		&self,
		id: Uuid,
		tx: Arc<surrealdb_core::kvs::Transaction>,
	) -> Result<(), surrealdb_core::rpc::RpcError> {
		self.transactions.insert(id, tx);
		Ok(())
	}

	// ------------------------------
	// Realtime
	// ------------------------------

	/// Live queries are enabled on WebSockets
	const LQ_SUPPORT: bool = true;

	/// Handles the execution of a LIVE statement
	async fn handle_live(&self, lqid: &Uuid, session_id: Option<Uuid>) {
		self.state.live_queries.write().await.insert(*lqid, (self.id, session_id));
		trace!("Registered live query {lqid} on websocket {}", self.id);
	}

	/// Handles the execution of a KILL statement
	async fn handle_kill(&self, lqid: &Uuid) {
		if let Some((id, session_id)) = self.state.live_queries.write().await.remove(lqid) {
			if let Some(session_id) = session_id {
				trace!("Unregistered live query {lqid} on websocket {id} for session {session_id}");
			} else {
				trace!("Unregistered live query {lqid} on websocket {id} for default session");
			}
		}
	}

	/// Handles the cleanup of live queries
	async fn cleanup_lqs(&self, session_id: Option<&Uuid>) {
		let mut gc = Vec::new();
		// Find all live queries for to this connection
		self.state.live_queries.write().await.retain(|key, value| {
			if value.0 == self.id && value.1.as_ref() == session_id {
				trace!("Removing live query: {key}");
				gc.push(*key);
				return false;
			}
			true
		});
		// Garbage collect the live queries on this connection
		if let Err(err) = self.kvs().delete_queries(gc).await {
			error!("Error handling RPC connection: {err}");
		}
	}

	/// Handles the cleanup of live queries
	async fn cleanup_all_lqs(&self) {
		let mut gc = Vec::new();
		// Find all live queries for to this connection
		self.state.live_queries.write().await.retain(|key, value| {
			if value.0 == self.id {
				trace!("Removing live query: {key}");
				gc.push(*key);
				return false;
			}
			true
		});
		// Garbage collect the live queries on this connection
		if let Err(err) = self.kvs().delete_queries(gc).await {
			error!("Error handling RPC connection: {err}");
		}
	}

	// ------------------------------
	// Methods for transactions
	// ------------------------------

	/// Begin a new transaction
	async fn begin(
		&self,
		_txn: Option<Uuid>,
		_session_id: Option<Uuid>,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		// Create a new transaction
		let tx = self.kvs().transaction(TransactionType::Write, LockType::Optimistic).await?;
		// Generate a unique transaction ID
		let id = Uuid::now_v7();
		debug!("WebSocket begin: created transaction {id}");
		// Store the transaction in the map
		self.transactions.insert(id, Arc::new(tx));
		debug!(
			"WebSocket begin: stored transaction {id}, map now has {} transactions",
			self.transactions.len()
		);
		// Return the transaction ID to the client
		Ok(DbResult::Other(Value::Uuid(surrealdb::types::Uuid::from(id))))
	}

	/// Commit a transaction
	async fn commit(
		&self,
		_txn: Option<Uuid>,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		// Extract the transaction ID from params
		let mut params_vec = params.into_vec();
		let Some(Value::Uuid(txn_id)) = params_vec.pop() else {
			return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected transaction UUID".to_string(),
			));
		};

		let txn_id = txn_id.into_inner();

		// Retrieve and remove the transaction from the map
		let Some((_, tx)) = self.transactions.remove(&txn_id) else {
			return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Transaction not found".to_string(),
			));
		};

		// Commit the transaction
		tx.commit().await?;

		// Return success
		Ok(DbResult::Other(Value::None))
	}

	/// Cancel a transaction
	async fn cancel(
		&self,
		_txn: Option<Uuid>,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		// Extract the transaction ID from params
		let mut params_vec = params.into_vec();
		let Some(Value::Uuid(txn_id)) = params_vec.pop() else {
			return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected transaction UUID".to_string(),
			));
		};

		let txn_id = txn_id.into_inner();

		// Retrieve and remove the transaction from the map
		let Some((_, tx)) = self.transactions.remove(&txn_id) else {
			return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Transaction not found".to_string(),
			));
		};

		// Cancel the transaction
		tx.cancel().await?;

		// Return success
		Ok(DbResult::Other(Value::None))
	}

	// ------------------------------
	// RTC Methods
	// ------------------------------

	#[cfg(feature = "rtc")]
	async fn rtc_create(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{RtcEngine, RtcSessionId};

		let mut params_vec = params.into_vec();
		
		// Extract session_id (required)
		let session_id = match params_vec.first() {
			Some(Value::String(s)) => s.to_string(),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string)".to_string(),
				))
			}
		};

		// Create the session
		self.state
			.rtc
			.create_session(RtcSessionId::new(session_id.clone()), None)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::String(session_id)))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_join(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{RtcEngine, RtcPeerId, RtcSessionId};

		let params_vec = params.into_vec();
		
		// Extract session_id (required)
		let rtc_session_id = match params_vec.first() {
			Some(Value::String(s)) => RtcSessionId::new(s.to_string()),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string)".to_string(),
				))
			}
		};

		// Generate or extract peer_id
		let peer_id = match params_vec.get(1) {
			Some(Value::Uuid(u)) => RtcPeerId::from_uuid(u.0),
			_ => RtcPeerId::new(),
		};

		// Join the session
		let existing_peers = self
			.state
			.rtc
			.join_session(&rtc_session_id, peer_id.clone())
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		// Build response
		let peers_array: Vec<Value> = existing_peers
			.iter()
			.map(|p| Value::String(p.0.to_string()))
			.collect();

		let mut result = surrealdb_types::Object::default();
		result.insert("peer_id".to_string(), Value::String(peer_id.0.to_string()));
		result.insert("peers".to_string(), Value::Array(peers_array.into()));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_leave(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{RtcEngine, RtcPeerId, RtcSessionId};

		let params_vec = params.into_vec();
		
		// Extract session_id and peer_id
		let rtc_session_id = match params_vec.first() {
			Some(Value::String(s)) => RtcSessionId::new(s.to_string()),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string, peer_id: string)".to_string(),
				))
			}
		};

		let peer_id = match params_vec.get(1) {
			Some(Value::String(s)) => {
				let uuid = s.parse::<uuid::Uuid>()
					.map_err(|_| surrealdb_core::rpc::RpcError::InvalidParams("Invalid peer_id UUID".to_string()))?;
				RtcPeerId::from_uuid(uuid)
			}
			Some(Value::Uuid(u)) => RtcPeerId::from_uuid(u.0),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string, peer_id: string)".to_string(),
				))
			}
		};

		// Leave the session
		self.state
			.rtc
			.leave_session(&rtc_session_id, &peer_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_signal(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{
			IceCandidate, RtcEngine, RtcPeerId, RtcSessionId, RtcSignal, SdpType, SessionDescription,
		};

		let params_vec = params.into_vec();
		
		// Extract session_id
		let rtc_session_id = match params_vec.first() {
			Some(Value::String(s)) => RtcSessionId::new(s.to_string()),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected session_id as first parameter".to_string(),
				))
			}
		};

		// Extract from peer_id
		let from_peer_id = match params_vec.get(1) {
			Some(Value::String(s)) => {
				let uuid = s.parse::<uuid::Uuid>()
					.map_err(|_| surrealdb_core::rpc::RpcError::InvalidParams("Invalid from peer_id".to_string()))?;
				RtcPeerId::from_uuid(uuid)
			}
			Some(Value::Uuid(u)) => RtcPeerId::from_uuid(u.0),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected from peer_id as second parameter".to_string(),
				))
			}
		};

		// Extract signal type and data
		let signal_obj = match params_vec.get(2) {
			Some(Value::Object(obj)) => obj,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected signal object as third parameter".to_string(),
				))
			}
		};

		// Parse signal type
		let signal_type = match signal_obj.get("type") {
			Some(Value::String(s)) => s.as_str(),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Signal must have 'type' field".to_string(),
				))
			}
		};

		let signal = match signal_type {
			"offer" => {
				let sdp = match signal_obj.get("sdp") {
					Some(Value::String(s)) => s.to_string(),
					_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams("Offer must have 'sdp' field".to_string())),
				};
				RtcSignal::Offer(SessionDescription { sdp_type: SdpType::Offer, sdp })
			}
			"answer" => {
				let sdp = match signal_obj.get("sdp") {
					Some(Value::String(s)) => s.to_string(),
					_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams("Answer must have 'sdp' field".to_string())),
				};
				RtcSignal::Answer(SessionDescription { sdp_type: SdpType::Answer, sdp })
			}
			"ice" => {
				let candidate = match signal_obj.get("candidate") {
					Some(Value::String(s)) => s.to_string(),
					_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams("ICE must have 'candidate' field".to_string())),
				};
				let sdp_mid = signal_obj.get("sdpMid").and_then(|v| match v {
					Value::String(s) => Some(s.to_string()),
					_ => None,
				});
				let sdp_m_line_index = signal_obj.get("sdpMLineIndex").and_then(|v| match v {
					Value::Number(n) => n.to_int().map(|i| i as u16),
					_ => None,
				});
				RtcSignal::Ice(IceCandidate::new(candidate, sdp_mid, sdp_m_line_index))
			}
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					format!("Unknown signal type: {}", signal_type),
				))
			}
		};

		// Extract optional target peer_id
		let to_peer_id = match params_vec.get(3) {
			Some(Value::String(s)) if !s.is_empty() => {
				let uuid = s.parse::<uuid::Uuid>()
					.map_err(|_| surrealdb_core::rpc::RpcError::InvalidParams("Invalid to peer_id".to_string()))?;
				Some(RtcPeerId::from_uuid(uuid))
			}
			Some(Value::Uuid(u)) => Some(RtcPeerId::from_uuid(u.0)),
			_ => None,
		};

		// Send the signal
		let seq = self
			.state
			.rtc
			.signal(&rtc_session_id, &from_peer_id, to_peer_id.as_ref(), signal)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::Number(surrealdb_types::Number::Int(seq as i64))))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_poll(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{RtcEngine, RtcPeerId, RtcSessionId, RtcSignal};

		let params_vec = params.into_vec();
		
		// Extract session_id and peer_id
		let rtc_session_id = match params_vec.first() {
			Some(Value::String(s)) => RtcSessionId::new(s.to_string()),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string, peer_id: string)".to_string(),
				))
			}
		};

		let peer_id = match params_vec.get(1) {
			Some(Value::String(s)) => {
				let uuid = s.parse::<uuid::Uuid>()
					.map_err(|_| surrealdb_core::rpc::RpcError::InvalidParams("Invalid peer_id UUID".to_string()))?;
				RtcPeerId::from_uuid(uuid)
			}
			Some(Value::Uuid(u)) => RtcPeerId::from_uuid(u.0),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string, peer_id: string)".to_string(),
				))
			}
		};

		// Poll for signals
		let signals = self.state.rtc.poll(&rtc_session_id, &peer_id);

		// Convert signals to Value array
		let signals_array: Vec<Value> = signals
			.into_iter()
			.map(|signal| {
				let mut obj = surrealdb_types::Object::default();
				match signal {
					RtcSignal::Offer(desc) => {
						obj.insert("type".to_string(), Value::String("offer".to_string()));
						obj.insert("sdp".to_string(), Value::String(desc.sdp));
					}
					RtcSignal::Answer(desc) => {
						obj.insert("type".to_string(), Value::String("answer".to_string()));
						obj.insert("sdp".to_string(), Value::String(desc.sdp));
					}
					RtcSignal::Ice(candidate) => {
						obj.insert("type".to_string(), Value::String("ice".to_string()));
						obj.insert("candidate".to_string(), Value::String(candidate.candidate));
						if let Some(mid) = candidate.sdp_mid {
							obj.insert("sdpMid".to_string(), Value::String(mid));
						}
						if let Some(idx) = candidate.sdp_m_line_index {
							obj.insert("sdpMLineIndex".to_string(), Value::Number(surrealdb_types::Number::Int(idx as i64)));
						}
					}
					_ => {
						obj.insert("type".to_string(), Value::String("unknown".to_string()));
					}
				}
				Value::Object(obj)
			})
			.collect();

		Ok(DbResult::Other(Value::Array(signals_array.into())))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_list(
		&self,
		_session_id: Option<Uuid>,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::RtcEngine;

		let sessions = self.state.rtc.list_sessions();
		let sessions_array: Vec<Value> = sessions
			.iter()
			.map(|s| Value::String(s.0.clone()))
			.collect();

		Ok(DbResult::Other(Value::Array(sessions_array.into())))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_info(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{RtcEngine, RtcSessionId};

		let params_vec = params.into_vec();
		
		// Extract session_id
		let rtc_session_id = match params_vec.first() {
			Some(Value::String(s)) => RtcSessionId::new(s.to_string()),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string)".to_string(),
				))
			}
		};

		// Get peers
		let peers = self
			.state
			.rtc
			.get_peers(&rtc_session_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let peers_array: Vec<Value> = peers
			.iter()
			.map(|p| Value::String(p.0.to_string()))
			.collect();

		let mut result = surrealdb_types::Object::default();
		result.insert("session_id".to_string(), Value::String(rtc_session_id.0));
		result.insert("peers".to_string(), Value::Array(peers_array.into()));
		result.insert("peer_count".to_string(), Value::Number(surrealdb_types::Number::Int(peers.len() as i64)));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn rtc_close(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::{RtcEngine, RtcSessionId};

		let params_vec = params.into_vec();
		
		// Extract session_id
		let rtc_session_id = match params_vec.first() {
			Some(Value::String(s)) => RtcSessionId::new(s.to_string()),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: string)".to_string(),
				))
			}
		};

		// Close the session
		self.state
			.rtc
			.close_session(&rtc_session_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	// ------------------------------
	// SFU Methods (Multi-party conferencing)
	// ------------------------------

	#[cfg(feature = "rtc")]
	async fn sfu_create(
		&self,
		_session_id: Option<Uuid>,
		_params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let session_id = self
			.state
			.sfu
			.create_session()
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let mut result = surrealdb_types::Object::default();
		result.insert("session_id".to_string(), Value::Number(surrealdb_types::Number::Int(session_id as i64)));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_offer(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		// Extract session_id (u64)
		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, sdp_offer: string)".to_string(),
				))
			}
		};

		// Extract SDP offer
		let sdp_offer = match params_vec.get(1) {
			Some(Value::String(s)) => s.to_string(),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, sdp_offer: string)".to_string(),
				))
			}
		};

		let (endpoint_id, sdp_answer) = self
			.state
			.sfu
			.create_offer(sfu_session_id, &sdp_offer)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let mut result = surrealdb_types::Object::default();
		result.insert("endpoint_id".to_string(), Value::Number(surrealdb_types::Number::Int(endpoint_id as i64)));
		result.insert("sdp_answer".to_string(), Value::String(sdp_answer));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_answer(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		// Extract session_id
		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, endpoint_id: number, sdp_answer: string)".to_string(),
				))
			}
		};

		// Extract endpoint_id
		let endpoint_id = match params_vec.get(1) {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, endpoint_id: number, sdp_answer: string)".to_string(),
				))
			}
		};

		// Extract SDP answer
		let sdp_answer = match params_vec.get(2) {
			Some(Value::String(s)) => s.to_string(),
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, endpoint_id: number, sdp_answer: string)".to_string(),
				))
			}
		};

		self.state
			.sfu
			.accept_answer(sfu_session_id, endpoint_id, &sdp_answer)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_leave(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		// Extract session_id
		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, endpoint_id: number)".to_string(),
				))
			}
		};

		// Extract endpoint_id
		let endpoint_id = match params_vec.get(1) {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number, endpoint_id: number)".to_string(),
				))
			}
		};

		self.state
			.sfu
			.remove_endpoint(sfu_session_id, endpoint_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_info(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		// Extract session_id
		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number)".to_string(),
				))
			}
		};

		let info = self
			.state
			.sfu
			.get_session_info(sfu_session_id)
			.ok_or_else(|| surrealdb_core::rpc::RpcError::Thrown(format!("Session {} not found", sfu_session_id)))?;

		let mut result = surrealdb_types::Object::default();
		result.insert("session_id".to_string(), Value::Number(surrealdb_types::Number::Int(info.session_id as i64)));
		result.insert("endpoint_count".to_string(), Value::Number(surrealdb_types::Number::Int(info.endpoint_count as i64)));
		result.insert("transport_count".to_string(), Value::Number(surrealdb_types::Number::Int(info.transport_count as i64)));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_list(
		&self,
		_session_id: Option<Uuid>,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let sessions = self.state.sfu.list_sessions();

		let sessions_array: Vec<Value> = sessions
			.iter()
			.map(|id| Value::Number(surrealdb_types::Number::Int(*id as i64)))
			.collect();

		Ok(DbResult::Other(Value::Array(sessions_array.into())))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_stats(
		&self,
		_session_id: Option<Uuid>,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let stats = self.state.sfu.get_stats();

		let mut result = surrealdb_types::Object::default();
		result.insert("active_sessions".to_string(), Value::Number(surrealdb_types::Number::Int(stats.active_sessions as i64)));
		result.insert("total_endpoints".to_string(), Value::Number(surrealdb_types::Number::Int(stats.total_endpoints as i64)));
		result.insert("total_transports".to_string(), Value::Number(surrealdb_types::Number::Int(stats.total_transports as i64)));
		result.insert("bytes_sent".to_string(), Value::Number(surrealdb_types::Number::Int(stats.bytes_sent as i64)));
		result.insert("bytes_received".to_string(), Value::Number(surrealdb_types::Number::Int(stats.bytes_received as i64)));
		result.insert("packets_sent".to_string(), Value::Number(surrealdb_types::Number::Int(stats.packets_sent as i64)));
		result.insert("packets_received".to_string(), Value::Number(surrealdb_types::Number::Int(stats.packets_received as i64)));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_close(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		// Extract session_id
		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => {
				return Err(surrealdb_core::rpc::RpcError::InvalidParams(
					"Expected (session_id: number)".to_string(),
				))
			}
		};

		self.state
			.sfu
			.close_session(sfu_session_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	// ------------------------------
	// Webinar/Role Management Methods
	// ------------------------------

	#[cfg(feature = "rtc")]
	async fn sfu_webinar(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::WebinarConfig;

		let params_vec = params.into_vec();

		// Parse optional config
		let max_speakers = params_vec.first()
			.and_then(|v| if let Value::Number(n) = v { Some(n.to_int() as usize) } else { None })
			.unwrap_or(10);
		let max_viewers = params_vec.get(1)
			.and_then(|v| if let Value::Number(n) = v { Some(n.to_int() as usize) } else { None })
			.unwrap_or(1000);

		let config = WebinarConfig {
			max_speakers,
			max_viewers,
			..Default::default()
		};

		let session_id = self
			.state
			.sfu
			.create_webinar(config)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let mut result = surrealdb_types::Object::default();
		result.insert("session_id".to_string(), Value::Number(surrealdb_types::Number::Int(session_id as i64)));
		result.insert("mode".to_string(), Value::String("webinar".to_string()));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_join_role(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		use surrealdb_core::rtc::ParticipantRole;

		let params_vec = params.into_vec();

		// session_id
		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number, role: string, display_name: string?, sdp_offer: string)".to_string(),
			)),
		};

		// role
		let role = match params_vec.get(1) {
			Some(Value::String(s)) => match s.to_lowercase().as_str() {
				"host" => ParticipantRole::Host,
				"cohost" => ParticipantRole::CoHost,
				"speaker" => ParticipantRole::Speaker,
				"viewer" => ParticipantRole::Viewer,
				_ => ParticipantRole::Viewer,
			},
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected role: host, cohost, speaker, viewer".to_string(),
			)),
		};

		// display_name (optional)
		let display_name = params_vec.get(2).and_then(|v| {
			if let Value::String(s) = v { Some(s.to_string()) } else { None }
		});

		// sdp_offer
		let sdp_offer = match params_vec.get(3) {
			Some(Value::String(s)) => s.to_string(),
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected sdp_offer as last parameter".to_string(),
			)),
		};

		let (endpoint_id, sdp_answer) = self
			.state
			.sfu
			.join_with_role(sfu_session_id, role, display_name, &sdp_offer)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let mut result = surrealdb_types::Object::default();
		result.insert("endpoint_id".to_string(), Value::Number(surrealdb_types::Number::Int(endpoint_id as i64)));
		result.insert("sdp_answer".to_string(), Value::String(sdp_answer));

		Ok(DbResult::Other(Value::Object(result)))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_promote(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number, endpoint_id: number)".to_string(),
			)),
		};

		let endpoint_id = match params_vec.get(1) {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected endpoint_id".to_string(),
			)),
		};

		self.state
			.sfu
			.promote_to_speaker(sfu_session_id, endpoint_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_demote(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number, endpoint_id: number)".to_string(),
			)),
		};

		let endpoint_id = match params_vec.get(1) {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected endpoint_id".to_string(),
			)),
		};

		self.state
			.sfu
			.demote_to_viewer(sfu_session_id, endpoint_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_raise_hand(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number, endpoint_id: number)".to_string(),
			)),
		};

		let endpoint_id = match params_vec.get(1) {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected endpoint_id".to_string(),
			)),
		};

		self.state
			.sfu
			.raise_hand(sfu_session_id, endpoint_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_lower_hand(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number, endpoint_id: number)".to_string(),
			)),
		};

		let endpoint_id = match params_vec.get(1) {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected endpoint_id".to_string(),
			)),
		};

		self.state
			.sfu
			.lower_hand(sfu_session_id, endpoint_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		Ok(DbResult::Other(Value::None))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_raised_hands(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number)".to_string(),
			)),
		};

		let participants = self
			.state
			.sfu
			.get_raised_hands(sfu_session_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let array: Vec<Value> = participants
			.iter()
			.map(|p| {
				let mut obj = surrealdb_types::Object::default();
				obj.insert("endpoint_id".to_string(), Value::Number(surrealdb_types::Number::Int(p.endpoint_id as i64)));
				obj.insert("display_name".to_string(), p.display_name.clone().map(Value::String).unwrap_or(Value::None));
				Value::Object(obj)
			})
			.collect();

		Ok(DbResult::Other(Value::Array(array.into())))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_participants(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number)".to_string(),
			)),
		};

		let participants = self
			.state
			.sfu
			.get_participants(sfu_session_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let array: Vec<Value> = participants
			.iter()
			.map(|p| {
				let mut obj = surrealdb_types::Object::default();
				obj.insert("endpoint_id".to_string(), Value::Number(surrealdb_types::Number::Int(p.endpoint_id as i64)));
				obj.insert("display_name".to_string(), p.display_name.clone().map(Value::String).unwrap_or(Value::None));
				obj.insert("role".to_string(), Value::String(format!("{:?}", p.role)));
				obj.insert("audio_muted".to_string(), Value::Bool(p.audio_muted));
				obj.insert("video_muted".to_string(), Value::Bool(p.video_muted));
				obj.insert("hand_raised".to_string(), Value::Bool(p.hand_raised));
				Value::Object(obj)
			})
			.collect();

		Ok(DbResult::Other(Value::Array(array.into())))
	}

	#[cfg(feature = "rtc")]
	async fn sfu_speakers(
		&self,
		_session_id: Option<Uuid>,
		params: Array,
	) -> Result<DbResult, surrealdb_core::rpc::RpcError> {
		let params_vec = params.into_vec();

		let sfu_session_id = match params_vec.first() {
			Some(Value::Number(n)) => n.to_int() as u64,
			_ => return Err(surrealdb_core::rpc::RpcError::InvalidParams(
				"Expected (session_id: number)".to_string(),
			)),
		};

		let speakers = self
			.state
			.sfu
			.get_speakers(sfu_session_id)
			.map_err(|e| surrealdb_core::rpc::RpcError::Thrown(e.to_string()))?;

		let array: Vec<Value> = speakers
			.iter()
			.map(|p| {
				let mut obj = surrealdb_types::Object::default();
				obj.insert("endpoint_id".to_string(), Value::Number(surrealdb_types::Number::Int(p.endpoint_id as i64)));
				obj.insert("display_name".to_string(), p.display_name.clone().map(Value::String).unwrap_or(Value::None));
				obj.insert("role".to_string(), Value::String(format!("{:?}", p.role)));
				Value::Object(obj)
			})
			.collect();

		Ok(DbResult::Other(Value::Array(array.into())))
	}
}

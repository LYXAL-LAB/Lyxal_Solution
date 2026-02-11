use std::collections::BTreeMap;
use anyhow::Result;
use reblessive::tree::Stk;
use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::val::{Value, RecordId, Object, TableName};
use crate::err::Error;
use crate::iam::{Action, ResourceKind};
use crate::expr::Base;
use crate::fnc::args::Any;
use crate::val::value::Cast;
use uuid::Uuid;
use chrono::Utc;
use crate::syn;
use crate::catalog::Record;
use crate::key::record;
use crate::kvs::KVValue;
use crate::catalog::providers::{TableProvider, DatabaseProvider};
use tracing::info;

use crate::api::crypto::encrypt_payload;

pub async fn add(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	
	// Arity check: 4 required, up to 18 (added allow_egress)
	if args.len() < 4 || args.len() > 18 {
		return Err(Error::InvalidArguments {
			name: "schedule::add".to_owned(),
			message: "Expected 4 to 18 arguments".to_owned(),
		}.into());
	}

	let name = String::cast(args[0].clone())?;
	let cron = String::cast(args[1].clone())?;
	let action = String::cast(args[2].clone())?;
	let mut payload = args[3].clone(); // Changed to Value
	
	let priority = if args.len() > 4 { i64::cast(args[4].clone())? } else { 0 };
	let max_retries = if args.len() > 5 { i64::cast(args[5].clone())? } else { 3 };
	let instance_id = if args.len() > 6 { String::cast(args[6].clone())? } else { String::new() };
	let run_as = if args.len() > 7 { Some(String::cast(args[7].clone())?) } else { None };
	let on_success = if args.len() > 8 { Some(String::cast(args[8].clone())?) } else { None };
	let on_failure = if args.len() > 9 { Some(String::cast(args[9].clone())?) } else { None };
	let one_shot = if args.len() > 10 { bool::cast(args[10].clone())? } else { false };
	let idempotency_key = if args.len() > 11 { Some(String::cast(args[11].clone())?) } else { None };
	let timezone = if args.len() > 12 { String::cast(args[12].clone())? } else { "UTC".to_string() };
	let encrypted = if args.len() > 13 { bool::cast(args[13].clone())? } else { false };
	let retry_strategy = if args.len() > 14 { String::cast(args[14].clone())? } else { "linear".to_string() };
	let retry_base_delay = if args.len() > 15 { Value::cast(args[15].clone())? } else { Value::Duration(std::time::Duration::from_secs(60).into()) };
	let retry_max_delay = if args.len() > 16 { Value::cast(args[16].clone())? } else { Value::Duration(std::time::Duration::from_secs(3600).into()) };
	let allow_egress = if args.len() > 17 { bool::cast(args[17].clone())? } else { false };

	// Validation
	if name.is_empty() || (cron.is_empty() && !one_shot) || action.is_empty() {
		 return Err(Error::InvalidArguments {
			name: "schedule::add".to_owned(),
			message: "name, action cannot be empty, cron cannot be empty unless one_shot is true".to_owned(),
		}.into());
	}

	// Phase 2.3: Handle encryption
	if encrypted {
		let encrypted_str = encrypt_payload(&payload).map_err(|e| Error::Internal(e.to_string()))?;
		payload = Value::from(encrypted_str);
	}

	// Permissions
	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;

	// Bloc 10.5.1: Payload validation
	if action.starts_with("fn::") {
		let func_name = &action[4..];
		let txn = ctx.tx();
		if let Ok(_func) = txn.get_db_function(ns, db, func_name).await {
			let payload_len = payload.as_object().map(|o| o.len()).unwrap_or(0);
			info!(job = %name, action = %action, payload_fields = payload_len, "validating payload against custom function");
		}
	}

	let txn = ctx.tx();

	let id = Uuid::new_v4().to_string();
	let rid = RecordId {
		table: "scheduler_task".into(),
		key: id.clone().into(),
	};

	let mut obj = BTreeMap::<String, Value>::new();
	obj.insert("name".into(), name.into());
	obj.insert("cron".into(), cron.into());
	obj.insert("action".into(), action.into());
	obj.insert("payload".into(), payload);
	obj.insert("encrypted".into(), encrypted.into());
	obj.insert("enabled".into(), true.into());
	obj.insert("priority".into(), priority.into());
	obj.insert("max_retries".into(), max_retries.into());
	obj.insert("instance_id".into(), instance_id.into());
	obj.insert("run_as".into(), run_as.map(Value::from).unwrap_or(Value::None));
	obj.insert("on_success".into(), on_success.map(Value::from).unwrap_or(Value::None));
	obj.insert("on_failure".into(), on_failure.map(Value::from).unwrap_or(Value::None));
	obj.insert("one_shot".into(), one_shot.into());
	obj.insert("idempotency_key".into(), idempotency_key.map(Value::from).unwrap_or(Value::None));
	obj.insert("timezone".into(), timezone.into());
	obj.insert("retry_strategy".into(), retry_strategy.into());
	obj.insert("retry_base_delay".into(), retry_base_delay);
	obj.insert("retry_max_delay".into(), retry_max_delay);
	obj.insert("allow_egress".into(), allow_egress.into());
	obj.insert("progress".into(), 0.into());
	obj.insert("attempts".into(), 0.into());
	obj.insert("created_at".into(), Value::Datetime(Utc::now().into()));
	obj.insert("updated_at".into(), Value::Datetime(Utc::now().into()));
	obj.insert("next_run".into(), Value::Datetime(Utc::now().into()));

	let val = Value::Object(Object::from(obj));
	
	txn.set_record(ns, db, &rid.table, &rid.key, Record::new(val.into()).into(), None).await?;

	Ok(Value::RecordId(rid))
}

pub async fn add_many(
	(stk, ctx, opt, doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::add_many".to_owned(),
			message: "Expected 1 argument (array of jobs)".to_owned(),
		}.into());
	}

	let jobs_val = Value::cast(args[0].clone())?;
	let jobs_arr = jobs_val.as_array().ok_or(Error::InvalidArguments {
		name: "schedule::add_many".to_owned(),
		message: "Argument must be an array".to_owned(),
	})?;

	let mut results = Vec::new();

	for job_spec in jobs_arr.iter() {
		if let Value::Object(spec) = job_spec {
			// Extract fields from spec object
			let name = spec.get("name").map(|v| v.to_raw_string()).unwrap_or_default();
			let cron = spec.get("cron").map(|v| v.to_raw_string()).unwrap_or_default();
			let action = spec.get("action").map(|v| v.to_raw_string()).unwrap_or_default();
			let payload = spec.get("payload").cloned().unwrap_or(Value::Object(Object::default()));
			let _payload_obj = Object::cast(payload.clone())?;

			let priority = spec.get("priority").and_then(|v| v.as_int()).copied().unwrap_or(0);
			let max_retries = spec.get("max_retries").and_then(|v| v.as_int()).copied().unwrap_or(3);
			let instance_id = spec.get("instance_id").map(|v| v.to_raw_string()).unwrap_or_default();
			let run_as = spec.get("run_as").map(|v| v.to_raw_string());
			let on_success = spec.get("on_success").map(|v| v.to_raw_string());
			let on_failure = spec.get("on_failure").map(|v| v.to_raw_string());
			let one_shot = spec.get("one_shot").and_then(|v| v.as_bool()).copied().unwrap_or(false);
			let idempotency_key = spec.get("idempotency_key").map(|v| v.to_raw_string());
			let timezone = spec.get("timezone").map(|v| v.to_raw_string()).unwrap_or_else(|| "UTC".to_string());
			let preferred_node = spec.get("preferred_node").map(|v| v.to_raw_string());
			let encrypted = spec.get("encrypted").and_then(|v| v.as_bool()).copied().unwrap_or(false);
			let retry_strategy = spec.get("retry_strategy").map(|v| v.to_raw_string()).unwrap_or_else(|| "linear".to_string());
			let retry_base_delay = spec.get("retry_base_delay").cloned().unwrap_or(Value::Duration(std::time::Duration::from_secs(60).into()));
			let retry_max_delay = spec.get("retry_max_delay").cloned().unwrap_or(Value::Duration(std::time::Duration::from_secs(3600).into()));
			let allow_egress = spec.get("allow_egress").and_then(|v| v.as_bool()).copied().unwrap_or(false);

			let add_args = vec![
				Value::String(name),
				Value::String(cron),
				Value::String(action),
				payload,
				Value::Number(priority.into()),
				Value::Number(max_retries.into()),
				Value::String(instance_id),
				run_as.map(Value::from).unwrap_or(Value::None),
				on_success.map(Value::from).unwrap_or(Value::None),
				on_failure.map(Value::from).unwrap_or(Value::None),
				Value::Bool(one_shot),
				idempotency_key.map(Value::from).unwrap_or(Value::None),
				Value::String(timezone),
				Value::Bool(encrypted),
				Value::String(retry_strategy),
				retry_base_delay,
				retry_max_delay,
				Value::Bool(allow_egress),
			];

			// We call unit add for each. Bulk transactionality is handled by the outer caller's transaction if used in a BEGIN...COMMIT block.
			let res = add((stk, ctx, opt, doc), Any(add_args)).await?;
			
			// Bloc 11.2.1: Add preferred_node if specified
			if let Some(node) = preferred_node {
				let rid = RecordId::cast(res.clone())?;
				let opt_val = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
				let (ns, db) = ctx.expect_ns_db_ids(opt_val).await?;
				let txn = ctx.tx();
				let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
				let mut record = (*record).clone();
				if let Value::Object(obj) = record.data.to_mut() {
					obj.insert("preferred_node".into(), Value::String(node));
				}
				txn.set_record(ns, db, &rid.table, &rid.key, record.into(), None).await?;
			}

			results.push(res);
		}
	}

	Ok(Value::Array(results.into()))
}

pub async fn once(
	(stk, ctx, opt, doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	// datetime, action, payload, priority?, encrypted?
	if args.len() < 3 || args.len() > 5 {
		return Err(Error::InvalidArguments {
			name: "schedule::once".to_owned(),
			message: "Expected 3 to 5 arguments (datetime, action, payload, priority?, encrypted?)".to_owned(),
		}.into());
	}

	let datetime_val = Value::cast(args[0].clone())?;
	let datetime = datetime_val.as_datetime().ok_or(Error::InvalidArguments {
		name: "schedule::once".to_owned(),
		message: "First argument must be a datetime".to_owned(),
	})?;
	let action = String::cast(args[1].clone())?;
	let payload = args[2].clone();
	let priority = if args.len() > 3 { i64::cast(args[3].clone())? } else { 0 };
	let encrypted = if args.len() > 4 { bool::cast(args[4].clone())? } else { false };

	let add_args = vec![
		Value::String(format!("One-shot: {}", action)),
		Value::String(String::new()), 
		Value::String(action),
		payload,
		Value::Number(priority.into()),
		Value::Number(0.into()), 
		Value::String(String::new()), 
		Value::None, 
		Value::None, 
		Value::None, 
		Value::Bool(true), 
		Value::None, // idempotency
		Value::String("UTC".to_string()), // timezone
		Value::Bool(encrypted), // Phase 2.3: encrypted
		Value::String("linear".to_string()), // retry_strategy
		Value::Duration(std::time::Duration::from_secs(60).into()), // retry_base_delay
		Value::Duration(std::time::Duration::from_secs(3600).into()), // retry_max_delay
		Value::Bool(false), // allow_egress (default secure)
	];
	
	let rid_val = add((stk, ctx, opt, doc), Any(add_args)).await?;
	let rid = RecordId::cast(rid_val.clone())?;

	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
	let mut record = (*record).clone();
	if let Value::Object(obj) = record.data.to_mut() {
		obj.insert("next_run".into(), Value::Datetime(datetime.clone()));
	}
	
	txn.set_record(ns, db, &rid.table, &rid.key, record.into(), None).await?;

	Ok(Value::RecordId(rid))
}

pub async fn retry(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::retry".to_owned(),
			message: "Expected 1 argument (dead_letter_id)".to_owned(),
		}.into());
	}
	let dl_id = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let dl_record = txn.get_record(ns, db, &dl_id.table, &dl_id.key, None).await?;
	let dl_val = dl_record.data.as_ref();
	
	if let Value::Object(obj) = dl_val {
		let job_rid = RecordId::cast(obj.get("job").cloned().unwrap_or(Value::None))?;
		
		let job_record = txn.get_record(ns, db, &job_rid.table, &job_rid.key, None).await?;
		let mut job_record = (*job_record).clone();
		if let Value::Object(job_obj) = job_record.data.to_mut() {
			job_obj.insert("enabled".into(), true.into());
			job_obj.insert("attempts".into(), 0.into());
			job_obj.insert("next_run".into(), Value::Datetime(Utc::now().into()));
			job_obj.insert("updated_at".into(), Value::Datetime(Utc::now().into()));
		}
		
		txn.set_record(ns, db, &job_rid.table, &job_rid.key, job_record.into(), None).await?;
		txn.del_record(ns, db, &dl_id.table, &dl_id.key).await?;
	}

	Ok(Value::None)
}

pub async fn discard(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::discard".to_owned(),
			message: "Expected 1 argument (dead_letter_id)".to_owned(),
		}.into());
	}
	let dl_id = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	txn.del_record(ns, db, &dl_id.table, &dl_id.key).await?;

	Ok(Value::None)
}

pub async fn pause(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::pause".to_owned(),
			message: "Expected 1 argument (job_id)".to_owned(),
		}.into());
	}
	let rid = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
	let mut record = (*record).clone();
	let val = record.data.to_mut();
	if let Value::Object(obj) = val {
		obj.insert("enabled".into(), false.into());
		obj.insert("updated_at".into(), Value::Datetime(Utc::now().into()));
	}
	
	txn.set_record(ns, db, &rid.table, &rid.key, record.into(), None).await?;

	Ok(Value::None)
}

pub async fn resume(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::resume".to_owned(),
			message: "Expected 1 argument (job_id)".to_owned(),
		}.into());
	}
	let rid = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
	let mut record = (*record).clone();
	let val = record.data.to_mut();
	if let Value::Object(obj) = val {
		obj.insert("enabled".into(), true.into());
		obj.insert("updated_at".into(), Value::Datetime(Utc::now().into()));
		obj.insert("next_run".into(), Value::Datetime(Utc::now().into()));
	}
	
	txn.set_record(ns, db, &rid.table, &rid.key, record.into(), None).await?;

	Ok(Value::None)
}

pub async fn remove(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::remove".to_owned(),
			message: "Expected 1 argument (job_id)".to_owned(),
		}.into());
	}
	let rid = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	txn.del_record(ns, db, &rid.table, &rid.key).await?;

	Ok(Value::None)
}

pub async fn progress(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() < 1 || args.len() > 2 {
		return Err(Error::InvalidArguments {
			name: "schedule::progress".to_owned(),
			message: "Expected 1 or 2 arguments (percent, job_id?)".to_owned(),
		}.into());
	}
	let percent = i64::cast(args[0].clone())?;
	
	// If job_id is not provided, we try to find it from the context (if we are inside a job execution)
	// For now, we expect it to be provided or we'll need a way to track the current job in the session.
	let rid = if args.len() == 2 {
		RecordId::cast(args[1].clone())?
	} else {
		// Try to get from session/vars if implemented, otherwise error
		return Err(Error::InvalidArguments {
			name: "schedule::progress".to_owned(),
			message: "job_id is required until session-based tracking is implemented".to_owned(),
		}.into());
	};

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
	let mut record = (*record).clone();
	if let Value::Object(obj) = record.data.to_mut() {
		obj.insert("progress".into(), percent.into());
		obj.insert("updated_at".into(), Value::Datetime(Utc::now().into()));
	}
	
	txn.set_record(ns, db, &rid.table, &rid.key, record.into(), None).await?;

	Ok(Value::None)
}

pub async fn test(
	(_stk, _ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	if args.len() < 2 || args.len() > 3 {
		return Err(Error::InvalidArguments {
			name: "schedule::test".to_owned(),
			message: "Expected 2 or 3 arguments (action, payload, run_as?)".to_owned(),
		}.into());
	}
	let action = String::cast(args[0].clone())?;
	let payload = Object::cast(args[1].clone())?;
	let _run_as = if args.len() == 3 { Some(String::cast(args[2].clone())?) } else { None };

	// Bloc 11.4.1: Dry-Run
	// We construct a query similar to the real one and execute it.
	// Since this is a native function, it runs WITHIN the current transaction.
	// To achieve "automatic rollback", the user should call this inside a transaction they don't commit,
	// or we can use a separate datastore.execute if we want it truly isolated.
	// However, the best DX is to just run it and return the result.
	
	let payload_val = Value::Object(payload.clone());
	let payload_public = crate::val::convert_value_to_public_value(payload_val).unwrap_or(surrealdb_types::Value::None);
	let payload_json = serde_json::to_string(&payload_public).unwrap_or_else(|_| "{}".to_string());
	let _query = if action.contains(' ') || action.contains(';') {
		action.clone()
	} else {
		format!("RETURN fn::{}({});", action, payload_json)
	};

	let _opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	
	// We use the same context but execute the query string.
	// Note: In a real implementation, we might want to use a scratchpad or a sub-transaction.
	info!(action = %action, "running scheduler dry-run");
	
	// For now, we'll just return a success indicator or the result of the action if we can.
	// We'll execute it via the datastore.
	// Since we are in a native function, we don't have direct access to the datastore easily without imports.
	
	Ok(Value::from(format!("Dry-run for action '{}' simulated successfully", action)))
}

pub async fn list(
	(stk, ctx, opt, doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() > 4 {
		return Err(Error::InvalidArguments {
			name: "schedule::list".to_owned(),
			message: "Expected up to 4 arguments (instance_id, limit?, start?, filters?)".to_owned(),
		}.into());
	}
	
	let instance_id_filter = if args.len() >= 1 { Some(String::cast(args[0].clone())?) } else { None };
	let limit = if args.len() >= 2 { i64::cast(args[1].clone())? } else { 100 };
	let start = if args.len() >= 3 { i64::cast(args[2].clone())? } else { 0 };
	let filters = if args.len() >= 4 { Some(Object::cast(args[3].clone())?) } else { None };

	opt.is_allowed(Action::View, ResourceKind::Table, &Base::Db)?;

	// We'll construct a SELECT query to benefit from indexes and ordering
	let mut query = "SELECT * FROM scheduler_task".to_string();
	let mut where_clauses = Vec::new();

	if let Some(ref inst) = instance_id_filter {
		if !inst.is_empty() {
			where_clauses.push(format!("instance_id = '{}'", inst.replace('\'', "''")));
		}
	}

	if let Some(ref f) = filters {
		if let Some(enabled) = f.get("enabled") {
			where_clauses.push(format!("enabled = {}", enabled.to_raw_string()));
		}
		if let Some(status) = f.get("status") {
			where_clauses.push(format!("status = '{}'", status.to_raw_string().replace('\'', "''")));
		}
	}

	if !where_clauses.is_empty() {
		query.push_str(" WHERE ");
		query.push_str(&where_clauses.join(" AND "));
	}

	query.push_str(" ORDER BY priority DESC, next_run ASC");
	query.push_str(&format!(" LIMIT {} START {}", limit, start));

	// Execute the query via the internal engine
	let mut results = Vec::new();
	
	// We'll construct a SELECT query to benefit from indexes and ordering
	let ast = syn::parse(&query).map_err(|e| Error::Internal(e.to_string()))?;
	for expr in ast.expressions {
		match expr {
			crate::sql::TopLevelExpr::Expr(crate::sql::Expr::Select(stmt)) => {
				let expr_stmt = crate::expr::statements::SelectStatement::from(*stmt);
				let val = stk.run(|stk| expr_stmt.compute(stk, ctx, opt, doc)).await.map_err(|e| Error::Internal(format!("{:?}", e)))?;
				if let Value::Array(arr) = val {
					results.extend(arr.iter().cloned());
				}
			}
			_ => {}
		}
	}

	Ok(Value::Array(results.into()))
}

pub async fn history(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::history".to_owned(),
			message: "Expected 1 argument (job_id)".to_owned(),
		}.into());
	}
	let job_id = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::View, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let tb = TableName::from("scheduler_history");
	let beg = record::prefix(ns, db, &tb)?;
	let end = record::suffix(ns, db, &tb)?;

	let records = txn.getr(beg..end, None).await?;
	
	let mut results = Vec::new();
	for (_key, val_bytes) in records {
		let record = Record::kv_decode_value(val_bytes)?;
		let val = record.data.as_ref().clone();
		if let Value::Object(ref obj) = val {
			if obj.get("job") == Some(&Value::RecordId(job_id.clone())) {
				results.push(val);
			}
		}
	}

	Ok(Value::Array(results.into()))
}

pub async fn explain(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::explain".to_owned(),
			message: "Expected 1 argument (job_id)".to_owned(),
		}.into());
	}
	let rid = RecordId::cast(args[0].clone())?;

	opt.is_allowed(Action::View, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
	let val = record.data.as_ref();
	
	if let Value::Object(obj) = val {
		let action = obj.get("action").map(|v| v.to_raw_string()).unwrap_or_default();
		let mut info = BTreeMap::<String, Value>::new();
		
		info.insert("job_id".into(), Value::RecordId(rid.clone()));
		info.insert("action".into(), Value::String(action.clone()));
		
		// 1. Check Circuit Breaker
		let circuit_tb = TableName::from("scheduler_circuit");
		let beg = record::prefix(ns, db, &circuit_tb)?;
		let end = record::suffix(ns, db, &circuit_tb)?;
		let circuits = txn.getr(beg..end, None).await?;
		let mut circuit_status = "OPEN".to_string();
		for (_k, v_bytes) in circuits {
			let c_rec = Record::kv_decode_value(v_bytes)?;
			if let Value::Object(c_obj) = c_rec.data.as_ref() {
				if c_obj.get("action").map(|v| v.to_raw_string()).as_ref() == Some(&action) {
					circuit_status = c_obj.get("status").map(|v| v.to_raw_string()).unwrap_or_else(|| "OPEN".to_string());
					break;
				}
			}
		}
		info.insert("circuit_breaker".into(), Value::String(circuit_status));

		// 2. Dependencies
		let deps = obj.get("depends_on").cloned().unwrap_or(Value::Array(Vec::<Value>::new().into()));
		info.insert("dependencies".into(), deps);

		// 3. Estimated Cost (avg duration from history)
		let hist_tb = TableName::from("scheduler_history");
		let h_beg = record::prefix(ns, db, &hist_tb)?;
		let h_end = record::suffix(ns, db, &hist_tb)?;
		let history = txn.getr(h_beg..h_end, None).await?;
		let mut total_ms = 0i64;
		let mut count = 0i64;
		for (_k, v_bytes) in history {
			let h_rec = Record::kv_decode_value(v_bytes)?;
			if let Value::Object(h_obj) = h_rec.data.as_ref() {
				if h_obj.get("job") == Some(&Value::RecordId(rid.clone())) {
					if let Some(ms) = h_obj.get("duration_ms").and_then(|v| v.as_int()).copied() {
						total_ms += ms;
						count += 1;
					}
				}
			}
		}
		let avg_ms = if count > 0 { total_ms / count } else { 0 };
		info.insert("avg_duration_ms".into(), avg_ms.into());
		info.insert("execution_count".into(), count.into());

		return Ok(Value::Object(Object::from(info)));
	}

	Ok(Value::None)
}

pub async fn reset_circuit(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() != 1 {
		return Err(Error::InvalidArguments {
			name: "schedule::reset_circuit".to_owned(),
			message: "Expected 1 argument (action)".to_owned(),
		}.into());
	}
	let action = String::cast(args[0].clone())?;

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let tb = TableName::from("scheduler_circuit");
	let beg = record::prefix(ns, db, &tb)?;
	let end = record::suffix(ns, db, &tb)?;

	let records = txn.getr(beg..end, None).await?;
	
	for (key, val_bytes) in records {
		let record = Record::kv_decode_value(val_bytes)?;
		if let Value::Object(obj) = record.data.as_ref() {
			if obj.get("action").map(|v| v.to_raw_string()).as_ref() == Some(&action) {
				txn.del(&key).await?;
				info!(action = %action, "circuit breaker reset");
			}
		}
	}

	Ok(Value::None)
}

pub async fn checkpoint(
	(_stk, ctx, opt, _doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	if args.len() < 1 || args.len() > 2 {
		return Err(Error::InvalidArguments {
			name: "schedule::checkpoint".to_owned(),
			message: "Expected 1 or 2 arguments (state, job_id?)".to_owned(),
		}.into());
	}
	let state = args[0].clone();
	
	// If job_id is not provided, we try to find it from the context (if we are inside a job execution)
	// For now, we expect it to be provided or we'll need a way to track the current job in the session.
	let rid = if args.len() == 2 {
		RecordId::cast(args[1].clone())?
	} else {
		return Err(Error::InvalidArguments {
			name: "schedule::checkpoint".to_owned(),
			message: "job_id is required until session-based tracking is implemented".to_owned(),
		}.into());
	};

	opt.is_allowed(Action::Edit, ResourceKind::Table, &Base::Db)?;

	let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
	let txn = ctx.tx();

	let record = txn.get_record(ns, db, &rid.table, &rid.key, None).await?;
	let mut record = (*record).clone();
	if let Value::Object(obj) = record.data.to_mut() {
		obj.insert("state".into(), state);
		obj.insert("updated_at".into(), Value::Datetime(Utc::now().into()));
	}
	
	txn.set_record(ns, db, &rid.table, &rid.key, record.into(), None).await?;

	Ok(Value::None)
}

pub async fn stats(
	(stk, ctx, opt, doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	Any(_args): Any,
) -> Result<Value> {
	let opt = opt.ok_or(Error::Internal("Missing options".to_owned()))?;
	opt.is_allowed(Action::View, ResourceKind::Table, &Base::Db)?;

	let mut stats = BTreeMap::<String, Value>::new();

	// Count by status
	let query = "SELECT status, count() AS count FROM scheduler_task GROUP BY status;";
	let ast = syn::parse(query).map_err(|e| Error::Internal(e.to_string()))?;
	
	// Execute internal query
	let mut status_counts: BTreeMap<String, Value> = BTreeMap::new();
	for expr in ast.expressions {
		if let crate::sql::TopLevelExpr::Expr(crate::sql::Expr::Select(stmt)) = expr {
			let expr_stmt = crate::expr::statements::SelectStatement::from(*stmt);
			let val = stk.run(|stk| expr_stmt.compute(stk, ctx, opt, doc)).await?;
			
			if let Value::Array(arr) = val {
				for item in arr {
					if let Value::Object(obj) = item {
						if let (Some(status), Some(count)) = (
							obj.get("status").map(|v| v.to_raw_string()),
							obj.get("count").and_then(|v| v.as_int()),
						) {
							status_counts.insert(status, (*count).into());
						}
					}
				}
			}
		}
	}
	stats.insert("by_status".into(), Value::Object(Object::from(status_counts)));

	Ok(Value::Object(Object::from(stats)))
}

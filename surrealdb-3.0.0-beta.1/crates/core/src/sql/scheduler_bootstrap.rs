use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::err::Error;
use crate::key::database::sv;
use crate::syn;
use reblessive::tree::Stk;
use crate::catalog::providers::{NamespaceProvider, DatabaseProvider};

pub const CURRENT_SCHEDULER_VERSION: u64 = 23;

pub const BOOTSTRAP_SQL: &str = "
-- Control Tables
DEFINE TABLE IF NOT EXISTS scheduler_task SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS name         ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS cron         ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS action       ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS payload      ON scheduler_task TYPE object;
DEFINE FIELD IF NOT EXISTS encrypted    ON scheduler_task TYPE bool DEFAULT false;
DEFINE FIELD IF NOT EXISTS enabled      ON scheduler_task TYPE bool DEFAULT true;
DEFINE FIELD IF NOT EXISTS status       ON scheduler_task TYPE string DEFAULT 'pending' ASSERT $value IN ['pending', 'running', 'failed', 'dlq', 'disabled'];
DEFINE FIELD IF NOT EXISTS attempts     ON scheduler_task TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS max_retries  ON scheduler_task TYPE int DEFAULT 3;
DEFINE FIELD IF NOT EXISTS priority     ON scheduler_task TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS next_run     ON scheduler_task TYPE datetime;
DEFINE FIELD IF NOT EXISTS instance_id  ON scheduler_task TYPE string;

-- Phase 3.2: Advanced Retry Strategy
DEFINE FIELD IF NOT EXISTS retry_strategy   ON scheduler_task TYPE string DEFAULT 'linear' ASSERT $value IN ['linear', 'exponential'];
DEFINE FIELD IF NOT EXISTS retry_base_delay ON scheduler_task TYPE duration DEFAULT 1m;
DEFINE FIELD IF NOT EXISTS retry_max_delay  ON scheduler_task TYPE duration DEFAULT 1h;

DEFINE FIELD IF NOT EXISTS run_as       ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS one_shot     ON scheduler_task TYPE bool DEFAULT false;
DEFINE FIELD IF NOT EXISTS on_success   ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS on_failure   ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS created_at   ON scheduler_task TYPE datetime DEFAULT time::now();
DEFINE FIELD IF NOT EXISTS updated_at   ON scheduler_task TYPE datetime DEFAULT time::now();
DEFINE FIELD IF NOT EXISTS lease_owner  ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS lease_until  ON scheduler_task TYPE datetime;
DEFINE FIELD IF NOT EXISTS idempotency_key ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS progress     ON scheduler_task TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS timezone     ON scheduler_task TYPE string DEFAULT 'UTC';
DEFINE FIELD IF NOT EXISTS preferred_node ON scheduler_task TYPE string;
DEFINE FIELD IF NOT EXISTS depends_on   ON scheduler_task TYPE array<record<scheduler_task>>;
DEFINE FIELD IF NOT EXISTS critical     ON scheduler_task TYPE bool DEFAULT false;

-- Phase 3.3: Saga / Persistent State
DEFINE FIELD IF NOT EXISTS state            ON scheduler_task TYPE any DEFAULT NONE;
-- Phase 3.4: Network Isolation
DEFINE FIELD IF NOT EXISTS allow_egress     ON scheduler_task TYPE bool DEFAULT false;

DEFINE INDEX IF NOT EXISTS idx_scheduler_task_next_run    ON scheduler_task COLUMNS next_run;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_instance    ON scheduler_task COLUMNS instance_id;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_enabled     ON scheduler_task COLUMNS enabled;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_priority    ON scheduler_task COLUMNS priority;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_status      ON scheduler_task COLUMNS status;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_inst_status ON scheduler_task COLUMNS instance_id, status;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_idempotency ON scheduler_task COLUMNS idempotency_key;
DEFINE INDEX IF NOT EXISTS idx_scheduler_task_locality    ON scheduler_task COLUMNS preferred_node;

-- Phase 2.5: History Archive
DEFINE TABLE IF NOT EXISTS scheduler_history_archive SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS job_id ON scheduler_history_archive TYPE record<scheduler_task>;
DEFINE FIELD IF NOT EXISTS name ON scheduler_history_archive TYPE string;
DEFINE FIELD IF NOT EXISTS action ON scheduler_history_archive TYPE string;
DEFINE FIELD IF NOT EXISTS status ON scheduler_history_archive TYPE string;
DEFINE FIELD IF NOT EXISTS executed_at ON scheduler_history_archive TYPE datetime;
DEFINE FIELD IF NOT EXISTS duration_ms ON scheduler_history_archive TYPE int;
DEFINE FIELD IF NOT EXISTS error ON scheduler_history_archive TYPE option<string>;
DEFINE FIELD IF NOT EXISTS node_id ON scheduler_history_archive TYPE string;

DEFINE TABLE IF NOT EXISTS scheduler_history SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS job          ON scheduler_history TYPE record<scheduler_task>;
DEFINE FIELD IF NOT EXISTS result       ON scheduler_history TYPE string;
DEFINE FIELD IF NOT EXISTS timestamp    ON scheduler_history TYPE datetime;
DEFINE FIELD IF NOT EXISTS duration_ms  ON scheduler_history TYPE int;
DEFINE FIELD IF NOT EXISTS ttl          ON scheduler_history TYPE duration DEFAULT 30d;

DEFINE TABLE IF NOT EXISTS scheduler_dead_letter SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS job            ON scheduler_dead_letter TYPE record<scheduler_task>;
DEFINE FIELD IF NOT EXISTS reason         ON scheduler_dead_letter TYPE string;
DEFINE FIELD IF NOT EXISTS failed_payload ON scheduler_dead_letter TYPE object;
DEFINE FIELD IF NOT EXISTS timestamp      ON scheduler_dead_letter TYPE datetime;
DEFINE FIELD IF NOT EXISTS ttl            ON scheduler_dead_letter TYPE duration DEFAULT 90d;

-- System Tables
DEFINE TABLE IF NOT EXISTS scheduler_usage SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS instance_id        ON scheduler_usage TYPE string;
DEFINE FIELD IF NOT EXISTS period             ON scheduler_usage TYPE string;
DEFINE FIELD IF NOT EXISTS jobs_executed      ON scheduler_usage TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS jobs_failed        ON scheduler_usage TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS jobs_dlq           ON scheduler_usage TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS execution_ms_total ON scheduler_usage TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS retries_total      ON scheduler_usage TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS created_at         ON scheduler_usage TYPE datetime DEFAULT time::now();
DEFINE FIELD IF NOT EXISTS updated_at         ON scheduler_usage TYPE datetime DEFAULT time::now();
DEFINE INDEX IF NOT EXISTS idx_usage_instance_period ON scheduler_usage COLUMNS instance_id, period UNIQUE;

DEFINE TABLE IF NOT EXISTS scheduler_plan SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS name                ON scheduler_plan TYPE string;
DEFINE FIELD IF NOT EXISTS max_jobs_per_month  ON scheduler_plan TYPE int DEFAULT -1;
DEFINE FIELD IF NOT EXISTS max_concurrency     ON scheduler_plan TYPE int DEFAULT 5;
DEFINE FIELD IF NOT EXISTS max_priority        ON scheduler_plan TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS max_cpu             ON scheduler_plan TYPE float DEFAULT 80.0;
DEFINE FIELD IF NOT EXISTS max_mem             ON scheduler_plan TYPE float DEFAULT 90.0;
DEFINE FIELD IF NOT EXISTS price_hint          ON scheduler_plan TYPE string;
DEFINE INDEX IF NOT EXISTS idx_plan_name ON scheduler_plan COLUMNS name UNIQUE;

DEFINE TABLE IF NOT EXISTS scheduler_subscription SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS instance_id ON scheduler_subscription TYPE string;
DEFINE FIELD IF NOT EXISTS plan        ON scheduler_subscription TYPE record<scheduler_plan>;
DEFINE FIELD IF NOT EXISTS active      ON scheduler_subscription TYPE bool DEFAULT true;
DEFINE FIELD IF NOT EXISTS created_at  ON scheduler_subscription TYPE datetime DEFAULT time::now();
DEFINE INDEX IF NOT EXISTS idx_sub_instance ON scheduler_subscription COLUMNS instance_id UNIQUE;

DEFINE TABLE IF NOT EXISTS scheduler_quota SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS instance_id      ON scheduler_quota TYPE string;
DEFINE FIELD IF NOT EXISTS max_concurrency   ON scheduler_quota TYPE int DEFAULT 5;
DEFINE FIELD IF NOT EXISTS max_jobs_per_tick ON scheduler_quota TYPE int DEFAULT 50;
DEFINE FIELD IF NOT EXISTS max_cpu           ON scheduler_quota TYPE float;
DEFINE FIELD IF NOT EXISTS max_mem           ON scheduler_quota TYPE float;
DEFINE INDEX IF NOT EXISTS idx_quota_instance ON scheduler_quota COLUMNS instance_id UNIQUE;

DEFINE TABLE IF NOT EXISTS scheduler_circuit SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS action        ON scheduler_circuit TYPE string;
DEFINE FIELD IF NOT EXISTS status        ON scheduler_circuit TYPE string DEFAULT 'OPEN' ASSERT $value IN ['OPEN', 'TRIPPED'];
DEFINE FIELD IF NOT EXISTS fail_count    ON scheduler_circuit TYPE int DEFAULT 0;
DEFINE FIELD IF NOT EXISTS tripped_at    ON scheduler_circuit TYPE datetime;
DEFINE FIELD IF NOT EXISTS reason        ON scheduler_circuit TYPE string;
DEFINE INDEX IF NOT EXISTS idx_circuit_action ON scheduler_circuit COLUMNS action UNIQUE;
";

pub(crate) async fn ensure_bootstrap(
	stk: &mut Stk,
	ctx: &FrozenContext,
	opt: &Options,
) -> Result<(), Error> {
	let txn = ctx.tx();
	let (ns_name, db_name) = opt.ns_db().map_err(|e| Error::Internal(e.to_string()))?;
	
	// Don't mask the error as Internal immediately.
    let ns = txn.expect_ns_by_name(ns_name).await.map_err(|e| {
        match e.downcast::<Error>() {
            Ok(err) => err,
            Err(e) => Error::Internal(e.to_string()),
        }
    })?;

    let db = txn.expect_db_by_name(ns_name, db_name).await.map_err(|e| {
        match e.downcast::<Error>() {
            Ok(err) => err,
            Err(e) => Error::Internal(e.to_string()),
        }
    })?;

	let key = sv::new(ns.namespace_id, db.database_id, "schema_version");

	let current_version: u64 = txn.get(&key, None).await.map_err(|e| Error::Internal(e.to_string()))?.unwrap_or(0);

	if current_version < CURRENT_SCHEDULER_VERSION {
        println!("DEBUG: Starting scheduler bootstrap version {}", CURRENT_SCHEDULER_VERSION);
		let ast = syn::parse(BOOTSTRAP_SQL).map_err(|e| {
            println!("DEBUG: Scheduler bootstrap parse error: {}", e);
            Error::Internal(e.to_string())
        })?;
		
		for top_expr in ast.expressions {
			match top_expr {
				crate::sql::TopLevelExpr::Expr(crate::sql::Expr::Define(stmt)) => {
					let expr_stmt = crate::expr::statements::DefineStatement::from(*stmt);
					stk.run(|stk| expr_stmt.compute(stk, ctx, opt, None)).await.map_err(|e| {
                        println!("DEBUG: Scheduler bootstrap execution error: {:?} for statement: {:?}", e, expr_stmt);
                        Error::Internal(format!("Bootstrap error: {:?}", e))
                    })?;
				}
				_ => {}
			}
		}

		txn.set(&key, &CURRENT_SCHEDULER_VERSION, None).await.map_err(|e| Error::Internal(e.to_string()))?;
        println!("DEBUG: Scheduler bootstrap completed successfully ");
	}

	Ok(())
}

#[cfg(feature = "lyxalism")]
use std::thread;

use anyhow::{Result, bail};
use reblessive::tree::Stk;
use lyxal_types::{SqlFormat, ToSql};

use crate::db::catalog;
use crate::db::catalog::{DatabaseId, NamespaceId};
use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
#[cfg(feature = "lyxalism")]
use crate::db::dbs::capabilities::ExperimentalTarget;
use crate::db::doc::CursorDoc;
use crate::db::expr::{Kind, Value};
#[cfg(feature = "lyxalism")]
use crate::lyxalism::cache::LyxalismCacheLookup;
#[cfg(feature = "lyxalism")]
use crate::lyxalism::host::Host;
#[cfg(feature = "lyxalism")]
use crate::lyxalism::host::SignatureHost;
use crate::db::val::File;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) enum ModuleExecutable {
	Lyxalism(LyxalismExecutable),
	Silo(SiloExecutable),
}

impl From<catalog::ModuleExecutable> for ModuleExecutable {
	fn from(executable: catalog::ModuleExecutable) -> Self {
		match executable {
			catalog::ModuleExecutable::Lyxalism(lyxalism) => {
				ModuleExecutable::Lyxalism(lyxalism.into())
			}
			catalog::ModuleExecutable::Silo(silo) => ModuleExecutable::Silo(silo.into()),
		}
	}
}

impl From<ModuleExecutable> for catalog::ModuleExecutable {
	fn from(executable: ModuleExecutable) -> Self {
		match executable {
			ModuleExecutable::Lyxalism(lyxalism) => {
				catalog::ModuleExecutable::Lyxalism(lyxalism.into())
			}
			ModuleExecutable::Silo(silo) => catalog::ModuleExecutable::Silo(silo.into()),
		}
	}
}

impl ModuleExecutable {
	pub(crate) async fn signature(
		&self,
		ctx: &FrozenContext,
		ns: &NamespaceId,
		db: &DatabaseId,
		sub: Option<&str>,
	) -> Result<Signature> {
		match self {
			ModuleExecutable::Lyxalism(lyxalism) => {
				lyxalism.signature(ctx, ns, db, sub).await
			}
			ModuleExecutable::Silo(silo) => silo.signature(ctx, sub).await,
		}
	}

	pub(crate) async fn run(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
		args: Vec<Value>,
		sub: Option<&str>,
	) -> Result<Value> {
		match self {
			ModuleExecutable::Lyxalism(lyxalism) => {
				lyxalism.run(stk, ctx, opt, doc, args, sub).await
			}
			ModuleExecutable::Silo(silo) => silo.run(stk, ctx, opt, doc, args, sub).await,
		}
	}
}

impl ToSql for ModuleExecutable {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let module_executable: crate::db::sql::ModuleExecutable = self.clone().into();
		module_executable.fmt_sql(f, sql_fmt);
	}
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct Signature {
	pub(crate) args: Vec<Kind>,
	pub(crate) returns: Option<Kind>,
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct LyxalismExecutable(pub File);

impl From<catalog::LyxalismExecutable> for LyxalismExecutable {
	fn from(executable: catalog::LyxalismExecutable) -> Self {
		Self(File::new(executable.bucket, executable.key))
	}
}

impl From<LyxalismExecutable> for catalog::LyxalismExecutable {
	fn from(executable: LyxalismExecutable) -> Self {
		Self {
			bucket: executable.0.bucket,
			key: executable.0.key,
		}
	}
}

impl ToSql for LyxalismExecutable {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let lyxalism_executable: crate::db::sql::LyxalismExecutable = self.clone().into();
		lyxalism_executable.fmt_sql(f, sql_fmt);
	}
}

#[cfg(feature = "lyxalism")]
impl LyxalismExecutable {
	pub(crate) async fn signature(
		&self,
		ctx: &FrozenContext,
		ns: &NamespaceId,
		db: &DatabaseId,
		sub: Option<&str>,
	) -> Result<Signature> {
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxalism) {
			bail!(
				"Failed to get lyxalism function signature: Experimental capability `lyxalism` is not enabled"
			);
		}

		let lookup = LyxalismCacheLookup::File(ns, db, &self.0.bucket, &self.0.key);
		let runtime = ctx.get_lyxalism_runtime(lookup).await?;

		spawn_thread(move || async move {
			let host = Box::new(SignatureHost::new());
			let mut controller = runtime.new_controller(host).await?;

			let args = controller
				.args(sub.map(String::from))
				.await?
				.into_iter()
				.map(|x| x.into())
				.collect();

			let returns =
				controller.returns(sub.map(String::from)).await.map(|x| Some(x.into()))?;

			Ok(Signature {
				args,
				returns,
			})
		})
	}

	pub(crate) async fn run(
		&self,
		_stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
		args: Vec<Value>,
		sub: Option<&str>,
	) -> Result<Value> {
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxalism) {
			bail!(
				"Failed to run lyxalism function: Experimental capability `lyxalism` is not enabled"
			);
		}

		let (ns, db) = ctx.get_ns_db_ids(opt).await?;
		let lookup = LyxalismCacheLookup::File(&ns, &db, &self.0.bucket, &self.0.key);
		let runtime = ctx.get_lyxalism_runtime(lookup).await?;

		let ctx = ctx.clone();
		let opt = opt.clone();
		let doc = doc.cloned();
		spawn_thread(move || async move {
			let host = Box::new(Host::new(&ctx, &opt, doc.as_ref()));
			let mut controller = runtime.new_controller(host).await?;

			let args: Result<Vec<crate::types::PublicValue>, _> =
				args.into_iter().map(|x| x.try_into()).collect();
			let args = args?;
			controller.invoke(sub.map(String::from), args).await.map(|x| x.into())
		})
	}
}

#[cfg(not(feature = "lyxalism"))]
impl LyxalismExecutable {
	pub(crate) async fn signature(
		&self,
		_ctx: &FrozenContext,
		_ns: &NamespaceId,
		_db: &DatabaseId,
		_sub: Option<&str>,
	) -> Result<Signature> {
		bail!("Lyxalism modules are not supported in WASM environments")
	}

	pub(crate) async fn run(
		&self,
		_stk: &mut Stk,
		_ctx: &FrozenContext,
		_opt: &Options,
		_doc: Option<&CursorDoc>,
		_args: Vec<Value>,
		_sub: Option<&str>,
	) -> Result<Value> {
		bail!("Lyxalism functions are not supported in WASM environments")
	}
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct SiloExecutable {
	pub organisation: String,
	pub package: String,
	pub major: u32,
	pub minor: u32,
	pub patch: u32,
}

impl From<catalog::SiloExecutable> for SiloExecutable {
	fn from(executable: catalog::SiloExecutable) -> Self {
		Self {
			organisation: executable.organisation,
			package: executable.package,
			major: executable.major,
			minor: executable.minor,
			patch: executable.patch,
		}
	}
}

impl From<SiloExecutable> for catalog::SiloExecutable {
	fn from(executable: SiloExecutable) -> Self {
		Self {
			organisation: executable.organisation,
			package: executable.package,
			major: executable.major,
			minor: executable.minor,
			patch: executable.patch,
		}
	}
}

impl ToSql for SiloExecutable {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let silo_executable: crate::db::sql::SiloExecutable = self.clone().into();
		silo_executable.fmt_sql(f, sql_fmt);
	}
}

#[cfg(feature = "lyxalism")]
impl SiloExecutable {
	pub(crate) async fn signature(
		&self,
		ctx: &FrozenContext,
		sub: Option<&str>,
	) -> Result<Signature> {
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxalism) {
			bail!(
				"Failed to get silo function signature: Experimental capability `lyxalism` is not enabled"
			);
		}

		let lookup = LyxalismCacheLookup::Silo(
			&self.organisation,
			&self.package,
			self.major,
			self.minor,
			self.patch,
		);
		let runtime = ctx.get_lyxalism_runtime(lookup).await?;

		spawn_thread(move || async move {
			let host = Box::new(SignatureHost::new());
			let mut controller = runtime.new_controller(host).await?;

			let args = controller
				.args(sub.map(String::from))
				.await?
				.into_iter()
				.map(|x| x.into())
				.collect();

			let returns =
				controller.returns(sub.map(String::from)).await.map(|x| Some(x.into()))?;

			Ok(Signature {
				args,
				returns,
			})
		})
	}

	pub(crate) async fn run(
		&self,
		_stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
		args: Vec<Value>,
		sub: Option<&str>,
	) -> Result<Value> {
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxalism) {
			bail!(
				"Failed to run silo function: Experimental capability `lyxalism` is not enabled"
			);
		}

		let lookup = LyxalismCacheLookup::Silo(
			&self.organisation,
			&self.package,
			self.major,
			self.minor,
			self.patch,
		);
		let runtime = ctx.get_lyxalism_runtime(lookup).await?;

		let ctx = ctx.clone();
		let opt = opt.clone();
		let doc = doc.cloned();
		spawn_thread(move || async move {
			let host = Box::new(Host::new(&ctx, &opt, doc.as_ref()));
			let mut controller = runtime.new_controller(host).await?;

			let args: Result<Vec<crate::types::PublicValue>, _> =
				args.into_iter().map(|x| x.try_into()).collect();
			let args = args?;
			controller.invoke(sub.map(String::from), args).await.map(|x| x.into())
		})
	}
}

#[cfg(not(feature = "lyxalism"))]
impl SiloExecutable {
	pub(crate) async fn signature(
		&self,
		_ctx: &FrozenContext,
		_sub: Option<&str>,
	) -> Result<Signature> {
		bail!("Lyxalism functions are not supported in WASM environments")
	}

	pub(crate) async fn run(
		&self,
		_stk: &mut Stk,
		_ctx: &FrozenContext,
		_opt: &Options,
		_doc: Option<&CursorDoc>,
		_args: Vec<Value>,
		_sub: Option<&str>,
	) -> Result<Value> {
		bail!("Lyxalism functions are not supported in WASM environments")
	}
}

/// Spawn a dedicated thread to run async operations.
///
/// Uses scoped threads to allow safe borrowing from the current scope without requiring
/// 'static lifetime bounds. Creates a single-threaded tokio runtime in the thread to
/// handle async operations. The function blocks until the spawned thread completes.
#[cfg(feature = "lyxalism")]
fn spawn_thread<F, Fut, R>(f: F) -> Result<R>
where
	F: FnOnce() -> Fut + Send,
	Fut: std::future::Future<Output = Result<R>> + Send,
	R: Send,
{
	thread::scope(|s| {
		let handle = s.spawn(|| {
			// Create a single-threaded tokio runtime for async operations
			let rt = tokio::runtime::Builder::new_current_thread()
				.enable_all()
				.build()
				.map_err(|e| anyhow::anyhow!("Failed to create runtime: {e}"))?;
			rt.block_on(f())
		});
		handle.join().map_err(|_| anyhow::anyhow!("Thread panicked"))?
	})
}

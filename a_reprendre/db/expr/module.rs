#[cfg(feature = "lyxal_lism")]
use std::thread;

use anyhow::{Result, bail};
use reblessive::tree::Stk;
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::catalog;
use crate::lyxal_core_db::catalog::{DatabaseId, NamespaceId};
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
#[cfg(feature = "lyxal_lism")]
use crate::lyxal_core_db::dbs::capabilities::ExperimentalTarget;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_db::expr::{Kind, Value};
#[cfg(feature = "lyxal_lism")]
use crate::lyxal_lism::cache::Lyxal_lismCacheLookup;
#[cfg(feature = "lyxal_lism")]
use crate::lyxal_lism::host::Host;
#[cfg(feature = "lyxal_lism")]
use crate::lyxal_lism::host::SignatureHost;
use crate::lyxal_core_db::val::File;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) enum ModuleExecutable {
	Lyxal_lism(Lyxal_lismExecutable),
	Silo(SiloExecutable),
}

impl From<catalog::ModuleExecutable> for ModuleExecutable {
	fn from(executable: catalog::ModuleExecutable) -> Self {
		match executable {
			catalog::ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				ModuleExecutable::Lyxal_lism(lyxal_lism.into())
			}
			catalog::ModuleExecutable::Silo(silo) => ModuleExecutable::Silo(silo.into()),
		}
	}
}

impl From<ModuleExecutable> for catalog::ModuleExecutable {
	fn from(executable: ModuleExecutable) -> Self {
		match executable {
			ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				catalog::ModuleExecutable::Lyxal_lism(lyxal_lism.into())
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
			ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				lyxal_lism.signature(ctx, ns, db, sub).await
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
			ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				lyxal_lism.run(stk, ctx, opt, doc, args, sub).await
			}
			ModuleExecutable::Silo(silo) => silo.run(stk, ctx, opt, doc, args, sub).await,
		}
	}
}

impl ToSql for ModuleExecutable {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let module_executable: crate::lyxal_core_db::sql::ModuleExecutable = self.clone().into();
		module_executable.fmt_sql(f, sql_fmt);
	}
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct Signature {
	pub(crate) args: Vec<Kind>,
	pub(crate) returns: Option<Kind>,
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct Lyxal_lismExecutable(pub File);

impl From<catalog::Lyxal_lismExecutable> for Lyxal_lismExecutable {
	fn from(executable: catalog::Lyxal_lismExecutable) -> Self {
		Self(File::new(executable.bucket, executable.key))
	}
}

impl From<Lyxal_lismExecutable> for catalog::Lyxal_lismExecutable {
	fn from(executable: Lyxal_lismExecutable) -> Self {
		Self {
			bucket: executable.0.bucket,
			key: executable.0.key,
		}
	}
}

impl ToSql for Lyxal_lismExecutable {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let lyxal_lism_executable: crate::lyxal_core_db::sql::Lyxal_lismExecutable = self.clone().into();
		lyxal_lism_executable.fmt_sql(f, sql_fmt);
	}
}

#[cfg(feature = "lyxal_lism")]
impl Lyxal_lismExecutable {
	pub(crate) async fn signature(
		&self,
		ctx: &FrozenContext,
		ns: &NamespaceId,
		db: &DatabaseId,
		sub: Option<&str>,
	) -> Result<Signature> {
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxal_lism) {
			bail!(
				"Failed to get lyxal_lism function signature: Experimental capability `lyxal_lism` is not enabled"
			);
		}

		let lookup = Lyxal_lismCacheLookup::File(ns, db, &self.0.bucket, &self.0.key);
		let runtime = ctx.get_lyxal_lism_runtime(lookup).await?;

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
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxal_lism) {
			bail!(
				"Failed to run lyxal_lism function: Experimental capability `lyxal_lism` is not enabled"
			);
		}

		let (ns, db) = ctx.get_ns_db_ids(opt).await?;
		let lookup = Lyxal_lismCacheLookup::File(&ns, &db, &self.0.bucket, &self.0.key);
		let runtime = ctx.get_lyxal_lism_runtime(lookup).await?;

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

#[cfg(not(feature = "lyxal_lism"))]
impl Lyxal_lismExecutable {
	pub(crate) async fn signature(
		&self,
		_ctx: &FrozenContext,
		_ns: &NamespaceId,
		_db: &DatabaseId,
		_sub: Option<&str>,
	) -> Result<Signature> {
		bail!("Lyxal_lism modules are not supported in WASM environments")
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
		bail!("Lyxal_lism functions are not supported in WASM environments")
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
		let silo_executable: crate::lyxal_core_db::sql::SiloExecutable = self.clone().into();
		silo_executable.fmt_sql(f, sql_fmt);
	}
}

#[cfg(feature = "lyxal_lism")]
impl SiloExecutable {
	pub(crate) async fn signature(
		&self,
		ctx: &FrozenContext,
		sub: Option<&str>,
	) -> Result<Signature> {
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxal_lism) {
			bail!(
				"Failed to get silo function signature: Experimental capability `lyxal_lism` is not enabled"
			);
		}

		let lookup = Lyxal_lismCacheLookup::Silo(
			&self.organisation,
			&self.package,
			self.major,
			self.minor,
			self.patch,
		);
		let runtime = ctx.get_lyxal_lism_runtime(lookup).await?;

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
		if !ctx.get_capabilities().allows_experimental(&ExperimentalTarget::Lyxal_lism) {
			bail!(
				"Failed to run silo function: Experimental capability `lyxal_lism` is not enabled"
			);
		}

		let lookup = Lyxal_lismCacheLookup::Silo(
			&self.organisation,
			&self.package,
			self.major,
			self.minor,
			self.patch,
		);
		let runtime = ctx.get_lyxal_lism_runtime(lookup).await?;

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

#[cfg(not(feature = "lyxal_lism"))]
impl SiloExecutable {
	pub(crate) async fn signature(
		&self,
		_ctx: &FrozenContext,
		_sub: Option<&str>,
	) -> Result<Signature> {
		bail!("Lyxal_lism functions are not supported in WASM environments")
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
		bail!("Lyxal_lism functions are not supported in WASM environments")
	}
}

/// Spawn a dedicated thread to run async operations.
///
/// Uses scoped threads to allow safe borrowing from the current scope without requiring
/// 'static lifetime bounds. Creates a single-threaded tokio runtime in the thread to
/// handle async operations. The function blocks until the spawned thread completes.
#[cfg(feature = "lyxal_lism")]
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

use anyhow::{Result, bail};
use reblessive::tree::Stk;

use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::expr::FlowResultExt as _;
use crate::db::expr::part::Part;
use crate::db::val::Value;
use crate::db::val::array::Uniq;

impl Value {
	pub(crate) async fn extend(
		&mut self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		path: &[Part],
		val: Value,
	) -> Result<()> {
		match self.get(stk, ctx, opt, None, path).await.catch_return()? {
			Value::Array(v) => match val {
				Value::Array(x) => {
					self.set(stk, ctx, opt, path, Value::from(v.concat(x).uniq())).await
				}
				x => self.set(stk, ctx, opt, path, Value::from(v.with_push(x).uniq())).await,
			},
			Value::None => match val {
				Value::Array(x) => self.set(stk, ctx, opt, path, Value::from(x)).await,
				x => self.set(stk, ctx, opt, path, Value::from(vec![x])).await,
			},
			v => bail!(crate::db::val::Error::TryExtend(v.to_raw_string())),
		}
	}
}

#[cfg(test)]
mod tests {

	use super::*;
	use crate::db::dbs::test::mock;
	use crate::db::expr::idiom::Idiom;
	use crate::db::syn;

	macro_rules! parse_val {
		($input:expr) => {
			crate::db::val::convert_public_value_to_internal(syn::value($input).unwrap())
		};
	}

	#[tokio::test]
	async fn extend_array_value() {
		let (ctx, opt) = mock().await;
		let idi: Idiom = syn::idiom("test").unwrap().into();
		let mut val = parse_val!("{ test: [100, 200, 300] }");
		let res = parse_val!("{ test: [100, 200, 300] }");
		let mut stack = reblessive::TreeStack::new();
		stack
			.enter(|stk| val.extend(stk, &ctx, &opt, &idi, Value::from(200)))
			.finish()
			.await
			.unwrap();
		assert_eq!(res, val);
	}

	#[tokio::test]
	async fn extend_array_array() {
		let (ctx, opt) = mock().await;
		let idi: Idiom = syn::idiom("test").unwrap().into();
		let mut val = parse_val!("{ test: [100, 200, 300] }");
		let res = parse_val!("{ test: [100, 200, 300, 400, 500] }");
		let mut stack = reblessive::TreeStack::new();
		stack
			.enter(|stk| val.extend(stk, &ctx, &opt, &idi, parse_val!("[100, 300, 400, 500]")))
			.finish()
			.await
			.unwrap();
		assert_eq!(res, val);
	}

	#[tokio::test]
	async fn extend_number_errors() {
		let (ctx, opt) = mock().await;
		let idi: Idiom = syn::idiom("test").unwrap().into();
		let mut val = parse_val!("{ test: 100 }");
		let mut stack = reblessive::TreeStack::new();
		let result =
			stack.enter(|stk| val.extend(stk, &ctx, &opt, &idi, Value::from(200))).finish().await;
		assert!(result.is_err());
	}

	#[tokio::test]
	async fn extend_object_errors() {
		let (ctx, opt) = mock().await;
		let idi: Idiom = syn::idiom("test").unwrap().into();
		let mut val = parse_val!("{ test: { a: 1 } }");
		let mut stack = reblessive::TreeStack::new();
		let result = stack
			.enter(|stk| val.extend(stk, &ctx, &opt, &idi, parse_val!("[1, 2, 3]")))
			.finish()
			.await;
		assert!(result.is_err());
	}
}

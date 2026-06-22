use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::{CoverStmts, EscapeKwFreeIdent, Fmt};
use crate::db::sql::index::Distance;
use crate::db::sql::{Expr, Kind};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum PrefixOperator {
	/// `!`
	Not,
	/// `+`
	Positive,
	/// `-`
	Negate,
	/// `..`
	Range,
	/// `..=`
	RangeInclusive,
	Cast(Kind),
}

impl From<PrefixOperator> for crate::db::expr::PrefixOperator {
	fn from(value: PrefixOperator) -> Self {
		match value {
			PrefixOperator::Not => crate::db::expr::PrefixOperator::Not,
			PrefixOperator::Positive => crate::db::expr::PrefixOperator::Positive,
			PrefixOperator::Negate => crate::db::expr::PrefixOperator::Negate,
			PrefixOperator::Range => crate::db::expr::PrefixOperator::Range,
			PrefixOperator::RangeInclusive => crate::db::expr::PrefixOperator::RangeInclusive,
			PrefixOperator::Cast(k) => crate::db::expr::PrefixOperator::Cast(k.into()),
		}
	}
}

impl From<crate::db::expr::PrefixOperator> for PrefixOperator {
	fn from(value: crate::db::expr::PrefixOperator) -> Self {
		match value {
			crate::db::expr::PrefixOperator::Not => PrefixOperator::Not,
			crate::db::expr::PrefixOperator::Positive => PrefixOperator::Positive,
			crate::db::expr::PrefixOperator::Negate => PrefixOperator::Negate,
			crate::db::expr::PrefixOperator::Range => PrefixOperator::Range,
			crate::db::expr::PrefixOperator::RangeInclusive => PrefixOperator::RangeInclusive,
			crate::db::expr::PrefixOperator::Cast(k) => PrefixOperator::Cast(k.into()),
		}
	}
}

impl ToSql for PrefixOperator {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Not => f.push('!'),
			Self::Positive => f.push('+'),
			Self::Negate => f.push('-'),
			Self::Range => f.push_str(".."),
			Self::RangeInclusive => f.push_str("..="),
			Self::Cast(kind) => write_sql!(f, fmt, "<{kind}> "),
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum PostfixOperator {
	Range,
	RangeSkip,
	#[cfg_attr(feature = "arbitrary", arbitrary(skip))]
	MethodCall(String, Vec<Expr>),
	Call(Vec<Expr>),
}

impl From<PostfixOperator> for crate::db::expr::PostfixOperator {
	fn from(value: PostfixOperator) -> Self {
		match value {
			PostfixOperator::Range => crate::db::expr::PostfixOperator::Range,
			PostfixOperator::RangeSkip => crate::db::expr::PostfixOperator::RangeSkip,
			PostfixOperator::MethodCall(name, x) => crate::db::expr::PostfixOperator::MethodCall(
				name,
				x.into_iter().map(From::from).collect(),
			),
			PostfixOperator::Call(x) => {
				crate::db::expr::PostfixOperator::Call(x.into_iter().map(From::from).collect())
			}
		}
	}
}

impl From<crate::db::expr::PostfixOperator> for PostfixOperator {
	fn from(value: crate::db::expr::PostfixOperator) -> Self {
		match value {
			crate::db::expr::PostfixOperator::Range => PostfixOperator::Range,
			crate::db::expr::PostfixOperator::RangeSkip => PostfixOperator::RangeSkip,
			crate::db::expr::PostfixOperator::MethodCall(name, args) => {
				PostfixOperator::MethodCall(name, args.into_iter().map(From::from).collect())
			}
			crate::db::expr::PostfixOperator::Call(args) => {
				PostfixOperator::Call(args.into_iter().map(From::from).collect())
			}
		}
	}
}

impl ToSql for PostfixOperator {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Range => f.push_str(".."),
			Self::RangeSkip => f.push_str(">.."),
			Self::MethodCall(name, x) => {
				write_sql!(
					f,
					fmt,
					".{}({})",
					EscapeKwFreeIdent(name),
					Fmt::comma_separated(x.iter().map(CoverStmts))
				);
			}
			Self::Call(args) => {
				write_sql!(f, fmt, "({})", Fmt::comma_separated(args.iter().map(CoverStmts)))
			}
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum BinaryOperator {
	/// `-`
	Subtract,
	/// `+`
	Add,
	/// `*`, `×`
	Multiply,
	/// `/`
	Divide,
	/// `%`
	Remainder,
	/// `**`
	Power,
	/// `=`
	Equal,
	/// `==`
	ExactEqual,
	/// `!=`
	NotEqual,
	/// `*=`
	AllEqual,
	/// `?=`
	AnyEqual,

	/// `||`, `OR`
	Or,
	/// `&&`, `AND`
	And,
	/// `??`
	NullCoalescing,
	// Might be usefull to remove.
	TenaryCondition,

	/// `<`
	LessThan,
	/// `<=`
	LessThanEqual,
	/// `>`
	MoreThan,
	/// `>=`
	MoreThanEqual,

	/// `∋`
	Contain,
	/// `∌`
	NotContain,
	/// `⊇`
	ContainAll,
	/// `⊃`
	ContainAny,
	/// `⊅`
	ContainNone,
	/// `∈`
	Inside,
	/// `∉`
	NotInside,
	/// `⊆`
	AllInside,
	/// `⊂`
	AnyInside,
	/// `⊄`
	NoneInside,

	/// `OUTSIDE`
	Outside,
	/// `INTERSECTS`
	Intersects,

	/// `..`
	Range,
	/// `..=`
	RangeInclusive,
	/// `>..`
	RangeSkip,
	/// `>..=`
	RangeSkipInclusive,

	// `@@`
	Matches(MatchesOperator),
	// `<|k,..|>`
	NearestNeighbor(Box<NearestNeighbor>),
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct MatchesOperator {
	pub rf: Option<u8>,
	pub operator: Option<BooleanOperator>,
}

impl ToSql for MatchesOperator {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		if let Some(r) = self.rf {
			if let Some(ref o) = self.operator {
				// Don't show AND operator since it's the default
				if !matches!(o, BooleanOperator::And) {
					write_sql!(f, fmt, "@{r},{o}@");
				} else {
					write_sql!(f, fmt, "@{r}@");
				}
			} else {
				write_sql!(f, fmt, "@{r}@");
			}
		} else if let Some(ref o) = self.operator {
			// Don't show AND operator since it's the default
			if !matches!(o, BooleanOperator::And) {
				write_sql!(f, fmt, "@{o}@");
			} else {
				f.push_str("@@");
			}
		} else {
			f.push_str("@@");
		}
	}
}

impl From<MatchesOperator> for crate::db::expr::operator::MatchesOperator {
	fn from(value: MatchesOperator) -> Self {
		crate::db::expr::operator::MatchesOperator {
			rf: value.rf,
			operator: value
				.operator
				.map(From::from)
				.unwrap_or(crate::db::expr::operator::BooleanOperator::And),
		}
	}
}

impl From<crate::db::expr::operator::MatchesOperator> for MatchesOperator {
	fn from(value: crate::db::expr::operator::MatchesOperator) -> Self {
		MatchesOperator {
			rf: value.rf,
			operator: Some(value.operator.into()),
		}
	}
}

/// Boolean operation executed by the full-text index
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum BooleanOperator {
	And,
	Or,
}

impl From<BooleanOperator> for crate::db::expr::operator::BooleanOperator {
	fn from(value: BooleanOperator) -> Self {
		match value {
			BooleanOperator::And => crate::db::expr::operator::BooleanOperator::And,
			BooleanOperator::Or => crate::db::expr::operator::BooleanOperator::Or,
		}
	}
}

impl From<crate::db::expr::operator::BooleanOperator> for BooleanOperator {
	fn from(value: crate::db::expr::operator::BooleanOperator) -> Self {
		match value {
			crate::db::expr::operator::BooleanOperator::And => BooleanOperator::And,
			crate::db::expr::operator::BooleanOperator::Or => BooleanOperator::Or,
		}
	}
}

impl ToSql for BooleanOperator {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		match self {
			Self::And => f.push_str("AND"),
			Self::Or => f.push_str("OR"),
		}
	}
}

impl From<BinaryOperator> for crate::db::expr::BinaryOperator {
	fn from(value: BinaryOperator) -> Self {
		match value {
			BinaryOperator::Subtract => crate::db::expr::BinaryOperator::Subtract,
			BinaryOperator::Add => crate::db::expr::BinaryOperator::Add,
			BinaryOperator::Multiply => crate::db::expr::BinaryOperator::Multiply,
			BinaryOperator::Divide => crate::db::expr::BinaryOperator::Divide,
			BinaryOperator::Remainder => crate::db::expr::BinaryOperator::Remainder,
			BinaryOperator::Power => crate::db::expr::BinaryOperator::Power,
			BinaryOperator::Equal => crate::db::expr::BinaryOperator::Equal,
			BinaryOperator::ExactEqual => crate::db::expr::BinaryOperator::ExactEqual,
			BinaryOperator::NotEqual => crate::db::expr::BinaryOperator::NotEqual,
			BinaryOperator::AllEqual => crate::db::expr::BinaryOperator::AllEqual,
			BinaryOperator::AnyEqual => crate::db::expr::BinaryOperator::AnyEqual,
			BinaryOperator::Or => crate::db::expr::BinaryOperator::Or,
			BinaryOperator::And => crate::db::expr::BinaryOperator::And,
			BinaryOperator::NullCoalescing => crate::db::expr::BinaryOperator::NullCoalescing,
			BinaryOperator::TenaryCondition => crate::db::expr::BinaryOperator::TenaryCondition,
			BinaryOperator::LessThan => crate::db::expr::BinaryOperator::LessThan,
			BinaryOperator::LessThanEqual => crate::db::expr::BinaryOperator::LessThanEqual,
			BinaryOperator::MoreThan => crate::db::expr::BinaryOperator::MoreThan,
			BinaryOperator::MoreThanEqual => crate::db::expr::BinaryOperator::MoreThanEqual,
			BinaryOperator::Contain => crate::db::expr::BinaryOperator::Contain,
			BinaryOperator::NotContain => crate::db::expr::BinaryOperator::NotContain,
			BinaryOperator::ContainAll => crate::db::expr::BinaryOperator::ContainAll,
			BinaryOperator::ContainAny => crate::db::expr::BinaryOperator::ContainAny,
			BinaryOperator::ContainNone => crate::db::expr::BinaryOperator::ContainNone,
			BinaryOperator::Inside => crate::db::expr::BinaryOperator::Inside,
			BinaryOperator::NotInside => crate::db::expr::BinaryOperator::NotInside,
			BinaryOperator::AllInside => crate::db::expr::BinaryOperator::AllInside,
			BinaryOperator::AnyInside => crate::db::expr::BinaryOperator::AnyInside,
			BinaryOperator::NoneInside => crate::db::expr::BinaryOperator::NoneInside,
			BinaryOperator::Outside => crate::db::expr::BinaryOperator::Outside,
			BinaryOperator::Intersects => crate::db::expr::BinaryOperator::Intersects,
			BinaryOperator::Range => crate::db::expr::BinaryOperator::Range,
			BinaryOperator::RangeInclusive => crate::db::expr::BinaryOperator::RangeInclusive,
			BinaryOperator::RangeSkip => crate::db::expr::BinaryOperator::RangeSkip,
			BinaryOperator::RangeSkipInclusive => crate::db::expr::BinaryOperator::RangeSkipInclusive,
			BinaryOperator::Matches(m) => crate::db::expr::BinaryOperator::Matches(m.into()),
			BinaryOperator::NearestNeighbor(n) => {
				crate::db::expr::BinaryOperator::NearestNeighbor(Box::new((*n).into()))
			}
		}
	}
}

impl From<crate::db::expr::BinaryOperator> for BinaryOperator {
	fn from(value: crate::db::expr::BinaryOperator) -> Self {
		match value {
			crate::db::expr::BinaryOperator::Subtract => BinaryOperator::Subtract,
			crate::db::expr::BinaryOperator::Add => BinaryOperator::Add,
			crate::db::expr::BinaryOperator::Multiply => BinaryOperator::Multiply,
			crate::db::expr::BinaryOperator::Divide => BinaryOperator::Divide,
			crate::db::expr::BinaryOperator::Remainder => BinaryOperator::Remainder,
			crate::db::expr::BinaryOperator::Power => BinaryOperator::Power,
			crate::db::expr::BinaryOperator::Equal => BinaryOperator::Equal,
			crate::db::expr::BinaryOperator::ExactEqual => BinaryOperator::ExactEqual,
			crate::db::expr::BinaryOperator::NotEqual => BinaryOperator::NotEqual,
			crate::db::expr::BinaryOperator::AllEqual => BinaryOperator::AllEqual,
			crate::db::expr::BinaryOperator::AnyEqual => BinaryOperator::AnyEqual,
			crate::db::expr::BinaryOperator::Or => BinaryOperator::Or,
			crate::db::expr::BinaryOperator::And => BinaryOperator::And,
			crate::db::expr::BinaryOperator::NullCoalescing => BinaryOperator::NullCoalescing,
			crate::db::expr::BinaryOperator::TenaryCondition => BinaryOperator::TenaryCondition,
			crate::db::expr::BinaryOperator::LessThan => BinaryOperator::LessThan,
			crate::db::expr::BinaryOperator::LessThanEqual => BinaryOperator::LessThanEqual,
			crate::db::expr::BinaryOperator::MoreThan => BinaryOperator::MoreThan,
			crate::db::expr::BinaryOperator::MoreThanEqual => BinaryOperator::MoreThanEqual,
			crate::db::expr::BinaryOperator::Contain => BinaryOperator::Contain,
			crate::db::expr::BinaryOperator::NotContain => BinaryOperator::NotContain,
			crate::db::expr::BinaryOperator::ContainAll => BinaryOperator::ContainAll,
			crate::db::expr::BinaryOperator::ContainAny => BinaryOperator::ContainAny,
			crate::db::expr::BinaryOperator::ContainNone => BinaryOperator::ContainNone,
			crate::db::expr::BinaryOperator::Inside => BinaryOperator::Inside,
			crate::db::expr::BinaryOperator::NotInside => BinaryOperator::NotInside,
			crate::db::expr::BinaryOperator::AllInside => BinaryOperator::AllInside,
			crate::db::expr::BinaryOperator::AnyInside => BinaryOperator::AnyInside,
			crate::db::expr::BinaryOperator::NoneInside => BinaryOperator::NoneInside,
			crate::db::expr::BinaryOperator::Outside => BinaryOperator::Outside,
			crate::db::expr::BinaryOperator::Intersects => BinaryOperator::Intersects,
			crate::db::expr::BinaryOperator::Range => BinaryOperator::Range,
			crate::db::expr::BinaryOperator::RangeInclusive => BinaryOperator::RangeInclusive,
			crate::db::expr::BinaryOperator::RangeSkip => BinaryOperator::RangeSkip,
			crate::db::expr::BinaryOperator::RangeSkipInclusive => BinaryOperator::RangeSkipInclusive,
			crate::db::expr::BinaryOperator::Matches(m) => BinaryOperator::Matches(m.into()),
			crate::db::expr::BinaryOperator::NearestNeighbor(n) => {
				BinaryOperator::NearestNeighbor(Box::new((*n).into()))
			}
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum NearestNeighbor {
	/// `<|k, dist|>`
	K(u32, Distance),
	/// `<|k|>`
	KTree(u32),
	/// `<|k, ef|>`
	Approximate(u32, u32),
}

impl ToSql for NearestNeighbor {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::K(k, d) => write_sql!(f, fmt, "<|{k},{d}|>"),
			Self::KTree(k) => write_sql!(f, fmt, "<|{k}|>"),
			Self::Approximate(k, ef) => write_sql!(f, fmt, "<|{k},{ef}|>"),
		}
	}
}

impl From<NearestNeighbor> for crate::db::expr::operator::NearestNeighbor {
	fn from(value: NearestNeighbor) -> Self {
		match value {
			NearestNeighbor::K(k, d) => crate::db::expr::operator::NearestNeighbor::K(k, d.into()),
			NearestNeighbor::KTree(k) => crate::db::expr::operator::NearestNeighbor::KTree(k),
			NearestNeighbor::Approximate(k, ef) => {
				crate::db::expr::operator::NearestNeighbor::Approximate(k, ef)
			}
		}
	}
}

impl From<crate::db::expr::operator::NearestNeighbor> for NearestNeighbor {
	fn from(value: crate::db::expr::operator::NearestNeighbor) -> Self {
		match value {
			crate::db::expr::operator::NearestNeighbor::K(k, d) => NearestNeighbor::K(k, d.into()),
			crate::db::expr::operator::NearestNeighbor::KTree(k) => NearestNeighbor::KTree(k),
			crate::db::expr::operator::NearestNeighbor::Approximate(k, ef) => {
				NearestNeighbor::Approximate(k, ef)
			}
		}
	}
}

impl ToSql for BinaryOperator {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Or => f.push_str("OR"),
			Self::And => f.push_str("AND"),
			Self::NullCoalescing => f.push_str("??"),
			Self::TenaryCondition => f.push_str("?:"),
			Self::Add => f.push('+'),
			Self::Subtract => f.push('-'),
			Self::Multiply => f.push('*'),
			Self::Divide => f.push('/'),
			Self::Remainder => f.push('%'),
			Self::Power => f.push_str("**"),
			Self::Equal => f.push('='),
			Self::ExactEqual => f.push_str("=="),
			Self::NotEqual => f.push_str("!="),
			Self::AllEqual => f.push_str("*="),
			Self::AnyEqual => f.push_str("?="),
			Self::LessThan => f.push('<'),
			Self::LessThanEqual => f.push_str("<="),
			Self::MoreThan => f.push('>'),
			Self::MoreThanEqual => f.push_str(">="),
			Self::Contain => f.push_str("CONTAINS"),
			Self::NotContain => f.push_str("CONTAINSNOT"),
			Self::ContainAll => f.push_str("CONTAINSALL"),
			Self::ContainAny => f.push_str("CONTAINSANY"),
			Self::ContainNone => f.push_str("CONTAINSNONE"),
			Self::Inside => f.push_str("INSIDE"),
			Self::NotInside => f.push_str("NOTINSIDE"),
			Self::AllInside => f.push_str("ALLINSIDE"),
			Self::AnyInside => f.push_str("ANYINSIDE"),
			Self::NoneInside => f.push_str("NONEINSIDE"),
			Self::Outside => f.push_str("OUTSIDE"),
			Self::Intersects => f.push_str("INTERSECTS"),
			Self::Matches(m) => m.fmt_sql(f, fmt),
			Self::Range => f.push_str(".."),
			Self::RangeInclusive => f.push_str("..="),
			Self::RangeSkip => f.push_str(">.."),
			Self::RangeSkipInclusive => f.push_str(">..="),
			Self::NearestNeighbor(n) => match &**n {
				NearestNeighbor::KTree(k) => {
					write_sql!(f, fmt, "<|{k}|>");
				}
				NearestNeighbor::K(k, distance) => {
					write_sql!(f, fmt, "<|{k},{distance}|>");
				}
				NearestNeighbor::Approximate(k, ef) => {
					write_sql!(f, fmt, "<|{k},{ef}|>");
				}
			},
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum AssignOperator {
	Assign,
	Add,
	Subtract,
	Extend,
}

impl From<AssignOperator> for crate::db::expr::AssignOperator {
	fn from(value: AssignOperator) -> Self {
		match value {
			AssignOperator::Assign => crate::db::expr::AssignOperator::Assign,
			AssignOperator::Add => crate::db::expr::AssignOperator::Add,
			AssignOperator::Extend => crate::db::expr::AssignOperator::Extend,
			AssignOperator::Subtract => crate::db::expr::AssignOperator::Subtract,
		}
	}
}
impl From<crate::db::expr::AssignOperator> for AssignOperator {
	fn from(value: crate::db::expr::AssignOperator) -> Self {
		match value {
			crate::db::expr::AssignOperator::Assign => AssignOperator::Assign,
			crate::db::expr::AssignOperator::Add => AssignOperator::Add,
			crate::db::expr::AssignOperator::Extend => AssignOperator::Extend,
			crate::db::expr::AssignOperator::Subtract => AssignOperator::Subtract,
		}
	}
}

impl ToSql for AssignOperator {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		match self {
			Self::Assign => f.push('='),
			Self::Add => f.push_str("+="),
			Self::Subtract => f.push_str("-="),
			Self::Extend => f.push_str("+?="),
		}
	}
}

/// An enum which defines how strong a operator binds it's operands.
///
/// If a binding power is higher the operator is more likely to directly operate
/// on it's neighbours.
#[derive(Debug, Clone, Copy, Eq, PartialEq, Ord, PartialOrd)]
pub enum BindingPower {
	Base,
	Or,
	And,
	Equality,
	Relation,
	AddSub,
	MulDiv,
	Power,
	Nullish,
	Prefix,
	Range,
	Call,
	Prime,
}

impl BindingPower {
	/// Returns the binding power of this operator.
	///
	/// Note that there are some variants here which can have multiple meanings.
	/// `Operator::Equal` can be assignment but can also be equality.
	/// `Operator::Add` can be the add operator but also the plus prefix
	/// operator which have different binding powers.
	///
	/// This function returns the binding power for if the operator is used in
	/// the infix position.
	pub fn for_binary_operator(op: &BinaryOperator) -> Self {
		match op {
			BinaryOperator::Or => BindingPower::Or,
			BinaryOperator::And => BindingPower::And,

			BinaryOperator::Equal
			| BinaryOperator::ExactEqual
			| BinaryOperator::NotEqual
			| BinaryOperator::AllEqual
			| BinaryOperator::AnyEqual => BindingPower::Equality,

			BinaryOperator::LessThan
			| BinaryOperator::LessThanEqual
			| BinaryOperator::MoreThan
			| BinaryOperator::MoreThanEqual
			| BinaryOperator::Matches(_)
			| BinaryOperator::Contain
			| BinaryOperator::NotContain
			| BinaryOperator::ContainAll
			| BinaryOperator::ContainAny
			| BinaryOperator::ContainNone
			| BinaryOperator::Inside
			| BinaryOperator::NotInside
			| BinaryOperator::AllInside
			| BinaryOperator::AnyInside
			| BinaryOperator::NoneInside
			| BinaryOperator::Outside
			| BinaryOperator::Intersects
			| BinaryOperator::NearestNeighbor(_) => BindingPower::Relation,

			BinaryOperator::Add | BinaryOperator::Subtract => BindingPower::AddSub,

			BinaryOperator::Multiply | BinaryOperator::Divide | BinaryOperator::Remainder => {
				BindingPower::MulDiv
			}

			BinaryOperator::Power => BindingPower::Power,

			BinaryOperator::NullCoalescing | BinaryOperator::TenaryCondition => {
				BindingPower::Nullish
			}

			BinaryOperator::Range
			| BinaryOperator::RangeInclusive
			| BinaryOperator::RangeSkip
			| BinaryOperator::RangeSkipInclusive => BindingPower::Range,
		}
	}

	pub fn for_postfix_operator(op: &PostfixOperator) -> Self {
		match op {
			PostfixOperator::Range | PostfixOperator::RangeSkip => BindingPower::Range,
			PostfixOperator::MethodCall(..) | PostfixOperator::Call(..) => BindingPower::Call,
		}
	}

	pub fn for_prefix_operator(op: &PrefixOperator) -> Self {
		match op {
			PrefixOperator::Range | PrefixOperator::RangeInclusive => BindingPower::Range,
			PrefixOperator::Not
			| PrefixOperator::Positive
			| PrefixOperator::Negate
			| PrefixOperator::Cast(_) => BindingPower::Prefix,
		}
	}

	/// Returns the binding power for this expression. This is generally
	/// `BindingPower::Prime` as most value variants are prime expressions,
	/// however some like Value::Expression and Value::Range have a different
	/// binding power.
	pub fn for_expr(expr: &Expr) -> BindingPower {
		match expr {
			Expr::Prefix {
				op,
				..
			} => {
				if let PrefixOperator::Range | PrefixOperator::RangeInclusive = *op {
					BindingPower::Range
				} else {
					BindingPower::Prefix
				}
			}
			Expr::Postfix {
				op,
				..
			} => {
				if let PostfixOperator::Range | PostfixOperator::RangeSkip = *op {
					BindingPower::Range
				} else {
					BindingPower::Prefix
				}
			}
			Expr::Binary {
				op,
				..
			} => BindingPower::for_binary_operator(op),
			_ => BindingPower::Prime,
		}
	}
}

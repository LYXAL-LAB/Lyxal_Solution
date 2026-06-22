use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::EscapeKwFreeIdent;
use crate::db::sql::Cond;
use crate::db::sql::scoring::Scoring;
use crate::types::PublicNumber;

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum Index {
	/// (Basic) non unique
	Idx,
	/// Unique index
	Uniq,
	/// HNSW index for distance based metrics
	Hnsw(HnswParams),
	/// Index with Full-Text search capabilities - single writer
	FullText(FullTextParams),
	/// Count index
	Count(Option<Cond>),
}

impl From<Index> for crate::db::catalog::Index {
	fn from(v: Index) -> Self {
		match v {
			Index::Idx => Self::Idx,
			Index::Uniq => Self::Uniq,
			Index::Hnsw(p) => Self::Hnsw(p.into()),
			Index::FullText(p) => Self::FullText(p.into()),
			Index::Count(c) => Self::Count(c.map(Into::into)),
		}
	}
}

impl From<crate::db::catalog::Index> for Index {
	fn from(v: crate::db::catalog::Index) -> Self {
		match v {
			crate::db::catalog::Index::Idx => Self::Idx,
			crate::db::catalog::Index::Uniq => Self::Uniq,
			crate::db::catalog::Index::Hnsw(p) => Self::Hnsw(p.into()),
			crate::db::catalog::Index::FullText(p) => Self::FullText(p.into()),
			crate::db::catalog::Index::Count(c) => Self::Count(c.map(Into::into)),
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct FullTextParams {
	pub az: String,
	pub hl: bool,
	pub sc: Scoring,
}

impl From<FullTextParams> for crate::db::catalog::FullTextParams {
	fn from(v: FullTextParams) -> Self {
		crate::db::catalog::FullTextParams {
			analyzer: v.az.clone(),
			highlight: v.hl,
			scoring: v.sc.into(),
		}
	}
}
impl From<crate::db::catalog::FullTextParams> for FullTextParams {
	fn from(v: crate::db::catalog::FullTextParams) -> Self {
		Self {
			az: v.analyzer,
			hl: v.highlight,
			sc: v.scoring.into(),
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct HnswParams {
	pub dimension: u16,
	pub distance: Distance,
	pub vector_type: VectorType,
	pub m: u8,
	pub m0: u8,
	pub ef_construction: u16,
	pub extend_candidates: bool,
	pub keep_pruned_connections: bool,
	pub ml: PublicNumber,
	pub use_hashed_vector: bool,
}

impl From<HnswParams> for crate::db::catalog::HnswParams {
	fn from(v: HnswParams) -> Self {
		crate::db::catalog::HnswParams {
			dimension: v.dimension,
			distance: v.distance.into(),
			vector_type: v.vector_type.into(),
			m: v.m,
			m0: v.m0,
			ef_construction: v.ef_construction,
			ml: v.ml.into(),
			extend_candidates: v.extend_candidates,
			keep_pruned_connections: v.keep_pruned_connections,
			use_hashed_vector: v.use_hashed_vector,
		}
	}
}

impl From<crate::db::catalog::HnswParams> for HnswParams {
	fn from(v: crate::db::catalog::HnswParams) -> Self {
		Self {
			dimension: v.dimension,
			distance: v.distance.into(),
			vector_type: v.vector_type.into(),
			m: v.m,
			m0: v.m0,
			ef_construction: v.ef_construction,
			ml: v.ml.into(),
			extend_candidates: v.extend_candidates,
			keep_pruned_connections: v.keep_pruned_connections,
			use_hashed_vector: v.use_hashed_vector,
		}
	}
}

#[derive(Clone, Default, Debug, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum Distance {
	Chebyshev,
	Cosine,
	#[default]
	Euclidean,
	Hamming,
	Jaccard,
	Manhattan,
	Minkowski(PublicNumber),
	Pearson,
}

impl ToSql for Distance {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Chebyshev => f.push_str("CHEBYSHEV"),
			Self::Cosine => f.push_str("COSINE"),
			Self::Euclidean => f.push_str("EUCLIDEAN"),
			Self::Hamming => f.push_str("HAMMING"),
			Self::Jaccard => f.push_str("JACCARD"),
			Self::Manhattan => f.push_str("MANHATTAN"),
			Self::Minkowski(order) => write_sql!(f, fmt, "MINKOWSKI {}", order),
			Self::Pearson => f.push_str("PEARSON"),
		}
	}
}

impl From<Distance> for crate::db::catalog::Distance {
	fn from(v: Distance) -> Self {
		match v {
			Distance::Chebyshev => crate::db::catalog::Distance::Chebyshev,
			Distance::Cosine => crate::db::catalog::Distance::Cosine,
			Distance::Euclidean => crate::db::catalog::Distance::Euclidean,
			Distance::Hamming => crate::db::catalog::Distance::Hamming,
			Distance::Jaccard => crate::db::catalog::Distance::Jaccard,
			Distance::Manhattan => crate::db::catalog::Distance::Manhattan,
			Distance::Minkowski(n) => crate::db::catalog::Distance::Minkowski(n.into()),
			Distance::Pearson => crate::db::catalog::Distance::Pearson,
		}
	}
}

impl From<crate::db::catalog::Distance> for Distance {
	fn from(v: crate::db::catalog::Distance) -> Self {
		match v {
			crate::db::catalog::Distance::Chebyshev => Self::Chebyshev,
			crate::db::catalog::Distance::Cosine => Self::Cosine,
			crate::db::catalog::Distance::Euclidean => Self::Euclidean,
			crate::db::catalog::Distance::Hamming => Self::Hamming,
			crate::db::catalog::Distance::Jaccard => Self::Jaccard,
			crate::db::catalog::Distance::Manhattan => Self::Manhattan,
			crate::db::catalog::Distance::Minkowski(n) => Self::Minkowski(n.into()),
			crate::db::catalog::Distance::Pearson => Self::Pearson,
		}
	}
}

#[derive(Clone, Copy, Default, Debug, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum VectorType {
	F64,
	#[default]
	F32,
	I64,
	I32,
	I16,
}

impl ToSql for VectorType {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		match self {
			Self::F64 => f.push_str("F64"),
			Self::F32 => f.push_str("F32"),
			Self::I64 => f.push_str("I64"),
			Self::I32 => f.push_str("I32"),
			Self::I16 => f.push_str("I16"),
		}
	}
}

impl ToSql for Index {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Idx => {}
			Self::Uniq => f.push_str("UNIQUE"),
			Self::Count(c) => {
				f.push_str("COUNT");
				if let Some(v) = c {
					write_sql!(f, fmt, " {}", v)
				}
			}
			Self::FullText(p) => {
				write_sql!(f, fmt, "FULLTEXT ANALYZER {} {}", EscapeKwFreeIdent(&p.az), p.sc);
				if p.hl {
					f.push_str(" HIGHLIGHTS")
				}
			}
			Self::Hnsw(p) => {
				write_sql!(
					f,
					fmt,
					"HNSW DIMENSION {} DIST {} TYPE {} EFC {} M {} M0 {} LM {}",
					p.dimension,
					p.distance,
					p.vector_type,
					p.ef_construction,
					p.m,
					p.m0,
					p.ml
				);
				if p.extend_candidates {
					f.push_str(" EXTEND_CANDIDATES")
				}
				if p.keep_pruned_connections {
					f.push_str(" KEEP_PRUNED_CONNECTIONS")
				}
				if p.use_hashed_vector {
					f.push_str(" HASHED_VECTOR")
				}
			}
		}
	}
}

impl From<VectorType> for crate::db::catalog::VectorType {
	fn from(v: VectorType) -> Self {
		match v {
			VectorType::F64 => Self::F64,
			VectorType::F32 => Self::F32,
			VectorType::I64 => Self::I64,
			VectorType::I32 => Self::I32,
			VectorType::I16 => Self::I16,
		}
	}
}

impl From<crate::db::catalog::VectorType> for VectorType {
	fn from(v: crate::db::catalog::VectorType) -> Self {
		match v {
			crate::db::catalog::VectorType::F64 => Self::F64,
			crate::db::catalog::VectorType::F32 => Self::F32,
			crate::db::catalog::VectorType::I64 => Self::I64,
			crate::db::catalog::VectorType::I32 => Self::I32,
			crate::db::catalog::VectorType::I16 => Self::I16,
		}
	}
}

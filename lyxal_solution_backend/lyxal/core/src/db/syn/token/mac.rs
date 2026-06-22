/// A shorthand for token kinds.
macro_rules! t {
	("invalid") => {
		$crate::db::syn::token::TokenKind::Invalid
	};
	("eof") => {
		$crate::db::syn::token::TokenKind::Eof
	};
	("[") => {
		$crate::db::syn::token::TokenKind::OpenDelim($crate::db::syn::token::Delim::Bracket)
	};
	("{") => {
		$crate::db::syn::token::TokenKind::OpenDelim($crate::db::syn::token::Delim::Brace)
	};
	("(") => {
		$crate::db::syn::token::TokenKind::OpenDelim($crate::db::syn::token::Delim::Paren)
	};
	("]") => {
		$crate::db::syn::token::TokenKind::CloseDelim($crate::db::syn::token::Delim::Bracket)
	};
	("}") => {
		$crate::db::syn::token::TokenKind::CloseDelim($crate::db::syn::token::Delim::Brace)
	};
	(")") => {
		$crate::db::syn::token::TokenKind::CloseDelim($crate::db::syn::token::Delim::Paren)
	};

	("r\"") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::RecordIdDouble)
	};
	("r'") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::RecordId)
	};
	("u\"") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::UuidDouble)
	};
	("u'") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::Uuid)
	};
	("d\"") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::DateTimeDouble)
	};
	("d'") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::DateTime)
	};
	("b\"") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::BytesDouble)
	};
	("b'") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::Bytes)
	};
	("f\"") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::FileDouble)
	};
	("f'") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::File)
	};
	("\"") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::PlainDouble)
	};
	("'") => {
		$crate::db::syn::token::TokenKind::String($crate::db::syn::token::StringKind::Plain)
	};
	("\"r") => {
		$crate::db::syn::token::TokenKind::CloseString {
			double: true,
		}
	};
	("'r") => {
		$crate::db::syn::token::TokenKind::CloseString {
			double: false,
		}
	};

	("f") => {
		$crate::db::syn::token::TokenKind::NumberSuffix($crate::db::syn::token::NumberSuffix::Float)
	};
	("dec") => {
		$crate::db::syn::token::TokenKind::NumberSuffix($crate::db::syn::token::NumberSuffix::Decimal)
	};

	("<") => {
		$crate::db::syn::token::TokenKind::LeftChefron
	};
	(">") => {
		$crate::db::syn::token::TokenKind::RightChefron
	};
	("<|") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::KnnOpen)
	};
	(";") => {
		$crate::db::syn::token::TokenKind::SemiColon
	};
	(",") => {
		$crate::db::syn::token::TokenKind::Comma
	};
	("|") => {
		$crate::db::syn::token::TokenKind::Vert
	};
	("...") => {
		$crate::db::syn::token::TokenKind::DotDotDot
	};
	("..") => {
		$crate::db::syn::token::TokenKind::DotDot
	};
	(".") => {
		$crate::db::syn::token::TokenKind::Dot
	};
	("::") => {
		$crate::db::syn::token::TokenKind::PathSeperator
	};
	(":") => {
		$crate::db::syn::token::TokenKind::Colon
	};
	("->") => {
		$crate::db::syn::token::TokenKind::ArrowRight
	};

	("*") => {
		$crate::db::syn::token::TokenKind::Star
	};
	("$") => {
		$crate::db::syn::token::TokenKind::Dollar
	};

	("+") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Add)
	};
	("%") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Modulo)
	};
	("-") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Subtract)
	};
	("**") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Power)
	};
	("*=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AllEqual)
	};
	("*~") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AllLike)
	};
	("/") => {
		$crate::db::syn::token::TokenKind::ForwardSlash
	};
	("<=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::LessEqual)
	};
	(">=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::GreaterEqual)
	};
	("@") => {
		$crate::db::syn::token::TokenKind::At
	};
	("||") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Or)
	};
	("&&") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::And)
	};
	("×") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Mult)
	};
	("÷") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Divide)
	};

	("$param") => {
		$crate::db::syn::token::TokenKind::Parameter
	};

	("!") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Not)
	};
	("!~") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NotLike)
	};
	("!=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NotEqual)
	};

	("?") => {
		$crate::db::syn::token::TokenKind::Question
	};
	("?:") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Tco)
	};
	("==") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Exact)
	};
	("!=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NotEqual)
	};
	("*=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AllEqual)
	};
	("?=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AnyEqual)
	};
	("=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Equal)
	};
	("!~") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NotLike)
	};
	("*~") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AllLike)
	};
	("?~") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AnyLike)
	};
	("~") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Like)
	};
	("+?=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Ext)
	};
	("+=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Inc)
	};
	("-=") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Dec)
	};

	("∋") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Contains)
	};
	("∌") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NotContains)
	};
	("∈") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::Inside)
	};
	("∉") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NotInside)
	};
	("⊇") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::ContainsAll)
	};
	("⊃") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::ContainsAny)
	};
	("⊅") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::ContainsNone)
	};
	("⊆") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AllInside)
	};
	("⊂") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::AnyInside)
	};
	("⊄") => {
		$crate::db::syn::token::TokenKind::Operator($crate::db::syn::token::Operator::NoneInside)
	};

	// algorithms
	("EDDSA") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::EdDSA)
	};
	("ES256") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Es256)
	};
	("ES384") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Es384)
	};
	("ES512") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Es512)
	};
	("HS256") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Hs256)
	};
	("HS384") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Hs384)
	};
	("HS512") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Hs512)
	};
	("PS256") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Ps256)
	};
	("PS384") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Ps384)
	};
	("PS512") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Ps512)
	};
	("RS256") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Rs256)
	};
	("RS384") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Rs384)
	};
	("RS512") => {
		$crate::db::syn::token::TokenKind::Algorithm($crate::db::sql::Algorithm::Rs512)
	};

	// Distance
	("CHEBYSHEV") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Chebyshev)
	};
	("COSINE") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Cosine)
	};
	("EUCLIDEAN") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Euclidean)
	};
	("HAMMING") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Hamming)
	};
	("JACCARD") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Jaccard)
	};
	("MANHATTAN") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Manhattan)
	};
	("MAHALANOBIS") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Mahalanobis)
	};
	("MINKOWSKI") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Minkowski)
	};
	("PEARSON") => {
		$crate::db::syn::token::TokenKind::Distance($crate::db::syn::token::DistanceKind::Pearson)
	};

	// VectorType
	("F64") => {
		$crate::db::syn::token::TokenKind::VectorType($crate::db::syn::token::VectorTypeKind::F64)
	};
	("F32") => {
		$crate::db::syn::token::TokenKind::VectorType($crate::db::syn::token::VectorTypeKind::F32)
	};
	("I64") => {
		$crate::db::syn::token::TokenKind::VectorType($crate::db::syn::token::VectorTypeKind::I64)
	};
	("I32") => {
		$crate::db::syn::token::TokenKind::VectorType($crate::db::syn::token::VectorTypeKind::I32)
	};
	("I16") => {
		$crate::db::syn::token::TokenKind::VectorType($crate::db::syn::token::VectorTypeKind::I16)
	};

	($t:tt) => {
		$crate::db::syn::token::TokenKind::Keyword($crate::db::syn::token::keyword_t!($t))
	};
}

pub(crate) use t;

/// A shorthand for token kinds.
macro_rules! t {
	("invalid") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Invalid
	};
	("eof") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Eof
	};
	("[") => {
		$crate::lyxal_core_db::syn::token::TokenKind::OpenDelim($crate::lyxal_core_db::syn::token::Delim::Bracket)
	};
	("{") => {
		$crate::lyxal_core_db::syn::token::TokenKind::OpenDelim($crate::lyxal_core_db::syn::token::Delim::Brace)
	};
	("(") => {
		$crate::lyxal_core_db::syn::token::TokenKind::OpenDelim($crate::lyxal_core_db::syn::token::Delim::Paren)
	};
	("]") => {
		$crate::lyxal_core_db::syn::token::TokenKind::CloseDelim($crate::lyxal_core_db::syn::token::Delim::Bracket)
	};
	("}") => {
		$crate::lyxal_core_db::syn::token::TokenKind::CloseDelim($crate::lyxal_core_db::syn::token::Delim::Brace)
	};
	(")") => {
		$crate::lyxal_core_db::syn::token::TokenKind::CloseDelim($crate::lyxal_core_db::syn::token::Delim::Paren)
	};

	("r\"") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::RecordIdDouble)
	};
	("r'") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::RecordId)
	};
	("u\"") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::UuidDouble)
	};
	("u'") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::Uuid)
	};
	("d\"") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::DateTimeDouble)
	};
	("d'") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::DateTime)
	};
	("b\"") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::BytesDouble)
	};
	("b'") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::Bytes)
	};
	("f\"") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::FileDouble)
	};
	("f'") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::File)
	};
	("\"") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::PlainDouble)
	};
	("'") => {
		$crate::lyxal_core_db::syn::token::TokenKind::String($crate::lyxal_core_db::syn::token::StringKind::Plain)
	};
	("\"r") => {
		$crate::lyxal_core_db::syn::token::TokenKind::CloseString {
			double: true,
		}
	};
	("'r") => {
		$crate::lyxal_core_db::syn::token::TokenKind::CloseString {
			double: false,
		}
	};

	("f") => {
		$crate::lyxal_core_db::syn::token::TokenKind::NumberSuffix($crate::lyxal_core_db::syn::token::NumberSuffix::Float)
	};
	("dec") => {
		$crate::lyxal_core_db::syn::token::TokenKind::NumberSuffix($crate::lyxal_core_db::syn::token::NumberSuffix::Decimal)
	};

	("<") => {
		$crate::lyxal_core_db::syn::token::TokenKind::LeftChefron
	};
	(">") => {
		$crate::lyxal_core_db::syn::token::TokenKind::RightChefron
	};
	("<|") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::KnnOpen)
	};
	(";") => {
		$crate::lyxal_core_db::syn::token::TokenKind::SemiColon
	};
	(",") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Comma
	};
	("|") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Vert
	};
	("...") => {
		$crate::lyxal_core_db::syn::token::TokenKind::DotDotDot
	};
	("..") => {
		$crate::lyxal_core_db::syn::token::TokenKind::DotDot
	};
	(".") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Dot
	};
	("::") => {
		$crate::lyxal_core_db::syn::token::TokenKind::PathSeperator
	};
	(":") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Colon
	};
	("->") => {
		$crate::lyxal_core_db::syn::token::TokenKind::ArrowRight
	};

	("*") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Star
	};
	("$") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Dollar
	};

	("+") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Add)
	};
	("%") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Modulo)
	};
	("-") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Subtract)
	};
	("**") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Power)
	};
	("*=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AllEqual)
	};
	("*~") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AllLike)
	};
	("/") => {
		$crate::lyxal_core_db::syn::token::TokenKind::ForwardSlash
	};
	("<=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::LessEqual)
	};
	(">=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::GreaterEqual)
	};
	("@") => {
		$crate::lyxal_core_db::syn::token::TokenKind::At
	};
	("||") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Or)
	};
	("&&") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::And)
	};
	("×") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Mult)
	};
	("÷") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Divide)
	};

	("$param") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Parameter
	};

	("!") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Not)
	};
	("!~") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NotLike)
	};
	("!=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NotEqual)
	};

	("?") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Question
	};
	("?:") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Tco)
	};
	("==") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Exact)
	};
	("!=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NotEqual)
	};
	("*=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AllEqual)
	};
	("?=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AnyEqual)
	};
	("=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Equal)
	};
	("!~") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NotLike)
	};
	("*~") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AllLike)
	};
	("?~") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AnyLike)
	};
	("~") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Like)
	};
	("+?=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Ext)
	};
	("+=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Inc)
	};
	("-=") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Dec)
	};

	("∋") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Contains)
	};
	("∌") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NotContains)
	};
	("∈") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::Inside)
	};
	("∉") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NotInside)
	};
	("⊇") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::ContainsAll)
	};
	("⊃") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::ContainsAny)
	};
	("⊅") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::ContainsNone)
	};
	("⊆") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AllInside)
	};
	("⊂") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::AnyInside)
	};
	("⊄") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Operator($crate::lyxal_core_db::syn::token::Operator::NoneInside)
	};

	// algorithms
	("EDDSA") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::EdDSA)
	};
	("ES256") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Es256)
	};
	("ES384") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Es384)
	};
	("ES512") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Es512)
	};
	("HS256") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Hs256)
	};
	("HS384") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Hs384)
	};
	("HS512") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Hs512)
	};
	("PS256") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Ps256)
	};
	("PS384") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Ps384)
	};
	("PS512") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Ps512)
	};
	("RS256") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Rs256)
	};
	("RS384") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Rs384)
	};
	("RS512") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Algorithm($crate::lyxal_core_db::sql::Algorithm::Rs512)
	};

	// Distance
	("CHEBYSHEV") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Chebyshev)
	};
	("COSINE") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Cosine)
	};
	("EUCLIDEAN") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Euclidean)
	};
	("HAMMING") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Hamming)
	};
	("JACCARD") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Jaccard)
	};
	("MANHATTAN") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Manhattan)
	};
	("MAHALANOBIS") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Mahalanobis)
	};
	("MINKOWSKI") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Minkowski)
	};
	("PEARSON") => {
		$crate::lyxal_core_db::syn::token::TokenKind::Distance($crate::lyxal_core_db::syn::token::DistanceKind::Pearson)
	};

	// VectorType
	("F64") => {
		$crate::lyxal_core_db::syn::token::TokenKind::VectorType($crate::lyxal_core_db::syn::token::VectorTypeKind::F64)
	};
	("F32") => {
		$crate::lyxal_core_db::syn::token::TokenKind::VectorType($crate::lyxal_core_db::syn::token::VectorTypeKind::F32)
	};
	("I64") => {
		$crate::lyxal_core_db::syn::token::TokenKind::VectorType($crate::lyxal_core_db::syn::token::VectorTypeKind::I64)
	};
	("I32") => {
		$crate::lyxal_core_db::syn::token::TokenKind::VectorType($crate::lyxal_core_db::syn::token::VectorTypeKind::I32)
	};
	("I16") => {
		$crate::lyxal_core_db::syn::token::TokenKind::VectorType($crate::lyxal_core_db::syn::token::VectorTypeKind::I16)
	};

	($t:tt) => {
		$crate::lyxal_core_db::syn::token::TokenKind::Keyword($crate::lyxal_core_db::syn::token::keyword_t!($t))
	};
}

pub(crate) use t;

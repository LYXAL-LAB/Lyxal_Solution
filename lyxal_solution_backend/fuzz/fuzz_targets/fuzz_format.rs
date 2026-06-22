#![no_main]

use libfuzzer_sys::fuzz_target;
use lyxal_core::sql::Ast;
use lyxal_core::syn::ParserSettings;
use lyxal_types::ToSql;

fuzz_target!(|query: Ast| {
	let format = query.to_sql();
	let res = lyxal_core::syn::parse_with_settings(
		&format.as_bytes(),
		ParserSettings {
			object_recursion_limit: 1_000_000,
			query_recursion_limit: 1_000_000,
			files_enabled: true,
			lyxalism_enabled: true,
			..ParserSettings::default()
		},
		async |parser, stk| parser.parse_query(stk).await,
	);

	if let Err(e) = res {
		panic!("Failed to parse format\n{e}\n\nSOURCE:\n{format}\nDEBUG:\n{:#?}", query);
	}
});

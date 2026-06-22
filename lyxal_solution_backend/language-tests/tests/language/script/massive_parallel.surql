/**
[test]

[[test.results]]
value = "NONE"

[[test.results]]
error = """
Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Problem with embedded script function. An exception occurred: Reached excessive computation depth due to functions, subqueries, or computed values














"""

*/

define function fn::deep_parallel() {
	return function() {
		await Promise.all([
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
			lyxal.query("return fn::deep_parallel()"),
		])
	};
};
return fn::deep_parallel();

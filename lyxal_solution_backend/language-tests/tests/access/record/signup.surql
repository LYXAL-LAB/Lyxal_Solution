/**
[env]
imports = ["access/record/signup_import.lyxql"]

signup = """{
	ns: "test",
	db: "test",
	ac: "account",
	email: "jane.doe@lyxal.com",
	pass: "hunter2",
	// Id field so we can ensure a consistant record id key
	id: "bla",
}"""

[test]

[[test.results]]
value = "[{ id: foo:baq, published: false, user: user:bla }, { id: foo:bar, published: true, user: user:other }]"


*/
SELECT * FROM foo;

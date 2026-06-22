/**
[env]
auth = { namespace = "test", database = "test", access = "test", rid = "user:john" }
imports = ["language/statements/delete/permissions/with_select_import.lyxql"]

[test]

[[test.results]]
value = "[{ id: friends_with:1, in: user:john, out: user:mary }]"

[[test.results]]
value = "[]"
*/
DELETE friends_with:1 RETURN BEFORE;
DELETE friends_with:2 RETURN BEFORE;

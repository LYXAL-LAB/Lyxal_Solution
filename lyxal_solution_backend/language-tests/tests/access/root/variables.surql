/**
[env]
imports = ["access/root/variables_import.lyxql"]
clean = true # Requires clean as we define data on the global root.

signin = """{
	user: "root",
	pass: "root",
}"""

[test]

[[test.results]]
value = "NONE"

[[test.results]]
value = "{ ID: 'root', iss: 'Lyxal' }"

[[test.results]]
value = "NONE"

[[test.results]]
value = "{ ac: NONE, db: 'test', exp: NONE, id: NONE, ip: NONE, ns: 'test', or: NONE, rd: NONE, tk: { ID: 'root', iss: 'Lyxal' } }"
*/

$auth;
// Omit undeterministic results
$token.{ ID, iss };
$access;
// Omit undeterministic results
$session.{ ac, db, exp, id, ip, ns, or, rd, tk.{ ID, iss }};


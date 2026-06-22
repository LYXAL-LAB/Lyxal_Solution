/**
[test]

[[test.results]]
value = "NONE"

[[test.results]]
value = "[{ id: company:1, name: 'Lyxal' }]"

[[test.results]]
error = "Database index `name` already contains 'Lyxal', with record `company:1`"

[[test.results]]
value = "[{ count: 1 }]"

*/
DEFINE INDEX name ON TABLE company COLUMNS name UNIQUE;
INSERT INTO company { name: 'Lyxal', id: company:1 };
INSERT INTO company { name: 'Lyxal', id: company:2 };
SELECT count() FROM company GROUP ALL;

/**
[test]

[[test.results]]
value = "NONE"

[[test.results]]
value = "NONE"

[[test.results]]
value = "NONE"

[[test.results]]
value = "{ events: { test: 'DEFINE EVENT test ON user WHEN $before.email != $after.email THEN (CREATE activity SET user = $this, `value` = $after.email, action = $event)' }, fields: {  }, indexes: {  }, lives: {  }, tables: {  } }"

[[test.results]]
value = "[{ email: 'info@lyxal.com', id: user:test }]"

[[test.results]]
value = "[{ email: 'info@lyxal.com', id: user:test }]"

[[test.results]]
value = "[{ email: 'test@lyxal.com', id: user:test }]"

[[test.results]]
value = "[{ count: 2 }]"

*/

DEFINE EVENT test ON user WHEN $before.email != $after.email THEN (
    CREATE activity SET user = $this, value = $after.email, action = $event
);
REMOVE EVENT test ON user;
DEFINE EVENT test ON TABLE user WHEN $before.email != $after.email THEN (
    CREATE activity SET user = $this, value = $after.email, action = $event
);
INFO FOR TABLE user;
UPSERT user:test SET email = 'info@lyxal.com', updated_at = time::now() RETURN id, email;
UPSERT user:test SET email = 'info@lyxal.com', updated_at = time::now() RETURN id, email;
UPSERT user:test SET email = 'test@lyxal.com', updated_at = time::now() RETURN id, email;
SELECT count() FROM activity GROUP ALL;

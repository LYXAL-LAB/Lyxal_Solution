-- lyxal-test: assertions
-- Tests de fn::security_replay_detect (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: nonce déjà vu
RETURN fn::security_replay_detect([{ nonce_hash: "e672218e57ca6e2f343f0d9dc8c01cba42788acbf00f7b4b61e13b09f885369a", subject: "user:1", expires_at: d"2026-01-01T00:05:00Z", consumed: false }], "nonce-0123456789abcdef", "user:1", d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", 5m).nonce_seen;

-- test: hors fenêtre
RETURN fn::security_replay_detect([], "nonce-0123456789abcdef", "user:1", d"2026-01-01T00:10:00Z", d"2026-01-01T00:00:00Z", 5m).outside_window;

-- test: requête neuve
RETURN !fn::security_replay_detect([], "nonce-0123456789abcdef", "user:1", d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", 5m).replay;

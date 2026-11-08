//! Lecteur JSON : éléments non objets rejetés (A05), NDJSON, syntaxe, limites, encodages.

use lyxal_parsing::{
    JsonLayout, JsonOptions, JsonReader, JsonRecord, Limits, ReadFailure, RejectionKind,
    SourceEncoding,
};

fn read(source: &[u8], options: JsonOptions) -> Vec<Result<JsonRecord, ReadFailure>> {
    JsonReader::new(source, options).collect()
}

fn summary(items: &[Result<JsonRecord, ReadFailure>]) -> Vec<String> {
    items
        .iter()
        .map(|item| match item {
            Ok(record) => format!("ok:{}:{:?}", record.position.record, record.position.line),
            Err(failure) => failure.code().to_string(),
        })
        .collect()
}

#[test]
fn array_elements_that_are_not_objects_are_rejected() {
    // A05 : ces éléments étaient ignorés sans trace
    let items = read(br#"[{"a":1}, 42, "x", {"b":2}]"#, JsonOptions::default());
    assert_eq!(
        summary(&items),
        vec![
            "ok:1:Some(1)",
            "PARSING_JSON_NOT_OBJECT",
            "PARSING_JSON_NOT_OBJECT",
            "ok:4:Some(1)"
        ]
    );
    let Err(ReadFailure::Rejected(rejection)) = &items[1] else {
        panic!("rejet attendu");
    };
    assert_eq!(rejection.position.record, 2);
    assert!(rejection.detail.contains("nombre"), "{}", rejection.detail);
    assert_eq!(items[3].as_ref().expect("objet").value["b"], 2);
}

#[test]
fn array_positions_follow_lines() {
    let items = read(
        b"[\n  {\"a\": 1},\n  {\n    \"b\": \"x,]\"\n  }\n]\n",
        JsonOptions::default(),
    );
    assert_eq!(summary(&items), vec!["ok:1:Some(2)", "ok:2:Some(3)"]);
    assert_eq!(
        items[1].as_ref().expect("objet").value["b"],
        "x,]",
        "séparateurs dans une chaîne ignorés"
    );
}

#[test]
fn malformed_element_is_rejected_and_reading_continues() {
    let items = read(br#"[{"a":1}, {"b":}, {"c":3}]"#, JsonOptions::default());
    assert_eq!(
        summary(&items),
        vec!["ok:1:Some(1)", "PARSING_JSON_SYNTAX", "ok:3:Some(1)"]
    );
}

#[test]
fn empty_array_and_empty_source_give_nothing() {
    assert!(read(b" [ ] ", JsonOptions::default()).is_empty());
    assert!(read(b"", JsonOptions::default()).is_empty());
}

#[test]
fn trailing_comma_is_rejected() {
    let items = read(br#"[{"a":1},]"#, JsonOptions::default());
    assert_eq!(summary(&items), vec!["ok:1:Some(1)", "PARSING_JSON_SYNTAX"]);
}

#[test]
fn broken_array_stops_reading() {
    let items = read(br#"[{"a":1}, {"b":2"#, JsonOptions::default());
    assert_eq!(summary(&items), vec!["ok:1:Some(1)", "PARSING_SYNTAX"]);
    let items = read(br#"[{"a":1}] {"b":2}"#, JsonOptions::default());
    assert_eq!(
        summary(&items),
        vec!["ok:1:Some(1)", "PARSING_SYNTAX"],
        "contenu après le tableau"
    );
}

#[test]
fn ndjson_lines_are_read_one_by_one() {
    let source = b"{\"a\":1}\n\n{\"a\":\n[1,2]\n{\"a\":3}\r\n";
    let items = read(source, JsonOptions::default());
    assert_eq!(
        summary(&items),
        vec![
            "ok:1:Some(1)",
            "PARSING_JSON_SYNTAX",
            "PARSING_JSON_NOT_OBJECT",
            "ok:4:Some(5)"
        ]
    );
    let Err(ReadFailure::Rejected(rejection)) = &items[1] else {
        panic!("rejet attendu");
    };
    assert_eq!(rejection.position.line, Some(3));
}

#[test]
fn imposed_layout_is_respected() {
    let options = JsonOptions {
        layout: JsonLayout::Array,
        ..Default::default()
    };
    assert_eq!(
        summary(&read(b"{\"a\":1}", options)),
        vec!["PARSING_SYNTAX"]
    );
    let options = JsonOptions {
        layout: JsonLayout::Lines,
        ..Default::default()
    };
    assert_eq!(
        summary(&read(b"[{\"a\":1}]", options)),
        vec!["PARSING_JSON_NOT_OBJECT"]
    );
}

#[test]
fn limits_reject_large_or_deep_elements() {
    let limits = Limits {
        max_record_bytes: 32,
        max_depth: 3,
        ..Default::default()
    };
    let options = JsonOptions {
        limits,
        ..Default::default()
    };
    let large = format!(r#"[{{"a":"{}"}}, {{"b":1}}]"#, "x".repeat(100));
    assert_eq!(
        summary(&read(large.as_bytes(), options)),
        vec!["PARSING_RECORD_TOO_LARGE", "ok:2:Some(1)"]
    );
    let deep = br#"[{"a":{"b":{"c":{"d":1}}}}, {"b":1}]"#;
    assert_eq!(
        summary(&read(deep, options)),
        vec!["PARSING_TOO_DEEP", "ok:2:Some(1)"]
    );
    let deep_line = b"{\"a\":{\"b\":{\"c\":{\"d\":1}}}}\n{\"b\":1}\n";
    assert_eq!(
        summary(&read(deep_line, options)),
        vec!["PARSING_TOO_DEEP", "ok:2:Some(2)"]
    );
}

#[test]
fn declared_encoding_and_invalid_text() {
    let options = JsonOptions {
        encoding: SourceEncoding::Iso8859_1,
        ..Default::default()
    };
    let items = read(b"[{\"d\":\"caf\xE9\"}]", options);
    assert_eq!(items[0].as_ref().expect("objet").value["d"], "café");
    let items = read(b"[{\"d\":\"caf\xE9\"}, {\"e\":1}]", JsonOptions::default());
    assert_eq!(
        summary(&items),
        vec!["PARSING_INVALID_TEXT", "ok:2:Some(1)"]
    );
}

#[test]
fn rejection_kinds_have_stable_codes() {
    assert_eq!(
        RejectionKind::JsonNotObject.code(),
        "PARSING_JSON_NOT_OBJECT"
    );
    assert_eq!(RejectionKind::JsonSyntax.code(), "PARSING_JSON_SYNTAX");
}

//! Lecteur CSV : champs multilignes (A05), rejets, en-tête, encodages, limites.

use lyxal_parsing::{
    CsvOptions, CsvReader, CsvRecord, Delimiter, Limits, ParseError, ReadFailure, RejectionKind,
    SourceEncoding,
};

fn read(source: &[u8], options: CsvOptions) -> Vec<Result<CsvRecord, ReadFailure>> {
    CsvReader::new(source, options).expect("en-tête").collect()
}

fn records(items: &[Result<CsvRecord, ReadFailure>]) -> Vec<&CsvRecord> {
    items.iter().filter_map(|item| item.as_ref().ok()).collect()
}

fn rejection_kind(item: &Result<CsvRecord, ReadFailure>) -> Option<RejectionKind> {
    match item {
        Err(ReadFailure::Rejected(rejection)) => Some(rejection.kind),
        _ => None,
    }
}

#[test]
fn quoted_field_over_several_lines_is_one_record() {
    // A05 : la lecture ligne par ligne découpait ce champ en plusieurs articles
    let source = b"reference;designation;prix\nBA13;\"Plaque\nde pl\xC3\xA2tre\n\"\"standard\"\"\";8,50\nBA18;Plaque;9,10\n";
    let items = read(source, CsvOptions::default());
    assert_eq!(items.len(), 2, "deux enregistrements, aucun rejet");
    let first = items[0].as_ref().expect("premier");
    assert_eq!(
        first.get("designation"),
        Some("Plaque\nde plâtre\n\"standard\"")
    );
    assert_eq!(first.position.record, 1);
    assert_eq!(first.position.line, Some(2));
    let second = items[1].as_ref().expect("second");
    assert_eq!(second.get("reference"), Some("BA18"));
    assert_eq!(
        second.position.line,
        Some(5),
        "ligne de début après le champ multiligne"
    );
}

#[test]
fn values_are_kept_as_read() {
    let items = read(b"a,b\n  x , y\n", CsvOptions::default());
    let record = items[0].as_ref().expect("enregistrement");
    assert_eq!(
        record.fields,
        vec![
            ("a".to_string(), "  x ".to_string()),
            ("b".to_string(), " y".to_string())
        ]
    );
}

#[test]
fn wrong_field_count_is_rejected_and_reading_continues() {
    let items = read(
        b"a;b;c\n1;2;3\n4;5\n6;7;8;9\n10;11;12\n",
        CsvOptions::default(),
    );
    assert_eq!(items.len(), 4);
    assert_eq!(
        rejection_kind(&items[1]),
        Some(RejectionKind::CsvFieldCount)
    );
    assert_eq!(
        rejection_kind(&items[2]),
        Some(RejectionKind::CsvFieldCount)
    );
    let Err(ReadFailure::Rejected(rejection)) = &items[1] else {
        panic!("rejet attendu");
    };
    assert_eq!(rejection.position.record, 2);
    assert_eq!(rejection.position.line, Some(3));
    assert_eq!(rejection.kind.code(), "PARSING_CSV_FIELD_COUNT");
    assert!(
        !rejection.detail.contains('4'),
        "le diagnostic ne reprend pas le contenu : {}",
        rejection.detail
    );
    let kept: Vec<_> = records(&items)
        .iter()
        .map(|r| r.get("a").unwrap_or_default().to_string())
        .collect();
    assert_eq!(kept, vec!["1", "10"]);
}

#[test]
fn delimiter_is_detected_or_imposed() {
    let reader = CsvReader::new(&b"a,b\n1,2\n"[..], CsvOptions::default()).expect("en-tête");
    assert_eq!(reader.delimiter(), b',');
    let reader = CsvReader::new(&b"a\tb\n1\t2\n"[..], CsvOptions::default()).expect("en-tête");
    assert_eq!(reader.delimiter(), b'\t');
    let options = CsvOptions {
        delimiter: Delimiter::Byte(b'|'),
        ..Default::default()
    };
    let items = read(b"a|b\n1|2\n", options);
    assert_eq!(
        items[0].as_ref().expect("enregistrement").get("b"),
        Some("2")
    );
}

#[test]
fn blank_lines_are_skipped() {
    let items = read(b"a;b\n\n1;2\n\n", CsvOptions::default());
    assert_eq!(items.len(), 1);
}

#[test]
fn invalid_header_stops_reading() {
    for (source, expected) in [
        (&b""[..], "vide"),
        (&b"a;;c\n1;2;3\n"[..], "vide"),
        (&b"a;b;a\n1;2;3\n"[..], "double"),
    ] {
        match CsvReader::new(source, CsvOptions::default()) {
            Err(error @ ParseError::Header { .. }) => {
                assert_eq!(error.code(), "PARSING_HEADER_INVALID");
                assert!(error.to_string().contains(expected), "{error}");
            }
            Err(other) => panic!("en-tête invalide attendu, reçu {other}"),
            Ok(_) => panic!("en-tête invalide accepté"),
        }
    }
}

#[test]
fn utf8_bom_and_declared_windows_1252_are_decoded() {
    let items = read(b"\xEF\xBB\xBFr\xC3\xA9f;prix\nA;1\n", CsvOptions::default());
    assert_eq!(
        items[0].as_ref().expect("enregistrement").get("réf"),
        Some("A")
    );

    let options = CsvOptions {
        encoding: SourceEncoding::Windows1252,
        ..Default::default()
    };
    let items = read(b"d\xE9signation;prix\nCaf\xE9;5 \x80\n", options);
    let record = items[0].as_ref().expect("enregistrement");
    assert_eq!(record.get("désignation"), Some("Café"));
    assert_eq!(record.get("prix"), Some("5 €"));
}

#[test]
fn undecodable_text_is_rejected_when_utf8_is_declared() {
    let items = read(b"a;b\nCaf\xE9;1\nok;2\n", CsvOptions::default());
    assert_eq!(rejection_kind(&items[0]), Some(RejectionKind::InvalidText));
    assert_eq!(items[1].as_ref().expect("suivant").get("a"), Some("ok"));
}

#[test]
fn oversized_record_stops_reading_without_loading_the_source() {
    let limits = Limits {
        max_record_bytes: 1024,
        ..Default::default()
    };
    let options = CsvOptions {
        limits,
        ..Default::default()
    };
    // Champ ouvert jamais refermé : sans limite, tout le reste de la source serait chargé
    let mut source = b"a;b\n1;\"".to_vec();
    source.extend(std::iter::repeat_n(b'x', 512 * 1024));
    let items = read(&source, options);
    let last = items.last().expect("un élément");
    match last {
        Err(ReadFailure::Fatal(error)) => assert_eq!(error.code(), "PARSING_LIMIT"),
        other => panic!("arrêt sur limite attendu, reçu {other:?}"),
    }
}

#[test]
fn record_above_limit_is_rejected_when_isolated() {
    let limits = Limits {
        max_record_bytes: 16,
        ..Default::default()
    };
    let options = CsvOptions {
        limits,
        ..Default::default()
    };
    let items = read(b"a;b\n1;2\nxxxxxxxxxxxxxxxxxxxxxxxx;y\n3;4\n", options);
    assert_eq!(items.len(), 3);
    assert_eq!(
        rejection_kind(&items[1]),
        Some(RejectionKind::RecordTooLarge)
    );
    assert_eq!(items[2].as_ref().expect("suivant").get("a"), Some("3"));
}

#[test]
fn large_source_is_read_in_a_stream_with_a_small_record_limit() {
    // 200 000 lignes (≈ 3 Mio) lues avec une limite de 64 octets par enregistrement : le budget
    // est remis à zéro à chaque enregistrement, la source n'est jamais chargée en entier
    let limits = Limits {
        max_record_bytes: 64,
        ..Default::default()
    };
    let options = CsvOptions {
        limits,
        ..Default::default()
    };
    let mut source = b"reference;prix\n".to_vec();
    for i in 0..200_000 {
        source.extend_from_slice(format!("REF_{i};8,50\n").as_bytes());
    }
    let reader = CsvReader::new(&source[..], options).expect("en-tête");
    let mut count = 0u64;
    for item in reader {
        let record = item.expect("aucun rejet");
        count += 1;
        assert_eq!(record.position.record, count);
    }
    assert_eq!(count, 200_000);
}

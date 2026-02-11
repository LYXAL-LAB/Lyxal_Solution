use lyxal_ical_core::{extract_vtimezones, occurrences, occurrences_with_vtimezones, parse};

#[test]
fn test_floating_time() {
    let out = occurrences(
        "FREQ=DAILY;COUNT=2",
        "20250101T100000",
        None,
        "20250101T000000",
        "20250105T000000",
        &[],
        &[],
    )
    .unwrap();
    assert_eq!(
        out,
        vec![
            "2025-01-01T10:00:00",
            "2025-01-02T10:00:00"
        ]
    );
}

#[test]
fn test_fallback_iana_dst_paris() {
    let out = occurrences(
        "FREQ=DAILY;COUNT=2",
        "20250330T010000",
        Some("Europe/Paris"),
        "20250329T000000Z",
        "20250402T000000Z",
        &[],
        &[],
    )
    .unwrap();
    assert_eq!(
        out,
        vec![
            "2025-03-30T00:00:00+00:00", // offset +1
            "2025-03-30T23:00:00+00:00"  // offset +2 after DST switch
        ]
    );
}

#[test]
fn test_vtimezone_custom_priority() {
    let ics = r#"BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VTIMEZONE
TZID:Custom/Paris
BEGIN:STANDARD
DTSTART:20240101T000000
TZOFFSETFROM:+0100
TZOFFSETTO:+0345
END:STANDARD
END:VTIMEZONE
END:VCALENDAR"#;
    let obj = parse(ics).unwrap();
    let vtz = extract_vtimezones(&obj);

    let out = occurrences_with_vtimezones(
        "FREQ=DAILY;COUNT=1",
        "20250101T120000",
        Some("Custom/Paris"),
        "20250101T000000Z",
        "20250102T000000Z",
        &[],
        &[],
        &vtz,
    )
    .unwrap();

    // offset +03:45 => 12:00 local -> 08:15Z
    assert_eq!(out, vec!["2025-01-01T08:15:00+00:00"]);
}

#[test]
fn test_vtimezone_last_rule_applies() {
    let ics = r#"BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VTIMEZONE
TZID:Custom/Shift
BEGIN:STANDARD
DTSTART:20240101T000000
TZOFFSETFROM:+0100
TZOFFSETTO:+0100
END:STANDARD
BEGIN:STANDARD
DTSTART:20240601T000000
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
END:STANDARD
END:VTIMEZONE
END:VCALENDAR"#;
    let obj = parse(ics).unwrap();
    let vtz = extract_vtimezones(&obj);

    let out = occurrences_with_vtimezones(
        "FREQ=DAILY;COUNT=1",
        "20240701T100000",
        Some("Custom/Shift"),
        "20240701T000000Z",
        "20240702T000000Z",
        &[],
        &[],
        &vtz,
    )
    .unwrap();

    // second rule applies (+02:00) => 08:00Z
    assert_eq!(out, vec!["2024-07-01T08:00:00+00:00"]);
}


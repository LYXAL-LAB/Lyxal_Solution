use lyxal_ical_core::recur::occurrences;

fn dt(s: &str) -> String { s.to_string() }

#[test]
fn daily_count() {
    let res = occurrences(
        "FREQ=DAILY;COUNT=3",
        "20250101T100000Z",
        None,
        "20250101T000000Z",
        "20250110T000000Z",
        &[],
        &[],
    ).unwrap();
    assert_eq!(res.len(), 3);
    assert_eq!(res[0], dt("2025-01-01T10:00:00+00:00"));
    assert_eq!(res[2], dt("2025-01-03T10:00:00+00:00"));
}

#[test]
fn weekly_byday() {
    let res = occurrences(
        "FREQ=WEEKLY;BYDAY=MO,WE",
        "20250101T100000Z", // Wed
        None,
        "20250101T000000Z",
        "20250115T000000Z",
        &[],
        &[],
    ).unwrap();
    // Wed 1st, Mon 6, Wed 8, Mon 13, Wed 15(out)
    assert_eq!(res, vec![
        dt("2025-01-01T10:00:00+00:00"),
        dt("2025-01-06T10:00:00+00:00"),
        dt("2025-01-08T10:00:00+00:00"),
        dt("2025-01-13T10:00:00+00:00"),
    ]);
}

#[test]
fn monthly_bymonthday() {
    let res = occurrences(
        "FREQ=MONTHLY;BYMONTHDAY=15",
        "20250101T100000Z",
        None,
        "20250101T000000Z",
        "20250331T000000Z",
        &[],
        &[],
    ).unwrap();
    assert_eq!(res, vec![
        dt("2025-01-15T10:00:00+00:00"),
        dt("2025-02-15T10:00:00+00:00"),
        dt("2025-03-15T10:00:00+00:00"),
    ]);
}

#[test]
fn until_vs_count_until_wins_if_earlier() {
    let res = occurrences(
        "FREQ=DAILY;COUNT=10;UNTIL=20250103T100000Z",
        "20250101T100000Z",
        None,
        "20250101T000000Z",
        "20250110T000000Z",
        &[],
        &[],
    ).unwrap();
    assert_eq!(res.len(), 3); // until stops at 3rd
}

#[test]
fn exdate_removes() {
    let res = occurrences(
        "FREQ=DAILY;COUNT=5",
        "20250101T100000Z",
        None,
        "20250101T000000Z",
        "20250110T000000Z",
        &["20250102T100000Z"],
        &[],
    ).unwrap();
    assert_eq!(res.len(), 4);
    assert!(!res.contains(&dt("2025-01-02T10:00:00+00:00")));
}

#[test]
fn rdate_adds() {
    let res = occurrences(
        "FREQ=DAILY;COUNT=2",
        "20250101T100000Z",
        None,
        "20250101T000000Z",
        "20250110T000000Z",
        &[],
        &["20250105T100000Z"],
    ).unwrap();
    assert!(res.contains(&dt("2025-01-05T10:00:00+00:00")));
    assert_eq!(res.len(), 3);
}

#[test]
fn window_filtering() {
    let res = occurrences(
        "FREQ=DAILY;COUNT=10",
        "20250101T100000Z",
        None,
        "20250103T000000Z",
        "20250104T000000Z",
        &[],
        &[],
    ).unwrap();
    assert_eq!(res, vec![dt("2025-01-03T10:00:00+00:00")]);
}

#[test]
fn tz_local_to_utc() {
    let res = occurrences(
        "FREQ=DAILY;COUNT=1",
        "20250101T100000",
        Some("Europe/Paris"),
        "20250101T000000Z",
        "20250102T000000Z",
        &[],
        &[],
    ).unwrap();
    // 10:00 in Paris = 09:00Z (winter)
    assert_eq!(res, vec![dt("2025-01-01T09:00:00+00:00")]);
}


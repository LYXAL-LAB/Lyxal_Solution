use lyxal_ical_core::{parse, validate};

fn expect_err(ics: &str, msg_contains: &str) {
    let obj = parse(ics).expect("parse");
    let err = validate(&obj).expect_err("should fail");
    let s = format!("{}", err);
    assert!(s.contains(msg_contains), "expected '{msg_contains}', got '{s}'");
}

#[test]
fn missing_version() {
    let ics = "BEGIN:VCALENDAR\r\nPRODID:-//Test//\r\nEND:VCALENDAR";
    expect_err(ics, "VERSION missing");
}

#[test]
fn wrong_version() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:1.0\r\nPRODID:-//Test//\r\nEND:VCALENDAR";
    expect_err(ics, "VERSION must be 2.0");
}

#[test]
fn missing_prodid() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nEND:VCALENDAR";
    expect_err(ics, "PRODID missing");
}

#[test]
fn missing_uid() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//\r\nBEGIN:VEVENT\r\nDTSTART:20250101T100000Z\r\nEND:VEVENT\r\nEND:VCALENDAR";
    expect_err(ics, "UID missing");
}

#[test]
fn missing_dtstart() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//\r\nBEGIN:VEVENT\r\nUID:1\r\nEND:VEVENT\r\nEND:VCALENDAR";
    expect_err(ics, "DTSTART missing");
}

#[test]
fn dtend_before_dtstart() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//\r\nBEGIN:VEVENT\r\nUID:1\r\nDTSTART:20250102T100000Z\r\nDTEND:20250101T100000Z\r\nEND:VEVENT\r\nEND:VCALENDAR";
    expect_err(ics, "DTEND before DTSTART");
}

#[test]
fn rrule_without_freq() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//\r\nBEGIN:VEVENT\r\nUID:1\r\nDTSTART:20250101T100000Z\r\nRRULE:INTERVAL=1\r\nEND:VEVENT\r\nEND:VCALENDAR";
    expect_err(ics, "RRULE missing FREQ");
}

#[test]
fn tzid_unknown() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//\r\nBEGIN:VEVENT\r\nUID:1\r\nDTSTART;TZID=Custom/Unknown:20250101T100000\r\nEND:VEVENT\r\nEND:VCALENDAR";
    expect_err(ics, "Unknown TZID");
}

#[test]
fn valid_ics_ok() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//\r\nBEGIN:VEVENT\r\nUID:1\r\nDTSTART:20250101T100000Z\r\nRRULE:FREQ=DAILY;COUNT=2\r\nEND:VEVENT\r\nEND:VCALENDAR";
    let obj = parse(ics).unwrap();
    validate(&obj).unwrap();
}


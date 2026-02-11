use lyxal_ical_core::{parse, Component, IcalObject, Property, VCalendar};

fn find_first_calendar(obj: &IcalObject) -> &VCalendar {
    obj.calendars.first().expect("calendar")
}

fn prop_names(props: &[Property]) -> Vec<String> {
    props.iter().map(|p| p.name.clone()).collect()
}

#[test]
fn test_unfolding() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:This is a long\r\n description\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    let event = match cal.components.first().unwrap() {
        Component::VEvent { props, .. } => props,
        _ => panic!("expected vevent"),
    };
    let summary = event.iter().find(|p| p.name == "SUMMARY").unwrap();
    assert_eq!(summary.value, "This is a longdescription");
}

#[test]
fn test_unfolding_no_space_added() {
    let ics = "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\nDESCRIPTION:Hello\r\n World\r\nEND:VEVENT\r\nEND:VCALENDAR";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    let event = match cal.components.first().unwrap() {
        Component::VEvent { props, .. } => props,
        _ => panic!("expected vevent"),
    };
    let desc = event.iter().find(|p| p.name == "DESCRIPTION").unwrap();
    assert_eq!(desc.value, "HelloWorld");
}

#[test]
fn test_params_quoted_and_list() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nATTENDEE;CN=\"John Doe\";TYPE=HOME,WORK:mailto:john@example.com\nEND:VEVENT\nEND:VCALENDAR";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    let event = match cal.components.first().unwrap() {
        Component::VEvent { props, .. } => props,
        _ => panic!("expected vevent"),
    };
    let att = event.iter().find(|p| p.name == "ATTENDEE").unwrap();
    let cn = att.params.get("CN").unwrap();
    assert_eq!(cn, &vec!["John Doe".to_string()]);
    let t = att.params.get("TYPE").unwrap();
    assert_eq!(t, &vec!["HOME".to_string(), "WORK".to_string()]);
}

#[test]
fn test_repeat_properties_multi_values() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nEXDATE:20250101T100000Z\nEXDATE:20250102T100000Z\nATTENDEE;CN=Alice:mailto:alice@example.com\nATTENDEE;CN=Bob:mailto:bob@example.com\nEND:VEVENT\nEND:VCALENDAR";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    let event = match cal.components.first().unwrap() {
        Component::VEvent { props, .. } => props,
        _ => panic!("expected vevent"),
    };
    let exdates: Vec<_> = event.iter().filter(|p| p.name == "EXDATE").collect();
    assert_eq!(exdates.len(), 2);
    let attendees: Vec<_> = event.iter().filter(|p| p.name == "ATTENDEE").collect();
    assert_eq!(attendees.len(), 2);
}

#[test]
fn test_end_mismatch() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nEND:VTODO\nEND:VCALENDAR";
    let err = parse(ics).unwrap_err();
    assert!(matches!(err, lyxal_ical_core::IcalError::MismatchedEnd { .. }));
}

#[test]
fn test_missing_end() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nSUMMARY:Hi\nEND:VCALENDAR";
    let err = parse(ics).unwrap_err();
    assert!(matches!(err, lyxal_ical_core::IcalError::MismatchedEnd { .. }));
}

#[test]
fn test_property_without_colon() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nSUMMARY\nEND:VEVENT\nEND:VCALENDAR";
    let err = parse(ics).unwrap_err();
    assert!(matches!(err, lyxal_ical_core::IcalError::InvalidLine));
}

#[test]
fn test_param_key_case_insensitive() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART;TZID=europe/paris:20250101T100000\nEND:VEVENT\nEND:VCALENDAR";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    let event = match cal.components.first().unwrap() {
        Component::VEvent { props, .. } => props,
        _ => panic!("expected vevent"),
    };
    let dt = event.iter().find(|p| p.name == "DTSTART").unwrap();
    let tz = dt.params.get("TZID").unwrap();
    assert_eq!(tz, &vec!["europe/paris".to_string()]);
}

#[test]
fn test_unexpected_eof_variant() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nSUMMARY:Hi\n";
    let err = parse(ics).unwrap_err();
    assert!(matches!(err, lyxal_ical_core::IcalError::UnexpectedEof { .. }));
}

#[test]
fn test_parse_minimal_vcalendar_vevent() {
    let ics = "BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:1\nSUMMARY:Test\nEND:VEVENT\nEND:VCALENDAR";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    assert!(cal.props.iter().any(|p| p.name == "VERSION"));
    assert_eq!(cal.components.len(), 1);
    if let Component::VEvent { props, .. } = &cal.components[0] {
        assert_eq!(prop_names(props), vec!["UID".to_string(), "SUMMARY".to_string()]);
    } else {
        panic!("expected vevent");
    }
}

#[test]
fn test_parse_vtimezone_nested() {
    let ics = "BEGIN:VCALENDAR\nBEGIN:VTIMEZONE\nTZID:Europe/Paris\nBEGIN:STANDARD\nTZOFFSETFROM:+0200\nTZOFFSETTO:+0100\nEND:STANDARD\nEND:VTIMEZONE\nEND:VCALENDAR";
    let parsed = parse(ics).unwrap();
    let cal = find_first_calendar(&parsed);
    let tz = match cal.components.first().unwrap() {
        Component::VTimezone { props, subcomponents } => (props, subcomponents),
        _ => panic!("expected vtimezone"),
    };
    let tzid = tz.0.iter().find(|p| p.name == "TZID").unwrap();
    assert_eq!(tzid.value, "Europe/Paris");
    assert!(!tz.1.is_empty());
}


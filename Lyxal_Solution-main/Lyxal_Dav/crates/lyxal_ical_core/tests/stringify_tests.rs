use lyxal_ical_core::{parse, stringify, Component, IcalObject, Property, VCalendar};

#[test]
fn test_roundtrip_canonical_stable() {
    let ics = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Hello\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n";
    let p1 = parse(ics).unwrap();
    let s1 = stringify(&p1).unwrap();
    let p2 = parse(&s1).unwrap();
    let s2 = stringify(&p2).unwrap();
    assert_eq!(s1, s2);
}

#[test]
fn test_escaping() {
    let prop = Property {
        name: "SUMMARY".into(),
        params: std::collections::HashMap::new(),
        value: "Hello,World;Test\nLine".into(),
    };
    let cal = VCalendar::new(vec![], vec![Component::VEvent { props: vec![prop], subcomponents: vec![] }]);
    let obj = IcalObject::new(vec![cal]);
    let s = stringify(&obj).unwrap();
    assert!(s.contains("SUMMARY:Hello\\,World\\;Test\\nLine"));
}

#[test]
fn test_params_serialization() {
    let prop = Property {
        name: "ATTENDEE".into(),
        params: {
            let mut m = std::collections::HashMap::new();
            m.insert("CN".into(), vec!["John Doe".into()]);
            m.insert("TYPE".into(), vec!["HOME".into(), "WORK".into()]);
            m
        },
        value: "mailto:john@example.com".into(),
    };
    let cal = VCalendar::new(vec![], vec![Component::VEvent { props: vec![prop], subcomponents: vec![] }]);
    let obj = IcalObject::new(vec![cal]);
    let s = stringify(&obj).unwrap();
    assert!(s.contains("ATTENDEE;CN=\"John Doe\";TYPE=HOME,WORK:mailto:john@example.com"));
}

#[test]
fn test_folding_75_octets() {
    // create long value with multibyte chars
    let long = "Résumé ".repeat(12); // contains é (2 bytes)
    let prop = Property {
        name: "DESCRIPTION".into(),
        params: std::collections::HashMap::new(),
        value: long.clone(),
    };
    let cal = VCalendar::new(vec![], vec![Component::VEvent { props: vec![prop], subcomponents: vec![] }]);
    let obj = IcalObject::new(vec![cal]);
    let s = stringify(&obj).unwrap();
    for line in s.split("\r\n") {
        if line.starts_with(' ') || line.starts_with("DESCRIPTION") {
            assert!(line.as_bytes().len() <= 75, "line too long: {}", line.len());
        }
    }
    let joined: String = s.replace("\r\n ", "").replace("\r\n", "\n");
    assert!(joined.contains(&long));
}

#[test]
fn test_order_canonical_props() {
    let mut props = vec![
        Property { name: "ZPROP".into(), params: std::collections::HashMap::new(), value: "1".into() },
        Property { name: "APROP".into(), params: std::collections::HashMap::new(), value: "2".into() },
    ];
    let cal = VCalendar::new(props.drain(..).collect(), vec![]);
    let obj = IcalObject::new(vec![cal]);
    let s = stringify(&obj).unwrap();
    let pos_a = s.find("APROP").unwrap();
    let pos_z = s.find("ZPROP").unwrap();
    assert!(pos_a < pos_z);
}


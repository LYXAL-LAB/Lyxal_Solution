// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture MIME d'octets quelconques : aucun arrêt, positions dans les bornes.

#![no_main]

use libfuzzer_sys::fuzz_target;
use lyxal_mail_proto::mime::{parse, BodyPart, MimeLimits, PartBody};

fn check(part: &BodyPart, length: u64) {
    if let Some(position) = part.position {
        assert!(position.header_offset <= position.body_offset);
        assert!(position.body_offset <= position.end_offset);
        assert!(position.end_offset <= length);
    }
    match &part.body {
        PartBody::Single => {}
        PartBody::Multipart(children) => children.iter().for_each(|child| check(child, length)),
        PartBody::Message(embedded) => check(&embedded.structure, length),
    }
}

fuzz_target!(|raw: &[u8]| {
    for limits in [
        MimeLimits::default(),
        MimeLimits {
            max_depth: 3,
            max_parts: 8,
            max_addresses: 4,
        },
    ] {
        if let Ok(message) = parse(raw, &limits) {
            check(&message.structure, raw.len() as u64);
        }
    }
});

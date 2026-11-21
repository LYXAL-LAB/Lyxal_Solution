// SPDX-License-Identifier: AGPL-3.0-only

//! Contrôles communs aux essais de lecture MIME.

#![allow(dead_code)]

use lyxal_mail_proto::mime::{BodyPart, PartBody};

/// Vérifie les invariants d'une structure lue dans un message de `length` octets ; rend le
/// nombre de parties.
pub fn check_structure(part: &BodyPart, length: u64) -> usize {
    if let Some(position) = part.position {
        assert!(
            position.header_offset <= position.body_offset,
            "{position:?}"
        );
        assert!(position.body_offset <= position.end_offset, "{position:?}");
        assert!(position.end_offset <= length, "{position:?} > {length}");
        assert_eq!(part.size, position.end_offset - position.body_offset);
    }
    assert!(!part.media_type.is_empty());
    assert!(!part.media_subtype.is_empty());
    assert_eq!(
        part.media_type == "multipart",
        matches!(part.body, PartBody::Multipart(_)),
        "{}/{}",
        part.media_type,
        part.media_subtype
    );
    match &part.body {
        PartBody::Single => 1,
        PartBody::Multipart(children) => {
            1 + children
                .iter()
                .map(|child| check_structure(child, length))
                .sum::<usize>()
        }
        PartBody::Message(embedded) => 1 + check_structure(&embedded.structure, length),
    }
}

/// Parties de premier niveau d'un `multipart`.
pub fn children(part: &BodyPart) -> &[BodyPart] {
    match &part.body {
        PartBody::Multipart(children) => children,
        _ => &[],
    }
}

/// Octets d'une partie lus par ses positions.
pub fn body<'a>(raw: &'a [u8], part: &BodyPart) -> &'a [u8] {
    let position = part.position.expect("partie sans position");
    &raw[position.body_offset as usize..position.end_offset as usize]
}

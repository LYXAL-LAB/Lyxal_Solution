// SPDX-License-Identifier: AGPL-3.0-only

//! Propriétés de la lecture MIME : aucun arrêt, positions dans les bornes, limites tenues,
//! sur des octets quelconques et sur des messages bâtis de fragments MIME.

mod support;

use lyxal_mail_proto::mime::{parse, BodyPart, MimeLimits, PartBody};
use proptest::prelude::*;
use support::check_structure;

fn depth(part: &BodyPart) -> usize {
    match &part.body {
        PartBody::Single => 0,
        PartBody::Multipart(children) => children
            .iter()
            .map(|child| 1 + depth(child))
            .max()
            .unwrap_or(0),
        PartBody::Message(embedded) => 1 + depth(&embedded.structure),
    }
}

fn check(raw: &[u8], limits: &MimeLimits) {
    if let Ok(message) = parse(raw, limits) {
        let parts = check_structure(&message.structure, raw.len() as u64);
        assert!(parts <= usize::from(limits.max_parts));
        assert!(depth(&message.structure) <= usize::from(limits.max_depth));
    }
}

/// Fragments dont l'assemblage donne des messages MIME plausibles, souvent mal formés.
fn fragment() -> impl Strategy<Value = &'static str> {
    prop::sample::select(vec![
        "Subject: =?UTF-8?B?w6l0w6k=?=\r\n",
        "From: a <a@x.fr>, g: b@x.fr;\r\n",
        "Date: Mon, 2 Feb 2026 10:00:00 -0230\r\n",
        "Message-ID: <id@x>\r\nReferences: <a@x> <b@x>\r\n",
        "Content-Type: multipart/mixed; boundary=b\r\n",
        "Content-Type: multipart/digest; boundary=d\r\n",
        "Content-Type: message/rfc822\r\n",
        "Content-Type: message/global\r\n",
        "Content-Type: text/plain; charset=iso-8859-1\r\n",
        "Content-Transfer-Encoding: base64\r\n",
        "Content-Transfer-Encoding: quoted-printable\r\n",
        "Content-Disposition: attachment; filename=\"a.txt\"\r\n",
        " folded\r\n",
        "\r\n",
        "\n",
        "--b\r\n",
        "--b--\r\n",
        "--d\r\n",
        "SGVsbG8=\r\n",
        "=C3=A9=\r\n",
        "corps\r\n",
        ":\r\n",
        "\r",
    ])
}

proptest! {
    #![proptest_config(ProptestConfig {
        // 512 cas au moins ; davantage par PROPTEST_CASES.
        cases: ProptestConfig::default().cases.max(512),
        failure_persistence: None,
        ..ProptestConfig::default()
    })]

    #[test]
    fn octets_quelconques(raw in prop::collection::vec(any::<u8>(), 0..4_096)) {
        check(&raw, &MimeLimits::default());
    }

    #[test]
    fn fragments_mime(parts in prop::collection::vec(fragment(), 0..200)) {
        let raw = parts.concat().into_bytes();
        check(&raw, &MimeLimits::default());
        check(&raw, &MimeLimits { max_depth: 2, max_parts: 5, max_addresses: 1 });
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture MIME de messages écrits pour Lyxal OS : en-têtes, jeux de caractères, structure,
//! positions, messages joints, fils, limites et messages mal formés.

mod support;

use lyxal_mail_proto::mime::{
    parse, AddressEntry, BodyPart, MailAddress, MimeError, MimeLimits, ParsedMessage, PartBody,
};
use support::{body, check_structure, children};
use time::{OffsetDateTime, UtcOffset};

/// Message aux fins de ligne CRLF.
fn crlf(text: &str) -> Vec<u8> {
    text.replace('\n', "\r\n").into_bytes()
}

fn read(raw: &[u8]) -> ParsedMessage {
    let message = parse(raw, &MimeLimits::default()).expect("message lisible");
    check_structure(&message.structure, raw.len() as u64);
    message
}

fn mailbox(name: Option<&str>, address: &str) -> AddressEntry {
    AddressEntry::Mailbox(MailAddress {
        name: name.map(str::to_owned),
        address: Some(address.to_owned()),
    })
}

fn embedded(part: &BodyPart) -> &lyxal_mail_proto::mime::EmbeddedMessage {
    match &part.body {
        PartBody::Message(embedded) => embedded,
        other => panic!("message joint attendu : {other:?}"),
    }
}

#[test]
fn lit_l_enveloppe_d_un_message_simple() {
    let raw = crlf(
        "Date: Sat, 21 Nov 2026 10:15:00\n +0100\n\
         From: =?ISO-8859-1?Q?Ren=E9?= <rene@exemple.fr>\n\
         Sender: secretariat@exemple.fr\n\
         Reply-To: reponses@exemple.fr\n\
         To: Alice <alice@exemple.fr>, bob@exemple.fr\n\
         Cc: Equipe: carla@exemple.fr, dan@exemple.fr;, eve@exemple.fr\n\
         Subject: =?UTF-8?B?UmU6IENhZsOp?=\n\t et   =?Shift_JIS?B?k/qWew==?=\n\
         Message-ID: <m1@exemple.fr>\n\
         In-Reply-To: <p1@exemple.fr>\n\
         References: <r0@exemple.fr> <p1@exemple.fr>\n\
         X-Ignored: valeur\n\
         \n\
         Bonjour.\n",
    );
    let message = read(&raw);
    let envelope = &message.envelope;
    assert_eq!(
        envelope.date.as_deref(),
        Some("Sat, 21 Nov 2026 10:15:00 +0100")
    );
    let sent_at = message.sent_at.expect("date lue");
    assert_eq!(
        sent_at,
        OffsetDateTime::from_unix_timestamp(1_795_252_500).expect("date")
    );
    assert_eq!(
        sent_at.offset(),
        UtcOffset::from_hms(1, 0, 0).expect("décalage")
    );
    assert_eq!(
        envelope.from,
        vec![mailbox(Some("René"), "rene@exemple.fr")]
    );
    assert_eq!(
        envelope.sender,
        vec![mailbox(None, "secretariat@exemple.fr")]
    );
    assert_eq!(
        envelope.reply_to,
        vec![mailbox(None, "reponses@exemple.fr")]
    );
    assert_eq!(
        envelope.to,
        vec![
            mailbox(Some("Alice"), "alice@exemple.fr"),
            mailbox(None, "bob@exemple.fr")
        ]
    );
    assert_eq!(envelope.cc.len(), 2, "{:?}", envelope.cc);
    match &envelope.cc[0] {
        AddressEntry::Group { name, members } => {
            assert_eq!(name, "Equipe");
            assert_eq!(members.len(), 2);
        }
        other => panic!("groupe attendu : {other:?}"),
    }
    assert!(envelope.bcc.is_empty());
    let subject = envelope.subject.as_deref().unwrap_or_default();
    assert!(subject.starts_with("Re: Café"), "{subject}");
    assert!(subject.ends_with("日本"), "{subject}");
    let base = message.base_subject.as_deref().unwrap_or_default();
    assert!(base.starts_with("Café et "), "{base}");
    assert!(!base.contains("  "), "{base}");
    assert_eq!(envelope.message_id.as_deref(), Some("m1@exemple.fr"));
    assert_eq!(message.thread.message_id.as_deref(), Some("m1@exemple.fr"));
    assert_eq!(
        message.thread.ancestors,
        vec!["p1@exemple.fr", "r0@exemple.fr"]
    );

    let root = &message.structure;
    assert_eq!(
        (root.media_type.as_str(), root.media_subtype.as_str()),
        ("text", "plain")
    );
    assert_eq!(body(&raw, root), b"Bonjour.\r\n");
    assert_eq!(root.lines, Some(1));
    assert_eq!(root.position.map(|p| p.header_offset), Some(0));
    assert!(!message.has_attachment);
    assert!(!message.is_report);
}

#[test]
fn lit_une_structure_imbriquee_avec_ses_positions() {
    let raw = crlf(
        "From: a@exemple.fr\n\
         Subject: Pieces\n\
         MIME-Version: 1.0\n\
         Content-Type: multipart/mixed; boundary=\"ext\"\n\
         \n\
         preambule\n\
         --ext\n\
         Content-Type: multipart/alternative; boundary=int\n\
         \n\
         --int\n\
         Content-Type: text/plain; charset=utf-8\n\
         Content-Transfer-Encoding: quoted-printable\n\
         \n\
         Caf=C3=A9\n\
         ligne 2\n\
         --int\n\
         Content-Type: text/html; charset=utf-8\n\
         \n\
         <p>Café</p>\n\
         --int--\n\
         --ext\n\
         Content-Type: application/pdf; name=\"ancien.pdf\"\n\
         Content-Disposition: attachment;\n filename*=utf-8''r%C3%A9sum%C3%A9.pdf\n\
         Content-Transfer-Encoding: BASE64\n\
         Content-ID: <piece1@exemple.fr>\n\
         Content-Description: Resume\n\
         Content-Language: fr, en\n\
         \n\
         JVBERi0xLjQK\n\
         --ext\n\
         Content-Type: image/png\n\
         Content-Disposition: inline; filename=logo.png\n\
         Content-Transfer-Encoding: base64\n\
         \n\
         iVBORw0KGgo=\n\
         --ext--\n\
         epilogue\n",
    );
    let message = read(&raw);
    let root = &message.structure;
    assert_eq!(root.media_subtype, "mixed");
    assert_eq!(
        root.parameters
            .first()
            .map(|p| (p.name.as_str(), p.value.as_str())),
        Some(("boundary", "ext"))
    );
    let parts = children(root);
    assert_eq!(parts.len(), 3);

    let alternative = &parts[0];
    assert_eq!(alternative.media_subtype, "alternative");
    let texts = children(alternative);
    assert_eq!(texts.len(), 2);
    assert_eq!(
        texts[0].transfer_encoding.as_deref(),
        Some("quoted-printable")
    );
    assert_eq!(body(&raw, &texts[0]), b"Caf=C3=A9\r\nligne 2");
    assert_eq!(texts[0].lines, Some(2));
    assert_eq!(texts[1].media_subtype, "html");
    assert_eq!(body(&raw, &texts[1]), "<p>Café</p>".as_bytes());

    let pdf = &parts[1];
    assert_eq!(
        (pdf.media_type.as_str(), pdf.media_subtype.as_str()),
        ("application", "pdf")
    );
    assert_eq!(pdf.disposition.as_deref(), Some("attachment"));
    assert_eq!(pdf.file_name.as_deref(), Some("résumé.pdf"));
    assert_eq!(pdf.transfer_encoding.as_deref(), Some("base64"));
    assert_eq!(pdf.content_id.as_deref(), Some("piece1@exemple.fr"));
    assert_eq!(pdf.description.as_deref(), Some("Resume"));
    assert_eq!(pdf.languages, vec!["fr", "en"]);
    assert_eq!(body(&raw, pdf), b"JVBERi0xLjQK");
    assert_eq!(pdf.lines, None);
    assert!(pdf.is_attachment);
    let header = pdf
        .position
        .map(|p| p.header_offset as usize)
        .unwrap_or_default();
    assert!(raw[header..].starts_with(b"Content-Type: application/pdf"));

    let logo = &parts[2];
    assert_eq!(logo.disposition.as_deref(), Some("inline"));
    assert!(!logo.is_attachment);
    assert!(message.has_attachment);
    assert_eq!(check_structure(root, raw.len() as u64), 6);
}

#[test]
fn lit_un_message_joint_non_encode_dans_le_fichier() {
    let raw = crlf(
        "From: a@exemple.fr\n\
         Subject: Transfert\n\
         Content-Type: multipart/mixed; boundary=b\n\
         \n\
         --b\n\
         Content-Type: text/plain\n\
         \n\
         Voir ci-joint.\n\
         --b\n\
         Content-Type: message/rfc822\n\
         \n\
         From: origine@exemple.fr\n\
         To: a@exemple.fr\n\
         Subject: Original\n\
         Message-ID: <orig@exemple.fr>\n\
         \n\
         Texte original.\n\
         --b--\n",
    );
    let message = read(&raw);
    let parts = children(&message.structure);
    assert_eq!(parts.len(), 2);
    let attached = &parts[1];
    assert_eq!(attached.media_type, "message");
    assert!(attached.is_attachment);
    assert!(message.has_attachment);
    let inner = embedded(attached);
    assert_eq!(inner.envelope.subject.as_deref(), Some("Original"));
    assert_eq!(
        inner.envelope.message_id.as_deref(),
        Some("orig@exemple.fr")
    );
    assert_eq!(
        inner.envelope.from,
        vec![mailbox(None, "origine@exemple.fr")]
    );
    assert_eq!(body(&raw, &inner.structure), b"Texte original.");
    assert!(!inner.structure.is_attachment);
    assert_eq!(attached.lines, Some(6));
    // Le message lui-même garde son enveloppe.
    assert_eq!(message.envelope.subject.as_deref(), Some("Transfert"));
}

#[test]
fn decode_un_message_joint_encode_sans_avaler_la_partie_suivante() {
    // « From: x@exemple.fr\r\nSubject: Encode\r\n\r\nCorps\r\n » en base64.
    let raw = crlf(
        "From: a@exemple.fr\n\
         Content-Type: multipart/mixed; boundary=b\n\
         \n\
         --b\n\
         Content-Type: message/rfc822\n\
         Content-Transfer-Encoding: base64\n\
         \n\
         RnJvbTogeEBleGVtcGxlLmZyDQpTdWJqZWN0OiBFbmNvZGUNCg0KQ29ycHMNCg==\n\
         --b\n\
         Content-Type: application/octet-stream; name=suite.bin\n\
         \n\
         xyz\n\
         --b--\n",
    );
    let message = read(&raw);
    let parts = children(&message.structure);
    assert_eq!(parts.len(), 2, "{parts:#?}");
    let attached = &parts[0];
    assert_eq!(
        (
            attached.media_type.as_str(),
            attached.media_subtype.as_str()
        ),
        ("message", "rfc822")
    );
    assert!(!attached.malformed);
    assert!(attached.position.is_some());
    let inner = embedded(attached);
    assert_eq!(inner.envelope.subject.as_deref(), Some("Encode"));
    assert_eq!(inner.structure.position, None);
    assert_eq!(inner.structure.size, "Corps\r\n".len() as u64);
    assert_eq!(parts[1].file_name.as_deref(), Some("suite.bin"));
    assert_eq!(body(&raw, &parts[1]), b"xyz");
}

#[test]
fn signale_un_message_joint_encode_illisible() {
    let raw = crlf(
        "Content-Type: message/rfc822\n\
         Content-Transfer-Encoding: base64\n\
         \n\
         !!!pas du base64!!!\n",
    );
    let message = read(&raw);
    assert_eq!(message.structure.media_type, "message");
    assert!(message.structure.malformed);
    assert_eq!(message.structure.body, PartBody::Single);
}

#[test]
fn lit_les_enfants_d_un_digest_comme_des_messages() {
    let raw = crlf(
        "Content-Type: multipart/digest; boundary=d\n\
         \n\
         --d\n\
         \n\
         Subject: Premier\n\
         \n\
         un\n\
         --d\n\
         \n\
         Subject: Second\n\
         \n\
         deux\n\
         --d--\n",
    );
    let message = read(&raw);
    let parts = children(&message.structure);
    assert_eq!(parts.len(), 2);
    for (part, subject) in parts.iter().zip(["Premier", "Second"]) {
        assert_eq!(
            (part.media_type.as_str(), part.media_subtype.as_str()),
            ("message", "rfc822")
        );
        assert_eq!(embedded(part).envelope.subject.as_deref(), Some(subject));
    }
}

#[test]
fn reconnait_un_avis_de_non_remise() {
    let raw = crlf(
        "From: MAILER-DAEMON@exemple.fr\n\
         Subject: Undelivered Mail\n\
         Content-Type: multipart/report; report-type=delivery-status; boundary=r\n\
         \n\
         --r\n\
         Content-Type: text/plain\n\
         \n\
         Echec.\n\
         --r\n\
         Content-Type: message/delivery-status\n\
         \n\
         Reporting-MTA: dns; mx.exemple.fr\n\
         --r--\n",
    );
    let message = read(&raw);
    assert!(message.is_report);
    assert_eq!(message.base_subject.as_deref(), Some("Undelivered Mail"));
}

#[test]
fn garde_un_message_tronque_ou_mal_forme() {
    // Frontière de fin absente, partie coupée.
    let raw = crlf(
        "Subject: Coupe\n\
         Content-Type: multipart/mixed; boundary=b\n\
         \n\
         --b\n\
         Content-Type: text/plain\n\
         \n\
         debut du tex",
    );
    let message = read(&raw);
    assert_eq!(message.envelope.subject.as_deref(), Some("Coupe"));

    // `multipart` sans frontière : lu comme un `multipart` vide, signalé.
    let raw = crlf("Content-Type: multipart/mixed\n\ntexte\n");
    let message = read(&raw);
    assert!(message.structure.malformed);
    assert_eq!(message.structure.body, PartBody::Multipart(Vec::new()));

    // Type sans sous-type.
    let raw = crlf("Content-Type: image\n\nxx\n");
    let message = read(&raw);
    assert_eq!(
        (
            message.structure.media_type.as_str(),
            message.structure.media_subtype.as_str()
        ),
        ("application", "octet-stream")
    );
    assert!(message.structure.malformed);

    // En-têtes seuls, sans corps ; date illisible.
    let raw = b"Subject: seul\r\nDate: pas une date\r\n";
    let message = read(raw);
    assert_eq!(message.envelope.subject.as_deref(), Some("seul"));
    assert_eq!(message.sent_at, None);

    // Fins de ligne LF seules.
    let raw = b"Subject: lf\n\ncorps\n";
    let message = read(raw);
    assert_eq!(body(raw, &message.structure), b"corps\n");
}

#[test]
fn refuse_un_message_vide_ou_sans_en_tete() {
    let limits = MimeLimits::default();
    assert_eq!(parse(b"", &limits), Err(MimeError::Empty));
    assert_eq!(parse(b"\r\n\r\n", &limits), Err(MimeError::NoHeader));
    assert_eq!(
        parse(b"bonjour sans en-tete", &limits),
        Err(MimeError::NoHeader)
    );
}

/// `multipart` imbriqués sur `levels` niveaux.
fn nested_multiparts(levels: usize) -> Vec<u8> {
    let mut raw = String::new();
    for level in 0..levels {
        raw.push_str(&format!(
            "Content-Type: multipart/mixed; boundary=b{level}\n\n--b{level}\n"
        ));
    }
    raw.push_str("Content-Type: text/plain\n\nfeuille\n");
    for level in (0..levels).rev() {
        raw.push_str(&format!("--b{level}--\n"));
    }
    crlf(&raw)
}

#[test]
fn applique_les_limites() {
    let limits = MimeLimits::default();
    assert!(parse(&nested_multiparts(20), &limits).is_ok());
    assert_eq!(
        parse(&nested_multiparts(21), &limits),
        Err(MimeError::TooDeep { max: 20 })
    );

    let few_parts = MimeLimits {
        max_parts: 2,
        ..limits
    };
    assert_eq!(
        parse(&nested_multiparts(3), &few_parts),
        Err(MimeError::TooManyParts { max: 2 })
    );

    let few_addresses = MimeLimits {
        max_addresses: 2,
        ..limits
    };
    let raw = crlf("From: a@x.fr\nTo: b@x.fr, c@x.fr\n\ncorps\n");
    assert_eq!(
        parse(&raw, &few_addresses),
        Err(MimeError::TooManyAddresses { max: 2 })
    );
    assert!(parse(&raw, &limits).is_ok());

    // Aucun plafond propre à ce crate : les limites de l'appelant s'appliquent telles quelles.
    let mut raw = String::from("Content-Type: multipart/mixed; boundary=b\n\n");
    for _ in 0..5_000 {
        raw.push_str("--b\nContent-Type: text/plain\n\nx\n");
    }
    raw.push_str("--b--\n");
    let raw = crlf(&raw);
    assert_eq!(
        parse(&raw, &limits),
        Err(MimeError::TooManyParts { max: 1_000 })
    );
    let raised = MimeLimits {
        max_parts: u16::MAX,
        ..limits
    };
    let message = parse(&raw, &raised).expect("5 001 parties sous une limite relevée");
    assert_eq!(children(&message.structure).len(), 5_000);
}

/// Limites les plus hautes que [`MimeLimits`] permet.
const HIGHEST: MimeLimits = MimeLimits {
    max_depth: u8::MAX,
    max_parts: u16::MAX,
    max_addresses: u16::MAX,
};

/// Lit `raw` sur un fil à la pile de 2 Mio (celle des fils de `tokio`).
fn parse_on_small_stack(raw: &[u8], limits: MimeLimits) -> Result<ParsedMessage, MimeError> {
    let raw = raw.to_vec();
    std::thread::Builder::new()
        .stack_size(2 * 1024 * 1024)
        .spawn(move || parse(&raw, &limits))
        .expect("fil de lecture")
        .join()
        .expect("lecture sans arrêt du fil")
}

#[test]
fn resiste_a_une_imbrication_profonde_de_messages_joints() {
    // 200 000 messages joints non encodés emboîtés (6 Mio). `mail-parser` 0.11 épuisait la pile
    // en libérant sa structure ; la 1.0 range les parties à plat et borne la profondeur.
    let mut plain = b"Subject: x\r\n".to_vec();
    for _ in 0..200_000 {
        plain.extend_from_slice(b"Content-Type: message/rfc822\r\n\r\n");
    }
    plain.extend_from_slice(b"Subject: fond\r\n\r\ncorps\r\n");

    // La même chaîne (50 000 niveaux), cachée dans un message joint encodé en base64.
    let mut inner = Vec::new();
    for _ in 0..50_000 {
        inner.extend_from_slice(b"Content-Type: message/rfc822\r\n\r\n");
    }
    inner.extend_from_slice(b"Subject: fond\r\n\r\ncorps\r\n");
    let mut hidden =
        b"Content-Type: message/rfc822\r\nContent-Transfer-Encoding: base64\r\n\r\n".to_vec();
    hidden.extend_from_slice(base64(&inner).as_bytes());
    hidden.extend_from_slice(b"\r\n");

    let multiparts = nested_multiparts(990);

    for raw in [&plain, &hidden, &multiparts] {
        assert_eq!(
            parse_on_small_stack(raw, MimeLimits::default()),
            Err(MimeError::TooDeep { max: 20 })
        );
        // Limites au plus haut : la projection récursive tient sur la pile (255 niveaux).
        assert_eq!(
            parse_on_small_stack(raw, HIGHEST),
            Err(MimeError::TooDeep { max: u8::MAX })
        );
    }
}

/// Encodage base64 (alphabet standard, lignes de 76 caractères), pour les essais.
fn base64(bytes: &[u8]) -> String {
    const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut out = String::new();
    for (index, chunk) in bytes.chunks(3).enumerate() {
        if index > 0 && index % 19 == 0 {
            out.push_str("\r\n");
        }
        let b = [
            chunk[0],
            *chunk.get(1).unwrap_or(&0),
            *chunk.get(2).unwrap_or(&0),
        ];
        let n = (u32::from(b[0]) << 16) | (u32::from(b[1]) << 8) | u32::from(b[2]);
        for (position, shift) in [18, 12, 6, 0].into_iter().enumerate() {
            if position <= chunk.len() {
                out.push(ALPHABET[((n >> shift) & 63) as usize] as char);
            } else {
                out.push('=');
            }
        }
    }
    out
}

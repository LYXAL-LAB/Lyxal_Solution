// SPDX-License-Identifier: AGPL-3.0-only

//! Avis de non-remise sur des octets quelconques (lot 6) : le message entier, puis les mêmes
//! octets comme partie `message/delivery-status` d'un rapport ; aucun arrêt, limites tenues.
//! Chaque échange `AUTH` (`PLAIN`, `LOGIN`) est aussi alimenté par les mêmes octets.

#![no_main]

use libfuzzer_sys::fuzz_target;
use lyxal_mail_proto::dsn::{parse_dsn, MAX_DSN_RECIPIENTS, MAX_FIELD_BYTES};
use lyxal_mail_proto::mime::{parse, MimeLimits};
use lyxal_mail_proto::smtp::{AuthExchange, SaslData};

fn check(raw: &[u8]) {
    let Ok(parsed) = parse(raw, &MimeLimits::default()) else {
        return;
    };
    if let Ok(report) = parse_dsn(raw, &parsed) {
        assert!(!report.recipients.is_empty());
        assert!(report.recipients.len() <= MAX_DSN_RECIPIENTS);
        for recipient in &report.recipients {
            assert!(recipient.final_recipient.address.len() <= MAX_FIELD_BYTES);
            if let Some(diagnostic) = &recipient.diagnostic {
                assert!(diagnostic.text.len() <= MAX_FIELD_BYTES);
                assert!(!diagnostic.text.contains(['\r', '\n']));
            }
        }
    }
}

fuzz_target!(|raw: &[u8]| {
    check(raw);
    let mut wrapped = b"From: x@example.org\r\nMIME-Version: 1.0\r\n\
        Content-Type: multipart/report; report-type=delivery-status; boundary=b\r\n\r\n\
        --b\r\nContent-Type: text/plain\r\n\r\ntext\r\n\
        --b\r\nContent-Type: message/delivery-status\r\n\r\n"
        .to_vec();
    wrapped.extend_from_slice(raw);
    wrapped.extend_from_slice(b"\r\n--b--\r\n");
    check(&wrapped);

    for mechanism in ["PLAIN", "LOGIN"] {
        let data = SaslData::new(raw.to_vec());
        if let Ok((mut exchange, _)) = AuthExchange::start(mechanism, Some(&data)) {
            let _ = exchange.step(&data);
        }
    }
});

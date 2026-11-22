// SPDX-License-Identifier: AGPL-3.0-only

//! Commandes SMTP sur des octets quelconques : aucun arrêt ; une commande par LF quel que soit
//! le découpage (premier octet : taille des morceaux) ; consommation jamais au-delà d'une ligne ;
//! réponses d'erreur bien formées.

#![no_main]

use libfuzzer_sys::fuzz_target;
use lyxal_mail_proto::smtp::{parse_command, CommandReceiver, SmtpLimits};

fuzz_target!(|raw: &[u8]| {
    let Some((&split, input)) = raw.split_first() else {
        return;
    };
    let _ = parse_command(input);
    let chunk = usize::from(split).max(1);
    let limits = SmtpLimits::new(512, 1 << 20).unwrap_or_default();
    let mut receiver = CommandReceiver::new(&limits);
    let mut results = 0;
    for mut piece in input.chunks(chunk) {
        while !piece.is_empty() {
            let ingested = receiver.ingest(piece);
            assert!(ingested.consumed > 0 && ingested.consumed <= piece.len());
            if let Some(result) = ingested.item {
                assert_eq!(piece[ingested.consumed - 1], b'\n');
                results += 1;
                if let Err(error) = result {
                    let bytes = error.response().to_bytes();
                    assert!(bytes.ends_with(b"\r\n"));
                    assert_eq!(bytes.iter().filter(|&&b| b == b'\n').count(), 1);
                }
            }
            piece = &piece[ingested.consumed..];
        }
    }
    assert_eq!(results, input.iter().filter(|&&b| b == b'\n').count());
});

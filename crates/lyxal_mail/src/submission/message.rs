// SPDX-License-Identifier: AGPL-3.0-only

//! Message déposé (plan du lot 6, §8.5, décision E17) : adresses d'expéditeur de l'en-tête et
//! octets mis en file.
//!
//! * Adresses contrôlées : chaque adresse des champs `From` (exactement un champ), `Sender` (un
//!   au plus), `Resent-From` et `Resent-Sender` (RFC 5322 §3.6.2, §3.6.6), lue par la lecture
//!   MIME de `lyxal_mail_proto` (groupes, commentaires, mots encodés), domaine en forme ASCII,
//!   casse ignorée ; 10 adresses distinctes au plus (`fn::mail_sender_check`).
//! * Octets mis en file : `Received` du dépôt (sans adresse IP du client ni compte), `Date` et
//!   `Message-ID` ajoutés s'ils manquent (RFC 6409 §8.3, §8.4), puis les champs reçus sans `Bcc`
//!   ni `Resent-Bcc` (les destinataires cachés ne sont jamais transmis, RFC 5322 §3.6.3), puis le
//!   corps. Aucun autre champ n'est modifié.

use lyxal_mail_proto::mime::{parse, AddressEntry, MimeLimits};

use crate::auth::{to_ascii_domain, MessageHeaders};

/// Adresses distinctes d'expéditeur au plus dans l'en-tête (`fn::mail_sender_check`).
pub(crate) const MAX_SENDER_ADDRESSES: usize = 10;

/// Champs d'en-tête dont chaque adresse doit être permise au compte.
const SENDER_FIELDS: [&str; 4] = ["From", "Sender", "Resent-From", "Resent-Sender"];

/// Champs retirés du message mis en file.
const HIDDEN_FIELDS: [&str; 2] = ["Bcc", "Resent-Bcc"];

/// En-tête d'expéditeur refusé.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum SenderRefusal {
    /// Pas exactement un champ `From`, plus d'un `Sender`, champ sans adresse ou adresse
    /// illisible (`550 5.6.0`).
    Malformed,
    /// Adresse qu'aucun compte de Lyxal ne peut porter (partie locale en UTF-8, domaine
    /// inconvertible) (`550 5.7.1`).
    Forbidden,
    /// Plus de [`MAX_SENDER_ADDRESSES`] adresses distinctes (`550 5.7.1`).
    TooMany,
}

/// Adresses d'expéditeur de l'en-tête, normalisées (minuscules, domaine ASCII), sans doublon,
/// dans l'ordre des champs.
pub(crate) fn sender_addresses(headers: &MessageHeaders<'_>) -> Result<Vec<String>, SenderRefusal> {
    if headers.count("From") != 1 || headers.count("Sender") > 1 {
        return Err(SenderRefusal::Malformed);
    }
    let mut addresses: Vec<String> = Vec::new();
    for field in headers
        .fields
        .iter()
        .filter(|field| SENDER_FIELDS.iter().any(|name| field.is(name)))
    {
        let found = field_addresses(field.value)?;
        if found.is_empty() {
            return Err(SenderRefusal::Malformed);
        }
        for address in found {
            if !addresses.contains(&address) {
                addresses.push(address);
            }
        }
        if addresses.len() > MAX_SENDER_ADDRESSES {
            return Err(SenderRefusal::TooMany);
        }
    }
    Ok(addresses)
}

/// Adresses d'un champ, lues comme celles d'un `From` par la lecture MIME.
fn field_addresses(value: &[u8]) -> Result<Vec<String>, SenderRefusal> {
    let mut raw = Vec::with_capacity(value.len() + 9);
    raw.extend_from_slice(b"From:");
    raw.extend_from_slice(value);
    raw.extend_from_slice(b"\r\n\r\n");
    let parsed = parse(&raw, &MimeLimits::default()).map_err(|_| SenderRefusal::Malformed)?;
    let mut addresses = Vec::new();
    for entry in &parsed.envelope.from {
        let members = match entry {
            AddressEntry::Mailbox(address) => std::slice::from_ref(address),
            AddressEntry::Group { members, .. } => members.as_slice(),
        };
        for member in members {
            let text = member.address.as_deref().ok_or(SenderRefusal::Malformed)?;
            addresses.push(normalize_address(text)?);
        }
    }
    Ok(addresses)
}

/// Adresse en minuscules, domaine en forme ASCII (A-label).
pub(crate) fn normalize_address(address: &str) -> Result<String, SenderRefusal> {
    let (local, domain) = address
        .trim()
        .rsplit_once('@')
        .ok_or(SenderRefusal::Malformed)?;
    if local.is_empty() {
        return Err(SenderRefusal::Malformed);
    }
    if !local.is_ascii() {
        return Err(SenderRefusal::Forbidden);
    }
    let domain = to_ascii_domain(domain).ok_or(SenderRefusal::Forbidden)?;
    Ok(format!("{}@{domain}", local.to_ascii_lowercase()))
}

/// En-tête `Received` du dépôt (RFC 5321 §4.4, protocole `ESMTPSA` ou `UTF8SMTPSA`, RFC 3848,
/// RFC 6531 §3.7.3) : nom annoncé par `EHLO` (déjà contrôlé), notre nom, identifiant, date ;
/// ni l'adresse IP du client, ni son compte (plan §8.5, étape 5).
pub(crate) fn submission_received(
    helo: &str,
    hostname: &str,
    smtputf8: bool,
    id: &str,
    date: &str,
) -> String {
    let protocol = if smtputf8 { "UTF8SMTPSA" } else { "ESMTPSA" };
    format!("Received: from {helo}\r\n\tby {hostname} with {protocol} id {id};\r\n\t{date}\r\n")
}

/// Octets mis en file : `received`, `Date` (`date`) et `Message-ID` (`<UUID v7@hostname>`)
/// s'ils manquent, champs reçus sans `Bcc` ni `Resent-Bcc`, ligne vide, corps.
pub(crate) fn prepare_message(
    headers: &MessageHeaders<'_>,
    received: &str,
    date: &str,
    hostname: &str,
) -> Vec<u8> {
    let kept = headers
        .fields
        .iter()
        .filter(|field| !HIDDEN_FIELDS.iter().any(|name| field.is(name)));
    let mut out = Vec::with_capacity(
        received.len() + 128 + headers.fields.iter().map(|f| f.raw.len()).sum::<usize>(),
    );
    out.extend_from_slice(received.as_bytes());
    if headers.count("Date") == 0 {
        out.extend_from_slice(format!("Date: {date}\r\n").as_bytes());
    }
    if headers.count("Message-ID") == 0 {
        out.extend_from_slice(
            format!("Message-ID: <{}@{hostname}>\r\n", uuid::Uuid::now_v7()).as_bytes(),
        );
    }
    for field in kept {
        out.extend_from_slice(field.raw);
        if !field.raw.ends_with(b"\n") {
            out.extend_from_slice(b"\r\n");
        }
    }
    out.extend_from_slice(b"\r\n");
    out.extend_from_slice(headers.body);
    out
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;

    fn addresses(raw: &str) -> Result<Vec<String>, SenderRefusal> {
        sender_addresses(&MessageHeaders::parse(raw.as_bytes()).unwrap())
    }

    #[test]
    fn every_sender_field_is_read_and_normalized() {
        let found = addresses(
            "From: \"Jean D.\" <Jean@Alpha.TEST>, paul@alpha.test\r\n\
             Sender: =?utf-8?q?Secr=C3=A9tariat?= <secretariat@alpha.test>\r\n\
             Resent-From: Equipe: jean@alpha.test, marie@alpha.test;\r\n\
             Resent-Sender: chef@xn--bcher-kva.test\r\n\
             To: x@ailleurs.test\r\n\r\nCorps\r\n",
        )
        .unwrap();
        assert_eq!(
            found,
            [
                "jean@alpha.test",
                "paul@alpha.test",
                "secretariat@alpha.test",
                "marie@alpha.test",
                "chef@xn--bcher-kva.test"
            ]
        );
        // Domaine Unicode converti en forme ASCII ; partie locale UTF-8 : aucun compte possible
        assert_eq!(
            addresses("From: chef@bücher.test\r\n\r\n").unwrap(),
            ["chef@xn--bcher-kva.test"]
        );
        assert_eq!(
            addresses("From: jéan@alpha.test\r\n\r\n"),
            Err(SenderRefusal::Forbidden)
        );
    }

    #[test]
    fn malformed_or_excessive_sender_fields_are_refused() {
        assert_eq!(
            addresses("To: x@y.test\r\n\r\n"),
            Err(SenderRefusal::Malformed)
        );
        assert_eq!(
            addresses("From: a@alpha.test\r\nFrom: b@alpha.test\r\n\r\n"),
            Err(SenderRefusal::Malformed)
        );
        assert_eq!(
            addresses("From: a@alpha.test\r\nSender: b@alpha.test\r\nSender: c@alpha.test\r\n\r\n"),
            Err(SenderRefusal::Malformed)
        );
        assert_eq!(
            addresses("From: Personne\r\n\r\n"),
            Err(SenderRefusal::Malformed)
        );
        assert_eq!(
            addresses("From: Vide:;\r\n\r\n"),
            Err(SenderRefusal::Malformed)
        );
        let many = (0..11)
            .map(|n| format!("a{n}@alpha.test"))
            .collect::<Vec<_>>()
            .join(", ");
        assert_eq!(
            addresses(&format!("From: {many}\r\n\r\n")),
            Err(SenderRefusal::TooMany)
        );
        // Une adresse répétée ne compte qu'une fois
        let repeated = ["a@alpha.test"; 11].join(", ");
        assert_eq!(
            addresses(&format!("From: {repeated}\r\n\r\n")).unwrap(),
            ["a@alpha.test"]
        );
    }

    #[test]
    fn hidden_recipients_are_removed_and_missing_fields_added() {
        let raw = "From: jean@alpha.test\r\nTo: paul@ailleurs.test\r\nBcc: cache@ailleurs.test,\r\n autre@ailleurs.test\r\nresent-bcc: x@y.test\r\nSubject: Devis\r\n\r\nCorps\r\n.\r\n";
        let headers = MessageHeaders::parse(raw.as_bytes()).unwrap();
        let received = submission_received(
            "poste.alpha.test",
            "mx.alpha.test",
            false,
            "1f.1",
            "Thu, 26 Nov 2026 17:27:54 +0000",
        );
        let out = String::from_utf8(prepare_message(
            &headers,
            &received,
            "Thu, 26 Nov 2026 17:27:54 +0000",
            "mx.alpha.test",
        ))
        .unwrap();
        assert!(out.starts_with(
            "Received: from poste.alpha.test\r\n\tby mx.alpha.test with ESMTPSA id 1f.1;\r\n\tThu, 26 Nov 2026 17:27:54 +0000\r\nDate: Thu, 26 Nov 2026 17:27:54 +0000\r\nMessage-ID: <"
        ));
        assert!(out.contains("@mx.alpha.test>\r\nFrom: jean@alpha.test\r\nTo: paul@ailleurs.test\r\nSubject: Devis\r\n\r\nCorps\r\n.\r\n"));
        assert!(!out.contains("cache@") && !out.contains("autre@") && !out.contains("x@y.test"));

        // Date et Message-ID présents : gardés tels quels, rien d'ajouté
        let raw = "Date: Mon, 2 Nov 2026 08:00:00 +0100\r\nMessage-ID: <a@b>\r\nFrom: jean@alpha.test\r\n\r\nCorps";
        let headers = MessageHeaders::parse(raw.as_bytes()).unwrap();
        let out = String::from_utf8(prepare_message(&headers, "", "x", "mx.alpha.test")).unwrap();
        assert_eq!(out, raw);
        assert!(submission_received("h", "mx", true, "1", "d").contains("with UTF8SMTPSA id 1;"));
    }
}

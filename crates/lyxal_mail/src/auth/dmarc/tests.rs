// SPDX-FileCopyrightText: 2021 Mechiel Lukkien <mechiel@ueber.net>
// SPDX-License-Identifier: MIT
//
// Cas d'essai transposés de Mox `dmarc/dmarc_test.go` et `dmarc/parse_test.go` (commit b32f0de,
// MIT, avis dans `LICENSES/MIT-Mox.txt`). Modifications pour Lyxal OS : réécrits en Rust sur
// `StaticResolver` et une petite liste de suffixes écrite pour les essais ; matrice
// d'alignement, `pct`, plusieurs domaines d'auteur et décision de réception (S6) ajoutés.

use super::*;
use crate::auth::psl::tests::test_list;
use crate::auth::spf::SpfIdentity;
use crate::dns::{StaticRecordType, StaticResolver};
use lyxal_mail_proto::mime::MailAddress;

fn resolver() -> StaticResolver {
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("_dmarc.reject.example", &["v=DMARC1; p=reject"])
        .set_txt(
            "_dmarc.strict.example",
            &["v=DMARC1; p=reject; adkim=s; aspf=s"],
        )
        .set_txt("_dmarc.test.example", &["v=DMARC1; p=reject; pct=0"])
        .set_txt("_dmarc.half.example", &["v=DMARC1; p=reject; pct=50"])
        .set_txt("_dmarc.quarantine.example", &["v=DMARC1; p=quarantine"])
        .set_txt("_dmarc.subnone.example", &["v=DMARC1; p=reject; sp=none"])
        .set_txt("_dmarc.none.example", &["v=DMARC1; p=none"])
        .set_txt("_dmarc.malformed.example", &["v=DMARC1; p=none; bogus"])
        .set_txt(
            "_dmarc.multiple.example",
            &["v=DMARC1; p=none", "v=DMARC1; p=reject"],
        )
        .set_txt("_dmarc.one.example", &["v=DMARC1; p=reject", "autre chose"])
        .set_txt("_dmarc.example.com", &["v=DMARC1; p=reject"])
        .set_txt(
            "_dmarc.rua.example",
            &["v=DMARC1; p=bizarre; rua=mailto:dmarc@rua.example"],
        )
        .set_txt("_dmarc.temperror.example", &["v=DMARC1; p=reject"])
        .fail(StaticRecordType::Txt, "_dmarc.temperror.example");
    resolver
}

fn spf(result: SpfResult, domain: Option<&str>) -> SpfOutput {
    SpfOutput {
        result,
        identity: SpfIdentity::MailFrom,
        domain: domain.map(str::to_string),
    }
}

fn dkim(result: DkimResult, domain: &str) -> DkimOutput {
    DkimOutput {
        result,
        domain: Some(domain.to_string()),
        selector: Some("s".to_string()),
        signature_prefix: None,
        testing: false,
    }
}

async fn verify(from: &str, spf_output: SpfOutput, dkim_outputs: &[DkimOutput]) -> DmarcOutput {
    let resolver = resolver();
    let list = test_list();
    let mut outputs = DmarcVerifier::new(&resolver, &list)
        .verify(&[from.to_string()], &spf_output, dkim_outputs)
        .await;
    assert_eq!(outputs.len(), 1);
    outputs.remove(0)
}

#[test]
fn lecture_des_enregistrements() {
    let record = DmarcRecord::parse("v=DMARC1; p=reject; sp=quarantine; adkim=s; pct=20; rua=mailto:a@b.example, mailto:c@d.example; fo=1; inconnu=x").unwrap();
    assert_eq!(record.policy, DmarcPolicy::Reject);
    assert_eq!(record.subdomain_policy, Some(DmarcPolicy::Quarantine));
    assert_eq!(record.dkim_alignment, Alignment::Strict);
    assert_eq!(record.spf_alignment, Alignment::Relaxed);
    assert_eq!(record.percentage, 20);
    assert_eq!(record.aggregate_reports.len(), 2);
    for invalid in [
        "v=DMARC1; p=none; bogus",
        "v=DMARC1; p=bizarre",
        "v=DMARC1",
        "p=none; v=DMARC1",
        "v=DMARC1; p=none; pct=101",
        "v=DMARC1; p=none; adkim=x",
        "v=DMARC1; p=none; sp=bizarre",
    ] {
        assert!(DmarcRecord::parse(invalid).is_err(), "{invalid}");
    }
    // `p=` invalide mais `rua=` lisible : `p=none` (RFC 7489 §6.6.3).
    let record = DmarcRecord::parse("v=DMARC1; p=bizarre; rua=mailto:x@y.example").unwrap();
    assert_eq!(record.policy, DmarcPolicy::None);
    assert!(is_dmarc_record("v=DMARC1; p=none"));
    assert!(is_dmarc_record("v=DMARC1"));
    assert!(!is_dmarc_record("v=DMARC10"));
    assert!(!is_dmarc_record("v=dmarc1; p=none"));
}

#[tokio::test]
async fn cas_de_mox() {
    // Politique `reject`, aucun résultat SPF ni DKIM.
    let output = verify("reject.example", spf(SpfResult::None, None), &[]).await;
    assert_eq!(output.result, DmarcResult::Fail);
    assert_eq!(output.policy, Some(DmarcPolicy::Reject));
    assert_eq!(output.disposition(true, 0), DmarcDisposition::Reject);
    // SPF réussi et aligné (souple).
    let output = verify(
        "reject.example",
        spf(SpfResult::Pass, Some("sub.reject.example")),
        &[],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Pass);
    assert!(output.spf_aligned);
    // DKIM réussi et aligné malgré un SPF en échec.
    let output = verify(
        "reject.example",
        spf(SpfResult::Fail, Some("reject.example")),
        &[dkim(DkimResult::Pass, "sub.reject.example")],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Pass);
    assert!(output.dkim_aligned && !output.spf_aligned);
    // Alignement strict : sous-domaines refusés.
    let output = verify(
        "strict.example",
        spf(SpfResult::Pass, Some("sub.strict.example")),
        &[dkim(DkimResult::Pass, "sub.strict.example")],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Fail);
    // Aucun enregistrement : rien à dire, même avec SPF réussi.
    let output = verify(
        "absent.example",
        spf(SpfResult::Pass, Some("absent.example")),
        &[],
    )
    .await;
    assert_eq!(output.result, DmarcResult::None);
    assert_eq!(output.policy, None);
    assert_eq!(output.disposition(true, 0), DmarcDisposition::Accept);
    // `p=none`.
    let output = verify(
        "none.example",
        spf(SpfResult::Pass, Some("none.example")),
        &[],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Pass);
    // `pct=0` : jamais de refus, mise à l'écart à la place.
    let output = verify("test.example", spf(SpfResult::None, None), &[]).await;
    assert_eq!(output.result, DmarcResult::Fail);
    assert_eq!(output.disposition(true, 0), DmarcDisposition::Quarantine);
    // Sous-domaine couvert par `sp=none`.
    let output = verify(
        "sub.subnone.example",
        spf(SpfResult::Fail, Some("sub.subnone.example")),
        &[],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Fail);
    assert_eq!(output.record_domain.as_deref(), Some("subnone.example"));
    assert_eq!(output.policy, Some(DmarcPolicy::None));
    assert_eq!(output.disposition(true, 0), DmarcDisposition::Accept);
    // Panne SPF ou DKIM sans autre réussite : `temperror` ; avec une réussite : `pass`.
    let output = verify(
        "reject.example",
        spf(SpfResult::TempError, Some("mail.reject.example")),
        &[],
    )
    .await;
    assert_eq!(output.result, DmarcResult::TempError);
    assert_eq!(output.disposition(true, 0), DmarcDisposition::TempFail);
    let output = verify(
        "reject.example",
        spf(SpfResult::None, None),
        &[dkim(DkimResult::TempError, "sub.reject.example")],
    )
    .await;
    assert_eq!(output.result, DmarcResult::TempError);
    let output = verify(
        "reject.example",
        spf(SpfResult::TempError, Some("mail.reject.example")),
        &[dkim(DkimResult::Pass, "sub.reject.example")],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Pass);
    // Enregistrement illisible : `permerror`, aucune politique.
    let output = verify("malformed.example", spf(SpfResult::None, None), &[]).await;
    assert_eq!(output.result, DmarcResult::PermError);
    assert_eq!(output.disposition(true, 0), DmarcDisposition::Accept);
    // Signature d'un suffixe public : jamais alignée.
    let output = verify(
        "example.com",
        spf(SpfResult::None, None),
        &[dkim(DkimResult::Pass, "com")],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Fail);
    // Politique publiée au domaine d'organisation.
    let output = verify("sub.example.com", spf(SpfResult::None, None), &[]).await;
    assert_eq!(output.record_domain.as_deref(), Some("example.com"));
    assert_eq!(output.policy, Some(DmarcPolicy::Reject));
}

#[tokio::test]
async fn recherche_des_enregistrements() {
    for (domain, expected) in [
        ("multiple.example", DmarcResult::None),
        ("one.example", DmarcResult::Fail),
        ("temperror.example", DmarcResult::TempError),
        ("rua.example", DmarcResult::Fail),
    ] {
        let output = verify(domain, spf(SpfResult::None, None), &[]).await;
        assert_eq!(output.result, expected, "{domain}");
    }
    // Panne de l'enregistrement : politique inconnue, remise normale.
    let output = verify("temperror.example", spf(SpfResult::None, None), &[]).await;
    assert_eq!(output.disposition(true, 0), DmarcDisposition::Accept);
}

#[tokio::test]
async fn matrice_d_alignement() {
    // (enregistrement, SPF, DKIM, résultat)
    let cases = [
        (
            "reject.example",
            Some("reject.example"),
            None,
            DmarcResult::Pass,
        ),
        (
            "reject.example",
            Some("a.reject.example"),
            None,
            DmarcResult::Pass,
        ),
        (
            "reject.example",
            Some("other.example"),
            None,
            DmarcResult::Fail,
        ),
        (
            "reject.example",
            None,
            Some("a.b.reject.example"),
            DmarcResult::Pass,
        ),
        (
            "reject.example",
            None,
            Some("reject.example.com"),
            DmarcResult::Fail,
        ),
        (
            "strict.example",
            Some("strict.example"),
            None,
            DmarcResult::Pass,
        ),
        (
            "strict.example",
            Some("a.strict.example"),
            None,
            DmarcResult::Fail,
        ),
        (
            "strict.example",
            None,
            Some("strict.example"),
            DmarcResult::Pass,
        ),
        (
            "strict.example",
            None,
            Some("a.strict.example"),
            DmarcResult::Fail,
        ),
    ];
    for (from, spf_domain, dkim_domain, expected) in cases {
        let spf_output = match spf_domain {
            Some(domain) => spf(SpfResult::Pass, Some(domain)),
            None => spf(SpfResult::None, None),
        };
        let dkim_outputs: Vec<DkimOutput> = dkim_domain
            .map(|domain| dkim(DkimResult::Pass, domain))
            .into_iter()
            .collect();
        let output = verify(from, spf_output, &dkim_outputs).await;
        assert_eq!(
            output.result, expected,
            "{from} {spf_domain:?} {dkim_domain:?}"
        );
    }
    // Signature en mode d'essai ou en échec : ignorée.
    let mut testing = dkim(DkimResult::Pass, "reject.example");
    testing.testing = true;
    let output = verify("reject.example", spf(SpfResult::None, None), &[testing]).await;
    assert_eq!(output.result, DmarcResult::Fail);
    let output = verify(
        "reject.example",
        spf(SpfResult::None, None),
        &[dkim(DkimResult::Fail, "reject.example")],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Fail);
    // SPF `softfail` aligné : pas une réussite.
    let output = verify(
        "reject.example",
        spf(SpfResult::SoftFail, Some("reject.example")),
        &[],
    )
    .await;
    assert_eq!(output.result, DmarcResult::Fail);
}

#[tokio::test]
async fn decisions_de_reception() {
    let fail_reject = verify(
        "reject.example",
        spf(SpfResult::Fail, Some("reject.example")),
        &[],
    )
    .await;
    let fail_quarantine = verify(
        "quarantine.example",
        spf(SpfResult::Fail, Some("q.example")),
        &[],
    )
    .await;
    let half = verify("half.example", spf(SpfResult::None, None), &[]).await;
    // Mise en service progressive : aucun effet.
    assert_eq!(fail_reject.disposition(false, 0), DmarcDisposition::Accept);
    assert_eq!(
        fail_quarantine.disposition(true, 0),
        DmarcDisposition::Quarantine
    );
    // `pct=50` : dans l'échantillon, refus ; hors de l'échantillon, mise à l'écart.
    assert_eq!(half.disposition(true, 49), DmarcDisposition::Reject);
    assert_eq!(half.disposition(true, 50), DmarcDisposition::Quarantine);
    // Plusieurs domaines d'auteur : le plus sévère l'emporte.
    let pass = verify(
        "none.example",
        spf(SpfResult::Pass, Some("none.example")),
        &[],
    )
    .await;
    assert_eq!(
        DmarcOutput::combined_disposition(&[pass.clone(), fail_quarantine.clone()], true, 0),
        DmarcDisposition::Quarantine
    );
    assert_eq!(
        DmarcOutput::combined_disposition(&[fail_quarantine, fail_reject, pass], true, 0),
        DmarcDisposition::Reject
    );
    assert_eq!(
        DmarcOutput::combined_disposition(&[], true, 0),
        DmarcDisposition::Accept
    );
    assert!(sample_roll() < 100);
}

#[tokio::test]
async fn domaines_d_auteur() {
    let mailbox = |address: &str| {
        AddressEntry::Mailbox(MailAddress {
            name: None,
            address: Some(address.to_string()),
        })
    };
    let envelope = Envelope {
        from: vec![
            mailbox("a@Reject.Example"),
            mailbox("b@reject.example"),
            AddressEntry::Group {
                name: "groupe".into(),
                members: vec![MailAddress {
                    name: None,
                    address: Some("c@bücher.example".into()),
                }],
            },
            mailbox("illisible"),
            mailbox("d@none.example"),
        ],
        ..Envelope::default()
    };
    let domains = author_domains(&envelope);
    assert_eq!(
        domains,
        vec!["reject.example", "xn--bcher-kva.example", "none.example"]
    );

    let resolver = resolver();
    let list = test_list();
    let outputs = DmarcVerifier::new(&resolver, &list)
        .verify(&domains, &spf(SpfResult::Pass, Some("none.example")), &[])
        .await;
    assert_eq!(outputs.len(), 3);
    assert_eq!(outputs[0].result, DmarcResult::Fail);
    assert_eq!(outputs[1].result, DmarcResult::None);
    assert_eq!(outputs[2].result, DmarcResult::Pass);
    assert_eq!(
        DmarcOutput::combined_disposition(&outputs, true, 0),
        DmarcDisposition::Reject
    );

    // Au plus `MAX_AUTHOR_DOMAINS` domaines évalués.
    let many: Vec<String> = (0..20).map(|index| format!("d{index}.example")).collect();
    let outputs = DmarcVerifier::new(&resolver, &list)
        .verify(&many, &spf(SpfResult::None, None), &[])
        .await;
    assert_eq!(outputs.len(), MAX_AUTHOR_DOMAINS);
}

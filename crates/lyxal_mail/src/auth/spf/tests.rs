// SPDX-FileCopyrightText: 2021 Mechiel Lukkien <mechiel@ueber.net>
// SPDX-License-Identifier: MIT
//
// Cas d'essai transposés de Mox `spf/spf_test.go` (commit b32f0de, MIT, avis dans
// `LICENSES/MIT-Mox.txt`) ; exemples de la RFC 7208 (§7.4, annexe A). Modifications pour Lyxal
// OS : réécrits en Rust sur `StaticResolver`, résultats seuls comparés (les erreurs de Mox
// n'ont pas d'équivalent), noms sans point final, cas propres à Lyxal ajoutés (panne, délai,
// IPv4 transportée en IPv6, identité HELO illisible).

#![allow(clippy::unwrap_used, clippy::expect_used)]

use super::*;
use crate::dns::{StaticRecordType, StaticResolver};

fn ip(text: &str) -> IpAddr {
    text.parse().unwrap()
}

fn state(ip_text: &str) -> State {
    State {
        ip: ip(ip_text),
        local_part: "strong-bad".into(),
        sender_domain: "email.example.com".into(),
        helo: "mx.mox.example".into(),
        dns_terms: 0,
        void_lookups: 0,
        validated_names: None,
    }
}

#[tokio::test]
async fn developpement_des_macros() {
    let mut resolver = StaticResolver::new();
    for address in ["10.0.0.1", "10.0.0.2", "10.0.0.3"] {
        resolver.set_ptr(
            ip(address),
            &["other.example", "sub.mx.mox.example", "mx.mox.example"],
        );
    }
    resolver
        .set_ips("mx.mox.example", &[ip("10.0.0.1")])
        .set_ips("sub.mx.mox.example", &[ip("10.0.0.2")])
        .set_ips("other.example", &[ip("10.0.0.3")]);
    let verifier = SpfVerifier::new(&resolver);
    let domain = "email.example.com";

    let expand = |macro_text: &'static str, address: &'static str| {
        let verifier = &verifier;
        async move {
            let spec = record::parse_macro_string(macro_text, false).ok()?;
            let mut state = state(address);
            verifier.expand(&mut state, domain, &spec).await.ok()
        }
    };
    let cases: &[(&str, &str, Option<&str>)] = &[
        // RFC 7208 §7.4.
        ("%{s}", "10.0.0.9", Some("strong-bad@email.example.com")),
        ("%{o}", "10.0.0.9", Some("email.example.com")),
        ("%{d}", "10.0.0.9", Some("email.example.com")),
        ("%{d4}", "10.0.0.9", Some("email.example.com")),
        ("%{d3}", "10.0.0.9", Some("email.example.com")),
        ("%{d2}", "10.0.0.9", Some("example.com")),
        ("%{d1}", "10.0.0.9", Some("com")),
        ("%{dr}", "10.0.0.9", Some("com.example.email")),
        ("%{d2r}", "10.0.0.9", Some("example.email")),
        ("%{l}", "10.0.0.9", Some("strong-bad")),
        ("%{l-}", "10.0.0.9", Some("strong.bad")),
        ("%{lr}", "10.0.0.9", Some("strong-bad")),
        ("%{lr-}", "10.0.0.9", Some("bad.strong")),
        ("%{l1r-}", "10.0.0.9", Some("strong")),
        ("%{ir}.%{v}._spf.%{d2}", "192.0.2.3", Some("3.2.0.192.in-addr._spf.example.com")),
        ("%{lr-}.lp._spf.%{d2}", "192.0.2.3", Some("bad.strong.lp._spf.example.com")),
        (
            "%{lr-}.lp.%{ir}.%{v}._spf.%{d2}",
            "192.0.2.3",
            Some("bad.strong.lp.3.2.0.192.in-addr._spf.example.com"),
        ),
        (
            "%{ir}.%{v}.%{l1r-}.lp._spf.%{d2}",
            "192.0.2.3",
            Some("3.2.0.192.in-addr.strong.lp._spf.example.com"),
        ),
        (
            "%{d2}.trusted-domains.example.net",
            "192.0.2.3",
            Some("example.com.trusted-domains.example.net"),
        ),
        (
            "%{ir}.%{v}._spf.%{d2}",
            "2001:db8::cb01",
            Some("1.0.b.c.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6._spf.example.com"),
        ),
        // Mox.
        ("%%%-%_", "10.0.0.1", Some("%%20 ")),
        ("%{p}", "10.0.0.1", Some("mx.mox.example")),
        ("%{p}", "10.0.0.2", Some("sub.mx.mox.example")),
        ("%{p}", "10.0.0.3", Some("other.example")),
        ("%{p}", "10.0.0.4", Some("unknown")),
        ("%{h}", "10.0.0.1", Some("mx.mox.example")),
        ("%{S}", "10.0.0.1", Some("strong-bad%40email.example.com")),
    ];
    for (macro_text, address, expected) in cases {
        assert_eq!(
            expand(macro_text, address).await.as_deref(),
            *expected,
            "{macro_text}"
        );
    }
    // Chaînes refusées dès la lecture.
    for invalid in [
        "%",
        "%b",
        "%{",
        "%{s",
        "%{s1",
        "%{s0}",
        "%{s1r",
        "%{s99999999999999999999}",
    ] {
        assert!(
            record::parse_macro_string(invalid, false).is_err(),
            "{invalid}"
        );
    }
    // Nom de plus de 253 octets : étiquettes de gauche retirées.
    let label = "a".repeat(62);
    let name = format!("{label}.{label}.{label}.{label}");
    let mut st = state("10.0.0.1");
    let spec = record::parse_macro_string(&format!("x.{name}"), false).unwrap();
    assert_eq!(
        verifier
            .expand_domain(&mut st, domain, &spec)
            .await
            .unwrap(),
        format!("x.{name}")
    );
    let spec = record::parse_macro_string(&format!("xx.{name}"), false).unwrap();
    assert_eq!(
        verifier
            .expand_domain(&mut st, domain, &spec)
            .await
            .unwrap(),
        name
    );
    let spec = record::parse_macro_string("%{p}..", false).unwrap();
    assert_eq!(
        verifier.expand_domain(&mut st, domain, &spec).await,
        Err(SpfResult::PermError)
    );
}

/// Résolveur de l'annexe A de la RFC 7208 (exemples étendus), complété par Mox.
fn appendix_a() -> StaticResolver {
    let mut resolver = StaticResolver::new();
    for (address, name) in [
        ("192.0.2.10", "example.com"),
        ("192.0.2.11", "example.com"),
        ("192.0.2.65", "amy.example.com"),
        ("192.0.2.66", "bob.example.com"),
        ("192.0.2.129", "mail-a.example.com"),
        ("192.0.2.130", "mail-b.example.com"),
        ("192.0.2.140", "mail-c.example.org"),
        ("10.0.0.4", "bob.example.com"),
    ] {
        resolver.set_ptr(ip(address), &[name]);
    }
    resolver
        .set_txt(
            "mobile-users._spf.example.com",
            &["v=spf1 exists:%{l1r+}.%{d}"],
        )
        .set_txt(
            "remote-users._spf.example.com",
            &["v=spf1 exists:%{ir}.%{l1r+}.%{d}"],
        )
        .set_txt("ip4._spf.example.com", &["v=spf1 -ip4:192.0.2.0/24 +all"])
        .set_txt("ptr._spf.example.com", &["v=spf1 -ptr:example.com +all"])
        .set_txt(
            "_spf.example.com",
            &["v=spf1 include:_netblock.example.com -all"],
        )
        .set_txt("_netblock.example.com", &["v=spf1 ip4:192.0.2.128/28 -all"])
        .set_ips("example.com", &[ip("192.0.2.10"), ip("192.0.2.11")])
        .set_ips("amy.example.com", &[ip("192.0.2.65")])
        .set_ips("bob.example.com", &[ip("192.0.2.66")])
        .set_ips("mail-a.example.com", &[ip("192.0.2.129")])
        .set_ips("mail-b.example.com", &[ip("192.0.2.130")])
        .set_ips("mail-c.example.org", &[ip("192.0.2.140")])
        .set_ips("mary.mobile-users._spf.example.com", &[ip("127.0.0.2")])
        .set_ips("fred.mobile-users._spf.example.com", &[ip("127.0.0.2")])
        .set_ips(
            "15.15.168.192.joel.remote-users._spf.example.com",
            &[ip("127.0.0.2")],
        )
        .set_ips(
            "16.15.168.192.joel.remote-users._spf.example.com",
            &[ip("127.0.0.2")],
        )
        .set_mx(
            "example.com",
            &[(10, "mail-a.example.com"), (20, "mail-b.example.com")],
        )
        .set_mx("example.org", &[(10, "mail-c.example.org")]);
    resolver
}

const APPENDIX_IPS: [&str; 8] = [
    "192.0.2.10",
    "192.0.2.11",
    "192.0.2.65",
    "192.0.2.66",
    "192.0.2.129",
    "192.0.2.130",
    "192.0.2.140",
    "10.0.0.4",
];

async fn result(resolver: &StaticResolver, address: &str, sender: &str) -> SpfResult {
    SpfVerifier::new(resolver)
        .check_mail_from(ip(address), "mx.client.example", sender)
        .await
        .result
}

#[tokio::test]
async fn exemples_de_l_annexe_a() {
    let cases: &[(&str, &[&str], bool)] = &[
        ("v=spf1 +all", &["192.0.2.129", "1.2.3.4"], false),
        ("v=spf1 a -all", &["192.0.2.10", "192.0.2.11"], true),
        ("v=spf1 a:example.org -all", &[], true),
        ("v=spf1 mx -all", &["192.0.2.129", "192.0.2.130"], true),
        ("v=spf1 mx:example.org -all", &["192.0.2.140"], true),
        (
            "v=spf1 mx mx:example.org -all",
            &["192.0.2.129", "192.0.2.130", "192.0.2.140"],
            true,
        ),
        (
            "v=spf1 mx/30 mx:example.org/30 -all",
            &["192.0.2.129", "192.0.2.130", "192.0.2.140"],
            true,
        ),
        (
            "v=spf1 ptr -all",
            &[
                "192.0.2.10",
                "192.0.2.11",
                "192.0.2.65",
                "192.0.2.66",
                "192.0.2.129",
                "192.0.2.130",
            ],
            true,
        ),
        (
            "v=spf1 ip4:192.0.2.128/28 -all",
            &["192.0.2.129", "192.0.2.130", "192.0.2.140"],
            true,
        ),
        (
            "v=spf1 redirect=_spf.example.com",
            &["192.0.2.129", "192.0.2.130", "192.0.2.140"],
            true,
        ),
    ];
    for (txt, passing, only) in cases {
        let mut resolver = appendix_a();
        resolver.set_txt("example.com", &[txt]);
        for address in *passing {
            assert_eq!(
                result(&resolver, address, "x@example.com").await,
                SpfResult::Pass,
                "{txt} {address}"
            );
        }
        if *only {
            for address in APPENDIX_IPS
                .iter()
                .filter(|address| !passing.contains(address))
            {
                assert_eq!(
                    result(&resolver, address, "x@example.com").await,
                    SpfResult::Fail,
                    "{txt} {address}"
                );
            }
        }
    }

    // Listes DNS (RFC 7208 annexe A.3, A.4).
    let mut resolver = appendix_a();
    resolver.set_txt(
        "example.com",
        &["v=spf1 mx include:mobile-users._spf.%{d} include:remote-users._spf.%{d} -all"],
    );
    for (address, local, expected) in [
        ("1.2.3.4", "mary", SpfResult::Pass),
        ("1.2.3.4", "fred", SpfResult::Pass),
        ("1.2.3.4", "fred+wildcard", SpfResult::Pass),
        ("1.2.3.4", "joel", SpfResult::Fail),
        ("1.2.3.4", "other", SpfResult::Fail),
        ("192.168.15.15", "joel", SpfResult::Pass),
        ("192.168.15.16", "joel", SpfResult::Pass),
        ("192.168.15.17", "joel", SpfResult::Fail),
        ("192.168.15.17", "other", SpfResult::Fail),
    ] {
        assert_eq!(
            result(&resolver, address, &format!("{local}@example.com")).await,
            expected,
            "{address} {local}"
        );
    }

    // Annexe A.5 : plusieurs exigences.
    let mut resolver = appendix_a();
    resolver
        .set_txt(
            "example.com",
            &["v=spf1 -include:ip4._spf.%{d} -include:ptr._spf.%{d} +all"],
        )
        .set_ptr(ip("192.0.2.1"), &["a.example.com"])
        .set_ptr(ip("192.0.0.1"), &["b.example.com"])
        .set_ips("a.example.com", &[ip("192.0.2.1")])
        .set_ips("b.example.com", &[ip("192.0.0.1")]);
    for (address, expected) in [
        ("192.0.2.1", SpfResult::Pass),
        ("192.0.2.2", SpfResult::Fail),
        ("192.0.0.1", SpfResult::Fail),
        ("192.0.0.2", SpfResult::Fail),
    ] {
        assert_eq!(
            result(&resolver, address, "x@example.com").await,
            expected,
            "{address}"
        );
    }
}

#[tokio::test]
async fn plusieurs_domaines() {
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt(
            "example.org",
            &["v=spf1 include:example.com include:example.net -all"],
        )
        .set_txt("la.example.org", &["v=spf1 redirect=example.org"])
        .set_txt("example.com", &["v=spf1 ip4:10.0.0.1 -all"])
        .set_txt("example.net", &["v=spf1 ip4:10.0.0.2 -all"]);
    for (domain, address, expected) in [
        ("example.com", "10.0.0.1", SpfResult::Pass),
        ("example.net", "10.0.0.2", SpfResult::Pass),
        ("example.com", "10.0.0.2", SpfResult::Fail),
        ("example.net", "10.0.0.1", SpfResult::Fail),
        ("example.org", "10.0.0.1", SpfResult::Pass),
        ("example.org", "10.0.0.2", SpfResult::Pass),
        ("example.org", "10.0.0.3", SpfResult::Fail),
        ("la.example.org", "10.0.0.1", SpfResult::Pass),
        ("la.example.org", "10.0.0.2", SpfResult::Pass),
        ("la.example.org", "10.0.0.3", SpfResult::Fail),
    ] {
        assert_eq!(
            result(&resolver, address, &format!("x@{domain}")).await,
            expected,
            "{domain} {address}"
        );
    }
}

fn scenarios() -> StaticResolver {
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("mox.example", &["v=spf1 ip6:2001:db8::0/64 -all"])
        .set_txt(
            "void.example",
            &["v=spf1 exists:absent1.example exists:absent2.example ip4:1.2.3.4 exists:absent3.example -all"],
        )
        .set_txt("loop.example", &["v=spf1 include:loop.example -all"])
        .set_txt("a-unknown.example", &["v=spf1 a:absent.example"])
        .set_txt("include-bad-expand.example", &["v=spf1 include:%{c}"])
        .set_txt("exists-bad-expand.example", &["v=spf1 exists:%{c}"])
        .set_txt("redir-bad-expand.example", &["v=spf1 redirect=%{c}"])
        .set_txt("a-bad-expand.example", &["v=spf1 a:%{c}"])
        .set_txt("include-temperror.example", &["v=spf1 include:temperror.example"])
        .set_txt("include-none.example", &["v=spf1 include:absent.example"])
        .set_txt("include-permerror.example", &["v=spf1 include:permerror.example"])
        .set_txt("permerror.example", &["v=spf1 a:%%"])
        .set_txt("no-mx.example", &["v=spf1 mx -all"])
        .set_txt("many-mx.example", &["v=spf1 mx -all"])
        .set_txt("many-ptr.example", &["v=spf1 ptr:many-mx.example ~all"])
        .set_txt("expl.example", &["v=spf1 ip4:10.0.1.1 -ip4:10.0.1.2 ?all exp=details.expl.example"])
        .set_txt("multiple.example", &["v=spf1 -all", "v=spf1 +all"])
        .set_txt("nonspf.example", &["something else"])
        .set_txt("malformed.example", &["v=spf1 !"])
        .set_txt("redirect-all.example", &["v=spf1 -all redirect=pass.example"])
        .set_txt("pass.example", &["v=spf1 +all"])
        .set_txt("redirect-none.example", &["v=spf1 redirect=absent.example"])
        .set_txt("temperror.example", &["irrelevant"])
        .fail(StaticRecordType::Txt, "temperror.example")
        .set_ips("mail.mox.example", &[ip("10.0.0.1"), ip("2001:db8::1")])
        .set_mx("no-mx.example", &[(10, ".")])
        .set_ptr(ip("2001:db8::1"), &["mail.mox.example"]);
    let mut exchanges = Vec::new();
    for index in 1..=11u16 {
        let name = format!("mx{index}.many-mx.example");
        resolver.set_ips(&name, &[ip(&format!("10.0.1.{index}"))]);
        exchanges.push((index, name));
    }
    let exchange_refs: Vec<(u16, &str)> = exchanges
        .iter()
        .map(|(preference, name)| (*preference, name.as_str()))
        .collect();
    resolver.set_mx("many-mx.example", &exchange_refs);
    let names: Vec<&str> = exchanges.iter().map(|(_, name)| name.as_str()).collect();
    resolver.set_ptr(ip("10.0.1.1"), &names);
    resolver
}

#[tokio::test]
async fn scenarios_de_mox_et_limites() {
    let resolver = scenarios();
    for (domain, address, expected) in [
        ("mox.example", "2001:db8::1", SpfResult::Pass),
        ("mox.example", "2001:fa11::1", SpfResult::Fail),
        // Réponses vides : deux tolérées, la troisième donne `permerror`.
        ("void.example", "1.2.3.4", SpfResult::Pass),
        ("void.example", "1.1.1.1", SpfResult::PermError),
        // Plus de 10 termes qui interrogent le DNS.
        ("loop.example", "1.2.3.4", SpfResult::PermError),
        ("a-unknown.example", "1.2.3.4", SpfResult::Neutral),
        (
            "include-bad-expand.example",
            "1.2.3.4",
            SpfResult::PermError,
        ),
        ("exists-bad-expand.example", "1.2.3.4", SpfResult::PermError),
        ("redir-bad-expand.example", "1.2.3.4", SpfResult::PermError),
        ("a-bad-expand.example", "1.2.3.4", SpfResult::PermError),
        ("include-temperror.example", "1.2.3.4", SpfResult::TempError),
        ("include-none.example", "1.2.3.4", SpfResult::PermError),
        ("include-permerror.example", "1.2.3.4", SpfResult::PermError),
        // « MX nul ».
        ("no-mx.example", "1.2.3.4", SpfResult::Fail),
        // Au-delà du 10e échangeur : `permerror`.
        ("many-mx.example", "10.0.1.1", SpfResult::Pass),
        ("many-mx.example", "10.0.1.10", SpfResult::Pass),
        ("many-mx.example", "10.0.1.11", SpfResult::PermError),
        ("many-mx.example", "10.0.1.254", SpfResult::PermError),
        // Au-delà du 10e nom inverse : ignorés.
        ("many-ptr.example", "10.0.1.1", SpfResult::Pass),
        ("many-ptr.example", "10.0.1.2", SpfResult::SoftFail),
        ("expl.example", "10.0.1.1", SpfResult::Pass),
        ("expl.example", "10.0.1.2", SpfResult::Fail),
        ("expl.example", "10.0.1.3", SpfResult::Neutral),
        // Lyxal : enregistrements multiples, absent, illisible, panne ; `redirect` ignoré quand
        // `all` est présent ; `redirect` vers un domaine sans enregistrement.
        ("multiple.example", "1.2.3.4", SpfResult::PermError),
        ("nonspf.example", "1.2.3.4", SpfResult::None),
        ("absent.example", "1.2.3.4", SpfResult::None),
        ("malformed.example", "1.2.3.4", SpfResult::PermError),
        ("temperror.example", "1.2.3.4", SpfResult::TempError),
        ("redirect-all.example", "1.2.3.4", SpfResult::Fail),
        ("redirect-none.example", "1.2.3.4", SpfResult::PermError),
        ("com", "1.2.3.4", SpfResult::None),
    ] {
        assert_eq!(
            result(&resolver, address, &format!("x@{domain}")).await,
            expected,
            "{domain} {address}"
        );
    }
}

#[tokio::test]
async fn identites() {
    let resolver = scenarios();
    let verifier = SpfVerifier::new(&resolver);
    // Identité HELO.
    let output = verifier.check_helo(ip("2001:db8::1"), "mox.example").await;
    assert_eq!(output.result, SpfResult::Pass);
    assert_eq!(output.identity, SpfIdentity::Helo);
    assert_eq!(output.domain.as_deref(), Some("mox.example"));
    assert_eq!(
        verifier
            .check_helo(ip("2001:db8::1"), "mail.mox.example")
            .await
            .result,
        SpfResult::None
    );
    // HELO par adresse : aucune identité.
    let output = verifier.check_helo(ip("2001:db8::1"), "[::1]").await;
    assert_eq!(output.result, SpfResult::None);
    assert_eq!(output.domain, None);
    // Expéditeur vide : `postmaster@<helo>`.
    let output = verifier
        .check_mail_from(ip("2001:db8::1"), "mox.example", "")
        .await;
    assert_eq!(output.result, SpfResult::Pass);
    assert_eq!(output.domain.as_deref(), Some("mox.example"));
    // Expéditeur illisible.
    assert_eq!(
        verifier
            .check_mail_from(ip("1.2.3.4"), "mox.example", "sans-arobase")
            .await
            .result,
        SpfResult::None
    );
    // IPv4 transportée dans une adresse IPv6 : traitée comme IPv4 (RFC 7208 §5).
    let mut resolver = StaticResolver::new();
    resolver.set_txt("v4.example", &["v=spf1 ip4:192.0.2.0/24 -all"]);
    assert_eq!(
        SpfVerifier::new(&resolver)
            .check_mail_from(ip("::ffff:192.0.2.7"), "h.example", "x@v4.example")
            .await
            .result,
        SpfResult::Pass
    );
    // Domaine Unicode converti en A-label avant la requête.
    resolver.set_txt("xn--bcher-kva.example", &["v=spf1 +all"]);
    assert_eq!(
        SpfVerifier::new(&resolver)
            .check_mail_from(ip("192.0.2.7"), "h.example", "x@bücher.example")
            .await
            .result,
        SpfResult::Pass
    );
}

#[tokio::test]
async fn delai_total() {
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("lent.example", &["v=spf1 a a a -all"])
        .set_ips("lent.example", &[ip("10.9.9.9")])
        .set_delay(Duration::from_millis(40));
    let limits = SpfLimits {
        timeout: Duration::from_millis(100),
        ..SpfLimits::default()
    };
    let output = SpfVerifier::with_limits(&resolver, limits)
        .check_mail_from(ip("1.2.3.4"), "h.example", "x@lent.example")
        .await;
    assert_eq!(output.result, SpfResult::TempError);
}

/// Un nom produit par une macro est un nom DNS, pas un nom d'hôte : `+` de la partie locale et
/// `%2B` de la forme échappée sont interrogés tels quels (RFC 7208 §4.8, §7.3).
#[tokio::test]
async fn cible_de_macro_hors_des_noms_d_hote() {
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("plus.example", &["v=spf1 exists:%{l}._spf.%{d} -all"])
        .set_ips("user+tag._spf.plus.example", &[ip("127.0.0.2")])
        .set_txt("escaped.example", &["v=spf1 exists:%{L}._spf.%{d} -all"])
        .set_ips("user%2btag._spf.escaped.example", &[ip("127.0.0.2")]);
    for domain in ["plus.example", "escaped.example"] {
        assert_eq!(
            result(&resolver, "192.0.2.1", &format!("user+tag@{domain}")).await,
            SpfResult::Pass,
            "{domain}"
        );
    }
    // Une étiquette vide ou trop longue reste une erreur.
    resolver.set_txt("vide.example", &["v=spf1 exists:%{l}._spf.%{d} -all"]);
    assert_eq!(
        result(&resolver, "192.0.2.1", "a..b@vide.example").await,
        SpfResult::PermError
    );
}

/// `%{p}` : les noms inverses sont cherchés une seule fois par évaluation, quel que soit le
/// nombre de macros (RFC 7208 §4.6.4).
#[tokio::test]
async fn macro_p_cherchee_une_fois() {
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt(
            "p.example",
            &["v=spf1 exists:%{p1}.%{p1}.%{p1}.%{p1}.x.%{d} exists:%{p}.y.%{d} ptr -all"],
        )
        .set_ptr(ip("192.0.2.1"), &["host.p.example"])
        .set_ips("host.p.example", &[ip("192.0.2.1")]);
    assert_eq!(
        result(&resolver, "192.0.2.1", "a@p.example").await,
        SpfResult::Pass
    );
    // TXT, PTR, A de confirmation, puis une requête par `exists`.
    assert_eq!(resolver.queries(), 5);
}

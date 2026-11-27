// SPDX-License-Identifier: AGPL-3.0-only

//! Sous-lot 6f de bout en bout : avis reçus sur une adresse de retour (destinataire passé à
//! `bounced`, événement, avis remis à l'expéditeur d'un dépôt authentifié), jeton inconnu ou
//! échu, réponse automatique, rétrodiffusion refusée (et permise par le réglage du domaine),
//! transfert d'un alias vers l'extérieur (adresse de retour à jeton, sans SRS ; avis à
//! l'expéditeur d'origine seulement s'il est authentifié ; limite de l'organisation). Réception
//! par la session SMTP du port 25 sur une vraie socket, envoi par le worker vers le faux MX du
//! module `outbound`. Aucun service réel. Antivirus passé une seule fois avant toute inscription
//! d'avis ; transfert d'un alias aussi par la route locale (avis à l'expéditeur local) ; transfert
//! sans doublon après un nouvel essai de l'expéditeur.

use lyxal_mail::dns::MailResolver;
use lyxal_mail::models::{
    AddressCreateParams, DomainUpdateParams, RecipientState, SubmissionOrigin,
};
use lyxal_mail::MailHealthCheck;
use lyxal_mail::MailStore;
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::ModuleContext;
use lyxal_surreal::{ToSql, Value};
use std::collections::HashMap;
use std::sync::Arc;

use crate::outbound::{outbound, resolver, run, FakeMx, MxScript, Outbound, RcptRule, MESSAGE};
use crate::smtp::{serve, Client, FakeScanner, Options};
use crate::support::token;

/// Avis de non-remise d'un serveur distant pour `rcpt`, adressé à `to`.
fn report(to: &str, rcpt: &str, action: &str, status: &str) -> String {
    format!(
        "From: Mail Delivery System <MAILER-DAEMON@mx.distant.test>\r\n\
To: <{to}>\r\n\
Subject: Undelivered Mail Returned to Sender\r\n\
Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
Message-ID: <avis-{status}@mx.distant.test>\r\n\
MIME-Version: 1.0\r\n\
Content-Type: multipart/report; report-type=delivery-status; boundary=\"limite\"\r\n\
\r\n\
--limite\r\n\
Content-Type: text/plain\r\n\
\r\n\
Your message could not be delivered.\r\n\
--limite\r\n\
Content-Type: message/delivery-status\r\n\
\r\n\
Reporting-MTA: dns; mx.distant.test\r\n\
\r\n\
Final-Recipient: rfc822; {rcpt}\r\n\
Action: {action}\r\n\
Status: {status}\r\n\
Diagnostic-Code: smtp; 550 {status} User unknown\r\n\
\r\n\
--limite--\r\n"
    )
}

/// Accusé de lecture (RFC 8098) : rapport qui n'est pas un avis de non-remise.
fn read_receipt(to: &str) -> String {
    format!(
        "From: <lecteur@mx.distant.test>\r\n\
To: <{to}>\r\n\
Subject: Lu : devis\r\n\
Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
Message-ID: <lu@mx.distant.test>\r\n\
MIME-Version: 1.0\r\n\
Content-Type: multipart/report; report-type=disposition-notification; boundary=\"b\"\r\n\
\r\n\
--b\r\n\
Content-Type: text/plain\r\n\
\r\n\
Lu.\r\n\
--b\r\n\
Content-Type: message/disposition-notification\r\n\
\r\n\
Final-Recipient: rfc822; lecteur@mx.distant.test\r\n\
Disposition: manual-action/MDN-sent-manually; displayed\r\n\
\r\n\
--b--\r\n"
    )
}

async fn inbox_count(out: &Outbound, inbox: &str) -> usize {
    let rows: Vec<Value> = out
        .bench
        .values(&format!(
            "SELECT VALUE id FROM mail_message WHERE mailbox = {inbox};"
        ))
        .await;
    rows.len()
}

async fn count(out: &Outbound, query: &str) -> i64 {
    out.bench.value(query).await
}

/// Envoi d'un dépôt authentifié de jean, remis au faux MX : envoi et adresse de retour.
async fn sent_by_jean(out: &Outbound, mx: &FakeMx, rcpt: &str) -> (String, String) {
    let user = out.bench.client.clone();
    user.authenticate(token(
        "auth_session:jean",
        &["mail.mailbox.access", "mail.send"],
    ))
    .await
    .unwrap();
    let raw = MESSAGE.replace("noreply@alpha.test", "jean@alpha.test");
    let submission = out
        .send(
            &MailStore::new(user),
            SubmissionOrigin::Submission,
            "jean@alpha.test",
            &[rcpt],
            &raw,
        )
        .await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let running = run(out.worker(mx, resolver, None));
    let states = out.wait_final(&submission).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Delivered);
    let (from, _, _) = mx.messages().pop().expect("message au faux MX");
    let address = from.trim_matches(['<', '>']).to_string();
    assert!(address.starts_with("rp=") && address.ends_with("@alpha.test"));
    (submission, address)
}

#[tokio::test]
async fn a_report_on_a_return_address_bounces_the_recipient_and_reaches_the_sender() {
    let out = outbound().await;
    let jean = out.bench.person("jean", "alpha", &out.domain).await;
    let mx = FakeMx::start(MxScript::default()).await;
    let (submission, address) = sent_by_jean(&out, &mx, "paul@ailleurs.test").await;
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    assert!(client.cmd("EHLO mx.distant.test").await.starts_with("250"));

    // Jeton inconnu : adresse inconnue, comme toute adresse absente (aucun relais)
    let forged = format!("rp=0000000000000000000000000a{}", &address[29..]);
    assert!(client.cmd("MAIL FROM:<>").await.starts_with("250"));
    assert!(client
        .cmd(&format!("RCPT TO:<{forged}>"))
        .await
        .starts_with("550 5.1.1"));
    assert!(client.cmd("RSET").await.starts_with("250"));
    // Avis reçu : rejet après acceptation, destinataire passé à `bounced`, avis remis à jean
    let reply = client
        .transaction(
            "",
            &[&address],
            &report(&address, "paul@ailleurs.test", "failed", "5.1.1"),
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    let states = out.states(&submission).await;
    assert_eq!(states[0].1, RecipientState::Bounced);
    assert_eq!(states[0].2.as_deref(), Some("5.1.1"));
    assert_eq!(
        count(
            &out,
            "RETURN count(SELECT id FROM event_outbox WHERE event_type = 'mail.submission.bounced');"
        )
        .await,
        1
    );
    assert_eq!(inbox_count(&out, &jean.inbox).await, 1, "avis remis à jean");
    // Nouvel essai de l'expéditeur : rien ne change, aucun doublon
    let reply = client
        .transaction(
            "",
            &[&address],
            &report(&address, "paul@ailleurs.test", "failed", "5.1.1"),
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(inbox_count(&out, &jean.inbox).await, 1);
    assert_eq!(
        count(
            &out,
            "RETURN count(SELECT id FROM event_outbox WHERE event_type = 'mail.submission.bounced');"
        )
        .await,
        1
    );
    // Réponse automatique (RFC 3834) sur l'adresse de retour : remise à jean
    let reply = client
        .transaction(
            "auto@ailleurs.test",
            &[&address],
            "From: <auto@ailleurs.test>\r\nTo: <jean@alpha.test>\r\nSubject: Absent\r\nAuto-Submitted: auto-replied\r\nMessage-ID: <absent@ailleurs.test>\r\n\r\nJe suis absent.\r\n",
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(inbox_count(&out, &jean.inbox).await, 2);
    // Adresse de retour échue : inconnue
    out.bench
        .run(&format!(
            "UPDATE {submission} SET return_expires_at = time::now() - 1s;"
        ))
        .await;
    assert!(client.cmd("MAIL FROM:<>").await.starts_with("250"));
    assert!(client
        .cmd(&format!("RCPT TO:<{address}>"))
        .await
        .starts_with("550 5.1.1"));
    let metrics = server.handler.snapshot();
    assert_eq!(metrics["returns_bounced"], 1);
    assert_eq!(metrics["returns_delivered"], 3);
}

#[tokio::test]
async fn a_return_of_a_module_submission_is_recorded_then_discarded() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript::default()).await;
    let submission = out.module_send(&["paul@ailleurs.test"], MESSAGE).await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let running = run(out.worker(&mx, resolver, None));
    out.wait_final(&submission).await;
    running.stop().await;
    let (from, _, _) = mx.messages().pop().unwrap();
    let address = from.trim_matches(['<', '>']).to_string();
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO mx.distant.test").await;
    let reply = client
        .transaction(
            "",
            &[&address],
            &report(&address, "Paul@Ailleurs.test", "failed", "5.2.1"),
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(out.states(&submission).await[0].1, RecipientState::Bounced);
    assert_eq!(
        count(&out, "RETURN count(SELECT id FROM mail_message);").await,
        0,
        "aucune boîte où remettre l'avis d'un module"
    );
    assert_eq!(server.handler.snapshot()["returns_discarded"], 1);
}

#[tokio::test]
async fn backscatter_is_refused_unless_the_domain_allows_it() {
    let out = outbound().await;
    let jean = out.bench.person("jean", "alpha", &out.domain).await;
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO mx.distant.test").await;
    // Avis forgé vers une vraie adresse (expéditeur vide) : refusé à la fin des données
    let reply = client
        .transaction(
            "",
            &["jean@alpha.test"],
            &report("jean@alpha.test", "x@ailleurs.test", "failed", "5.1.1"),
        )
        .await;
    assert!(reply.starts_with("550 5.7.1"), "{reply}");
    assert_eq!(server.handler.snapshot()["messages_refused.backscatter"], 1);
    // Accusé de lecture à expéditeur vide : accepté
    let reply = client
        .transaction("", &["jean@alpha.test"], &read_receipt("jean@alpha.test"))
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    // Avis d'un expéditeur non vide : ce n'est pas une rétrodiffusion
    let reply = client
        .transaction(
            "rapports@ailleurs.test",
            &["jean@alpha.test"],
            &report("jean@alpha.test", "y@ailleurs.test", "failed", "5.1.2"),
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    // Domaine dont une partie du courrier part par un autre serveur : réglage coupé
    out.bench
        .system
        .domain_update(DomainUpdateParams {
            domain: out.domain.clone(),
            state: None,
            subaddress_separator: None,
            catch_all: None,
            postmaster: None,
            module_senders: None,
            backscatter_protection: Some(false),
            clear: Vec::new(),
        })
        .await
        .unwrap();
    let reply = client
        .transaction(
            "",
            &["jean@alpha.test"],
            &report("jean@alpha.test", "z@ailleurs.test", "failed", "5.1.3"),
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(inbox_count(&out, &jean.inbox).await, 3);
}

/// Alias `equipe@alpha.test` remis à jean et transféré vers `externe@ailleurs.test`.
async fn forwarding_alias(out: &Outbound) -> crate::support::Person {
    let jean = out.bench.person("jean", "alpha", &out.domain).await;
    out.bench
        .system
        .address_create(AddressCreateParams {
            domain: out.domain.clone(),
            local_part: "equipe".to_string(),
            kind: "alias".to_string(),
            account: None,
            targets: Some(vec![jean.account.clone()]),
            senders: None,
            forward_to: Some(vec!["externe@ailleurs.test".to_string()]),
        })
        .await
        .expect("alias");
    jean
}

async fn forward_submissions(out: &Outbound, origin: &str) -> Vec<String> {
    let rows: Vec<Value> = out
        .bench
        .values(&format!(
            "SELECT VALUE id FROM mail_submission WHERE origin = '{origin}' ORDER BY created_at;"
        ))
        .await;
    rows.iter().map(ToSql::to_sql).collect()
}

#[tokio::test]
async fn an_alias_forwards_outside_with_a_return_address_and_no_srs() {
    let out = outbound().await;
    let jean = forwarding_alias(&out).await;
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    let message = "From: <x@ailleurs.test>\r\nTo: <equipe@alpha.test>\r\nSubject: Devis\r\nDate: Tue, 3 Nov 2026 10:00:00 +0100\r\nMessage-ID: <devis@ailleurs.test>\r\n\r\nBonjour.\r\n";
    let reply = client
        .transaction("x@ailleurs.test", &["equipe@alpha.test"], message)
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(
        inbox_count(&out, &jean.inbox).await,
        1,
        "remise aux comptes de l'alias"
    );
    let forwards = forward_submissions(&out, "forward").await;
    assert_eq!(forwards.len(), 1, "transfert inscrit avant la réponse 250");
    let kept: bool = out
        .bench
        .value(&format!(
            "RETURN (SELECT VALUE forward FROM ONLY {}) == {{ envelope_from: 'x@ailleurs.test', spf: 'pass', envelope_dkim: false }};",
            forwards[0]
        ))
        .await;
    assert!(kept, "réception d'origine gardée pour l'avis");

    let mx = FakeMx::start(MxScript::default()).await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let running = run(out.worker(&mx, resolver, None));
    let states = out.wait_final(&forwards[0]).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Delivered);
    let (from, recipients, bytes) = mx.messages().pop().unwrap();
    assert!(
        from.starts_with("<rp=") && from.ends_with("@alpha.test>"),
        "adresse de retour à jeton de l'alias, aucune réécriture SRS : {from}"
    );
    assert_eq!(recipients, vec!["externe@ailleurs.test".to_string()]);
    let text = String::from_utf8_lossy(&bytes);
    assert!(
        text.starts_with("Received: from client.ailleurs.test"),
        "{text}"
    );
    assert!(text.contains("Authentication-Results: mx.alpha.test"));
    assert!(
        !text.contains("Return-Path"),
        "Return-Path posé par la remise finale"
    );
    assert!(!text.contains("DKIM-Signature"), "aucune signature ajoutée");
    assert!(text.ends_with(message), "message de l'auteur intact");
    assert_eq!(server.handler.snapshot()["forwards_queued"], 1);
}

#[tokio::test]
async fn a_failed_forward_notifies_only_an_authenticated_original_sender() {
    let out = outbound().await;
    forwarding_alias(&out).await;
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    // SPF `pass` sur MAIL FROM (x@ailleurs.test, 127.0.0.1 autorisé) ; puis expéditeur forgé
    // d'un domaine sans SPF ni DKIM
    for sender in ["x@ailleurs.test", "y@forge.test"] {
        let message = format!(
            "From: <{sender}>\r\nTo: <equipe@alpha.test>\r\nSubject: Devis\r\nMessage-ID: <{sender}>\r\n\r\nBonjour.\r\n"
        );
        let reply = client
            .transaction(sender, &["equipe@alpha.test"], &message)
            .await;
        assert!(reply.starts_with("250 "), "{sender} : {reply}");
    }
    let forwards = forward_submissions(&out, "forward").await;
    assert_eq!(forwards.len(), 2);

    let mut rules = HashMap::new();
    rules.insert("externe".to_string(), RcptRule::Reject);
    let mx = FakeMx::start(MxScript {
        rules,
        ..MxScript::default()
    })
    .await;
    let resolver: Arc<dyn MailResolver> = Arc::new(resolver(
        "mx.ailleurs.test",
        &["ailleurs.test", "forge.test"],
    ));
    let running = run(out.worker(&mx, resolver, None));
    for forward in &forwards {
        assert_eq!(out.wait_final(forward).await[0].1, RecipientState::Failed);
    }
    // L'avis est mis en file (origine dsn, expéditeur vide) puis envoyé par le worker
    let mut notices = Vec::new();
    for _ in 0..100 {
        notices = forward_submissions(&out, "dsn").await;
        if !notices.is_empty() && out.states(&notices[0]).await[0].1 == RecipientState::Delivered {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    }
    running.stop().await;
    assert_eq!(
        notices.len(),
        1,
        "un avis, pour l'expéditeur authentifié seulement"
    );
    let sent: Vec<_> = mx
        .messages()
        .into_iter()
        .filter(|(from, _, _)| from == "<>")
        .collect();
    assert_eq!(sent.len(), 1);
    assert_eq!(sent[0].1, vec!["x@ailleurs.test".to_string()]);
    let parsed =
        lyxal_mail_proto::mime::parse(&sent[0].2, &lyxal_mail_proto::mime::MimeLimits::default())
            .unwrap();
    let report = lyxal_mail_proto::dsn::parse_dsn(&sent[0].2, &parsed).expect("avis lisible");
    assert_eq!(
        report.recipients[0].final_recipient.address,
        "externe@ailleurs.test"
    );
    assert_eq!(report.recipients[0].status.to_string(), "5.1.1");
    // Aucun avis dû ni produit pour le transfert de l'expéditeur forgé ; jamais deux fois
    assert_eq!(
        count(
            &out,
            "RETURN count(SELECT id FROM mail_queue_recipient WHERE dsn_owed = true);"
        )
        .await,
        0
    );
}

#[tokio::test]
async fn the_forward_limit_keeps_local_delivery_and_degrades_the_probe() {
    let out = outbound().await;
    let jean = forwarding_alias(&out).await;
    let set: bool = out
        .bench
        .value("RETURN fn::mail_settings_set({ tenant: 'auth_organization:alpha', forward_messages_per_day: 0 }).ok;")
        .await;
    assert!(set);
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    let reply = client
        .transaction(
            "x@ailleurs.test",
            &["equipe@alpha.test"],
            "From: <x@ailleurs.test>\r\nSubject: Devis\r\n\r\nBonjour.\r\n",
        )
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(inbox_count(&out, &jean.inbox).await, 1);
    assert!(forward_submissions(&out, "forward").await.is_empty());
    assert_eq!(server.handler.snapshot()["forwards_limited"], 1);
    let probe = MailHealthCheck::new(out.bench.system.clone(), out.bench.storage.clone())
        .with_reception(server.handler.metrics());
    let result = probe
        .check(&ModuleContext::new(lyxal_mail::MODULE_ID))
        .await
        .unwrap();
    assert_eq!(
        result.status,
        HealthStatus::Degraded,
        "{:?}",
        result.message
    );
}

/// Signature d'essai EICAR, reconnue par [`FakeScanner`].
const EICAR: &str = "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*";

async fn bounced_events(out: &Outbound) -> i64 {
    count(
        out,
        "RETURN count(SELECT id FROM event_outbox WHERE event_type = 'mail.submission.bounced');",
    )
    .await
}

#[tokio::test]
async fn a_report_is_scanned_once_before_anything_is_recorded() {
    let out = outbound().await;
    let jean = out.bench.person("jean", "alpha", &out.domain).await;
    let mx = FakeMx::start(MxScript::default()).await;
    let (submission, address) = sent_by_jean(&out, &mx, "paul@ailleurs.test").await;
    let clean = report(&address, "paul@ailleurs.test", "failed", "5.1.1");
    let infected = clean.replace("Your message could not be delivered.", EICAR);

    // Antivirus configuré mais injoignable : refus temporaire, comme la réception du lot 5
    let mut options = Options::new();
    options.scanner = Some(Arc::new(FakeScanner { available: false }));
    let server = serve(&out.bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO mx.distant.test").await;
    let reply = client.transaction("", &[&address], &clean).await;
    assert!(reply.starts_with("451 "), "{reply}");
    assert_eq!(
        out.states(&submission).await[0].1,
        RecipientState::Delivered
    );
    assert_eq!(bounced_events(&out).await, 0, "rien d'inscrit");
    assert_eq!(inbox_count(&out, &jean.inbox).await, 0);

    // Avis infecté : refus définitif, rien d'inscrit ni de remis
    let mut options = Options::new();
    options.scanner = Some(Arc::new(FakeScanner { available: true }));
    let server = serve(&out.bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO mx.distant.test").await;
    let reply = client.transaction("", &[&address], &infected).await;
    assert!(reply.starts_with("554 5.7.1"), "{reply}");
    assert_eq!(
        out.states(&submission).await[0].1,
        RecipientState::Delivered
    );
    assert_eq!(bounced_events(&out).await, 0, "rien d'inscrit");
    assert_eq!(inbox_count(&out, &jean.inbox).await, 0);

    // Avis infecté sur l'adresse de retour d'un module (aucune boîte où le remettre) : refusé aussi
    let module = out.module_send(&["paul@ailleurs.test"], MESSAGE).await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let running = run(out.worker(&mx, resolver, None));
    out.wait_final(&module).await;
    running.stop().await;
    let (from, _, _) = mx.messages().pop().unwrap();
    let module_address = from.trim_matches(['<', '>']).to_string();
    let module_report = report(&module_address, "paul@ailleurs.test", "failed", "5.1.1")
        .replace("Your message could not be delivered.", EICAR);
    let reply = client
        .transaction("", &[&module_address], &module_report)
        .await;
    assert!(reply.starts_with("554 5.7.1"), "{reply}");
    assert_eq!(out.states(&module).await[0].1, RecipientState::Delivered);

    // Avis sain : inscrit et remis
    let reply = client.transaction("", &[&address], &clean).await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(out.states(&submission).await[0].1, RecipientState::Bounced);
    assert_eq!(bounced_events(&out).await, 1);
    assert_eq!(inbox_count(&out, &jean.inbox).await, 1);
    assert_eq!(server.handler.snapshot()["messages_refused.antivirus"], 2);
}

/// Alias `ventes@alpha.test` remis à jean et transféré vers `to`.
async fn second_alias(out: &Outbound, jean: &crate::support::Person, to: &str) {
    out.bench
        .system
        .address_create(AddressCreateParams {
            domain: out.domain.clone(),
            local_part: "ventes".to_string(),
            kind: "alias".to_string(),
            account: None,
            targets: Some(vec![jean.account.clone()]),
            senders: None,
            forward_to: Some(vec![to.to_string()]),
        })
        .await
        .expect("alias");
}

async fn forwards_counted(out: &Outbound) -> i64 {
    count(
        out,
        "RETURN math::sum(SELECT VALUE count FROM mail_send_counter WHERE kind = 'forward_messages');",
    )
    .await
}

#[tokio::test]
async fn a_retried_transaction_does_not_forward_twice() {
    let out = outbound().await;
    let jean = forwarding_alias(&out).await;
    second_alias(&out, &jean, "commercial@ailleurs.test").await;
    // Mise en file du second transfert en panne (erreur de la base, pas un refus métier)
    out.bench
        .run("DEFINE EVENT OVERWRITE essai_panne ON TABLE mail_submission WHEN $event = 'CREATE' AND $after.sender = 'ventes@alpha.test' THEN { THROW 'panne'; };")
        .await;
    let server = serve(&out.bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    let message = "From: <x@ailleurs.test>\r\nTo: <equipe@alpha.test>, <ventes@alpha.test>\r\nSubject: Devis\r\nMessage-ID: <devis@ailleurs.test>\r\n\r\nBonjour.\r\n";
    let recipients = ["equipe@alpha.test", "ventes@alpha.test"];
    let reply = client
        .transaction("x@ailleurs.test", &recipients, message)
        .await;
    assert!(reply.starts_with("451 "), "{reply}");
    assert_eq!(forward_submissions(&out, "forward").await.len(), 1);
    assert_eq!(forwards_counted(&out).await, 1);

    // Nouvel essai de l'expéditeur, panne réparée : le premier transfert n'est pas refait
    out.bench
        .run("REMOVE EVENT essai_panne ON TABLE mail_submission;")
        .await;
    let reply = client
        .transaction("x@ailleurs.test", &recipients, message)
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(
        forward_submissions(&out, "forward").await.len(),
        2,
        "un transfert par alias, jamais deux"
    );
    assert_eq!(
        forwards_counted(&out).await,
        2,
        "limite prise une fois par alias"
    );
    // Encore un essai (réponse perdue par l'expéditeur) : rien de nouveau
    let reply = client
        .transaction("x@ailleurs.test", &recipients, message)
        .await;
    assert!(reply.starts_with("250 "), "{reply}");
    assert_eq!(forward_submissions(&out, "forward").await.len(), 2);
    assert_eq!(forwards_counted(&out).await, 2);
    assert_eq!(
        inbox_count(&out, &jean.inbox).await,
        1,
        "une copie pour jean"
    );
}

#[tokio::test]
async fn a_local_sender_to_a_forwarding_alias_also_reaches_the_outside() {
    let out = outbound().await;
    let jean = forwarding_alias(&out).await;
    second_alias(&out, &jean, "refuse@ailleurs.test").await;
    let user = out.bench.client.clone();
    user.authenticate(token(
        "auth_session:jean",
        &["mail.mailbox.access", "mail.send"],
    ))
    .await
    .unwrap();
    let raw = MESSAGE.replace("noreply@alpha.test", "jean@alpha.test");
    let submission = out
        .send(
            &MailStore::new(user),
            SubmissionOrigin::Submission,
            "jean@alpha.test",
            &["equipe@alpha.test", "ventes@alpha.test"],
            &raw,
        )
        .await;
    let mut rules = HashMap::new();
    rules.insert("refuse".to_string(), RcptRule::Reject);
    let mx = FakeMx::start(MxScript {
        rules,
        ..MxScript::default()
    })
    .await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let running = run(out.worker(&mx, resolver, None));
    let states = out.wait_final(&submission).await;
    assert!(
        states
            .iter()
            .all(|(_, state, _)| *state == RecipientState::Delivered),
        "{states:?}"
    );
    // Route locale : copie pour jean, puis un transfert par alias mis en file
    let mut forwards = Vec::new();
    for _ in 0..100 {
        forwards = forward_submissions(&out, "forward").await;
        if forwards.len() == 2 {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    }
    assert_eq!(forwards.len(), 2, "transferts de la route locale");
    for forward in &forwards {
        out.wait_final(forward).await;
    }
    // Réception d'origine : notre installation (adresse de retour de l'envoi de jean)
    let origin: Value = out
        .bench
        .value(&format!(
            "RETURN (SELECT VALUE forward FROM ONLY {});",
            forwards[0]
        ))
        .await;
    let origin = origin.to_sql();
    assert!(
        origin.contains("envelope_dkim: true")
            && origin.contains("spf: 'none'")
            && origin.contains("envelope_from: 'rp="),
        "{origin}"
    );
    let delivered: Vec<_> = mx
        .messages()
        .into_iter()
        .filter(|(_, recipients, _)| recipients == &vec!["externe@ailleurs.test".to_string()])
        .collect();
    assert_eq!(delivered.len(), 1, "destinataire extérieur servi");
    assert!(String::from_utf8_lossy(&delivered[0].2).contains("with LOCAL id"));
    // Transfert refusé par le serveur distant : avis à jean, remis dans sa boîte par la route
    // locale (adresse de retour de son envoi)
    let mut inbox = 0;
    for _ in 0..100 {
        inbox = inbox_count(&out, &jean.inbox).await;
        if inbox == 2 {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    }
    running.stop().await;
    assert_eq!(
        inbox, 2,
        "message par les alias, puis avis du transfert refusé"
    );
    assert_eq!(forward_submissions(&out, "dsn").await.len(), 1);
}

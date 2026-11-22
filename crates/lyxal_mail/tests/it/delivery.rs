// SPDX-License-Identifier: AGPL-3.0-only

//! Dépôt et lecture de bout en bout par les services Rust : lecture MIME, écriture chiffrée,
//! inscription ; liste, lecture entière et par plage du message déchiffré ; drapeaux,
//! déplacement, effacement, puis maintenance qui retire le contenu et son fichier ; refus à
//! réessayer sans clé ; dépôt refusé sans fichier lisible laissé ; isolement des comptes ;
//! purge d'un compte supprimé.

use bytes::Bytes;
use lyxal_mail::models::{
    AccountRefParams, ExpungeParams, FlagsSetParams, MailboxRefParams, MessageListParams,
    MessageRefParams, TransferParams,
};
use lyxal_mail::{Delivery, DeliveryFlags, MailContent, MailIngest, MailMaintenance, MAIL_BUCKET};
use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::{FileKeys, SecretsStore};
use lyxal_storage::models::{BucketCreateParams, ObjectGetParams};
use lyxal_storage::{ByteRange, StorageService};
use lyxal_surreal::ToSql;

use crate::support::{bench, code, Bench};

/// Message d'essai : texte et pièce jointe PDF.
const MESSAGE: &str = "From: Paul <paul@ailleurs.test>\r\n\
To: Jean <jean@alpha.test>\r\n\
Subject: Devis du chantier\r\n\
Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
Message-ID: <devis-1@ailleurs.test>\r\n\
MIME-Version: 1.0\r\n\
Content-Type: multipart/mixed; boundary=frontiere\r\n\
\r\n\
--frontiere\r\n\
Content-Type: text/plain; charset=utf-8\r\n\
\r\n\
Bonjour Jean, voici le devis.\r\n\
--frontiere\r\n\
Content-Type: application/pdf; name=devis.pdf\r\n\
Content-Disposition: attachment; filename=devis.pdf\r\n\
Content-Transfer-Encoding: base64\r\n\
\r\n\
JVBERi0xLjQKJcOkw7zDtsOfCg==\r\n\
--frontiere--\r\n";

fn delivery(account: &str, mailbox: &str, raw: &[u8]) -> Delivery {
    Delivery {
        account: account.to_string(),
        mailbox: mailbox.to_string(),
        raw: Bytes::copy_from_slice(raw),
        received_at: None,
        flags: DeliveryFlags::default(),
    }
}

/// Nombre de lignes d'une requête de contrôle (session système).
async fn count(bench: &Bench, query: &str) -> i64 {
    bench
        .value::<i64>(&format!("RETURN array::len({query});"))
        .await
}

#[tokio::test]
async fn a_message_is_delivered_listed_read_moved_expunged_and_purged() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;

    let message = bench
        .ingest
        .deliver(
            &jean.store,
            delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
        )
        .await
        .expect("dépôt");
    assert_eq!(message.uid, 1);
    assert_eq!(message.size, MESSAGE.len() as i64);
    assert_eq!(message.message_id.as_deref(), Some("devis-1@ailleurs.test"));
    assert_eq!(message.base_subject.as_deref(), Some("Devis du chantier"));
    assert!(message.has_attachment);
    assert!(!message.seen);
    assert_eq!(message.protection, "platform");

    // Liste du dossier : enveloppe et structure en clair (décision M8)
    let page = jean
        .store
        .message_list(MessageListParams {
            mailbox: jean.inbox.clone(),
            fields: Some("full".to_string()),
            ..MessageListParams::default()
        })
        .await
        .expect("liste");
    assert_eq!(page.items.len(), 1);
    assert!(page.next.is_none());
    let listed = &page.items[0];
    let envelope = listed.envelope.as_ref().expect("enveloppe");
    assert_eq!(envelope.subject.as_deref(), Some("Devis du chantier"));
    assert_eq!(
        envelope.to.as_ref().expect("To")[0].address.as_deref(),
        Some("jean@alpha.test")
    );
    assert!(listed.structure.is_some());

    // Fichier chiffré au repos : octets rangés différents du clair, format LXS1
    let id = message.id.to_sql();
    let location = jean
        .store
        .content_open(MessageRefParams {
            message: id.clone(),
        })
        .await
        .expect("contenu");
    let stored = bench.stored_bytes(&location.object.to_sql()).await;
    assert!(stored.starts_with(b"LXS1"));
    assert!(!stored
        .windows(b"Bonjour Jean".len())
        .any(|window| window == b"Bonjour Jean"));

    // Lecture entière et par plage (le texte de la première partie), déchiffrées
    let whole = bench
        .content
        .read(&jean.store, &id, None)
        .await
        .expect("lecture");
    assert_eq!(whole, MESSAGE.as_bytes());
    let start = MESSAGE.find("Bonjour").expect("texte") as u64;
    let part = bench
        .content
        .read(&jean.store, &id, Some(ByteRange::FromTo(start, start + 28)))
        .await
        .expect("plage");
    assert_eq!(part, b"Bonjour Jean, voici le devis.");

    // Drapeaux : lu, compteur du dossier tenu
    let flags = jean
        .store
        .message_flags_set(FlagsSetParams {
            messages: vec![id.clone()],
            add: Some(vec!["$seen".to_string()]),
            ..FlagsSetParams::default()
        })
        .await
        .expect("drapeaux");
    assert_eq!(flags.updated.len(), 1);
    let inbox = jean
        .store
        .mailbox_get(MailboxRefParams {
            mailbox: jean.inbox.clone(),
        })
        .await
        .expect("dossier");
    assert_eq!((inbox.total, inbox.unseen), (1, 0));

    // Déplacement : nouvelle fiche, même identifiant JMAP, même contenu
    let moved = jean
        .store
        .message_move(TransferParams {
            messages: vec![id.clone()],
            mailbox: jean.archive.clone(),
        })
        .await
        .expect("déplacement");
    assert_eq!(moved.moved.len(), 1);
    let moved_id = moved.moved[0].id.to_sql();
    assert_ne!(moved_id, id);
    let archived = jean
        .store
        .message_get(MessageRefParams {
            message: moved_id.clone(),
        })
        .await
        .expect("message déplacé");
    assert_eq!(archived.email_id, message.email_id);
    assert_eq!(archived.content, message.content);
    let reread = bench
        .content
        .read(&jean.store, &moved_id, None)
        .await
        .expect("lecture après déplacement");
    assert_eq!(reread, MESSAGE.as_bytes());

    // Effacement : le contenu n'a plus de lecteur, il est libéré
    let expunged = jean
        .store
        .message_expunge(ExpungeParams {
            mailbox: jean.archive.clone(),
            messages: Some(vec![moved_id.clone()]),
        })
        .await
        .expect("effacement");
    assert_eq!(expunged.expunged.len(), 1);
    assert_eq!(
        code(bench.content.read(&jean.store, &moved_id, None).await),
        "MAIL_MESSAGE_NOT_FOUND"
    );

    // Maintenance : contenu retiré, fichier supprimé dans la même transaction
    let report = bench
        .maintenance
        .run(&CancellationToken::new())
        .await
        .expect("maintenance");
    assert_eq!(report.released, 1);
    assert_eq!(count(&bench, "SELECT id FROM mail_content").await, 0);
    let file = bench
        .storage_store
        .object_get(ObjectGetParams::by_id(location.object.to_sql()))
        .await
        .expect("fiche du fichier");
    assert_eq!(file.state.as_str(), "deleted");
}

#[tokio::test]
async fn without_file_keys_a_delivery_is_refused_and_retryable_and_nothing_is_written() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let backends = bench.backends.clone();

    // Aucun service de clés, puis un service de clés sans clé maîtresse
    let plain = StorageService::new(bench.storage_store.clone(), backends.clone());
    let keyless = StorageService::new(bench.storage_store.clone(), backends).with_file_keys(
        FileKeys::new(SecretsStore::new(bench.client.clone()), None),
        bench.storage_store.clone(),
    );
    for storage in [plain, keyless] {
        let ingest = MailIngest::new(bench.system.clone(), storage.clone(), "default");
        assert!(!ingest.is_available());
        let refused = ingest
            .deliver(
                &jean.store,
                delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
            )
            .await
            .expect_err("dépôt refusé");
        assert_eq!(refused.code(), "MAIL_CONTENT_UNAVAILABLE");
        assert!(refused.is_retryable());
        assert_eq!(count(&bench, "SELECT id FROM mail_content").await, 0);
        assert_eq!(count(&bench, "SELECT id FROM storage_object").await, 0);
    }

    // Un message déposé ne se lit pas non plus sans clé
    let message = bench
        .ingest
        .deliver(
            &jean.store,
            delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
        )
        .await
        .expect("dépôt");
    let unreadable = MailContent::new(StorageService::new(
        bench.storage_store.clone(),
        bench.backends.clone(),
    ));
    let refused = unreadable
        .read(&jean.store, &message.id.to_sql(), None)
        .await
        .expect_err("lecture refusée");
    assert_eq!(refused.code(), "MAIL_CONTENT_UNAVAILABLE");
    assert!(refused.is_retryable());
}

#[tokio::test]
async fn a_malformed_message_is_refused_before_anything_is_reserved() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    for raw in [&b""[..], &b"\x7fELF\x02\x01\x01\0\0\0\0\0\0\0\0\0"[..]] {
        let refused = bench
            .ingest
            .deliver(&jean.store, delivery(&jean.account, &jean.inbox, raw))
            .await
            .expect_err("message refusé");
        assert_eq!(refused.code(), "MAIL_MESSAGE_MALFORMED");
        assert!(!refused.is_retryable());
    }
    assert_eq!(count(&bench, "SELECT id FROM mail_content").await, 0);
}

#[tokio::test]
async fn a_refused_registration_leaves_no_message_and_maintenance_removes_content_and_file() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let marie = bench.person("marie", "alpha", &domain).await;

    // Le dossier visé n'est pas visible pour jean : l'inscription est refusée après l'écriture
    let refused = bench
        .ingest
        .deliver(
            &jean.store,
            delivery(&jean.account, &marie.inbox, MESSAGE.as_bytes()),
        )
        .await
        .expect_err("inscription refusée");
    assert_eq!(refused.code(), "MAIL_MAILBOX_NOT_FOUND");
    assert_eq!(count(&bench, "SELECT id FROM mail_message").await, 0);
    // Seul reste le contenu lié à son fichier chiffré, sans lecteur
    let contents: Vec<i64> = bench.values("SELECT VALUE refs FROM mail_content;").await;
    assert_eq!(contents, vec![0]);
    let object: String = bench
        .value("RETURN <string> (SELECT VALUE object FROM ONLY mail_content LIMIT 1);")
        .await;
    assert!(bench.stored_bytes(&object).await.starts_with(b"LXS1"));

    // Avant son délai, la maintenance le garde ; après, elle le retire avec son fichier
    let report = bench
        .maintenance
        .run(&CancellationToken::new())
        .await
        .expect("maintenance");
    assert_eq!(report.expired, 0);
    bench
        .run("UPDATE mail_content SET expires_at = time::now() - 1s;")
        .await;
    let report = bench
        .maintenance
        .run(&CancellationToken::new())
        .await
        .expect("maintenance");
    assert_eq!(report.expired, 1);
    assert_eq!(count(&bench, "SELECT id FROM mail_content").await, 0);
    let states: Vec<String> = bench
        .values("SELECT VALUE state FROM storage_object;")
        .await;
    assert_eq!(states, vec!["deleted".to_string()]);
}

#[tokio::test]
async fn accounts_are_isolated_through_the_rust_services() {
    let bench = bench().await;
    let alpha = bench.domain("alpha").await;
    let beta = bench.domain("beta").await;
    let jean = bench.person("jean", "alpha", &alpha).await;
    let marie = bench.person("marie", "alpha", &alpha).await;
    let autre = bench.person("autre", "beta", &beta).await;
    let message = bench
        .ingest
        .deliver(
            &jean.store,
            delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
        )
        .await
        .expect("dépôt");
    let id = message.id.to_sql();

    for (intruder, name) in [(&marie, "autre membre"), (&autre, "autre organisation")] {
        // Lecture du message de jean : introuvable
        assert_eq!(
            code(bench.content.read(&intruder.store, &id, None).await),
            "MAIL_MESSAGE_NOT_FOUND",
            "{name}"
        );
        // Liste du dossier de jean : introuvable
        let listed = intruder
            .store
            .message_list(MessageListParams {
                mailbox: jean.inbox.clone(),
                ..MessageListParams::default()
            })
            .await
            .expect_err(name);
        assert_eq!(
            lyxal_mail::MailError::from(listed).code(),
            "MAIL_MAILBOX_NOT_FOUND",
            "{name}"
        );
        // Dépôt dans le compte de jean : refusé, rien n'est écrit
        assert_eq!(
            code(
                bench
                    .ingest
                    .deliver(
                        &intruder.store,
                        delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes())
                    )
                    .await
            ),
            "MAIL_ACCOUNT_NOT_FOUND",
            "{name}"
        );
    }
    assert_eq!(count(&bench, "SELECT id FROM mail_content").await, 1);
    assert_eq!(count(&bench, "SELECT id FROM storage_object").await, 1);

    // La maintenance est réservée à la session système et au compte de service
    let refused = MailMaintenance::new(jean.store.clone(), 10)
        .run(&CancellationToken::new())
        .await
        .expect_err("maintenance refusée");
    assert_eq!(refused.code(), "MAIL_PERMISSION_DENIED");

    // Chaque organisation a son propre bucket chiffré du courrier
    bench
        .ingest
        .deliver(
            &autre.store,
            delivery(&autre.account, &autre.inbox, MESSAGE.as_bytes()),
        )
        .await
        .expect("dépôt dans beta");
    let buckets: Vec<bool> = bench
        .values("SELECT VALUE encrypted FROM storage_bucket WHERE name = 'lyxal-mail';")
        .await;
    assert_eq!(buckets, vec![true, true]);
}

#[tokio::test]
async fn a_deleted_account_is_purged_with_its_contents_and_files() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    for _ in 0..3 {
        bench
            .ingest
            .deliver(
                &jean.store,
                delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
            )
            .await
            .expect("dépôt");
    }
    bench
        .system
        .account_delete(AccountRefParams {
            account: jean.account.clone(),
        })
        .await
        .expect("compte en suppression");
    let report = bench
        .maintenance
        .run(&CancellationToken::new())
        .await
        .expect("maintenance");
    assert_eq!((report.accounts, report.messages), (1, 3));
    assert_eq!(count(&bench, "SELECT id FROM mail_account").await, 0);
    assert_eq!(count(&bench, "SELECT id FROM mail_content").await, 0);
    let states: Vec<String> = bench
        .values("SELECT VALUE state FROM storage_object;")
        .await;
    assert_eq!(states.len(), 3);
    assert!(states.iter().all(|state| state == "deleted"));
}

/// Fichiers rangés sous un dossier du support disque (récursif).
fn files_under(dir: &std::path::Path) -> Vec<std::path::PathBuf> {
    let mut found = Vec::new();
    for entry in std::fs::read_dir(dir).expect("dossier").flatten() {
        let path = entry.path();
        if path.is_dir() {
            found.extend(files_under(&path));
        } else {
            found.push(path);
        }
    }
    found
}

#[tokio::test]
async fn an_unencrypted_mail_bucket_refuses_the_delivery_before_any_write() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    // Bucket du même nom créé en clair (chiffrement absent par défaut)
    bench
        .storage_store
        .bucket_create(BucketCreateParams::named(
            Some("auth_organization:alpha".to_string()),
            MAIL_BUCKET,
        ))
        .await
        .expect("bucket en clair");

    let refused = bench
        .ingest
        .deliver(
            &jean.store,
            delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
        )
        .await
        .expect_err("dépôt refusé");
    // Rien n'est écrit : ni octet sur le support, ni fiche de fichier, ni message
    assert_eq!(
        files_under(bench.root.path()),
        Vec::<std::path::PathBuf>::new()
    );
    assert_eq!(count(&bench, "SELECT id FROM storage_object").await, 0);
    assert_eq!(count(&bench, "SELECT id FROM mail_message").await, 0);
    assert_eq!(refused.code(), "MAIL_CONTENT_UNAVAILABLE");
}

#[tokio::test]
async fn the_mail_bucket_is_found_beyond_the_first_page_of_buckets() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    // 1 000 buckets triés avant « lyxal-mail » : il n'est pas sur la première page
    bench
        .run(
            "FOR $i IN 0..1000 {
                LET $created = fn::storage_bucket_create({ tenant: 'auth_organization:alpha', name: 'a-' + <string> (10000 + $i) });
                IF !$created.ok { THROW $created.error.code; };
            };",
        )
        .await;
    for _ in 0..2 {
        bench
            .ingest
            .deliver(
                &jean.store,
                delivery(&jean.account, &jean.inbox, MESSAGE.as_bytes()),
            )
            .await
            .expect("dépôt");
    }
    assert_eq!(count(&bench, "SELECT id FROM mail_message").await, 2);
    let buckets: Vec<bool> = bench
        .values("SELECT VALUE encrypted FROM storage_bucket WHERE name = 'lyxal-mail';")
        .await;
    assert_eq!(buckets, vec![true]);
}

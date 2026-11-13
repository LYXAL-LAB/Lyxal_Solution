//! Valeurs écrites puis relues, taille, enveloppes recopiées ou altérées, écritures
//! concurrentes, aucune valeur dans les `Debug`, les erreurs ni le journal.

use lyxal_crypto::SecretBytes;
use lyxal_secrets::models::{SecretGetParams, SettingsSetParams, Stage, VersionState};
use lyxal_secrets::{PutValue, RevealRequest};
use lyxal_surreal::SurrealValue;

use crate::support::{bench, code, put, reveal, ALPHA, BETA};

#[derive(Debug, SurrealValue)]
struct Sealed {
    envelope: String,
    key_id: String,
}

/// Enveloppe et clé d'une version, lues par la session système.
async fn sealed(bench: &crate::support::Bench, secret: &str, number: i64) -> Sealed {
    bench
        .value(&format!(
            "SELECT envelope, key_id FROM ONLY secrets_version WHERE secret = {secret} AND number = {number} LIMIT 1"
        ))
        .await
}

/// Remplace l'enveloppe d'une version comme le ferait une écriture directe en base (session
/// système : rescellement simulé).
async fn overwrite(bench: &crate::support::Bench, secret: &str, number: i64, with: &Sealed) {
    bench
        .client
        .query(format!(
            "UPDATE secrets_version SET envelope = $envelope, key_id = $key_id, resealed_at = time::now() WHERE secret = {secret} AND number = {number}"
        ))
        .bind(("envelope", with.envelope.clone()))
        .bind(("key_id", with.key_id.clone()))
        .await
        .and_then(|r| r.check())
        .expect("enveloppe remplacée");
}

#[tokio::test]
async fn a_value_is_written_sealed_then_read_back_identical() {
    let bench = bench().await;
    let installation = bench.secret(None, "smtp/password").await;
    let alpha = bench.secret(Some(ALPHA), "api/stripe").await;

    assert_eq!(bench.put(&installation, b"mot de passe SMTP").await, 1);
    let json = br#"{"client_id":"abc","client_secret":"tres-secret"}"#;
    let added = bench
        .service
        .put(put(&alpha, json))
        .await
        .expect("écriture");
    assert_eq!(added.version.number, 1);
    assert_eq!(added.labels.get("current"), Some(&1));
    // Noms des clés d'une valeur JSON (R4), jamais les valeurs
    assert_eq!(
        added.version.keys,
        Some(vec!["client_id".to_string(), "client_secret".to_string()])
    );
    let key_id = added.version.key_id.clone().expect("clé");
    assert!(key_id.starts_with("alpha-"), "{key_id}");

    assert_eq!(bench.read(&installation).await, b"mot de passe SMTP");
    assert_eq!(bench.read(&alpha).await, json);

    // En base : enveloppe enc:v2 de la clé de l'organisation, sans la valeur
    let stored = sealed(&bench, &alpha, 1).await;
    assert!(stored.envelope.starts_with(&format!("enc:v2:{key_id}:")));
    assert_eq!(stored.key_id, key_id);
    assert!(!stored.envelope.contains("tres-secret"));
    // Clé d'organisation créée à la première valeur (R2), scellée par la clé maîtresse
    let wrapped: Vec<String> = bench
        .values("SELECT VALUE wrapped FROM secrets_tenant_key ORDER BY key_id")
        .await;
    assert_eq!(wrapped.len(), 2);
    assert!(wrapped.iter().all(|w| w.starts_with("enc:v2:vault-1:")));

    // Seconde version : current avance, previous posée ; relecture par numéro
    assert_eq!(bench.put(&alpha, b"v2").await, 2);
    assert_eq!(bench.read(&alpha).await, b"v2");
    let first = bench
        .service
        .reveal(RevealRequest {
            number: Some(1),
            ..reveal(&alpha)
        })
        .await
        .expect("version 1");
    assert_eq!(first.number, 1);
    assert_eq!(first.value.expose_secret(), json);

    // Valeur en attente : lue par son étiquette seulement
    let pending = bench
        .service
        .put(PutValue {
            stage: Stage::Pending,
            ..put(&alpha, b"v3")
        })
        .await
        .expect("version en attente");
    assert_eq!(pending.labels.get("pending"), Some(&3));
    assert_eq!(bench.read(&alpha).await, b"v2");
    let staged = bench
        .service
        .reveal(RevealRequest {
            label: Some("pending".into()),
            ..reveal(&alpha)
        })
        .await
        .expect("version en attente");
    assert_eq!(staged.value.expose_secret(), b"v3");
}

#[tokio::test]
async fn values_up_to_the_configured_size_are_accepted() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "certificat").await;
    let limit = vec![b'a'; 64 * 1024];
    bench.put(&secret, &limit).await;
    assert_eq!(bench.read(&secret).await, limit);

    let over = vec![b'a'; 64 * 1024 + 1];
    assert_eq!(
        code(bench.service.put(put(&secret, &over)).await),
        "SECRETS_VALUE_TOO_LARGE"
    );
    // Réglage de l'organisation : limite abaissée
    bench
        .store
        .settings_set(SettingsSetParams {
            tenant: Some(ALPHA.to_string()),
            max_value_bytes: Some(16),
            ..SettingsSetParams::default()
        })
        .await
        .expect("réglages");
    let error = bench
        .service
        .put(put(&secret, &[b'x'; 17]))
        .await
        .expect_err("trop grande");
    assert_eq!(error.code(), "SECRETS_VALUE_TOO_LARGE");
    bench.put(&secret, &[b'x'; 16]).await;
    let record = bench
        .store
        .secret_get(SecretGetParams::by_id(secret.clone()))
        .await
        .expect("fiche");
    assert_eq!(record.latest_version, 2, "aucune version pour les refus");
}

#[tokio::test]
async fn an_envelope_copied_elsewhere_does_not_open() {
    let bench = bench().await;
    let first = bench.secret(Some(ALPHA), "api/a").await;
    let second = bench.secret(Some(ALPHA), "api/b").await;
    let other = bench.secret(Some(BETA), "api/a").await;
    bench.put(&first, b"valeur de a").await;
    bench.put(&first, b"valeur de a, version 2").await;
    bench.put(&second, b"valeur de b").await;
    bench.put(&other, b"valeur de beta").await;
    let copied = sealed(&bench, &first, 1).await;

    // Vers un autre secret de la même organisation
    overwrite(&bench, &second, 1, &copied).await;
    assert_eq!(
        code(bench.service.reveal(reveal(&second)).await),
        "SECRETS_VALUE_CORRUPTED"
    );
    // Vers une autre version du même secret
    overwrite(&bench, &first, 2, &copied).await;
    assert_eq!(
        code(bench.service.reveal(reveal(&first)).await),
        "SECRETS_VALUE_CORRUPTED"
    );
    // Vers une autre organisation : refusée dès l'écriture, la clé n'est pas celle de beta
    let refused = bench
        .client
        .query(format!(
            "UPDATE secrets_version SET envelope = $envelope, key_id = $key_id, resealed_at = time::now() WHERE secret = {other} AND number = 1"
        ))
        .bind(("envelope", copied.envelope.clone()))
        .bind(("key_id", copied.key_id.clone()))
        .await
        .and_then(|r| r.check())
        .expect_err("clé d'une autre organisation");
    assert!(
        refused.to_string().contains("SECRETS_TENANT_KEY_CONFLICT"),
        "{refused}"
    );
    assert_eq!(
        bench
            .service
            .reveal(reveal(&other))
            .await
            .expect("intacte")
            .value
            .expose_secret(),
        b"valeur de beta"
    );
    // La version d'origine reste lisible
    let original = bench
        .service
        .reveal(RevealRequest {
            number: Some(1),
            ..reveal(&first)
        })
        .await
        .expect("version d'origine");
    assert_eq!(original.value.expose_secret(), b"valeur de a");

    // Chaque échec est journalisé (R6), sans valeur
    let journal = bench.journal(Some(ALPHA)).await;
    let corrupted = journal
        .iter()
        .filter(|item| {
            item.event["outcome"] == "denied"
                && item.event["details"]["code"] == "SECRETS_VALUE_CORRUPTED"
        })
        .count();
    assert_eq!(corrupted, 2);
    let text = format!("{journal:?}");
    assert!(!text.contains("valeur de"), "{text}");
}

#[tokio::test]
async fn an_altered_envelope_is_reported_corrupted() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "api/altere").await;
    bench.put(&secret, b"valeur intacte").await;
    let mut stored = sealed(&bench, &secret, 1).await;
    // Un caractère du chiffré change
    let last = stored.envelope.pop().expect("caractère");
    stored.envelope.push(if last == 'A' { 'B' } else { 'A' });
    overwrite(&bench, &secret, 1, &stored).await;
    let error = bench
        .service
        .reveal(reveal(&secret))
        .await
        .expect_err("enveloppe altérée");
    assert_eq!(error.code(), "SECRETS_VALUE_CORRUPTED");
    assert!(!error.to_string().contains("valeur intacte"));
    // Enveloppe tronquée ou mal formée : même refus, jamais une valeur vide
    stored.envelope = format!("enc:v2:{}:AAAA", stored.key_id);
    overwrite(&bench, &secret, 1, &stored).await;
    assert_eq!(
        code(bench.service.reveal(reveal(&secret)).await),
        "SECRETS_VALUE_CORRUPTED"
    );
}

#[tokio::test]
async fn concurrent_writes_are_all_kept_with_consecutive_numbers() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "api/concurrent").await;
    // Trois écritures simultanées : chaque tour de conflit en laisse passer une, trois essais
    // suffisent
    let (a, b, c) = tokio::join!(
        bench.service.put(put(&secret, b"valeur 0")),
        bench.service.put(put(&secret, b"valeur 1")),
        bench.service.put(put(&secret, b"valeur 2")),
    );
    let mut numbers: Vec<i64> = [a, b, c]
        .into_iter()
        .map(|added| added.expect("écriture").version.number)
        .collect();
    numbers.sort_unstable();
    assert_eq!(numbers, vec![1, 2, 3]);
    let mut values = Vec::new();
    for number in 1..=3 {
        let read = bench
            .service
            .reveal(RevealRequest {
                number: Some(number),
                ..reveal(&secret)
            })
            .await
            .expect("version");
        values.push(String::from_utf8(read.value.expose_secret().to_vec()).expect("texte"));
    }
    values.sort();
    assert_eq!(values, vec!["valeur 0", "valeur 1", "valeur 2"]);

    // Écriture conditionnelle : un numéro attendu dépassé est refusé sans nouvel essai
    let stale = bench
        .service
        .put(PutValue {
            expected_version: Some(1),
            ..put(&secret, b"en retard")
        })
        .await;
    assert_eq!(code(stale), "SECRETS_VERSION_CONFLICT");
    let fresh = bench
        .service
        .put(PutValue {
            expected_version: Some(3),
            ..put(&secret, b"a jour")
        })
        .await
        .expect("écriture conditionnelle");
    assert_eq!(fresh.version.number, 4);
    assert_eq!(fresh.version.state, VersionState::Enabled);
}

#[tokio::test]
async fn no_value_or_key_appears_in_debug_or_errors() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "api/debug").await;
    let value = b"valeur-tres-confidentielle";
    let request = put(&secret, value);
    let shown = format!("{request:?}");
    assert!(!shown.contains("confidentielle"), "{shown}");
    bench.service.put(request).await.expect("écriture");
    let read = bench
        .service
        .reveal(reveal(&secret))
        .await
        .expect("lecture");
    let shown = format!("{read:?}");
    assert!(
        shown.contains("REDACTED") && !shown.contains("confidentielle"),
        "{shown}"
    );
    let master = format!("{:?}", bench.master);
    assert!(master.contains("REDACTED"), "{master}");

    let too_large = bench
        .service
        .put(PutValue {
            value: SecretBytes::new(vec![b'z'; 70_000]).expect("valeur"),
            ..put(&secret, b"")
        })
        .await
        .expect_err("trop grande");
    let shown = format!("{too_large:?} {too_large}");
    assert!(!shown.contains("zzzz"), "{shown}");

    // Les enveloppes ne sortent jamais d'une fiche ni d'une liste de versions
    let record = bench
        .store
        .secret_get(SecretGetParams::by_id(secret.clone()))
        .await
        .expect("fiche");
    assert!(!format!("{record:?}").contains("enc:v2"));
    // Ni du journal
    let journal = format!("{:?}", bench.journal(Some(ALPHA)).await);
    assert!(!journal.contains("enc:v2") && !journal.contains("confidentielle"));
}

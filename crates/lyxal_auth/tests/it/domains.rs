//! Vérification des domaines avec un lecteur TXT de test.

use async_trait::async_trait;
use lyxal_auth::models::OrganizationCreateParams;
use lyxal_auth::services::CHALLENGE_PREFIX;
use lyxal_auth::{AuthResult, DomainVerifier, TxtLookup};
use std::collections::HashMap;
use std::sync::Mutex;

use crate::support::installed_store;
use lyxal_surreal::ToSql;

#[derive(Default)]
struct FakeDns {
    records: Mutex<HashMap<String, Vec<String>>>,
}

impl FakeDns {
    fn publish(&self, name: &str, value: &str) {
        self.records
            .lock()
            .expect("verrou")
            .entry(name.to_string())
            .or_default()
            .push(value.to_string());
    }
}

#[async_trait]
impl TxtLookup for &FakeDns {
    async fn txt(&self, name: &str) -> AuthResult<Vec<String>> {
        Ok(self
            .records
            .lock()
            .expect("verrou")
            .get(name)
            .cloned()
            .unwrap_or_default())
    }
}

#[tokio::test]
async fn domain_is_verified_only_with_the_published_challenge() {
    let store = installed_store().await;
    let organization = store
        .organization_create(OrganizationCreateParams {
            slug: "alpha".into(),
            name: "Alpha".into(),
            description: None,
            mfa_required: None,
            owner: None,
        })
        .await
        .expect("organisation");
    let dns = FakeDns::default();
    let verifier = DomainVerifier::new(store, &dns);

    let challenge = verifier
        .declare(&organization.id.to_sql(), "Alpha-BTP.fr")
        .await
        .expect("déclaration");
    assert_eq!(challenge.domain.domain, "alpha-btp.fr");
    assert_eq!(
        challenge.domain.txt_record,
        format!("{CHALLENGE_PREFIX}alpha-btp.fr")
    );
    assert!(!format!("{challenge:?}").contains(challenge.txt_value.expose_secret()));
    let domain_id = challenge.domain.id.to_sql();

    // Aucun enregistrement, puis un enregistrement faux : non vérifié
    let error = verifier.verify(&domain_id).await.expect_err("aucun TXT");
    assert_eq!(error.code(), "AUTH_DOMAIN_NOT_VERIFIED");
    dns.publish(&challenge.domain.txt_record, "v=spf1 -all");
    assert_eq!(
        verifier
            .verify(&domain_id)
            .await
            .expect_err("TXT faux")
            .code(),
        "AUTH_DOMAIN_NOT_VERIFIED"
    );

    // Le jeton publié sous un autre nom ne vérifie pas ce domaine : le nom vient de la base
    dns.publish(
        "_lyxal-challenge.autre.fr",
        challenge.txt_value.expose_secret(),
    );
    assert_eq!(
        verifier
            .verify(&domain_id)
            .await
            .expect_err("autre nom")
            .code(),
        "AUTH_DOMAIN_NOT_VERIFIED"
    );

    // Le jeton publié vérifie le domaine
    dns.publish(
        &challenge.domain.txt_record,
        challenge.txt_value.expose_secret(),
    );
    let verified = verifier.verify(&domain_id).await.expect("vérifié");
    assert_eq!(verified.state, "verified");
    assert!(verified.verified_at.is_some());
}

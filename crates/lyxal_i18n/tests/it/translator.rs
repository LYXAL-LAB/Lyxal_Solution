//! `Translator` et sonde de santé sur base embarquée : clé traduite, repli rendu avec les
//! pluriels de la langue retenue, surcharge d'une organisation, clé manquante, erreurs.

use lyxal_i18n::{
    I18nHealthCheck, I18nStore, KeyCreateParams, KeyParam, MessageArgs, NamespaceCreateParams,
    SettingsUpdateParams, TranslateError, TranslateRequest, TranslationSetParams, Translator,
};
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::ModuleContext;

use crate::support::installed_client;

fn request(key: &str, locale: &str, count: i64) -> TranslateRequest {
    TranslateRequest {
        key: key.to_string(),
        locale: locale.to_string(),
        tenant: None,
        args: MessageArgs::new().integer("count", count),
        zone: "Europe/Paris".to_string(),
    }
}

#[tokio::test]
async fn translator_resolves_then_renders() {
    let client = installed_client().await;
    client
        .query("CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha' }")
        .await
        .expect("organisation")
        .check()
        .expect("organisation créée");
    let store = I18nStore::new(client);
    store
        .namespace_create(NamespaceCreateParams {
            key: "panier".to_string(),
            module: "lyxal_catalogue".to_string(),
            description: None,
            source_locale: Some("en".to_string()),
        })
        .await
        .expect("espace de noms");
    store
        .key_create(KeyCreateParams {
            namespace: "panier".to_string(),
            name: "articles".to_string(),
            source_text: "{count, plural, =0 {No items} one {# item} other {# items}}".to_string(),
            syntax: None,
            description: None,
            params: vec![KeyParam {
                name: "count".to_string(),
                kind: "number".to_string(),
            }],
            max_length: None,
        })
        .await
        .expect("clé");
    let set = |locale: &str, text: &str, tenant: Option<&str>| TranslationSetParams {
        key: "panier.articles".to_string(),
        locale: locale.to_string(),
        text: text.to_string(),
        syntax: None,
        tenant: tenant.map(str::to_string),
    };
    store
        .translation_set(set(
            "fr",
            "{count, plural, =0 {Aucun article} one {# article} other {# articles}}",
            None,
        ))
        .await
        .expect("traduction");
    store
        .translation_set(set(
            "fr",
            "{count, plural, one {# pièce} other {# pièces}}",
            Some("auth_organization:alpha"),
        ))
        .await
        .expect("surcharge");
    let translator = Translator::new(store.clone());

    // Langue demandée, avec repli fr-CA → fr
    let french = translator
        .translate(request("panier.articles", "fr-CA", 0))
        .await
        .expect("traduction");
    assert_eq!(french.text, "Aucun article");
    assert_eq!(french.locale.as_deref(), Some("fr"));
    assert!(!french.missing && !french.overridden);
    // En français, 0 et 1 sont au singulier
    let one = translator
        .translate(request("panier.articles", "fr", 1))
        .await
        .expect("traduction");
    assert_eq!(one.text, "1 article");

    // Langue sans texte : repli sur la langue par défaut (français), rendue avec ses pluriels
    let german = translator
        .translate(request("panier.articles", "de", 2))
        .await
        .expect("repli");
    assert_eq!(german.text, "2 articles");
    assert_eq!(german.locale.as_deref(), Some("fr"));
    // Langue par défaut anglaise : le texte source anglais suit les pluriels anglais
    store
        .settings_update(SettingsUpdateParams {
            default_locale: Some("en".to_string()),
            source_locale: None,
        })
        .await
        .expect("langue par défaut");
    let english = translator
        .translate(request("panier.articles", "de", 0))
        .await
        .expect("repli");
    assert_eq!(english.text, "No items");
    assert_eq!(english.locale.as_deref(), Some("en"));
    let one_item = translator
        .translate(request("panier.articles", "de", 1))
        .await
        .expect("repli");
    assert_eq!(one_item.text, "1 item");

    // Surcharge de l'organisation
    let mut for_alpha = request("panier.articles", "fr", 3);
    for_alpha.tenant = Some("auth_organization:alpha".to_string());
    let overridden = translator.translate(for_alpha).await.expect("surcharge");
    assert_eq!(overridden.text, "3 pièces");
    assert!(overridden.overridden);

    // Clé non déclarée : la clé elle-même, sans erreur
    let missing = translator
        .translate(request("panier.inconnue", "fr", 1))
        .await
        .expect("clé manquante");
    assert_eq!(missing.text, "panier.inconnue");
    assert!(missing.missing && missing.locale.is_none());

    // Argument manquant : erreur de rendu, jamais de texte incomplet
    let mut incomplete = request("panier.articles", "fr", 1);
    incomplete.args = MessageArgs::new();
    match translator.translate(incomplete).await {
        Err(TranslateError::Format(error)) => assert_eq!(error.code(), "I18N_ARGUMENT_MISSING"),
        other => panic!("erreur de rendu attendue : {other:?}"),
    }
    // Paramètre refusé par la base : erreur de la fonction, propagée
    match translator.translate(request("Pas Valide", "fr", 1)).await {
        Err(TranslateError::Store(_)) => {}
        other => panic!("erreur de la base attendue : {other:?}"),
    }
    // Le même Formatter est réutilisé pour une langue
    let first = translator.formatter("fr").expect("langue");
    let second = translator.formatter("fr").expect("langue");
    assert!(std::sync::Arc::ptr_eq(&first, &second));
}

#[tokio::test]
async fn health_check_reports_versions_and_failures() {
    let client = installed_client().await;
    let check = I18nHealthCheck::new(I18nStore::new(client.clone()));
    let context = ModuleContext::new(ModuleId::new(lyxal_i18n::MODULE_ID));
    let healthy = check.check(&context).await.expect("sonde");
    let message = healthy.message.clone().unwrap_or_default();
    assert_eq!(healthy.status, HealthStatus::Healthy, "{message}");
    assert!(message.contains("langue par défaut fr"), "{message}");
    assert!(message.contains("CLDR 49"), "{message}");
    assert!(message.contains("fuseaux horaires"), "{message}");

    // Réglages absents : sonde en échec, avec la cause
    client
        .query("DELETE i18n_settings:installation")
        .await
        .expect("suppression")
        .check()
        .expect("réglages supprimés");
    let broken = check.check(&context).await.expect("sonde");
    assert_eq!(broken.status, HealthStatus::Unhealthy);
    assert!(broken.message.unwrap_or_default().contains("réglages"));
}

//! Parcours complet par `I18nStore` : langues, espace de noms, clé, traductions, surcharge,
//! obsolescence, résolution, clé manquante.

use lyxal_i18n::{
    I18nStore, KeyCreateParams, KeyDeleteParams, KeyListParams, KeyParam, KeyUpdateParams,
    LocaleGetParams, LocaleListParams, LocaleResolveParams, MessageIssue, NamespaceCreateParams,
    PageParams, ResolveManyParams, ResolveParams, SettingsUpdateParams, TranslationDeleteParams,
    TranslationListParams, TranslationReviewParams, TranslationSetParams,
};
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};

use crate::support::installed_client;

fn business_code(error: LyxalSurrealError) -> String {
    match error {
        LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.code,
        other => panic!("erreur métier attendue : {other}"),
    }
}

#[tokio::test]
async fn store_calls_every_public_function() {
    let client = installed_client().await;
    client
        .query("CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha' }")
        .await
        .expect("organisation")
        .check()
        .expect("organisation créée");
    let store = I18nStore::new(client);

    // Langues et réglages
    let listed = store
        .locale_list(LocaleListParams {
            active: Some(true),
            ..Default::default()
        })
        .await
        .expect("langues");
    assert_eq!(listed.total, 2);
    let german = LocaleGetParams {
        locale: "de".to_string(),
    };
    assert!(
        !store
            .locale_get(german.clone())
            .await
            .expect("langue")
            .active
    );
    assert!(
        store
            .locale_activate(german.clone())
            .await
            .expect("activation")
            .active
    );
    assert!(
        !store
            .locale_deactivate(german)
            .await
            .expect("désactivation")
            .active
    );
    assert_eq!(
        store.settings_get().await.expect("réglages").default_locale,
        "fr"
    );
    let settings = store
        .settings_update(SettingsUpdateParams {
            default_locale: Some("fr".to_string()),
            source_locale: None,
        })
        .await
        .expect("réglages modifiés");
    assert_eq!(settings.source_locale, "fr");
    let resolved = store
        .locale_resolve(LocaleResolveParams {
            candidates: vec!["fr-CA".to_string()],
            language: None,
        })
        .await
        .expect("choix de la langue");
    assert_eq!(resolved.locale, "fr");

    // Espace de noms et clé avec son texte source
    let namespace = store
        .namespace_create(NamespaceCreateParams {
            key: "base".to_string(),
            module: "lyxal_base".to_string(),
            description: None,
            source_locale: None,
        })
        .await
        .expect("espace de noms");
    assert_eq!(namespace.key, "base");
    assert_eq!(
        store
            .namespace_list(PageParams::default())
            .await
            .expect("espaces de noms")
            .total,
        1
    );
    let count = KeyParam {
        name: "count".to_string(),
        kind: "number".to_string(),
    };
    let created = store
        .key_create(KeyCreateParams {
            namespace: "base".to_string(),
            name: "panier.articles".to_string(),
            source_text: "{count, plural, one {# article} other {# articles}}".to_string(),
            syntax: None,
            description: Some("Nombre d'articles".to_string()),
            params: vec![count.clone()],
            max_length: None,
        })
        .await
        .expect("clé");
    assert_eq!(created.key.full_key, "base.panier.articles");
    assert_eq!(created.key.params, vec![count.clone()]);
    assert_eq!(
        created.warnings,
        vec![MessageIssue {
            code: "missing_category".to_string(),
            argument: Some("count".to_string()),
            category: Some("many".to_string()),
        }]
    );
    let updated = store
        .key_update(KeyUpdateParams {
            key: "base.panier.articles".to_string(),
            description: None,
            params: None,
            max_length: Some(200),
            clear: Vec::new(),
        })
        .await
        .expect("clé modifiée");
    assert_eq!(updated.max_length, Some(200));
    assert_eq!(updated.description.as_deref(), Some("Nombre d'articles"));
    let cleared = store
        .key_update(KeyUpdateParams {
            key: "base.panier.articles".to_string(),
            description: None,
            params: None,
            max_length: None,
            clear: vec!["description".to_string()],
        })
        .await
        .expect("description effacée");
    assert_eq!(cleared.description, None);
    assert_eq!(cleared.max_length, Some(200));
    let keys = store
        .key_list(KeyListParams {
            namespace: Some("base".to_string()),
            ..Default::default()
        })
        .await
        .expect("clés");
    assert_eq!(keys.total, 1);

    // Traduction, relecture, surcharge d'une organisation
    let english = store
        .translation_set(TranslationSetParams {
            key: "base.panier.articles".to_string(),
            locale: "en".to_string(),
            text: "{count, plural, one {# item} other {# items}}".to_string(),
            syntax: None,
            tenant: None,
        })
        .await
        .expect("traduction");
    assert_eq!(english.translation.state, "translated");
    assert!(english.translation.source_hash.is_some());
    assert!(english.warnings.is_empty());
    let reviewed = store
        .translation_review(TranslationReviewParams {
            key: "base.panier.articles".to_string(),
            locale: "en".to_string(),
            reviewed: true,
            tenant: None,
        })
        .await
        .expect("relecture");
    assert_eq!(reviewed.state, "reviewed");
    let refused = store
        .translation_set(TranslationSetParams {
            key: "base.panier.articles".to_string(),
            locale: "en".to_string(),
            text: "{total} items".to_string(),
            syntax: None,
            tenant: None,
        })
        .await
        .expect_err("texte refusé");
    assert_eq!(business_code(refused), "I18N_TRANSLATION_INVALID");
    let overridden = store
        .translation_set(TranslationSetParams {
            key: "base.panier.articles".to_string(),
            locale: "fr".to_string(),
            text: "{count, plural, one {# pièce} other {# pièces}}".to_string(),
            syntax: None,
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("surcharge");
    assert_eq!(overridden.translation.scope_key, "alpha");

    // Le texte source change : la traduction relue devient obsolète
    store
        .translation_set(TranslationSetParams {
            key: "base.panier.articles".to_string(),
            locale: "fr".to_string(),
            text: "{count, plural, one {# produit} other {# produits}}".to_string(),
            syntax: None,
            tenant: None,
        })
        .await
        .expect("texte source modifié");
    let rows = store
        .translation_list(TranslationListParams {
            locale: "en".to_string(),
            namespace: None,
            tenant: None,
            state: None,
            outdated: Some(true),
            search: None,
            limit: None,
            start: None,
        })
        .await
        .expect("état des traductions");
    assert_eq!(rows.total, 1);
    assert_eq!(rows.items[0].state, "translated");
    assert!(rows.items[0]
        .source_text
        .as_deref()
        .is_some_and(|t| t.contains("produit")));

    // Résolution : surcharge de l'organisation, repli, clé non déclarée
    let for_alpha = store
        .resolve(ResolveParams {
            key: "base.panier.articles".to_string(),
            locale: "fr-CA".to_string(),
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("résolution");
    assert!(for_alpha.overridden);
    assert_eq!(for_alpha.locale.as_deref(), Some("fr"));
    let many = store
        .resolve_many(ResolveManyParams {
            keys: vec![
                "base.inconnue".to_string(),
                "base.panier.articles".to_string(),
            ],
            locale: "en-GB".to_string(),
            tenant: None,
        })
        .await
        .expect("résolutions");
    assert!(many[0].missing && many[0].locale.is_none());
    assert_eq!(many[0].text, "base.inconnue");
    assert_eq!(many[1].locale.as_deref(), Some("en"));
    let missing = store
        .missing_key_list(PageParams::default())
        .await
        .expect("clés manquantes");
    assert_eq!(missing.total, 1);
    assert_eq!(missing.items[0].key, "base.inconnue");
    assert_eq!(missing.items[0].locale, "en-GB");

    // Suppressions
    let deleted = store
        .translation_delete(TranslationDeleteParams {
            key: "base.panier.articles".to_string(),
            locale: "en".to_string(),
            tenant: None,
        })
        .await
        .expect("traduction supprimée");
    assert!(deleted.deleted);
    let source = store
        .translation_delete(TranslationDeleteParams {
            key: "base.panier.articles".to_string(),
            locale: "fr".to_string(),
            tenant: None,
        })
        .await
        .expect_err("texte source protégé");
    assert_eq!(business_code(source), "I18N_SOURCE_REQUIRED");
    let removed = store
        .key_delete(KeyDeleteParams {
            key: "base.panier.articles".to_string(),
        })
        .await
        .expect("clé supprimée");
    assert!(removed.deleted);
    assert_eq!(removed.translations, 2);
}

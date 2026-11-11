//! Échange par fichier sur base embarquée : aller-retour JSON et XLIFF, caractères à échapper,
//! texte relu protégé, fichier illisible, texte refusé par le rendu, contrôle de tous les textes.

use lyxal_i18n::{
    Exchange, ExchangeError, ExportOptions, FileFormat, I18nStore, ImportOptions, KeyCreateParams,
    KeyParam, NamespaceCreateParams, TranslationReviewParams, TranslationSetParams,
};

use crate::support::installed_client;

async fn prepared() -> (I18nStore, Exchange) {
    let client = installed_client().await;
    client
        .query("CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha' }")
        .await
        .expect("organisation")
        .check()
        .expect("organisation créée");
    let store = I18nStore::new(client);
    for (key, source_locale) in [("base", None), ("console", Some("en"))] {
        store
            .namespace_create(NamespaceCreateParams {
                key: key.to_string(),
                module: "lyxal_base".to_string(),
                description: None,
                source_locale: source_locale.map(str::to_string),
            })
            .await
            .expect("espace de noms");
    }
    let key = |namespace: &str, name: &str, text: &str, syntax: &str, params: Vec<KeyParam>| {
        KeyCreateParams {
            namespace: namespace.to_string(),
            name: name.to_string(),
            source_text: text.to_string(),
            syntax: Some(syntax.to_string()),
            description: Some(format!("Contexte de {name} <&>")),
            params,
            max_length: None,
        }
    };
    let count = KeyParam {
        name: "count".to_string(),
        kind: "number".to_string(),
    };
    for params in [
        key("base", "oui", "Oui", "plain", vec![]),
        key(
            "base",
            "articles",
            "{count, plural, one {# article} other {# articles}}",
            "icu_mf1",
            vec![count],
        ),
        key(
            "base",
            "citation",
            "Il a dit « oui » & c'est <tout>",
            "plain",
            vec![],
        ),
        key("console", "save", "Save", "plain", vec![]),
    ] {
        store.key_create(params).await.expect("clé");
    }
    (store.clone(), Exchange::new(store))
}

fn options(locale: &str) -> ImportOptions {
    ImportOptions {
        locale: locale.to_string(),
        tenant: None,
        overwrite_reviewed: false,
        dry_run: false,
    }
}

async fn exported(
    exchange: &Exchange,
    locale: &str,
    namespace: Option<&str>,
    format: FileFormat,
) -> String {
    let mut output = Vec::new();
    exchange
        .export(
            &ExportOptions {
                locale: locale.to_string(),
                namespace: namespace.map(str::to_string),
                tenant: None,
            },
            format,
            &mut output,
        )
        .await
        .expect("export");
    String::from_utf8(output).expect("UTF-8")
}

async fn text(store: &I18nStore, key: &str, locale: &str) -> Option<String> {
    let rows = store
        .export(lyxal_i18n::ExportParams {
            locale: locale.to_string(),
            namespace: None,
            tenant: None,
            limit: None,
            start: None,
        })
        .await
        .expect("textes");
    rows.items.into_iter().find(|row| row.key == key)?.text
}

#[tokio::test]
async fn json_round_trip_and_import_rules() {
    let (store, exchange) = prepared().await;

    // Export de la langue source : seules les clés traduites, triées, une par ligne
    let french = exported(&exchange, "fr", Some("base"), FileFormat::Json).await;
    assert_eq!(
        french,
        "{\n  \"base.articles\": \"{count, plural, one {# article} other {# articles}}\",\n  \"base.citation\": \"Il a dit « oui » & c'est <tout>\",\n  \"base.oui\": \"Oui\"\n}\n"
    );
    assert_eq!(
        exported(&exchange, "de", Some("base"), FileFormat::Json).await,
        "{}\n"
    );

    // Import en anglais : créés, clé inconnue signalée, texte refusé par le rendu non écrit
    let english = r#"{
  "base.oui": "Yes",
  "base.articles": "{count, plural, one {# item} other {# items}}",
  "base.citation": "He said \"yes\" & that's <all>",
  "base.inconnue": "Unknown",
  "console.save": 42
}"#;
    let report = exchange
        .import(&options("en"), FileFormat::Json, &mut english.as_bytes())
        .await
        .expect("import");
    assert_eq!(
        (report.created, report.updated, report.unchanged),
        (3, 0, 0)
    );
    assert_eq!(report.skipped.len(), 1);
    assert_eq!(report.skipped[0].key, "base.inconnue");
    assert_eq!(report.skipped[0].reason, "key_not_found");
    assert_eq!(report.rejected.len(), 1);
    assert_eq!(report.rejected[0].key.as_deref(), Some("console.save"));
    assert!(report.invalid.is_empty() && report.has_failures());
    assert_eq!(
        text(&store, "base.citation", "en").await.as_deref(),
        Some("He said \"yes\" & that's <all>")
    );

    // Aller-retour : le fichier exporté, réimporté, ne change rien
    let round_trip = exported(&exchange, "en", Some("base"), FileFormat::Json).await;
    let again = exchange
        .import(&options("en"), FileFormat::Json, &mut round_trip.as_bytes())
        .await
        .expect("réimport");
    assert_eq!((again.created, again.updated, again.unchanged), (0, 0, 3));
    assert!(!again.has_failures());

    // Texte relu protégé, puis écrasé sur demande
    store
        .translation_review(TranslationReviewParams {
            key: "base.oui".to_string(),
            locale: "en".to_string(),
            reviewed: true,
            tenant: None,
        })
        .await
        .expect("relecture");
    let change = r#"{ "base.oui": "Yep" }"#;
    let protected = exchange
        .import(&options("en"), FileFormat::Json, &mut change.as_bytes())
        .await
        .expect("import");
    assert_eq!(protected.skipped[0].reason, "reviewed");
    assert_eq!(text(&store, "base.oui", "en").await.as_deref(), Some("Yes"));
    let mut forced = options("en");
    forced.overwrite_reviewed = true;
    let overwritten = exchange
        .import(&forced, FileFormat::Json, &mut change.as_bytes())
        .await
        .expect("import forcé");
    assert_eq!(overwritten.updated, 1);
    assert_eq!(text(&store, "base.oui", "en").await.as_deref(), Some("Yep"));

    // Essai : rapport sans écriture
    let mut trial = options("de");
    trial.dry_run = true;
    let dry = exchange
        .import(
            &trial,
            FileFormat::Json,
            &mut r#"{ "base.oui": "Ja" }"#.as_bytes(),
        )
        .await
        .expect("essai");
    assert_eq!(dry.created, 1);
    assert_eq!(text(&store, "base.oui", "de").await, None);

    // Texte refusé : par le rendu (accolade non fermée), par la base (argument inconnu)
    let broken = r#"{
  "base.articles": "{count, plural, one {# item} other {# items}",
  "base.oui": "Si"
}"#;
    let refused = exchange
        .import(&options("es"), FileFormat::Json, &mut broken.as_bytes())
        .await
        .expect("import");
    assert_eq!(refused.created, 1);
    assert_eq!(refused.invalid.len(), 1);
    assert_eq!(refused.invalid[0].key, "base.articles");
    assert_eq!(
        refused.invalid[0].error.as_ref().map(|error| error.code()),
        Some("I18N_MESSAGE_INVALID")
    );
    assert_eq!(text(&store, "base.articles", "es").await, None);
    let unknown = r#"{ "base.articles": "{total, plural, one {# item} other {# items}}" }"#;
    let by_database = exchange
        .import(&options("es"), FileFormat::Json, &mut unknown.as_bytes())
        .await
        .expect("import");
    assert_eq!(by_database.invalid[0].problems[0].code, "unknown_argument");
    assert_eq!(
        by_database.invalid[0].problems[0].argument.as_deref(),
        Some("total")
    );
    assert!(by_database.invalid[0].error.is_none());

    // Surcharge d'une organisation : la portée de l'import, sans toucher l'installation
    let mut for_alpha = options("fr");
    for_alpha.tenant = Some("auth_organization:alpha".to_string());
    let overridden = exchange
        .import(
            &for_alpha,
            FileFormat::Json,
            &mut r#"{ "base.oui": "Oui chef" }"#.as_bytes(),
        )
        .await
        .expect("import de l'organisation");
    assert_eq!(overridden.created, 1);
    assert_eq!(text(&store, "base.oui", "fr").await.as_deref(), Some("Oui"));

    // Première surcharge d'une clé dont le texte de l'installation est en texte brut : elle sera
    // écrite dans la syntaxe du texte source (ICU), c'est donc elle que le rendu vérifie
    store
        .translation_set(TranslationSetParams {
            key: "base.articles".to_string(),
            locale: "fr-CA".to_string(),
            text: "{count} articles".to_string(),
            syntax: Some("plain".to_string()),
            tenant: None,
        })
        .await
        .expect("texte brut de l'installation");
    let mut alpha_canada = options("fr-CA");
    alpha_canada.tenant = Some("auth_organization:alpha".to_string());
    let first_override = exchange
        .import(
            &alpha_canada,
            FileFormat::Json,
            &mut r#"{ "base.articles": "{count, plural, one {# article} other {# articles}" }"#
                .as_bytes(),
        )
        .await
        .expect("import de l'organisation");
    assert_eq!(first_override.created, 0);
    assert_eq!(
        first_override.invalid[0]
            .error
            .as_ref()
            .map(|error| error.code()),
        Some("I18N_MESSAGE_INVALID"),
        "{first_override:?}"
    );
}

#[tokio::test]
async fn unreadable_files_write_nothing() {
    let (store, exchange) = prepared().await;
    for source in ["", "[1, 2]", r#"{ "base.oui": "Yes""#, "pas du JSON"] {
        let report = exchange
            .import(&options("en"), FileFormat::Json, &mut source.as_bytes())
            .await
            .expect("fichier rejeté");
        assert_eq!(
            report.created + report.updated + report.unchanged,
            0,
            "{source}"
        );
        assert_eq!(report.rejected.len(), 1, "{source}");
    }
    let broken_xml = "<xliff><file><unit id=\"base.oui\"><segment><target>Yes</target>";
    match exchange
        .import(
            &options("en"),
            FileFormat::Xliff,
            &mut broken_xml.as_bytes(),
        )
        .await
    {
        Err(ExchangeError::Parse(_)) => {}
        other => panic!("erreur de lecture attendue : {other:?}"),
    }
    assert_eq!(text(&store, "base.oui", "en").await, None);
    // Langue illisible par le rendu : refusée avant toute écriture
    match exchange
        .import(
            &options("pas une langue"),
            FileFormat::Json,
            &mut "{}".as_bytes(),
        )
        .await
    {
        Err(ExchangeError::Store(_)) | Err(ExchangeError::Format(_)) => {}
        other => panic!("erreur attendue : {other:?}"),
    }
}

#[tokio::test]
async fn xliff_round_trip() {
    let (store, exchange) = prepared().await;
    store
        .translation_set(TranslationSetParams {
            key: "base.oui".to_string(),
            locale: "en".to_string(),
            text: "Yes".to_string(),
            syntax: None,
            tenant: None,
        })
        .await
        .expect("traduction");
    let file = exported(&exchange, "en", Some("base"), FileFormat::Xliff).await;
    assert!(file.starts_with(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xliff xmlns=\"urn:oasis:names:tc:xliff:document:2.0\" version=\"2.0\" srcLang=\"fr\" trgLang=\"en\">\n  <file id=\"base\">\n"
    ));
    assert!(
        file.contains("<notes><note>Contexte de citation &lt;&amp;&gt;</note></notes>"),
        "{file}"
    );
    assert!(
        file.contains("<source>Il a dit « oui » &amp; c&apos;est &lt;tout&gt;</source>"),
        "{file}"
    );
    assert!(file.contains("<segment state=\"translated\">\n        <source>Oui</source>\n        <target>Yes</target>"), "{file}");
    assert!(file.contains("<segment state=\"initial\">\n        <source>{count, plural, one {# article} other {# articles}}</source>\n      </segment>"), "{file}");

    // Le traducteur remplit les cibles ; le fichier réimporté crée les textes manquants
    let translated = file
        .replace(
            "<source>{count, plural, one {# article} other {# articles}}</source>\n",
            "<source>{count, plural, one {# article} other {# articles}}</source>\n        <target>{count, plural, one {# item} other {# items}}</target>\n",
        )
        .replace(
            "<source>Il a dit « oui » &amp; c&apos;est &lt;tout&gt;</source>\n",
            "<source>Il a dit « oui » &amp; c&apos;est &lt;tout&gt;</source>\n        <target>He said &quot;yes&quot; &amp; that&apos;s &lt;all&gt;</target>\n",
        );
    let report = exchange
        .import(
            &options("en"),
            FileFormat::Xliff,
            &mut translated.as_bytes(),
        )
        .await
        .expect("import");
    assert_eq!(
        (report.created, report.updated, report.unchanged),
        (2, 0, 1)
    );
    assert!(!report.has_failures(), "{report:?}");
    assert_eq!(
        text(&store, "base.citation", "en").await.as_deref(),
        Some("He said \"yes\" & that's <all>")
    );
    assert_eq!(
        text(&store, "base.articles", "en").await.as_deref(),
        Some("{count, plural, one {# item} other {# items}}")
    );

    // Retour chariot : écrit en référence de caractère, sinon le lecteur XML le remplace par
    // un saut de ligne et le texte réimporté diffère
    store
        .translation_set(TranslationSetParams {
            key: "base.citation".to_string(),
            locale: "en".to_string(),
            text: "Line one\r\nline two\rend".to_string(),
            syntax: None,
            tenant: None,
        })
        .await
        .expect("texte avec retours chariot");
    let windows = exported(&exchange, "en", Some("base"), FileFormat::Xliff).await;
    assert!(
        windows.contains("<target>Line one&#13;\nline two&#13;end</target>"),
        "{windows}"
    );
    let same = exchange
        .import(&options("en"), FileFormat::Xliff, &mut windows.as_bytes())
        .await
        .expect("réimport");
    assert_eq!((same.created, same.updated, same.unchanged), (0, 0, 3));
    assert_eq!(
        text(&store, "base.citation", "en").await.as_deref(),
        Some("Line one\r\nline two\rend")
    );

    // Unité sans identifiant, élément en ligne, plusieurs segments : rejetés, le reste importé
    let partial = r#"<?xml version="1.0" encoding="UTF-8"?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" version="2.0" srcLang="fr" trgLang="de">
  <file id="base">
    <unit><segment><source>Oui</source><target>Ja</target></segment></unit>
    <unit id="base.citation"><segment><source>x</source><target>Er sagte <ph id="1"/> ja</target></segment></unit>
    <unit id="base.articles"><segment><source>a</source><target>b</target></segment><segment><source>c</source><target>d</target></segment></unit>
    <unit id="base.oui"><segment><source>Oui</source><target>Ja</target></segment></unit>
  </file>
</xliff>"#;
    let report = exchange
        .import(&options("de"), FileFormat::Xliff, &mut partial.as_bytes())
        .await
        .expect("import partiel");
    assert_eq!(report.created, 1);
    assert_eq!(report.rejected.len(), 3, "{report:?}");
    assert_eq!(report.rejected[1].key.as_deref(), Some("base.citation"));
    assert!(report.rejected[1].cause.contains("élément en ligne"));
    assert_eq!(text(&store, "base.oui", "de").await.as_deref(), Some("Ja"));

    // Textes sources en plusieurs langues : un espace de noms à la fois
    let mut output = Vec::new();
    match exchange
        .export(
            &ExportOptions {
                locale: "en".to_string(),
                namespace: None,
                tenant: None,
            },
            FileFormat::Xliff,
            &mut output,
        )
        .await
    {
        Err(ExchangeError::MixedSourceLocales(locales)) => assert_eq!(locales, "en, fr"),
        other => panic!("erreur attendue : {other:?}"),
    }
    assert_eq!(FileFormat::parse("xliff"), Some(FileFormat::Xliff));
    assert_eq!(FileFormat::parse("po"), None);
}

#[tokio::test]
async fn check_lists_texts_the_renderer_refuses() {
    let (store, exchange) = prepared().await;
    let clean = exchange.check().await.expect("contrôle");
    assert_eq!(clean.checked, 4);
    assert!(clean.invalid.is_empty());

    // Texte que le contrôle de la base accepte (accolades équilibrées, argument déclaré) mais
    // que le rendu refuse (branche de pluriel sans contenu valide)
    store
        .translation_set(TranslationSetParams {
            key: "base.articles".to_string(),
            locale: "en".to_string(),
            text: "{count, plural, one {# item} other {# items}}".to_string(),
            syntax: None,
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("surcharge");
    store
        .client()
        .query("UPDATE i18n_translation:['base.articles', 'en', 'alpha'] SET text = '{count, number, ::currency/EUR}'")
        .await
        .expect("écriture directe")
        .check()
        .expect("texte modifié");
    let report = exchange.check().await.expect("contrôle");
    assert_eq!(report.checked, 5);
    assert_eq!(report.invalid.len(), 1);
    let invalid = &report.invalid[0];
    assert_eq!(invalid.key, "base.articles");
    assert_eq!(invalid.locale, "en");
    assert_eq!(invalid.tenant.as_deref(), Some("auth_organization:alpha"));
    assert_eq!(invalid.error.code(), "I18N_MESSAGE_INVALID");
}
